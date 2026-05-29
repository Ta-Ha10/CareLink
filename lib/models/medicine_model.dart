import 'package:cloud_firestore/cloud_firestore.dart';

/// Medicine model for patient medication reminders
class MedicineModel {
  final String id;
  final String patientId;
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

  const MedicineModel({
    required this.id,
    required this.patientId,
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
  });

  /// Create MedicineModel from Firestore document
  factory MedicineModel.fromJson(Map<String, dynamic> json, String docId) {
    return MedicineModel(
      id: docId,
      patientId: json['patientId'] as String? ?? '',
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
    );
  }

  /// Convert MedicineModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
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
    };
  }

  /// Create a copy with updated fields
  MedicineModel copyWith({
    String? id,
    String? patientId,
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
  }) {
    return MedicineModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
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
    );
  }

  @override
  String toString() => 'MedicineModel(id: $id, medicineName: $medicineName, time: $time)';
}
