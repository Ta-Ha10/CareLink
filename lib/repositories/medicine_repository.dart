import 'package:carelink/services/firestore_service.dart';
import 'package:carelink/models/medicine_model.dart';
import 'package:carelink/core/exceptions.dart';
import 'package:carelink/core/constants.dart';

/// Medicine Repository
/// Handles medicine CRUD operations and reminders
class MedicineRepository {
  final FirestoreService _firestoreService;
  static const String _subcollectionName = 'medicines';

  MedicineRepository({required FirestoreService firestoreService})
    : _firestoreService = firestoreService;

  /// Create new medicine reminder
  Future<String> createMedicine({
    required String connectionId,
    required String patientId,
    required String monitorId,
    required String medicineName,
    required String dosage,
    required String time,
    required bool repeatDaily,
    required String createdBy,
    String? notes,
    List<String>? daysOfWeek,
  }) async {
    try {
      final medicine = MedicineModel(
        id: '', // Will be set by Firestore
        connectionId: connectionId,
        patientId: patientId,
        monitorId: monitorId,
        medicineName: medicineName,
        dosage: dosage,
        time: time,
        repeatDaily: repeatDaily,
        notes: notes,
        createdBy: createdBy,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        daysOfWeek: daysOfWeek,
        lastReminderKey: null,
        lastReminderAt: null,
      );

      final ref = await _firestoreService.createSubcollectionDocument(
        parentCollection: FirestoreCollections.connections,
        parentDocId: connectionId,
        collection: _subcollectionName,
        data: medicine.toJson(),
      );

      return ref.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Get medicine by ID
  Future<MedicineModel> getMedicineById({
    required String connectionId,
    required String medicineId,
  }) async {
    try {
      final doc = await _firestoreService.getDocument(
        collection:
            '${FirestoreCollections.connections}/$connectionId/$_subcollectionName',
        docId: medicineId,
      );

      if (!doc.exists) {
        throw FirestoreException.documentNotFound(medicineId);
      }

      return MedicineModel.fromJson(doc.data()!, medicineId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all medicines for a patient
  Future<List<MedicineModel>> getConnectionMedicines({
    required String connectionId,
    bool onlyActive = true,
  }) async {
    try {
      final conditions = <QueryCondition>[];
      if (onlyActive) {
        conditions.add(QueryCondition(field: 'isActive', value: true));
      }

      final result = await _firestoreService.querySubcollectionDocuments(
        parentCollection: FirestoreCollections.connections,
        parentDocId: connectionId,
        collection: _subcollectionName,
        conditions: conditions,
      );

      final medicines = result.docs
          .map((doc) => MedicineModel.fromJson(doc.data(), doc.id))
          .toList();

      medicines.sort(_compareByTime);
      return medicines;
    } catch (e) {
      rethrow;
    }
  }

  /// Stream medicines for a patient (real-time updates)
  Stream<List<MedicineModel>> streamConnectionMedicines({
    required String connectionId,
    bool onlyActive = true,
  }) {
    try {
      final conditions = <QueryCondition>[];
      if (onlyActive) {
        conditions.add(QueryCondition(field: 'isActive', value: true));
      }

      return _firestoreService
          .streamSubcollectionDocuments(
            parentCollection: FirestoreCollections.connections,
            parentDocId: connectionId,
            collection: _subcollectionName,
            conditions: conditions,
          )
          .map((snapshot) {
            final medicines = snapshot.docs
                .map((doc) => MedicineModel.fromJson(doc.data(), doc.id))
                .toList();
            medicines.sort(_compareByTime);
            return medicines;
          });
    } catch (e) {
      return Stream.error(e);
    }
  }

  /// Update medicine details
  Future<void> updateMedicine({
    required String connectionId,
    required String medicineId,
    String? medicineName,
    String? dosage,
    String? time,
    bool? repeatDaily,
    String? notes,
    List<String>? daysOfWeek,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (medicineName != null) updateData['medicineName'] = medicineName;
      if (dosage != null) updateData['dosage'] = dosage;
      if (time != null) updateData['time'] = time;
      if (repeatDaily != null) updateData['repeatDaily'] = repeatDaily;
      if (notes != null) updateData['notes'] = notes;
      if (daysOfWeek != null) updateData['daysOfWeek'] = daysOfWeek;

      if (updateData.isNotEmpty) {
        updateData['updatedAt'] = DateTime.now();

        await _firestoreService.updateDocument(
          collection:
              '${FirestoreCollections.connections}/$connectionId/$_subcollectionName',
          docId: medicineId,
          data: updateData,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Enable/disable medicine reminder
  Future<void> toggleMedicineActive({
    required String connectionId,
    required String medicineId,
    required bool isActive,
  }) async {
    try {
      await _firestoreService.updateDocument(
        collection:
            '${FirestoreCollections.connections}/$connectionId/$_subcollectionName',
        docId: medicineId,
        data: {'isActive': isActive, 'updatedAt': DateTime.now()},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Delete medicine reminder
  Future<void> deleteMedicine({
    required String connectionId,
    required String medicineId,
  }) async {
    try {
      await _firestoreService.deleteDocument(
        collection:
            '${FirestoreCollections.connections}/$connectionId/$_subcollectionName',
        docId: medicineId,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get upcoming medicines for a patient (within next N hours)
  Future<List<MedicineModel>> getUpcomingMedicines({
    required String connectionId,
    int hoursAhead = 24,
  }) async {
    try {
      final medicines = await getConnectionMedicines(
        connectionId: connectionId,
        onlyActive: true,
      );

      // Filter medicines with times within the next N hours
      // This is a client-side filter as Firestore can't directly query by time string
      return medicines.where((medicine) {
        final parts = medicine.time.split(':');
        final medicineHour = int.parse(parts[0]);
        final medicineMinute = int.parse(parts[1]);

        final now = DateTime.now();
        final medicineDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          medicineHour,
          medicineMinute,
        );

        final timeDiff = medicineDateTime.difference(now);
        return timeDiff.isNegative == false && timeDiff.inHours <= hoursAhead;
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  int _compareByTime(MedicineModel a, MedicineModel b) {
    return _timeToMinutes(a.time).compareTo(_timeToMinutes(b.time));
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    if (parts.length < 2) {
      return 0;
    }

    final hour = int.tryParse(parts[0]) ?? 0;
    final minutePart = parts[1].split(' ').first;
    final minute = int.tryParse(minutePart) ?? 0;
    final isPm = time.toUpperCase().contains('PM');
    final isAm = time.toUpperCase().contains('AM');

    var normalizedHour = hour;
    if (isPm && normalizedHour < 12) {
      normalizedHour += 12;
    }
    if (isAm && normalizedHour == 12) {
      normalizedHour = 0;
    }

    return normalizedHour * 60 + minute;
  }
}
