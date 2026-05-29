import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';

class Medicine {
  final String id;
  final String name;
  final String type;
  final String time;

  Medicine({
    required this.id,
    required this.name,
    required this.type,
    required this.time,
  });
}

class MedicinePage extends StatefulWidget {
  const MedicinePage({super.key});

  @override
  State<MedicinePage> createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage> {
  final List<Medicine> medicines = [];

  void _addMedicine() {
    showDialog(
      context: context,
      builder: (context) => _AddMedicineDialog(
        onAdd: (name, type, time) {
          setState(() {
            medicines.add(
              Medicine(
                id: DateTime.now().toString(),
                name: name,
                type: type,
                time: time,
              ),
            );
          });
        },
      ),
    );
  }

  void _deleteMedicine(String id) {
    setState(() {
      medicines.removeWhere((m) => m.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CareScaffold(
      bottomNavIndex: 2,
      floatingActionButton: FloatingActionButton(
        onPressed: _addMedicine,
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add),
      ),
      child: PageContent(
        children: [
          Text(
            'Today\'s Schedule',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            'Wednesday, Oct 24',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          const _DayStrip(),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(
                child: _ControlCard(
                  icon: Icons.notifications_active,
                  title: 'Reminders',
                  subtitle: 'Voice & Text',
                  active: true,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: _ControlCard(
                  icon: Icons.vibration,
                  title: 'Vibration',
                  subtitle: 'Gentle Haptic',
                  active: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (medicines.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(
                      Icons.medication,
                      size: 48,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No medicines added yet',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to add your first medicine',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...medicines.map((medicine) {
              final colors = [
                AppColors.primary,
                AppColors.secondary,
                AppColors.tertiary,
              ];
              final index = medicines.indexOf(medicine) % colors.length;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _MedicineCard(
                  title: medicine.name,
                  detail: medicine.type,
                  time: medicine.time,
                  color: colors[index],
                  icon: Icons.medication,
                  onDelete: () => _deleteMedicine(medicine.id),
                ),
              );
            }).toList(),
          if (medicines.isNotEmpty) const SizedBox(height: 28),
          if (medicines.isNotEmpty)
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
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Connect with your nurse instantly.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.tonal(
                          onPressed: () {},
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Call Caregiver'),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.emergency,
                    color: Colors.white.withValues(alpha: 0.18),
                    size: 96,
                  ),
                ],
              ),
            ),
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

class _ControlCard extends StatelessWidget {
  const _ControlCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.active,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 24,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(icon, color: AppColors.primary),
              ),
              Switch(
                value: active,
                onChanged: (_) {},
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  const _MedicineCard({
    required this.title,
    required this.detail,
    required this.time,
    required this.color,
    required this.icon,
    this.button = false,
    this.faded = false,
    this.note,
    this.onDelete,
  });

  final String title;
  final String detail;
  final String time;
  final Color color;
  final IconData icon;
  final bool button;
  final bool faded;
  final String? note;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: faded ? 0.76 : 1,
      child: Container(
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
              child: Icon(icon, color: color, size: 30),
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
                              title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              detail,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
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
                              time,
                              style: TextStyle(
                                color: button
                                    ? AppColors.primary
                                    : AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (onDelete != null) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                iconSize: 18,
                                color: Colors.red,
                                onPressed: onDelete,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  if (button) ...[
                    const SizedBox(height: 16),
                    GradientButton(
                      label: 'Mark Taken',
                      icon: Icons.check_circle,
                      height: 48,
                      onPressed: () {},
                    ),
                  ],
                  if (note != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 16,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          note!,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddMedicineDialog extends StatefulWidget {
  const _AddMedicineDialog({required this.onAdd});

  final Function(String name, String type, String time) onAdd;

  @override
  State<_AddMedicineDialog> createState() => _AddMedicineDialogState();
}

class _AddMedicineDialogState extends State<_AddMedicineDialog> {
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _timeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _timeController.dispose();
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
    if (_nameController.text.isEmpty ||
        _typeController.text.isEmpty ||
        _timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    widget.onAdd(
      _nameController.text,
      _typeController.text,
      _timeController.text,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Medicine'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Medicine Name (e.g., Aspirin)',
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _typeController,
              decoration: InputDecoration(
                hintText: 'Type & Dosage (e.g., 500mg - After Breakfast)',
                labelText: 'Type/Dosage',
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
