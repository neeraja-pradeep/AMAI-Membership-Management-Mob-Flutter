import 'package:freezed_annotation/freezed_annotation.dart';

part 'registration_request.freezed.dart';
part 'registration_request.g.dart';

/// Registration request DTO (Role Selection Phase)
///
/// Sent to API for initial registration step
@freezed
class RegistrationRequest with _$RegistrationRequest {
  const factory RegistrationRequest({
    required String role,
  }) = _RegistrationRequest;

  factory RegistrationRequest.fromJson(Map<String, dynamic> json) =>
      _$RegistrationRequestFromJson(json);
}
