/// Custom exception classes for the CareLink application.
/// These provide structured error handling across Firebase operations.

/// Base exception class for all application exceptions
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  AppException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Authentication-related exceptions
class AuthException extends AppException {
  AuthException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );

  /// User not found during login
  factory AuthException.userNotFound() => AuthException(
    message: 'User not found. Please check your email.',
    code: 'user-not-found',
  );

  /// Wrong password provided
  factory AuthException.wrongPassword() => AuthException(
    message: 'Invalid password. Please try again.',
    code: 'wrong-password',
  );

  /// Email already registered
  factory AuthException.emailAlreadyInUse() => AuthException(
    message: 'This email is already registered.',
    code: 'email-already-in-use',
  );

  /// Weak password provided
  factory AuthException.weakPassword() => AuthException(
    message: 'Password must be at least 6 characters.',
    code: 'weak-password',
  );

  /// Invalid email format
  factory AuthException.invalidEmail() => AuthException(
    message: 'Invalid email format.',
    code: 'invalid-email',
  );

  /// User disabled
  factory AuthException.userDisabled() => AuthException(
    message: 'This user account has been disabled.',
    code: 'user-disabled',
  );

  /// Generic authentication error
  factory AuthException.generic(String message, {String? code}) => AuthException(
    message: message,
    code: code ?? 'auth-error',
  );
}

/// Firestore database exceptions
class FirestoreException extends AppException {
  FirestoreException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );

  /// Document not found
  factory FirestoreException.documentNotFound(String docId) => FirestoreException(
    message: 'Document not found: $docId',
    code: 'not-found',
  );

  /// Permission denied
  factory FirestoreException.permissionDenied() => FirestoreException(
    message: 'Permission denied. You do not have access to this resource.',
    code: 'permission-denied',
  );

  /// Write failed
  factory FirestoreException.writeFailed(String reason) => FirestoreException(
    message: 'Failed to write data: $reason',
    code: 'write-failed',
  );

  /// Read failed
  factory FirestoreException.readFailed(String reason) => FirestoreException(
    message: 'Failed to read data: $reason',
    code: 'read-failed',
  );

  /// Generic firestore error
  factory FirestoreException.generic(String message, {String? code}) => FirestoreException(
    message: message,
    code: code ?? 'firestore-error',
  );
}

/// Network-related exceptions
class NetworkException extends AppException {
  NetworkException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );

  /// No internet connection
  factory NetworkException.noConnection() => NetworkException(
    message: 'No internet connection. Please check your connection.',
    code: 'no-connection',
  );

  /// Request timeout
  factory NetworkException.timeout() => NetworkException(
    message: 'Request timed out. Please try again.',
    code: 'timeout',
  );

  /// Generic network error
  factory NetworkException.generic(String message, {String? code}) => NetworkException(
    message: message,
    code: code ?? 'network-error',
  );
}

/// Validation exceptions
class ValidationException extends AppException {
  ValidationException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );

  /// Invalid input data
  factory ValidationException.invalidInput(String field) => ValidationException(
    message: 'Invalid input for field: $field',
    code: 'invalid-input',
  );

  /// Missing required field
  factory ValidationException.missingField(String field) => ValidationException(
    message: 'Required field is missing: $field',
    code: 'missing-field',
  );

  /// Generic validation error
  factory ValidationException.generic(String message, {String? code}) => ValidationException(
    message: message,
    code: code ?? 'validation-error',
  );
}
