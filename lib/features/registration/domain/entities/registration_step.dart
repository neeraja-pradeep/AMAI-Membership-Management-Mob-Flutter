/// Registration step enumeration
///
/// Represents the 5-step practitioner registration flow
enum RegistrationStep {
  personalDetails(1, 'Personal Details'),
  professionalDetails(2, 'Professional Details'),
  addressDetails(3, 'Address Details'),
  documentUploads(4, 'Document Uploads'),
  payment(5, 'Payment');

  const RegistrationStep(this.stepNumber, this.displayName);

  final int stepNumber;
  final String displayName;

  /// Check if this is the first step
  bool get isFirst => this == RegistrationStep.personalDetails;

  /// Check if this is the last step
  bool get isLast => this == RegistrationStep.payment;

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
