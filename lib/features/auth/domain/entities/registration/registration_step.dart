/// Registration step enumeration
///
/// Represents the 3-step practitioner registration flow
/// Matches backend API: Membership → Address → Documents
enum RegistrationStep {
  membershipDetails(1, 'Membership Details'),
  addressDetails(2, 'Address Details'),
  documentUploads(3, 'Document Uploads');

  const RegistrationStep(this.stepNumber, this.displayName);

  final int stepNumber;
  final String displayName;

  /// Check if this is the first step
  bool get isFirst => this == RegistrationStep.membershipDetails;

  /// Check if this is the last step
  bool get isLast => this == RegistrationStep.documentUploads;

  /// Get the next step
  RegistrationStep? get next {
    final currentIndex = RegistrationStep.values.indexOf(this);
    if (currentIndex < RegistrationStep.values.length - 1) {
      return RegistrationStep.values[currentIndex + 1];
    }
    return null;
  }

  /// Get the previous step
  RegistrationStep? get previous {
    final currentIndex = RegistrationStep.values.indexOf(this);
    if (currentIndex > 0) {
      return RegistrationStep.values[currentIndex - 1];
    }
    return null;
  }

  /// Progress percentage (0.0 to 1.0)
  double get progress => stepNumber / RegistrationStep.values.length;

  /// Total number of steps
  static int get totalSteps => RegistrationStep.values.length;
}
