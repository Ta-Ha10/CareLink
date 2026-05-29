import 'package:carelink/services/firestore_service.dart';
import 'package:carelink/models/user_model.dart';
import 'package:carelink/core/exceptions.dart';
import 'package:carelink/core/constants.dart';

/// User Repository
/// Handles user profile management and user-related operations
class UserRepository {
  final FirestoreService _firestoreService;

  UserRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  /// Get user by ID
  Future<UserModel> getUserById({required String uid}) async {
    try {
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

  /// Get user by email
  Future<UserModel?> getUserByEmail({required String email}) async {
    try {
      final result = await _firestoreService.queryDocuments(
        collection: FirestoreCollections.users,
        conditions: [QueryCondition(field: 'email', value: email)],
        limit: 1,
      );

      if (result.docs.isEmpty) {
        return null;
      }

      return UserModel.fromJson(result.docs.first.data());
    } catch (e) {
      rethrow;
    }
  }

  /// Stream user profile
  Stream<UserModel> streamUser({required String uid}) {
    return _firestoreService
        .streamDocuments(
          collection: FirestoreCollections.users,
          conditions: [QueryCondition(field: 'uid', value: uid)],
          limit: 1,
        )
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            throw FirestoreException.documentNotFound(uid);
          }
          return UserModel.fromJson(snapshot.docs.first.data());
        });
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (name != null && name.isNotEmpty) {
        updateData['name'] = name;
      }
      if (phone != null) {
        updateData['phone'] = phone;
      }
      if (photoUrl != null) {
        updateData['photoUrl'] = photoUrl;
      }

      if (updateData.isNotEmpty) {
        updateData['updatedAt'] = DateTime.now();

        await _firestoreService.updateDocument(
          collection: FirestoreCollections.users,
          docId: uid,
          data: updateData,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Update user online status
  Future<void> updateOnlineStatus({
    required String uid,
    required bool isOnline,
  }) async {
    try {
      await _firestoreService.updateDocument(
        collection: FirestoreCollections.users,
        docId: uid,
        data: {
          'isOnline': isOnline,
          'updatedAt': DateTime.now(),
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get all monitors for a patient (stream)
  Stream<List<UserModel>> streamPatientMonitors({required String patientId}) {
    return _firestoreService
        .streamDocuments(
          collection: FirestoreCollections.users,
          conditions: [
            QueryCondition(field: 'role', value: 'monitor'),
          ],
        )
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => UserModel.fromJson(doc.data()))
              .toList();
        });
  }

  /// Get all patients monitored by a specific monitor (stream)
  Stream<List<UserModel>> streamMonitorPatients({required String monitorId}) {
    return _firestoreService
        .streamDocuments(
          collection: FirestoreCollections.users,
          conditions: [
            QueryCondition(field: 'role', value: 'patient'),
          ],
        )
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => UserModel.fromJson(doc.data()))
              .where((user) => user.connectedMonitorId == monitorId)
              .toList();
        });
  }

  /// Update FCM token for notifications
  Future<void> updateFcmToken({
    required String uid,
    required String token,
  }) async {
    try {
      await _firestoreService.updateDocument(
        collection: FirestoreCollections.users,
        docId: uid,
        data: {
          'fcmToken': token,
          'updatedAt': DateTime.now(),
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Link monitor to patient
  Future<void> connectMonitorToPatient({
    required String patientId,
    required String monitorId,
  }) async {
    try {
      await _firestoreService.updateDocument(
        collection: FirestoreCollections.users,
        docId: patientId,
        data: {
          'connectedMonitorId': monitorId,
          'updatedAt': DateTime.now(),
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Disconnect monitor from patient
  Future<void> disconnectMonitorFromPatient({required String patientId}) async {
    try {
      await _firestoreService.updateDocument(
        collection: FirestoreCollections.users,
        docId: patientId,
        data: {
          'connectedMonitorId': null,
          'updatedAt': DateTime.now(),
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
