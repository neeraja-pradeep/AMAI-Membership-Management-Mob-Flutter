import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_role.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// User data transfer object (DTO)
///
/// Maps between API JSON and domain User entity
@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required int id,
    required String email,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    required String role,
    String? phone,
    @JsonKey(name: 'profile_image_url') String? profileImageUrl,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Convert to domain entity
  User toEntity() {
    return User(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      role: UserRole.fromApiValue(role),
      phone: phone,
      profileImageUrl: profileImageUrl,
    );
  }

  /// Create from domain entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      role: user.role.apiValue,
      phone: user.phone,
      profileImageUrl: user.profileImageUrl,
    );
  }
}
