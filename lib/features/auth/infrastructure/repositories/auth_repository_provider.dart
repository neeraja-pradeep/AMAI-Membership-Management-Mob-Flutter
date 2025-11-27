import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client_provider.dart';
import '../../../../core/storage/hive/cache_manager_provider.dart';
import '../data_sources/local/auth_local_ds.dart';
import '../data_sources/remote/auth_api.dart';
import 'auth_repository_impl.dart';

/// Auth API provider
final authApiProvider = Provider<AuthApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthApi(apiClient);
});

/// Auth local data source provider
final authLocalDsProvider = Provider<AuthLocalDs>((ref) {
  return AuthLocalDs();
});

/// Auth repository provider (singleton)
///
/// Usage:
/// ```dart
/// final authRepository = ref.watch(authRepositoryProvider);
/// ```
final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  final authApi = ref.watch(authApiProvider);
  final authLocalDs = ref.watch(authLocalDsProvider);
  final cacheManager = ref.watch(cacheManagerProvider);

  final repository = AuthRepositoryImpl(
    authApi: authApi,
    authLocalDs: authLocalDs,
    cacheManager: cacheManager,
  );

  // Cleanup on dispose
  ref.onDispose(() {
    repository.dispose();
  });

  return repository;
});
