import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';

class ConnectDevicePage extends StatefulWidget {
  const ConnectDevicePage({super.key});

  @override
  State<ConnectDevicePage> createState() => _ConnectDevicePageState();
}

class _ConnectDevicePageState extends State<ConnectDevicePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController codeController = TextEditingController();
  late final AnimationController scanController;
  bool loading = false;
  bool success = false;

  @override
  void initState() {
    super.initState();
    scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    codeController.dispose();
    scanController.dispose();
    super.dispose();
  }

  void connect() {
    setState(() => loading = true);
    Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => success = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const CareTopBar(
            showProfile: false,
            trailingIcon: Icons.help_outline,
            leading: BackButton(color: AppColors.primary),
          ),
          PageContent(
            padding: const EdgeInsets.fromLTRB(24, 96, 24, 32),
            maxWidth: 390,
            children: [
              Text(
                'Connect Device',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Position the QR code inside the frame to link your health monitor automatically.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 34),
              Center(
                child: SizedBox.square(
                  dimension: 280,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                Colors.grey,
                                BlendMode.saturation,
                              ),
                              child: Image.network(
                                scanImage,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              color: Colors.black.withValues(alpha: 0.38),
                            ),
                            AnimatedBuilder(
                              animation: scanController,
                              builder: (context, child) {
                                return Positioned(
                                  top: scanController.value * 278,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 2,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          AppColors.primaryContainer,
                                          Colors.transparent,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryContainer
                                              .withValues(alpha: 0.5),
                                          blurRadius: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.42),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Scanning for devices...',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const _Corner(alignment: Alignment.topLeft),
                      const _Corner(alignment: Alignment.topRight),
                      const _Corner(alignment: Alignment.bottomLeft),
                      const _Corner(alignment: Alignment.bottomRight),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 34),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: AppColors.outlineVariant.withValues(alpha: 0.45),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'OR',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.onSurfaceVariant.withValues(
                          alpha: 0.6,
                        ),
                        letterSpacing: 2.4,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: AppColors.outlineVariant.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Manual Invite Code',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: codeController,
                maxLength: 8,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                  UpperCaseTextFormatter(),
                ],
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  letterSpacing: 3.2,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'ENTER 8-DIGIT CODE',
                  suffixIcon: const Icon(
                    Icons.edit_note,
                    color: AppColors.primary,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: Color(0xFFE2E8F0),
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              GradientButton(
                label: loading ? 'Establishing Link...' : 'Connect',
                icon: loading ? Icons.sync : Icons.arrow_forward,
                height: 64,
                onPressed: loading ? () {} : connect,
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Secured by CareLink End-to-End Encryption',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant.withValues(
                          alpha: 0.72,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (success)
            Positioned.fill(
              child: Container(
                color: Colors.white.withValues(alpha: 0.72),
                child: Center(
                  child: GlassCard(
                    radius: 32,
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          radius: 42,
                          backgroundColor: AppColors.secondaryContainer,
                          child: Icon(
                            Icons.check_circle,
                            color: AppColors.onSecondaryContainer,
                            size: 44,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'Connection Successful',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Your device is now securely paired with the CareLink ecosystem.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 28),
                        OutlinedButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/patient'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Continue to Dashboard'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  const _Corner({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          border: Border(
            top: alignment.y < 0
                ? const BorderSide(color: AppColors.primaryContainer, width: 4)
                : BorderSide.none,
            bottom: alignment.y > 0
                ? const BorderSide(color: AppColors.primaryContainer, width: 4)
                : BorderSide.none,
            left: alignment.x < 0
                ? const BorderSide(color: AppColors.primaryContainer, width: 4)
                : BorderSide.none,
            right: alignment.x > 0
                ? const BorderSide(color: AppColors.primaryContainer, width: 4)
                : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: alignment == Alignment.topLeft
                ? const Radius.circular(12)
                : Radius.zero,
            topRight: alignment == Alignment.topRight
                ? const Radius.circular(12)
                : Radius.zero,
            bottomLeft: alignment == Alignment.bottomLeft
                ? const Radius.circular(12)
                : Radius.zero,
            bottomRight: alignment == Alignment.bottomRight
                ? const Radius.circular(12)
                : Radius.zero,
          ),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
