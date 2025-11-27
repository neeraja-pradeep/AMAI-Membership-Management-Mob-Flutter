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
class NoInternetException extends AuthException {
  const NoInternetException({
    String message = 'No internet connection',
    String code = 'NO_INTERNET',
  }) : super(message, code: code);
}

class TimeoutException extends AuthException {
  const TimeoutException({
    String message = 'Request timed out',
    String code = 'TIMEOUT',
  }) : super(message, code: code);
}

class DnsException extends AuthException {
  const DnsException({
    String message = 'Cannot reach server',
    String code = 'DNS_FAILURE',
  }) : super(message, code: code);
}

/// HTTP Exceptions
class BadRequestException extends AuthException {
  const BadRequestException({
    required String message,
    String code = '400',
    Map<String, String>? fieldErrors,
  }) : super(message, code: code, fieldErrors: fieldErrors);
}

class UnauthorizedException extends AuthException {
  final int attemptCount;

  const UnauthorizedException({
    required String message,
    String code = '401',
    this.attemptCount = 1,
  }) : super(message, code: code);

  bool get shouldLockout => attemptCount >= 5;
  int get lockoutDuration => 60;
}

class ForbiddenException extends AuthException {
  const ForbiddenException({required String message, String code = '403'})
    : super(message, code: code);
}

class UnprocessableEntityException extends AuthException {
  const UnprocessableEntityException({
    required String message,
    String code = '422',
    Map<String, String>? fieldErrors,
  }) : super(message, code: code, fieldErrors: fieldErrors);
}

class TooManyRequestsException extends AuthException {
  final int retryAfter;

  const TooManyRequestsException({
    required String message,
    String code = '429',
    required this.retryAfter,
  }) : super(message, code: code);
}

class ServerException extends AuthException {
  final int? statusCode;

  const ServerException({
    required String message,
    String code = '500',
    this.statusCode,
  }) : super(message, code: code);
}

class UnknownHttpException extends AuthException {
  final int statusCode;

  UnknownHttpException({required this.statusCode, required String message})
    : super(message, code: statusCode.toString());
}

/// Parsing Errors
class JsonParsingException extends AuthException {
  const JsonParsingException({
    String message = 'Invalid response format',
    String code = 'PARSING_ERROR',
  }) : super(message, code: code);
}

class MissingFieldException extends AuthException {
  const MissingFieldException({
    required String fieldName,
    String code = 'MISSING_FIELD',
  }) : super('Required field missing: $fieldName', code: code);
}

class UnknownException extends AuthException {
  const UnknownException({
    String message = 'An unknown error occurred',
    String code = 'UNKNOWN',
  }) : super(message, code: code);
}
