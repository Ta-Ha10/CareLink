import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/exceptions.dart';
import '../models/connection_model.dart';
import '../models/medicine_model.dart';
import '../models/user_model.dart';
import '../repositories/connection_repository.dart';
import '../repositories/medicine_repository.dart';
import '../repositories/user_repository.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class PatientDashboardPage extends StatefulWidget {
  const PatientDashboardPage({super.key});

  @override
  State<PatientDashboardPage> createState() => _PatientDashboardPageState();
}

class _PatientDashboardPageState extends State<PatientDashboardPage> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();
  late final ConnectionRepository _connectionRepository = ConnectionRepository(
    firestoreService: _firestoreService,
  );
  late final MedicineRepository _medicineRepository = MedicineRepository(
    firestoreService: _firestoreService,
  );
  late final UserRepository _userRepository = UserRepository(
    firestoreService: _firestoreService,
  );
  late final Future<_HomeContext> _contextFuture = _loadContext();

  Future<_HomeContext> _loadContext() async {
    final uid = _authService.currentUserId;
    if (uid == null) {
      throw AuthException(message: 'No user logged in', code: 'no-user');
    }

    final currentUser = await _userRepository.getUserById(uid: uid);
    final connection = await _connectionRepository
        .getLatestActiveConnectionForPatient(patientId: uid);

    return _HomeContext(
      currentUser: currentUser,
      connection: connection,
      patient: currentUser,
    );
  }

  String _formatMedicineTime(String time) {
    return time;
  }

  Color _colorForIndex(int index) {
    final colors = [AppColors.primary, AppColors.secondary, AppColors.tertiary];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_HomeContext>(
      future: _contextFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          final error = snapshot.error;
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  error is AppException ? error.message : error.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final contextData = snapshot.data!;
        final connection = contextData.connection;

        return CareScaffold(
          bottomNavIndex: 0,
          child: PageContent(
            children: [
              const _DailyProgressCard(),
              const SizedBox(height: 16),
              GradientButton(
                label: 'Logout',
                icon: Icons.logout,
                gradient: LinearGradient(
                  colors: [
                    AppColors.error,
                    AppColors.error.withValues(alpha: 0.82),
                  ],
                ),
                onPressed: () async {
                  try {
                    await FirebaseAuthService().logout();
                    if (!context.mounted) return;
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/auth', (route) => false);
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logout failed: $e')),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              if (connection == null)
                GradientButton(
                  label: 'Link Caregiver',
                  icon: Icons.person_add_alt_1,
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamed('/connect', arguments: UserRole.patient),
                )
              else
                GlassCard(
                  radius: 24,
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.secondaryContainer,
                        child: Icon(Icons.link, color: AppColors.primary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Patient Linked',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Connected with a caregiver',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(child: _WatchCard()),
                  SizedBox(width: 16),
                  Expanded(child: _HeartRateCard()),
                ],
              ),
              const SizedBox(height: 28),
              SectionTitle(
                'Next Medications',
                action: connection == null ? null : 'Connected',
              ),
              const SizedBox(height: 14),
              StreamBuilder<List<MedicineModel>>(
                stream: connection == null
                    ? Stream.value(const <MedicineModel>[])
                    : _medicineRepository.streamConnectionMedicines(
                        connectionId: connection.id,
                      ),
                builder: (context, medicineSnapshot) {
                  if (medicineSnapshot.connectionState ==
                          ConnectionState.waiting &&
                      !medicineSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final medicines = medicineSnapshot.data ?? const [];
                  if (medicines.isEmpty) {
                    return GlassCard(
                      radius: 24,
                      child: Text(
                        connection == null
                            ? 'No active caregiver connection yet.'
                            : 'No medicines have been added yet.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  }

                  return SizedBox(
                    height: 122,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: medicines.length,
                      separatorBuilder: (_, index) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final medicine = medicines[index];
                        return _MedicineSummaryCard(
                          medicineName: medicine.medicineName,
                          detail:
                              '${medicine.dosage} • ${_formatMedicineTime(medicine.time)}',
                          color: _colorForIndex(index),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 26),
              GlassCard(
                radius: 28,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Steps This Week',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _WeeklyBars(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: () => Navigator.of(context).pushNamed('/sos'),
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    gradient: emergencyGradient(),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withValues(alpha: 0.28),
                        blurRadius: 34,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.sos, color: Colors.white, size: 42),
                      const SizedBox(height: 8),
                      Text(
                        'Emergency Help',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hold for 3 seconds to alert caregivers',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeContext {
  final UserModel currentUser;
  final ConnectionModel? connection;
  final UserModel patient;

  const _HomeContext({
    required this.currentUser,
    required this.connection,
    required this.patient,
  });
}

class _MedicineSummaryCard extends StatelessWidget {
  const _MedicineSummaryCard({
    required this.medicineName,
    required this.detail,
    required this.color,
  });

  final String medicineName;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: glassDecoration(radius: 18).copyWith(
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(Icons.medication, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicineName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  detail,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const CircleAvatar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            child: Icon(Icons.local_pharmacy),
          ),
        ],
      ),
    );
  }
}

class _DailyProgressCard extends StatelessWidget {
  const _DailyProgressCard();

  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      radius: 28,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Progress',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
              Icon(Icons.auto_awesome, color: AppColors.onSecondaryContainer),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Feeling Great',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 58,
                height: 58,
                child: CircularProgressIndicator(
                  value: 0.8,
                  strokeWidth: 6,
                  color: AppColors.secondaryFixedDim,
                  backgroundColor: AppColors.surfaceContainerHigh,
                ),
              ),
              SizedBox(width: 14),
              Flexible(child: Text('4 of 5 health goals completed today.')),
            ],
          ),
        ],
      ),
    );
  }
}

class _WatchCard extends StatelessWidget {
  const _WatchCard();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 156,
      child: GlassCard(
        radius: 28,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.watch, color: AppColors.primary, size: 30),
                Row(
                  children: [
                    Icon(
                      Icons.battery_5_bar,
                      color: AppColors.secondaryFixedDim,
                      size: 18,
                    ),
                    Text(
                      '72%',
                      style: TextStyle(color: AppColors.secondaryFixedDim),
                    ),
                  ],
                ),
              ],
            ),
            Spacer(),
            Text(
              'CareLink Watch v2',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
            Text(
              'Connected',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeartRateCard extends StatelessWidget {
  const _HeartRateCard();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 156,
      child: GlassCard(
        radius: 28,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.favorite, color: AppColors.error),
                Icon(Icons.show_chart, color: AppColors.primary),
              ],
            ),
            const Spacer(),
            const Text(
              'Heart Rate',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('74', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(width: 4),
                const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text(
                    'BPM',
                    style: TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyBars extends StatelessWidget {
  const _WeeklyBars();

  @override
  Widget build(BuildContext context) {
    final values = [0.5, 0.75, 0.9, 0.66, 0.5, 0.85, 0.25];
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Column(
      children: [
        SizedBox(
          height: 128,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < values.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FractionallySizedBox(
                      heightFactor: values[i],
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          color: i == 2
                              ? AppColors.primaryContainer
                              : AppColors.surfaceContainerHigh,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < days.length; i++)
              Expanded(
                child: Text(
                  days[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: i == 2 ? AppColors.primary : AppColors.outline,
                    fontWeight: i == 2 ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
