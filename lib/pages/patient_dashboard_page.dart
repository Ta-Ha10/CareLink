import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';

class PatientDashboardPage extends StatelessWidget {
  const PatientDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CareScaffold(
      bottomNavIndex: 0,
      child: PageContent(
        children: [
          const _DailyProgressCard(),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: _WatchCard()),
              SizedBox(width: 16),
              Expanded(child: _HeartRateCard()),
            ],
          ),
          const SizedBox(height: 28),
          const SectionTitle('Next Medications', action: 'View All'),
          const SizedBox(height: 14),
          SizedBox(
            height: 92,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _DoseCard(
                  medicine: 'Lisinopril',
                  detail: '10mg • 09:00 AM',
                  active: true,
                ),
                SizedBox(width: 14),
                _DoseCard(
                  medicine: 'Atorvastatin',
                  detail: '20mg • 08:00 PM',
                  active: false,
                ),
              ],
            ),
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

class _DoseCard extends StatelessWidget {
  const _DoseCard({
    required this.medicine,
    required this.detail,
    required this.active,
  });

  final String medicine;
  final String detail;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: glassDecoration(radius: 18).copyWith(
        border: Border(
          left: BorderSide(
            color: active ? AppColors.primary : AppColors.secondaryFixedDim,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: active
                ? AppColors.primaryFixed.withValues(alpha: 0.5)
                : AppColors.secondaryContainer.withValues(alpha: 0.35),
            child: Icon(
              active ? Icons.medication : Icons.medication_liquid,
              color: active ? AppColors.primary : AppColors.secondary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine,
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
          CircleAvatar(
            backgroundColor: active ? AppColors.primary : Colors.transparent,
            foregroundColor: active ? Colors.white : AppColors.outline,
            child: Icon(active ? Icons.check : Icons.schedule),
          ),
        ],
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
