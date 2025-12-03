import 'package:json_annotation/json_annotation.dart';
import 'package:myapp/features/profile/domain/entities/user_profile.dart';

part 'user_profile_model.g.dart';

/// Infrastructure model for UserProfile with JSON serialization
/// Maps API response from /api/accounts/users/{user-id}/ to domain entity
@JsonSerializable()
class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.email,
    required this.phone,
    required this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.gender,
    this.profilePicture,
    this.profilePicturePath,
    required this.isActive,
    required this.isVerified,
    this.bloodGroup,
    this.parentName,
    this.maritalStatus,
    this.role,
    this.lastLogin,
    this.zoneDetail,
    this.zone,
    this.isAdmin,
    this.isSuperuser,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates model from JSON map
  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);

  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'phone')
  final String phone;

  @JsonKey(name: 'first_name')
  final String firstName;

  @JsonKey(name: 'last_name')
  final String? lastName;

  @JsonKey(name: 'date_of_birth')
  final String? dateOfBirth;

  @JsonKey(name: 'gender')
  final String? gender;

  @JsonKey(name: 'profile_picture')
  final String? profilePicture;

  @JsonKey(name: 'profile_picture_path')
  final String? profilePicturePath;

  @JsonKey(name: 'is_active')
  final bool isActive;

  @JsonKey(name: 'is_verified')
  final bool isVerified;

  @JsonKey(name: 'blood_group')
  final String? bloodGroup;

  @JsonKey(name: 'parent_name')
  final String? parentName;

  @JsonKey(name: 'marital_status')
  final String? maritalStatus;

  @JsonKey(name: 'role')
  final String? role;

  @JsonKey(name: 'last_login')
  final String? lastLogin;

  @JsonKey(name: 'zone_detail')
  final dynamic zoneDetail;

  @JsonKey(name: 'zone')
  final int? zone;

  @JsonKey(name: 'is_admin')
  final bool? isAdmin;

  @JsonKey(name: 'is_superuser')
  final bool? isSuperuser;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  /// Converts model to JSON map
  Map<String, dynamic> toJson() => _$UserProfileModelToJson(this);

  /// Converts to domain entity
  UserProfile toDomain() {
    return UserProfile(
      id: id,
      email: email,
      phone: phone,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: _parseDate(dateOfBirth),
      gender: gender,
      profilePicture: profilePicture,
      profilePicturePath: profilePicturePath,
      isActive: isActive,
      isVerified: isVerified,
      bloodGroup: bloodGroup,
      parentName: parentName,
      maritalStatus: maritalStatus,
      role: role,
      lastLogin: _parseDateTime(lastLogin),
    );
  }

  /// Parses date string from API (format: yyyy-MM-dd)
  static DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Parses datetime string from API (ISO8601 format)
  static DateTime? _parseDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return null;
    try {
      return DateTime.parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }
}
