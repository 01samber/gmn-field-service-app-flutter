import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading_spinner.dart';
import '../../../core/widgets/error_message.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/costs_provider.dart';
import '../data/models/cost.dart';

class CostsScreen extends ConsumerStatefulWidget {
  const CostsScreen({super.key});

  @override
  ConsumerState<CostsScreen> createState() => _CostsScreenState();
}

class _CostsScreenState extends ConsumerState<CostsScreen> {
  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final costsAsync = ref.watch(costsProvider);
    final summary = ref.watch(costSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Costs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(costsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Summary cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Requested',
                        amount: summary.requested,
                        color: AppColors.amber,
                        icon: Icons.pending_actions,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Approved',
                        amount: summary.approved,
                        color: AppColors.info,
                        icon: Icons.thumb_up_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Paid',
                        amount: summary.paid,
                        color: AppColors.success,
                        icon: Icons.paid_outlined,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Filter chip
            if (_selectedStatus != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Chip(
                        label: Text(Formatters.formatStatus(_selectedStatus!)),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() => _selectedStatus = null);
                          ref.read(costsFilterProvider.notifier).state =
                              CostsFilter();
                        },
                      ),
                    ],
                  ),
                ),
              ),

            // Costs list
            costsAsync.when(
              data: (costs) {
                if (costs.isEmpty) {
                  return SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.attach_money,
                      title: 'No Cost Requests',
                      message: 'Create your first cost request',
                      actionLabel: 'Request Payment',
                      onAction: () => context.go('/costs/new'),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _CostCard(
                        cost: costs[index],
                        onApprove: () => _approveCost(costs[index]),
                        onMarkPaid: () => _markAsPaid(costs[index]),
                        onDelete: () => _deleteCost(costs[index]),
                      ),
                      childCount: costs.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(child: PageLoader()),
              error: (error, stack) => SliverFillRemaining(
                child: ErrorMessage(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(costsProvider),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/costs/new'),
        icon: const Icon(Icons.add),
        label: const Text('Request'),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by Status',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('All'),
              selected: _selectedStatus == null,
              onTap: () {
                setState(() => _selectedStatus = null);
                ref.read(costsFilterProvider.notifier).state = CostsFilter();
                Navigator.pop(context);
              },
            ),
            ...AppConstants.costStatuses.map((status) {
              return ListTile(
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.getCostStatusColor(status),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                title: Text(Formatters.formatStatus(status)),
                selected: _selectedStatus == status,
                onTap: () {
                  setState(() => _selectedStatus = status);
                  ref.read(costsFilterProvider.notifier).state = CostsFilter(
                    status: status,
                  );
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _approveCost(Cost cost) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Approve Cost',
      message: 'Approve ${Formatters.currency(cost.amount)} payment request?',
      confirmLabel: 'Approve',
    );
    if (confirmed == true) {
      final success = await ref
          .read(costsNotifierProvider.notifier)
          .approve(cost.id);
      if (success && mounted) {
        showSnackBar(context, message: 'Cost approved');
      }
    }
  }

  Future<void> _markAsPaid(Cost cost) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Mark as Paid',
      message: 'Mark ${Formatters.currency(cost.amount)} as paid?',
      confirmLabel: 'Mark Paid',
    );
    if (confirmed == true) {
      final success = await ref
          .read(costsNotifierProvider.notifier)
          .markAsPaid(cost.id);
      if (success && mounted) {
        showSnackBar(context, message: 'Cost marked as paid');
      }
    }
  }

  Future<void> _deleteCost(Cost cost) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Cost',
      message: 'Delete this cost request?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirmed == true) {
      final success = await ref
          .read(costsNotifierProvider.notifier)
          .delete(cost.id);
      if (success && mounted) {
        showSnackBar(context, message: 'Cost deleted');
      }
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            Formatters.compactCurrency(amount),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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

class _CostCard extends StatelessWidget {
  final Cost cost;
  final VoidCallback onApprove;
  final VoidCallback onMarkPaid;
  final VoidCallback onDelete;

  const _CostCard({
    required this.cost,
    required this.onApprove,
    required this.onMarkPaid,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Formatters.currency(cost.amount),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                StatusBadge(status: cost.status, type: StatusType.cost),
              ],
            ),
            const SizedBox(height: 12),
            if (cost.workOrder != null)
              _buildInfoRow(
                context,
                Icons.work_outline,
                '${cost.workOrder!.woNumber} - ${cost.workOrder!.client}',
              ),
            if (cost.technician != null)
              _buildInfoRow(
                context,
                Icons.person_outline,
                '${cost.technician!.name} (${cost.technician!.trade})',
              ),
            if (cost.note != null && cost.note!.isNotEmpty)
              _buildInfoRow(context, Icons.note_outlined, cost.note!),
            const SizedBox(height: 8),
            _buildTimeline(context),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (cost.isRequested) ...[
                  TextButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.thumb_up_outlined, size: 18),
                    label: const Text('Approve'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.info,
                    ),
                  ),
                ],
                if (cost.isApproved) ...[
                  TextButton.icon(
                    onPressed: onMarkPaid,
                    icon: const Icon(Icons.paid_outlined, size: 18),
                    label: const Text('Mark Paid'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.success,
                    ),
                  ),
                ],
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: AppColors.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    return Row(
      children: [
        _buildTimelineItem(
          context,
          'Requested',
          cost.requestedAt,
          isCompleted: true,
          color: AppColors.amber,
        ),
        Expanded(
          child: Container(
            height: 2,
            color: cost.approvedAt != null ? AppColors.info : AppColors.border,
          ),
        ),
        _buildTimelineItem(
          context,
          'Approved',
          cost.approvedAt,
          isCompleted: cost.approvedAt != null,
          color: AppColors.info,
        ),
        Expanded(
          child: Container(
            height: 2,
            color: cost.paidAt != null ? AppColors.success : AppColors.border,
          ),
        ),
        _buildTimelineItem(
          context,
          'Paid',
          cost.paidAt,
          isCompleted: cost.paidAt != null,
          color: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    String label,
    DateTime? date, {
    required bool isCompleted,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isCompleted ? color : AppColors.border,
            shape: BoxShape.circle,
          ),
          child: isCompleted
              ? const Icon(Icons.check, size: 8, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: isCompleted ? color : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
