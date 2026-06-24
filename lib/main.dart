import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/constants.dart';
import 'pages/auth_page.dart';
import 'pages/connect_device_page.dart';
import 'pages/gps_tracking_page.dart';
import 'pages/medicine_page.dart';
import 'pages/monitoring_page.dart';
import 'pages/activity_page.dart';
import 'pages/patient_dashboard_page.dart';
import 'pages/role_selection_page.dart';
import 'pages/settings_page.dart';
import 'pages/smartwatch_page.dart';
import 'pages/sos_page.dart';
import 'pages/splash_page.dart';
import 'services/medicine_reminder_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (!e.toString().contains('duplicate-app')) {
      rethrow;
    }
  }
  MedicineReminderService.instance.start();
  runApp(const CareLinkApp());
}

class CareLinkApp extends StatelessWidget {
  const CareLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareLink',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashPage(),
        '/role': (_) => const RoleSelectionPage(),
        '/auth': (_) => const AuthPage(),
        '/connect': (context) {
          final role = ModalRoute.of(context)?.settings.arguments as UserRole?;
          return ConnectDevicePage(role: role);
        },
        '/patient': (_) => const PatientDashboardPage(),
        '/monitoring': (_) => const MonitoringPage(),
        '/medicine': (_) => const MedicinePage(),
        '/gps': (_) => const GpsTrackingPage(),
        '/sos': (_) => const SosPage(),
        '/activity': (_) => const ActivityPage(),
        '/notifications': (_) => const ActivityPage(),
        '/watch': (_) => const SmartwatchPage(),
        '/settings': (_) => const SettingsPage(),
      },
    );
  }
}
