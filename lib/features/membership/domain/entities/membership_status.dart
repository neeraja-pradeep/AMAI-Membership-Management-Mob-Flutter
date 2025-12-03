import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'membership_status.freezed.dart';

/// Domain entity representing the current membership status
/// Used in the Current Status Card of the Membership screen
@freezed
class MembershipStatus with _$MembershipStatus {
  const factory MembershipStatus({
    /// Unique identifier for the membership
    required String id,

    /// Whether the membership is currently active
    required bool isActive,

    /// Membership type (student, house_surgeon, practitioner, honorary)
    required String membershipType,

    /// Membership validity end date
    required DateTime validUntil,

    /// Member's name for display
    required String memberName,

    /// Membership number for display
    required String membershipNumber,

    /// Membership start date
    DateTime? startDate,
  }) = _MembershipStatus;

  const MembershipStatus._();

  /// Check if membership has expired
  bool get isExpired => validUntil.isBefore(DateTime.now());

  /// Days remaining until expiry (negative if expired)
  int get daysUntilExpiry => validUntil.difference(DateTime.now()).inDays;

  /// Check if renewal is due (expiring within 30 days or expired)
  bool get isRenewalDue => daysUntilExpiry <= 30;

  /// Check if membership is expiring soon (within 30 days but not expired)
  bool get isExpiringSoon => daysUntilExpiry > 0 && daysUntilExpiry <= 30;

  /// Whether to show the renewal button
  bool get shouldShowRenewalButton => isRenewalDue;

  /// Formatted validity date string (e.g., "31 Dec 2025")
  String get formattedValidUntil => DateFormat('dd MMM yyyy').format(validUntil);

  /// Formatted membership type for display
  String get displayMembershipType {
    switch (membershipType) {
      case 'student':
        return 'Student';
      case 'house_surgeon':
        return 'House Surgeon';
      case 'practitioner':
        return 'Practitioner';
      case 'honorary':
        return 'Honorary';
      default:
        return membershipType;
    }
  }

  /// Status text based on membership state
  String get statusText {
    if (!isActive) return 'INACTIVE';
    if (isExpired) return 'EXPIRED';
    if (isExpiringSoon) return 'EXPIRING SOON';
    return 'ACTIVE';
  }

  /// Empty membership status for initial/loading state
  static MembershipStatus empty() => MembershipStatus(
        id: '',
        isActive: false,
        membershipType: '',
        validUntil: DateTime.now(),
        memberName: '',
        membershipNumber: '',
      );
}
