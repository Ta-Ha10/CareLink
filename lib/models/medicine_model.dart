import 'package:cloud_firestore/cloud_firestore.dart';

/// Medicine model for patient medication reminders
class MedicineModel {
  final String id;
  final String connectionId;
  final String patientId;
  final String monitorId;
  final String medicineName;
  final String dosage;
  final String time; // Format: HH:mm (24-hour format)
  final bool repeatDaily;
  final String? notes;
  final String createdBy; // UID of who created this medicine entry
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String>? daysOfWeek; // Optional: specific days if not daily
  final String? lastReminderKey;
  final DateTime? lastReminderAt;

  const MedicineModel({
    required this.id,
    required this.connectionId,
    required this.patientId,
    required this.monitorId,
    required this.medicineName,
    required this.dosage,
    required this.time,
    required this.repeatDaily,
    this.notes,
    required this.createdBy,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.daysOfWeek,
    this.lastReminderKey,
    this.lastReminderAt,
  });

  /// Create MedicineModel from Firestore document
  factory MedicineModel.fromJson(Map<String, dynamic> json, String docId) {
    return MedicineModel(
      id: docId,
      connectionId: json['connectionId'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      monitorId: json['monitorId'] as String? ?? '',
      medicineName: json['medicineName'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      time: json['time'] as String? ?? '09:00',
      repeatDaily: json['repeatDaily'] as bool? ?? true,
      notes: json['notes'] as String?,
      createdBy: json['createdBy'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
      daysOfWeek: List<String>.from(json['daysOfWeek'] as List? ?? []),
      lastReminderKey: json['lastReminderKey'] as String?,
      lastReminderAt: (json['lastReminderAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert MedicineModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'connectionId': connectionId,
      'patientId': patientId,
      'monitorId': monitorId,
      'medicineName': medicineName,
      'dosage': dosage,
      'time': time,
      'repeatDaily': repeatDaily,
      'notes': notes,
      'createdBy': createdBy,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt ?? DateTime.now()),
      'daysOfWeek': daysOfWeek ?? [],
      'lastReminderKey': lastReminderKey,
      'lastReminderAt': lastReminderAt != null
          ? Timestamp.fromDate(lastReminderAt!)
          : null,
    };
  }

  /// Create a copy with updated fields
  MedicineModel copyWith({
    String? id,
    String? connectionId,
    String? patientId,
    String? monitorId,
    String? medicineName,
    String? dosage,
    String? time,
    bool? repeatDaily,
    String? notes,
    String? createdBy,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? daysOfWeek,
    String? lastReminderKey,
    DateTime? lastReminderAt,
  }) {
    return MedicineModel(
      id: id ?? this.id,
      connectionId: connectionId ?? this.connectionId,
      patientId: patientId ?? this.patientId,
      monitorId: monitorId ?? this.monitorId,
      medicineName: medicineName ?? this.medicineName,
      dosage: dosage ?? this.dosage,
      time: time ?? this.time,
      repeatDaily: repeatDaily ?? this.repeatDaily,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      lastReminderKey: lastReminderKey ?? this.lastReminderKey,
      lastReminderAt: lastReminderAt ?? this.lastReminderAt,
    );
  }

  @override
  String toString() =>
      'MedicineModel(id: $id, medicineName: $medicineName, time: $time)';
}
