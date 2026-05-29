import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              left: -120,
              child: _GlowBlob(animation: _controller, size: 360),
            ),
            Positioned(
              bottom: -110,
              right: -90,
              child: _GlowBlob(
                animation: _controller,
                size: 300,
                color: AppColors.tertiaryFixed.withValues(alpha: 0.18),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ListView(
                  children: [
                    const SizedBox(height: 34),
                    GlassCard(
                      radius: 28,
                      color: Colors.white.withValues(alpha: 0.12),
                      padding: const EdgeInsets.all(18),
                      child: const Icon(
                        Icons.medical_services,
                        color: Colors.white,
                        size: 62,
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      'CareLink',
                      style: Theme.of(
                        context,
                      ).textTheme.displayLarge?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'FUTURISTIC WELLNESS',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                        letterSpacing: 3.0,
                      ),
                    ),
                    const SizedBox(height: 56),
                    Text(
                      'Precision Care for Every Generation',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Empowering patients and caregivers with real-time health monitoring and seamless medical coordination.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                    const SizedBox(height: 44),
                    SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/role'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 14,
                          shadowColor: Colors.white.withValues(alpha: 0.25),
                        ),
                        child: const Text('Get Started'),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed('/auth'),
                      child: Text(
                        'Already have an account? Log In',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.68),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          color: Colors.white.withValues(alpha: 0.42),
                          size: 18,
                        ),
                        Text(
                          'Secure & HIPAA Compliant Encrypted Data',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.45),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({
    required this.animation,
    required this.size,
    this.color = const Color(0x1AFFFFFF),
  });

  final Animation<double> animation;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1 + animation.value * 0.12,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        );
      },
    );
  }
}
