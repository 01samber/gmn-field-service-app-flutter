import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../routing/app_router.dart';
import '../providers/technicians_provider.dart';
import '../data/models/technician.dart';

class TechniciansScreen extends ConsumerStatefulWidget {
  const TechniciansScreen({super.key});

  @override
  ConsumerState<TechniciansScreen> createState() => _TechniciansScreenState();
}

class _TechniciansScreenState extends ConsumerState<TechniciansScreen> {
  final _searchController = TextEditingController();
  String? _selectedTrade;
  bool _showBlacklisted = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(techniciansFilterProvider.notifier).state = ref
        .read(techniciansFilterProvider)
        .copyWith(search: value);
  }

  void _onTradeChanged(String? trade) {
    setState(() => _selectedTrade = trade);
    ref.read(techniciansFilterProvider.notifier).state = ref
        .read(techniciansFilterProvider)
        .copyWith(trade: trade, clearTrade: trade == null);
  }

  void _toggleShowBlacklisted() {
    setState(() => _showBlacklisted = !_showBlacklisted);
    ref.read(techniciansFilterProvider.notifier).state = ref
        .read(techniciansFilterProvider)
        .copyWith(includeBlacklisted: _showBlacklisted);
  }

  @override
  Widget build(BuildContext context) {
    final techniciansAsync = ref.watch(techniciansProvider);
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
                      'Technicians',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleShowBlacklisted,
                    icon: Icon(
                      _showBlacklisted
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    tooltip: _showBlacklisted
                        ? 'Hide blacklisted'
                        : 'Show blacklisted',
                  ),
                  IconButton(
                    onPressed: () => ref.invalidate(techniciansProvider),
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
                      hintText: 'Search technicians...',
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

                  // Trade Filter
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'All Trades',
                          isSelected: _selectedTrade == null,
                          onSelected: () => _onTradeChanged(null),
                        ),
                        ...AppConstants.trades.map(
                          (trade) => _FilterChip(
                            label: trade,
                            isSelected: _selectedTrade == trade,
                            onSelected: () => _onTradeChanged(trade),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Technicians List
            Expanded(
              child: techniciansAsync.when(
                loading: () => const ShimmerList(),
                error: (error, _) => ErrorMessage(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(techniciansProvider),
                ),
                data: (response) {
                  if (response.data.isEmpty) {
                    return EmptyState(
                      icon: Icons.engineering_outlined,
                      title: 'No Technicians',
                      message:
                          _selectedTrade != null ||
                              _searchController.text.isNotEmpty
                          ? 'Try adjusting your filters'
                          : 'Add your first technician to get started',
                      actionLabel: 'Add Technician',
                      onAction: () => context.push(AppRoutes.technicianCreate),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(techniciansProvider);
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: response.data.length,
                      itemBuilder: (context, index) {
                        final technician = response.data[index];
                        return _TechnicianCard(
                          technician: technician,
                          onTap: () =>
                              context.push('/technicians/${technician.id}'),
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
        onPressed: () => context.push(AppRoutes.technicianCreate),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
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
        selectedColor: AppColors.brand500.withValues(
          alpha: isDark ? 0.3 : 0.15,
        ),
        checkmarkColor: AppColors.brand500,
        labelStyle: TextStyle(
          color: isSelected
              ? AppColors.brand500
              : (isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _TechnicianCard extends StatelessWidget {
  final Technician technician;
  final VoidCallback onTap;

  const _TechnicianCard({required this.technician, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      borderColor: technician.isBlacklisted
          ? AppColors.error.withValues(alpha: 0.5)
          : null,
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: technician.isBlacklisted
                  ? AppColors.error.withValues(alpha: isDark ? 0.2 : 0.1)
                  : (isDark
                        ? AppColors.brand500.withValues(alpha: 0.15)
                        : AppColors.brand50),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                technician.initials,
                style: TextStyle(
                  color: technician.isBlacklisted
                      ? AppColors.error
                      : AppColors.brand500,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        technician.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: technician.isBlacklisted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Blacklisted',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.slate800 : AppColors.slate100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        technician.trade,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.star, size: 14, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      technician.rating.toStringAsFixed(1),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${technician.jobsDone} jobs',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      currencyFormat.format(technician.gmnMoneyMade),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Arrow
          Icon(
            Icons.chevron_right,
            color: isDark ? AppColors.slate500 : AppColors.slate400,
          ),
        ],
      ),
    );
  }
}
