import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';

class SmartwatchPage extends StatelessWidget {
  const SmartwatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CareScaffold(
      bottomNavIndex: 1,
      child: PageContent(
        maxWidth: 520,
        children: [
          Center(
            child: Column(
              children: [
                SizedBox(
                  width: 260,
                  height: 260,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            width: 2,
                          ),
                        ),
                      ),
                      Container(
                        width: 215,
                        height: 215,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                      ),
                      Container(
                        width: 190,
                        height: 190,
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x1F0F172A),
                              blurRadius: 30,
                              offset: Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Image.network(watchImage, fit: BoxFit.contain),
                      ),
                      Positioned(
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.sync, color: Colors.white, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Syncing Live',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Apple Watch Series 9',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Wrap(
                  spacing: 14,
                  alignment: WrapAlignment.center,
                  children: [
                    _InlineStatus(
                      icon: Icons.battery_5_bar,
                      label: '84% Charged',
                    ),
                    _InlineStatus(
                      icon: Icons.check_circle,
                      label: 'Last sync: Just now',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          GlassCard(
            radius: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.monitor_heart, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Live ECG Stream',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryFixed,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'REAL-TIME',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 70,
                  width: double.infinity,
                  child: CustomPaint(painter: _EcgPainter()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Expanded(
                child: _MetricBox(
                  icon: Icons.favorite,
                  label: 'Heart Rate',
                  value: '72',
                  unit: 'BPM',
                  color: Colors.red,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: _MetricBox(
                  icon: Icons.bloodtype,
                  label: 'Oxygen SpO2',
                  value: '98',
                  unit: '%',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _StepsBox(),
          const SizedBox(height: 26),
          Text(
            'Settings & Security',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          const _SettingsButton(
            icon: Icons.security_update_good,
            label: 'Data Encryption',
          ),
          const SizedBox(height: 10),
          const _SettingsButton(icon: Icons.share, label: 'Caregiver Access'),
          const SizedBox(height: 10),
          const _SettingsButton(
            icon: Icons.link_off,
            label: 'Disconnect Device',
            danger: true,
          ),
        ],
      ),
    );
  }
}

class _InlineStatus extends StatelessWidget {
  const _InlineStatus({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.secondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 22,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            label.toUpperCase(),
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Text(
                  unit,
                  style: const TextStyle(color: AppColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepsBox extends StatelessWidget {
  const _StepsBox();
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 22,
      color: Colors.white,
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFE6FFFB),
            child: Icon(Icons.directions_run, color: AppColors.secondary),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAILY STEPS',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '8,432 / 10,000',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 58,
            height: 58,
            child: CircularProgressIndicator(
              value: 0.84,
              color: AppColors.secondary,
              backgroundColor: AppColors.surfaceContainerHigh,
              strokeWidth: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton({
    required this.icon,
    required this.label,
    this.danger = false,
  });
  final IconData icon;
  final String label;
  final bool danger;
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 18,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: danger ? AppColors.error : AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: danger ? AppColors.error : AppColors.onBackground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (!danger)
            const Icon(Icons.chevron_right, color: AppColors.outline),
        ],
      ),
    );
  }
}

class _EcgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryContainer
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(0, size.height * .55)
      ..lineTo(size.width * .12, size.height * .55)
      ..lineTo(size.width * .15, size.height * .2)
      ..lineTo(size.width * .18, size.height * .88)
      ..lineTo(size.width * .22, size.height * .55)
      ..lineTo(size.width * .42, size.height * .55)
      ..lineTo(size.width * .46, size.height * .08)
      ..lineTo(size.width * .51, size.height * .95)
      ..lineTo(size.width * .56, size.height * .55)
      ..lineTo(size.width, size.height * .55);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
