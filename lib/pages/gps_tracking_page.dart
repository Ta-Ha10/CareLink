import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';

class GpsTrackingPage extends StatelessWidget {
  const GpsTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CareScaffold(
      topBar: false,
      bottomNavIndex: 1,
      child: Stack(
        children: [
          Positioned.fill(child: Image.network(mapImage, fit: BoxFit.cover)),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.surface.withValues(alpha: 0.92),
                    Colors.transparent,
                    Colors.transparent,
                    AppColors.surface.withValues(alpha: 0.9),
                  ],
                  stops: const [0, 0.16, 0.75, 1],
                ),
              ),
            ),
          ),
          const CareTopBar(),
          Positioned(
            top: 260,
            left: 150,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.person_pin_circle, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: const Text('Martha • Just now'),
                ),
              ],
            ),
          ),
          Positioned(
            top: 210,
            right: 110,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.secondary,
              child: const Icon(Icons.home, color: Colors.white),
            ),
          ),
          Positioned(
            top: 96,
            left: 24,
            right: 24,
            child: GlassCard(
              radius: 28,
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.primaryFixed,
                        child: Icon(
                          Icons.directions_walk,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CURRENT ACTIVITY',
                              style: TextStyle(
                                color: AppColors.outline,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Daily Walk',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'On Track',
                          style: TextStyle(
                            color: AppColors.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(
                        child: _MiniMetric(
                          label: 'Heart Rate',
                          value: '78',
                          unit: 'bpm',
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _MiniMetric(
                          label: 'Distance',
                          value: '0.8',
                          unit: 'mi',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 116,
            left: 24,
            right: 24,
            child: Column(
              children: [
                GradientButton(
                  label: 'Call Martha',
                  icon: Icons.call,
                  onPressed: () {},
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble),
                  label: const Text('Send Voice Message'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GradientButton(
                  label: 'Emergency Alert',
                  icon: Icons.emergency,
                  gradient: emergencyGradient(),
                  onPressed: () => Navigator.of(context).pushNamed('/sos'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.outline),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppColors.primary),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
