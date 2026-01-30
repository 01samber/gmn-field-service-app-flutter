import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/work_orders_provider.dart';

class WorkOrderDetailScreen extends ConsumerWidget {
  final String workOrderId;

  const WorkOrderDetailScreen({super.key, required this.workOrderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workOrderAsync = ref.watch(workOrderProvider(workOrderId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Order Details'),
        actions: [
          workOrderAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (workOrder) => PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  context.push('/work-orders/$workOrderId/edit');
                } else if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Work Order'),
                      content: const Text(
                        'Are you sure you want to delete this work order?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    await ref
                        .read(workOrdersNotifierProvider.notifier)
                        .deleteWorkOrder(workOrderId);
                    if (context.mounted) {
                      context.pop();
                    }
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 12),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: AppColors.error),
                      const SizedBox(width: 12),
                      Text('Delete', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: workOrderAsync.when(
        loading: () => const LoadingSpinner(),
        error: (error, _) => ErrorMessage(
          message: error.toString(),
          onRetry: () => ref.invalidate(workOrderProvider(workOrderId)),
        ),
        data: (workOrder) {
          final currencyFormat = NumberFormat.currency(symbol: '\$');
          final dateFormat = DateFormat('MMM d, yyyy h:mm a');

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(workOrderProvider(workOrderId));
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.slate800
                                    : AppColors.slate100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                workOrder.woNumber,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            StatusBadge(status: workOrder.status),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          workOrder.client,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.build_outlined,
                              size: 16,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              workOrder.trade,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(width: 16),
                            PriorityBadge(priority: workOrder.priority),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Status Actions
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Update Status',
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: AppConstants.workOrderStatuses
                              .map(
                                (status) => _StatusButton(
                                  status: status,
                                  isSelected: workOrder.status == status,
                                  onTap: workOrder.status == status
                                      ? null
                                      : () async {
                                          await ref
                                              .read(
                                                workOrdersNotifierProvider
                                                    .notifier,
                                              )
                                              .updateStatus(
                                                workOrderId,
                                                status,
                                              );
                                        },
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Details
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Details', style: theme.textTheme.titleSmall),
                        const SizedBox(height: 16),
                        _DetailRow(
                          icon: Icons.attach_money,
                          label: 'NTE',
                          value: currencyFormat.format(workOrder.nte),
                          valueColor: AppColors.brand500,
                        ),
                        if (workOrder.fullAddress.isNotEmpty)
                          _DetailRow(
                            icon: Icons.location_on_outlined,
                            label: 'Address',
                            value: workOrder.fullAddress,
                          ),
                        if (workOrder.technician != null)
                          _DetailRow(
                            icon: Icons.person_outline,
                            label: 'Technician',
                            value: workOrder.technician!.name,
                          ),
                        if (workOrder.etaAt != null)
                          _DetailRow(
                            icon: Icons.schedule,
                            label: 'ETA',
                            value: dateFormat.format(workOrder.etaAt!),
                          ),
                        if (workOrder.completedAt != null)
                          _DetailRow(
                            icon: Icons.check_circle_outline,
                            label: 'Completed',
                            value: dateFormat.format(workOrder.completedAt!),
                          ),
                        _DetailRow(
                          icon: Icons.calendar_today,
                          label: 'Created',
                          value: dateFormat.format(workOrder.createdAt),
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  if (workOrder.description != null &&
                      workOrder.description!.isNotEmpty)
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            workOrder.description!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),

                  // Notes
                  if (workOrder.notes != null && workOrder.notes!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Notes', style: theme.textTheme.titleSmall),
                            const SizedBox(height: 12),
                            Text(
                              workOrder.notes!,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String status;
  final bool isSelected;
  final VoidCallback? onTap;

  const _StatusButton({
    required this.status,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getStatusColor(status);
    final bgColor = AppColors.getStatusBackground(
      status,
      isDark: Theme.of(context).brightness == Brightness.dark,
    );

    return Material(
      color: isSelected ? color : bgColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            _formatStatus(status),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : color,
            ),
          ),
        ),
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool showDivider;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}
