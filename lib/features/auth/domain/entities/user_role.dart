/// User role enum for AMAI membership types
///
/// Supported roles:
/// - practitioner: Full practicing member
/// - house_surgeon: House surgeon member
/// - student: Student member
enum UserRole {
  practitioner,
  houseSurgeon,
  student;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case UserRole.practitioner:
        return 'Practitioner';
      case UserRole.houseSurgeon:
        return 'House Surgeon';
      case UserRole.student:
        return 'Student';
    }
  }

  /// API value (snake_case)
  String get apiValue {
    switch (this) {
      case UserRole.practitioner:
        return 'practitioner';
      case UserRole.houseSurgeon:
        return 'house_surgeon';
      case UserRole.student:
        return 'student';
    }
  }

  /// Parse from API value
  static UserRole fromApiValue(String value) {
    switch (value.toLowerCase()) {
      case 'practitioner':
        return UserRole.practitioner;
      case 'house_surgeon':
        return UserRole.houseSurgeon;
      case 'student':
        return UserRole.student;
      default:
        throw ArgumentError('Unknown user role: $value');
    }
  }
}
