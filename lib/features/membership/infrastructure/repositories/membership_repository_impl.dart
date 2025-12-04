import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fpdart/fpdart.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/core/network/network_exceptions.dart';
import 'package:myapp/features/membership/domain/entities/membership_payment_response.dart';
import 'package:myapp/features/membership/domain/entities/membership_status.dart';
import 'package:myapp/features/membership/domain/repositories/membership_repository.dart';
import 'package:myapp/features/membership/infrastructure/data_sources/local/membership_local_ds.dart';
import 'package:myapp/features/membership/infrastructure/data_sources/remote/membership_api.dart';

/// Implementation of MembershipRepository
/// Handles API calls, caching logic, and connectivity checks
class MembershipRepositoryImpl implements MembershipRepository {
  const MembershipRepositoryImpl({
    required this.membershipApi,
    required this.localDataSource,
    required this.connectivity,
  });

  final MembershipApi membershipApi;
  final MembershipLocalDataSource localDataSource;
  final Connectivity connectivity;

  @override
  Future<Either<Failure, MembershipStatus?>> getMembershipStatus({
    String? ifModifiedSince,
  }) async {
    try {
      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure());
      }

      // Make API call
      final response = await membershipApi.fetchMembershipStatus(
        ifModifiedSince: ifModifiedSince,
      );

      // Handle 304 Not Modified
      if (response.isNotModified) {
        return const Right(null);
      }

      // Handle successful response
      if (response.isSuccess && response.data != null) {
        // Store the new timestamp
        if (response.timestamp != null) {
          await storeTimestamp(response.timestamp!);
        }

        // Convert to domain entity
        return Right(response.data!.toDomain());
      }

      // Handle empty response
      return const Left(
        ServerFailure(message: 'No membership data found'),
      );
    } on NetworkException catch (e) {
      return Left(FailureMapper.fromNetworkException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
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

  @override
  Future<Either<Failure, MembershipPaymentResponse>> initiateMembershipPayment({
    required int userId,
  }) async {
    try {
      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure());
      }

      // Make API call
      final response = await membershipApi.initiateMembershipPayment(
        userId: userId,
      );

      // Handle successful response
      if (response.isSuccess && response.data != null) {
        return Right(response.data!.toDomain());
      }

      // Handle empty response
      return const Left(
        ServerFailure(message: 'Failed to initiate payment'),
      );
    } on NetworkException catch (e) {
      return Left(FailureMapper.fromNetworkException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyMembershipPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure());
      }

      // Make API call
      final response = await membershipApi.verifyMembershipPayment(
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      );

      // Handle successful response
      if (response.isSuccess) {
        return const Right(true);
      }

      // Handle failure
      return const Left(
        ServerFailure(message: 'Payment verification failed'),
      );
    } on NetworkException catch (e) {
      return Left(FailureMapper.fromNetworkException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
