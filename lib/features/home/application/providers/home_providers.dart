import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/core/network/api_client.dart';
import 'package:myapp/features/home/application/states/announcements_state.dart';
import 'package:myapp/features/home/application/states/aswas_state.dart';
import 'package:myapp/features/home/application/states/events_state.dart';
import 'package:myapp/features/home/application/states/membership_state.dart';
import 'package:myapp/features/home/application/usecases/fetch_announcements_usecase.dart';
import 'package:myapp/features/home/application/usecases/fetch_aswas_usecase.dart';
import 'package:myapp/features/home/application/usecases/fetch_events_usecase.dart';
import 'package:myapp/features/home/application/usecases/fetch_membership_usecase.dart';
import 'package:myapp/features/home/domain/repositories/home_repository.dart';
import 'package:myapp/features/home/infrastructure/data_sources/local/home_local_ds.dart';
import 'package:myapp/features/home/infrastructure/data_sources/remote/home_api.dart';
import 'package:myapp/features/home/infrastructure/repositories/home_repository_impl.dart';

// ============== Core Providers ==============

/// Provider for current user ID
/// TODO: Replace with actual user ID from auth state
final userIdProvider = Provider<int>((ref) {
  return 43; // Practitioner user ID
});

/// Provider for API client
/// TODO: Replace with actual user ID from auth state
final apiClientProvider = Provider<ApiClient>((ref) {
  final userId = ref.watch(userIdProvider);
  return ApiClient(userId: userId);
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

/// Provider for Fetch Aswas Usecase
final fetchAswasUsecaseProvider = Provider<FetchAswasUsecase>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return FetchAswasUsecase(repository: repository);
});

/// Provider for Fetch Events Usecase
final fetchEventsUsecaseProvider = Provider<FetchEventsUsecase>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return FetchEventsUsecase(repository: repository);
});

/// Provider for Fetch Announcements Usecase
final fetchAnnouncementsUsecaseProvider =
    Provider<FetchAnnouncementsUsecase>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return FetchAnnouncementsUsecase(repository: repository);
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
    await repository.clearMembershipTimestamp();
    state = const MembershipState.initial();
  }
}

// ============== Aswas Plus State Providers ==============

/// Provider for Aswas Plus State
/// Data is kept in-memory, only timestamp is persisted in Hive
final aswasStateProvider =
    StateNotifierProvider<AswasNotifier, AswasState>((ref) {
  return AswasNotifier(ref);
});

/// Notifier for managing Aswas Plus state
/// Handles fresh fetch on app launch and if-modified-since on refresh
class AswasNotifier extends StateNotifier<AswasState> {
  AswasNotifier(this._ref) : super(const AswasState.initial());

  final Ref _ref;

  /// Initialize by fetching fresh data from API
  /// Called on app launch - does NOT use if-modified-since
  Future<void> initialize() async {
    state = const AswasState.loading();

    final userId = _ref.read(userIdProvider);
    final usecase = _ref.read(fetchAswasUsecaseProvider);
    final result = await usecase(userId: userId);

    result.fold(
      (failure) {
        state = AswasState.error(failure: failure);
      },
      (aswasPlus) {
        if (aswasPlus != null) {
          state = AswasState.loaded(aswasPlus: aswasPlus);
        } else {
          state = const AswasState.empty();
        }
      },
    );
  }

  /// Refresh Aswas Plus using if-modified-since
  /// Called on pull-to-refresh - uses stored timestamp
  Future<void> refresh() async {
    final previousData = state.currentData;
    state = AswasState.loading(previousData: previousData);

    final userId = _ref.read(userIdProvider);
    final usecase = _ref.read(fetchAswasUsecaseProvider);
    final result = await usecase.refresh(userId: userId);

    result.fold(
      (failure) {
        // On error, keep previous data visible with error banner
        state = AswasState.error(
          failure: failure,
          cachedData: previousData,
        );
      },
      (aswasPlus) {
        if (aswasPlus != null) {
          // Got fresh data (200 OK)
          state = AswasState.loaded(aswasPlus: aswasPlus);
        } else {
          // 304 Not Modified - keep in-memory data
          if (previousData != null) {
            state = AswasState.loaded(aswasPlus: previousData);
          } else {
            state = const AswasState.empty();
          }
        }
      },
    );
  }

  /// Clear state and timestamp
  Future<void> clear() async {
    final repository = _ref.read(homeRepositoryProvider);
    await repository.clearAswasTimestamp();
    state = const AswasState.initial();
  }
}

// ============== Events State Providers ==============

