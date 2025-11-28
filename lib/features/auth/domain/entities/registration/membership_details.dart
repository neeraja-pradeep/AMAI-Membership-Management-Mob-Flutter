/// Membership details entity for Step 1
///
/// Contains all information required for membership registration
/// Matches backend POST /api/membership/register/ requirements
class MembershipDetails {
  final String email;
  final String password;
  final String phone;
  final String waPhone; // WhatsApp phone
  final String firstName;
  final String lastName;
  final MembershipType membershipType;
  final String bloodGroup;
  final int bamsStartYear;
  final String institutionName;

  const MembershipDetails({
    required this.email,
    required this.password,
    required this.phone,
    required this.waPhone,
    required this.firstName,
    required this.lastName,
    required this.membershipType,
    required this.bloodGroup,
    required this.bamsStartYear,
    required this.institutionName,
  });

  /// Get full name
  String get fullName => '$firstName $lastName';

  /// Check if all required fields are filled
  bool get isComplete {
    return email.isNotEmpty &&
        password.isNotEmpty &&
        password.length >= 8 && // Minimum password length
        phone.isNotEmpty &&
        phone.length == 10 && // Indian phone number
        waPhone.isNotEmpty &&
        waPhone.length == 10 &&
        firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        bloodGroup.isNotEmpty &&
        bamsStartYear > 1900 &&
        bamsStartYear <= DateTime.now().year &&
        institutionName.isNotEmpty;
  }

  MembershipDetails copyWith({
    String? email,
    String? password,
    String? phone,
    String? waPhone,
    String? firstName,
    String? lastName,
    MembershipType? membershipType,
    String? bloodGroup,
    int? bamsStartYear,
    String? institutionName,
  }) {
    return MembershipDetails(
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      waPhone: waPhone ?? this.waPhone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      membershipType: membershipType ?? this.membershipType,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      bamsStartYear: bamsStartYear ?? this.bamsStartYear,
      institutionName: institutionName ?? this.institutionName,
    );
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'phone': phone,
      'wa_phone': waPhone,
      'first_name': firstName,
      'last_name': lastName,
      'membership_type': membershipType.value,
      'blood_group': bloodGroup,
      'bams_start_year': bamsStartYear,
      'institution_name': institutionName,
    };
  }

  /// Create from JSON
  factory MembershipDetails.fromJson(Map<String, dynamic> json) {
    return MembershipDetails(
      email: json['email'] as String,
      password: json['password'] as String,
      phone: json['phone'] as String,
      waPhone: json['wa_phone'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      membershipType: MembershipType.fromValue(json['membership_type'] as String),
      bloodGroup: json['blood_group'] as String,
      bamsStartYear: json['bams_start_year'] as int,
      institutionName: json['institution_name'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MembershipDetails &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          password == other.password &&
          phone == other.phone &&
          waPhone == other.waPhone &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          membershipType == other.membershipType &&
          bloodGroup == other.bloodGroup &&
          bamsStartYear == other.bamsStartYear &&
          institutionName == other.institutionName;

  @override
  int get hashCode =>
      email.hashCode ^
      password.hashCode ^
      phone.hashCode ^
      waPhone.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      membershipType.hashCode ^
      bloodGroup.hashCode ^
      bamsStartYear.hashCode ^
      institutionName.hashCode;

  @override
  String toString() {
    return 'MembershipDetails(fullName: $fullName, email: $email, type: ${membershipType.displayName})';
  }
}

/// Membership type enum matching backend requirements
enum MembershipType {
  student('student', 'Student'),
  practitioner('practitioner', 'Practitioner'),
  houseSurgeon('house_surgeon', 'House Surgeon'),
  honorary('honorary', 'Honorary');

  final String value;
  final String displayName;

  const MembershipType(this.value, this.displayName);

  static MembershipType fromValue(String value) {
    return MembershipType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MembershipType.practitioner,
    );
  }
}

/// Blood group options
class BloodGroup {
  static const List<String> options = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
}
