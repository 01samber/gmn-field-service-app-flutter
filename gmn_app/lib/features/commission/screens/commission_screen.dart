import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/loading_spinner.dart';
import '../../../core/widgets/error_message.dart';
import '../../../core/utils/formatters.dart';
import '../../work_orders/providers/work_orders_provider.dart';
import '../../work_orders/data/models/work_order.dart';

// Commission tiers
const List<Map<String, dynamic>> _commissionTiers = [
  {'min': 0, 'max': 4, 'rate': 0.0},
  {'min': 5, 'max': 9, 'rate': 0.02},
  {'min': 10, 'max': 14, 'rate': 0.04},
  {'min': 15, 'max': 19, 'rate': 0.06},
  {'min': 20, 'max': double.infinity, 'rate': 0.08},
];

class CommissionScreen extends ConsumerStatefulWidget {
  const CommissionScreen({super.key});

  @override
  ConsumerState<CommissionScreen> createState() => _CommissionScreenState();
}

class _CommissionScreenState extends ConsumerState<CommissionScreen> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final workOrdersAsync = ref.watch(workOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Commission Calculator')),
      body: workOrdersAsync.when(
        data: (response) {
          final workOrders = response.data;
          final monthlyWOs = _filterByMonth(workOrders, _selectedMonth);
          final qualifiedWOs = _getQualifiedWorkOrders(monthlyWOs);
          final commissionData = _calculateCommission(qualifiedWOs);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month selector
                CustomCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() {
                            _selectedMonth = DateTime(
                              _selectedMonth.year,
                              _selectedMonth.month - 1,
                            );
                          });
                        },
                      ),
                      Text(
                        Formatters.monthYear(_selectedMonth),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _selectedMonth.isBefore(DateTime.now())
                            ? () {
                                setState(() {
                                  _selectedMonth = DateTime(
                                    _selectedMonth.year,
                                    _selectedMonth.month + 1,
                                  );
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Summary
                CustomCard(
                  gradient: AppColors.primaryGradient,
                  showBorder: false,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Commission',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                Formatters.currency(
                                  commissionData['commission'] as double,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(51),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${((commissionData['rate'] as double) * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryStat(
                            'Qualified WOs',
                            (commissionData['qualifiedCount'] as double)
                                .toStringAsFixed(1),
                          ),
                          _buildSummaryStat(
                            'Total Revenue',
                            Formatters.compactCurrency(
                              commissionData['totalRevenue'] as double,
                            ),
                          ),
                          _buildSummaryStat(
                            'Paid Jobs',
                            monthlyWOs
                                .where((wo) => wo.status == 'paid')
                                .length
                                .toString(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Commission tiers
                Text(
                  'Commission Tiers',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                CustomCard(
                  child: Column(
                    children: _commissionTiers.map((tier) {
                      final isActive =
                          (commissionData['qualifiedCount'] as double) >=
                              tier['min'] &&
                          (commissionData['qualifiedCount'] as double) <=
                              (tier['max'] == double.infinity
                                  ? 999
                                  : tier['max']);
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary.withAlpha(26)
                              : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            if (isActive)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: 20,
                              )
                            else
                              const SizedBox(width: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                tier['max'] == double.infinity
                                    ? '${tier['min']}+ qualified WOs'
                                    : '${tier['min']}-${tier['max']} qualified WOs',
                                style: TextStyle(
                                  fontWeight: isActive ? FontWeight.w600 : null,
                                  color: isActive ? AppColors.primary : null,
                                ),
                              ),
                            ),
                            Text(
                              '${((tier['rate'] as double) * 100).toInt()}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Qualification rules
                Text(
                  'Qualification Rules',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRule('Only PAID jobs count toward commission'),
                      _buildRule(
                        'Profit ratio must be ≥75% (unless Team Lead exception)',
                      ),
                      _buildRule('Incurred or NTE ≤ \$225 = 0.5 count'),
                      _buildRule('Reassigned jobs = ×2 count'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Work orders breakdown
                Text(
                  'Work Orders Breakdown',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (monthlyWOs.isEmpty)
                  const CustomCard(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('No work orders for this month'),
                      ),
                    ),
                  )
                else
                  ...monthlyWOs.map((wo) => _buildWorkOrderCard(context, wo)),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
        loading: () => PageLoader(),
        error: (error, stack) => ErrorMessage(
          message: error.toString(),
          onRetry: () => ref.invalidate(workOrdersProvider),
        ),
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildRule(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkOrderCard(BuildContext context, WorkOrder wo) {
    final isPaid = wo.status == 'paid';
    final count = _getWorkOrderCount(wo);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CustomCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isPaid
                    ? AppColors.success.withAlpha(26)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isPaid ? Icons.check_circle : Icons.pending,
                color: isPaid ? AppColors.success : AppColors.textTertiary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wo.woNumber,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    wo.client,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatters.formatStatus(wo.status),
                  style: TextStyle(
                    fontSize: 12,
                    color: isPaid ? AppColors.success : AppColors.textSecondary,
                    fontWeight: isPaid ? FontWeight.w600 : null,
                  ),
                ),
                if (isPaid)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(26),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '×${count.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<WorkOrder> _filterByMonth(List<WorkOrder> workOrders, DateTime month) {
    return workOrders.where((wo) {
      return wo.createdAt.year == month.year &&
          wo.createdAt.month == month.month;
    }).toList();
  }

  List<WorkOrder> _getQualifiedWorkOrders(List<WorkOrder> workOrders) {
    return workOrders.where((wo) => wo.status == 'paid').toList();
  }

  double _getWorkOrderCount(WorkOrder wo) {
    // Basic count logic
    double count = 1.0;

    // NTE <= $225 = 0.5 count
    if (wo.nte <= 225) {
      count = 0.5;
    }

    return count;
  }

  Map<String, dynamic> _calculateCommission(List<WorkOrder> qualifiedWOs) {
    double qualifiedCount = 0;
    double totalRevenue = 0;

    for (final wo in qualifiedWOs) {
      qualifiedCount += _getWorkOrderCount(wo);
      totalRevenue += wo.nte;
    }

    // Find applicable rate
    double rate = 0;
    for (final tier in _commissionTiers) {
      if (qualifiedCount >= tier['min'] &&
          qualifiedCount <=
              (tier['max'] == double.infinity ? 999 : tier['max'])) {
        rate = tier['rate'];
        break;
      }
    }

    final commission = totalRevenue * rate;

    return {
      'qualifiedCount': qualifiedCount,
      'totalRevenue': totalRevenue,
      'rate': rate,
      'commission': commission,
    };
  }
}
