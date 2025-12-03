import 'package:myapp/core/network/api_client.dart';
import 'package:myapp/core/network/endpoints.dart';
import 'package:myapp/features/membership/infrastructure/models/membership_status_model.dart';

/// Abstract class defining the membership API contract
abstract class MembershipApi {
  /// Fetches membership status for a user
  ///
  /// [userId] - The user ID to fetch membership for
  /// [ifModifiedSince] - Optional timestamp for conditional request
  ///
  /// Returns ApiResponse with MembershipStatusModel on success,
  /// null on 304 Not Modified
  Future<ApiResponse<MembershipStatusModel?>> fetchMembershipStatus({
    required int userId,
    String? ifModifiedSince,
  });
}

/// Implementation of MembershipApi using ApiClient
class MembershipApiImpl implements MembershipApi {
  const MembershipApiImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<ApiResponse<MembershipStatusModel?>> fetchMembershipStatus({
    required int userId,
    String? ifModifiedSince,
  }) async {
    final response = await apiClient.get<MembershipStatusModel?>(
      Endpoints.membershipByUserId(userId),
      ifModifiedSince: ifModifiedSince,
      fromJson: (json) {
        if (json == null) return null;
        final data = json as Map<String, dynamic>;
        // Extract nested 'membership' object from response
        final membershipData = data['membership'] as Map<String, dynamic>?;
        if (membershipData == null) return null;
        return MembershipStatusModel.fromJson(membershipData);
      },
    );

    return response;
  }
}
