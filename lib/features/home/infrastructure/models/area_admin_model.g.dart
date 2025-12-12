// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'area_admin_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDetailModel _$UserDetailModelFromJson(Map<String, dynamic> json) =>
    UserDetailModel(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      phone: json['phone'] as String,
      firstName: json['first_name'] as String,
      groupsName: (json['groups_name'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      lastName: json['last_name'] as String?,
      waPhone: json['wa_phone'] as String?,
    );

Map<String, dynamic> _$UserDetailModelToJson(UserDetailModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'phone': instance.phone,
      'wa_phone': instance.waPhone,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'groups_name': instance.groupsName,
    };

AreaAdminModel _$AreaAdminModelFromJson(Map<String, dynamic> json) =>
    AreaAdminModel(
      id: (json['id'] as num).toInt(),
      user: (json['user'] as num).toInt(),
      zone: (json['zone'] as num).toInt(),
      userDetail:
          UserDetailModel.fromJson(json['user_detail'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AreaAdminModelToJson(AreaAdminModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'zone': instance.zone,
      'user_detail': instance.userDetail,
    };

AreaAdminsResponse _$AreaAdminsResponseFromJson(Map<String, dynamic> json) =>
    AreaAdminsResponse(
      userAreaAdmins: (json['user_area_admins'] as List<dynamic>)
          .map((e) => AreaAdminModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      parentAreaAdmins: (json['parent_area_admins'] as List<dynamic>)
          .map((e) => AreaAdminModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      userZone: json['user_zone'] as String?,
      parentZone: json['parent_zone'] as String?,
    );

Map<String, dynamic> _$AreaAdminsResponseToJson(
        AreaAdminsResponse instance) =>
    <String, dynamic>{
      'user_area_admins': instance.userAreaAdmins,
      'parent_area_admins': instance.parentAreaAdmins,
      'user_zone': instance.userZone,
      'parent_zone': instance.parentZone,
    };
