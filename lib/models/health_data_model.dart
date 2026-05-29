import 'package:cloud_firestore/cloud_firestore.dart';

/// Health Data model for storing patient health metrics
class HealthDataModel {
  final String id;
  final String patientId;
  final int? heartRate;
  final int? steps;
  final double? sleepHours;
  final double? temperature;
  final DateTime recordedAt;
  final DateTime? synceAt; // When the data was synced to server

  const HealthDataModel({
    required this.id,
    required this.patientId,
    this.heartRate,
    this.steps,
    this.sleepHours,
    this.temperature,
    required this.recordedAt,
    this.synceAt,
  });

  /// Create HealthDataModel from Firestore document
  factory HealthDataModel.fromJson(Map<String, dynamic> json, String docId) {
    return HealthDataModel(
      id: docId,
      patientId: json['patientId'] as String? ?? '',
      heartRate: json['heartRate'] as int?,
      steps: json['steps'] as int?,
      sleepHours: (json['sleepHours'] as num?)?.toDouble(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      recordedAt: (json['recordedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      synceAt: (json['synceAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert HealthDataModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'heartRate': heartRate,
      'steps': steps,
      'sleepHours': sleepHours,
      'temperature': temperature,
      'recordedAt': Timestamp.fromDate(recordedAt),
      'synceAt': synceAt != null ? Timestamp.fromDate(synceAt!) : Timestamp.fromDate(DateTime.now()),
    };
  }

  /// Create a copy with updated fields
  HealthDataModel copyWith({
    String? id,
    String? patientId,
    int? heartRate,
    int? steps,
    double? sleepHours,
    double? temperature,
    DateTime? recordedAt,
    DateTime? synceAt,
  }) {
    return HealthDataModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      heartRate: heartRate ?? this.heartRate,
      steps: steps ?? this.steps,
      sleepHours: sleepHours ?? this.sleepHours,
      temperature: temperature ?? this.temperature,
      recordedAt: recordedAt ?? this.recordedAt,
      synceAt: synceAt ?? this.synceAt,
    );
  }

  @override
  String toString() => 'HealthDataModel(id: $id, patientId: $patientId, heartRate: $heartRate)';
}
