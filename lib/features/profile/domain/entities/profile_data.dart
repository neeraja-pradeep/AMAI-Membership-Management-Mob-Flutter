import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:myapp/features/profile/domain/entities/membership_type.dart';
import 'package:myapp/features/profile/domain/entities/user_profile.dart';

part 'profile_data.freezed.dart';

/// Aggregate entity combining user profile with membership info
@freezed
class ProfileData with _$ProfileData {
  const factory ProfileData({
    /// User profile information
    required UserProfile userProfile,

    /// Membership type (from membership endpoint)
    required MembershipType membershipType,

    /// Membership number
    String? membershipNumber,

    /// Membership status
    String? membershipStatus,

    /// Membership valid until date
    DateTime? validUntil,
  }) = _ProfileData;

  const ProfileData._();

  /// Check if user is a practitioner
  bool get isPractitioner => membershipType == MembershipType.practitioner;

  /// Check if user is a house surgeon
  bool get isHouseSurgeon => membershipType == MembershipType.houseSurgeon;

  /// Check if user is a student
  bool get isStudent => membershipType == MembershipType.student;

  /// Get formatted valid until date
  String? get formattedValidUntil {
    if (validUntil == null) return null;
    return '${validUntil!.day}/${validUntil!.month}/${validUntil!.year}';
  }
}
