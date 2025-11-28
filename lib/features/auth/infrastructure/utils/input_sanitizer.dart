/// Input sanitizer for form fields
///
/// SECURITY REQUIREMENTS:
/// - Escape special characters in text fields
/// - Prevent SQL injection (additional layer, API is primary defense)
/// - Limit input lengths strictly
/// - Validate and sanitize email/phone formats
class InputSanitizer {
  /// Sanitize general text input
  ///
  /// Escapes HTML special characters and removes dangerous content
  static String sanitizeText(String input) {
    String sanitized = input.trim();

    // Escape HTML special characters
    sanitized = sanitized
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');

    // Remove null bytes and control characters
    sanitized = sanitized.replaceAll('\x00', '');
    sanitized = sanitized.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

    return sanitized;
  }

  /// Sanitize for SQL (additional safety layer)
  ///
  /// NOTE: API should handle this, but we add extra layer for defense in depth
  static String sanitizeForSQL(String input) {
    String sanitized = input.trim();

    // Escape single quotes (SQL string delimiter)
    sanitized = sanitized.replaceAll("'", "''");

    // Remove SQL comment indicators
    sanitized = sanitized.replaceAll('--', '');
    sanitized = sanitized.replaceAll('/*', '');
    sanitized = sanitized.replaceAll('*/', '');

    // Remove dangerous SQL keywords (case-insensitive)
    final dangerousPatterns = [
      r'\bSELECT\b',
      r'\bINSERT\b',
      r'\bUPDATE\b',
      r'\bDELETE\b',
      r'\bDROP\b',
      r'\bCREATE\b',
      r'\bALTER\b',
      r'\bEXEC\b',
      r'\bEXECUTE\b',
      r'\bUNION\b',
      r'\bSCRIPT\b',
    ];

    for (final pattern in dangerousPatterns) {
      sanitized = sanitized.replaceAll(
        RegExp(pattern, caseSensitive: false),
        '',
      );
    }

    return sanitized;
  }

  /// Validate and enforce length limits
  ///
  /// Returns error message if validation fails, null otherwise
  static String? validateLength(
    String input, {
    int? minLength,
    int? maxLength,
  }) {
    if (minLength != null && input.length < minLength) {
      return 'Minimum length is $minLength characters';
    }

    if (maxLength != null && input.length > maxLength) {
      return 'Maximum length is $maxLength characters';
    }

    return null;
  }

  /// Sanitize email address
  ///
  /// Returns sanitized email or throws ArgumentError if invalid
  static String sanitizeEmail(String email) {
    // Trim and convert to lowercase
    String sanitized = email.trim().toLowerCase();

    // Remove spaces
    sanitized = sanitized.replaceAll(' ', '');

    // Basic format validation
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(sanitized)) {
      throw ArgumentError('Invalid email format');
    }

    // Check for suspicious patterns
    if (sanitized.contains('..') || sanitized.startsWith('.')) {
      throw ArgumentError('Invalid email format');
    }

    return sanitized;
  }

  /// Sanitize phone number
  ///
  /// Returns sanitized phone or throws ArgumentError if invalid
  static String sanitizePhone(String phone) {
    // Remove all non-digit characters except +
    String sanitized = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Validate format
    if (sanitized.startsWith('+')) {
      // International format: +[country code][number]
      // E.164 format: 1-15 digits after +
      if (sanitized.length < 8 || sanitized.length > 16) {
        throw ArgumentError('Invalid international phone format');
      }

      // Check for multiple + signs
      if (sanitized.indexOf('+') != sanitized.lastIndexOf('+')) {
        throw ArgumentError('Invalid phone format: multiple + signs');
      }
    } else {
      // Local format: typically 10 digits
      if (sanitized.length < 10 || sanitized.length > 11) {
        throw ArgumentError('Invalid phone format');
      }
    }

    return sanitized;
  }

  /// Sanitize name (person's name)
  ///
  /// Allows letters, spaces, hyphens, apostrophes
  static String sanitizeName(String name) {
    String sanitized = name.trim();

    // Allow only letters, spaces, hyphens, apostrophes, and dots
    sanitized = sanitized.replaceAll(
      RegExp(r"[^a-zA-Z\s\-'.]"),
      '',
    );

    // Remove multiple consecutive spaces
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');

    // Capitalize first letter of each word
    sanitized = sanitized.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');

    return sanitized;
  }

  /// Sanitize alphanumeric input (e.g., council registration number)
  ///
  /// Allows only letters and numbers
  static String sanitizeAlphanumeric(String input) {
    String sanitized = input.trim().toUpperCase();

    // Remove all non-alphanumeric characters
    sanitized = sanitized.replaceAll(RegExp(r'[^A-Z0-9]'), '');

    return sanitized;
  }

  /// Sanitize address
  ///
  /// Allows letters, numbers, spaces, and common punctuation
  static String sanitizeAddress(String address) {
    String sanitized = address.trim();

    // Allow letters, numbers, spaces, and common address characters
    sanitized = sanitized.replaceAll(
      RegExp(r'[^a-zA-Z0-9\s,.\-/#]'),
      '',
    );

    // Remove multiple consecutive spaces
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');

    return sanitized;
  }

  /// Validate numeric input
  ///
  /// Returns error message if not a valid number within range
  static String? validateNumeric(
    String input, {
    num? min,
    num? max,
  }) {
    final number = num.tryParse(input);

    if (number == null) {
      return 'Please enter a valid number';
    }

    if (min != null && number < min) {
      return 'Value must be at least $min';
    }

    if (max != null && number > max) {
      return 'Value must not exceed $max';
    }

    return null;
  }

  /// Validate URL
  ///
  /// Returns sanitized URL or throws ArgumentError if invalid
  static String sanitizeUrl(String url) {
    String sanitized = url.trim();

    // Basic URL validation
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(sanitized)) {
      throw ArgumentError('Invalid URL format');
    }

    return sanitized;
  }
}

/// Input length limits for all registration fields
///
/// SECURITY: Strictly enforce these limits to prevent buffer overflows
/// and database issues
class InputLengthLimits {
  InputLengthLimits._();

  // Personal details
  static const int firstName = 50;
  static const int lastName = 50;
  static const int email = 100;
  static const int phone = 15;

  // Professional details
  static const int councilNumber = 50;
  static const int councilName = 100;
  static const int qualification = 100;
  static const int specialization = 100;
  static const int instituteName = 200;
  static const int designation = 100;
  static const int workplace = 200;

  // Address details
  static const int addressLine = 200;
  static const int city = 50;
  static const int state = 50;
  static const int pincode = 10;
  static const int country = 50;

  // Numeric limits
  static const int minYearsOfExperience = 0;
  static const int maxYearsOfExperience = 70;

  // General
  static const int generalTextField = 500;
}

/// Input validation patterns
class InputPatterns {
  InputPatterns._();

  // Email pattern (RFC 5322 simplified)
  static final RegExp email = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Phone pattern (international and local)
  static final RegExp phone = RegExp(
    r'^\+?[1-9]\d{1,14}$',
  );

  // Name pattern (letters, spaces, hyphens, apostrophes)
  static final RegExp name = RegExp(
    r"^[a-zA-Z\s\-'.]+$",
  );

  // Alphanumeric pattern
  static final RegExp alphanumeric = RegExp(
    r'^[a-zA-Z0-9]+$',
  );

  // Numeric pattern
  static final RegExp numeric = RegExp(
    r'^[0-9]+$',
  );

  // Pincode pattern (6 digits for India)
  static final RegExp pincode = RegExp(
    r'^[0-9]{6}$',
  );
}
