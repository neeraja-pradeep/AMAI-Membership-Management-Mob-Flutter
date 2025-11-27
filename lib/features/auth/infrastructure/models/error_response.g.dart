// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrorResponse _$ErrorResponseFromJson(Map<String, dynamic> json) =>
    ErrorResponse(
      errorCode: json['error_code'] as String?,
      errorMessage: json['error_message'] as String?,
      message: json['message'] as String?,
      detail: json['detail'] as String?,
      fieldErrors: (json['field_errors'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
      errors: json['errors'] as Map<String, dynamic>?,
      retryAfter: (json['retry_after'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ErrorResponseToJson(ErrorResponse instance) =>
    <String, dynamic>{
      'error_code': instance.errorCode,
      'error_message': instance.errorMessage,
      'message': instance.message,
      'detail': instance.detail,
      'field_errors': instance.fieldErrors,
      'errors': instance.errors,
      'retry_after': instance.retryAfter,
    };
