import 'package:json_annotation/json_annotation.dart';
import 'package:myapp/features/membership/domain/entities/membership_status.dart';

part 'membership_status_model.g.dart';

/// Infrastructure model for MembershipStatus with JSON serialization
/// Maps API response to domain entity
@JsonSerializable()
class MembershipStatusModel {
  const MembershipStatusModel({
    required this.id,
    required this.membershipNumber,
    required this.userFirstName,
    required this.endDate,
    required this.status,
    this.membershipType,
    this.startDate,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  /// Computed property to check if membership is active
  bool get isActive => status.toLowerCase() == 'active';

  /// Creates model from JSON map
  factory MembershipStatusModel.fromJson(Map<String, dynamic> json) =>
      _$MembershipStatusModelFromJson(json);

  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'membership_number')
  final String membershipNumber;

  @JsonKey(name: 'user_first_name')
  final String userFirstName;

  @JsonKey(name: 'end_date')
  final String endDate;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'membership_type')
  final String? membershipType;

  @JsonKey(name: 'start_date')
  final String? startDate;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @JsonKey(name: 'user')
  final int? user;

  /// Converts model to JSON map
  Map<String, dynamic> toJson() => _$MembershipStatusModelToJson(this);

  /// Converts to domain entity
  MembershipStatus toDomain() {
    return MembershipStatus(
      id: id.toString(),
      isActive: isActive,
      membershipType: membershipType ?? 'unknown',
      validUntil: _parseDate(endDate),
      memberName: userFirstName,
      membershipNumber: membershipNumber,
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
