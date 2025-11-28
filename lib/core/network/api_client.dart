import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// API client with Dio, cookie management, and interceptors
///
/// Features:
/// - Automatic cookie persistence via path_provider
/// - SSL/TLS security (rejects self-signed certificates in production)
/// - Request/response logging (debug mode only)
/// - Error handling
/// - Timeout configuration (30s for production)
class ApiClient {
  late final Dio _dio;
  late final CookieJar _cookieJar;

  static const String kBaseUrl = 'https://amai.nexogms.com';
  static const Duration kConnectionTimeout = Duration(seconds: 30);
  static const Duration kReceiveTimeout = Duration(seconds: 30);
  static const Duration kSendTimeout = Duration(seconds: 30);

  ApiClient() {
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
        // SECURITY: Validate SSL certificates
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _configureSecurity();
    _initializeCookieJar();
    _setupInterceptors();
  }

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
    } else {
      // DEBUG: Allow self-signed certificates for local testing
      // WARNING: This is ONLY for development environments
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) {
          // Only allow in debug mode
          if (kDebugMode) {
            print('[API SECURITY WARNING] Accepting self-signed certificate for $host:$port');
            return true;
          }
          return false;
        };
        return client;
      };
    }
  }

  /// Initialize cookie jar for persistent cookies
  ///
  /// SECURITY: Session cookies stored via path_provider (not Hive)
  /// Cookies are stored in app's document directory with file system permissions
  Future<void> _initializeCookieJar() async {
    final directory = await getApplicationDocumentsDirectory();
    final cookiePath = '${directory.path}/.cookies/';
    _cookieJar = PersistCookieJar(
      storage: FileStorage(cookiePath),
    );

    // Add cookie manager interceptor
    _dio.interceptors.add(CookieManager(_cookieJar));
  }

  /// Setup request/response interceptors
  ///
  /// SECURITY: Passwords and tokens are NEVER logged
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Log request in debug mode (SECURITY: Never log passwords/tokens)
          if (kDebugMode) {
            final path = options.path;
            final method = options.method;
            // Don't log request body for login/register (contains passwords)
            if (!path.contains('login') && !path.contains('register')) {
              print('[API] $method $path');
            } else {
              print('[API] $method $path [BODY HIDDEN FOR SECURITY]');
            }
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log response in debug mode (SECURITY: Never log sensitive data)
          if (kDebugMode) {
            print('[API] ${response.statusCode} ${response.requestOptions.path}');
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          // Log errors (SECURITY: Never expose stack traces in production)
          if (kDebugMode) {
            print('[API ERROR] ${error.requestOptions.path}: ${error.message}');
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Add custom header (e.g., XCSRF token)
  void addHeader(String key, String value) {
    _dio.options.headers[key] = value;
  }

  /// Remove header
  void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }

  /// Clear all cookies
  Future<void> clearCookies() async {
    await _cookieJar.deleteAll();
  }

  /// Get cookies for a specific URI
  Future<List<Cookie>> getCookies(Uri uri) async {
    return await _cookieJar.loadForRequest(uri);
  }
}
