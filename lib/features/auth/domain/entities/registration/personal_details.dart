/// Personal details entity for Step 1
///
/// Contains practitioner's basic personal information
/// UPDATED: Added new required fields for backend integration
class PersonalDetails {
  final String firstName;
  final String lastName;
  final String email;
  final String password; // NEW: Required for account creation
  final String phone;
  final String waPhone; // NEW: WhatsApp phone number
  final DateTime dateOfBirth;
  final String gender; // 'male', 'female', 'other'
  final String bloodGroup; // NEW: A+, A-, B+, B-, AB+, AB-, O+, O-
  final String membershipType; // NEW: student, practitioner, house_surgeon, honorary
  final String? profileImagePath; // Local file path

  const PersonalDetails({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phone,
    required this.waPhone,
    required this.dateOfBirth,
    required this.gender,
    required this.bloodGroup,
    required this.membershipType,
    this.profileImagePath,
  });

  /// Get full name
  String get fullName => '$firstName $lastName';

  /// Get age from date of birth
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  /// Check if all required fields are filled
  bool get isComplete {
    return firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        password.length >= 8 &&
        phone.isNotEmpty &&
        phone.length == 10 &&
        waPhone.isNotEmpty &&
        waPhone.length == 10 &&
        gender.isNotEmpty &&
        bloodGroup.isNotEmpty &&
        membershipType.isNotEmpty;
  }

  PersonalDetails copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? phone,
    String? waPhone,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodGroup,
    String? membershipType,
    String? profileImagePath,
  }) {
    return PersonalDetails(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      waPhone: waPhone ?? this.waPhone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      membershipType: membershipType ?? this.membershipType,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalDetails &&
          runtimeType == other.runtimeType &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          email == other.email &&
          phone == other.phone &&
          waPhone == other.waPhone &&
          dateOfBirth == other.dateOfBirth &&
          gender == other.gender &&
          bloodGroup == other.bloodGroup &&
          membershipType == other.membershipType;

  @override
  int get hashCode =>
      firstName.hashCode ^
      lastName.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      waPhone.hashCode ^
      dateOfBirth.hashCode ^
      gender.hashCode ^
      bloodGroup.hashCode ^
      membershipType.hashCode;

  @override
  String toString() {
    return 'PersonalDetails(fullName: $fullName, email: $email, phone: $phone, membershipType: $membershipType)';
  }
}
