import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/exceptions.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../repositories/auth_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  bool remember = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -110,
            left: -100,
            child: _FloatingShape(color: AppColors.primary, size: 360),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: _FloatingShape(
              color: AppColors.secondaryContainer,
              size: 310,
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(
                    children: [
                      Text(
                        'CareLink',
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Futuristic wellness at your fingertips.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 32),
                      GlassCard(
                        radius: 24,
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _TabButton(
                                    'Login',
                                    isLogin,
                                    () => setState(() => isLogin = true),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _TabButton(
                                    'Register',
                                    !isLogin,
                                    () => setState(() => isLogin = false),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 240),
                              child: isLogin
                                  ? _LoginForm(
                                      remember: remember,
                                      onRemember: (value) =>
                                          setState(() => remember = value),
                                    )
                                  : const _RegisterForm(),
                            ),
                            const SizedBox(height: 28),
                            const _DividerLabel(),
                            const SizedBox(height: 22),
                            Row(
                              children: [
                                Expanded(
                                  child: _SocialButton(
                                    label: 'Google',
                                    icon: Icons.g_mobiledata,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _SocialButton(
                                    label: 'Apple',
                                    icon: Icons.apple,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),
                      Text.rich(
                        TextSpan(
                          text: 'By continuing, you agree to CareLink\'s ',
                          children: [
                            TextSpan(
                              text: 'Terms of Service',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: AppColors.secondaryContainer,
              foregroundColor: AppColors.onSecondaryContainer,
              child: const Icon(Icons.support_agent),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton(this.label, this.active, this.onTap);

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: active ? AppColors.primary : Colors.transparent,
          foregroundColor: active ? Colors.white : AppColors.onSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm({required this.remember, required this.onRemember});

  final bool remember;
  final ValueChanged<bool> onRemember;

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final authService = FirebaseAuthService();
      final firestoreService = FirestoreService();
      final authRepository = AuthRepository(
        authService: authService,
        firestoreService: firestoreService,
      );

      await authRepository.loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/role');
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
      _showErrorSnackBar(e.message);
    } catch (e) {
      setState(() {
        _errorMessage = 'Login failed. Please try again.';
        _isLoading = false;
      });
      _showErrorSnackBar('Unexpected error: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('login'),
      children: [
        _AuthField(
          label: 'Email Address',
          hint: 'name@example.com',
          controller: _emailController,
          enabled: !_isLoading,
        ),
        const SizedBox(height: 16),
        _AuthField(
          label: 'Password',
          hint: 'Password',
          obscure: true,
          controller: _passwordController,
          enabled: !_isLoading,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Checkbox(
              value: widget.remember,
              activeColor: AppColors.primary,
              onChanged: _isLoading ? null : (value) => widget.onRemember(value ?? false),
            ),
            const Expanded(child: Text('Remember for 30 days')),
            TextButton(
              onPressed: _isLoading ? null : () {},
              child: const Text('Forgot?'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        GradientButton(
          label: _isLoading ? 'Signing In...' : 'Sign In',
          onPressed: () { if (!_isLoading) _handleLogin(); },
        ),
      ],
    );
  }
}

class _RegisterForm extends StatefulWidget {
  const _RegisterForm();

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  UserRole? _selectedRole;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _selectedRole = UserRole.patient; // Default to patient
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    setState(() {
      _errorMessage = null;
    });

    if (_nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Full name is required');
      return false;
    }

    if (_emailController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Email is required');
      return false;
    }

    if (!_emailController.text.contains('@')) {
      setState(() => _errorMessage = 'Invalid email address');
      return false;
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Password is required');
      return false;
    }

    if (_passwordController.text.length < 8) {
      setState(() => _errorMessage = 'Password must be at least 8 characters');
      return false;
    }

    if (!_passwordController.text.contains(RegExp(r'[0-9]'))) {
      setState(() => _errorMessage = 'Password must contain at least one number');
      return false;
    }

    return true;
  }

  Future<void> _handleRegistration() async {
    if (!_validateForm()) {
      _showErrorSnackBar(_errorMessage ?? 'Form validation failed');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = FirebaseAuthService();
      final firestoreService = FirestoreService();
      final authRepository = AuthRepository(
        authService: authService,
        firestoreService: firestoreService,
      );

      await authRepository.registerUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        role: _selectedRole ?? UserRole.patient,
        phone: '', // Will be added in profile completion
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Redirecting...'),
            backgroundColor: Colors.green,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/role');
        }
      }
    } on AuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar(e.message);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Registration failed: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('register'),
      children: [
        _AuthField(
          label: 'Full Name',
          hint: 'John Doe',
          controller: _nameController,
          enabled: !_isLoading,
        ),
        const SizedBox(height: 16),
        _AuthField(
          label: 'Email Address',
          hint: 'name@example.com',
          controller: _emailController,
          enabled: !_isLoading,
        ),
        const SizedBox(height: 16),
        _AuthField(
          label: 'Create Password',
          hint: 'Password',
          obscure: true,
          controller: _passwordController,
          enabled: !_isLoading,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Must be at least 8 characters with one number.',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.outline),
          ),
        ),
        const SizedBox(height: 16),
        // Role Selection
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Text(
                'Account Type',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _RoleButton(
                    label: 'Patient',
                    selected: _selectedRole == UserRole.patient,
                    onTap: _isLoading ? null : () => setState(() => _selectedRole = UserRole.patient),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _RoleButton(
                    label: 'Monitor',
                    selected: _selectedRole == UserRole.monitor,
                    onTap: _isLoading ? null : () => setState(() => _selectedRole = UserRole.monitor),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        GradientButton(
          label: _isLoading ? 'Creating Account...' : 'Create Account',
          icon: Icons.person_add,
          onPressed: () { if (!_isLoading) _handleRegistration(); },
        ),
      ],
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outlineVariant,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: selected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
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

class _DividerLabel extends StatelessWidget {
  const _DividerLabel();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR CONTINUE WITH',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.outline),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        foregroundColor: AppColors.onBackground,
        side: BorderSide(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _FloatingShape extends StatelessWidget {
  const _FloatingShape({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.32),
        shape: BoxShape.circle,
      ),
    );
  }
}
