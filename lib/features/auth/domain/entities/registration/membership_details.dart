/// Membership details entity for complete practitioner registration
///
/// Contains all information required for membership registration
/// Matches backend POST /api/membership/register/ requirements
///
/// UPDATED: Now includes personal + professional details in one entity
class MembershipDetails {
  // Personal Information Fields
  final String email;
  final String password;
  final String firstName;
  final String phone;
  final String waPhone; // WhatsApp phone
  final DateTime dateOfBirth;
  final String gender; // 'male', 'female', 'other'
  final String bloodGroup;
  final MembershipType membershipType;

  // Professional Details Fields
  final String medicalCouncilState;
  final String medicalCouncilNo;
  final String centralCouncilNo;
  final String ugCollege;
  final String zoneId;
  final String professionalDetails1;
  final String professionalDetails2;

  // Optional fields (kept for backward compatibility)
  final String? lastName;
  final int? bamsStartYear;
  final String? institutionName;

  const MembershipDetails({
    required this.email,
    required this.password,
    required this.firstName,
    required this.phone,
    required this.waPhone,
    required this.dateOfBirth,
    required this.gender,
    required this.bloodGroup,
    required this.membershipType,
    required this.medicalCouncilState,
    required this.medicalCouncilNo,
    required this.centralCouncilNo,
    required this.ugCollege,
    required this.zoneId,
    required this.professionalDetails1,
    required this.professionalDetails2,
    this.lastName,
    this.bamsStartYear,
    this.institutionName,
  });

  /// Get full name
  String get fullName => lastName != null ? '$firstName $lastName' : firstName;

  /// Check if all required fields are filled
  bool get isComplete {
    return email.isNotEmpty &&
        password.isNotEmpty &&
        password.length >= 8 && // Minimum password length
        firstName.isNotEmpty &&
        phone.isNotEmpty &&
        phone.length == 10 && // Indian phone number
        waPhone.isNotEmpty &&
        waPhone.length == 10 &&
        gender.isNotEmpty &&
        bloodGroup.isNotEmpty &&
        medicalCouncilState.isNotEmpty &&
        medicalCouncilNo.isNotEmpty &&
        centralCouncilNo.isNotEmpty &&
        ugCollege.isNotEmpty &&
        zoneId.isNotEmpty &&
        professionalDetails1.isNotEmpty &&
        professionalDetails2.isNotEmpty;
  }

  MembershipDetails copyWith({
    String? email,
    String? password,
    String? firstName,
    String? phone,
    String? waPhone,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodGroup,
    MembershipType? membershipType,
    String? medicalCouncilState,
    String? medicalCouncilNo,
    String? centralCouncilNo,
    String? ugCollege,
    String? zoneId,
    String? professionalDetails1,
    String? professionalDetails2,
    String? lastName,
    int? bamsStartYear,
    String? institutionName,
  }) {
    return MembershipDetails(
      email: email ?? this.email,
      password: password ?? this.password,
      firstName: firstName ?? this.firstName,
      phone: phone ?? this.phone,
      waPhone: waPhone ?? this.waPhone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      membershipType: membershipType ?? this.membershipType,
      medicalCouncilState: medicalCouncilState ?? this.medicalCouncilState,
      medicalCouncilNo: medicalCouncilNo ?? this.medicalCouncilNo,
      centralCouncilNo: centralCouncilNo ?? this.centralCouncilNo,
      ugCollege: ugCollege ?? this.ugCollege,
      zoneId: zoneId ?? this.zoneId,
      professionalDetails1: professionalDetails1 ?? this.professionalDetails1,
      professionalDetails2: professionalDetails2 ?? this.professionalDetails2,
      lastName: lastName ?? this.lastName,
      bamsStartYear: bamsStartYear ?? this.bamsStartYear,
      institutionName: institutionName ?? this.institutionName,
    );
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'membership_type': membershipType.value,
      'first_name': firstName,
      'email': email,
      'password': password,
      'phone': phone,
      'wa_phone': waPhone,
      'date_of_birth': '${dateOfBirth.year}-${dateOfBirth.month.toString().padLeft(2, '0')}-${dateOfBirth.day.toString().padLeft(2, '0')}', // YYYY-MM-DD format
      'gender': gender,
      'blood_group': bloodGroup,
      'medical_council_state': medicalCouncilState,
      'medical_council_no': medicalCouncilNo,
      'central_council_no': centralCouncilNo,
      'ug_college': ugCollege,
      'zone_id': zoneId,
      'professional_details1': professionalDetails1,
      'professional_details2': professionalDetails2,
    };
  }

  /// Create from JSON
  factory MembershipDetails.fromJson(Map<String, dynamic> json) {
    return MembershipDetails(
      email: json['email'] as String,
      password: json['password'] as String,
      firstName: json['first_name'] as String,
      phone: json['phone'] as String,
      waPhone: json['wa_phone'] as String,
      dateOfBirth: DateTime.parse(json['date_of_birth'] as String),
      gender: json['gender'] as String,
      bloodGroup: json['blood_group'] as String,
      membershipType: MembershipType.fromValue(json['membership_type'] as String),
      medicalCouncilState: json['medical_council_state'] as String,
      medicalCouncilNo: json['medical_council_no'] as String,
      centralCouncilNo: json['central_council_no'] as String,
      ugCollege: json['ug_college'] as String,
      zoneId: json['zone_id'] as String,
      professionalDetails1: json['professional_details1'] as String,
      professionalDetails2: json['professional_details2'] as String,
      lastName: json['last_name'] as String?,
      bamsStartYear: json['bams_start_year'] as int?,
      institutionName: json['institution_name'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MembershipDetails &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          firstName == other.firstName &&
          phone == other.phone;

  @override
  int get hashCode => email.hashCode ^ firstName.hashCode ^ phone.hashCode;

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

/// Gender options
class Gender {
  static const String male = 'male';
  static const String female = 'female';
  static const String other = 'other';

  static const List<String> options = [male, female, other];

  static String getDisplayName(String value) {
    switch (value) {
      case male:
        return 'Male';
      case female:
        return 'Female';
      case other:
        return 'Other';
      default:
        return value;
    }
  }
}
