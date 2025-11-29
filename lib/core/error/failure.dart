import 'package:myapp/core/network/network_exceptions.dart';

/// Base failure class for domain-level error handling
sealed class Failure {
  const Failure({
    required this.message,
    this.code,
  });

  final String message;
  final String? code;

  /// Convert failure to user-friendly message
  String toUserMessage() => message;

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    this.statusCode,
  });

  final int? statusCode;

  @override
  String toUserMessage() {
    if (statusCode != null) {
      switch (statusCode) {
        case 401:
          return 'Please login again to continue.';
        case 403:
          return 'You do not have permission to access this resource.';
        case 404:
          return 'The requested data was not found.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return message;
      }
    }
    return message;
  }
}

/// Network connectivity failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.code = 'NETWORK_ERROR',
  });

  @override
  String toUserMessage() => 'Please check your internet connection and try again.';
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Failed to load cached data.',
    super.code = 'CACHE_ERROR',
  });

  @override
  String toUserMessage() => 'Unable to load saved data. Please refresh.';
}

/// Timeout failures
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Request timed out.',
    super.code = 'TIMEOUT_ERROR',
  });

  @override
  String toUserMessage() =>
      'The request took too long. Please try again.';
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_ERROR',
  });
}

/// Unknown/unexpected failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred.',
    super.code = 'UNKNOWN_ERROR',
  });

  @override
  String toUserMessage() => 'Something went wrong. Please try again.';
}

/// Utility to map NetworkException to Failure
class FailureMapper {
  FailureMapper._();

  /// Maps NetworkException to appropriate Failure
  static Failure fromNetworkException(NetworkException exception) {
    switch (exception) {
      case NoInternetException():
        return const NetworkFailure();
      case ServerException(statusCode: final code, message: final msg):
        return ServerFailure(
          message: msg,
          statusCode: code,
        );
      case TimeoutException():
        return const TimeoutFailure();
      case CancelledException():
        return const UnknownFailure(message: 'Request was cancelled.');
      case NotModifiedException():
        // This is not really a failure, but handling for completeness
        return const ServerFailure(
          message: 'Data not modified.',
          statusCode: 304,
        );
      case UnknownException(message: final msg):
        return UnknownFailure(message: msg);
    }
  }

  /// Maps any exception to Failure
  static Failure fromException(Object exception) {
    if (exception is NetworkException) {
      return fromNetworkException(exception);
    }
    if (exception is Failure) {
      return exception;
    }
    return UnknownFailure(message: exception.toString());
  }
}
