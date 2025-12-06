import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'membership_card.freezed.dart';

/// Domain entity representing an AMAI Membership Card
/// Used to display membership information on the homescreen
@freezed
class MembershipCard with _$MembershipCard {
  const factory MembershipCard({
    /// Unique identifier
    required String id,

    /// Member's full name (user_first_name from API)
    required String holderName,

    /// Membership number for display
    required String membershipNumber,

    /// Membership validity end date
    required DateTime validUntil,

    /// Whether the membership is currently active
    required bool isActive,

    /// User ID from the API (for profile operations)
    int? userId,

    /// Membership type (student, house_surgeon, practitioner, honorary)
    String? membershipType,

    /// Membership start date
    DateTime? startDate,

    /// Academic details (list of qualifications like UG, PG, PhD, etc.)
    List<String>? academicDetails,

    /// Professional details (list of professional categories)
    List<String>? professionalDetails,
  }) = _MembershipCard;

  const MembershipCard._();

  /// Check if membership has expired
  bool get isExpired => validUntil.isBefore(DateTime.now());

  /// Check if membership is expiring soon (within 30 days)
  bool get isExpiringSoon {
    final daysUntilExpiry = validUntil.difference(DateTime.now()).inDays;
    return daysUntilExpiry > 0 && daysUntilExpiry <= 30;
  }

  /// Days remaining until expiry (negative if expired)
  int get daysRemaining => validUntil.difference(DateTime.now()).inDays;

  /// Formatted validity date string for display (e.g., "31 Dec 2025")
  String get displayValidUntil => DateFormat('dd MMM yyyy').format(validUntil);

  /// Formatted membership type for display
  String get displayMembershipType {
    if (membershipType == null) return '';
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
        return membershipType!;
    }
  }

  /// Status text based on membership state
  String get statusText {
    if (!isActive) return 'INACTIVE';
    if (isExpired) return 'EXPIRED';
    if (isExpiringSoon) return 'EXPIRING SOON';
    return 'ACTIVE';
  }

  /// Empty membership card for initial/loading state
  static MembershipCard empty() => MembershipCard(
        id: '',
        holderName: '',
        membershipNumber: '',
        validUntil: DateTime.now(),
        isActive: false,
      );
}
