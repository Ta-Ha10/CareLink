import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/exceptions.dart';
import '../models/user_model.dart';
import '../repositories/connection_repository.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class ConnectDevicePage extends StatefulWidget {
  const ConnectDevicePage({super.key, this.role});

  final UserRole? role;

  @override
  State<ConnectDevicePage> createState() => _ConnectDevicePageState();
}

class _ConnectDevicePageState extends State<ConnectDevicePage> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  late final ConnectionRepository _connectionRepository = ConnectionRepository(
    firestoreService: FirestoreService(),
  );
  final TextEditingController _patientEmailController = TextEditingController();
  final TextEditingController _patientPasswordController =
      TextEditingController();

  bool _loading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get _isMonitor => widget.role == UserRole.monitor;

  @override
  void initState() {
    super.initState();
    if (widget.role == UserRole.patient) {
      _syncPatientLinkRecord();
    }
  }

  @override
  void dispose() {
    _patientEmailController.dispose();
    _patientPasswordController.dispose();
    super.dispose();
  }

  Future<void> _syncPatientLinkRecord() async {
    final patientId = _authService.currentUserId;
    final patientEmail = _authService.currentUserEmail;
    if (patientId == null || patientEmail == null) {
      return;
    }

    try {
      await _connectionRepository.upsertPatientLink(
        patientId: patientId,
        patientName: patientEmail.split('@').first,
        patientEmail: patientEmail,
      );
    } catch (_) {
      // If we can't seed the index, the patient can still use the app.
    }
  }

  Future<void> _linkPatientByCredentials() async {
    final currentUserId = _authService.currentUserId;

    if (!_isMonitor) {
      setState(
        () => _errorMessage = 'Only caregivers can link a patient here.',
      );
      return;
    }

    if (currentUserId == null) {
      setState(() => _errorMessage = 'Please sign in first.');
      return;
    }

    final patientEmail = _patientEmailController.text.trim();
    final patientPassword = _patientPasswordController.text;

    if (patientEmail.isEmpty || !patientEmail.contains('@')) {
      setState(() => _errorMessage = 'Enter a valid patient email.');
      return;
    }

    if (patientPassword.isEmpty) {
      setState(() => _errorMessage = 'Enter the patient password.');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final verifiedPatient = await _authService.verifyEmailAndPassword(
        email: patientEmail,
        password: patientPassword,
      );

      final firestore = FirestoreService();
      final patientDoc = await firestore.getDocument(
        collection: FirestoreCollections.users,
        docId: verifiedPatient.uid,
      );

      if (!patientDoc.exists) {
        throw FirestoreException.documentNotFound(verifiedPatient.uid);
      }

      final patient = UserModel.fromJson(patientDoc.data()!);
      if (patient.role != UserRole.patient) {
        throw ValidationException.invalidInput(
          'patient email must belong to a patient account',
        );
      }

      await _connectionRepository.linkPatientAndMonitor(
        patientId: patient.uid,
        monitorId: currentUserId,
        patientName: patient.name,
        patientEmail: patient.email,
        monitorName: _authService.currentUserEmail ?? 'Caregiver',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _successMessage = 'Linked ${patient.name} successfully.';
        _loading = false;
      });
      _patientPasswordController.clear();
    } catch (e) {
      if (!mounted) {
        return;
      }

      final message = e is AppException ? e.message : e.toString();
      setState(() {
        _errorMessage = 'Link failed: $message';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = _authService.currentUserEmail;

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
            maxWidth: 620,
            children: [
              Text(
                'Link Caregiver & Patient',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _isMonitor
                    ? 'Select a patient to create a secure connection.'
                    : 'Share your account email with your caregiver so they can connect your account.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              if (_isMonitor)
                GlassCard(
                  radius: 28,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Caregiver Link',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the patient account email and password to verify ownership before linking.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _AuthField(
                        label: 'Patient Email',
                        hint: 'patient@example.com',
                        controller: _patientEmailController,
                        enabled: !_loading,
                      ),
                      const SizedBox(height: 16),
                      _AuthField(
                        label: 'Patient Password',
                        hint: 'Password',
                        obscure: true,
                        controller: _patientPasswordController,
                        enabled: !_loading,
                      ),
                      const SizedBox(height: 20),
                      GradientButton(
                        label: _loading ? 'Linking...' : 'Verify & Link',
                        icon: Icons.link,
                        onPressed: _loading ? () {} : _linkPatientByCredentials,
                      ),
                    ],
                  ),
                )
              else
                GlassCard(
                  radius: 28,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Account Email',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Share this email with your caregiver. They can use it to connect your account.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.18),
                          ),
                        ),
                        child: SelectableText(
                          currentUserEmail ?? 'Sign in again to get your email',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                letterSpacing: 2.4,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      GradientButton(
                        label: 'Open Patient Home',
                        icon: Icons.home,
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushReplacementNamed('/patient');
                        },
                      ),
                    ],
                  ),
                ),
              if (_successMessage != null) ...[
                const SizedBox(height: 16),
                GlassCard(
                  radius: 24,
                  child: Text(
                    _successMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.label,
    required this.hint,
    this.obscure = false,
    this.controller,
    this.enabled = true,
  });

  final String label;
  final String hint;
  final bool obscure;
  final TextEditingController? controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 5),
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
        TextField(
          controller: controller,
          obscureText: obscure,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.52),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
          ),
        ),
      ],
    );
  }
}
