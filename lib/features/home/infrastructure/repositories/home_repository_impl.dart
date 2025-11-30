import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fpdart/fpdart.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/core/network/network_exceptions.dart';
import 'package:myapp/features/home/domain/entities/membership_card.dart';
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
  Future<String?> getStoredTimestamp() async {
    return localDataSource.getTimestamp();
  }

  @override
  Future<void> storeTimestamp(String timestamp) async {
    await localDataSource.storeTimestamp(timestamp);
  }

  @override
  Future<void> clearTimestamp() async {
    await localDataSource.clearTimestamp();
  }
}
