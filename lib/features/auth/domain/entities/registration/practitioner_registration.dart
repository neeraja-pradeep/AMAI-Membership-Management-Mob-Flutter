import 'membership_details.dart';
import 'personal_details.dart';
import 'professional_details.dart';
import 'address_details.dart';
import 'document_upload.dart';
import 'registration_step.dart';

/// Payment status
enum PaymentStatus {
  pending,
  processing,
  completed,
  failed;
}

/// Payment details entity for Step 5
class PaymentDetails {
  final String sessionId; // Payment gateway session ID
  final double amount;
  final String currency;
  final PaymentStatus status;
  final String? transactionId;
  final String? paymentMethod; // 'card', 'upi', 'netbanking', etc.
  final DateTime? completedAt; // When payment was completed

  const PaymentDetails({
    required this.sessionId,
    required this.amount,
    this.currency = 'INR',
    this.status = PaymentStatus.pending,
    this.transactionId,
    this.paymentMethod,
    this.completedAt,
  });

  bool get isComplete => status == PaymentStatus.completed;

  PaymentDetails copyWith({
    String? sessionId,
    double? amount,
    String? currency,
    PaymentStatus? status,
    String? transactionId,
    String? paymentMethod,
    DateTime? completedAt,
  }) {
    return PaymentDetails(
      sessionId: sessionId ?? this.sessionId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  String toString() {
    return 'PaymentDetails(sessionId: $sessionId, amount: $amount $currency, status: $status, txnId: $transactionId)';
  }
}

/// Main practitioner registration entity
///
/// Combines all registration steps into a single entity
/// State persists across app restarts for 24 hours
class PractitionerRegistration {
  final String registrationId; // UUID for tracking
  final RegistrationStep currentStep;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;

  // Application ID from backend (Step 1)
  final String? applicationId;

  // NEW: 3-step registration data
  final MembershipDetails? membershipDetails;

  // DEPRECATED: Old 5-step fields (kept for backward compatibility)
  final PersonalDetails? personalDetails;
  final ProfessionalDetails? professionalDetails;

  // Step data (nullable until completed)
  final AddressDetails? addressDetails;
  final DocumentUploads? documentUploads;
  final PaymentDetails? paymentDetails;

  const PractitionerRegistration({
    required this.registrationId,
    this.currentStep = RegistrationStep.membershipDetails,
    required this.createdAt,
    required this.lastUpdatedAt,
    this.applicationId,
    this.membershipDetails,
    this.personalDetails,
    this.professionalDetails,
    this.addressDetails,
    this.documentUploads,
    this.paymentDetails,
  });

  /// Check if registration is expired (>24 hours old)
  bool get isExpired {
    final now = DateTime.now();
    final expiryTime = createdAt.add(const Duration(hours: 24));
    return now.isAfter(expiryTime);
  }

  /// Check if current step is complete
  bool isStepComplete(RegistrationStep step) {
    switch (step) {
      case RegistrationStep.membershipDetails:
        return membershipDetails?.isComplete ?? false;
      case RegistrationStep.addressDetails:
        return addressDetails?.isComplete ?? false;
      case RegistrationStep.documentUploads:
        return documentUploads?.isComplete ?? false;
    }
  }

  /// Check if can proceed to next step
  ///
  /// REQUIREMENT: Multi-step validation
  /// - Validates current step is complete
  /// - Validates all previous steps remain valid
  bool get canProceedToNext {
    // Current step must be complete
    if (!isStepComplete(currentStep)) return false;

    // REQUIREMENT: Validate all previous steps
    return arePreviousStepsValid();
  }

  /// Validate all steps before current step
  ///
  /// REQUIREMENT: Multi-step validation - all previous screens must remain valid
  bool arePreviousStepsValid() {
    switch (currentStep) {
      case RegistrationStep.membershipDetails:
        // No previous steps
        return true;

      case RegistrationStep.addressDetails:
        // Must have valid membership details
        return membershipDetails?.isComplete ?? false;

      case RegistrationStep.documentUploads:
        // Must have valid membership + address details
        return (membershipDetails?.isComplete ?? false) &&
            (addressDetails?.isComplete ?? false);
    }
  }

  /// Check if entire registration is complete (3 steps)
  bool get isComplete {
    return membershipDetails != null &&
        addressDetails != null &&
        documentUploads != null;
  }

  /// Get completion percentage (0.0 to 1.0)
  double get completionPercentage {
    int completedSteps = 0;
    if (membershipDetails?.isComplete == true) completedSteps++;
    if (addressDetails?.isComplete == true) completedSteps++;
    if (documentUploads?.isComplete == true) completedSteps++;

    return completedSteps / RegistrationStep.totalSteps;
  }

  PractitionerRegistration copyWith({
    String? registrationId,
    RegistrationStep? currentStep,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
    String? applicationId,
    MembershipDetails? membershipDetails,
    PersonalDetails? personalDetails,
    ProfessionalDetails? professionalDetails,
    AddressDetails? addressDetails,
    DocumentUploads? documentUploads,
    PaymentDetails? paymentDetails,
  }) {
    return PractitionerRegistration(
      registrationId: registrationId ?? this.registrationId,
      currentStep: currentStep ?? this.currentStep,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      applicationId: applicationId ?? this.applicationId,
      membershipDetails: membershipDetails ?? this.membershipDetails,
      personalDetails: personalDetails ?? this.personalDetails,
      professionalDetails: professionalDetails ?? this.professionalDetails,
      addressDetails: addressDetails ?? this.addressDetails,
      documentUploads: documentUploads ?? this.documentUploads,
      paymentDetails: paymentDetails ?? this.paymentDetails,
    );
  }

  @override
  String toString() {
    return 'PractitionerRegistration(id: $registrationId, step: ${currentStep.displayName}, completion: ${(completionPercentage * 100).toStringAsFixed(0)}%, expired: $isExpired)';
  }
}
