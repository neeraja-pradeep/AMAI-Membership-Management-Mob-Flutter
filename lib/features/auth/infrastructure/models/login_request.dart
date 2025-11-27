import 'package:json_annotation/json_annotation.dart';

part 'login_request.g.dart';

/// Login request DTO
///
/// Sent to API for authentication
@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;
  @JsonKey(name: 'remember_me')
  final bool rememberMe;
  @JsonKey(name: 'device_id')
  final String deviceId;

  const LoginRequest({
    required this.email,
    required this.password,
    this.rememberMe = false,
    required this.deviceId,
  });

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
      rememberMe: rememberMe ?? this.rememberMe,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginRequest &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          deviceId == other.deviceId;

  @override
  int get hashCode => email.hashCode ^ deviceId.hashCode;
}
