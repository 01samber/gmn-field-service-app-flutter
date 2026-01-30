import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../routing/app_router.dart';
import '../providers/work_orders_provider.dart';
import '../data/models/work_order.dart';

class WorkOrdersScreen extends ConsumerStatefulWidget {
  const WorkOrdersScreen({super.key});

  @override
  ConsumerState<WorkOrdersScreen> createState() => _WorkOrdersScreenState();
}

class _WorkOrdersScreenState extends ConsumerState<WorkOrdersScreen> {
  final _searchController = TextEditingController();
  String? _selectedStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(workOrdersFilterProvider.notifier).state = ref
        .read(workOrdersFilterProvider)
        .copyWith(search: value);
  }

  void _onStatusChanged(String? status) {
    setState(() => _selectedStatus = status);
    ref.read(workOrdersFilterProvider.notifier).state = ref
        .read(workOrdersFilterProvider)
        .copyWith(status: status, clearStatus: status == null);
  }

  @override
  Widget build(BuildContext context) {
    final workOrdersAsync = ref.watch(workOrdersProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Work Orders',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => ref.invalidate(workOrdersProvider),
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            ),

            // Search and Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Search
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search work orders...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                    ),
                    onChanged: _onSearchChanged,
                  ),
                  const SizedBox(height: 12),

                  // Status Filter
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'All',
                          isSelected: _selectedStatus == null,
                          onSelected: () => _onStatusChanged(null),
                        ),
                        ...AppConstants.workOrderStatuses.map(
                          (status) => _FilterChip(
                            label: _formatStatus(status),
                            isSelected: _selectedStatus == status,
                            onSelected: () => _onStatusChanged(status),
                            color: AppColors.getStatusColor(status),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Work Orders List
            Expanded(
              child: workOrdersAsync.when(
                loading: () => const ShimmerList(),
                error: (error, _) => ErrorMessage(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(workOrdersProvider),
                ),
                data: (response) {
                  if (response.data.isEmpty) {
                    return EmptyState(
                      icon: Icons.assignment_outlined,
                      title: 'No Work Orders',
                      message:
                          _selectedStatus != null ||
                              _searchController.text.isNotEmpty
                          ? 'Try adjusting your filters'
                          : 'Create your first work order to get started',
                      actionLabel: 'Create Work Order',
                      onAction: () => context.push(AppRoutes.workOrderCreate),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(workOrdersProvider);
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: response.data.length,
                      itemBuilder: (context, index) {
                        final workOrder = response.data[index];
                        return _WorkOrderCard(
                          workOrder: workOrder,
                          onTap: () =>
                              context.push('/work-orders/${workOrder.id}'),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.workOrderCreate),
        icon: const Icon(Icons.add),
        label: const Text('New'),
      ),
    );
  }

  String _formatStatus(String status) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        selectedColor: (color ?? AppColors.brand500).withValues(
          alpha: isDark ? 0.3 : 0.15,
        ),
        checkmarkColor: color ?? AppColors.brand500,
        labelStyle: TextStyle(
          color: isSelected
              ? (color ?? AppColors.brand500)
              : (isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _WorkOrderCard extends StatelessWidget {
  final WorkOrder workOrder;
  final VoidCallback onTap;

  const _WorkOrderCard({required this.workOrder, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with WO number and status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.slate800 : AppColors.slate100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  workOrder.woNumber,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              StatusBadge(status: workOrder.status, size: BadgeSize.small),
            ],
          ),
          const SizedBox(height: 12),

          // Client name
          Text(
            workOrder.client,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Trade and location
          Row(
            children: [
              Icon(
                Icons.build_outlined,
                size: 14,
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
              const SizedBox(width: 4),
              Text(
                workOrder.trade,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              if (workOrder.city != null || workOrder.state != null) ...[
                const SizedBox(width: 12),
                Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    [
                      workOrder.city,
                      workOrder.state,
                    ].where((e) => e != null && e.isNotEmpty).join(', '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // Footer with NTE, technician, and priority
          Row(
            children: [
              if (workOrder.nte > 0) ...[
                Text(
                  'NTE: ${currencyFormat.format(workOrder.nte)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.brand500,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              if (workOrder.technician != null) ...[
                Icon(
                  Icons.person_outline,
                  size: 14,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                ),
                const SizedBox(width: 4),
                Text(
                  workOrder.technician!.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
              const Spacer(),
              PriorityBadge(
                priority: workOrder.priority,
                size: BadgeSize.small,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
