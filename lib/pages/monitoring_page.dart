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

class MonitoringPage extends StatefulWidget {
  const MonitoringPage({super.key});

  @override
  State<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage> {
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
  late final Future<_MonitorHomeContext> _contextFuture = _loadContext();

  Future<_MonitorHomeContext> _loadContext() async {
    final uid = _authService.currentUserId;
    if (uid == null) {
      throw AuthException(message: 'No user logged in', code: 'no-user');
    }

    final currentUser = await _userRepository.getUserById(uid: uid);
    final connection =
        await _connectionRepository.getLatestActiveConnectionForMonitor(
          monitorId: uid,
        ) ??
        await _connectionRepository.getLatestConnectionForMonitor(
          monitorId: uid,
        );

    UserModel? patient;
    if (connection != null) {
      patient = await _userRepository.getUserById(uid: connection.patientId);
    }

    return _MonitorHomeContext(
      currentUser: currentUser,
      connection: connection,
      patient: patient,
    );
  }

  Color _colorForIndex(int index) {
    final colors = [AppColors.primary, AppColors.secondary, AppColors.tertiary];
    return colors[index % colors.length];
  }

  Future<void> _editVital({
    required BuildContext context,
    required String title,
    required String fieldLabel,
    required String initialValue,
    required IconData icon,
    required Color color,
    required TextInputType keyboardType,
    required Future<void> Function(String value) onSave,
    String? helperText,
    String? hintText,
    bool Function(String value)? validator,
  }) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(text: initialValue);
    var saving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.12),
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(title)),
                ],
              ),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    labelText: fieldLabel,
                    hintText: hintText,
                    helperText: helperText,
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) {
                      return 'Please enter $fieldLabel';
                    }
                    if (validator != null && !validator(text)) {
                      return 'Enter a valid $fieldLabel';
                    }
                    return null;
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: saving
                      ? null
                      : () async {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }

                          setDialogState(() => saving = true);
                          try {
                            await onSave(controller.text.trim());
                            if (!dialogContext.mounted) return;
                            Navigator.of(dialogContext).pop();
                          } catch (e) {
                            if (!dialogContext.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to update $fieldLabel: $e',
                                ),
                              ),
                            );
                          } finally {
                            if (dialogContext.mounted) {
                              setDialogState(() => saving = false);
                            }
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_MonitorHomeContext>(
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
        final patient = contextData.patient;

        return CareScaffold(
          bottomNavIndex: 1,
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.of(context).pushNamed('/sos'),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            child: const Icon(Icons.emergency),
          ),
          child: PageContent(
            maxWidth: 980,
            children: [
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
              const SizedBox(height: 20),
              if (connection == null)
                GradientButton(
                  label: 'Link Patient',
                  icon: Icons.link,
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamed('/connect', arguments: UserRole.monitor),
                )
              else
                GlassCard(
                  radius: 24,
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.secondaryContainer,
                        child: Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                        ),
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
                              patient != null
                                  ? '${patient.name} (${patient.email})'
                                  : 'Connected with a patient',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 760;
                  return StreamBuilder<ConnectionModel?>(
                    stream: connection == null
                        ? Stream.value(null)
                        : _connectionRepository.streamConnectionById(
                            connectionId: connection.id,
                          ),
                    builder: (context, connectionSnapshot) {
                      final liveConnection =
                          connectionSnapshot.data ?? connection;
                      final heartRate =
                          liveConnection?.heartRate?.toString() ?? '--';
                      final bloodPressure =
                          liveConnection?.bloodPressure ?? '--';
                      final currentState =
                          liveConnection?.currentState ?? 'Not set';
                      void showNoConnectionSnack() {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Link a patient before editing vitals.',
                            ),
                          ),
                        );
                      }

                      final cards = [
                        _EditableVitalCard(
                          label: 'Heart Rate',
                          value: heartRate,
                          unit: 'BPM',
                          icon: Icons.favorite,
                          color: AppColors.error,
                          onEdit: () {
                            if (liveConnection == null) {
                              showNoConnectionSnack();
                              return;
                            }
                            _editVital(
                              context: context,
                              title: 'Edit Heart Rate',
                              fieldLabel: 'Heart Rate',
                              initialValue:
                                  liveConnection.heartRate?.toString() ?? '',
                              icon: Icons.favorite,
                              color: AppColors.error,
                              keyboardType: TextInputType.number,
                              hintText: 'Enter heart rate in BPM',
                              validator: (value) => int.tryParse(value) != null,
                              onSave: (value) async {
                                await _connectionRepository
                                    .updateConnectionVitals(
                                      connectionId: liveConnection.id,
                                      heartRate: int.parse(value),
                                      updatedBy: contextData.currentUser.uid,
                                    );
                              },
                            );
                          },
                        ),
                        _EditableVitalCard(
                          label: 'Blood Pressure',
                          value: bloodPressure,
                          unit: 'mmHg',
                          icon: Icons.bloodtype,
                          color: AppColors.secondary,
                          onEdit: () {
                            if (liveConnection == null) {
                              showNoConnectionSnack();
                              return;
                            }
                            _editVital(
                              context: context,
                              title: 'Edit Blood Pressure',
                              fieldLabel: 'Blood Pressure',
                              initialValue: liveConnection.bloodPressure ?? '',
                              icon: Icons.bloodtype,
                              color: AppColors.secondary,
                              keyboardType: TextInputType.text,
                              hintText: 'Example: 120/80',
                              onSave: (value) async {
                                await _connectionRepository
                                    .updateConnectionVitals(
                                      connectionId: liveConnection.id,
                                      bloodPressure: value,
                                      updatedBy: contextData.currentUser.uid,
                                    );
                              },
                            );
                          },
                        ),
                        _EditableVitalCard(
                          label: 'Current State',
                          value: currentState,
                          unit: 'Status',
                          icon: Icons.bed,
                          color: AppColors.tertiary,
                          onEdit: () {
                            if (liveConnection == null) {
                              showNoConnectionSnack();
                              return;
                            }
                            _editVital(
                              context: context,
                              title: 'Edit Current State',
                              fieldLabel: 'Current State',
                              initialValue: liveConnection.currentState ?? '',
                              icon: Icons.bed,
                              color: AppColors.tertiary,
                              keyboardType: TextInputType.text,
                              hintText: 'Example: Resting, Walking, Sleeping',
                              onSave: (value) async {
                                await _connectionRepository
                                    .updateConnectionVitals(
                                      connectionId: liveConnection.id,
                                      currentState: value,
                                      updatedBy: contextData.currentUser.uid,
                                    );
                              },
                            );
                          },
                        ),
                      ];

                      return GridView.count(
                        crossAxisCount: wide ? 3 : 1,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: wide ? 1.65 : 2.4,
                        children: cards,
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              GlassCard(
                radius: 28,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Linked Patient',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      patient != null
                          ? '${patient.name} (${patient.email})'
                          : 'No active patient linked yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SectionTitle('Patient Medicines', action: 'Live Sync'),
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
                            ? 'Link a patient to see their medicines.'
                            : 'No medicines have been added for this patient yet.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  }

                  return Column(
                    children: [
                      for (var i = 0; i < medicines.length; i++) ...[
                        _MedicineCard(
                          medicine: medicines[i],
                          color: _colorForIndex(i),
                        ),
                        if (i != medicines.length - 1)
                          const SizedBox(height: 16),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 760;
                  final children = [const _MapPreview(), const _ActivityHint()];
                  return wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: children[0]),
                            const SizedBox(width: 20),
                            Expanded(child: children[1]),
                          ],
                        )
                      : Column(
                          children: [
                            children[0],
                            const SizedBox(height: 20),
                            children[1],
                          ],
                        );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MonitorHomeContext {
  final UserModel currentUser;
  final ConnectionModel? connection;
  final UserModel? patient;

  const _MonitorHomeContext({
    required this.currentUser,
    required this.connection,
    required this.patient,
  });
}

class _MedicineCard extends StatelessWidget {
  const _MedicineCard({required this.medicine, required this.color});

  final MedicineModel medicine;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border(left: BorderSide(color: color, width: 6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(Icons.medication, color: color, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medicine.medicineName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            medicine.dosage,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        medicine.time,
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if ((medicine.notes ?? '').isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    medicine.notes!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableVitalCard extends StatelessWidget {
  const _EditableVitalCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.onEdit,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    color: onEdit == null
                        ? AppColors.outline
                        : AppColors.onSurfaceVariant,
                    tooltip: onEdit == null ? 'No patient linked' : 'Edit',
                  ),
                  CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.12),
                    child: Icon(icon, color: color),
                  ),
                ],
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  unit,
                  style: const TextStyle(color: AppColors.outline),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 28,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 320,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Live Location',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'At Home',
                      style: TextStyle(color: AppColors.onSecondaryContainer),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(mapImage, fit: BoxFit.cover),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: FloatingActionButton.small(
                        heroTag: 'mapPreviewLocation',
                        onPressed: () {},
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        child: const Icon(Icons.my_location),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityHint extends StatelessWidget {
  const _ActivityHint();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shared Activity',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          const Text(
            'Use the Activity tab to add shared updates and notes that both sides can read.',
          ),
        ],
      ),
    );
  }
}
