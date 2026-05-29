# CareLink Firebase Backend Architecture

A production-ready, scalable Firebase backend for a Flutter healthcare monitoring application. This comprehensive implementation includes authentication, Firestore database structure, repositories, and real-time synchronization for patient-monitor healthcare connections.

## 📋 Overview

CareLink is a healthcare platform that connects patients with monitors/caregivers for real-time health monitoring, medication reminders, GPS tracking, and emergency alerts.

**Backend Focus**: Firebase Authentication + Cloud Firestore with clean architecture and repository pattern.

## 🏗️ Architecture

### Clean Architecture Layers

```
lib/
├── core/                          # Constants, enums, exceptions
│   ├── constants.dart            # App-wide constants
│   └── exceptions.dart           # Custom exceptions
│
├── models/                        # Data models with JSON serialization
│   ├── user_model.dart
│   ├── connection_model.dart
│   ├── medicine_model.dart
│   ├── notification_model.dart
│   ├── sos_alert_model.dart
│   ├── health_data_model.dart
│   └── location_model.dart
│
├── services/                      # Low-level Firebase operations
│   ├── firebase_auth_service.dart
│   └── firestore_service.dart
│
├── repositories/                  # Business logic & data access
│   ├── auth_repository.dart
│   ├── user_repository.dart
│   ├── medicine_repository.dart
│   ├── notification_repository.dart
│   ├── sos_repository.dart
│   ├── location_repository.dart
│   ├── health_data_repository.dart
│   └── connection_repository.dart
│
└── features/                      # Feature-specific implementations
    ├── auth/
    ├── users/
    ├── medicines/
    ├── notifications/
    ├── sos/
    ├── locations/
    ├── health/
    └── connections/
```

## 🔑 Key Features

### 1. **Authentication**
- Email/password registration and login
- Password reset functionality
- Session persistence
- Role-based access (Patient, Monitor)
- Online/offline status tracking

### 2. **Firestore Database**
- 7 main collections with optimized schemas
- Real-time synchronization
- Batch operations support
- Transaction support
- Pagination ready

### 3. **Real-Time Streams**
- Live notifications
- Real-time location tracking
- Health data updates
- Medicine reminders
- SOS alerts
- Connection status

### 4. **Repository Pattern**
- 8 specialized repositories
- CRUD operations
- Query builders with conditions
- Error handling and recovery
- Type-safe operations

### 5. **Security**
- Comprehensive Firestore security rules
- Authentication required
- User data privacy
- Role-based access control
- Monitor access limitations

## 📦 Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^latest
  firebase_auth: ^latest
  cloud_firestore: ^latest
  firebase_messaging: ^latest  # For notifications
```

## 🚀 Getting Started

### 1. Firebase Setup

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase
firebase init firestore
firebase init auth

# Configure Flutter
flutterfire configure
```

### 2. Deploy Security Rules

```bash
firebase deploy --only firestore:rules
```

### 3. Initialize Services

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
```

### 4. Use Repositories

```dart
// Initialize services
final authService = FirebaseAuthService();
final firestoreService = FirestoreService();

// Create repositories
final authRepository = AuthRepository(
  authService: authService,
  firestoreService: firestoreService,
);

