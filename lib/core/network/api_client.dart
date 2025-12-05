import 'package:dio/dio.dart';
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

/// Dio-based API client with interceptors and error handling
class ApiClient {
  ApiClient({
    required int userId,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _userId = userId;
    _configureDio();
  }

  final Dio _dio;
  late final int _userId;

  /// Configure Dio with base options and interceptors
  void _configureDio() {
    _dio.options = BaseOptions(
      baseUrl: Endpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      // Don't throw on 304 or 404 status (404 may contain application_status in body)
      validateStatus: (status) =>
          (status != null && status >= 200 && status < 300) ||
          status == 304 ||
          status == 404,
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(userId: _userId),
      _LoggingInterceptor(),
    ]);
  }

  /// GET request
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

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    String? ifModifiedSince,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
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

  /// PUT request
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

  /// PATCH request
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

  /// DELETE request
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
}

/// Interceptor to add authentication headers
class _AuthInterceptor extends Interceptor {
  _AuthInterceptor({required this.userId});

  final int userId;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add dev header with user ID as per API documentation
    options.headers['dev'] = userId.toString();
    handler.next(options);
  }
}

/// Interceptor for logging requests and responses
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Log request in debug mode
    // ignore: avoid_print
    print('API Request: ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Log response in debug mode
    // ignore: avoid_print
    print('API Response: ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log error in debug mode
    // ignore: avoid_print
    print('API Error: ${err.type} ${err.message}');
    handler.next(err);
  }
}
