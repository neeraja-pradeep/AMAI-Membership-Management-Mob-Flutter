/// Enum representing the type of membership
/// Used to determine conditional UI in profile screen
enum MembershipType {
  practitioner,
  houseSurgeon,
  student;

  /// Factory to parse membership type from API string
  static MembershipType fromString(String? value) {
    if (value == null) return MembershipType.practitioner;

    final normalized = value.toLowerCase().replaceAll(' ', '').replaceAll('_', '');

    switch (normalized) {
      case 'practitioner':
        return MembershipType.practitioner;
      case 'housesurgeon':
        return MembershipType.houseSurgeon;
      case 'student':
        return MembershipType.student;
      default:
        return MembershipType.practitioner;
    }
  }

  /// Display name for UI
  String get displayName {
    switch (this) {
      case MembershipType.practitioner:
        return 'Practitioner';
      case MembershipType.houseSurgeon:
        return 'House Surgeon';
      case MembershipType.student:
        return 'Student';
    }
  }
}
