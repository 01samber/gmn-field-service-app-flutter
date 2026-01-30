import 'package:intl/intl.dart';

/// Utility class for formatting values
class Formatters {
  Formatters._();

  static final _currencyFormat = NumberFormat.currency(symbol: '\$');
  static final _compactCurrencyFormat = NumberFormat.compactCurrency(
    symbol: '\$',
  );
  static final _percentFormat = NumberFormat.percentPattern();
  static final _dateFormat = DateFormat('MMM d, yyyy');
  static final _dateTimeFormat = DateFormat('MMM d, yyyy h:mm a');
  static final _timeFormat = DateFormat('h:mm a');

  /// Format as currency ($1,234.56)
  static String currency(double value) => _currencyFormat.format(value);

  /// Format as compact currency ($1.2K)
  static String compactCurrency(double value) =>
      _compactCurrencyFormat.format(value);

  /// Format as percentage (12%)
  static String percent(double value) => _percentFormat.format(value);

  /// Format date (Jan 1, 2024)
  static String date(DateTime date) => _dateFormat.format(date);

  /// Format date and time (Jan 1, 2024 2:30 PM)
  static String dateTime(DateTime date) => _dateTimeFormat.format(date);

  /// Format time only (2:30 PM)
  static String time(DateTime date) => _timeFormat.format(date);

  /// Format relative time (2h ago, Yesterday, etc.)
  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return _dateFormat.format(date);
    }
  }

  /// Format file size (1.2 MB)
  static String fileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Format phone number
  static String phone(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    return phone;
  }

  /// Capitalize first letter of each word
  static String titleCase(String text) {
    return text
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  /// Format status (in_progress -> In Progress)
  static String status(String status) {
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

  /// Alias for status() method
  static String formatStatus(String status) => Formatters.status(status);

  /// Capitalize first letter of a string
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
  }

  /// Format as month and year (January 2024)
  static String monthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }
}
