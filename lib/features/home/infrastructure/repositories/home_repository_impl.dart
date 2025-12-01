import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fpdart/fpdart.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/core/network/network_exceptions.dart';
import 'package:myapp/features/home/domain/entities/announcement.dart';
import 'package:myapp/features/home/domain/entities/aswas_plus.dart';
import 'package:myapp/features/home/domain/entities/membership_card.dart';
import 'package:myapp/features/home/domain/entities/upcoming_event.dart';
import 'package:myapp/features/home/domain/repositories/home_repository.dart';
import 'package:myapp/features/home/infrastructure/data_sources/local/home_local_ds.dart';
import 'package:myapp/features/home/infrastructure/data_sources/remote/home_api.dart';

/// Implementation of HomeRepository
/// Data is kept in-memory (Riverpod state), only timestamp is persisted in Hive
class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl({
    required this.homeApi,
    required this.localDataSource,
    required this.connectivity,
  });

  final HomeApi homeApi;
  final HomeLocalDataSource localDataSource;
  final Connectivity connectivity;

  // ============== Membership Card ==============

  @override
  Future<Either<Failure, MembershipCard?>> getMembershipCard({
    required int userId,
    String? ifModifiedSince,
  }) async {
    // Check connectivity
    final connectivityResult = await connectivity.checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);

    if (!isOnline) {
      // Offline - return network failure (UI should show in-memory data if available)
      return left(const NetworkFailure());
    }

    try {
      // Online - make API call
      final response = await homeApi.fetchMembershipCard(
        userId: userId,
        ifModifiedSince: ifModifiedSince ?? '',
      );

      // Handle 304 Not Modified
      if (response.isNotModified) {
        return right(null); // Signal to use in-memory data
      }

      // Handle successful response with data
      if (response.isSuccess && response.data != null) {
        final membershipCard = response.data!.toDomain();

        // Store new timestamp for future if-modified-since requests
        if (response.timestamp != null) {
          await storeMembershipTimestamp(response.timestamp!);
        }

        return right(membershipCard);
      }

      // No data returned
      return right(null);
    } on NetworkException catch (e) {
      return left(FailureMapper.fromNetworkException(e));
    } catch (e) {
      return left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<String?> getMembershipTimestamp() async {
    return localDataSource.getMembershipTimestamp();
  }

  @override
  Future<void> storeMembershipTimestamp(String timestamp) async {
    await localDataSource.storeMembershipTimestamp(timestamp);
  }

  @override
  Future<void> clearMembershipTimestamp() async {
    await localDataSource.clearMembershipTimestamp();
  }

  // ============== Aswas Plus ==============

  @override
  Future<Either<Failure, AswasPlus?>> getAswasPlus({
    required int userId,
    String? ifModifiedSince,
  }) async {
    // Check connectivity
    final connectivityResult = await connectivity.checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);

    if (!isOnline) {
      // Offline - return network failure (UI should show in-memory data if available)
      return left(const NetworkFailure());
    }

    try {
      // Online - make API call
      final response = await homeApi.fetchAswasPlus(
        userId: userId,
        ifModifiedSince: ifModifiedSince ?? '',
      );

      // Handle 304 Not Modified
      if (response.isNotModified) {
        return right(null); // Signal to use in-memory data
      }

      // Handle successful response with data
      if (response.isSuccess && response.data != null) {
        final aswasPlus = response.data!.toDomain();

        // Only return if policy is active
        if (!aswasPlus.isActive) {
          return right(null);
        }

        // Store new timestamp for future if-modified-since requests
        if (response.timestamp != null) {
          await storeAswasTimestamp(response.timestamp!);
        }

        return right(aswasPlus);
      }

      // No data returned (no active policy)
      return right(null);
    } on NetworkException catch (e) {
      return left(FailureMapper.fromNetworkException(e));
    } catch (e) {
      return left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<String?> getAswasTimestamp() async {
    return localDataSource.getAswasTimestamp();
  }

  @override
  Future<void> storeAswasTimestamp(String timestamp) async {
    await localDataSource.storeAswasTimestamp(timestamp);
  }

  @override
  Future<void> clearAswasTimestamp() async {
    await localDataSource.clearAswasTimestamp();
  }

  // ============== Events ==============

  @override
  Future<Either<Failure, List<UpcomingEvent>?>> getEvents({
    String? ifModifiedSince,
  }) async {
    // Check connectivity
    final connectivityResult = await connectivity.checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);

    if (!isOnline) {
      // Offline - return network failure (UI should show in-memory data if available)
      return left(const NetworkFailure());
    }

    try {
      // Online - make API call
      final response = await homeApi.fetchEvents(
        ifModifiedSince: ifModifiedSince ?? '',
      );

      // Handle 304 Not Modified
      if (response.isNotModified) {
        return right(null); // Signal to use in-memory data
      }

      // Handle successful response with data
      if (response.isSuccess && response.data != null) {
        final events = response.data!.map((e) => e.toDomain()).toList();

        // Store new timestamp for future if-modified-since requests
        if (response.timestamp != null) {
          await storeEventsTimestamp(response.timestamp!);
        }

        return right(events);
      }

      // No data returned
      return right([]);
    } on NetworkException catch (e) {
      return left(FailureMapper.fromNetworkException(e));
    } catch (e) {
      return left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<String?> getEventsTimestamp() async {
    return localDataSource.getEventsTimestamp();
  }

  @override
  Future<void> storeEventsTimestamp(String timestamp) async {
    await localDataSource.storeEventsTimestamp(timestamp);
  }

  @override
  Future<void> clearEventsTimestamp() async {
    await localDataSource.clearEventsTimestamp();
  }

  // ============== Announcements ==============

  @override
  Future<Either<Failure, List<Announcement>?>> getAnnouncements({
    String? ifModifiedSince,
  }) async {
    // Check connectivity
    final connectivityResult = await connectivity.checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);

    if (!isOnline) {
      // Offline - return network failure (UI should show in-memory data if available)
      return left(const NetworkFailure());
    }

    try {
      // Online - make API call
      final response = await homeApi.fetchAnnouncements(
        ifModifiedSince: ifModifiedSince ?? '',
      );

      // Handle 304 Not Modified
      if (response.isNotModified) {
        return right(null); // Signal to use in-memory data
      }

      // Handle successful response with data
      if (response.isSuccess && response.data != null) {
        final announcements = response.data!.map((e) => e.toDomain()).toList();

        // Store new timestamp for future if-modified-since requests
        if (response.timestamp != null) {
          await storeAnnouncementsTimestamp(response.timestamp!);
        }

        return right(announcements);
      }

      // No data returned
      return right([]);
    } on NetworkException catch (e) {
      return left(FailureMapper.fromNetworkException(e));
    } catch (e) {
      return left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<String?> getAnnouncementsTimestamp() async {
    return localDataSource.getAnnouncementsTimestamp();
  }

  @override
  Future<void> storeAnnouncementsTimestamp(String timestamp) async {
    await localDataSource.storeAnnouncementsTimestamp(timestamp);
  }

  @override
  Future<void> clearAnnouncementsTimestamp() async {
    await localDataSource.clearAnnouncementsTimestamp();
  }

  // ============== Clear All ==============

  @override
  Future<void> clearAllTimestamps() async {
    await localDataSource.clearAllTimestamps();
  }
}
