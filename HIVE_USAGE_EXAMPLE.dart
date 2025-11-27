// ============================================================================
// HIVE CACHE USAGE EXAMPLES
// ============================================================================
// This file demonstrates real-world usage of the HIVE cache architecture
// following the project's coding standards and folder structure.
// ============================================================================

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import cache components
import 'lib/core/storage/hive/cache_manager.dart';
import 'lib/core/storage/hive/cache_manager_provider.dart';
import 'lib/core/storage/hive/cache_utils.dart';

// ============================================================================
// EXAMPLE 1: Auth Repository with Cache
// Location: lib/features/auth/infrastructure/repositories/auth_repository_impl.dart
// ============================================================================

/// Auth repository implementation using HIVE cache
class AuthRepositoryImpl {
  final CacheManager _cacheManager;
  final Dio _dio;

  AuthRepositoryImpl({
    required CacheManager cacheManager,
    required Dio dio,
  })  : _cacheManager = cacheManager,
        _dio = dio;

  /// Login with email and password
  /// Cache the response for faster subsequent logins
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    // Generate unique cache key
    final cacheKey = CacheUtils.generateCacheKey(
      endpoint: '/api/accounts/login/',
      method: 'POST',
      requestBody: {
        'email': email,
        'password': password,
      },
    );

    // Fetch with 3-layer cache
    final result = await _cacheManager.get<Map<String, dynamic>>(
      cacheKey: cacheKey,
      networkFetch: () async {
        final response = await _dio.post(
          '/api/accounts/login/',
          data: {
            'email': email,
            'password': password,
          },
        );
        return response.data as Map<String, dynamic>;
      },
      headers: {}, // Response headers will be populated by Dio
    );

    // Parse and return
    return LoginResponse.fromJson(result.data!);
  }

  /// Register new user
  /// Note: Registration should NOT be cached (mutation operation)
  Future<RegisterResponse> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    // No cache for mutations - direct network call
    final response = await _dio.post(
      '/api/membership/register/',
      data: {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
      },
    );

    return RegisterResponse.fromJson(response.data);
  }
}

/// Riverpod provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  final cacheManager = ref.watch(cacheManagerProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://amai.nexogms.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  return AuthRepositoryImpl(
    cacheManager: cacheManager,
    dio: dio,
  );
});

// ============================================================================
// EXAMPLE 2: Dashboard Repository with Background Refresh
// Location: lib/features/dashboard/infrastructure/repositories/dashboard_repository_impl.dart
// ============================================================================

class DashboardRepositoryImpl {
  final CacheManager _cacheManager;
  final Dio _dio;

  DashboardRepositoryImpl({
    required CacheManager cacheManager,
    required Dio dio,
  })  : _cacheManager = cacheManager,
        _dio = dio;

  /// Fetch dashboard data
  /// Uses cache if valid (< 12h), refreshes in background
  Future<DashboardData> fetchDashboard({
    required String userId,
    bool forceRefresh = false,
  }) async {
    final cacheKey = CacheUtils.generateCacheKey(
      endpoint: '/api/dashboard',
      method: 'GET',
      queryParams: {'user_id': userId},
    );

    final result = await _cacheManager.get<Map<String, dynamic>>(
      cacheKey: cacheKey,
      forceRefresh: forceRefresh,
      networkFetch: () async {
        final response = await _dio.get(
          '/api/dashboard',
          queryParameters: {'user_id': userId},
        );
        return response.data as Map<String, dynamic>;
      },
    );

    return DashboardData.fromJson(result.data!);
  }

