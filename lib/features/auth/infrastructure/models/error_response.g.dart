// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ErrorResponseImpl _$$ErrorResponseImplFromJson(Map<String, dynamic> json) =>
    _$ErrorResponseImpl(
      errorCode: json['error_code'] as String,
      errorMessage: json['error_message'] as String,
      fieldErrors: (json['field_errors'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
      retryAfter: (json['retry_after'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ErrorResponseImplToJson(_$ErrorResponseImpl instance) =>
    <String, dynamic>{
      'error_code': instance.errorCode,
      'error_message': instance.errorMessage,
      'field_errors': instance.fieldErrors,
      'retry_after': instance.retryAfter,
    };
