import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
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

      return loginResponse;
    } on DioException catch (e) {
      // Handle API errors
      if (e.response?.data != null) {
        final errorResponse = ErrorResponse.fromJson(e.response!.data);
        throw Exception(errorResponse.userMessage);
      }
      rethrow;
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
      if (e.response?.data != null) {
        final errorResponse = ErrorResponse.fromJson(e.response!.data);
        throw Exception(errorResponse.userMessage);
      }
      rethrow;
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
}
