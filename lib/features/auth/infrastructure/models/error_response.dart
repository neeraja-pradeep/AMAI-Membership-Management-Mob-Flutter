import 'package:json_annotation/json_annotation.dart';

part 'error_response.g.dart';

/// Error response DTO
///
/// Received from API when request fails
@JsonSerializable()
class ErrorResponse {
  @JsonKey(name: 'error_code')
  final String? errorCode;

  @JsonKey(name: 'error_message')
  final String? errorMessage;

  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'detail')
  final String? detail;

  @JsonKey(name: 'field_errors')
  final Map<String, List<String>>? fieldErrors;

  @JsonKey(name: 'errors')
  final Map<String, dynamic>? errors;

  @JsonKey(name: 'retry_after')
  final int? retryAfter;

  const ErrorResponse({
    this.errorCode,
    this.errorMessage,
    this.message,
    this.detail,
    this.fieldErrors,
    this.errors,
    this.retryAfter,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);

  /// Get user-friendly message
  String get userMessage {
    // Priority: field errors → message → errorMessage → detail → generic
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      final firstError = fieldErrors!.values.first.first;
      return firstError;
    }

    if (errors != null && errors!.isNotEmpty) {
      final firstError = errors!.values.first;
      if (firstError is List && firstError.isNotEmpty) {
        return firstError.first.toString();
      }
      return firstError.toString();
    }

    return message ?? errorMessage ?? detail ?? 'An error occurred';
  }

  /// Check if should retry request
  bool get shouldRetry => retryAfter != null && retryAfter! > 0;

  /// Get field-specific error message
  String? getFieldError(String fieldName) {
    if (fieldErrors != null && fieldErrors!.containsKey(fieldName)) {
      final errors = fieldErrors![fieldName];
      return errors != null && errors.isNotEmpty ? errors.first : null;
    }

    if (errors != null && errors!.containsKey(fieldName)) {
      final error = errors![fieldName];
      if (error is List && error.isNotEmpty) {
        return error.first.toString();
      }
      return error.toString();
    }

    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorResponse &&
          runtimeType == other.runtimeType &&
          errorCode == other.errorCode &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => errorCode.hashCode ^ errorMessage.hashCode;
}
