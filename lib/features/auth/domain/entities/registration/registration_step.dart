/// Registration step enumeration
///
/// Represents the 5-step practitioner registration flow:
/// 1. Personal Details (collect data)
/// 2. Professional Details → API: POST /api/membership/register/ (combined personal + professional)
/// 3. Address Details → API: POST /api/accounts/addresses/
/// 4. Document Uploads → API: POST /api/membership/application-documents/
/// 5. Payment (final step)
enum RegistrationStep {
  personalDetails(1, 'Personal Details'),
  professionalDetails(2, 'Professional Details'),
  addressDetails(3, 'Address Details'),
  documentUploads(4, 'Document Uploads'),
  payment(5, 'Payment'),

  // DEPRECATED: Old 3-step flow (kept for backward compatibility)
  membershipDetails(1, 'Membership Details');

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
