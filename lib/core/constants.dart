/// Constants and enums used throughout the CareLink application

/// User roles in the application
enum UserRole {
  patient('patient'),
  monitor('monitor');

  final String value;
  const UserRole(this.value);

  /// Convert string to UserRole enum
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.patient,
    );
  }
}

/// Firestore collection names
class FirestoreCollections {
  static const String users = 'users';
  static const String connections = 'connections';
  static const String medicines = 'medicines';
  static const String notifications = 'notifications';
  static const String sosAlerts = 'sos_alerts';
  static const String healthData = 'health_data';
  static const String locations = 'locations';
}

/// SOS alert status
enum SosStatus {
  active('active'),
  resolved('resolved');

  final String value;
  const SosStatus(this.value);

  static SosStatus fromString(String value) {
    return SosStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => SosStatus.active,
    );
  }
}

/// Connection status between patient and monitor
enum ConnectionStatus {
  active('active'),
  pending('pending'),
  rejected('rejected'),
  terminated('terminated');

  final String value;
  const ConnectionStatus(this.value);

  static ConnectionStatus fromString(String value) {
    return ConnectionStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ConnectionStatus.pending,
    );
  }
}

/// Notification types
enum NotificationType {
  medicine('medicine'),
  sos('sos'),
  warning('warning'),
  system('system'),
  connectionRequest('connectionRequest');

  final String value;
  const NotificationType(this.value);

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.system,
    );
  }
}

/// Firebase exception error codes mapping
class FirebaseErrorCodes {
  // Auth errors
  static const String userNotFound = 'user-not-found';
  static const String wrongPassword = 'wrong-password';
  static const String emailAlreadyInUse = 'email-already-in-use';
  static const String weakPassword = 'weak-password';
  static const String invalidEmail = 'invalid-email';
  static const String userDisabled = 'user-disabled';
  static const String operationNotAllowed = 'operation-not-allowed';
  static const String tooManyRequests = 'too-many-requests';

  // Network errors
  static const String networkRequestFailed = 'network-request-failed';
}

/// Application constants
class AppConstants {
  // Firebase configuration
  static const String firebaseProjectId = 'carelink-healthcare';

  // Session management
  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration inactivityTimeout = Duration(minutes: 30);

  // Location tracking
  static const Duration locationUpdateInterval = Duration(minutes: 5);
  static const double locationAccuracyThreshold = 10.0; // meters

  // Health data
  static const Duration healthDataSyncInterval = Duration(hours: 1);

  // Medicine reminders
  static const Duration medicineReminderThreshold = Duration(minutes: 15);

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 100;

  // API call timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration databaseTimeout = Duration(seconds: 15);
}
