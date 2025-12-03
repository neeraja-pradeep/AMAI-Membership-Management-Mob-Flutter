import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/core/network/api_client.dart';
import 'package:myapp/features/home/application/providers/home_providers.dart';
import 'package:myapp/features/membership/application/states/membership_screen_state.dart';
import 'package:myapp/features/membership/application/usecases/fetch_membership_status_usecase.dart';
import 'package:myapp/features/membership/domain/repositories/membership_repository.dart';
import 'package:myapp/features/membership/infrastructure/data_sources/local/membership_local_ds.dart';
import 'package:myapp/features/membership/infrastructure/data_sources/remote/membership_api.dart';
import 'package:myapp/features/membership/infrastructure/repositories/membership_repository_impl.dart';

// ============== Core Providers (reusing from home) ==============

// Using userIdProvider and apiClientProvider from home_providers.dart

// ============== Membership Box Provider ==============

/// Provider for Membership Hive Box
final membershipBoxProvider = Provider<Box<dynamic>>((ref) {
  // Box is opened in hive_init.dart
  return Hive.box(MembershipBoxKeys.boxName);
});

// ============== Data Source Providers ==============

/// Provider for Membership API
final membershipApiProvider = Provider<MembershipApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MembershipApiImpl(apiClient: apiClient);
});

/// Provider for Membership Local Data Source
final membershipLocalDataSourceProvider =
    Provider<MembershipLocalDataSource>((ref) {
  final box = ref.watch(membershipBoxProvider);
  return MembershipLocalDataSourceImpl(box: box);
});

// ============== Repository Provider ==============

/// Provider for Membership Repository
final membershipRepositoryProvider = Provider<MembershipRepository>((ref) {
  final membershipApi = ref.watch(membershipApiProvider);
  final localDataSource = ref.watch(membershipLocalDataSourceProvider);
  final connectivity = ref.watch(connectivityProvider);

  return MembershipRepositoryImpl(
    membershipApi: membershipApi,
    localDataSource: localDataSource,
    connectivity: connectivity,
  );
});

// ============== Usecase Providers ==============

/// Provider for Fetch Membership Status Usecase
final fetchMembershipStatusUsecaseProvider =
    Provider<FetchMembershipStatusUsecase>((ref) {
  final repository = ref.watch(membershipRepositoryProvider);
  return FetchMembershipStatusUsecase(repository: repository);
});

// ============== State Provider ==============

/// Provider for Membership Screen State
final membershipScreenStateProvider =
    StateNotifierProvider<MembershipScreenNotifier, MembershipScreenState>(
        (ref) {
  return MembershipScreenNotifier(ref);
});

/// Notifier for managing membership screen state
class MembershipScreenNotifier extends StateNotifier<MembershipScreenState> {
  MembershipScreenNotifier(this._ref)
      : super(const MembershipScreenState.initial());

  final Ref _ref;

  /// Initialize by fetching fresh data from API
  /// Called on screen load - does NOT use if-modified-since
  Future<void> initialize() async {
    state = const MembershipScreenState.loading();

    final usecase = _ref.read(fetchMembershipStatusUsecaseProvider);
    final result = await usecase();

    result.fold(
      (failure) {
        state = MembershipScreenState.error(failure: failure);
      },
      (membershipStatus) {
        if (membershipStatus != null) {
          state =
              MembershipScreenState.loaded(membershipStatus: membershipStatus);
        } else {
          state = const MembershipScreenState.empty();
        }
      },
    );
  }

  /// Refresh membership status using if-modified-since
  /// Called on pull-to-refresh
  Future<void> refresh() async {
    final previousData = state.currentData;
    state = MembershipScreenState.loading(previousData: previousData);

    final usecase = _ref.read(fetchMembershipStatusUsecaseProvider);
    final result = await usecase.refresh();

    result.fold(
      (failure) {
        // On error, keep previous data visible with error banner
        state = MembershipScreenState.error(
          failure: failure,
          cachedData: previousData,
        );
      },
      (membershipStatus) {
        if (membershipStatus != null) {
          // Got fresh data (200 OK)
          state =
              MembershipScreenState.loaded(membershipStatus: membershipStatus);
        } else {
          // 304 Not Modified - keep in-memory data
          if (previousData != null) {
            state =
                MembershipScreenState.loaded(membershipStatus: previousData);
          } else {
            state = const MembershipScreenState.empty();
          }
        }
      },
    );
  }

  /// Clear state and timestamp
  Future<void> clear() async {
    final repository = _ref.read(membershipRepositoryProvider);
    await repository.clearTimestamp();
    state = const MembershipScreenState.initial();
  }
}
