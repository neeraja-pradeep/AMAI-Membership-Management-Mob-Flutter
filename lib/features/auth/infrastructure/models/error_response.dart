import 'package:freezed_annotation/freezed_annotation.dart';

part 'error_response.freezed.dart';
part 'error_response.g.dart';

/// Error response DTO
///
/// Received from API when request fails
@freezed
class ErrorResponse with _$ErrorResponse {
  const ErrorResponse._();

  const factory ErrorResponse({
    @JsonKey(name: 'error_code') required String errorCode,
    @JsonKey(name: 'error_message') required String errorMessage,
    @JsonKey(name: 'field_errors') Map<String, List<String>>? fieldErrors,
    @JsonKey(name: 'retry_after') int? retryAfter,
  }) = _ErrorResponse;

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);

  /// Get user-friendly message
  String get userMessage {
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      final firstError = fieldErrors!.values.first.first;
      return firstError;
    }
    return errorMessage;
  }

  /// Check if should retry request
  bool get shouldRetry => retryAfter != null && retryAfter! > 0;
}
