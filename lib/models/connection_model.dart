import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';

/// Connection model linking patients with monitors
class ConnectionModel {
  final String id;
  final String patientId;
  final String monitorId;
  final String inviteCode;
  final ConnectionStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final String? patientName; // Denormalized for quick access
  final String? monitorName; // Denormalized for quick access

  const ConnectionModel({
    required this.id,
    required this.patientId,
    required this.monitorId,
    required this.inviteCode,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.patientName,
    this.monitorName,
  });

  /// Create ConnectionModel from Firestore document
  factory ConnectionModel.fromJson(Map<String, dynamic> json, String docId) {
    return ConnectionModel(
      id: docId,
      patientId: json['patientId'] as String? ?? '',
      monitorId: json['monitorId'] as String? ?? '',
      inviteCode: json['inviteCode'] as String? ?? '',
      status: ConnectionStatus.fromString(json['status'] as String? ?? 'pending'),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      acceptedAt: (json['acceptedAt'] as Timestamp?)?.toDate(),
      patientName: json['patientName'] as String?,
      monitorName: json['monitorName'] as String?,
    );
  }

  /// Convert ConnectionModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'monitorId': monitorId,
      'inviteCode': inviteCode,
      'status': status.value,
      'createdAt': Timestamp.fromDate(createdAt),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'patientName': patientName,
      'monitorName': monitorName,
    };
  }

  /// Create a copy with updated fields
  ConnectionModel copyWith({
    String? id,
    String? patientId,
    String? monitorId,
    String? inviteCode,
    ConnectionStatus? status,
    DateTime? createdAt,
    DateTime? acceptedAt,
    String? patientName,
    String? monitorName,
  }) {
    return ConnectionModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      monitorId: monitorId ?? this.monitorId,
      inviteCode: inviteCode ?? this.inviteCode,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      patientName: patientName ?? this.patientName,
      monitorName: monitorName ?? this.monitorName,
    );
  }

  @override
  String toString() => 'ConnectionModel(id: $id, patientId: $patientId, monitorId: $monitorId, status: ${status.value})';
}
