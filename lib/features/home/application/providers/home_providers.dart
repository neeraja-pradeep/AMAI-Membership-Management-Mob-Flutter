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

/// Provider for Home Hive Box (opened in main.dart before app runs)
final homeBoxProvider = Provider<Box<dynamic>>((ref) {
  // Box is already opened in main.dart, just get the reference
  return Hive.box(HomeBoxKeys.boxName);
});

// ============== Data Source Providers ==============

/// Provider for Home API
final homeApiProvider = Provider<HomeApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HomeApiImpl(apiClient: apiClient);
});

/// Provider for Home Local Data Source (timestamp only)
final homeLocalDataSourceProvider = Provider<HomeLocalDataSource>((ref) {
  final box = ref.watch(homeBoxProvider);
  return HomeLocalDataSourceImpl(box: box);
});

// ============== Repository Providers ==============

/// Provider for Home Repository
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final homeApi = ref.watch(homeApiProvider);
  final localDataSource = ref.watch(homeLocalDataSourceProvider);
  final connectivity = ref.watch(connectivityProvider);

  return HomeRepositoryImpl(
    homeApi: homeApi,
    localDataSource: localDataSource,
    connectivity: connectivity,
  );
});

// ============== Usecase Providers ==============

/// Provider for Fetch Membership Usecase
final fetchMembershipUsecaseProvider = Provider<FetchMembershipUsecase>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return FetchMembershipUsecase(repository: repository);
});

// ============== State Providers ==============

/// Provider for Membership State
/// Data is kept in-memory, only timestamp is persisted in Hive
final membershipStateProvider =
    StateNotifierProvider<MembershipNotifier, MembershipState>((ref) {
  return MembershipNotifier(ref);
});

/// Notifier for managing membership state
/// Handles fresh fetch on app launch and if-modified-since on refresh
class MembershipNotifier extends StateNotifier<MembershipState> {
  MembershipNotifier(this._ref) : super(const MembershipState.initial());

  final Ref _ref;

  /// Initialize by fetching fresh data from API
  /// Called on app launch - does NOT use if-modified-since
  Future<void> initialize() async {
    state = const MembershipState.loading();

    final usecase = _ref.read(fetchMembershipUsecaseProvider);
    final result = await usecase();

    result.fold(
      (failure) {
        state = MembershipState.error(failure: failure);
      },
      (membershipCard) {
        if (membershipCard != null) {
          state = MembershipState.loaded(membershipCard: membershipCard);
        } else {
          state = const MembershipState.empty();
        }
      },
    );
  }

  /// Refresh membership card using if-modified-since
  /// Called on pull-to-refresh - uses stored timestamp
  Future<void> refresh() async {
    final previousData = state.currentData;
    state = MembershipState.loading(previousData: previousData);

    final usecase = _ref.read(fetchMembershipUsecaseProvider);
    final result = await usecase.refresh();

    result.fold(
      (failure) {
        // On error, keep previous data visible with error banner
        state = MembershipState.error(
          failure: failure,
          cachedData: previousData,
        );
      },
      (membershipCard) {
        if (membershipCard != null) {
          // Got fresh data (200 OK)
          state = MembershipState.loaded(membershipCard: membershipCard);
        } else {
          // 304 Not Modified - keep in-memory data
          if (previousData != null) {
            state = MembershipState.loaded(membershipCard: previousData);
          } else {
            state = const MembershipState.empty();
          }
        }
      },
    );
  }

  /// Clear state and timestamp
  Future<void> clear() async {
    final repository = _ref.read(homeRepositoryProvider);
    await repository.clearTimestamp();
    state = const MembershipState.initial();
  }
}
