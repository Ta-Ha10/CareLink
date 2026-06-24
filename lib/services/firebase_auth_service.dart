import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:carelink/core/exceptions.dart';

/// Firebase Authentication Service
/// Handles all authentication operations including signup, login, logout, and password reset
class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthService({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// Get current authenticated user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Get current user ID
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  /// Check if user is authenticated
  bool get isAuthenticated => _firebaseAuth.currentUser != null;

  /// Get current user email
  String? get currentUserEmail => _firebaseAuth.currentUser?.email;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Register new user with email and password
  ///
  /// Throws [AuthException] if registration fails
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        throw AuthException(
          message: 'Email and password cannot be empty',
          code: 'empty-fields',
        );
      }

      if (password.length < 6) {
        throw AuthException.weakPassword();
      }

      // Register user
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException.generic('Registration failed: ${e.toString()}');
    }
  }

  /// Login user with email and password
  ///
  /// Throws [AuthException] if login fails
  Future<UserCredential> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        throw AuthException(
          message: 'Email and password cannot be empty',
          code: 'empty-fields',
        );
      }

      // Login user
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException.generic('Login failed: ${e.toString()}');
    }
  }

  /// Verify an email/password pair without changing the active auth session.
  Future<VerifiedAuthUser> verifyEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw AuthException(
          message: 'Email and password cannot be empty',
          code: 'empty-fields',
        );
      }

      final apiKey = Firebase.app().options.apiKey;
      final response = await http.post(
        Uri.https(
          'identitytoolkit.googleapis.com',
          '/v1/accounts:signInWithPassword',
          {'key': apiKey},
        ),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
          'returnSecureToken': true,
        }),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 400) {
        throw _handleIdentityToolkitError(body);
      }

      return VerifiedAuthUser(
        uid: body['localId'] as String? ?? '',
        email: body['email'] as String? ?? email.trim(),
        idToken: body['idToken'] as String?,
      );
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException.generic(
        'Failed to verify credentials: ${e.toString()}',
      );
    }
  }

  /// Logout current user
  ///
  /// Throws [AuthException] if logout fails
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException.generic('Logout failed: ${e.toString()}');
    }
  }

  /// Send password reset email
  ///
  /// Throws [AuthException] if operation fails
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      if (email.isEmpty) {
        throw AuthException(
          message: 'Email cannot be empty',
          code: 'empty-email',
        );
      }

      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException.generic(
        'Failed to send reset email: ${e.toString()}',
      );
    }
  }

  /// Confirm password reset with new password
  ///
  /// Throws [AuthException] if operation fails
  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    try {
      if (code.isEmpty || newPassword.isEmpty) {
        throw AuthException(
          message: 'Code and password cannot be empty',
          code: 'empty-fields',
        );
      }

      if (newPassword.length < 6) {
        throw AuthException.weakPassword();
      }

      await _firebaseAuth.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException.generic('Failed to reset password: ${e.toString()}');
    }
  }

  /// Update user email
  ///
  /// Throws [AuthException] if operation fails
  Future<void> updateEmail({required String newEmail}) async {
    try {
      if (newEmail.isEmpty) {
        throw AuthException(
          message: 'Email cannot be empty',
          code: 'empty-email',
        );
      }

      if (currentUser == null) {
        throw AuthException(message: 'No user logged in', code: 'no-user');
      }

      await currentUser!.verifyBeforeUpdateEmail(newEmail.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException.generic('Failed to update email: ${e.toString()}');
    }
  }

  /// Update user password
  ///
  /// Throws [AuthException] if operation fails
  Future<void> updatePassword({required String newPassword}) async {
    try {
      if (newPassword.isEmpty) {
        throw AuthException(
          message: 'Password cannot be empty',
          code: 'empty-password',
        );
      }

      if (newPassword.length < 6) {
        throw AuthException.weakPassword();
      }

      if (currentUser == null) {
        throw AuthException(message: 'No user logged in', code: 'no-user');
      }

      await currentUser!.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException.generic('Failed to update password: ${e.toString()}');
    }
  }

  /// Delete current user account
  ///
  /// Throws [AuthException] if operation fails
  Future<void> deleteAccount() async {
    try {
      if (currentUser == null) {
        throw AuthException(message: 'No user logged in', code: 'no-user');
      }

      await currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException.generic('Failed to delete account: ${e.toString()}');
    }
  }

  /// Check if email is verified
  bool isEmailVerified() => currentUser?.emailVerified ?? false;

  /// Send email verification
  ///
  /// Throws [AuthException] if operation fails
  Future<void> sendEmailVerification() async {
    try {
      if (currentUser == null) {
        throw AuthException(message: 'No user logged in', code: 'no-user');
      }

      await currentUser!.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException.generic(
        'Failed to send verification email: ${e.toString()}',
      );
    }
  }

  /// Handle Firebase Authentication exceptions
  AuthException _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException.userNotFound();
      case 'wrong-password':
        return AuthException.wrongPassword();
      case 'email-already-in-use':
        return AuthException.emailAlreadyInUse();
      case 'weak-password':
        return AuthException.weakPassword();
      case 'invalid-email':
        return AuthException.invalidEmail();
      case 'user-disabled':
        return AuthException.userDisabled();
      case 'operation-not-allowed':
        return AuthException(
          message: 'This operation is not allowed',
          code: e.code,
        );
      case 'too-many-requests':
        return AuthException(
          message: 'Too many attempts. Please try again later.',
          code: e.code,
        );
      default:
        return AuthException.generic(
          e.message ?? 'Authentication error',
          code: e.code,
        );
    }
  }

  AuthException _handleIdentityToolkitError(Map<String, dynamic> body) {
    final error = body['error'];
    final message = error is Map<String, dynamic>
        ? error['message']?.toString()
        : null;

    switch (message) {
      case 'EMAIL_NOT_FOUND':
        return AuthException.userNotFound();
      case 'INVALID_PASSWORD':
      case 'INVALID_LOGIN_CREDENTIALS':
        return AuthException.wrongPassword();
      case 'USER_DISABLED':
        return AuthException.userDisabled();
      case 'TOO_MANY_ATTEMPTS_TRY_LATER':
        return AuthException(
          message: 'Too many attempts. Please try again later.',
          code: 'too-many-requests',
        );
      case 'INVALID_EMAIL':
        return AuthException.invalidEmail();
      default:
        return AuthException.generic(
          message ?? 'Authentication error',
          code: 'auth-error',
        );
    }
  }
}

class VerifiedAuthUser {
  final String uid;
  final String email;
  final String? idToken;

  const VerifiedAuthUser({
    required this.uid,
    required this.email,
    this.idToken,
  });
}
