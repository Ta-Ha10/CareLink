import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CareScaffold(
      bottomNavIndex: 3,
      child: PageContent(
        maxWidth: 760,
        children: [
          Text(
            'Recent Alerts',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            'Stay updated with your daily health activity.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 28),
          const _AlertGroup(
            title: 'Critical Alerts',
            icon: Icons.emergency,
            color: AppColors.error,
            children: [
              _NotificationCard(
                title: 'Fall Detected: John Doe',
                body:
                    'Smart sensor triggered a fall alert in the Living Room area. Immediate attention required.',
                time: '2m ago',
                icon: Icons.location_on,
                color: AppColors.error,
                primaryAction: 'View Location',
                secondaryAction: 'Call Device',
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _AlertGroup(
            title: 'Medication Reminders',
            icon: Icons.medication,
            color: Color(0xFFF59E0B),
            children: [
              _NotificationCard(
                title: 'Missed: Metoprolol 25mg',
                body:
                    'Scheduled for 09:00 AM. Heart rate optimization medication.',
                time: '45m ago',
                icon: Icons.medication_liquid,
                color: Color(0xFFF59E0B),
                primaryAction: 'Mark as Taken',
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _AlertGroup(
            title: 'Health Sync Updates',
            icon: Icons.sync,
            color: AppColors.primary,
            children: [
              _NotificationCard(
                title: 'Daily Report Available',
                body:
                    'Yesterday\'s vitals summary: Sleep (7.5h), Avg Heart Rate (72 bpm).',
                time: '2h ago',
                icon: Icons.favorite,
                color: AppColors.primary,
                primaryAction: 'Review Stats',
              ),
              _NotificationCard(
                title: 'Device Maintenance',
                body:
                    'Wearable battery at 20%. Please connect to charger soon.',
                time: '5h ago',
                icon: Icons.battery_charging_full,
                color: AppColors.tertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlertGroup extends StatelessWidget {
  const _AlertGroup({
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...children.expand((child) => [child, const SizedBox(height: 14)]),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.color,
    this.primaryAction,
    this.secondaryAction,
  });

  final String title;
  final String body;
  final String time;
  final IconData icon;
  final Color color;
  final String? primaryAction;
  final String? secondaryAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: glassDecoration(radius: 18).copyWith(
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color),
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
                      child: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      time,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                if (primaryAction != null) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: Text(primaryAction!),
                      ),
                      if (secondaryAction != null)
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                          child: Text(secondaryAction!),
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
