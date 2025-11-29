import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/core/network/api_client.dart';
import 'package:myapp/features/home/application/states/membership_state.dart';
import 'package:myapp/features/home/application/usecases/fetch_membership_usecase.dart';
import 'package:myapp/features/home/domain/repositories/home_repository.dart';
import 'package:myapp/features/home/infrastructure/data_sources/local/home_local_ds.dart';
import 'package:myapp/features/home/infrastructure/data_sources/remote/home_api.dart';
import 'package:myapp/features/home/infrastructure/repositories/home_repository_impl.dart';

// ============== Core Providers ==============

/// Provider for API client
/// TODO: Replace with actual user ID from auth state
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(userId: 19); // Practitioner user ID
});

/// Provider for Connectivity
final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

/// Provider for Home Hive Box
final homeBoxProvider = FutureProvider<Box<dynamic>>((ref) async {
  return Hive.openBox(HomeBoxKeys.boxName);
});

// ============== Data Source Providers ==============

/// Provider for Home API
final homeApiProvider = Provider<HomeApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HomeApiImpl(apiClient: apiClient);
});

/// Provider for Home Local Data Source
final homeLocalDataSourceProvider = Provider<HomeLocalDataSource?>((ref) {
  final boxAsync = ref.watch(homeBoxProvider);
  return boxAsync.whenOrNull(
    data: (box) => HomeLocalDataSourceImpl(box: box),
  );
});

// ============== Repository Providers ==============

/// Provider for Home Repository
final homeRepositoryProvider = Provider<HomeRepository?>((ref) {
  final homeApi = ref.watch(homeApiProvider);
  final localDataSource = ref.watch(homeLocalDataSourceProvider);
  final connectivity = ref.watch(connectivityProvider);

  if (localDataSource == null) return null;

  return HomeRepositoryImpl(
    homeApi: homeApi,
    localDataSource: localDataSource,
    connectivity: connectivity,
  );
});

// ============== Usecase Providers ==============

/// Provider for Fetch Membership Usecase
final fetchMembershipUsecaseProvider = Provider<FetchMembershipUsecase?>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  if (repository == null) return null;
  return FetchMembershipUsecase(repository: repository);
});

/// Provider for Get Cached Membership Usecase
final getCachedMembershipUsecaseProvider =
    Provider<GetCachedMembershipUsecase?>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  if (repository == null) return null;
  return GetCachedMembershipUsecase(repository: repository);
});

// ============== State Providers ==============

/// Provider for Membership State
final membershipStateProvider =
    StateNotifierProvider<MembershipNotifier, MembershipState>((ref) {
  return MembershipNotifier(ref);
});

/// Notifier for managing membership state
class MembershipNotifier extends StateNotifier<MembershipState> {
  MembershipNotifier(this._ref) : super(const MembershipState.initial());

  final Ref _ref;

  /// Initialize by loading cached data first, then fetching fresh data
  Future<void> initialize() async {
    // First, try to show cached data
    await _loadCachedData();

    // Then fetch fresh data from API
    await fetchMembershipCard();
  }

  /// Load cached membership card data
  Future<void> _loadCachedData() async {
    final usecase = _ref.read(getCachedMembershipUsecaseProvider);
    if (usecase == null) return;

    final result = await usecase();
    result.fold(
      (_) {}, // Ignore cache errors
      (cachedCard) {
        if (cachedCard != null) {
          state = MembershipState.loaded(membershipCard: cachedCard);
        }
      },
    );
  }

  /// Fetch membership card from API
  Future<void> fetchMembershipCard() async {
    final usecase = _ref.read(fetchMembershipUsecaseProvider);
    if (usecase == null) {
      state = const MembershipState.error(
        failure: CacheFailure(message: 'Service not ready. Please try again.'),
      );
      return;
    }

    // Set loading state, preserving previous data
    final previousData = state.currentData;
    state = MembershipState.loading(previousData: previousData);

    final result = await usecase();

    result.fold(
      (failure) {
        // Error state - show error but keep cached data visible
        state = MembershipState.error(
          failure: failure,
          cachedData: previousData,
        );
      },
      (membershipCard) {
        state = MembershipState.loaded(membershipCard: membershipCard);
      },
    );
  }

  /// Refresh membership card (pull-to-refresh)
  Future<void> refresh() async {
    await fetchMembershipCard();
  }

  /// Clear state and cache
  Future<void> clear() async {
    final repository = _ref.read(homeRepositoryProvider);
    await repository?.clearCache();
    state = const MembershipState.initial();
  }
}
