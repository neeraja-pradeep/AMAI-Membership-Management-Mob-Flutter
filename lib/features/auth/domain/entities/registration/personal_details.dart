/// Personal details entity for Step 1
///
/// Contains practitioner's basic personal information.
/// UPDATED to support student + house surgeon requirements.
class PersonalDetails {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phone;
  final String waPhone;
  final DateTime dateOfBirth;
  final String gender;
  final String bloodGroup;
  final String membershipType; // student, practitioner, house_surgeon
  final String? profileImagePath;

  // NEW FIELDS
  final String? institutionName; // Required for student + house_surgeon
  final String? bamsStartYear; // Required for student only
  final String? magazinePreference; // Required for house_surgeon only

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

    // NEW OPTIONAL FIELDS
    this.institutionName,
    this.bamsStartYear,
    this.magazinePreference,
  });

  /// Convenience: Full name getter
  String get fullName => '$firstName $lastName';

  /// Calculate age
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  /// Validation based on role
  bool get isComplete {
    final baseValid =
        firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        password.length >= 8 &&
        phone.length == 10 &&
        waPhone.length == 10 &&
        gender.isNotEmpty &&
        bloodGroup.isNotEmpty &&
        membershipType.isNotEmpty;

    // Role-based validation
    if (membershipType == "house surgeon") {
      return baseValid &&
          institutionName?.isNotEmpty == true &&
          magazinePreference?.isNotEmpty == true;
    }

    if (membershipType == "student") {
      return baseValid &&
          institutionName?.isNotEmpty == true &&
          bamsStartYear?.isNotEmpty == true;
    }

    // Practitioner doesn't need extra fields
    return baseValid;
  }

  /// Copy with updated fields
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
    String? institutionName,
    String? bamsStartYear,
    String? magazinePreference,
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
      institutionName: institutionName ?? this.institutionName,
      bamsStartYear: bamsStartYear ?? this.bamsStartYear,
      magazinePreference: magazinePreference ?? this.magazinePreference,
    );
  }

  @override
  String toString() {
    return 'PersonalDetails(fullName: $fullName, email: $email, phone: $phone, role: $membershipType)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalDetails &&
          runtimeType == other.runtimeType &&
          email == other.email;

  @override
  int get hashCode => email.hashCode;
}
