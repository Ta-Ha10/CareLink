import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';

class SosPage extends StatefulWidget {
  const SosPage({super.key});

  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> {
  Timer? timer;
  double progress = 0;
  bool alerted = false;

  void startHold() {
    timer?.cancel();
    progress = 0;
    timer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      setState(() => progress = (progress + 0.02).clamp(0, 1));
      if (progress >= 1) {
        timer.cancel();
        setState(() => alerted = true);
      }
    });
  }

  void endHold() {
    timer?.cancel();
    if (!alerted) setState(() => progress = 0);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CareScaffold(
      bottomNavIndex: 3,
      child: PageContent(
        maxWidth: 430,
        children: [
          Text(
            'Emergency Help',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 8),
          Text(
            'Press and hold the button for 3 seconds to initiate SOS alert.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 28),
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              alignment: Alignment.center,
              children: [
                for (final inset in [0.0, 30.0, 62.0])
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.all(inset),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(
                            alpha: 0.1 + inset / 600,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 5,
                    color: AppColors.error,
                    backgroundColor: AppColors.error.withValues(alpha: 0.1),
                  ),
                ),
                GestureDetector(
                  onLongPressStart: (_) => startHold(),
                  onLongPressEnd: (_) => endHold(),
                  onTapDown: (_) => startHold(),
                  onTapUp: (_) => endHold(),
                  onTapCancel: endHold,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      gradient: alerted
                          ? const LinearGradient(
                              colors: [Color(0xFF16A34A), Color(0xFF15803D)],
                            )
                          : const LinearGradient(
                              colors: [AppColors.error, Color(0xFFEF4444)],
                            ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.error.withValues(alpha: 0.3),
                          blurRadius: 44,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          alerted ? Icons.check_circle : Icons.emergency,
                          color: Colors.white,
                          size: 62,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          alerted ? 'ALERTED' : 'SOS',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                letterSpacing: 1.4,
                              ),
                        ),
                        Text(
                          alerted ? 'Help notified' : 'Hold to alert',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.82),
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
          GlassCard(
            radius: 28,
            child: Column(
              children: [
                const Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryFixed,
                      child: Icon(Icons.location_on, color: AppColors.primary),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Live Location',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Sharing is active',
                            style: TextStyle(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text('GPS High'),
                      backgroundColor: AppColors.secondaryContainer,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    height: 128,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(mapImage, fit: BoxFit.cover),
                        Center(
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.35,
                                  ),
                                  blurRadius: 18,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionTitle('Primary Contacts', action: 'Edit'),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(
                child: _ContactCard(
                  name: 'Sarah (Daughter)',
                  detail: '0.5 mi away',
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: _ContactCard(name: 'Dr. James', detail: 'At Clinic'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.name, required this.detail});

  final String name;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(profileImage),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(
            detail,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.call, size: 18),
            label: const Text('Call'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.06),
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
