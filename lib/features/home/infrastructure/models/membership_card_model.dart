import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:myapp/features/home/domain/entities/membership_card.dart';

part 'membership_card_model.g.dart';

/// Infrastructure model for MembershipCard with JSON serialization
/// Maps API response to domain entity
@JsonSerializable()
@HiveType(typeId: 1)
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

  @HiveField(0)
  @JsonKey(name: 'id')
  final int id;

  @HiveField(1)
  @JsonKey(name: 'membership_number')
  final String membershipNumber;

  @HiveField(2)
  @JsonKey(name: 'user_first_name')
  final String userFirstName;

  @HiveField(3)
  @JsonKey(name: 'end_date')
  final String endDate;

  @HiveField(4)
  @JsonKey(name: 'is_active')
  final bool isActive;

  @HiveField(5)
  @JsonKey(name: 'membership_type')
  final String? membershipType;

  @HiveField(6)
  @JsonKey(name: 'start_date')
  final String? startDate;

  @HiveField(7)
  @JsonKey(name: 'created_at')
  final String? createdAt;

  @HiveField(8)
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

  /// Creates model from domain entity (for caching)
  factory MembershipCardModel.fromDomain(MembershipCard entity) {
    return MembershipCardModel(
      id: int.tryParse(entity.id) ?? 0,
      membershipNumber: entity.membershipNumber,
      userFirstName: entity.holderName,
      endDate: _formatDate(entity.validUntil),
      isActive: entity.isActive,
      membershipType: entity.membershipType,
      startDate: entity.startDate != null ? _formatDate(entity.startDate!) : null,
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

  /// Formats date to API format
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
