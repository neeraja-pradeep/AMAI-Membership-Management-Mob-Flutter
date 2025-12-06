import 'package:fpdart/fpdart.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/features/profile/domain/entities/profile_data.dart';
import 'package:myapp/features/profile/domain/entities/user_profile.dart';

/// Abstract repository contract for profile feature
abstract class ProfileRepository {
  /// Fetches current user profile data (session-based)
  ///
  /// Uses the authenticated session to get the current user's profile
  ///
  /// Returns:
  /// - Right(ProfileData) on success
  /// - Left(Failure) on error
  Future<Either<Failure, ProfileData>> getCurrentProfileData();

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

  /// Updates user personal information
  ///
  /// [userId] - The user ID to update
  /// [data] - Map containing the fields to update:
  ///   - first_name: User's first name
  ///   - email: User's email address
  ///   - phone: User's phone number
  ///   - wa_phone: User's WhatsApp number
  ///   - date_of_birth: User's date of birth (YYYY-MM-DD format)
  ///   - gender: User's gender
  ///   - blood_group: User's blood group
  ///
  /// Returns:
  /// - Right(true) on success
  /// - Left(Failure) on error
  Future<Either<Failure, bool>> updatePersonalInfo({
    required int userId,
    required Map<String, dynamic> data,
  });
}
