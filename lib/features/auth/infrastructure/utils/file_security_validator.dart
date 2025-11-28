import 'dart:io';
import 'package:mime/mime.dart';

/// File security validator
///
/// Validates files before upload to prevent security vulnerabilities:
/// - Validates file extension AND MIME type
/// - Scans file headers to prevent extension spoofing
/// - Rejects executable files
/// - Sanitizes file names
class FileSecurityValidator {
  /// Allowed MIME types for uploads
  static const allowedMimeTypes = {
    'image/jpeg',
    'image/png',
    'application/pdf',
  };

  /// Allowed file extensions
  static const allowedExtensions = {
    'jpg',
    'jpeg',
    'png',
    'pdf',
  };

  /// Blocked extensions (executables, scripts, etc.)
  static const blockedExtensions = {
    // Windows executables
    'exe', 'msi', 'bat', 'cmd', 'com', 'scr',
    // Unix/Linux executables
    'sh', 'bash', 'csh', 'ksh', 'run',
    // Mobile app packages
    'apk', 'ipa', 'xap',
    // Mac executables
    'app', 'dmg', 'pkg',
    // Linux packages
    'deb', 'rpm',
    // Java/Cross-platform
    'jar', 'war', 'ear',
    // Scripts
    'js', 'vbs', 'ps1', 'php', 'py', 'rb', 'pl',
    // Archives (could contain executables)
    'zip', 'rar', '7z', 'tar', 'gz',
  };

  /// Maximum filename length
  static const maxFilenameLength = 100;

  /// Validate file comprehensively
  ///
  /// Returns [FileValidationResult] with validation status
  static Future<FileValidationResult> validateFile(File file) async {
    // 1. Check if file exists
    if (!await file.exists()) {
      return FileValidationResult.failure('File does not exist');
    }

    // 2. Get file extension
    final filename = file.path.split('/').last;
    final extension = filename.split('.').last.toLowerCase();

    // 3. Check for blocked extensions (executables)
    if (blockedExtensions.contains(extension)) {
      return FileValidationResult.failure(
        'Executable and script files are not allowed for security reasons',
      );
    }

    // 4. Check if extension is in allowed list
    if (!allowedExtensions.contains(extension)) {
      return FileValidationResult.failure(
        'Invalid file type. Allowed: ${allowedExtensions.join(", ").toUpperCase()}',
      );
    }

    // 5. Validate MIME type
    final mimeType = lookupMimeType(file.path);

    if (mimeType == null || !allowedMimeTypes.contains(mimeType)) {
      return FileValidationResult.failure(
        'Invalid file type. Allowed: PDF, JPG, PNG',
      );
    }

    // 6. Validate file header (prevent extension spoofing)
    final headerValid = await _validateFileHeader(file, extension);

    if (!headerValid) {
      return FileValidationResult.failure(
        'File appears to be corrupted or has wrong extension',
      );
    }

    // 7. Sanitize filename
    final sanitizedName = sanitizeFilename(filename);

    return FileValidationResult.success(sanitizedName);
  }

  /// Validate file header (magic numbers)
  ///
  /// Prevents extension spoofing by checking actual file content
  static Future<bool> _validateFileHeader(File file, String extension) async {
    try {
      final bytes = await file.readAsBytes();

      if (bytes.isEmpty) return false;

      switch (extension) {
        case 'pdf':
          // PDF: %PDF (0x25 0x50 0x44 0x46)
          return bytes.length >= 4 &&
              bytes[0] == 0x25 &&
              bytes[1] == 0x50 &&
              bytes[2] == 0x44 &&
              bytes[3] == 0x46;

        case 'jpg':
        case 'jpeg':
          // JPEG: 0xFF 0xD8
          return bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xD8;

        case 'png':
          // PNG: 0x89 0x50 0x4E 0x47 0x0D 0x0A 0x1A 0x0A
          return bytes.length >= 8 &&
              bytes[0] == 0x89 &&
              bytes[1] == 0x50 &&
              bytes[2] == 0x4E &&
              bytes[3] == 0x47 &&
              bytes[4] == 0x0D &&
              bytes[5] == 0x0A &&
              bytes[6] == 0x1A &&
              bytes[7] == 0x0A;

        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Sanitize filename to prevent security vulnerabilities
  ///
  /// Removes:
  /// - Path traversal attempts (.., /, \)
  /// - Special characters that could cause issues
  /// - Excessively long names
  static String sanitizeFilename(String filename) {
    String sanitized = filename;

    // Remove path traversal attempts
    sanitized = sanitized.replaceAll('..', '');
    sanitized = sanitized.replaceAll('/', '');
    sanitized = sanitized.replaceAll('\\', '');

    // Remove special characters that could cause issues
    // Keep: letters, numbers, dots, dashes, underscores
    sanitized = sanitized.replaceAll(RegExp(r'[^a-zA-Z0-9.\-_]'), '_');

    // Remove multiple consecutive underscores
    sanitized = sanitized.replaceAll(RegExp(r'_+'), '_');

    // Ensure filename has an extension
    if (!sanitized.contains('.')) {
      sanitized = '${sanitized}.tmp';
    }

    // Limit length while preserving extension
    if (sanitized.length > maxFilenameLength) {
      final parts = sanitized.split('.');
      final extension = parts.last;
      final nameWithoutExt = parts.sublist(0, parts.length - 1).join('.');

      final maxNameLength = maxFilenameLength - extension.length - 1;
      sanitized = '${nameWithoutExt.substring(0, maxNameLength)}.$extension';
    }

    return sanitized;
  }

  /// Check if file size is within limit
  ///
  /// Returns error message if file is too large, null otherwise
  static Future<String?> validateFileSize(
    File file, {
    required int maxSizeMB,
  }) async {
    final sizeBytes = await file.length();
    final maxSizeBytes = maxSizeMB * 1024 * 1024;

    if (sizeBytes > maxSizeBytes) {
      return 'File size exceeds ${maxSizeMB}MB limit';
    }

    return null;
  }

  /// Get human-readable file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

/// File validation result
class FileValidationResult {
  final bool isValid;
  final String? error;
  final String? sanitizedFilename;

  const FileValidationResult._({
    required this.isValid,
    this.error,
    this.sanitizedFilename,
  });

  /// Create success result
  factory FileValidationResult.success(String sanitizedFilename) {
    return FileValidationResult._(
      isValid: true,
      sanitizedFilename: sanitizedFilename,
    );
  }

  /// Create failure result
  factory FileValidationResult.failure(String error) {
    return FileValidationResult._(
      isValid: false,
      error: error,
    );
  }

  @override
  String toString() {
    if (isValid) {
      return 'FileValidationResult(valid, filename: $sanitizedFilename)';
    } else {
      return 'FileValidationResult(invalid, error: $error)';
    }
  }
}
