import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';

/// SOS Alert model for emergency situations
class SosAlertModel {
  final String id;
  final String patientId;
  final String monitorId;
  final double latitude;
  final double longitude;
  final SosStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? resolutionNotes;

  const SosAlertModel({
    required this.id,
    required this.patientId,
    required this.monitorId,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    this.resolutionNotes,
  });

  /// Create SosAlertModel from Firestore document
  factory SosAlertModel.fromJson(Map<String, dynamic> json, String docId) {
    return SosAlertModel(
      id: docId,
      patientId: json['patientId'] as String? ?? '',
      monitorId: json['monitorId'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      status: SosStatus.fromString(json['status'] as String? ?? 'active'),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolvedAt: (json['resolvedAt'] as Timestamp?)?.toDate(),
      resolutionNotes: json['resolutionNotes'] as String?,
    );
  }

  /// Convert SosAlertModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'monitorId': monitorId,
      'latitude': latitude,
      'longitude': longitude,
      'status': status.value,
      'createdAt': Timestamp.fromDate(createdAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'resolutionNotes': resolutionNotes,
    };
  }

  /// Create a copy with updated fields
  SosAlertModel copyWith({
    String? id,
    String? patientId,
    String? monitorId,
    double? latitude,
    double? longitude,
    SosStatus? status,
    DateTime? createdAt,
    DateTime? resolvedAt,
    String? resolutionNotes,
  }) {
    return SosAlertModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      monitorId: monitorId ?? this.monitorId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
    );
  }

  @override
  String toString() => 'SosAlertModel(id: $id, patientId: $patientId, status: ${status.value})';
}
