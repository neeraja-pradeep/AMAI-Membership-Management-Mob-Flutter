import 'package:json_annotation/json_annotation.dart';

part 'area_admin_model.g.dart';

/// User detail model containing admin information
@JsonSerializable()
class UserDetailModel {
  const UserDetailModel({
    required this.id,
    required this.email,
    required this.phone,
    required this.firstName,
    required this.groupsName,
    this.lastName,
    this.waPhone,
  });

  factory UserDetailModel.fromJson(Map<String, dynamic> json) =>
      _$UserDetailModelFromJson(json);

  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'phone')
  final String phone;

  @JsonKey(name: 'wa_phone')
  final String? waPhone;

  @JsonKey(name: 'first_name')
  final String firstName;

  @JsonKey(name: 'last_name')
  final String? lastName;

  @JsonKey(name: 'groups_name')
  final List<String> groupsName;

  Map<String, dynamic> toJson() => _$UserDetailModelToJson(this);
}

/// Area admin model containing admin details
@JsonSerializable()
class AreaAdminModel {
  const AreaAdminModel({
    required this.id,
    required this.user,
    required this.zone,
    required this.userDetail,
  });

  factory AreaAdminModel.fromJson(Map<String, dynamic> json) =>
      _$AreaAdminModelFromJson(json);

  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'user')
  final int user;

  @JsonKey(name: 'zone')
  final int zone;

  @JsonKey(name: 'user_detail')
  final UserDetailModel userDetail;

  Map<String, dynamic> toJson() => _$AreaAdminModelToJson(this);
}

/// Response wrapper for area admins API
@JsonSerializable()
class AreaAdminsResponse {
  const AreaAdminsResponse({
    required this.userAreaAdmins,
    required this.parentAreaAdmins,
    this.userZone,
    this.parentZone,
  });

  factory AreaAdminsResponse.fromJson(Map<String, dynamic> json) =>
      _$AreaAdminsResponseFromJson(json);

  @JsonKey(name: 'user_area_admins')
  final List<AreaAdminModel> userAreaAdmins;

  @JsonKey(name: 'parent_area_admins')
  final List<AreaAdminModel> parentAreaAdmins;

  @JsonKey(name: 'user_zone')
  final String? userZone;

  @JsonKey(name: 'parent_zone')
  final String? parentZone;

  Map<String, dynamic> toJson() => _$AreaAdminsResponseToJson(this);

  /// Get all area admins (both user and parent admins combined)
  List<AreaAdminModel> get allAdmins => [
        ...userAreaAdmins,
        ...parentAreaAdmins,
      ];
}