  /// Get cache status for dashboard
  Future<CacheStatus> getDashboardCacheStatus(String userId) async {
    final cacheKey = CacheUtils.generateCacheKey(
      endpoint: '/api/dashboard',
      method: 'GET',
      queryParams: {'user_id': userId},
    );

    // Try to get from cache without network fetch
    final result = await _cacheManager.get<Map<String, dynamic>>(
      cacheKey: cacheKey,
      networkFetch: () async {
        throw Exception('No network fetch');
      },
    );

    return CacheStatus(
      source: result.source,
      isStale: result.isStale,
      lastModified: result.lastModified,
    );
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepositoryImpl>((ref) {
  final cacheManager = ref.watch(cacheManagerProvider);
  final dio = Dio(BaseOptions(baseUrl: 'https://amai.nexogms.com'));

  return DashboardRepositoryImpl(
    cacheManager: cacheManager,
    dio: dio,
  );
});

// ============================================================================
// EXAMPLE 3: Membership Applications with Pagination Cache
// Location: lib/features/membership/infrastructure/repositories/membership_repository_impl.dart
// ============================================================================

class MembershipRepositoryImpl {
  final CacheManager _cacheManager;
  final Dio _dio;

  MembershipRepositoryImpl({
    required CacheManager cacheManager,
    required Dio dio,
  })  : _cacheManager = cacheManager,
        _dio = dio;

  /// Fetch membership applications with pagination
  /// Each page is cached independently
  Future<PaginatedResponse<MembershipApplication>> fetchApplications({
    required int page,
    int pageSize = 20,
  }) async {
    // Unique cache key per page
    final cacheKey = CacheUtils.generateCacheKey(
      endpoint: '/api/membership/membership-applications/',
      method: 'GET',
      queryParams: {
        'page': page.toString(),
        'page_size': pageSize.toString(),
      },
    );

    final result = await _cacheManager.get<Map<String, dynamic>>(
      cacheKey: cacheKey,
      networkFetch: () async {
        final response = await _dio.get(
          '/api/membership/membership-applications/',
          queryParameters: {
            'page': page,
            'page_size': pageSize,
          },
        );
        return response.data as Map<String, dynamic>;
      },
    );

    return PaginatedResponse<MembershipApplication>.fromJson(
      result.data!,
      (json) => MembershipApplication.fromJson(json),
    );
  }

  /// Clear all cached applications (useful after approval/rejection)
  Future<void> clearApplicationsCache() async {
    await _cacheManager.clearAll();
  }
}

// ============================================================================
// EXAMPLE 4: UseCase with Cache (Application Layer)
// Location: lib/features/auth/application/usecases/login.dart
// ============================================================================

class LoginUseCase {
  final AuthRepositoryImpl _repository;

  LoginUseCase(this._repository);

  Future<LoginResult> execute({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _repository.login(
        email: email,
        password: password,
      );

      return LoginResult.success(response);
    } catch (e) {
      return LoginResult.failure(e.toString());
    }
  }
}

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

// ============================================================================
// EXAMPLE 5: Provider with Cache Statistics
// Location: lib/features/settings/application/providers/cache_stats_provider.dart
// ============================================================================

/// Provider to monitor cache statistics
final cacheStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final cacheManager = ref.watch(cacheManagerProvider);
  return cacheManager.getStats();
});

/// StateNotifier to manage cache operations
class CacheControllerStateNotifier extends StateNotifier<CacheControlState> {
  final CacheManager _cacheManager;

  CacheControllerStateNotifier(this._cacheManager)
      : super(const CacheControlState.initial());

  /// Clear all cache
  Future<void> clearAllCache() async {
    state = const CacheControlState.loading();

    try {
      await _cacheManager.clearAll();
      state = const CacheControlState.success('Cache cleared successfully');
    } catch (e) {
      state = CacheControlState.error(e.toString());
    }
  }

  /// Get cache statistics
  void loadStats() {
    final stats = _cacheManager.getStats();
    state = CacheControlState.loaded(stats);
  }
}

final cacheControllerProvider =
    StateNotifierProvider<CacheControllerStateNotifier, CacheControlState>(
  (ref) {
    final cacheManager = ref.watch(cacheManagerProvider);
    return CacheControllerStateNotifier(cacheManager);
  },
);

// ============================================================================
// MODEL CLASSES (for example purposes)
// ============================================================================

class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final User user;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      user: User.fromJson(json['user']),
    );
  }
}

class User {
  final int id;
  final String email;
  final String firstName;
  final String lastName;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
    );
  }
}

class RegisterResponse {
  final String message;
  final int userId;

  RegisterResponse({required this.message, required this.userId});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'] as String,
      userId: json['user_id'] as int,
    );
  }
}

class DashboardData {
  final String greeting;
  final List<String> recentActivities;

  DashboardData({required this.greeting, required this.recentActivities});

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      greeting: json['greeting'] as String,
      recentActivities: (json['recent_activities'] as List)
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class CacheStatus {
  final CacheSource source;
  final bool isStale;
  final String? lastModified;

  CacheStatus({
    required this.source,
    required this.isStale,
    this.lastModified,
  });
}

class MembershipApplication {
  final int id;
  final String status;

  MembershipApplication({required this.id, required this.status});

  factory MembershipApplication.fromJson(Map<String, dynamic> json) {
    return MembershipApplication(
      id: json['id'] as int,
      status: json['status'] as String,
    );
  }
}

class PaginatedResponse<T> {
  final List<T> results;
  final int count;
  final String? next;
  final String? previous;

  PaginatedResponse({
    required this.results,
    required this.count,
    this.next,
    this.previous,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse(
      results: (json['results'] as List)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
    );
  }
}

class LoginResult {
  final bool isSuccess;
  final LoginResponse? response;
  final String? error;

  LoginResult.success(this.response)
      : isSuccess = true,
        error = null;

  LoginResult.failure(this.error)
      : isSuccess = false,
        response = null;
}

// State classes
sealed class CacheControlState {
  const CacheControlState();

  const factory CacheControlState.initial() = _Initial;
  const factory CacheControlState.loading() = _Loading;
  const factory CacheControlState.success(String message) = _Success;
  const factory CacheControlState.error(String message) = _Error;
  const factory CacheControlState.loaded(Map<String, dynamic> stats) = _Loaded;
}

class _Initial extends CacheControlState {
  const _Initial();
}

class _Loading extends CacheControlState {
  const _Loading();
}

class _Success extends CacheControlState {
  final String message;
  const _Success(this.message);
}

class _Error extends CacheControlState {
  final String message;
  const _Error(this.message);
}

class _Loaded extends CacheControlState {
  final Map<String, dynamic> stats;
  const _Loaded(this.stats);
}
