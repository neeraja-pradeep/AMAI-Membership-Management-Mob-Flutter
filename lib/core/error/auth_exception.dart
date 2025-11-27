/// Base authentication exception
abstract class AuthException implements Exception {
  final String message;
  final String? code;
  final Map<String, String>? fieldErrors;

  const AuthException(this.message, {this.code, this.fieldErrors});

  @override
  String toString() => message;
}

/// Network Exceptions

/// No internet connection exception
class NoInternetException extends AuthException {
  const NoInternetException()
      : super('No internet connection', code: 'NO_INTERNET');
}

/// Request timeout exception (>30s)
class TimeoutException extends AuthException {
  const TimeoutException()
      : super('Request timed out', code: 'TIMEOUT');
}

/// DNS failure exception
class DnsException extends AuthException {
  const DnsException()
      : super('Cannot reach server', code: 'DNS_FAILURE');
}

/// HTTP Exceptions

/// 400 Bad Request
class BadRequestException extends AuthException {
  const BadRequestException(
    super.message, {
    super.fieldErrors,
  }) : super(code: '400');
}

/// 401 Unauthorized - Invalid credentials
class UnauthorizedException extends AuthException {
  final int attemptCount;

  const UnauthorizedException({this.attemptCount = 1})
      : super('Invalid credentials', code: '401');

  /// Check if should show lockout (5+ failed attempts)
  bool get shouldLockout => attemptCount >= 5;

  /// Get lockout duration in seconds
  int get lockoutDuration => 60;
}

/// 403 Forbidden - Session expired or XCSRF token mismatch
class ForbiddenException extends AuthException {
  const ForbiddenException()
      : super('Session expired, please login again', code: '403');
}

/// 422 Unprocessable Entity - Validation errors
class UnprocessableEntityException extends AuthException {
  const UnprocessableEntityException(
    super.message, {
    super.fieldErrors,
  }) : super(code: '422');
}

/// 429 Too Many Requests - Rate limiting
class TooManyRequestsException extends AuthException {
  final int retryAfter; // seconds

  const TooManyRequestsException(this.retryAfter)
      : super(
          'Too many attempts. Try again in $retryAfter seconds',
          code: '429',
        );
}

/// 500/502/503 Server Error
class ServerException extends AuthException {
  final int? statusCode;

  const ServerException({this.statusCode})
      : super('Something went wrong, please try again', code: '500');
}

/// Unknown HTTP status code
class UnknownHttpException extends AuthException {
  final int statusCode;

  const UnknownHttpException(this.statusCode)
      : super(
          'An unexpected error occurred',
          code: statusCode.toString(),
        );
}

/// Parsing Exceptions

/// Invalid JSON response
class JsonParsingException extends AuthException {
  const JsonParsingException()
      : super('Invalid response format', code: 'PARSING_ERROR');
}

/// Missing required field in response
class MissingFieldException extends AuthException {
  final String fieldName;

  const MissingFieldException(this.fieldName)
      : super(
          'Required field missing: $fieldName',
          code: 'MISSING_FIELD',
        );
}

/// Generic exception for unknown errors
class UnknownException extends AuthException {
  const UnknownException([String? message])
      : super(message ?? 'An unknown error occurred', code: 'UNKNOWN');
}
