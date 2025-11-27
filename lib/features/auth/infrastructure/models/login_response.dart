import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'login_response.freezed.dart';
part 'login_response.g.dart';

/// Login response DTO
///
/// Received from API after successful authentication
@freezed
class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required bool success,
    @JsonKey(name: 'session_id') required String sessionId,
    @JsonKey(name: 'xcsrf_token') required String xcsrfToken,
    required UserModel user,
    @JsonKey(name: 'expires_at') required String expiresAt,
    @JsonKey(name: 'if_modified_since') String? ifModifiedSince,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}
