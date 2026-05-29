import 'package:firebase_auth/firebase_auth.dart';
import 'package:carelink/services/firebase_auth_service.dart';
import 'package:carelink/services/firestore_service.dart';
import 'package:carelink/models/user_model.dart';
import 'package:carelink/core/exceptions.dart';
import 'package:carelink/core/constants.dart';

/// Authentication Repository
/// Handles authentication business logic and user creation in Firestore
class AuthRepository {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  AuthRepository({
    required FirebaseAuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService;

  /// Get current user ID
  String? get currentUserId => _authService.currentUserId;

  /// Get current authenticated user
  User? get currentUser => _authService.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _authService.isAuthenticated;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  /// Register new user with email, password, and role
  /// Creates both Firebase Auth account and Firestore user document
  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
  }) async {
    try {
      // Validate inputs
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        throw ValidationException.missingField('name, email, or password');
      }

      if (name.length < 2) {
        throw ValidationException.invalidInput('name must be at least 2 characters');
      }

      // Register with Firebase Auth
      final userCredential = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) {
        throw AuthException.generic('Failed to create user account');
      }

      // Create user document in Firestore
      final user = UserModel(
        uid: uid,
        name: name,
        email: email,
        role: role,
        phone: phone,
        isOnline: true,
        createdAt: DateTime.now(),
      );

      try {
        await _firestoreService.createDocument(
          collection: FirestoreCollections.users,
          customId: uid,
          data: user.toJson(),
        );
      } catch (e) {
        // Log Firestore write error but don't fail registration
        // Auth user is already created successfully
        print('Warning: Failed to create Firestore user document: $e');
      }

      return user;
    } catch (e) {
      // If Auth creation fails, rethrow
      rethrow;
    }
  }

  /// Login user using Firebase Auth
  /// Returns user data from auth or Firestore if available
  Future<UserModel> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Login with Firebase Auth
      await _authService.loginWithEmailAndPassword(
        email: email,
        password: password,
      );

      final authUser = _authService.currentUser;
      final uid = authUser?.uid;
      if (uid == null) {
        throw AuthException.generic('Login failed: no user found');
      }

      // Try to get user document from Firestore, but don't fail if it doesn't exist
      UserModel? firestoreUser;
      try {
        final userDoc = await _firestoreService.getDocument(
          collection: FirestoreCollections.users,
          docId: uid,
        );
        
        if (userDoc.exists) {
          firestoreUser = UserModel.fromJson(userDoc.data()!);
          
          // Update online status
          await _firestoreService.updateDocument(
            collection: FirestoreCollections.users,
            docId: uid,
            data: {'isOnline': true, 'updatedAt': DateTime.now()},
          );
        }
      } catch (e) {
        // Firestore is optional - continue with auth user data
        print('Note: Could not access Firestore: $e');
      }

      // If we have Firestore user data, use it; otherwise create from auth
      return firestoreUser ??
          UserModel(
            uid: uid,
            name: authUser?.email?.split('@')[0] ?? 'User',
            email: authUser?.email ?? '',
            role: UserRole.patient, // Default role
            isOnline: true,
            createdAt: DateTime.now(),
          );
    } catch (e) {
      rethrow;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      final uid = _authService.currentUserId;

      // Try to update offline status in Firestore (optional)
      if (uid != null) {
        try {
          await _firestoreService.updateDocument(
            collection: FirestoreCollections.users,
            docId: uid,
            data: {'isOnline': false, 'updatedAt': DateTime.now()},
          );
        } catch (e) {
          // Firestore update is optional - continue with logout
          print('Note: Could not update offline status: $e');
        }
      }

      await _authService.logout();
    } catch (e) {
      rethrow;
    }
  }

  /// Get current user profile
  Future<UserModel> getCurrentUserProfile() async {
    try {
      final uid = _authService.currentUserId;
      if (uid == null) {
        throw AuthException(
          message: 'No user logged in',
          code: 'no-user',
        );
      }

      final userDoc = await _firestoreService.getDocument(
        collection: FirestoreCollections.users,
        docId: uid,
      );

      if (!userDoc.exists) {
        throw FirestoreException.documentNotFound(uid);
      }

      return UserModel.fromJson(userDoc.data()!);
    } catch (e) {
      rethrow;
    }
  }

  /// Stream current user profile changes
  Stream<UserModel?> streamCurrentUserProfile() {
    final uid = _authService.currentUserId;
    if (uid == null) {
      return Stream.error(
        AuthException(message: 'No user logged in', code: 'no-user'),
      );
    }

    return _firestoreService
        .streamDocuments(
          collection: FirestoreCollections.users,
          conditions: [QueryCondition(field: 'uid', value: uid)],
        )
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return UserModel.fromJson(snapshot.docs.first.data());
        });
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _authService.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  /// Update FCM token for push notifications
  Future<void> updateFcmToken({required String token}) async {
    try {
      final uid = _authService.currentUserId;
      if (uid == null) {
        throw AuthException(message: 'No user logged in', code: 'no-user');
      }

      await _firestoreService.updateDocument(
        collection: FirestoreCollections.users,
        docId: uid,
        data: {'fcmToken': token, 'updatedAt': DateTime.now()},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Delete user account and all associated data
  Future<void> deleteAccount({required String uid}) async {
    try {
      // Delete user document from Firestore
      await _firestoreService.deleteDocument(
        collection: FirestoreCollections.users,
        docId: uid,
      );

      // Delete Firebase Auth account
      await _authService.deleteAccount();
    } catch (e) {
      rethrow;
    }
  }
}
