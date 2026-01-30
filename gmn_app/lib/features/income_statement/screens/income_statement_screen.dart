import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/loading_spinner.dart';
import '../../../core/widgets/error_message.dart';
import '../../../core/utils/formatters.dart';
import '../../work_orders/providers/work_orders_provider.dart';
import '../../work_orders/data/models/work_order.dart';
import '../../costs/providers/costs_provider.dart';
import '../../costs/data/models/cost.dart';
import '../../proposals/providers/proposals_provider.dart';
import '../../proposals/data/models/proposal.dart';

class IncomeStatementScreen extends ConsumerWidget {
  const IncomeStatementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workOrdersAsync = ref.watch(workOrdersProvider);
    final costsAsync = ref.watch(costsProvider);
    final proposalsAsync = ref.watch(proposalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Income Statement')),
      body: workOrdersAsync.when(
        data: (workOrdersResponse) {
          final List<WorkOrder> workOrders = workOrdersResponse.data;
          return costsAsync.when(
            data: (List<Cost> costs) {
              return proposalsAsync.when(
                data: (List<Proposal> proposals) {
                  // Calculate metrics
                  final totalRevenue = proposals.fold<double>(
                    0,
                    (sum, p) => sum + p.total,
                  );
                  final totalCosts = costs.fold<double>(
                    0,
                    (sum, c) => sum + c.amount,
                  );
                  final paidCosts = costs
                      .where((c) => c.status == 'paid')
                      .fold<double>(0, (sum, c) => sum + c.amount);
                  final netIncome = totalRevenue - paidCosts;
                  final profitMargin = totalRevenue > 0
                      ? (netIncome / totalRevenue * 100)
                      : 0.0;

                  // Revenue by trade
                  final revenueByTrade = <String, double>{};
                  for (final wo in workOrders) {
                    revenueByTrade[wo.trade] =
                        (revenueByTrade[wo.trade] ?? 0) + (wo.nte);
                  }

                  // Monthly data (last 6 months)
                  final monthlyData = _calculateMonthlyData(workOrders, costs);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // KPI Cards
                        Row(
                          children: [
                            Expanded(
                              child: _KpiCard(
                                title: 'Total Revenue',
                                value: Formatters.compactCurrency(totalRevenue),
                                icon: Icons.trending_up,
                                color: AppColors.emerald,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _KpiCard(
                                title: 'Total Costs',
                                value: Formatters.compactCurrency(totalCosts),
                                icon: Icons.trending_down,
                                color: AppColors.rose,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _KpiCard(
                                title: 'Net Income',
                                value: Formatters.compactCurrency(netIncome),
                                icon: Icons.account_balance,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _KpiCard(
                                title: 'Profit Margin',
                                value: '${profitMargin.toStringAsFixed(1)}%',
                                icon: Icons.pie_chart,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Revenue vs Costs Chart
                        Text(
                          'Revenue vs Costs (6 Months)',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        CustomCard(
                          child: SizedBox(
                            height: 220,
                            child: _RevenueVsCostsChart(data: monthlyData),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Revenue by Trade
                        Text(
                          'Revenue by Trade',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        CustomCard(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 200,
                                child: revenueByTrade.isNotEmpty
                                    ? _RevenueByTradeChart(data: revenueByTrade)
                                    : const Center(
                                        child: Text('No data available'),
                                      ),
                              ),
                              const SizedBox(height: 16),
                              ...revenueByTrade.entries.map((entry) {
                                final percent = totalRevenue > 0
                                    ? (entry.value / totalRevenue * 100)
                                    : 0.0;
                                return _buildTradeRow(
                                  context,
                                  entry.key,
                                  entry.value,
                                  percent,
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Performance Summary
                        Text(
                          'Performance Summary',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        CustomCard(
                          child: Column(
                            children: [
                              _buildSummaryRow(
                                context,
                                'Total Work Orders',
                                workOrders.length.toString(),
                              ),
                              _buildSummaryRow(
                                context,
                                'Paid Work Orders',
                                workOrders
                                    .where((wo) => wo.status == 'paid')
                                    .length
                                    .toString(),
                              ),
                              _buildSummaryRow(
                                context,
                                'Total Proposals',
                                proposals.length.toString(),
                              ),
                              _buildSummaryRow(
                                context,
                                'Approved Proposals',
                                proposals
                                    .where((p) => p.status == 'approved')
                                    .length
                                    .toString(),
                              ),
                              _buildSummaryRow(
                                context,
                                'Pending Costs',
                                costs
                                    .where((c) => c.status == 'requested')
                                    .length
                                    .toString(),
                              ),
                              _buildSummaryRow(
                                context,
                                'Avg. Work Order Value',
                                Formatters.currency(
                                  workOrders.isNotEmpty
                                      ? workOrders.fold<double>(
                                              0,
                                              (sum, wo) => sum + wo.nte,
                                            ) /
                                            workOrders.length
                                      : 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Goals Progress
                        Text(
                          'Monthly Goals',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _GoalCard(
                          title: 'Revenue Goal',
                          current: totalRevenue,
                          goal: 50000,
                          color: AppColors.emerald,
                        ),
                        const SizedBox(height: 8),
                        _GoalCard(
                          title: 'Work Orders Goal',
                          current: workOrders.length.toDouble(),
                          goal: 30,
                          color: AppColors.primary,
                          isCount: true,
                        ),
                        const SizedBox(height: 8),
                        _GoalCard(
                          title: 'Profit Margin Goal',
                          current: profitMargin,
                          goal: 35,
                          color: AppColors.secondary,
                          isPercent: true,
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  );
                },
                loading: () => PageLoader(),
                error: (error, _) => ErrorMessage(message: error.toString()),
              );
            },
            loading: () => PageLoader(),
            error: (error, _) => ErrorMessage(message: error.toString()),
          );
        },
        loading: () => PageLoader(),
        error: (error, _) => ErrorMessage(
          message: error.toString(),
          onRetry: () => ref.invalidate(workOrdersProvider),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _calculateMonthlyData(
    List<WorkOrder> workOrders,
    List<Cost> costs,
  ) {
    final now = DateTime.now();
    final data = <Map<String, dynamic>>[];

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i);
      final monthWOs = workOrders.where(
        (wo) =>
            wo.createdAt.year == month.year &&
            wo.createdAt.month == month.month,
      );
      final monthCosts = costs.where(
        (c) =>
            c.createdAt.year == month.year && c.createdAt.month == month.month,
      );

      final revenue = monthWOs.fold<double>(
        0,
        (sum, wo) => sum + wo.nte,
      );
      final cost = monthCosts.fold<double>(0, (sum, c) => sum + c.amount);

      data.add({'month': month, 'revenue': revenue, 'cost': cost});
    }

    return data;
  }

  Widget _buildTradeRow(
    BuildContext context,
    String trade,
    double value,
    double percent,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getTradeColor(trade),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(trade)),
          Text(
            Formatters.currency(value),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Text(
            '${percent.toStringAsFixed(1)}%',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Color _getTradeColor(String trade) {
    final colors = {
      'Plumbing': AppColors.primary,
      'Electrical': AppColors.amber,
      'HVAC': AppColors.emerald,
      'Carpentry': AppColors.secondary,
      'Roofing': AppColors.rose,
      'Painting': AppColors.info,
      'General': AppColors.textSecondary,
    };
    return colors[trade] ?? AppColors.textSecondary;
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String title;
  final double current;
  final double goal;
  final Color color;
  final bool isPercent;
  final bool isCount;

  const _GoalCard({
    required this.title,
    required this.current,
    required this.goal,
    required this.color,
    this.isPercent = false,
    this.isCount = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current / goal).clamp(0.0, 1.0);
    final progressPercent = (progress * 100).toStringAsFixed(0);

    String formatValue(double value) {
      if (isPercent) return '${value.toStringAsFixed(1)}%';
      if (isCount) return value.toInt().toString();
      return Formatters.compactCurrency(value);
    }

    return CustomCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                '$progressPercent%',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withAlpha(26),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${formatValue(current)} / ${formatValue(goal)}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _RevenueVsCostsChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const _RevenueVsCostsChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxY(),
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= data.length) return const SizedBox();
                final month = data[value.toInt()]['month'] as DateTime;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _getMonthLabel(month),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  Formatters.compactCurrency(value),
                  style: const TextStyle(fontSize: 10),
                );
              },
              reservedSize: 50,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value['revenue'] ?? 0,
                color: AppColors.emerald,
                width: 12,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
              BarChartRodData(
                toY: entry.value['cost'] ?? 0,
                color: AppColors.rose,
                width: 12,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  double _getMaxY() {
    double max = 0;
    for (final item in data) {
      if ((item['revenue'] ?? 0) > max) max = item['revenue'];
      if ((item['cost'] ?? 0) > max) max = item['cost'];
    }
    return max * 1.2;
  }

  String _getMonthLabel(DateTime month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month.month - 1];
  }
}

class _RevenueByTradeChart extends StatelessWidget {
  final Map<String, double> data;

  const _RevenueByTradeChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold<double>(0, (sum, v) => sum + v);
    if (total == 0) return const Center(child: Text('No data'));

    final colors = {
      'Plumbing': AppColors.primary,
      'Electrical': AppColors.amber,
      'HVAC': AppColors.emerald,
      'Carpentry': AppColors.secondary,
      'Roofing': AppColors.rose,
      'Painting': AppColors.info,
      'General': AppColors.textSecondary,
    };

    return PieChart(
      PieChartData(
        sections: data.entries.map((entry) {
          final percent = entry.value / total * 100;
          return PieChartSectionData(
            value: entry.value,
            title: percent >= 5 ? '${percent.toStringAsFixed(0)}%' : '',
            color: colors[entry.key] ?? AppColors.textSecondary,
            radius: 60,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 30,
      ),
    );
  }
}
