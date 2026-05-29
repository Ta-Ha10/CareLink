import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -190,
            left: -190,
            child: _Blob(color: AppColors.primaryFixed, size: 500),
          ),
          Positioned(
            bottom: -90,
            right: -120,
            child: _Blob(color: AppColors.secondaryFixedDim, size: 400),
          ),
          const CareTopBar(
            showProfile: false,
            trailingIcon: Icons.help_outline,
          ),
          PageContent(
            padding: const EdgeInsets.fromLTRB(24, 112, 24, 32),
            maxWidth: 920,
            children: [
              Text(
                'Welcome to CareLink',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.displayLarge?.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 14),
              Text(
                'To personalize your experience, please select your primary role in the health circle.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 44),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 700;
                  final cards = [
                    RoleCard(
                      title: 'I am a Patient',
                      description:
                          'Access your health vitals, medication reminders, and direct emergency assistance in one secure place.',
                      action: 'Continue as Patient',
                      icon: Icons.person,
                      color: AppColors.primary,
                      onTap: () => Navigator.of(context).pushNamed('/patient'),
                    ),
                    RoleCard(
                      title: 'I am a Caregiver',
                      description:
                          'Monitor loved ones remotely, receive real-time alerts, and coordinate care plans with clinical precision.',
                      action: 'Continue as Caregiver',
                      icon: Icons.visibility,
                      color: AppColors.secondary,
                      onTap: () =>
                          Navigator.of(context).pushNamed('/monitoring'),
                    ),
                  ];
                  if (!wide) {
                    return Column(
                      children: [
                        cards[0],
                        const SizedBox(height: 20),
                        cards[1],
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: 28),
                      Expanded(child: cards[1]),
                    ],
                  );
                },
              ),
              const SizedBox(height: 48),
              Text(
                'Already have an account?',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.outline),
              ),
              const SizedBox(height: 14),
              Center(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pushNamed('/auth'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.22),
                      width: 2,
                    ),
                    minimumSize: const Size(180, 48),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Sign In Instead'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  const RoleCard({
    super.key,
    required this.title,
    required this.description,
    required this.action,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String description;
  final String action;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: GlassCard(
        radius: 32,
        padding: const EdgeInsets.all(28),
        child: Stack(
          children: [
            Positioned(
              top: -8,
              right: -8,
              child: Icon(icon, size: 92, color: color.withValues(alpha: 0.08)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: color == AppColors.primary
                        ? primaryGradient()
                        : null,
                    color: color == AppColors.primary
                        ? null
                        : AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.22),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: color == AppColors.primary
                        ? Colors.white
                        : AppColors.onSecondaryContainer,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 24),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        action,
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: color),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: color),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.42),
        shape: BoxShape.circle,
      ),
    );
  }
}
