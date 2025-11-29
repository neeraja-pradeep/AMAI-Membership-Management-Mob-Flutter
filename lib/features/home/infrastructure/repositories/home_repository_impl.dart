import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fpdart/fpdart.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/core/network/network_exceptions.dart';
import 'package:myapp/features/home/domain/entities/membership_card.dart';
import 'package:myapp/features/home/domain/repositories/home_repository.dart';
import 'package:myapp/features/home/infrastructure/data_sources/local/home_local_ds.dart';
import 'package:myapp/features/home/infrastructure/data_sources/remote/home_api.dart';
import 'package:myapp/features/home/infrastructure/models/membership_card_model.dart';

/// Implementation of HomeRepository
/// Handles API calls, caching, and if-modified-since logic
class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl({
    required this.homeApi,
    required this.localDataSource,
    required this.connectivity,
  });

  final HomeApi homeApi;
  final HomeLocalDataSource localDataSource;
  final Connectivity connectivity;

  @override
  Future<Either<Failure, MembershipCard?>> getMembershipCard({
    required String ifModifiedSince,
  }) async {
    // Check connectivity
    final connectivityResult = await connectivity.checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);

    if (!isOnline) {
      // Offline - return cached data
      final cachedResult = await getCachedMembershipCard();
      return cachedResult.fold(
        (failure) => left(const NetworkFailure()),
        (cachedCard) {
          if (cachedCard != null) {
            return right(cachedCard);
          }
          return left(const NetworkFailure(
            message: 'No cached data available while offline.',
          ));
        },
      );
    }

    try {
      // Online - make API call
      final response = await homeApi.fetchMembershipCard(
        ifModifiedSince: ifModifiedSince,
      );

      // Handle 304 Not Modified
      if (response.isNotModified) {
        return right(null); // Signal to use cached data
      }

      // Handle successful response with data
      if (response.isSuccess && response.data != null) {
        final membershipCard = response.data!.toDomain();

        // Cache the new data
        await cacheMembershipCard(membershipCard);

        // Store new timestamp
        if (response.timestamp != null) {
          await storeTimestamp(response.timestamp!);
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
  Future<Either<Failure, MembershipCard?>> getCachedMembershipCard() async {
    try {
      final cachedModel = await localDataSource.getCachedMembershipCard();

      if (cachedModel == null) {
        return right(null);
      }

      return right(cachedModel.toDomain());
    } catch (e) {
      return left(const CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> cacheMembershipCard(MembershipCard card) async {
    try {
      final model = MembershipCardModel.fromDomain(card);
      await localDataSource.cacheMembershipCard(model);
      return right(unit);
    } catch (e) {
      return left(const CacheFailure(
        message: 'Failed to cache membership card.',
      ));
    }
  }

  @override
  Future<String?> getStoredTimestamp() async {
    return localDataSource.getTimestamp();
  }

  @override
  Future<void> storeTimestamp(String timestamp) async {
    await localDataSource.storeTimestamp(timestamp);
  }

  @override
  Future<void> clearCache() async {
    await localDataSource.clearCache();
  }
}
