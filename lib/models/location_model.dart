import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Location model for real-time GPS tracking
class LocationModel {
  final String patientId;
  final double latitude;
  final double longitude;
  final double? speed; // In m/s
  final double? accuracy; // In meters
  final DateTime updatedAt;

  const LocationModel({
    required this.patientId,
    required this.latitude,
    required this.longitude,
    this.speed,
    this.accuracy,
    required this.updatedAt,
  });

  /// Create LocationModel from Firestore document
  factory LocationModel.fromJson(Map<String, dynamic> json, String patientId) {
    return LocationModel(
      patientId: patientId,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      speed: (json['speed'] as num?)?.toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert LocationModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'accuracy': accuracy,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create a copy with updated fields
  LocationModel copyWith({
    String? patientId,
    double? latitude,
    double? longitude,
    double? speed,
    double? accuracy,
    DateTime? updatedAt,
  }) {
    return LocationModel(
      patientId: patientId ?? this.patientId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      speed: speed ?? this.speed,
      accuracy: accuracy ?? this.accuracy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calculate distance between two locations using Haversine formula
  double distanceTo(LocationModel other) {
    const double earthRadius = 6371000; // in meters
    final double lat1Rad = latitude * (pi / 180);
    final double lat2Rad = other.latitude * (pi / 180);
    final double deltaLatRad = (other.latitude - latitude) * (pi / 180);
    final double deltaLngRad = (other.longitude - longitude) * (pi / 180);

    final double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLngRad / 2) * sin(deltaLngRad / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  @override
  String toString() => 'LocationModel(patientId: $patientId, lat: $latitude, lng: $longitude)';
}
