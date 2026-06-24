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

class MedicinePage extends StatefulWidget {
  const MedicinePage({super.key});

  @override
  State<MedicinePage> createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();
  late final MedicineRepository _medicineRepository = MedicineRepository(
    firestoreService: _firestoreService,
  );
  late final ConnectionRepository _connectionRepository = ConnectionRepository(
    firestoreService: _firestoreService,
  );
  late final UserRepository _userRepository = UserRepository(
    firestoreService: _firestoreService,
  );
  late final Future<_MedicineContext> _contextFuture = _loadContext();

  Future<_MedicineContext> _loadContext() async {
    final uid = _authService.currentUserId;
    if (uid == null) {
      throw AuthException(message: 'No user logged in', code: 'no-user');
    }

    final currentUser = await _userRepository.getUserById(uid: uid);
    if (currentUser.role == UserRole.patient) {
      final connection = await _connectionRepository
          .getLatestActiveConnectionForPatient(patientId: uid);
      return _MedicineContext(
        currentUser: currentUser,
        connection: connection,
        patient: currentUser,
      );
    }

    final connection = await _connectionRepository
        .getLatestActiveConnectionForMonitor(monitorId: uid);
    if (connection == null) {
      return _MedicineContext(
        currentUser: currentUser,
        connection: null,
        patient: null,
      );
    }

    final patient = await _userRepository.getUserById(
      uid: connection.patientId,
    );
    return _MedicineContext(
      currentUser: currentUser,
      connection: connection,
      patient: patient,
    );
  }

