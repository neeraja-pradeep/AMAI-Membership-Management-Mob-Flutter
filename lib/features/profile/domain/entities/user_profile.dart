import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'user_profile.freezed.dart';

/// Domain entity representing user profile information
/// Data from /api/accounts/users/{user-id}/ endpoint
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    /// Unique user identifier
    required int id,

    /// User's email address
    required String email,

    /// User's phone number
    required String phone,

    /// User's first name
    required String firstName,

    /// User's last name (optional)
    String? lastName,

    /// Date of birth
    DateTime? dateOfBirth,

    /// Gender
    String? gender,

    /// Profile picture URL
    String? profilePicture,

    /// Profile picture path
    String? profilePicturePath,

    /// Whether user account is active
    required bool isActive,

    /// Whether user is verified
    required bool isVerified,

    /// Blood group
    String? bloodGroup,

    /// Parent's name
    String? parentName,

    /// Marital status
    String? maritalStatus,

    /// User role
    String? role,

    /// Last login timestamp
    DateTime? lastLogin,
  }) = _UserProfile;

  const UserProfile._();

  /// Get full name (first + last)
  String get fullName {
    if (lastName != null && lastName!.isNotEmpty) {
      return '$firstName $lastName';
    }
    return firstName;
  }

  /// Get display name (firstName or fullName)
  String get displayName => firstName;

  /// Check if user has profile picture
  bool get hasProfilePicture =>
      (profilePicture != null && profilePicture!.isNotEmpty) ||
      (profilePicturePath != null && profilePicturePath!.isNotEmpty);

  /// Get profile picture URL
  String? get profilePictureUrl => profilePicture ?? profilePicturePath;

  /// Get initials for avatar fallback
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = (lastName != null && lastName!.isNotEmpty)
        ? lastName![0].toUpperCase()
        : '';
    return '$first$last';
  }

  /// Formatted date of birth for display
  String? get formattedDateOfBirth {
    if (dateOfBirth == null) return null;
    return DateFormat('dd MMM yyyy').format(dateOfBirth!);
  }

  /// Formatted gender for display
  String? get formattedGender {
    if (gender == null) return null;
    return gender![0].toUpperCase() + gender!.substring(1).toLowerCase();
  }
}
