import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../../../../core/error/auth_exception.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/endpoints.dart';
import '../../models/error_response.dart';
import '../../models/login_request.dart';
import '../../models/login_response.dart';
import '../../models/registration_request.dart';

/// Auth remote data source (API layer)
///
/// Handles all authentication-related API calls
class AuthApi {
  final ApiClient _apiClient;
  final Uuid _uuid = const Uuid();
  int _loginAttemptCount = 0;

  AuthApi(this._apiClient);

  /// Login with email and password
  ///
  /// POST /api/accounts/login/
  ///
  /// Returns LoginResponse on success
  /// Throws DioException on failure
  Future<LoginResponse> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      // Generate device ID (or retrieve from persistent storage)
      final deviceId = _uuid.v4();

      final request = LoginRequest(
        email: email,
        password: password,
        rememberMe: rememberMe,
        deviceId: deviceId,
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        Endpoints.login,
        data: request.toJson(),
      );

      // Extract session ID from cookies
      final cookies = await _apiClient.getCookies(
        Uri.parse(Endpoints.fullUrl(Endpoints.login)),
      );
      final sessionCookie = cookies.firstWhere(
        (cookie) => cookie.name == 'sessionid',
        orElse: () => throw Exception('Session cookie not found'),
      );

      // Extract XCSRF token from response headers
      final xcsrfToken = response.headers.value('x-csrftoken') ??
          response.data?['xcsrf_token'] as String? ??
          '';

      // Extract If-Modified-Since header
      final ifModifiedSince = response.headers.value('last-modified');

      // Build login response
      final loginResponse = LoginResponse.fromJson({
        ...response.data!,
        'session_id': sessionCookie.value,
        'xcsrf_token': xcsrfToken,
        'if_modified_since': ifModifiedSince,
      });

      // Add XCSRF token to future requests
      if (xcsrfToken.isNotEmpty) {
        _apiClient.addHeader('X-CSRFToken', xcsrfToken);
      }

      // Reset attempt count on successful login
      _loginAttemptCount = 0;

      return loginResponse;
    } on DioException catch (e) {
      // Increment attempt count for 401 errors
      if (e.response?.statusCode == 401) {
        _loginAttemptCount++;
      }
      throw _handleDioException(e, loginAttemptCount: _loginAttemptCount);
    }
  }

  /// Register with selected role (Phase 1)
  ///
  /// POST /api/membership/register/
  ///
  /// Returns true on success
  /// Throws exception on failure
  Future<bool> registerWithRole({
    required String role,
  }) async {
    try {
      final request = RegistrationRequest(role: role);

      await _apiClient.post<Map<String, dynamic>>(
        Endpoints.register,
        data: request.toJson(),
      );

      return true;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Logout current user
  ///
  /// POST /api/accounts/logout/
  ///
  /// Returns true on success
  Future<bool> logout() async {
    try {
      await _apiClient.post<Map<String, dynamic>>(Endpoints.logout);

      // Clear cookies and headers
      await _apiClient.clearCookies();
      _apiClient.removeHeader('X-CSRFToken');

      return true;
    } on DioException {
      // Even if logout fails on server, clear local data
      await _apiClient.clearCookies();
      _apiClient.removeHeader('X-CSRFToken');
      return false;
    }
  }

  /// Refresh session (if needed)
  ///
  /// This would typically call a refresh endpoint
  /// For now, returns current session status
  Future<bool> refreshSession() async {
    // TODO: Implement actual session refresh endpoint when available
    return true;
  }

  /// Reset login attempt counter (call after successful login or timeout)
  void resetLoginAttempts() {
    _loginAttemptCount = 0;
  }

  /// Handle Dio exceptions and convert to custom auth exceptions
  ///
  /// Maps DioException to appropriate AuthException based on error type
  AuthException _handleDioException(
    DioException e, {
    int loginAttemptCount = 0,
  }) {
    // Network errors (no response from server)
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return TimeoutException(
        message: 'Request timed out. Please check your connection and try again.',
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      if (e.message?.contains('SocketException') ?? false) {
        if (e.message?.contains('Failed host lookup') ?? false) {
          return DnsException(
            message: 'Unable to reach server. Please check your internet connection.',
          );
        }
        return NoInternetException(
          message: 'No internet connection. Please check your network settings.',
        );
      }
      return NoInternetException(
        message: 'Connection failed. Please check your internet connection.',
      );
    }

    // HTTP errors (server responded with error)
    final response = e.response;
    if (response == null) {
      return UnknownHttpException(
        message: 'An unexpected error occurred. Please try again.',
        code: 'UNKNOWN',
      );
    }

    final statusCode = response.statusCode ?? 0;
    ErrorResponse? errorResponse;

    // Try to parse error response
    try {
      if (response.data != null && response.data is Map<String, dynamic>) {
        errorResponse = ErrorResponse.fromJson(response.data);
      }
    } catch (_) {
      // Parsing failed, will use default messages
    }

    final message = errorResponse?.userMessage ??
                   errorResponse?.message ??
                   'An error occurred';
    final code = errorResponse?.errorCode;
    final fieldErrors = errorResponse?.fieldErrors;

    // Map status codes to specific exceptions
    switch (statusCode) {
      case 400:
        return BadRequestException(
          message: message,
          code: code,
          fieldErrors: fieldErrors?.map(
            (key, value) => MapEntry(key, value.join(', ')),
          ),
        );

      case 401:
        return UnauthorizedException(
          message: message,
          code: code,
          attemptCount: loginAttemptCount,
        );

      case 403:
        return ForbiddenException(
          message: message.isEmpty
              ? 'Access forbidden. Your session may have expired.'
              : message,
          code: code,
        );

      case 422:
        return UnprocessableEntityException(
          message: message,
          code: code,
          fieldErrors: fieldErrors?.map(
            (key, value) => MapEntry(key, value.join(', ')),
          ),
        );

      case 429:
        final retryAfter = errorResponse?.retryAfter ??
                          int.tryParse(response.headers.value('retry-after') ?? '') ??
                          60;
        return TooManyRequestsException(
          message: message.isEmpty
              ? 'Too many requests. Please wait before trying again.'
              : message,
          code: code,
          retryAfter: retryAfter,
        );

      case 500:
      case 502:
      case 503:
        return ServerException(
          message: message.isEmpty
              ? 'Server error. Please try again later.'
              : message,
          code: code ?? 'SERVER_ERROR_$statusCode',
        );

      default:
        if (statusCode >= 400 && statusCode < 500) {
          return BadRequestException(
            message: message,
            code: code ?? 'CLIENT_ERROR_$statusCode',
          );
        } else if (statusCode >= 500) {
          return ServerException(
            message: message,
            code: code ?? 'SERVER_ERROR_$statusCode',
          );
        } else {
          return UnknownHttpException(
            message: message,
            code: code ?? 'HTTP_ERROR_$statusCode',
          );
        }
    }
  }
}
