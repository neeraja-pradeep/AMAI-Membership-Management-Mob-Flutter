// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SessionModelImpl _$$SessionModelImplFromJson(Map<String, dynamic> json) =>
    _$SessionModelImpl(
      sessionId: json['session_id'] as String,
      xcsrfToken: json['xcsrf_token'] as String,
      expiresAt: json['expires_at'] as String,
      ifModifiedSince: json['if_modified_since'] as String?,
    );

Map<String, dynamic> _$$SessionModelImplToJson(_$SessionModelImpl instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'xcsrf_token': instance.xcsrfToken,
      'expires_at': instance.expiresAt,
      'if_modified_since': instance.ifModifiedSince,
    };
