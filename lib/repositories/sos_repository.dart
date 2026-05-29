import 'package:carelink/services/firestore_service.dart';
import 'package:carelink/models/sos_alert_model.dart';
import 'package:carelink/core/exceptions.dart';
import 'package:carelink/core/constants.dart';

/// SOS Alert Repository
/// Handles emergency alert creation and management
class SosRepository {
  final FirestoreService _firestoreService;

  SosRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  /// Create a new SOS alert
  Future<String> createSosAlert({
    required String patientId,
    required String monitorId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final sosAlert = SosAlertModel(
        id: '',
        patientId: patientId,
        monitorId: monitorId,
        latitude: latitude,
        longitude: longitude,
        status: SosStatus.active,
        createdAt: DateTime.now(),
      );

      final ref = await _firestoreService.createDocument(
        collection: FirestoreCollections.sosAlerts,
        data: sosAlert.toJson(),
      );

      return ref.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Get SOS alert by ID
  Future<SosAlertModel> getSosAlertById({required String alertId}) async {
    try {
      final doc = await _firestoreService.getDocument(
        collection: FirestoreCollections.sosAlerts,
        docId: alertId,
      );

      if (!doc.exists) {
        throw FirestoreException.documentNotFound(alertId);
      }

      return SosAlertModel.fromJson(doc.data()!, alertId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get active SOS alerts for a patient
  Future<List<SosAlertModel>> getPatientActiveSosAlerts({
    required String patientId,
  }) async {
    try {
      final result = await _firestoreService.queryDocuments(
        collection: FirestoreCollections.sosAlerts,
        conditions: [
          QueryCondition(field: 'patientId', value: patientId),
          QueryCondition(field: 'status', value: 'active'),
        ],
        orderBy: 'createdAt',
        descending: true,
      );

      return result.docs
          .map((doc) => SosAlertModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Stream active SOS alerts for a monitor
  Stream<List<SosAlertModel>> streamMonitorActiveSosAlerts({
    required String monitorId,
  }) {
    try {
      return _firestoreService
          .streamDocuments(
            collection: FirestoreCollections.sosAlerts,
            conditions: [
              QueryCondition(field: 'monitorId', value: monitorId),
              QueryCondition(field: 'status', value: 'active'),
            ],
            orderBy: 'createdAt',
            descending: true,
          )
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => SosAlertModel.fromJson(doc.data(), doc.id))
                .toList();
          });
    } catch (e) {
      return Stream.error(e);
    }
  }

  /// Resolve SOS alert
  Future<void> resolveSosAlert({
    required String alertId,
    String? resolutionNotes,
  }) async {
    try {
      await _firestoreService.updateDocument(
        collection: FirestoreCollections.sosAlerts,
        docId: alertId,
        data: {
          'status': 'resolved',
          'resolvedAt': DateTime.now(),
          'resolutionNotes': resolutionNotes,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get all SOS alerts for a patient (including resolved)
  Future<List<SosAlertModel>> getPatientSosHistory({
    required String patientId,
    int limit = 50,
  }) async {
    try {
      final result = await _firestoreService.queryDocuments(
        collection: FirestoreCollections.sosAlerts,
        conditions: [
          QueryCondition(field: 'patientId', value: patientId),
        ],
        orderBy: 'createdAt',
        descending: true,
        limit: limit,
      );

      return result.docs
          .map((doc) => SosAlertModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Stream SOS alerts for a patient (including resolved)
  Stream<List<SosAlertModel>> streamPatientSosAlerts({
    required String patientId,
    int limit = 50,
  }) {
    try {
      return _firestoreService
          .streamDocuments(
            collection: FirestoreCollections.sosAlerts,
            conditions: [
              QueryCondition(field: 'patientId', value: patientId),
            ],
            orderBy: 'createdAt',
            descending: true,
            limit: limit,
          )
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => SosAlertModel.fromJson(doc.data(), doc.id))
                .toList();
          });
    } catch (e) {
      return Stream.error(e);
    }
  }

  /// Get recent active SOS alerts
  Future<List<SosAlertModel>> getRecentActiveSosAlerts({
    int limitMinutes = 30,
  }) async {
    try {
      final result = await _firestoreService.queryDocuments(
        collection: FirestoreCollections.sosAlerts,
        conditions: [
          QueryCondition(field: 'status', value: 'active'),
        ],
        orderBy: 'createdAt',
        descending: true,
      );

      final now = DateTime.now();
      final timeThreshold = Duration(minutes: limitMinutes);

      return result.docs
          .map((doc) => SosAlertModel.fromJson(doc.data(), doc.id))
          .where((alert) => now.difference(alert.createdAt).compareTo(timeThreshold) < 0)
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get SOS statistics for a patient
  Future<Map<String, int>> getSosStatistics({
    required String patientId,
  }) async {
    try {
      final alerts = await getPatientSosHistory(patientId: patientId);

      final activeCount = alerts.where((alert) => alert.status == SosStatus.active).length;
      final resolvedCount = alerts.where((alert) => alert.status == SosStatus.resolved).length;

      return {
        'total': alerts.length,
        'active': activeCount,
        'resolved': resolvedCount,
      };
    } catch (e) {
      rethrow;
    }
  }
}
