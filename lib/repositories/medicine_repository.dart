import 'package:carelink/services/firestore_service.dart';
import 'package:carelink/models/medicine_model.dart';
import 'package:carelink/core/exceptions.dart';
import 'package:carelink/core/constants.dart';

/// Medicine Repository
/// Handles medicine CRUD operations and reminders
class MedicineRepository {
  final FirestoreService _firestoreService;

  MedicineRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  /// Create new medicine reminder
  Future<String> createMedicine({
    required String patientId,
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
        patientId: patientId,
        medicineName: medicineName,
        dosage: dosage,
        time: time,
        repeatDaily: repeatDaily,
        notes: notes,
        createdBy: createdBy,
        isActive: true,
        createdAt: DateTime.now(),
        daysOfWeek: daysOfWeek,
      );

      final ref = await _firestoreService.createDocument(
        collection: FirestoreCollections.medicines,
        data: medicine.toJson(),
      );

      return ref.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Get medicine by ID
  Future<MedicineModel> getMedicineById({required String medicineId}) async {
    try {
      final doc = await _firestoreService.getDocument(
        collection: FirestoreCollections.medicines,
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
  Future<List<MedicineModel>> getPatientMedicines({
    required String patientId,
    bool onlyActive = true,
  }) async {
    try {
      final conditions = [
        QueryCondition(field: 'patientId', value: patientId),
      ];

      if (onlyActive) {
        conditions.add(QueryCondition(field: 'isActive', value: true));
      }

      final result = await _firestoreService.queryDocuments(
        collection: FirestoreCollections.medicines,
        conditions: conditions,
        orderBy: 'time',
      );

      return result.docs
          .map((doc) => MedicineModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Stream medicines for a patient (real-time updates)
  Stream<List<MedicineModel>> streamPatientMedicines({
    required String patientId,
    bool onlyActive = true,
  }) {
    try {
      final conditions = [
        QueryCondition(field: 'patientId', value: patientId),
      ];

      if (onlyActive) {
        conditions.add(QueryCondition(field: 'isActive', value: true));
      }

      return _firestoreService
          .streamDocuments(
            collection: FirestoreCollections.medicines,
            conditions: conditions,
            orderBy: 'time',
          )
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => MedicineModel.fromJson(doc.data(), doc.id))
                .toList();
          });
    } catch (e) {
      return Stream.error(e);
    }
  }

  /// Update medicine details
  Future<void> updateMedicine({
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
          collection: FirestoreCollections.medicines,
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
    required String medicineId,
    required bool isActive,
  }) async {
    try {
      await _firestoreService.updateDocument(
        collection: FirestoreCollections.medicines,
        docId: medicineId,
        data: {
          'isActive': isActive,
          'updatedAt': DateTime.now(),
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Delete medicine reminder
  Future<void> deleteMedicine({required String medicineId}) async {
    try {
      await _firestoreService.deleteDocument(
        collection: FirestoreCollections.medicines,
        docId: medicineId,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get upcoming medicines for a patient (within next N hours)
  Future<List<MedicineModel>> getUpcomingMedicines({
    required String patientId,
    int hoursAhead = 24,
  }) async {
    try {
      final medicines = await getPatientMedicines(
        patientId: patientId,
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
}
