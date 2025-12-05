import 'package:myapp/core/network/api_client.dart';
import 'package:myapp/core/network/endpoints.dart';
import 'package:myapp/features/profile/infrastructure/models/user_profile_model.dart';

/// Abstract interface for Profile API operations
abstract class ProfileApi {
  /// Fetches user profile by ID
  ///
  /// [userId] - The user ID to fetch profile for
  ///
  /// Returns ApiResponse containing:
  /// - UserProfileModel on success (200)
  /// - null data on error
  Future<ApiResponse<UserProfileModel>> fetchUserProfile({
    required int userId,
  });

  /// Updates user personal information
  ///
  /// [userId] - The user ID to update
  /// [data] - Map containing the fields to update
  ///
  /// Returns ApiResponse containing:
  /// - Updated UserProfileModel on success (200)
  /// - null data on error
  Future<ApiResponse<UserProfileModel>> updatePersonalInfo({
    required int userId,
    required Map<String, dynamic> data,
  });
}

/// Implementation of ProfileApi using ApiClient
class ProfileApiImpl implements ProfileApi {
  const ProfileApiImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<ApiResponse<UserProfileModel>> fetchUserProfile({
    required int userId,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      Endpoints.userProfile(userId),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    // Parse the response
    UserProfileModel? userProfile;

    if (response.data != null) {
      userProfile = UserProfileModel.fromJson(response.data!);
    }

    return ApiResponse<UserProfileModel>(
      data: userProfile,
      statusCode: response.statusCode,
      timestamp: response.timestamp,
    );
  }

  @override
  Future<ApiResponse<UserProfileModel>> updatePersonalInfo({
    required int userId,
    required Map<String, dynamic> data,
  }) async {
    final response = await apiClient.patch<Map<String, dynamic>>(
      Endpoints.userProfile(userId),
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    // Parse the response
    UserProfileModel? userProfile;

    if (response.data != null) {
      userProfile = UserProfileModel.fromJson(response.data!);
    }

    return ApiResponse<UserProfileModel>(
      data: userProfile,
      statusCode: response.statusCode,
      timestamp: response.timestamp,
    );
  }
}
