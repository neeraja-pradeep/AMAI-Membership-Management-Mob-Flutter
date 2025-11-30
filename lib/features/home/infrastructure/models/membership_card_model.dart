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
    required this.isActive,
    this.membershipType,
    this.startDate,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates model from JSON map
  factory MembershipCardModel.fromJson(Map<String, dynamic> json) =>
      _$MembershipCardModelFromJson(json);

  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'membership_number')
  final String membershipNumber;

  @JsonKey(name: 'user_first_name')
  final String userFirstName;

  @JsonKey(name: 'end_date')
  final String endDate;

  @JsonKey(name: 'is_active')
  final bool isActive;

  @JsonKey(name: 'membership_type')
  final String? membershipType;

  @JsonKey(name: 'start_date')
  final String? startDate;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

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
      membershipType: membershipType,
      startDate: startDate != null ? _parseDate(startDate!) : null,
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

/// Response wrapper for paginated membership list
@JsonSerializable()
class MembershipListResponse {
  const MembershipListResponse({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  factory MembershipListResponse.fromJson(Map<String, dynamic> json) =>
      _$MembershipListResponseFromJson(json);

  @JsonKey(name: 'count')
  final int count;

  @JsonKey(name: 'results')
  final List<MembershipCardModel> results;

  @JsonKey(name: 'next')
  final String? next;

  @JsonKey(name: 'previous')
  final String? previous;

  Map<String, dynamic> toJson() => _$MembershipListResponseToJson(this);

  /// Gets the first membership card (for current user's membership)
  MembershipCardModel? get firstMembership =>
      results.isNotEmpty ? results.first : null;
}
