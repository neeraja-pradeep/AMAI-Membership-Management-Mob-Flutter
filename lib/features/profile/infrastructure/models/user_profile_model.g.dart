// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfileModel _$UserProfileModelFromJson(Map<String, dynamic> json) =>
    UserProfileModel(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      phone: json['phone'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      gender: json['gender'] as String?,
      profilePicture: json['profile_picture'] as String?,
      profilePicturePath: json['profile_picture_path'] as String?,
      isActive: json['is_active'] as bool,
      isVerified: json['is_verified'] as bool,
      bloodGroup: json['blood_group'] as String?,
      parentName: json['parent_name'] as String?,
      maritalStatus: json['marital_status'] as String?,
      role: json['role'] as String?,
      lastLogin: json['last_login'] as String?,
      zoneDetail: json['zone_detail'],
      zone: (json['zone'] as num?)?.toInt(),
      isAdmin: json['is_admin'] as bool?,
      isSuperuser: json['is_superuser'] as bool?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$UserProfileModelToJson(UserProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'phone': instance.phone,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'date_of_birth': instance.dateOfBirth,
      'gender': instance.gender,
      'profile_picture': instance.profilePicture,
      'profile_picture_path': instance.profilePicturePath,
      'is_active': instance.isActive,
      'is_verified': instance.isVerified,
      'blood_group': instance.bloodGroup,
      'parent_name': instance.parentName,
      'marital_status': instance.maritalStatus,
      'role': instance.role,
      'last_login': instance.lastLogin,
      'zone_detail': instance.zoneDetail,
      'zone': instance.zone,
      'is_admin': instance.isAdmin,
      'is_superuser': instance.isSuperuser,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
