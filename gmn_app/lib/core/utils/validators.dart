/// Utility class for form validation
class Validators {
  Validators._();

  /// Validate email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validate password
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  /// Validate required field
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName is required'
          : 'This field is required';
    }
    return null;
  }

  /// Validate phone number
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validate number
  static String? number(
    String? value, {
    double? min,
    double? max,
    bool allowDecimal = true,
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (!allowDecimal && number != number.truncateToDouble()) {
      return 'Please enter a whole number';
    }

    if (min != null && number < min) {
      return '${fieldName ?? 'Value'} must be at least $min';
    }

    if (max != null && number > max) {
      return '${fieldName ?? 'Value'} must be at most $max';
    }

    return null;
  }

  /// Validate URL
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    if (!(Uri.tryParse(value)?.hasAbsolutePath ?? false)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  /// Validate min length
  static String? minLength(String? value, int length, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    if (value.length < length) {
      return '${fieldName ?? 'This field'} must be at least $length characters';
    }
    return null;
  }

  /// Validate max length
  static String? maxLength(String? value, int length, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    if (value.length > length) {
      return '${fieldName ?? 'This field'} must be at most $length characters';
    }
    return null;
  }

  /// Combine multiple validators
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
