import 'package:carelink/services/firestore_service.dart';
import 'package:carelink/models/health_data_model.dart';
import 'package:carelink/core/exceptions.dart';
import 'package:carelink/core/constants.dart';

/// Health Data Repository
/// Handles health metrics storage and retrieval from smartwatch and health devices
class HealthDataRepository {
  final FirestoreService _firestoreService;

  HealthDataRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  /// Add new health data record
  Future<String> addHealthData({
    required String patientId,
    int? heartRate,
    int? steps,
    double? sleepHours,
    double? temperature,
    DateTime? recordedAt,
  }) async {
    try {
      final healthData = HealthDataModel(
        id: '',
        patientId: patientId,
        heartRate: heartRate,
        steps: steps,
        sleepHours: sleepHours,
        temperature: temperature,
        recordedAt: recordedAt ?? DateTime.now(),
        synceAt: DateTime.now(),
      );

      final ref = await _firestoreService.createDocument(
        collection: FirestoreCollections.healthData,
        data: healthData.toJson(),
      );

      return ref.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Get health data by ID
  Future<HealthDataModel> getHealthDataById({
    required String recordId,
  }) async {
    try {
      final doc = await _firestoreService.getDocument(
        collection: FirestoreCollections.healthData,
        docId: recordId,
      );

      if (!doc.exists) {
        throw FirestoreException.documentNotFound(recordId);
      }

      return HealthDataModel.fromJson(doc.data()!, recordId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get latest health data for a patient
  Future<HealthDataModel?> getLatestHealthData({
    required String patientId,
  }) async {
    try {
      final result = await _firestoreService.queryDocuments(
        collection: FirestoreCollections.healthData,
        conditions: [
          QueryCondition(field: 'patientId', value: patientId),
        ],
        orderBy: 'recordedAt',
        descending: true,
        limit: 1,
      );

      if (result.docs.isEmpty) {
        return null;
      }

      return HealthDataModel.fromJson(result.docs.first.data(), result.docs.first.id);
    } catch (e) {
      rethrow;
    }
  }

  /// Stream latest health data updates (real-time)
  Stream<HealthDataModel?> streamLatestHealthData({
    required String patientId,
  }) {
    try {
      return _firestoreService
          .streamDocuments(
            collection: FirestoreCollections.healthData,
            conditions: [
              QueryCondition(field: 'patientId', value: patientId),
            ],
            orderBy: 'recordedAt',
            descending: true,
            limit: 1,
          )
          .map((snapshot) {
            if (snapshot.docs.isEmpty) return null;
            return HealthDataModel.fromJson(
              snapshot.docs.first.data(),
              snapshot.docs.first.id,
            );
          });
    } catch (e) {
      return Stream.error(e);
    }
  }

  /// Get health data for a date range
  Future<List<HealthDataModel>> getHealthDataByDateRange({
    required String patientId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final result = await _firestoreService.queryDocuments(
        collection: FirestoreCollections.healthData,
        conditions: [
          QueryCondition(field: 'patientId', value: patientId),
          QueryCondition(field: 'recordedAt', value: startDate, operator: '>='),
          QueryCondition(field: 'recordedAt', value: endDate, operator: '<='),
        ],
        orderBy: 'recordedAt',
        descending: true,
      );

      return result.docs
          .map((doc) => HealthDataModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Stream health data for a date range
  Stream<List<HealthDataModel>> streamHealthDataByDateRange({
    required String patientId,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    try {
      return _firestoreService
          .streamDocuments(
            collection: FirestoreCollections.healthData,
            conditions: [
              QueryCondition(field: 'patientId', value: patientId),
              QueryCondition(field: 'recordedAt', value: startDate, operator: '>='),
              QueryCondition(field: 'recordedAt', value: endDate, operator: '<='),
            ],
            orderBy: 'recordedAt',
            descending: true,
          )
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => HealthDataModel.fromJson(doc.data(), doc.id))
                .toList();
          });
    } catch (e) {
      return Stream.error(e);
    }
  }

  /// Get daily summary for a patient
  Future<Map<String, dynamic>> getDailySummary({
    required String patientId,
    DateTime? date,
  }) async {
    try {
      final targetDate = date ?? DateTime.now();
      final startOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final records = await getHealthDataByDateRange(
        patientId: patientId,
        startDate: startOfDay,
        endDate: endOfDay,
      );

      if (records.isEmpty) {
        return {
          'date': targetDate.toIso8601String(),
          'hasData': false,
        };
      }

      final avgHeartRate = records
          .where((r) => r.heartRate != null)
          .map((r) => r.heartRate!)
          .fold<int>(0, (sum, hr) => sum + hr) ~/
          (records.where((r) => r.heartRate != null).length == 0
              ? 1
              : records.where((r) => r.heartRate != null).length);

      final totalSteps = records
          .where((r) => r.steps != null)
          .map((r) => r.steps!)
          .fold<int>(0, (sum, steps) => sum + steps);

      final avgSleep = records
          .where((r) => r.sleepHours != null)
          .map((r) => r.sleepHours!)
          .fold<double>(0, (sum, sleep) => sum + sleep) /
          (records.where((r) => r.sleepHours != null).length == 0
              ? 1
              : records.where((r) => r.sleepHours != null).length);

      final avgTemp = records
          .where((r) => r.temperature != null)
          .map((r) => r.temperature!)
          .fold<double>(0, (sum, temp) => sum + temp) /
          (records.where((r) => r.temperature != null).length == 0
              ? 1
              : records.where((r) => r.temperature != null).length);

      return {
        'date': targetDate.toIso8601String(),
        'hasData': true,
        'avgHeartRate': avgHeartRate,
        'totalSteps': totalSteps,
        'avgSleep': avgSleep.toStringAsFixed(2),
        'avgTemp': avgTemp.toStringAsFixed(2),
        'recordCount': records.length,
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Get weekly summary
  Future<List<Map<String, dynamic>>> getWeeklySummary({
    required String patientId,
    DateTime? endDate,
  }) async {
    try {
      final end = endDate ?? DateTime.now();
      final start = end.subtract(const Duration(days: 7));

      final summaries = <Map<String, dynamic>>[];

      for (int i = 0; i < 7; i++) {
        final date = start.add(Duration(days: i));
        final summary = await getDailySummary(patientId: patientId, date: date);
        summaries.add(summary);
      }

      return summaries;
    } catch (e) {
      rethrow;
    }
  }

  /// Update health data record
  Future<void> updateHealthData({
    required String recordId,
    int? heartRate,
    int? steps,
    double? sleepHours,
    double? temperature,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (heartRate != null) updateData['heartRate'] = heartRate;
      if (steps != null) updateData['steps'] = steps;
      if (sleepHours != null) updateData['sleepHours'] = sleepHours;
      if (temperature != null) updateData['temperature'] = temperature;

      if (updateData.isNotEmpty) {
        await _firestoreService.updateDocument(
          collection: FirestoreCollections.healthData,
          docId: recordId,
          data: updateData,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Delete health data record
  Future<void> deleteHealthData({required String recordId}) async {
    try {
      await _firestoreService.deleteDocument(
        collection: FirestoreCollections.healthData,
        docId: recordId,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Check for abnormal readings
  Future<List<String>> checkAbnormalReadings({
    required String patientId,
  }) async {
    try {
      final latestData = await getLatestHealthData(patientId: patientId);
      if (latestData == null) return [];

      final warnings = <String>[];

      // Check heart rate
      if (latestData.heartRate != null) {
        if (latestData.heartRate! < 60 || latestData.heartRate! > 100) {
          warnings.add('Abnormal heart rate: ${latestData.heartRate!} bpm');
        }
      }

      // Check temperature
      if (latestData.temperature != null) {
        if (latestData.temperature! < 36.1 || latestData.temperature! > 37.3) {
          warnings.add('Abnormal temperature: ${latestData.temperature!}°C');
        }
      }

      return warnings;
    } catch (e) {
      rethrow;
    }
  }
}
