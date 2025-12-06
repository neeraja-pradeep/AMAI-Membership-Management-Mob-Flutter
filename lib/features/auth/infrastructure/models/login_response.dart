import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginUserData {
  final int id;
  final String email;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;

  const LoginUserData({
    required this.id,
    required this.email,
    required this.firstName,
    this.lastName,
  });

  factory LoginUserData.fromJson(Map<String, dynamic> json) =>
      _$LoginUserDataFromJson(json);

  Map<String, dynamic> toJson() => _$LoginUserDataToJson(this);
}

@JsonSerializable()
class LoginResponse {
  final String detail;
  final LoginUserData? user;

  const LoginResponse({required this.detail, this.user});

  /// Get the user ID from the response
  int? get userId => user?.id;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}
