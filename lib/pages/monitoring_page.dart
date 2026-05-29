import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';

class MonitoringPage extends StatelessWidget {
  const MonitoringPage({super.key});

  @override
  Widget build(BuildContext context) {
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
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 760;
              final cards = const [
                _VitalCard(
                  label: 'Heart Rate',
                  value: '72',
                  unit: 'BPM',
                  icon: Icons.favorite,
                  color: AppColors.error,
                ),
                _VitalCard(
                  label: 'Blood Oxygen',
                  value: '98',
                  unit: '%',
                  icon: Icons.air,
                  color: AppColors.secondary,
                ),
                _VitalCard(
                  label: 'Current State',
                  value: 'Resting',
                  unit: '45 mins',
                  icon: Icons.bed,
                  color: AppColors.tertiary,
                ),
              ];
              return GridView.count(
                crossAxisCount: wide ? 3 : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: wide ? 1.55 : 2.4,
                children: cards,
              );
            },
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 760;
              final children = [const _MapPreview(), const _RecentAlerts()];
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
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 760;
              return wide
                  ? const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _DailyMedsCard()),
                        SizedBox(width: 20),
                        Expanded(flex: 2, child: _ActivityTimeline()),
                      ],
                    )
                  : const Column(
                      children: [
                        _DailyMedsCard(),
                        SizedBox(height: 20),
                        _ActivityTimeline(),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }
}

class _VitalCard extends StatelessWidget {
  const _VitalCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

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
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color),
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

class _RecentAlerts extends StatelessWidget {
  const _RecentAlerts();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 28,
      child: SizedBox(
        height: 280,
        child: Column(
          children: [
            const SectionTitle('Recent Alerts', action: 'View All'),
            const SizedBox(height: 16),
            const _AlertTile(
              title: 'High Heart Rate Detected',
              text: 'Pulse peaked at 110 BPM during rest.',
              time: '10:45 AM Today',
              color: AppColors.error,
              icon: Icons.warning,
            ),
            const SizedBox(height: 12),
            const _AlertTile(
              title: 'Medication Missed',
              text: 'Morning dosage of Lisinopril not confirmed.',
              time: '09:00 AM Today',
              color: AppColors.primary,
              icon: Icons.notifications,
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({
    required this.title,
    required this.text,
    required this.time,
    required this.color,
    required this.icon,
  });

  final String title;
  final String text;
  final String time;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  text,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.outline,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyMedsCard extends StatelessWidget {
  const _DailyMedsCard();

  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      radius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Meds',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16),
          _MedStatus(
            name: 'Lisinopril',
            detail: 'Taken at 8:15 AM',
            done: true,
          ),
          SizedBox(height: 14),
          _MedStatus(name: 'Metformin', detail: 'Due at 8:00 PM', done: false),
        ],
      ),
    );
  }
}

class _MedStatus extends StatelessWidget {
  const _MedStatus({
    required this.name,
    required this.detail,
    required this.done,
  });

  final String name;
  final String detail;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: done
              ? AppColors.secondary.withValues(alpha: 0.1)
              : AppColors.outlineVariant.withValues(alpha: 0.12),
          child: Icon(
            done ? Icons.check : Icons.schedule,
            color: done ? AppColors.secondary : AppColors.outline,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(
              detail,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.outline),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActivityTimeline extends StatelessWidget {
  const _ActivityTimeline();

  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      radius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Timeline',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 18),
          _TimelineItem(
            icon: Icons.directions_walk,
            title: 'Morning Walk Completed',
            text: '2,450 steps tracked in Central Park area.',
            time: '7:30 AM - 8:00 AM',
          ),
          SizedBox(height: 18),
          _TimelineItem(
            icon: Icons.restaurant,
            title: 'Breakfast',
            text: 'Logged by smart kitchen device.',
            time: '8:20 AM',
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.icon,
    required this.title,
    required this.text,
    required this.time,
  });

  final IconData icon;
  final String title;
  final String text;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          child: Icon(icon, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(
                text,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.outline,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
