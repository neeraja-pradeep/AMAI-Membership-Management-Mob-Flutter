// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      success: json['success'] as bool,
      sessionId: json['session_id'] as String?,
      xcsrfToken: json['xcsrf_token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      expiresAt: json['expires_at'] as String,
      ifModifiedSince: json['if_modified_since'] as String?,
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'session_id': instance.sessionId,
      'xcsrf_token': instance.xcsrfToken,
      'user': instance.user,
      'expires_at': instance.expiresAt,
      'if_modified_since': instance.ifModifiedSince,
    };
