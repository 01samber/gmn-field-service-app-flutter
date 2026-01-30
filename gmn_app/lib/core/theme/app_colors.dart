import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand Colors (Sky Blue)
  static const Color brand50 = Color(0xFFF0F9FF);
  static const Color brand100 = Color(0xFFE0F2FE);
  static const Color brand200 = Color(0xFFBAE6FD);
  static const Color brand300 = Color(0xFF7DD3FC);
  static const Color brand400 = Color(0xFF38BDF8);
  static const Color brand500 = Color(0xFF0EA5E9); // Primary
  static const Color brand600 = Color(0xFF0284C7);
  static const Color brand700 = Color(0xFF0369A1);
  static const Color brand800 = Color(0xFF075985);
  static const Color brand900 = Color(0xFF0C4A6E);
  static const Color brand950 = Color(0xFF082F49);

  // Primary alias
  static const Color primary = brand500;
  static const Color primaryDark = brand600;
  static const Color primaryDarker = brand700;
  static const Color primaryLight = brand400;
  static const Color primaryLighter = brand200;

  // Slate (Neutral)
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);

  // Status Colors - Light Mode
  static const Color waitingLight = Color(0xFFFFFBEB); // amber-50
  static const Color waitingText = Color(0xFFB45309); // amber-700
  static const Color waitingDark = Color(0xFF451A03); // amber-900

  static const Color inProgressLight = Color(0xFFF0F9FF); // sky-50
  static const Color inProgressText = Color(0xFF0369A1); // sky-700
  static const Color inProgressDark = Color(0xFF0C4A6E); // sky-900

  static const Color completedLight = Color(0xFFECFDF5); // emerald-50
  static const Color completedText = Color(0xFF047857); // emerald-700
  static const Color completedDark = Color(0xFF064E3B); // emerald-900

  static const Color invoicedLight = Color(0xFFF5F3FF); // violet-50
  static const Color invoicedText = Color(0xFF6D28D9); // violet-700
  static const Color invoicedDark = Color(0xFF4C1D95); // violet-900

  static const Color paidLight = Color(0xFFF0FDF4); // green-50
  static const Color paidText = Color(0xFF15803D); // green-700
  static const Color paidDark = Color(0xFF14532D); // green-900

  static const Color overdueLight = Color(0xFFFFF1F2); // rose-50
  static const Color overdueText = Color(0xFFBE123C); // rose-700
  static const Color overdueDark = Color(0xFF881337); // rose-900

  // Semantic Colors
  static const Color success = Color(0xFF10B981); // emerald-500
  static const Color warning = Color(0xFFF59E0B); // amber-500
  static const Color error = Color(0xFFEF4444); // red-500
  static const Color info = Color(0xFF0EA5E9); // sky-500

  // Background Colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF0F172A); // slate-900
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E293B); // slate-800

  // Card Colors
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E293B); // slate-800
  static const Color cardBorderLight = Color(0xFFE2E8F0); // slate-200
  static const Color cardBorderDark = Color(0xFF334155); // slate-700

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF0F172A); // slate-900
  static const Color textSecondaryLight = Color(0xFF64748B); // slate-500
  static const Color textTertiaryLight = Color(0xFF94A3B8); // slate-400
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // slate-50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // slate-400
  static const Color textTertiaryDark = Color(0xFF64748B); // slate-500

  // Glow Colors
  static const Color glowBrand = Color(0x660EA5E9); // 40% opacity
  static const Color glowSuccess = Color(0x6610B981);
  static const Color glowWarning = Color(0x66F59E0B);
  static const Color glowDanger = Color(0x66EF4444);

  // Additional Color Aliases (for convenience)
  static const Color amber = Color(0xFFF59E0B); // amber-500
  static const Color emerald = Color(0xFF10B981); // emerald-500
  static const Color rose = Color(0xFFF43F5E); // rose-500
  static const Color secondary = Color(0xFF8B5CF6); // violet-500

  // Text color aliases (default to light mode)
  static const Color textSecondary = textSecondaryLight;
  static const Color textTertiary = textTertiaryLight;

  // Surface color aliases
  static const Color surface = surfaceLight;
  static const Color surfaceVariant = Color(0xFFF1F5F9); // slate-100
  static const Color surfaceVariantDark = Color(0xFF334155); // slate-700

  // Border color aliases
  static const Color border = cardBorderLight;
  static const Color borderDark = cardBorderDark;

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [brand500, brand600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Get status color for work orders
  static Color getStatusColor(String status, {bool isDark = false}) {
    switch (status.toLowerCase()) {
      case 'waiting':
        return isDark ? waitingDark : waitingText;
      case 'in_progress':
        return isDark ? inProgressDark : inProgressText;
      case 'completed':
        return isDark ? completedDark : completedText;
      case 'invoiced':
        return isDark ? invoicedDark : invoicedText;
      case 'paid':
        return isDark ? paidDark : paidText;
      default:
        return isDark ? slate900 : slate500;
    }
  }

  // Get status background color
  static Color getStatusBackground(String status, {bool isDark = false}) {
    switch (status.toLowerCase()) {
      case 'waiting':
        return isDark ? waitingDark.withValues(alpha: 0.3) : waitingLight;
      case 'in_progress':
        return isDark ? inProgressDark.withValues(alpha: 0.3) : inProgressLight;
      case 'completed':
        return isDark ? completedDark.withValues(alpha: 0.3) : completedLight;
      case 'invoiced':
        return isDark ? invoicedDark.withValues(alpha: 0.3) : invoicedLight;
      case 'paid':
        return isDark ? paidDark.withValues(alpha: 0.3) : paidLight;
      default:
        return isDark ? slate800 : slate100;
    }
  }

  // Get priority color
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return error;
      case 'high':
        return warning;
      case 'normal':
        return brand500;
      case 'low':
        return slate400;
      default:
        return slate400;
    }
  }

  // Get cost status color
  static Color getCostStatusColor(String status, {bool isDark = false}) {
    switch (status.toLowerCase()) {
      case 'requested':
        return isDark ? waitingDark : waitingText;
      case 'approved':
        return isDark ? inProgressDark : inProgressText;
      case 'paid':
        return isDark ? paidDark : paidText;
      default:
        return isDark ? slate900 : slate500;
    }
  }

  // Get proposal status color
  static Color getProposalStatusColor(String status, {bool isDark = false}) {
    switch (status.toLowerCase()) {
      case 'draft':
        return isDark ? slate700 : slate500;
      case 'sent':
        return isDark ? inProgressDark : inProgressText;
      case 'approved':
        return isDark ? paidDark : paidText;
      case 'rejected':
        return isDark ? overdueDark : overdueText;
      default:
        return isDark ? slate900 : slate500;
    }
  }
}