// Use repositories
try {
  final user = await authRepository.registerUser(
    email: 'user@example.com',
    password: 'password123',
    name: 'John Doe',
    role: UserRole.patient,
  );
} on AuthException catch (e) {
  print('Error: ${e.message}');
}
```

## 📚 Collections Schema

### users
```
users/{uid}
- uid: string
- name: string
- email: string
- role: "patient" | "monitor"
- phone: string (optional)
- photoUrl: string (optional)
- connectedMonitorId: string (optional)
- fcmToken: string (optional)
- isOnline: boolean
- createdAt: timestamp
- updatedAt: timestamp
```

### connections
```
connections/{connectionId}
- patientId: string
- monitorId: string
- inviteCode: string (6-char code)
- status: "pending" | "active" | "rejected" | "terminated"
- createdAt: timestamp
- acceptedAt: timestamp (optional)
```

### medicines
```
medicines/{medicineId}
- patientId: string
- medicineName: string
- dosage: string
- time: string (HH:mm format)
- repeatDaily: boolean
- notes: string (optional)
- createdBy: string
- isActive: boolean
- daysOfWeek: array (optional)
- createdAt: timestamp
- updatedAt: timestamp
```

### notifications
```
notifications/{notificationId}
- userId: string
- title: string
- message: string
- type: "medicine" | "sos" | "warning" | "system" | "connectionRequest"
- isRead: boolean
- createdAt: timestamp
- metadata: object (optional)
```

### sos_alerts
```
sos_alerts/{alertId}
- patientId: string
- monitorId: string
- latitude: number
- longitude: number
- status: "active" | "resolved"
- createdAt: timestamp
- resolvedAt: timestamp (optional)
- resolutionNotes: string (optional)
```

### health_data
```
health_data/{recordId}
- patientId: string
- heartRate: number (optional)
- steps: number (optional)
- sleepHours: number (optional)
- temperature: number (optional)
- recordedAt: timestamp
- synceAt: timestamp
```

### locations
```
locations/{patientId}
- patientId: string
- latitude: number
- longitude: number
- speed: number (optional)
- accuracy: number (optional)
- updatedAt: timestamp
```

## 🔐 Security Rules

The `firestore.rules` file implements:
- Authentication requirements
- User data privacy
- Role-based access
- Monitor-patient connections
- Document ownership validation
- Deny-by-default policy

## 📖 Repositories Quick Guide

### AuthRepository
- `registerUser()` - Register with profile creation
- `loginUser()` - Login with profile retrieval
- `logout()` - Logout with status update
- `getCurrentUserProfile()` - Get current user
- `sendPasswordResetEmail()` - Password reset

### UserRepository
- `getUserById()` - Get user profile
- `updateUserProfile()` - Update profile
- `streamUser()` - Real-time profile
- `connectMonitorToPatient()` - Link monitor
- `disconnectMonitorFromPatient()` - Unlink monitor

### MedicineRepository
- `createMedicine()` - Add reminder
- `getPatientMedicines()` - Get all medicines
- `streamPatientMedicines()` - Real-time list
- `updateMedicine()` - Update details
- `toggleMedicineActive()` - Enable/disable
- `getUpcomingMedicines()` - Get next N hours

### NotificationRepository
- `createNotification()` - Create notification
- `streamUserNotifications()` - Real-time notifications
- `markNotificationAsRead()` - Mark read
- `getUnreadCount()` - Get unread count
- `streamUnreadCount()` - Real-time count

### SosRepository
- `createSosAlert()` - Trigger emergency
- `streamMonitorActiveSosAlerts()` - Monitor alerts
- `resolveSosAlert()` - Resolve alert
- `getPatientSosHistory()` - Get history

### LocationRepository
- `updateLocation()` - Update GPS
- `streamPatientLocation()` - Real-time tracking
- `isPatientWithinGeofence()` - Geofence check

### HealthDataRepository
- `addHealthData()` - Add metrics
- `getLatestHealthData()` - Latest metrics
- `streamLatestHealthData()` - Real-time data
- `getDailySummary()` - Daily stats
- `checkAbnormalReadings()` - Health alerts

### ConnectionRepository
- `createConnectionRequest()` - Request connection
- `acceptConnection()` - Accept request
- `streamPatientConnections()` - Connection list
- `areConnected()` - Check connection status

## 🚦 Common Operations

### Register Patient
```dart
final user = await authRepository.registerUser(
  email: 'patient@example.com',
  password: 'password123',
  name: 'John Doe',
  role: UserRole.patient,
);
```

### Create Medicine Reminder
```dart
final id = await medicineRepository.createMedicine(
  patientId: uid,
  medicineName: 'Aspirin',
  dosage: '500mg',
  time: '09:00',
  repeatDaily: true,
  createdBy: uid,
);
```

### Stream Notifications
```dart
notificationRepository.streamUserNotifications(
  userId: uid,
  unreadOnly: true,
).listen((notifications) {
  setState(() => unreadList = notifications);
});
```

### Create SOS Alert
```dart
final sosId = await sosRepository.createSosAlert(
  patientId: patientId,
  monitorId: monitorId,
  latitude: 37.7749,
  longitude: -122.4194,
);
```

### Track Location
```dart
locationRepository.streamPatientLocation(
  patientId: patientId,
).listen((location) {
  updateMapMarker(location);
});
```

## 🧪 Testing

### With Firebase Emulator
```bash
firebase emulators:start --only firestore,auth
```

### In Code
```dart
if (kDebugMode) {
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
}
```

## 📝 Error Handling

All operations throw custom exceptions:

```dart
try {
  await authRepository.registerUser(...);
} on AuthException catch (e) {
  print('Auth error: ${e.message}');
} on FirestoreException catch (e) {
  print('Database error: ${e.message}');
} on NetworkException catch (e) {
  print('Network error: ${e.message}');
} on ValidationException catch (e) {
  print('Validation error: ${e.message}');
}
```

## 📊 Best Practices

1. **Use Service Locator**: Use GetIt or Provider for dependency injection
2. **Implement Caching**: Cache frequently accessed data
3. **Batch Operations**: Use batch writes for multiple documents
4. **Monitor Reads**: Each read costs money - optimize queries
5. **Real-time vs One-time**: Use streams only when needed
6. **Error Recovery**: Implement retry logic
7. **Loading States**: Show UI feedback during operations
8. **Pagination**: Implement for large datasets

## 📚 Documentation

- `BACKEND_ARCHITECTURE.dart` - Complete architecture guide
- `QUICK_REFERENCE.dart` - 44+ code examples
- `firestore.rules` - Security rules

## 🔗 Project Structure Files

- **Core Layer**: Exception handling, constants, enums
- **Model Layer**: Data classes with JSON serialization
- **Service Layer**: Firebase operations
- **Repository Layer**: Business logic
- **Feature Layer**: Feature-specific code

## ✅ Checklist

- [ ] Firebase project created
- [ ] Firestore database enabled
- [ ] Firebase Auth enabled
- [ ] Dependencies added to pubspec.yaml
- [ ] `flutterfire configure` run
- [ ] Security rules deployed
- [ ] Services initialized in main.dart
- [ ] Repositories created
- [ ] Error handling implemented
- [ ] Testing setup complete

## 🤝 Contributing

This is a template for CareLink backend. Extend with:
- Push notifications (FCM)
- Cloud Functions for business logic
- Analytics integration
- Crash reporting

## 📞 Support

For Firebase help:
- [Firebase Documentation](https://firebase.google.com/docs)
- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)
- [Security Rules Guide](https://firebase.google.com/docs/firestore/security/get-started)

## 📄 License

This code is provided as-is for the CareLink project.

---

**Version**: 1.0.0  
**Created**: 2026  
**Firebase Auth**: ✅ Implemented  
**Firestore**: ✅ Implemented  
**Real-time Streams**: ✅ Implemented  
**Security Rules**: ✅ Implemented  