  Future<void> _openAddMedicineDialog(_MedicineContext contextData) async {
    final patient = contextData.patient;
    final connection = contextData.connection;

    if (patient == null || connection == null) {
      return;
    }

    final added = await showDialog<_NewMedicineInput>(
      context: context,
      builder: (dialogContext) => _AddMedicineDialog(
        patientName: patient.name,
        patientEmail: patient.email,
      ),
    );

    if (added == null || !mounted) {
      return;
    }

    try {
      await _medicineRepository.createMedicine(
        connectionId: connection.id,
        patientId: patient.uid,
        monitorId: contextData.currentUser.uid,
        medicineName: added.medicineName,
        dosage: added.dosage,
        time: added.time,
        repeatDaily: added.repeatDaily,
        createdBy: contextData.currentUser.uid,
        notes: added.notes.isEmpty ? null : added.notes,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${added.medicineName} for ${patient.name}.'),
          backgroundColor: Colors.green,
        ),
      );
    } on AppException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add medicine: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  String _todayLabel() {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final now = DateTime.now();
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  Color _cardColorForIndex(int index) {
    final colors = [AppColors.primary, AppColors.secondary, AppColors.tertiary];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_MedicineContext>(
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
        final canEditMedicines =
            contextData.currentUser.role == UserRole.monitor &&
            connection != null &&
            patient != null;

        return CareScaffold(
          bottomNavIndex: 2,
          floatingActionButton: canEditMedicines
              ? FloatingActionButton(
                  onPressed: () => _openAddMedicineDialog(contextData),
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.add),
                )
              : null,
          child: PageContent(
            children: [
              Text(
                canEditMedicines ? 'Patient Medicines' : 'My Medicines',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                _todayLabel(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              if (contextData.currentUser.role == UserRole.monitor)
                _CaregiverHeader(connection: connection, patient: patient)
              else
                _PatientHeader(connection: connection),
              const SizedBox(height: 20),
              const _DayStrip(),
              const SizedBox(height: 24),
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

                  if (connection == null) {
                    return GlassCard(
                      radius: 28,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contextData.currentUser.role == UserRole.monitor
                                ? 'No active patient connection'
                                : 'No active caregiver connection',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            contextData.currentUser.role == UserRole.monitor
                                ? 'Link a patient first, then add medicines to that connection.'
                                : 'Wait for your caregiver to connect your account before medicines appear here.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    );
                  }

                  if (medicines.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.medication,
                              size: 48,
                              color: AppColors.onSurfaceVariant.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              canEditMedicines
                                  ? 'No medicines added for this connection yet'
                                  : 'No medicines added yet',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: AppColors.onSurfaceVariant),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              canEditMedicines
                                  ? 'Tap + to add the first medicine'
                                  : 'Ask your caregiver to add your medicines',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.onSurfaceVariant),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      for (var i = 0; i < medicines.length; i++) ...[
                        _MedicineCard(
                          medicine: medicines[i],
                          color: _cardColorForIndex(i),
                        ),
                        if (i != medicines.length - 1)
                          const SizedBox(height: 16),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: emergencyGradient(),
                  borderRadius: BorderRadius.circular(34),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Missed a dose?',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            canEditMedicines
                                ? 'Your caregiver can update the schedule instantly.'
                                : 'Connect with your caregiver instantly.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.emergency,
                      color: Colors.white.withValues(alpha: 0.18),
                      size: 92,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MedicineContext {
  final UserModel currentUser;
  final ConnectionModel? connection;
  final UserModel? patient;

  const _MedicineContext({
    required this.currentUser,
    required this.connection,
    required this.patient,
  });
}

class _PatientHeader extends StatelessWidget {
  const _PatientHeader({required this.connection});

  final ConnectionModel? connection;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Schedule',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            connection != null
                ? 'Your medicine list is stored inside the active caregiver connection.'
                : 'Your medicine list will appear here once a caregiver connects your account.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _CaregiverHeader extends StatelessWidget {
  const _CaregiverHeader({required this.connection, required this.patient});

  final ConnectionModel? connection;
  final UserModel? patient;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Linked Patient', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            patient != null
                ? '${patient!.name} (${patient!.email})'
                : 'No active patient linked yet',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          if (connection != null) ...[
            const SizedBox(height: 6),
            Text(
              'Connection id: ${connection!.id}',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.outline),
            ),
          ],
        ],
      ),
    );
  }
}

class _DayStrip extends StatelessWidget {
  const _DayStrip();

  @override
  Widget build(BuildContext context) {
    final days = [
      ('MON', '22'),
      ('TUE', '23'),
      ('WED', '24'),
      ('THU', '25'),
      ('FRI', '26'),
    ];
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final active = index == 2;
          return Container(
            width: 64,
            height: active ? 96 : 80,
            margin: EdgeInsets.only(top: active ? 0 : 8),
            decoration: BoxDecoration(
              gradient: active ? primaryGradient() : null,
              color: active ? null : Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(18),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.22),
                        blurRadius: 20,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  days[index].$1,
                  style: TextStyle(
                    color: active ? Colors.white70 : AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                Text(
                  days[index].$2,
                  style: TextStyle(
                    color: active ? Colors.white : AppColors.onBackground,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (active)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
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
                            style: Theme.of(context).textTheme.titleLarge,
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
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 16,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          medicine.notes!,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ),
                    ],
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

class _NewMedicineInput {
  final String medicineName;
  final String dosage;
  final String time;
  final bool repeatDaily;
  final String notes;

  const _NewMedicineInput({
    required this.medicineName,
    required this.dosage,
    required this.time,
    required this.repeatDaily,
    required this.notes,
  });
}

class _AddMedicineDialog extends StatefulWidget {
  const _AddMedicineDialog({
    required this.patientName,
    required this.patientEmail,
  });

  final String patientName;
  final String patientEmail;

  @override
  State<_AddMedicineDialog> createState() => _AddMedicineDialogState();
}

class _AddMedicineDialogState extends State<_AddMedicineDialog> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();
  bool _repeatDaily = true;

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _timeController.text = pickedTime.format(context);
      });
    }
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty ||
        _dosageController.text.trim().isEmpty ||
        _timeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill medicine name, dosage, and time'),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      _NewMedicineInput(
        medicineName: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        time: _timeController.text.trim(),
        repeatDaily: _repeatDaily,
        notes: _notesController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add medicine for ${widget.patientName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.patientEmail,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Medicine name',
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dosageController,
              decoration: InputDecoration(
                hintText: 'Dosage, e.g. 500mg',
                labelText: 'Dosage',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(
                hintText: 'Time',
                labelText: 'Time',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: const Icon(Icons.schedule),
              ),
              readOnly: true,
              onTap: _selectTime,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _repeatDaily,
              onChanged: (value) => setState(() => _repeatDaily = value),
              title: const Text('Repeat daily'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Optional notes',
                labelText: 'Notes',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}
