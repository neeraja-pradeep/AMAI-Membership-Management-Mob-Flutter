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

  int _loginAttemptCount = 0;

  AuthApi(this._apiClient);

  /// Login with email and password
  ///
  /// POST /api/accounts/login/
  ///
  /// CRITICAL PATTERN: Cookie-based session and CSRF
  /// - Backend sets session and CSRF cookies (HTTP-only)
  /// - Dio CookieManager stores cookies automatically
  /// - ApiClient interceptor extracts CSRF from cookies on every request
  /// - NO manual token extraction or storage
  ///
  /// Returns LoginResponse on success
  /// Throws DioException on failure
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      // Generate device ID (or retrieve from persistent storage)

      final request = LoginRequest(email: email, password: password);

      final response = await _apiClient.post<Map<String, dynamic>>(
        Endpoints.login,
        data: request.toJson(),
      );

      // CRITICAL PATTERN: Cookies are stored automatically by Dio CookieManager
      // Backend sets:
      // - sessionid cookie (HTTP-only)
      // - csrftoken cookie (HTTP-only)
      // Both stored in .cookies/ directory via path_provider

      // // Extract XCSRF token from response headers
      // final xcsrfToken =
      //     response.headers.value('x-csrftoken') ??
      //     response.data?['xcsrf_token'] as String? ??
      //     '';

      // // Extract If-Modified-Since header
      // final ifModifiedSince = response.headers.value('last-modified');

      // Build login response (user data only - no tokens)
      final loginResponse = LoginResponse.fromJson(response.data!);

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
  Future<bool> registerWithRole({required String role}) async {
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
  /// CRITICAL PATTERN: Cookie-based session and CSRF
  /// - Clears all cookies (session + CSRF)
  /// - NO manual header removal needed
  ///
  /// Returns true on success
  Future<bool> logout() async {
    try {
      await _apiClient.post<Map<String, dynamic>>(Endpoints.logout);

      // CRITICAL PATTERN: Clear all cookies (session + CSRF)
      // This removes both sessionid and csrftoken cookies
      // NO manual header removal needed - cookies handle everything
      await _apiClient.clearCookies();

      return true;
    } on DioException {
      // Even if logout fails on server, clear local data
      await _apiClient.clearCookies();
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

  /// Send OTP for forgot password
  ///
  /// POST /api/auth/otp-signin/
  ///
  /// Sends OTP to the provided phone number
  /// Returns true on success
  /// Throws AuthException on failure
  Future<bool> sendOtp({required String phoneNumber}) async {
    try {
      await _apiClient.post<Map<String, dynamic>>(
        Endpoints.otpSignIn,
        data: {'phone_number': phoneNumber},
      );
      return true;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Verify OTP and reset password
  ///
  /// POST /api/auth/otp-signin/
  ///
  /// Verifies OTP and sets new password
  /// Returns true on success
  /// Throws AuthException on failure
  Future<bool> verifyOtpAndResetPassword({
    required String phoneNumber,
    required String otpCode,
    required String newPassword,
  }) async {
    try {
      await _apiClient.post<Map<String, dynamic>>(
        Endpoints.otpSignIn,
        data: {
          'phone_number': phoneNumber,
          'otp_code': otpCode,
          'new_password': newPassword,
        },
      );
      return true;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
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
    // Network errors
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const TimeoutException(
        message:
            'Request timed out. Please check your connection and try again.',
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      if (e.message?.contains('SocketException') ?? false) {
        if (e.message?.contains('Failed host lookup') ?? false) {
          return const DnsException(
            message:
                'Unable to reach server. Please check your internet connection.',
          );
        }
        return const NoInternetException(
          message:
              'No internet connection. Please check your network settings.',
        );
      }
      return const NoInternetException(
        message: 'Connection failed. Please check your internet connection.',
      );
    }

    // If no response
    final response = e.response;
    if (response == null) {
      return UnknownHttpException(
        statusCode: 0,
        message: 'An unexpected error occurred. Please try again.',
      );
    }

    final statusCode = response.statusCode ?? 0;
    ErrorResponse? errorResponse;

    try {
      if (response.data is Map<String, dynamic>) {
        errorResponse = ErrorResponse.fromJson(response.data);
      }
    } catch (_) {}

    final message =
        errorResponse?.userMessage ??
        errorResponse?.message ??
        'An error occurred';
    final code = errorResponse?.errorCode;
    final fieldErrors = errorResponse?.fieldErrors;

    switch (statusCode) {
      case 400:
        return BadRequestException(
          message: message,
          code: code ?? '400',
          fieldErrors: fieldErrors?.map((k, v) => MapEntry(k, v.join(', '))),
        );

      case 401:
        return UnauthorizedException(
          message: message,
          code: code ?? '401',
          attemptCount: loginAttemptCount,
        );

      case 403:
        return ForbiddenException(
          message: message.isEmpty
              ? 'Access forbidden. Your session may have expired.'
              : message,
          code: code ?? '403',
        );

      case 422:
        return UnprocessableEntityException(
          message: message,
          code: code ?? '422',
          fieldErrors: fieldErrors?.map((k, v) => MapEntry(k, v.join(', '))),
        );

      case 429:
        final retryAfter =
            errorResponse?.retryAfter ??
            int.tryParse(response.headers.value('retry-after') ?? '') ??
            60;
        return TooManyRequestsException(
          message: message.isEmpty
              ? 'Too many requests. Please wait before trying again.'
              : message,
          retryAfter: retryAfter,
          code: code ?? '429',
        );

      case 500:
      case 502:
      case 503:
        return ServerException(
          message: message.isEmpty
              ? 'Server error. Please try again later.'
              : message,
          code: code ?? 'SERVER_ERROR_$statusCode',
          statusCode: statusCode,
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
            statusCode: statusCode,
          );
        } else {
          return UnknownHttpException(statusCode: statusCode, message: message);
        }
    }
  }
}
