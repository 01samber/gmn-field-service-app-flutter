import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum BadgeSize { small, medium, large }

class StatusBadge extends StatelessWidget {
  final String status;
  final BadgeSize size;
  final bool showDot;
  final StatusType type;

  const StatusBadge({
    super.key,
    required this.status,
    this.size = BadgeSize.medium,
    this.showDot = true,
    this.type = StatusType.workOrder,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (backgroundColor, textColor) = _getColors(isDark);
    final (padding, fontSize, dotSize) = _getSizeParams();

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size == BadgeSize.small ? 6 : 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: size == BadgeSize.small ? 4 : 6),
          ],
          Text(
            _formatStatus(status),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _getColors(bool isDark) {
    switch (type) {
      case StatusType.workOrder:
        return (
          AppColors.getStatusBackground(status, isDark: isDark),
          AppColors.getStatusColor(status, isDark: isDark),
        );
      case StatusType.cost:
        return (
          _getCostBackground(isDark),
          AppColors.getCostStatusColor(status, isDark: isDark),
        );
      case StatusType.proposal:
        return (
          _getProposalBackground(isDark),
          AppColors.getProposalStatusColor(status, isDark: isDark),
        );
      case StatusType.priority:
        return (
          _getPriorityBackground(isDark),
          AppColors.getPriorityColor(status),
        );
    }
  }

  Color _getCostBackground(bool isDark) {
    switch (status.toLowerCase()) {
      case 'requested':
        return isDark
            ? AppColors.waitingDark.withValues(alpha: 0.3)
            : AppColors.waitingLight;
      case 'approved':
        return isDark
            ? AppColors.inProgressDark.withValues(alpha: 0.3)
            : AppColors.inProgressLight;
      case 'paid':
        return isDark
            ? AppColors.paidDark.withValues(alpha: 0.3)
            : AppColors.paidLight;
      default:
        return isDark ? AppColors.slate800 : AppColors.slate100;
    }
  }

  Color _getProposalBackground(bool isDark) {
    switch (status.toLowerCase()) {
      case 'draft':
        return isDark ? AppColors.slate800 : AppColors.slate100;
      case 'sent':
        return isDark
            ? AppColors.inProgressDark.withValues(alpha: 0.3)
            : AppColors.inProgressLight;
      case 'approved':
        return isDark
            ? AppColors.paidDark.withValues(alpha: 0.3)
            : AppColors.paidLight;
      case 'rejected':
        return isDark
            ? AppColors.overdueDark.withValues(alpha: 0.3)
            : AppColors.overdueLight;
      default:
        return isDark ? AppColors.slate800 : AppColors.slate100;
    }
  }

  Color _getPriorityBackground(bool isDark) {
    switch (status.toLowerCase()) {
      case 'urgent':
        return isDark
            ? AppColors.error.withValues(alpha: 0.15)
            : AppColors.error.withValues(alpha: 0.1);
      case 'high':
        return isDark
            ? AppColors.warning.withValues(alpha: 0.15)
            : AppColors.warning.withValues(alpha: 0.1);
      case 'normal':
        return isDark
            ? AppColors.brand500.withValues(alpha: 0.15)
            : AppColors.brand500.withValues(alpha: 0.1);
      case 'low':
        return isDark ? AppColors.slate800 : AppColors.slate100;
      default:
        return isDark ? AppColors.slate800 : AppColors.slate100;
    }
  }

  (EdgeInsets, double, double) _getSizeParams() {
    switch (size) {
      case BadgeSize.small:
        return (
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          11.0,
          5.0,
        );
      case BadgeSize.medium:
        return (
          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          12.0,
          6.0,
        );
      case BadgeSize.large:
        return (
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          14.0,
          7.0,
        );
    }
  }

  String _formatStatus(String status) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

enum StatusType { workOrder, cost, proposal, priority }

// Priority badge (alias for easier usage)
class PriorityBadge extends StatelessWidget {
  final String priority;
  final BadgeSize size;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.size = BadgeSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    return StatusBadge(
      status: priority,
      size: size,
      showDot: false,
      type: StatusType.priority,
    );
  }
}
