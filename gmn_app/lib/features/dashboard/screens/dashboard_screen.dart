import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../routing/app_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../data/models/dashboard_stats.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardStatsProvider);
          },
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.name ?? 'User',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await ref.read(authStateProvider.notifier).logout();
                          if (context.mounted) {
                            context.go(AppRoutes.login);
                          }
                        },
                        icon: const Icon(Icons.logout_outlined),
                        tooltip: 'Logout',
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              statsAsync.when(
                loading: () => const SliverFillRemaining(
                  child: LoadingSpinner(message: 'Loading dashboard...'),
                ),
                error: (error, _) => SliverFillRemaining(
                  child: ErrorMessage(
                    message: error.toString(),
                    onRetry: () => ref.invalidate(dashboardStatsProvider),
                  ),
                ),
                data: (stats) => SliverList(
                  delegate: SliverChildListDelegate([
                    // Alerts
                    if (stats.alerts.isNotEmpty)
                      _AlertsSection(alerts: stats.alerts),

                    // Overview Stats
                    _OverviewSection(overview: stats.overview),

                    // Status Chart
                    _StatusChartSection(statusBreakdown: stats.statusBreakdown),

                    // Financial Summary
                    _FinancialSection(financial: stats.financial),

                    // Top Technicians
                    if (stats.topTechnicians.isNotEmpty)
                      _TopTechniciansSection(technicians: stats.topTechnicians),

                    // Recent Activity
                    if (stats.recentActivity.isNotEmpty)
                      _RecentActivitySection(activities: stats.recentActivity),

                    const SizedBox(height: 100), // Bottom padding for nav bar
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertsSection extends StatelessWidget {
  final List<Alert> alerts;

  const _AlertsSection({required this.alerts});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: alerts.map((alert) {
          final color = _getAlertColor(alert.severity);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(_getAlertIcon(alert.type), color: color, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    alert.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white : AppColors.slate900,
                    ),
                  ),
                ),
                if (alert.count > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${alert.count}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getAlertColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  IconData _getAlertIcon(String type) {
    switch (type.toLowerCase()) {
      case 'overdue':
        return Icons.schedule;
      case 'pending':
        return Icons.pending_actions;
      case 'urgent':
        return Icons.priority_high;
      default:
        return Icons.info_outline;
    }
  }
}

class _OverviewSection extends StatelessWidget {
  final Overview overview;

  const _OverviewSection({required this.overview});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Overview', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              StatCard(
                title: 'Work Orders',
                value: '${overview.totalWorkOrders}',
                icon: Icons.assignment,
                iconColor: AppColors.brand500,
                onTap: () => context.go(AppRoutes.workOrders),
              ),
              StatCard(
                title: 'Active',
                value: '${overview.activeWorkOrders}',
                icon: Icons.pending_actions,
                iconColor: AppColors.warning,
              ),
              StatCard(
                title: 'Completed',
                value: '${overview.completedThisMonth}',
                icon: Icons.check_circle,
                iconColor: AppColors.success,
                trend: 'This month',
              ),
              StatCard(
                title: 'Technicians',
                value: '${overview.totalTechnicians}',
                icon: Icons.engineering,
                iconColor: AppColors.invoicedText,
                onTap: () => context.go(AppRoutes.technicians),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChartSection extends StatelessWidget {
  final StatusBreakdown statusBreakdown;

  const _StatusChartSection({required this.statusBreakdown});

  @override
  Widget build(BuildContext context) {
    if (statusBreakdown.total == 0) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AppCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Work Order Status', style: theme.textTheme.titleMedium),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                            value: statusBreakdown.waiting.toDouble(),
                            title: '',
                            color: AppColors.waitingText,
                            radius: 25,
                          ),
                          PieChartSectionData(
                            value: statusBreakdown.inProgress.toDouble(),
                            title: '',
                            color: AppColors.inProgressText,
                            radius: 25,
                          ),
                          PieChartSectionData(
                            value: statusBreakdown.completed.toDouble(),
                            title: '',
                            color: AppColors.completedText,
                            radius: 25,
                          ),
                          PieChartSectionData(
                            value: statusBreakdown.invoiced.toDouble(),
                            title: '',
                            color: AppColors.invoicedText,
                            radius: 25,
                          ),
                          PieChartSectionData(
                            value: statusBreakdown.paid.toDouble(),
                            title: '',
                            color: AppColors.paidText,
                            radius: 25,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LegendItem(
                        color: AppColors.waitingText,
                        label: 'Waiting',
                        count: statusBreakdown.waiting,
                      ),
                      _LegendItem(
                        color: AppColors.inProgressText,
                        label: 'In Progress',
                        count: statusBreakdown.inProgress,
                      ),
                      _LegendItem(
                        color: AppColors.completedText,
                        label: 'Completed',
                        count: statusBreakdown.completed,
                      ),
                      _LegendItem(
                        color: AppColors.invoicedText,
                        label: 'Invoiced',
                        count: statusBreakdown.invoiced,
                      ),
                      _LegendItem(
                        color: AppColors.paidText,
                        label: 'Paid',
                        count: statusBreakdown.paid,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Text('$label ($count)', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _FinancialSection extends StatelessWidget {
  final Financial financial;

  const _FinancialSection({required this.financial});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Financial', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              StatCard(
                title: 'Total Revenue',
                value: currencyFormat.format(financial.totalRevenue),
                icon: Icons.attach_money,
                iconColor: AppColors.success,
              ),
              StatCard(
                title: 'Pending',
                value: currencyFormat.format(financial.pendingPayments),
                icon: Icons.pending,
                iconColor: AppColors.warning,
              ),
              StatCard(
                title: 'Paid This Month',
                value: currencyFormat.format(financial.paidThisMonth),
                icon: Icons.check_circle,
                iconColor: AppColors.paidText,
              ),
              StatCard(
                title: 'Avg Job Value',
                value: currencyFormat.format(financial.averageJobValue),
                icon: Icons.analytics,
                iconColor: AppColors.brand500,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopTechniciansSection extends StatelessWidget {
  final List<TopTechnician> technicians;

  const _TopTechniciansSection({required this.technicians});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Top Technicians', style: theme.textTheme.titleMedium),
              TextButton(
                onPressed: () => context.go(AppRoutes.technicians),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...technicians
              .take(3)
              .map(
                (tech) => AppCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.brand500.withValues(alpha: 0.15)
                              : AppColors.brand50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            tech.name.isNotEmpty
                                ? tech.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: AppColors.brand500,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tech.name, style: theme.textTheme.titleSmall),
                            const SizedBox(height: 2),
                            Text(
                              tech.trade,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tech.rating.toStringAsFixed(1),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${tech.jobsCompleted} jobs',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
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
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  final List<RecentActivity> activities;

  const _RecentActivitySection({required this.activities});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activity', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          AppCard(
            padding: EdgeInsets.zero,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.take(5).length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.slate800 : AppColors.slate100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getActivityIcon(activity.type),
                      color: isDark ? AppColors.slate400 : AppColors.slate500,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    activity.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    _formatTime(activity.timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'work_order':
        return Icons.assignment;
      case 'technician':
        return Icons.engineering;
      case 'cost':
        return Icons.attach_money;
      case 'proposal':
        return Icons.description;
      default:
        return Icons.info_outline;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }
}
