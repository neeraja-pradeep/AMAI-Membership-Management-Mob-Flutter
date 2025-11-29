import 'dart:io';

import 'package:dio/dio.dart';

/// Network exception types for handling API errors
sealed class NetworkException implements Exception {
  const NetworkException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// No internet connection
class NoInternetException extends NetworkException {
  const NoInternetException()
      : super('No internet connection. Please check your network.');
}

/// Server returned an error response
class ServerException extends NetworkException {
  const ServerException({
    required this.statusCode,
    required String message,
  }) : super(message);

  final int statusCode;
}

/// Request timeout
class TimeoutException extends NetworkException {
  const TimeoutException()
      : super('Request timed out. Please try again.');
}

/// Request was cancelled
class CancelledException extends NetworkException {
  const CancelledException() : super('Request was cancelled.');
}

/// Unknown/unexpected error
class UnknownException extends NetworkException {
  const UnknownException([String? message])
      : super(message ?? 'An unexpected error occurred.');
}

/// 304 Not Modified response - not an error, but special handling needed
class NotModifiedException extends NetworkException {
  const NotModifiedException() : super('Data not modified.');
}

/// Utility class to map DioException to NetworkException
class NetworkExceptionMapper {
  NetworkExceptionMapper._();

  /// Maps a DioException to appropriate NetworkException
  static NetworkException fromDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.cancel:
        return const CancelledException();

      case DioExceptionType.connectionError:
        return const NoInternetException();

      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode ?? 500;
        final message = _extractErrorMessage(exception.response);

        // Handle 304 Not Modified specially
        if (statusCode == 304) {
          return const NotModifiedException();
        }

        return ServerException(
          statusCode: statusCode,
          message: message,
        );

      case DioExceptionType.badCertificate:
        return const UnknownException('SSL certificate error.');

      case DioExceptionType.unknown:
        if (exception.error is SocketException) {
          return const NoInternetException();
        }
        return UnknownException(exception.message);
    }
  }

  /// Extracts error message from response
  static String _extractErrorMessage(Response<dynamic>? response) {
    if (response == null) {
      return 'Server error occurred.';
    }

    final data = response.data;
    if (data is Map<String, dynamic>) {
      // Try common error message fields
      if (data.containsKey('message')) {
        return data['message'].toString();
      }
      if (data.containsKey('error')) {
        return data['error'].toString();
      }
      if (data.containsKey('detail')) {
        return data['detail'].toString();
      }
    }

    return _defaultMessageForStatusCode(response.statusCode ?? 500);
  }

  /// Default error messages for HTTP status codes
  static String _defaultMessageForStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Access denied.';
      case 404:
        return 'Resource not found.';
      case 422:
        return 'Validation error.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Internal server error.';
      case 502:
        return 'Bad gateway.';
      case 503:
        return 'Service unavailable.';
      default:
        return 'Server error occurred.';
    }
  }
}
