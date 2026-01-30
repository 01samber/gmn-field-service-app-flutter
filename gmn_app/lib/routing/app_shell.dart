import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import 'app_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: child, bottomNavigationBar: const _BottomNavBar());
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _getSelectedIndex(location);

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Work Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Technicians',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            activeIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex(String location) {
    if (location.startsWith(AppRoutes.dashboard)) return 0;
    if (location.startsWith(AppRoutes.workOrders)) return 1;
    if (location.startsWith(AppRoutes.technicians)) return 2;
    return 3; // More menu items
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.dashboard);
        break;
      case 1:
        context.go(AppRoutes.workOrders);
        break;
      case 2:
        context.go(AppRoutes.technicians);
        break;
      case 3:
        _showMoreMenu(context);
        break;
    }
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const _MoreMenuSheet(),
    );
  }
}

class _MoreMenuSheet extends StatelessWidget {
  const _MoreMenuSheet();

  @override
  Widget build(BuildContext context) {
    final items = [
      _MoreMenuItem(
        icon: Icons.description_outlined,
        label: 'Proposals',
        route: AppRoutes.proposals,
      ),
      _MoreMenuItem(
        icon: Icons.attach_money,
        label: 'Costs',
        route: AppRoutes.costs,
      ),
      _MoreMenuItem(
        icon: Icons.folder_outlined,
        label: 'Files',
        route: AppRoutes.files,
      ),
      _MoreMenuItem(
        icon: Icons.calendar_today_outlined,
        label: 'Calendar',
        route: AppRoutes.calendar,
      ),
      _MoreMenuItem(
        icon: Icons.calculate_outlined,
        label: 'Commission',
        route: AppRoutes.commission,
      ),
      _MoreMenuItem(
        icon: Icons.bar_chart_outlined,
        label: 'Income Statement',
        route: AppRoutes.incomeStatement,
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'More',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => _buildMenuItem(context, item)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, _MoreMenuItem item) {
    final location = GoRouterState.of(context).matchedLocation;
    final isSelected = location.startsWith(item.route);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(26)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          item.icon,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
      title: Text(
        item.label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? AppColors.primary : null,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        context.go(item.route);
      },
    );
  }
}

class _MoreMenuItem {
  final IconData icon;
  final String label;
  final String route;

  _MoreMenuItem({required this.icon, required this.label, required this.route});
}
