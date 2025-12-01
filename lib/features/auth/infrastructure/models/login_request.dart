import 'package:json_annotation/json_annotation.dart';

part 'login_request.g.dart';

/// Login request DTO
///
/// Sent to API for authentication
@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);

  LoginRequest copyWith({
    String? email,
    String? password,
    bool? rememberMe,
    String? deviceId,
  }) {
    return LoginRequest(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}
