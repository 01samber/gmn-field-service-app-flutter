import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading_spinner.dart';
import '../../../core/widgets/error_message.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/utils/formatters.dart';
import '../providers/proposals_provider.dart';
import '../data/models/proposal.dart';

class ProposalsScreen extends ConsumerWidget {
  const ProposalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proposalsAsync = ref.watch(proposalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Proposals')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(proposalsProvider);
        },
        child: proposalsAsync.when(
          data: (proposals) {
            if (proposals.isEmpty) {
              return EmptyState(
                icon: Icons.description_outlined,
                title: 'No Proposals',
                message: 'Create your first service proposal',
                actionLabel: 'Create Proposal',
                onAction: () => context.go('/proposals/new'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: proposals.length,
              itemBuilder: (context, index) {
                return _ProposalCard(
                  proposal: proposals[index],
                  onTap: () => context.go('/proposals/${proposals[index].id}'),
                );
              },
            );
          },
          loading: () => PageLoader(),
          error: (error, stack) => ErrorMessage(
            message: error.toString(),
            onRetry: () => ref.invalidate(proposalsProvider),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/proposals/new'),
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
    );
  }
}

class _ProposalCard extends StatelessWidget {
  final Proposal proposal;
  final VoidCallback onTap;

  const _ProposalCard({required this.proposal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  proposal.proposalNumber,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                StatusBadge(status: proposal.status, type: StatusType.proposal),
              ],
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
                proposal.technician!.name,
              ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(13),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        Formatters.currency(proposal.total),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Parts: ${proposal.parts.length}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Multiplier: ${proposal.costMultiplier}x',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Created ${Formatters.relativeTime(proposal.createdAt)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
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
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