/// Provider for Events State
/// Data is kept in-memory, only timestamp is persisted in Hive
final eventsStateProvider =
    StateNotifierProvider<EventsNotifier, EventsState>((ref) {
  return EventsNotifier(ref);
});

/// Notifier for managing events state
/// Handles fresh fetch on app launch and if-modified-since on refresh
class EventsNotifier extends StateNotifier<EventsState> {
  EventsNotifier(this._ref) : super(const EventsState.initial());

  final Ref _ref;

  /// Initialize by fetching fresh data from API
  /// Called on app launch - does NOT use if-modified-since
  Future<void> initialize() async {
    state = const EventsState.loading();

    final usecase = _ref.read(fetchEventsUsecaseProvider);
    final result = await usecase();

    result.fold(
      (failure) {
        state = EventsState.error(failure: failure);
      },
      (events) {
        if (events != null && events.isNotEmpty) {
          state = EventsState.loaded(events: events);
        } else {
          state = const EventsState.empty();
        }
      },
    );
  }

  /// Refresh events using if-modified-since
  /// Called on pull-to-refresh - uses stored timestamp
  Future<void> refresh() async {
    final previousData = state.currentData;
    state = EventsState.loading(previousData: previousData);

    final usecase = _ref.read(fetchEventsUsecaseProvider);
    final result = await usecase.refresh();

    result.fold(
      (failure) {
        // On error, keep previous data visible with error banner
        state = EventsState.error(
          failure: failure,
          cachedData: previousData,
        );
      },
      (events) {
        if (events != null) {
          // Got fresh data (200 OK)
          if (events.isNotEmpty) {
            state = EventsState.loaded(events: events);
          } else {
            state = const EventsState.empty();
          }
        } else {
          // 304 Not Modified - keep in-memory data
          if (previousData != null && previousData.isNotEmpty) {
            state = EventsState.loaded(events: previousData);
          } else {
            state = const EventsState.empty();
          }
        }
      },
    );
  }

  /// Clear state and timestamp
  Future<void> clear() async {
    final repository = _ref.read(homeRepositoryProvider);
    await repository.clearEventsTimestamp();
    state = const EventsState.initial();
  }
}

// ============== Announcements State Providers ==============

/// Provider for Announcements State
/// Data is kept in-memory, only timestamp is persisted in Hive
final announcementsStateProvider =
    StateNotifierProvider<AnnouncementsNotifier, AnnouncementsState>((ref) {
  return AnnouncementsNotifier(ref);
});

/// Notifier for managing announcements state
/// Handles fresh fetch on app launch and if-modified-since on refresh
class AnnouncementsNotifier extends StateNotifier<AnnouncementsState> {
  AnnouncementsNotifier(this._ref) : super(const AnnouncementsState.initial());

  final Ref _ref;

  /// Initialize by fetching fresh data from API
  /// Called on app launch - does NOT use if-modified-since
  Future<void> initialize() async {
    state = const AnnouncementsState.loading();

    final usecase = _ref.read(fetchAnnouncementsUsecaseProvider);
    final result = await usecase();

    result.fold(
      (failure) {
        state = AnnouncementsState.error(failure: failure);
      },
      (announcements) {
        if (announcements != null && announcements.isNotEmpty) {
          state = AnnouncementsState.loaded(announcements: announcements);
        } else {
          state = const AnnouncementsState.empty();
        }
      },
    );
  }

  /// Refresh announcements using if-modified-since
  /// Called on pull-to-refresh - uses stored timestamp
  Future<void> refresh() async {
    final previousData = state.currentData;
    state = AnnouncementsState.loading(previousData: previousData);

    final usecase = _ref.read(fetchAnnouncementsUsecaseProvider);
    final result = await usecase.refresh();

    result.fold(
      (failure) {
        // On error, keep previous data visible with error banner
        state = AnnouncementsState.error(
          failure: failure,
          cachedData: previousData,
        );
      },
      (announcements) {
        if (announcements != null) {
          // Got fresh data (200 OK)
          if (announcements.isNotEmpty) {
            state = AnnouncementsState.loaded(announcements: announcements);
          } else {
            state = const AnnouncementsState.empty();
          }
        } else {
          // 304 Not Modified - keep in-memory data
          if (previousData != null && previousData.isNotEmpty) {
            state = AnnouncementsState.loaded(announcements: previousData);
          } else {
            state = const AnnouncementsState.empty();
          }
        }
      },
    );
  }

  /// Clear state and timestamp
  Future<void> clear() async {
    final repository = _ref.read(homeRepositoryProvider);
    await repository.clearAnnouncementsTimestamp();
    state = const AnnouncementsState.initial();
  }
}
