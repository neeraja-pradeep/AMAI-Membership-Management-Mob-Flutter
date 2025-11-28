/// Personal details entity for Step 1
///
/// Contains practitioner's basic personal information
class PersonalDetails {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final DateTime dateOfBirth;
  final String gender; // 'male', 'female', 'other'
  final String? profileImagePath; // Local file path

  const PersonalDetails({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.gender,
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
        phone.isNotEmpty &&
        gender.isNotEmpty;
  }

  PersonalDetails copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
    String? profileImagePath,
  }) {
    return PersonalDetails(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
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
          dateOfBirth == other.dateOfBirth &&
          gender == other.gender &&
          profileImagePath == other.profileImagePath;

  @override
  int get hashCode =>
      firstName.hashCode ^
      lastName.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      dateOfBirth.hashCode ^
      gender.hashCode ^
      (profileImagePath?.hashCode ?? 0);

  @override
  String toString() {
    return 'PersonalDetails(fullName: $fullName, email: $email, phone: $phone, age: $age)';
  }
}
