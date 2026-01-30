import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../routing/app_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const AppBottomNavigation(),
    );
  }
}

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({super.key});

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location == AppRoutes.dashboard) return 0;
    if (location.startsWith('/work-orders')) return 1;
    if (location.startsWith('/technicians')) return 2;
    if (location.startsWith('/costs')) return 3;
    if (location.startsWith('/proposals') ||
        location.startsWith('/calendar') ||
        location.startsWith('/files') ||
        location.startsWith('/commission') ||
        location.startsWith('/income-statement')) {
      return 4;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.dashboard_outlined,
                selectedIcon: Icons.dashboard,
                label: 'Dashboard',
                isSelected: selectedIndex == 0,
                onTap: () => context.go(AppRoutes.dashboard),
              ),
              _NavItem(
                icon: Icons.assignment_outlined,
                selectedIcon: Icons.assignment,
                label: 'Work Orders',
                isSelected: selectedIndex == 1,
                onTap: () => context.go(AppRoutes.workOrders),
              ),
              _NavItem(
                icon: Icons.engineering_outlined,
                selectedIcon: Icons.engineering,
                label: 'Technicians',
                isSelected: selectedIndex == 2,
                onTap: () => context.go(AppRoutes.technicians),
              ),
              _NavItem(
                icon: Icons.attach_money_outlined,
                selectedIcon: Icons.attach_money,
                label: 'Costs',
                isSelected: selectedIndex == 3,
                onTap: () => context.go(AppRoutes.costs),
              ),
              _MoreNavItem(isSelected: selectedIndex == 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                    ? AppColors.brand500.withValues(alpha: 0.15)
                    : AppColors.brand50)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              size: 24,
              color: isSelected
                  ? AppColors.brand500
                  : (isDark ? AppColors.slate400 : AppColors.slate500),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.brand500
                    : (isDark ? AppColors.slate400 : AppColors.slate500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreNavItem extends StatelessWidget {
  final bool isSelected;

  const _MoreNavItem({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () => _showMoreMenu(context),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                    ? AppColors.brand500.withValues(alpha: 0.15)
                    : AppColors.brand50)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.more_horiz : Icons.more_horiz_outlined,
              size: 24,
              color: isSelected
                  ? AppColors.brand500
                  : (isDark ? AppColors.slate400 : AppColors.slate500),
            ),
            const SizedBox(height: 4),
            Text(
              'More',
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.brand500
                    : (isDark ? AppColors.slate400 : AppColors.slate500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreMenu(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.slate600 : AppColors.slate300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _MoreMenuItem(
                icon: Icons.description_outlined,
                label: 'Proposals',
                onTap: () {
                  Navigator.pop(context);
                  context.go(AppRoutes.proposals);
                },
              ),
              _MoreMenuItem(
                icon: Icons.calendar_today_outlined,
                label: 'Calendar',
                onTap: () {
                  Navigator.pop(context);
                  context.go(AppRoutes.calendar);
                },
              ),
              _MoreMenuItem(
                icon: Icons.folder_outlined,
                label: 'Files',
                onTap: () {
                  Navigator.pop(context);
                  context.go(AppRoutes.files);
                },
              ),
              _MoreMenuItem(
                icon: Icons.calculate_outlined,
                label: 'Commission Calculator',
                onTap: () {
                  Navigator.pop(context);
                  context.go(AppRoutes.commission);
                },
              ),
              _MoreMenuItem(
                icon: Icons.bar_chart_outlined,
                label: 'Income Statement',
                onTap: () {
                  Navigator.pop(context);
                  context.go(AppRoutes.incomeStatement);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MoreMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.slate800 : AppColors.slate100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isDark ? AppColors.slate300 : AppColors.slate600,
        ),
      ),
      title: Text(label, style: theme.textTheme.titleMedium),
      trailing: Icon(
        Icons.chevron_right,
        color: isDark ? AppColors.slate500 : AppColors.slate400,
      ),
      onTap: onTap,
    );
  }
}
