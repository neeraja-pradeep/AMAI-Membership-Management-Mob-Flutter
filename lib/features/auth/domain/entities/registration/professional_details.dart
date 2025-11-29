/// Professional details entity for Step 2
///
/// Contains practitioner's professional credentials
/// UPDATED: Matches backend /api/membership/register/ requirements
class ProfessionalDetails {
  final String medicalCouncilState; // State medical council
  final String medicalCouncilNo; // Medical council registration number
  final String centralCouncilNo; // Central council number
  final String ugCollege; // UG College name

  final String professionalDetails1; // Additional professional details 1
  final String professionalDetails2; // Additional professional details 2

  const ProfessionalDetails({
    required this.medicalCouncilState,
    required this.medicalCouncilNo,
    required this.centralCouncilNo,
    required this.ugCollege,

    required this.professionalDetails1,
    required this.professionalDetails2,
  });

  /// Check if all required fields are filled
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
    String? zoneId,
    String? professionalDetails1,
    String? professionalDetails2,
  }) {
    return ProfessionalDetails(
      medicalCouncilState: medicalCouncilState ?? this.medicalCouncilState,
      medicalCouncilNo: medicalCouncilNo ?? this.medicalCouncilNo,
      centralCouncilNo: centralCouncilNo ?? this.centralCouncilNo,
      ugCollege: ugCollege ?? this.ugCollege,

      professionalDetails1: professionalDetails1 ?? this.professionalDetails1,
      professionalDetails2: professionalDetails2 ?? this.professionalDetails2,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfessionalDetails &&
          runtimeType == other.runtimeType &&
          medicalCouncilState == other.medicalCouncilState &&
          medicalCouncilNo == other.medicalCouncilNo &&
          centralCouncilNo == other.centralCouncilNo &&
          ugCollege == other.ugCollege &&
          professionalDetails1 == other.professionalDetails1 &&
          professionalDetails2 == other.professionalDetails2;

  @override
  int get hashCode =>
      medicalCouncilState.hashCode ^
      medicalCouncilNo.hashCode ^
      centralCouncilNo.hashCode ^
      ugCollege.hashCode ^
      professionalDetails1.hashCode ^
      professionalDetails2.hashCode;

  @override
  String toString() {
    return 'ProfessionalDetails(medicalCouncilNo: $medicalCouncilNo, state: $medicalCouncilState, ugCollege: $ugCollege)';
  }
}
