/// Professional details entity for Step 2
///
/// Contains practitioner's professional credentials
class ProfessionalDetails {
  final String medicalCouncilRegistrationNumber;
  final String medicalCouncil; // 'MCI', 'State Medical Council', etc.
  final DateTime registrationDate;
  final String qualification; // 'MBBS', 'MD', 'MS', etc.
  final String? specialization;
  final String? instituteName;
  final int yearsOfExperience;
  final String? currentWorkplace;
  final String? designation;

  const ProfessionalDetails({
    required this.medicalCouncilRegistrationNumber,
    required this.medicalCouncil,
    required this.registrationDate,
    required this.qualification,
    this.specialization,
    this.instituteName,
    required this.yearsOfExperience,
    this.currentWorkplace,
    this.designation,
  });

  /// Check if all required fields are filled
  bool get isComplete {
    return medicalCouncilRegistrationNumber.isNotEmpty &&
        medicalCouncil.isNotEmpty &&
        qualification.isNotEmpty &&
        yearsOfExperience >= 0;
  }

  ProfessionalDetails copyWith({
    String? medicalCouncilRegistrationNumber,
    String? medicalCouncil,
    DateTime? registrationDate,
    String? qualification,
    String? specialization,
    String? instituteName,
    int? yearsOfExperience,
    String? currentWorkplace,
    String? designation,
  }) {
    return ProfessionalDetails(
      medicalCouncilRegistrationNumber: medicalCouncilRegistrationNumber ??
          this.medicalCouncilRegistrationNumber,
      medicalCouncil: medicalCouncil ?? this.medicalCouncil,
      registrationDate: registrationDate ?? this.registrationDate,
      qualification: qualification ?? this.qualification,
      specialization: specialization ?? this.specialization,
      instituteName: instituteName ?? this.instituteName,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      currentWorkplace: currentWorkplace ?? this.currentWorkplace,
      designation: designation ?? this.designation,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfessionalDetails &&
          runtimeType == other.runtimeType &&
          medicalCouncilRegistrationNumber ==
              other.medicalCouncilRegistrationNumber &&
          medicalCouncil == other.medicalCouncil &&
          registrationDate == other.registrationDate &&
          qualification == other.qualification &&
          specialization == other.specialization &&
          instituteName == other.instituteName &&
          yearsOfExperience == other.yearsOfExperience &&
          currentWorkplace == other.currentWorkplace &&
          designation == other.designation;

  @override
  int get hashCode =>
      medicalCouncilRegistrationNumber.hashCode ^
      medicalCouncil.hashCode ^
      registrationDate.hashCode ^
      qualification.hashCode ^
      (specialization?.hashCode ?? 0) ^
      (instituteName?.hashCode ?? 0) ^
      yearsOfExperience.hashCode ^
      (currentWorkplace?.hashCode ?? 0) ^
      (designation?.hashCode ?? 0);

  @override
  String toString() {
    return 'ProfessionalDetails(registration: $medicalCouncilRegistrationNumber, qualification: $qualification, experience: $yearsOfExperience years)';
  }
}
