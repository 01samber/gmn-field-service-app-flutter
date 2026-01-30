import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading_spinner.dart';
import '../../../core/widgets/error_message.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/utils/formatters.dart';
import '../providers/proposals_provider.dart';

class ProposalDetailScreen extends ConsumerWidget {
  final String id;

  const ProposalDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proposalAsync = ref.watch(proposalProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proposal Details'),
        actions: [
          proposalAsync.whenOrNull(
            data: (proposal) => PopupMenuButton(
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
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share_outlined),
                      SizedBox(width: 12),
                      Text('Share'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: AppColors.error),
                      SizedBox(width: 12),
                      Text('Delete', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value == 'edit') {
                  context.go('/proposals/$id/edit');
                } else if (value == 'share') {
                  _shareProposal(context, proposal);
                } else if (value == 'delete') {
                  final confirmed = await ConfirmDialog.show(
                    context: context,
                    title: 'Delete Proposal',
                    message: 'Are you sure you want to delete this proposal?',
                    confirmLabel: 'Delete',
                    isDestructive: true,
                  );
                  if (confirmed == true) {
                    final success = await ref.read(proposalsNotifierProvider.notifier).delete(id);
                    if (success && context.mounted) {
                      context.go('/proposals');
                      showSnackBar(context, message: 'Proposal deleted');
                    }
                  }
                }
              },
            ),
          ) ?? const SizedBox(),
        ],
      ),
      body: proposalAsync.when(
        data: (proposal) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            proposal.proposalNumber,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          StatusBadge(status: proposal.status, type: StatusType.proposal),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Created ${Formatters.date(proposal.createdAt)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Related info
                if (proposal.workOrder != null || proposal.technician != null)
                  CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Related To',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        if (proposal.workOrder != null)
                          _buildInfoRow(
                            context,
                            Icons.work_outline,
                            '${proposal.workOrder!.woNumber} - ${proposal.workOrder!.client}',
                          ),
                        if (proposal.technician != null)
                          _buildInfoRow(
                            context,
                            Icons.person_outline,
                            '${proposal.technician!.name} (${proposal.technician!.trade})',
                          ),
                        if (proposal.helper != null)
                          _buildInfoRow(
                            context,
                            Icons.person_add_outlined,
                            'Helper: ${proposal.helper!.name}',
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Cost breakdown
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cost Breakdown',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _buildCostRow(context, 'Trip Fee', proposal.tripFee),
                      _buildCostRow(context, 'Assessment Fee', proposal.assessmentFee),
                      const Divider(height: 24),
                      _buildCostRow(
                        context,
                        'Tech Labor (${proposal.techHours}h × ${Formatters.currency(proposal.techRate)})',
                        proposal.techHours * proposal.techRate,
                      ),
                      if (proposal.helperHours > 0)
                        _buildCostRow(
                          context,
                          'Helper Labor (${proposal.helperHours}h × ${Formatters.currency(proposal.helperRate)})',
                          proposal.helperHours * proposal.helperRate,
                        ),
                      const Divider(height: 24),
                      if (proposal.parts.isNotEmpty) ...[
                        Text(
                          'Parts & Materials',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        ...proposal.parts.map((part) => _buildCostRow(
                              context,
                              '${part.name} (${part.quantity}x)',
                              part.total,
                            )),
                        const Divider(height: 24),
                      ],
                      _buildCostRow(
                        context,
                        'Subtotal',
                        proposal.baseCost,
                        isBold: true,
                      ),
                      _buildCostRow(
                        context,
                        'Multiplier (${proposal.costMultiplier}x)',
                        proposal.subtotal - proposal.baseCost,
                        highlight: true,
                      ),
                      _buildCostRow(context, 'Subtotal (with multiplier)', proposal.subtotal),
                      _buildCostRow(context, 'Tax (${(proposal.taxRate * 100).toStringAsFixed(1)}%)', proposal.tax),
                      const Divider(height: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TOTAL',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              Formatters.currency(proposal.total),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
        loading: () => PageLoader(),
        error: (error, stack) => ErrorMessage(
          message: error.toString(),
          onRetry: () => ref.invalidate(proposalProvider(id)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/proposals/$id/edit'),
        icon: const Icon(Icons.edit),
        label: const Text('Edit'),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(
    BuildContext context,
    String label,
    double amount, {
    bool isBold = false,
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isBold ? FontWeight.w600 : null,
                  color: highlight ? AppColors.primary : null,
                ),
          ),
          Text(
            Formatters.currency(amount),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isBold ? FontWeight.w600 : null,
                  color: highlight ? AppColors.primary : null,
                ),
          ),
        ],
      ),
    );
  }

  void _shareProposal(BuildContext context, dynamic proposal) {
    final text = '''
Service Proposal ${proposal.proposalNumber}

${proposal.workOrder != null ? 'Client: ${proposal.workOrder!.client}\n' : ''}${proposal.workOrder != null ? 'Work Order: ${proposal.workOrder!.woNumber}\n' : ''}
Cost Breakdown:
- Trip Fee: ${Formatters.currency(proposal.tripFee)}
- Assessment: ${Formatters.currency(proposal.assessmentFee)}
- Labor: ${Formatters.currency(proposal.laborCost)}
- Parts: ${Formatters.currency(proposal.partsCost)}

Total: ${Formatters.currency(proposal.total)}
''';
    Share.share(text);
  }
}
