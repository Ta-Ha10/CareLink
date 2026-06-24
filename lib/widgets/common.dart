import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

const profileImage =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCSW1mhaLcNsleAHOGrvAmkZ8snQ_Qzt1suUjk8xI4Rgf4XOHPcalWwuIfh9xd5_FaG3DgLGOjNSiERN6dtaP_Gr5-YAarXrEWLC7bAnBbDBZmzOQPsQtnwg_REPWqf9Ro6a66tSKbQMRuaxxjvPjhvvY0aOQqVk7YjhZ7YqxNdQ4C3u38Kqu9VUCo1yvI8KMlYHZ0FRrD0aUDGSNlVmTjI_cRbx6q6QxjiN2PTVClgt9C5JoIzSD58kn74nQfGbwW6OMOIwQxObhI';
const mapImage =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuDlDkVoleEqslNkJRqCzny_tAzL5fn5l8zTThHxVppfMWV7DVtK7_TIKJALqKOYO6ZUyDp32P4UvfoRaPkKurXW7-Df1JoBAs2wOV3lKX80MFVJJ2K8UxCJRLq17AsGDLtU83wrTBL3yczw_UIVa6Q6KVla2orYh1SlhcAzzcFcCHovSTNcIfzaIHLNtGIiiSN-ELwk6eEJZhV36DJtOo-RgosjtMU7O0txZerKJJ_6FpP99jeFLUi6uv6ds5bR8o98QXFm2_W6cHE';
const scanImage =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBMeatpwCEKvMgyqmratBbUR42q_x_YrPPbl7Xt_TXJCS33V6YDA_lScq7QRvge6No_-dQ6wgznBf2FY5v--WzaVhM25fs5I2Mw-0e5KvXwRgBhC1nKUBKQUi-FnV03hy2RjAmZBKr18NRNAnPeZZupDkl2d4ZI6rkbPA_8q4tlmw-f-CW3RfvR27GKVoSGBXiNG57yvbnelXpXSzB3AW9lemLHmn3MMGP3T8PaMdfJ0olGL-72GneEBVHHJ2GYabH9kbngPMJL3Ew';
const watchImage =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBe8l7Zr1StNG3m1Cjdsu2LBY1sudeBpTAAAjfnnfp0dhEbdGDPMTFIJVqxYtfpysTuzuh2kHFNpbY-KcruqOhWa4mdNUMkHRkqSccvf2As07JSR46HFWTIpJRfgJnXRx50ZZmkg10xt62T82BOdpy3LpvffVVa1dk630HD2vv2rSRAEUJYO5Y6k-0W9M_8Zm0KPU_CCDDkMRMMWnLjku_ihcm3uJE00EUKrGmFmug_KYWPQVOqJ5gq7Y9ccV7-NcjRJSDnSUFHdbA';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 24,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: glassDecoration(radius: radius, color: color),
      child: child,
    );
  }
}

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_forward,
    this.height = 56,
    this.gradient,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;
  final double height;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient ?? primaryGradient(),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: TextButton.icon(
          onPressed: onPressed,
          iconAlignment: IconAlignment.end,
          icon: Icon(icon, color: Colors.white),
          label: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class CareTopBar extends StatelessWidget {
  const CareTopBar({
    super.key,
    this.showProfile = true,
    this.leading,
    this.trailingIcon = Icons.notifications_outlined,
    this.onTrailing,
  });

  final bool showProfile;
  final Widget? leading;
  final IconData trailingIcon;
  final VoidCallback? onTrailing;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            border: Border(
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              if (leading != null)
                leading!
              else if (showProfile)
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(profileImage),
                ),
              if (showProfile || leading != null) const SizedBox(width: 12),
              Text(
                'CareLink',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onTrailing,
                icon: Icon(trailingIcon, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CareScaffold extends StatelessWidget {
  const CareScaffold({
    super.key,
    required this.child,
    this.bottomNavIndex,
    this.topBar = true,
    this.floatingActionButton,
  });

  final Widget child;
  final int? bottomNavIndex;
  final bool topBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [child, if (topBar) const CareTopBar()],
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavIndex == null
          ? null
          : CareBottomNav(index: bottomNavIndex!),
    );
  }
}

class CareBottomNav extends StatelessWidget {
  const CareBottomNav({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Home', Icons.home, '/patient'),
      ('Monitoring', Icons.monitor_heart, '/monitoring'),
      ('Medicine', Icons.medication, '/medicine'),
      ('Activity', Icons.event_note, '/activity'),
      ('Settings', Icons.settings, '/settings'),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var i = 0; i < items.length; i++)
              _NavItem(
                label: items[i].$1,
                icon: items[i].$2,
                active: index == i,
                onTap: () => Navigator.of(context).pushNamed(items[i].$3),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.white : AppColors.onSurfaceVariant;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontSize: 11,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PageContent extends StatelessWidget {
  const PageContent({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(24, 96, 24, 128),
    this.maxWidth = 720,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = constraints.maxWidth < maxWidth
            ? constraints.maxWidth
            : maxWidth;

        return SingleChildScrollView(
          padding: padding,
          child: Center(
            child: SizedBox(
              width: contentWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        );
      },
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.action});

  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (action != null)
          Text(action!, style: const TextStyle(color: AppColors.primary)),
      ],
    );
  }
}
