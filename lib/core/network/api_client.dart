import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:myapp/core/network/endpoints.dart';
import 'package:myapp/core/network/network_exceptions.dart';

/// Response wrapper that includes data, status code, and timestamp
class ApiResponse<T> {
  const ApiResponse({
    required this.data,
    required this.statusCode,
    this.timestamp,
  });

  final T? data;
  final int statusCode;
  final String? timestamp;

  /// Check if response is 304 Not Modified
  bool get isNotModified => statusCode == 304;

  /// Check if response is successful (2xx)
  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

/// API client with Dio, cookie management, and interceptors
///
/// Features:
/// - Automatic cookie persistence via path_provider
/// - SSL/TLS security (rejects self-signed certificates in production)
/// - Request/response logging (debug mode only)
/// - Error handling with ApiResponse wrapper
/// - Timeout configuration (30s for production)
/// - Session validation for auto-login
/// - CSRF token auto-extraction from cookies
class ApiClient {
  late final Dio _dio;
  late final PersistCookieJar _cookieJar;
  bool _isInitialized = false;
  int? _devUserId;

  static const String kBaseUrl = 'https://amai.nexogms.com';
  static const Duration kConnectionTimeout = Duration(seconds: 30);
  static const Duration kReceiveTimeout = Duration(seconds: 30);
  static const Duration kSendTimeout = Duration(seconds: 30);

  ApiClient({int? devUserId}) {
    _devUserId = devUserId;
    _dio = Dio(
      BaseOptions(
        baseUrl: kBaseUrl,
        connectTimeout: kConnectionTimeout,
        receiveTimeout: kReceiveTimeout,
        sendTimeout: kSendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        // Don't throw on 304 or 404 status (404 may contain application_status in body)
        validateStatus: (status) =>
            (status != null && status >= 200 && status < 300) ||
            status == 304 ||
            status == 404,
      ),
    );

    _configureSecurity();
  }

  /// Set dev user ID (for development/testing purposes)
  void setDevUserId(int userId) {
    _devUserId = userId;
  }

  /// Initialize the API client (must be called before first use)
  ///
  /// This sets up cookie persistence and interceptors.
  /// Call this in main() before runApp().
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _initializeCookieJar();
    _setupInterceptors();
    _isInitialized = true;
  }

  /// Check if API client is initialized
  bool get isInitialized => _isInitialized;

  /// Configure SSL/TLS security
  ///
  /// SECURITY REQUIREMENTS:
  /// - Reject self-signed certificates in production
  /// - Accept self-signed certificates in debug mode (for local testing)
  void _configureSecurity() {
    if (kReleaseMode) {
      // PRODUCTION: Strict SSL validation
      // Dio will automatically reject self-signed certificates
      // No additional configuration needed
    } else {}
  }

  /// Initialize cookie jar for persistent cookies
  ///
  /// SECURITY: Session cookies stored via path_provider (not Hive)
  /// Cookies are stored in app's document directory with file system permissions
  Future<void> _initializeCookieJar() async {
    final directory = await getApplicationDocumentsDirectory();
    final cookiePath = '${directory.path}/.cookies/';
    _cookieJar = PersistCookieJar(storage: FileStorage(cookiePath));

    // Add cookie manager interceptor
    _dio.interceptors.add(CookieManager(_cookieJar));
  }

