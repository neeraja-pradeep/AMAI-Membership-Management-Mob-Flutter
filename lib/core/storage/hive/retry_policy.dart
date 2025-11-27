import 'dart:async';
import 'dart:math';
import 'cache_config.dart';

/// HTTP exception wrapper for status code checking
class HttpException implements Exception {
  final int statusCode;
  final String message;

  HttpException(this.statusCode, this.message);

  @override
  String toString() => 'HttpException: $statusCode - $message';
}

/// Retry policy with exponential backoff
///
/// Retry Strategy:
/// - Attempt 1: Immediate
/// - Attempt 2: +2s delay
/// - Attempt 3: +4s delay
/// - Attempt 4: +8s delay
/// - Max attempts: 4
/// - Max total wait: 15s
class RetryPolicy {
  /// Executes an operation with exponential backoff retry logic
  ///
  /// Retry conditions:
  /// - 5xx server errors: Retry
  /// - 4xx client errors: Do NOT retry (rethrow immediately)
  /// - Timeout/network errors: Retry
  ///
  /// Returns the result of the operation if successful
  /// Throws the last exception if all retries fail
  Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxAttempts = CacheConfig.maxRetryAttempts,
  }) async {
    int attempt = 0;

    while (attempt < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempt++;

        // If max attempts reached, rethrow
        if (attempt >= maxAttempts) {
          rethrow;
        }

        // Don't retry 4xx errors (client errors)
        if (e is HttpException && e.statusCode >= 400 && e.statusCode < 500) {
          rethrow;
        }

        // Calculate exponential backoff delay
        // Formula: 2^(attempt - 1) * base_delay
        // Attempt 1: 2^0 * 2s = 2s
        // Attempt 2: 2^1 * 2s = 4s
        // Attempt 3: 2^2 * 2s = 8s
        final delaySeconds = pow(2, attempt - 1).toInt() *
            CacheConfig.retryBaseDelay.inSeconds;
        final delay = Duration(seconds: delaySeconds);

        // Wait before retry
        await Future.delayed(delay);
      }
    }

    throw Exception('Max retries exceeded');
  }

  /// Executes an operation with a single retry
  /// Useful for simple operations that don't need full exponential backoff
  Future<T> executeWithSingleRetry<T>(
    Future<T> Function() operation,
  ) async {
    try {
      return await operation();
    } catch (e) {
      // Wait 2 seconds and retry once
      await Future.delayed(CacheConfig.retryBaseDelay);
      return await operation();
    }
  }

  /// Checks if an error is retryable
  bool isRetryable(dynamic error) {
    if (error is HttpException) {
      // Retry server errors (5xx), not client errors (4xx)
      return error.statusCode >= 500;
    }

    // Retry timeout and network errors
    if (error is TimeoutException) return true;

    // Check for common network error messages
    final errorMessage = error.toString().toLowerCase();
    if (errorMessage.contains('socket') ||
        errorMessage.contains('connection') ||
        errorMessage.contains('network') ||
        errorMessage.contains('timeout')) {
      return true;
    }

    return false;
  }
}
