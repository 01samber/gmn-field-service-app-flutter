import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../providers/technicians_provider.dart';

class TechnicianDetailScreen extends ConsumerWidget {
  final String technicianId;

  const TechnicianDetailScreen({super.key, required this.technicianId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final technicianAsync = ref.watch(technicianProvider(technicianId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Technician Details'),
        actions: [
          technicianAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (technician) => PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  context.push('/technicians/$technicianId/edit');
                } else if (value == 'blacklist') {
                  _showBlacklistDialog(context, ref, technician.isBlacklisted);
                } else if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Technician'),
                      content: const Text(
                        'Are you sure you want to delete this technician?',
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
                        .read(techniciansNotifierProvider.notifier)
                        .deleteTechnician(technicianId);
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
                  value: 'blacklist',
                  child: Row(
                    children: [
                      Icon(
                        technician.isBlacklisted
                            ? Icons.check_circle_outline
                            : Icons.block,
                        color: technician.isBlacklisted
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        technician.isBlacklisted
                            ? 'Remove from Blacklist'
                            : 'Add to Blacklist',
                        style: TextStyle(
                          color: technician.isBlacklisted
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
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
      body: technicianAsync.when(
        loading: () => const LoadingSpinner(),
        error: (error, _) => ErrorMessage(
          message: error.toString(),
          onRetry: () => ref.invalidate(technicianProvider(technicianId)),
        ),
        data: (technician) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(technicianProvider(technicianId));
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  AppCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: technician.isBlacklisted
                                    ? AppColors.error.withValues(
                                        alpha: isDark ? 0.2 : 0.1,
                                      )
                                    : (isDark
                                          ? AppColors.brand500.withValues(
                                              alpha: 0.15,
                                            )
                                          : AppColors.brand50),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Center(
                                child: Text(
                                  technician.initials,
                                  style: TextStyle(
                                    color: technician.isBlacklisted
                                        ? AppColors.error
                                        : AppColors.brand500,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    technician.name,
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? AppColors.slate800
                                              : AppColors.slate100,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          technician.trade,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                      if (technician.isBlacklisted) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.error.withValues(
                                              alpha: isDark ? 0.2 : 0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.block,
                                                size: 14,
                                                color: AppColors.error,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Blacklisted',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.error,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Stats Row
                        Row(
                          children: [
                            Expanded(
                              child: _StatItem(
                                icon: Icons.star,
                                iconColor: AppColors.warning,
                                label: 'Rating',
                                value: technician.rating.toStringAsFixed(1),
                              ),
                            ),
                            Expanded(
                              child: _StatItem(
                                icon: Icons.assignment,
                                iconColor: AppColors.brand500,
                                label: 'Jobs',
                                value: '${technician.jobsDone}',
                              ),
                            ),
                            Expanded(
                              child: _StatItem(
                                icon: Icons.attach_money,
                                iconColor: AppColors.success,
                                label: 'Earned',
                                value: currencyFormat.format(
                                  technician.gmnMoneyMade,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Contact Actions
                  Row(
                    children: [
                      if (technician.phone != null &&
                          technician.phone!.isNotEmpty)
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.phone,
                            label: 'Call',
                            onTap: () => _launchPhone(technician.phone!),
                          ),
                        ),
                      if (technician.email != null &&
                          technician.email!.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.email,
                            label: 'Email',
                            onTap: () => _launchEmail(technician.email!),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Contact Details
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact Information',
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 16),
                        if (technician.phone != null &&
                            technician.phone!.isNotEmpty)
                          _DetailRow(
                            icon: Icons.phone_outlined,
                            label: 'Phone',
                            value: technician.phone!,
                          ),
                        if (technician.email != null &&
                            technician.email!.isNotEmpty)
                          _DetailRow(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: technician.email!,
                          ),
                        if (technician.fullAddress.isNotEmpty)
                          _DetailRow(
                            icon: Icons.location_on_outlined,
                            label: 'Address',
                            value: technician.fullAddress,
                            showDivider: false,
                          ),
                        if (technician.phone == null &&
                            technician.email == null &&
                            technician.fullAddress.isEmpty)
                          Text(
                            'No contact information available',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Rate Info
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Billing', style: theme.textTheme.titleSmall),
                        const SizedBox(height: 16),
                        _DetailRow(
                          icon: Icons.attach_money,
                          label: 'Hourly Rate',
                          value:
                              '${currencyFormat.format(technician.hourlyRate)}/hr',
                          valueColor: AppColors.brand500,
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),

                  // Notes
                  if (technician.notes != null &&
                      technician.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Notes', style: theme.textTheme.titleSmall),
                          const SizedBox(height: 12),
                          Text(
                            technician.notes!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Blacklist Reason
                  if (technician.isBlacklisted &&
                      technician.blacklistReason != null &&
                      technician.blacklistReason!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(
                          alpha: isDark ? 0.15 : 0.1,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Blacklist Reason',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            technician.blacklistReason!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showBlacklistDialog(
    BuildContext context,
    WidgetRef ref,
    bool isBlacklisted,
  ) {
    if (isBlacklisted) {
      // Remove from blacklist
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Remove from Blacklist'),
          content: const Text(
            'Are you sure you want to remove this technician from the blacklist?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await ref
                    .read(techniciansNotifierProvider.notifier)
                    .toggleBlacklist(technicianId, isBlacklisted: false);
              },
              child: const Text('Remove'),
            ),
          ],
        ),
      );
    } else {
      // Add to blacklist with reason
      final reasonController = TextEditingController();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add to Blacklist'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Are you sure you want to blacklist this technician?'),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason (optional)',
                  hintText: 'Enter reason for blacklisting',
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await ref
                    .read(techniciansNotifierProvider.notifier)
                    .toggleBlacklist(
                      technicianId,
                      isBlacklisted: true,
                      reason: reasonController.text.trim().isNotEmpty
                          ? reasonController.text.trim()
                          : null,
                    );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Blacklist'),
            ),
          ],
        ),
      );
    }
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.brand500),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: AppColors.brand500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(width: 16),
              Expanded(
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
