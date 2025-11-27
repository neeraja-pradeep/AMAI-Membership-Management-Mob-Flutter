// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionModel _$SessionModelFromJson(Map<String, dynamic> json) => SessionModel(
      xcsrfToken: json['xcsrf_token'] as String,
      expiresAt: json['expires_at'] as String,
      ifModifiedSince: json['if_modified_since'] as String?,
    );

Map<String, dynamic> _$SessionModelToJson(SessionModel instance) =>
    <String, dynamic>{
      'xcsrf_token': instance.xcsrfToken,
      'expires_at': instance.expiresAt,
      'if_modified_since': instance.ifModifiedSince,
    };
