import 'package:json_annotation/json_annotation.dart';

part 'registration_request.g.dart';

/// Registration request DTO (Role Selection Phase)
///
/// Sent to API for initial registration step
@JsonSerializable()
class RegistrationRequest {
  final String role;

  const RegistrationRequest({
    required this.role,
  });

  factory RegistrationRequest.fromJson(Map<String, dynamic> json) =>
      _$RegistrationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegistrationRequestToJson(this);

  RegistrationRequest copyWith({
    String? role,
  }) {
    return RegistrationRequest(
      role: role ?? this.role,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegistrationRequest &&
          runtimeType == other.runtimeType &&
          role == other.role;

  @override
  int get hashCode => role.hashCode;

  @override
  String toString() {
    return 'RegistrationRequest(role: $role)';
  }
}
