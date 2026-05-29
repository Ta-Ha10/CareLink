import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';

/// User model representing a patient or monitor in the system
class UserModel {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? photoUrl;
  final String? connectedMonitorId; // For patients: their monitor's UID
  final String? fcmToken; // For push notifications
  final bool isOnline;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.photoUrl,
    this.connectedMonitorId,
    this.fcmToken,
    this.isOnline = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create UserModel from Firestore document
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: UserRole.fromString(json['role'] as String? ?? 'patient'),
      phone: json['phone'] as String?,
      photoUrl: json['photoUrl'] as String?,
      connectedMonitorId: json['connectedMonitorId'] as String?,
      fcmToken: json['fcmToken'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert UserModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role.value,
      'phone': phone,
      'photoUrl': photoUrl,
      'connectedMonitorId': connectedMonitorId,
      'fcmToken': fcmToken,
      'isOnline': isOnline,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt ?? DateTime.now()),
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    UserRole? role,
    String? phone,
    String? photoUrl,
    String? connectedMonitorId,
    String? fcmToken,
    bool? isOnline,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      connectedMonitorId: connectedMonitorId ?? this.connectedMonitorId,
      fcmToken: fcmToken ?? this.fcmToken,
      isOnline: isOnline ?? this.isOnline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() => 'UserModel(uid: $uid, name: $name, email: $email, role: ${role.value})';
}
