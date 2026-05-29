import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkMode = false;
  bool vitalAlerts = true;
  bool medication = true;
  bool caregiver = false;
  bool contrast = false;
  double textSize = 4;

  @override
  Widget build(BuildContext context) {
    return CareScaffold(
      bottomNavIndex: 4,
      child: PageContent(
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
          Text(
            'Manage your account and app preferences',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          _Section(
            title: 'Appearance & Locale',
            children: [
              _SettingsTile(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                subtitle: 'Switch between light and dark themes',
                value: darkMode,
                onChanged: (value) => setState(() => darkMode = value),
              ),
              const Divider(height: 1, color: AppColors.surfaceContainer),
              const _SettingsTile(
                icon: Icons.language,
                title: 'Language',
                subtitle: 'English (US)',
                trailing: Icon(
                  Icons.chevron_right,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _Section(
            title: 'Notifications',
            children: [
              _SettingsTile(
                icon: Icons.monitor_heart,
                title: 'Vital Sign Alerts',
                subtitle: 'Critical changes in monitoring',
                iconColor: AppColors.error,
                iconBackground: AppColors.errorContainer,
                value: vitalAlerts,
                onChanged: (value) => setState(() => vitalAlerts = value),
              ),
              const Divider(height: 1, color: AppColors.surfaceContainer),
              _SettingsTile(
                icon: Icons.medication,
                title: 'Medication Reminders',
                subtitle: 'Push notifications for daily doses',
                iconColor: AppColors.tertiary,
                iconBackground: AppColors.tertiaryFixed,
                value: medication,
                onChanged: (value) => setState(() => medication = value),
              ),
              const Divider(height: 1, color: AppColors.surfaceContainer),
              _SettingsTile(
                icon: Icons.groups,
                title: 'Caregiver Activity',
                subtitle: 'Daily summary of check-ins',
                value: caregiver,
                onChanged: (value) => setState(() => caregiver = value),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _Section(
            title: 'Accessibility',
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const _IconBadge(icon: Icons.format_size),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Text Size',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                'Adjust for better readability',
                                style: TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Large',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                    Slider(
                      value: textSize,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      activeColor: AppColors.primary,
                      onChanged: (value) => setState(() => textSize = value),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.surfaceContainer),
              _SettingsTile(
                icon: Icons.contrast,
                title: 'High Contrast',
                subtitle: 'Enhance color distinction',
                value: contrast,
                onChanged: (value) => setState(() => contrast = value),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/sos'),
            icon: const Icon(Icons.emergency),
            label: const Text('EMERGENCY ASSISTANCE'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 26),
          Text(
            'CareLink Version 2.4.0\n© 2024 CareLink Wellness Systems',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.outline),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.primary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor = AppColors.primary,
    this.iconBackground = AppColors.primaryFixed,
    this.value,
    this.onChanged,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color iconBackground;
  final bool? value;
  final ValueChanged<bool>? onChanged;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _IconBadge(icon: icon, color: iconColor, background: iconBackground),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          trailing ??
              Switch(
                value: value ?? false,
                activeThumbColor: AppColors.primary,
                onChanged: onChanged,
              ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.icon,
    this.color = AppColors.primary,
    this.background = AppColors.primaryFixed,
  });

  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: background,
      foregroundColor: color,
      child: Icon(icon),
    );
  }
}
