import 'package:carelink/services/firestore_service.dart';
import 'package:carelink/models/connection_model.dart';
import 'package:carelink/core/exceptions.dart';
import 'package:carelink/core/constants.dart';
import 'dart:math';

/// Connection Repository
/// Handles patient-monitor connections and invite codes
class ConnectionRepository {
  final FirestoreService _firestoreService;

  ConnectionRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  /// Generate a unique 6-character invite code
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// Create a connection request from monitor to patient
  Future<String> createConnectionRequest({
    required String patientId,
    required String monitorId,
    String? patientName,
    String? monitorName,
  }) async {
    try {
      final inviteCode = _generateInviteCode();

      final connection = ConnectionModel(
        id: '',
        patientId: patientId,
        monitorId: monitorId,
        inviteCode: inviteCode,
        status: ConnectionStatus.pending,
        createdAt: DateTime.now(),
        patientName: patientName,
        monitorName: monitorName,
      );

      final ref = await _firestoreService.createDocument(
        collection: FirestoreCollections.connections,
        data: connection.toJson(),
      );

      return ref.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Get connection by ID
  Future<ConnectionModel> getConnectionById({
    required String connectionId,
  }) async {
    try {
      final doc = await _firestoreService.getDocument(
        collection: FirestoreCollections.connections,
        docId: connectionId,
      );

      if (!doc.exists) {
        throw FirestoreException.documentNotFound(connectionId);
      }

      return ConnectionModel.fromJson(doc.data()!, connectionId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get connection by invite code
  Future<ConnectionModel?> getConnectionByInviteCode({
    required String inviteCode,
  }) async {
    try {
      final result = await _firestoreService.queryDocuments(
        collection: FirestoreCollections.connections,
        conditions: [
          QueryCondition(field: 'inviteCode', value: inviteCode.toUpperCase()),
        ],
        limit: 1,
      );

      if (result.docs.isEmpty) {
        return null;
      }

      return ConnectionModel.fromJson(result.docs.first.data(), result.docs.first.id);
    } catch (e) {
      rethrow;
    }
  }

  /// Get connections for a patient
  Future<List<ConnectionModel>> getPatientConnections({
    required String patientId,
    ConnectionStatus? status,
  }) async {
    try {
      final conditions = [
        QueryCondition(field: 'patientId', value: patientId),
      ];

      if (status != null) {
        conditions.add(QueryCondition(field: 'status', value: status.value));
      }

      final result = await _firestoreService.queryDocuments(
        collection: FirestoreCollections.connections,
        conditions: conditions,
        orderBy: 'createdAt',
        descending: true,
      );

      return result.docs
          .map((doc) => ConnectionModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get connections for a monitor
  Future<List<ConnectionModel>> getMonitorConnections({
    required String monitorId,
    ConnectionStatus? status,
  }) async {
    try {
      final conditions = [
        QueryCondition(field: 'monitorId', value: monitorId),
      ];

      if (status != null) {
        conditions.add(QueryCondition(field: 'status', value: status.value));
      }

      final result = await _firestoreService.queryDocuments(
        collection: FirestoreCollections.connections,
        conditions: conditions,
        orderBy: 'createdAt',
        descending: true,
      );

      return result.docs
          .map((doc) => ConnectionModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Stream patient connections (real-time)
  Stream<List<ConnectionModel>> streamPatientConnections({
    required String patientId,
    ConnectionStatus? status,
  }) {
    try {
      final conditions = [
        QueryCondition(field: 'patientId', value: patientId),
      ];

      if (status != null) {
        conditions.add(QueryCondition(field: 'status', value: status.value));
      }

      return _firestoreService
          .streamDocuments(
            collection: FirestoreCollections.connections,
            conditions: conditions,
            orderBy: 'createdAt',
            descending: true,
          )
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => ConnectionModel.fromJson(doc.data(), doc.id))
                .toList();
          });
    } catch (e) {
      return Stream.error(e);
    }
  }

  /// Stream monitor connections (real-time)
  Stream<List<ConnectionModel>> streamMonitorConnections({
    required String monitorId,
    ConnectionStatus? status,
  }) {
    try {
      final conditions = [
        QueryCondition(field: 'monitorId', value: monitorId),
      ];

      if (status != null) {
        conditions.add(QueryCondition(field: 'status', value: status.value));
      }

      return _firestoreService
          .streamDocuments(
            collection: FirestoreCollections.connections,
            conditions: conditions,
            orderBy: 'createdAt',
            descending: true,
          )
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => ConnectionModel.fromJson(doc.data(), doc.id))
                .toList();
          });
    } catch (e) {
      return Stream.error(e);
    }
  }

  /// Accept connection request
  Future<void> acceptConnection({
    required String connectionId,
  }) async {
    try {
      await _firestoreService.updateDocument(
        collection: FirestoreCollections.connections,
        docId: connectionId,
        data: {
          'status': ConnectionStatus.active.value,
          'acceptedAt': DateTime.now(),
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Reject connection request
  Future<void> rejectConnection({
    required String connectionId,
  }) async {
    try {
      await _firestoreService.updateDocument(
        collection: FirestoreCollections.connections,
        docId: connectionId,
        data: {
          'status': ConnectionStatus.rejected.value,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Terminate active connection
  Future<void> terminateConnection({
    required String connectionId,
  }) async {
    try {
      await _firestoreService.updateDocument(
        collection: FirestoreCollections.connections,
        docId: connectionId,
        data: {
          'status': ConnectionStatus.terminated.value,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Check if patient and monitor are connected
  Future<bool> areConnected({
    required String patientId,
    required String monitorId,
  }) async {
    try {
      final connections = await getPatientConnections(
        patientId: patientId,
        status: ConnectionStatus.active,
      );

      return connections.any((conn) => conn.monitorId == monitorId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get connection status between patient and monitor
  Future<ConnectionStatus?> getConnectionStatus({
    required String patientId,
    required String monitorId,
  }) async {
    try {
      final connections = await getPatientConnections(patientId: patientId);

      final connection =
          connections.firstWhere((conn) => conn.monitorId == monitorId, orElse: () => ConnectionModel(
            id: '',
            patientId: patientId,
            monitorId: monitorId,
            inviteCode: '',
            status: ConnectionStatus.pending,
            createdAt: DateTime.now(),
          ));

      return connection.id.isEmpty ? null : connection.status;
    } catch (e) {
      rethrow;
    }
  }

  /// Get pending connection requests for a patient
  Future<List<ConnectionModel>> getPendingConnectionRequests({
    required String patientId,
  }) {
    return getPatientConnections(
      patientId: patientId,
      status: ConnectionStatus.pending,
    );
  }

  /// Get all active monitors for a patient
  Future<List<ConnectionModel>> getActiveMonitorsForPatient({
    required String patientId,
  }) {
    return getPatientConnections(
      patientId: patientId,
      status: ConnectionStatus.active,
    );
  }

  /// Get all patients monitored by a monitor
  Future<List<ConnectionModel>> getPatientsMonitoredBy({
    required String monitorId,
  }) {
    return getMonitorConnections(
      monitorId: monitorId,
      status: ConnectionStatus.active,
    );
  }

  /// Delete connection (hard delete)
  Future<void> deleteConnection({
    required String connectionId,
  }) async {
    try {
      await _firestoreService.deleteDocument(
        collection: FirestoreCollections.connections,
        docId: connectionId,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get connection statistics
  Future<Map<String, int>> getConnectionStatistics({
    required String userId,
    required UserRole role,
  }) async {
    try {
      final List<ConnectionModel> connections;

      if (role == UserRole.patient) {
        connections = await getPatientConnections(patientId: userId);
      } else {
        connections = await getMonitorConnections(monitorId: userId);
      }

      final stats = {
        'total': connections.length,
        'active': connections.where((c) => c.status == ConnectionStatus.active).length,
        'pending': connections.where((c) => c.status == ConnectionStatus.pending).length,
        'rejected': connections.where((c) => c.status == ConnectionStatus.rejected).length,
        'terminated': connections.where((c) => c.status == ConnectionStatus.terminated).length,
      };

      return stats;
    } catch (e) {
      rethrow;
    }
  }
}