  /// Setup request/response interceptors
  ///
  /// CRITICAL PATTERN: CSRF token auto-extraction from cookies
  /// - No manual token storage in Hive
  /// - No manual token extraction from response headers/body
  /// - CSRF token comes from cookies ONLY
  void _setupInterceptors() {
    // CSRF interceptor - MUST come before logging
    // Automatically extracts CSRF token from cookies and adds to requests
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final csrf = await _getCsrfToken();
          if (csrf != null) {
            options.headers['X-CSRFToken'] = csrf;
          }
          // Add dev header if set (for development/testing)
          if (_devUserId != null) {
            options.headers['dev'] = _devUserId.toString();
          }
          return handler.next(options);
        },
      ),
    );

    // Logging interceptor
    if (kDebugMode) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final path = options.path;
            final method = options.method;
            // Don't log request body for login/register (contains passwords)
            if (!path.contains('login') && !path.contains('register')) {
              debugPrint('[API] $method $path');
            } else {
              debugPrint('[API] $method $path [BODY HIDDEN FOR SECURITY]');
            }
            return handler.next(options);
          },
          onResponse: (response, handler) {
            debugPrint(
              '[API] ${response.statusCode} ${response.requestOptions.path}',
            );
            return handler.next(response);
          },
          onError: (error, handler) {
            debugPrint(
                '[API ERROR] ${error.requestOptions.path}: ${error.message}');
            return handler.next(error);
          },
        ),
      );
    }
  }

  /// Extract CSRF token from cookies
  ///
  /// CRITICAL PATTERN: Token comes from cookies, NOT from Hive or response headers
  /// This is the ONLY source of CSRF token in the entire application
  Future<String?> _getCsrfToken() async {
    final cookies = await _cookieJar.loadForRequest(
      Uri.parse(_dio.options.baseUrl),
    );

    final csrfCookie = cookies.firstWhere(
      (c) => c.name.toLowerCase() == 'csrftoken',
      orElse: () => Cookie('', ''),
    );

    return csrfCookie.value.isEmpty ? null : csrfCookie.value;
  }

  /// Check if a valid session exists
  ///
  /// Returns true if sessionid cookie exists and is not expired.
  /// Used for auto-login on app startup.
  Future<bool> hasValidSession() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final cookies = await _cookieJar.loadForRequest(
        Uri.parse(_dio.options.baseUrl),
      );

      // Check for sessionid cookie
      final sessionCookie = cookies.firstWhere(
        (c) => c.name.toLowerCase() == 'sessionid',
        orElse: () => Cookie('', ''),
      );

      if (sessionCookie.value.isEmpty) {
        return false;
      }

      // Check if session cookie is expired
      if (sessionCookie.expires != null) {
        if (sessionCookie.expires!.isBefore(DateTime.now())) {
          return false;
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error checking session: $e');
      return false;
    }
  }

  /// Validate session with server
  ///
  /// Makes a request to verify the session is still valid on the server.
  /// Returns true if session is valid, false otherwise.
  Future<bool> validateSessionWithServer() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Try to access the session validation endpoint
      final response = await _dio.get('/api/session/validate/');

      // If we get a 200, session is valid
      if (response.statusCode == 200) {
        return true;
      }

      // 401/403 means session is invalid
      if (response.statusCode == 401 || response.statusCode == 403) {
        return false;
      }

      // For other status codes, try checking addresses endpoint as fallback
      final fallbackResponse = await _dio.get('/api/accounts/addresses/');
      return fallbackResponse.statusCode == 200;
    } catch (e) {
      debugPrint('Session validation failed: $e');
      return false;
    }
  }

  /// GET request with ApiResponse wrapper
  ///
  /// Returns ApiResponse<T> with optional fromJson parsing and conditional requests
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    String? ifModifiedSince,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: Options(
          headers: ifModifiedSince != null
              ? {'If-Modified-Since': ifModifiedSince}
              : null,
        ),
      );

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw NetworkExceptionMapper.fromDioException(e);
    }
  }

  /// POST request with ApiResponse wrapper
  ///
  /// Returns ApiResponse<T> with optional fromJson parsing
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw NetworkExceptionMapper.fromDioException(e);
    }
  }

  /// PUT request with ApiResponse wrapper
  ///
  /// Returns ApiResponse<T> with optional fromJson parsing
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw NetworkExceptionMapper.fromDioException(e);
    }
  }

  /// PATCH request with ApiResponse wrapper
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.patch<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw NetworkExceptionMapper.fromDioException(e);
    }
  }

  /// DELETE request with ApiResponse wrapper
  ///
  /// Returns ApiResponse<T> with optional fromJson parsing
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw NetworkExceptionMapper.fromDioException(e);
    }
  }

  /// Handle response and extract timestamp from headers
  ApiResponse<T> _handleResponse<T>(
    Response<dynamic> response,
    T Function(dynamic json)? fromJson,
  ) {
    final statusCode = response.statusCode ?? 500;

    // Handle 304 Not Modified
    if (statusCode == 304) {
      return ApiResponse<T>(
        data: null,
        statusCode: statusCode,
        timestamp: null,
      );
    }

    // Extract Last-Modified timestamp from response headers
    final timestamp = response.headers.value('Last-Modified') ??
        response.headers.value('Date');

    // Parse response data
    T? data;
    if (response.data != null && fromJson != null) {
      data = fromJson(response.data);
    } else if (response.data is T) {
      data = response.data as T;
    }

    return ApiResponse<T>(
      data: data,
      statusCode: statusCode,
      timestamp: timestamp,
    );
  }

  /// Clear all cookies
  ///
  /// CRITICAL PATTERN: This clears both session AND CSRF token cookies
  /// Used on logout to completely clear authentication state
  Future<void> clearCookies() async {
    await _cookieJar.deleteAll();
  }

  /// Get cookies for a specific URI
  Future<List<Cookie>> getCookies(Uri uri) async {
    return await _cookieJar.loadForRequest(uri);
  }
}
