import 'package:fpdart/fpdart.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/features/profile/domain/entities/profile_data.dart';
import 'package:myapp/features/profile/domain/entities/user_profile.dart';

/// Abstract repository contract for profile feature
abstract class ProfileRepository {
  /// Fetches user profile data
  ///
  /// [userId] - The user ID to fetch profile for
  ///
  /// Returns:
  /// - Right(UserProfile) on success
  /// - Left(Failure) on error
  Future<Either<Failure, UserProfile>> getUserProfile({
    required int userId,
  });

  /// Fetches complete profile data (user + membership info)
  ///
  /// [userId] - The user ID to fetch profile for
  ///
  /// Returns:
  /// - Right(ProfileData) on success
  /// - Left(Failure) on error
  Future<Either<Failure, ProfileData>> getProfileData({
    required int userId,
  });
}
