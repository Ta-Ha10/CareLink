import 'package:carelink/services/firestore_service.dart';
import 'package:carelink/models/location_model.dart';
import 'package:carelink/core/exceptions.dart';
import 'package:carelink/core/constants.dart';

/// Location Repository
/// Handles real-time GPS location tracking and updates
class LocationRepository {
  final FirestoreService _firestoreService;

  LocationRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  /// Update or create patient location
  Future<void> updateLocation({
    required String patientId,
    required double latitude,
    required double longitude,
    double? speed,
    double? accuracy,
  }) async {
    try {
      final locationData = {
        'patientId': patientId,
        'latitude': latitude,
        'longitude': longitude,
        'speed': speed,
        'accuracy': accuracy,
        'updatedAt': DateTime.now(),
      };

      await _firestoreService.createDocument(
        collection: FirestoreCollections.locations,
        customId: patientId,
        data: locationData,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get current location of a patient
  Future<LocationModel?> getPatientCurrentLocation({
    required String patientId,
  }) async {
    try {
      final doc = await _firestoreService.getDocument(
        collection: FirestoreCollections.locations,
        docId: patientId,
      );

      if (!doc.exists) {
        return null;
      }

      return LocationModel.fromJson(doc.data()!, patientId);
    } catch (e) {
      rethrow;
    }
  }

  /// Stream patient location updates (real-time)
  Stream<LocationModel?> streamPatientLocation({
    required String patientId,
  }) {
    try {
      return _firestoreService
          .streamDocuments(
            collection: FirestoreCollections.locations,
            conditions: [
              QueryCondition(field: 'patientId', value: patientId),
            ],
            limit: 1,
          )
          .map((snapshot) {
            if (snapshot.docs.isEmpty) return null;
            return LocationModel.fromJson(snapshot.docs.first.data(), patientId);
          });
    } catch (e) {
      return Stream.error(e);
    }
  }

  /// Get multiple patient locations
  Future<Map<String, LocationModel>> getMultiplePatientsLocations({
    required List<String> patientIds,
  }) async {
    try {
      final locations = <String, LocationModel>{};

      for (final patientId in patientIds) {
        final location = await getPatientCurrentLocation(patientId: patientId);
        if (location != null) {
          locations[patientId] = location;
        }
      }

      return locations;
    } catch (e) {
      rethrow;
    }
  }

  /// Stream locations for multiple patients
  Stream<Map<String, LocationModel>> streamMultiplePatientsLocations({
    required List<String> patientIds,
  }) {
    try {
      return _firestoreService
          .streamDocuments(
            collection: FirestoreCollections.locations,
            conditions: [
              QueryCondition(field: 'patientId', value: patientIds, operator: 'in'),
            ],
          )
          .map((snapshot) {
            final locations = <String, LocationModel>{};
            for (final doc in snapshot.docs) {
              final patientId = doc.data()['patientId'] as String;
              locations[patientId] = LocationModel.fromJson(doc.data(), patientId);
            }
            return locations;
          });
    } catch (e) {
      return Stream.error(e);
    }
  }

  /// Get patient location history (stored separately or from collection)
  /// Note: For historical data, consider creating a separate 'location_history' collection
  /// This method assumes you want recent locations only
  Future<List<LocationModel>> getPatientLocationHistory({
    required String patientId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    try {
      // Get current location as the most recent
      final currentLocation = await getPatientCurrentLocation(
        patientId: patientId,
      );

      if (currentLocation == null) {
        return [];
      }

      return [currentLocation];
    } catch (e) {
      rethrow;
    }
  }

  /// Calculate distance between patient and monitor
  Future<double> getDistanceBetweenPatientAndMonitor({
    required String patientId,
    required LocationModel monitorLocation,
  }) async {
    try {
      final patientLocation = await getPatientCurrentLocation(
        patientId: patientId,
      );

      if (patientLocation == null) {
        throw FirestoreException.documentNotFound('Patient location not found');
      }

      return patientLocation.distanceTo(monitorLocation);
    } catch (e) {
      rethrow;
    }
  }

  /// Check if patient is within geofence
  /// Simplified geofence check - in production, consider using dedicated geofencing services
  Future<bool> isPatientWithinGeofence({
    required String patientId,
    required double centerLatitude,
    required double centerLongitude,
    required double radiusInMeters,
  }) async {
    try {
      final patientLocation = await getPatientCurrentLocation(
        patientId: patientId,
      );

      if (patientLocation == null) {
        return false;
      }

      final centerLocation = LocationModel(
        patientId: patientId,
        latitude: centerLatitude,
        longitude: centerLongitude,
        updatedAt: DateTime.now(),
      );

      final distance = patientLocation.distanceTo(centerLocation);
      return distance <= radiusInMeters;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete location (privacy/cleanup)
  Future<void> deleteLocation({required String patientId}) async {
    try {
      await _firestoreService.deleteDocument(
        collection: FirestoreCollections.locations,
        docId: patientId,
      );
    } catch (e) {
      rethrow;
    }
  }
}
