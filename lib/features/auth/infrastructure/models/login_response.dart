import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'login_response.g.dart';

/// Login response DTO
///
/// Received from API after successful authentication
///
/// NOTE: session_id is stored in HTTP-only cookies by the server
/// and managed by Dio's cookie manager. It may be present in the
/// response but is not used by the app (cookies are used instead).
@JsonSerializable()
class LoginResponse {
  final bool success;

  /// Session ID - OPTIONAL and IGNORED
  /// The actual session is managed via HTTP-only cookies by Dio
  @JsonKey(name: 'session_id')
  final String? sessionId;

  @JsonKey(name: 'xcsrf_token')
  final String xcsrfToken;

  final UserModel user;

  @JsonKey(name: 'expires_at')
  final String expiresAt;

  @JsonKey(name: 'if_modified_since')
  final String? ifModifiedSince;

  const LoginResponse({
    required this.success,
    this.sessionId,
    required this.xcsrfToken,
    required this.user,
    required this.expiresAt,
    this.ifModifiedSince,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

  LoginResponse copyWith({
    bool? success,
    String? sessionId,
    String? xcsrfToken,
    UserModel? user,
    String? expiresAt,
    String? ifModifiedSince,
  }) {
    return LoginResponse(
      success: success ?? this.success,
      sessionId: sessionId ?? this.sessionId,
      xcsrfToken: xcsrfToken ?? this.xcsrfToken,
      user: user ?? this.user,
      expiresAt: expiresAt ?? this.expiresAt,
      ifModifiedSince: ifModifiedSince ?? this.ifModifiedSince,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginResponse &&
          runtimeType == other.runtimeType &&
          success == other.success &&
          sessionId == other.sessionId &&
          xcsrfToken == other.xcsrfToken &&
          user == other.user &&
          expiresAt == other.expiresAt &&
          ifModifiedSince == other.ifModifiedSince;

  @override
  int get hashCode =>
      success.hashCode ^
      sessionId.hashCode ^
      xcsrfToken.hashCode ^
      user.hashCode ^
      expiresAt.hashCode ^
      ifModifiedSince.hashCode;

  @override
  String toString() {
    return 'LoginResponse(success: $success, xcsrfToken: ${xcsrfToken.substring(0, 8)}..., user: $user, expiresAt: $expiresAt)';
  }
}
