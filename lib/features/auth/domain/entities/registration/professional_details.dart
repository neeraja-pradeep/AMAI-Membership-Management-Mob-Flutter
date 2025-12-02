/// Professional details entity for Step 2
///
/// Contains practitioner's or house surgeon's professional credentials.
/// UPDATED: Added optional fields required for House Surgeon role.
class ProfessionalDetails {
  // ---------------- PRACTITIONER FIELDS ----------------
  final String medicalCouncilState;
  final String medicalCouncilNo;
  final String centralCouncilNo;
  final String ugCollege;

  final String professionalDetails1;
  final String professionalDetails2;

  // ---------------- HOUSE SURGEON EXTRA FIELDS ----------------
  final String? provisionalRegistrationNumber;
  final String? councilDistrictNumber;
  final String? country;
  final String? state;
  final String? membershipDistrict;
  final String? membershipArea;

  const ProfessionalDetails({
    required this.medicalCouncilState,
    required this.medicalCouncilNo,
    required this.centralCouncilNo,
    required this.ugCollege,
    required this.professionalDetails1,
    required this.professionalDetails2,

    this.provisionalRegistrationNumber,
    this.councilDistrictNumber,
    this.country,
    this.state,
    this.membershipDistrict,
    this.membershipArea,
  });

  /// Check if minimum required practitioner fields are filled
  bool get isComplete {
    return medicalCouncilState.isNotEmpty &&
        medicalCouncilNo.isNotEmpty &&
        centralCouncilNo.isNotEmpty &&
        ugCollege.isNotEmpty &&
        professionalDetails1.isNotEmpty &&
        professionalDetails2.isNotEmpty;
  }

  ProfessionalDetails copyWith({
    String? medicalCouncilState,
    String? medicalCouncilNo,
    String? centralCouncilNo,
    String? ugCollege,
    String? professionalDetails1,
    String? professionalDetails2,

    // added
    String? provisionalRegistrationNumber,
    String? councilDistrictNumber,
    String? country,
    String? state,
    String? membershipDistrict,
    String? membershipArea,
  }) {
    return ProfessionalDetails(
      medicalCouncilState: medicalCouncilState ?? this.medicalCouncilState,
      medicalCouncilNo: medicalCouncilNo ?? this.medicalCouncilNo,
      centralCouncilNo: centralCouncilNo ?? this.centralCouncilNo,
      ugCollege: ugCollege ?? this.ugCollege,

      professionalDetails1: professionalDetails1 ?? this.professionalDetails1,
      professionalDetails2: professionalDetails2 ?? this.professionalDetails2,

      provisionalRegistrationNumber:
          provisionalRegistrationNumber ?? this.provisionalRegistrationNumber,
      councilDistrictNumber:
          councilDistrictNumber ?? this.councilDistrictNumber,
      country: country ?? this.country,
      state: state ?? this.state,
      membershipDistrict: membershipDistrict ?? this.membershipDistrict,
      membershipArea: membershipArea ?? this.membershipArea,
    );
  }

  @override
  String toString() {
    return '''
ProfessionalDetails(
  medicalCouncilState: $medicalCouncilState,
  medicalCouncilNo: $medicalCouncilNo,
  centralCouncilNo: $centralCouncilNo,
  ugCollege: $ugCollege,
  professionalDetails1: $professionalDetails1,
  professionalDetails2: $professionalDetails2,
  provisionalRegistrationNumber: $provisionalRegistrationNumber,
  councilDistrictNumber: $councilDistrictNumber,
  country: $country,
  state: $state,
  membershipDistrict: $membershipDistrict,
  membershipArea: $membershipArea
)
''';
  }
}
