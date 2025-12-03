import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fpdart/fpdart.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/core/network/network_exceptions.dart';
import 'package:myapp/features/home/infrastructure/data_sources/remote/home_api.dart';
import 'package:myapp/features/profile/domain/entities/membership_type.dart';
import 'package:myapp/features/profile/domain/entities/profile_data.dart';
import 'package:myapp/features/profile/domain/entities/user_profile.dart';
import 'package:myapp/features/profile/domain/repositories/profile_repository.dart';
import 'package:myapp/features/profile/infrastructure/data_sources/remote/profile_api.dart';

/// Implementation of ProfileRepository
class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({
    required this.profileApi,
    required this.homeApi,
    required this.connectivity,
  });

  final ProfileApi profileApi;
  final HomeApi homeApi;
  final Connectivity connectivity;

  @override
  Future<Either<Failure, UserProfile>> getUserProfile({
    required int userId,
  }) async {
    // Check connectivity
    final connectivityResult = await connectivity.checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);

    if (!isOnline) {
      return left(const NetworkFailure());
    }

    try {
      final response = await profileApi.fetchUserProfile(userId: userId);

      if (response.isSuccess && response.data != null) {
        return right(response.data!.toDomain());
      }

      return left(const ServerFailure(message: 'Failed to load user profile'));
    } on NetworkException catch (e) {
      return left(FailureMapper.fromNetworkException(e));
    } catch (e) {
      return left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, ProfileData>> getProfileData({
    required int userId,
  }) async {
    // Check connectivity
    final connectivityResult = await connectivity.checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);

    if (!isOnline) {
      return left(const NetworkFailure());
    }

    try {
      // Fetch user profile and membership data in parallel
      final results = await Future.wait([
        profileApi.fetchUserProfile(userId: userId),
        homeApi.fetchMembershipCard(ifModifiedSince: ''),
      ]);

      final userProfileResponse = results[0];
      final membershipResponse = results[1];

      if (!userProfileResponse.isSuccess || userProfileResponse.data == null) {
        return left(const ServerFailure(message: 'Failed to load user profile'));
      }

      final userProfile = userProfileResponse.data!.toDomain();

      // Extract membership type from membership response
      MembershipType membershipType = MembershipType.practitioner;
      String? membershipNumber;
      String? membershipStatus;
      DateTime? validUntil;

      if (membershipResponse.isSuccess && membershipResponse.data != null) {
        final membership = membershipResponse.data!;
        membershipType = MembershipType.fromString(membership.membershipType);
        membershipNumber = membership.membershipNumber;
        membershipStatus = membership.status;
        try {
          validUntil = DateTime.parse(membership.endDate);
        } catch (_) {}
      }

      return right(ProfileData(
        userProfile: userProfile,
        membershipType: membershipType,
        membershipNumber: membershipNumber,
        membershipStatus: membershipStatus,
        validUntil: validUntil,
      ));
    } on NetworkException catch (e) {
      return left(FailureMapper.fromNetworkException(e));
    } catch (e) {
      return left(FailureMapper.fromException(e));
    }
  }
}
