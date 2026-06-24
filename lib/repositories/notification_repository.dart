import 'package:carelink/services/firestore_service.dart';
import 'package:carelink/models/notification_model.dart';
import 'package:carelink/core/exceptions.dart';
import 'package:carelink/core/constants.dart';

/// Notification Repository
/// Handles notification CRUD and streaming operations
class NotificationRepository {
  final FirestoreService _firestoreService;

  NotificationRepository({required FirestoreService firestoreService})
    : _firestoreService = firestoreService;

  /// Create a new notification
  Future<String> createNotification({
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final notification = NotificationModel(
        id: '',
        userId: userId,
        title: title,
        message: message,
        type: type,
        isRead: false,
        createdAt: DateTime.now(),
        metadata: metadata,
      );

      final ref = await _firestoreService.createDocument(
        collection: FirestoreCollections.notifications,
        data: notification.toJson(),
      );

      return ref.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Get notification by ID
  Future<NotificationModel> getNotificationById({
    required String notificationId,
  }) async {
    try {
      final doc = await _firestoreService.getDocument(
        collection: FirestoreCollections.notifications,
        docId: notificationId,
      );

      if (!doc.exists) {
        throw FirestoreException.documentNotFound(notificationId);
      }

      return NotificationModel.fromJson(doc.data()!, notificationId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all notifications for a user
  Future<List<NotificationModel>> getUserNotifications({
    required String userId,
    int limit = 50,
    bool unreadOnly = false,
  }) async {
    try {
      final result = await _firestoreService.queryDocuments(
        collection: FirestoreCollections.notifications,
        conditions: [QueryCondition(field: 'userId', value: userId)],
      );

      final notifications =
          result.docs
              .map((doc) => NotificationModel.fromJson(doc.data(), doc.id))
              .where(
                (notification) => !unreadOnly || notification.isRead == false,
              )
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return notifications.take(limit).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Stream notifications for a user (real-time)
  Stream<List<NotificationModel>> streamUserNotifications({
    required String userId,
    int limit = 50,
    bool unreadOnly = false,
  }) {
    try {
      return _firestoreService
          .streamDocuments(
            collection: FirestoreCollections.notifications,
            conditions: [QueryCondition(field: 'userId', value: userId)],
          )
          .map((snapshot) {
            final notifications =
                snapshot.docs
                    .map(
                      (doc) => NotificationModel.fromJson(doc.data(), doc.id),
                    )
                    .where(
                      (notification) =>
                          !unreadOnly || notification.isRead == false,
                    )
                    .toList()
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return notifications.take(limit).toList();
          });
    } catch (e) {
      return Stream.error(e);
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead({required String notificationId}) async {
    try {
      await _firestoreService.updateDocument(
        collection: FirestoreCollections.notifications,
        docId: notificationId,
        data: {'isRead': true},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Mark all notifications as read for a user
  Future<void> markAllNotificationsAsRead({required String userId}) async {
    try {
      final unreadNotifications = await getUserNotifications(
        userId: userId,
        unreadOnly: true,
      );

      if (unreadNotifications.isEmpty) return;

      final operations = unreadNotifications
          .map(
            (notification) => BatchUpdateOperation(
              collection: FirestoreCollections.notifications,
              docId: notification.id,
              data: {'isRead': true},
            ),
          )
          .toList();

      if (operations.isNotEmpty) {
        await _firestoreService.batchWrite(operations);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Delete notification
  Future<void> deleteNotification({required String notificationId}) async {
    try {
      await _firestoreService.deleteDocument(
        collection: FirestoreCollections.notifications,
        docId: notificationId,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Delete all notifications for a user
  Future<void> deleteAllNotificationsForUser({required String userId}) async {
    try {
      final notifications = await getUserNotifications(userId: userId);

      if (notifications.isEmpty) return;

      final operations = notifications
          .map(
            (notification) => BatchDeleteOperation(
              collection: FirestoreCollections.notifications,
              docId: notification.id,
            ),
          )
          .toList();

      if (operations.isNotEmpty) {
        await _firestoreService.batchWrite(operations);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount({required String userId}) async {
    try {
      final result = await _firestoreService.queryDocuments(
        collection: FirestoreCollections.notifications,
        conditions: [QueryCondition(field: 'userId', value: userId)],
      );

      return result.docs
          .map((doc) => NotificationModel.fromJson(doc.data(), doc.id))
          .where((notification) => notification.isRead == false)
          .length;
    } catch (e) {
      rethrow;
    }
  }

  /// Stream unread count
  Stream<int> streamUnreadCount({required String userId}) {
    return _firestoreService
        .streamDocuments(
          collection: FirestoreCollections.notifications,
          conditions: [QueryCondition(field: 'userId', value: userId)],
        )
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => NotificationModel.fromJson(doc.data(), doc.id))
              .where((notification) => notification.isRead == false)
              .length;
        });
  }

  /// Create medicine notification
  Future<String> createMedicineNotification({
    required String userId,
    required String medicineName,
    required String dosage,
  }) {
    return createNotification(
      userId: userId,
      title: 'Medicine Reminder',
      message: 'Take $medicineName ($dosage)',
      type: NotificationType.medicine,
      metadata: {'medicineName': medicineName, 'dosage': dosage},
    );
  }

  /// Create activity notification
  Future<String> createActivityNotification({
    required String userId,
    required String activityTitle,
    required String activityDescription,
    required String activityTime,
  }) {
    return createNotification(
      userId: userId,
      title: 'Activity Update',
      message: '$activityTitle - $activityDescription at $activityTime',
      type: NotificationType.activity,
      metadata: {
        'activityTitle': activityTitle,
        'activityDescription': activityDescription,
        'activityTime': activityTime,
      },
    );
  }

  /// Create SOS notification
  Future<String> createSosNotification({
    required String userId,
    required String patientName,
    required double latitude,
    required double longitude,
  }) {
    return createNotification(
      userId: userId,
      title: 'SOS Alert',
      message: '$patientName has triggered an emergency alert',
      type: NotificationType.sos,
      metadata: {
        'patientName': patientName,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }

  /// Create warning notification
  Future<String> createWarningNotification({
    required String userId,
    required String title,
    required String message,
  }) {
    return createNotification(
      userId: userId,
      title: title,
      message: message,
      type: NotificationType.warning,
    );
  }
}
