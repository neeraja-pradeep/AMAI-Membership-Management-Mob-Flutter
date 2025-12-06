import 'package:json_annotation/json_annotation.dart';
import 'package:myapp/features/home/domain/entities/membership_card.dart';

part 'membership_card_model.g.dart';

/// Infrastructure model for MembershipCard with JSON serialization
/// Maps API response to domain entity
@JsonSerializable()
class MembershipCardModel {
  const MembershipCardModel({
    required this.id,
    required this.membershipNumber,
    required this.userFirstName,
    required this.endDate,
    required this.status,
    this.user,
    this.membershipType,
    this.startDate,
    this.createdAt,
    this.updatedAt,
    this.academicDetails,
  });

  /// Computed property to check if membership is active
  bool get isActive => status.toLowerCase() == 'active';

  /// Creates model from JSON map
  factory MembershipCardModel.fromJson(Map<String, dynamic> json) =>
      _$MembershipCardModelFromJson(json);

  @JsonKey(name: 'id', defaultValue: 0)
  final int id;

  @JsonKey(name: 'membership_number')
  final String membershipNumber;

  @JsonKey(name: 'user_first_name')
  final String userFirstName;

  @JsonKey(name: 'end_date')
  final String endDate;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'user')
  final int? user;

  @JsonKey(name: 'membership_type')
  final String? membershipType;

  @JsonKey(name: 'start_date')
  final String? startDate;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @JsonKey(name: 'academic_details')
  final List<String>? academicDetails;

  /// Converts model to JSON map
  Map<String, dynamic> toJson() => _$MembershipCardModelToJson(this);

  /// Converts to domain entity
  MembershipCard toDomain() {
    return MembershipCard(
      id: id.toString(),
      holderName: userFirstName,
      membershipNumber: membershipNumber,
      validUntil: _parseDate(endDate),
      isActive: isActive,
      userId: user,
      membershipType: membershipType,
      startDate: startDate != null ? _parseDate(startDate!) : null,
      academicDetails: academicDetails,
    );
  }

  /// Parses date string from API (format: yyyy-MM-dd)
  static DateTime _parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      // Return current date as fallback
      return DateTime.now();
    }
  }
}

/// Response wrapper for membership detail endpoint
/// Extracts membership data from the nested response structure
/// Also handles error responses with application_status field
@JsonSerializable()
class MembershipDetailResponse {
  const MembershipDetailResponse({
    this.membership,
    this.error,
    this.applicationStatus,
  });

  factory MembershipDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$MembershipDetailResponseFromJson(json);

  @JsonKey(name: 'membership')
  final MembershipCardModel? membership;

  @JsonKey(name: 'error')
  final String? error;

  @JsonKey(name: 'application_status')
  final String? applicationStatus;

  /// Check if this is a pending application response
  bool get isPendingApplication =>
      applicationStatus?.toLowerCase() == 'pending';

  /// Check if this is a rejected application response
  bool get isRejectedApplication =>
      applicationStatus?.toLowerCase() == 'rejected';

  Map<String, dynamic> toJson() => _$MembershipDetailResponseToJson(this);
}
