import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Utility functions for cache operations
class CacheUtils {
  CacheUtils._();

  /// Generates a unique cache key using SHA256 hash
  ///
  /// Cache key formula:
  /// SHA256(endpoint + HTTP_method + sorted_query_params + request_body_hash + auth_token_hash)
  static String generateCacheKey({
    required String endpoint,
    required String method,
    Map<String, dynamic>? queryParams,
    dynamic requestBody,
    String? authToken,
  }) {
    final buffer = StringBuffer();

    // Add endpoint
    buffer.write(endpoint);

    // Add HTTP method
    buffer.write(method.toUpperCase());

    // Add sorted query parameters
    if (queryParams != null && queryParams.isNotEmpty) {
      final sortedKeys = queryParams.keys.toList()..sort();
      for (final key in sortedKeys) {
        buffer.write('$key=${queryParams[key]}');
      }
    }

    // Add request body hash
    if (requestBody != null) {
      final bodyJson = jsonEncode(requestBody);
      final bodyHash = sha256.convert(utf8.encode(bodyJson)).toString();
      buffer.write(bodyHash);
    }

    // Add auth token hash
    if (authToken != null && authToken.isNotEmpty) {
      final tokenHash = sha256.convert(utf8.encode(authToken)).toString();
      buffer.write(tokenHash);
    }

    // Generate final SHA256 hash
    final keyString = buffer.toString();
    final bytes = utf8.encode(keyString);
    final hash = sha256.convert(bytes);

    return hash.toString();
  }

  /// Calculates the approximate size of data in bytes
  static int calculateDataSize(dynamic data) {
    try {
      final jsonString = jsonEncode(data);
      return utf8.encode(jsonString).length;
    } catch (e) {
      // Fallback: rough estimation
      return data.toString().length * 2;
    }
  }

  /// Validates if data is a valid cache entry
  static bool isValidCacheData(dynamic data) {
    if (data == null) return false;

    // Check if data can be serialized to JSON
    try {
      jsonEncode(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Extracts Last-Modified header from response headers
  static String? extractLastModified(Map<String, dynamic>? headers) {
    if (headers == null) return null;

    // Try different header key variations
    final variations = [
      'last-modified',
      'Last-Modified',
      'LAST-MODIFIED',
    ];

    for (final key in variations) {
      if (headers.containsKey(key)) {
        final value = headers[key];
        if (value is String) return value;
        if (value is List && value.isNotEmpty) return value.first.toString();
      }
    }

    return null;
  }

  /// Formats cache age for display
  static String formatCacheAge(int cachedAt) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final difference = now - cachedAt;
    final duration = Duration(milliseconds: difference);

    if (duration.inMinutes < 1) {
      return 'Just now';
    } else if (duration.inHours < 1) {
      return '${duration.inMinutes} min ago';
    } else if (duration.inDays < 1) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''} ago';
    }
  }
}
