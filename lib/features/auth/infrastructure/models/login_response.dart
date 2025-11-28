import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'login_response.g.dart';

/// Login response DTO
///
/// Received from API after successful authentication
///
/// CRITICAL PATTERN: Cookie-based session and CSRF
/// - session_id: Backend sets HTTP-only cookie, ignored in response
/// - xcsrf_token: Backend sets HTTP-only cookie, ignored in response
/// - Both managed by Dio CookieManager automatically
/// - NO manual storage or handling of session/CSRF tokens
@JsonSerializable()
class LoginResponse {
  final bool success;

  /// Session ID - OPTIONAL and IGNORED
  /// The actual session is managed via HTTP-only cookies by Dio
  /// Backend may send in response but app uses cookies instead
  @JsonKey(name: 'session_id')
  final String? sessionId;

  /// CSRF Token - OPTIONAL and IGNORED
  /// The actual CSRF token is managed via HTTP-only cookies by Dio
  /// Backend may send in response but app uses cookies instead
  /// ApiClient interceptor extracts from cookies on every request
  @JsonKey(name: 'xcsrf_token')
  final String? xcsrfToken;

  final UserModel user;

  @JsonKey(name: 'expires_at')
  final String expiresAt;

  @JsonKey(name: 'if_modified_since')
  final String? ifModifiedSince;

  const LoginResponse({
    required this.success,
    this.sessionId,
    this.xcsrfToken,
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
    final tokenPreview = xcsrfToken != null && xcsrfToken!.length >= 8
        ? '${xcsrfToken!.substring(0, 8)}...'
        : 'null';
    return 'LoginResponse(success: $success, xcsrfToken: $tokenPreview, user: $user, expiresAt: $expiresAt)';
  }
}
