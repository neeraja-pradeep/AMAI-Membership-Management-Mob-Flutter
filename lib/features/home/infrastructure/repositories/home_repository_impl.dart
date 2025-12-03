import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fpdart/fpdart.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/core/network/network_exceptions.dart';
import 'package:myapp/features/aswas_plus/domain/entities/digital_product.dart';
import 'package:myapp/features/aswas_plus/domain/entities/nominee.dart';
import 'package:myapp/features/aswas_plus/domain/entities/renewal_response.dart';
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
        ifModifiedSince: ifModifiedSince ?? '',
      );

      // Handle 304 Not Modified
      if (response.isNotModified) {
        return right(null); // Signal to use in-memory data
      }

      // Handle successful response with data
      if (response.isSuccess && response.data != null) {
        final aswasPlus = response.data!.toDomain();

        // Return policy if active or inactive (show details for both)
        if (!aswasPlus.isActive && !aswasPlus.isExpired) {
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

  // ============== Nominees ==============

  @override
  Future<Either<Failure, List<Nominee>?>> getNominees({
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
      final response = await homeApi.fetchNominees(
        ifModifiedSince: ifModifiedSince ?? '',
      );

      // Handle 304 Not Modified
      if (response.isNotModified) {
        return right(null); // Signal to use in-memory data
      }

      // Handle successful response with data
      if (response.isSuccess && response.data != null) {
        final nominees = response.data!.map((e) => e.toDomain()).toList();

        // Store new timestamp for future if-modified-since requests
        if (response.timestamp != null) {
          await storeNomineesTimestamp(response.timestamp!);
        }

        return right(nominees);
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
  Future<String?> getNomineesTimestamp() async {
    return localDataSource.getNomineesTimestamp();
  }

  @override
  Future<void> storeNomineesTimestamp(String timestamp) async {
    await localDataSource.storeNomineesTimestamp(timestamp);
  }

  @override
  Future<void> clearNomineesTimestamp() async {
    await localDataSource.clearNomineesTimestamp();
  }

  // ============== Digital Products ==============

  @override
  Future<Either<Failure, DigitalProduct?>> getDigitalProduct({
    required int productId,
  }) async {
    // Check connectivity
    final connectivityResult = await connectivity.checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);

    if (!isOnline) {
      return left(const NetworkFailure());
    }

    try {
      final response = await homeApi.fetchDigitalProduct(productId: productId);

      if (response.isSuccess && response.data != null) {
        return right(response.data!.toDomain());
      }

      return right(null);
    } on NetworkException catch (e) {
      return left(FailureMapper.fromNetworkException(e));
    } catch (e) {
      return left(FailureMapper.fromException(e));
    }
  }

  // ============== Insurance Renewal ==============

  @override
  Future<Either<Failure, RenewalResponse?>> initiateInsuranceRenewal() async {
    // Check connectivity
    final connectivityResult = await connectivity.checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);

    if (!isOnline) {
      return left(const NetworkFailure());
    }

    try {
      final response = await homeApi.initiateInsuranceRenewal();

      if (response.isSuccess && response.data != null) {
        return right(response.data!.toDomain());
      }

      return right(null);
    } on NetworkException catch (e) {
      return left(FailureMapper.fromNetworkException(e));
    } catch (e) {
      return left(FailureMapper.fromException(e));
    }
  }

  // ============== Payment Verification ==============

  @override
  Future<Either<Failure, bool>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    // Check connectivity
    final connectivityResult = await connectivity.checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);

    if (!isOnline) {
      return left(const NetworkFailure());
    }

    try {
      final response = await homeApi.verifyPayment(
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      );

      if (response.isSuccess) {
        return right(true);
      }

      return right(false);
    } on NetworkException catch (e) {
      return left(FailureMapper.fromNetworkException(e));
    } catch (e) {
      return left(FailureMapper.fromException(e));
    }
  }

  // ============== Clear All ==============

  @override
  Future<void> clearAllTimestamps() async {
    await localDataSource.clearAllTimestamps();
  }
}
