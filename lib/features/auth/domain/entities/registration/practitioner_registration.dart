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

  // Application ID from backend (returned after Step 2)
  final String? applicationId;

  // CURRENT: 5-step registration data (Personal → Professional → Address → Documents → Payment)
  final PersonalDetails? personalDetails;
  final ProfessionalDetails? professionalDetails;

  // DEPRECATED: Old 3-step flow (Membership → Address → Documents)
  final MembershipDetails? membershipDetails;

  // Step data (nullable until completed)
  final AddressDetails? addressDetails;
  final DocumentUploads? documentUploads;
  final PaymentDetails? paymentDetails;

  const PractitionerRegistration({
    required this.registrationId,
    this.currentStep = RegistrationStep.personalDetails,
    required this.createdAt,
    required this.lastUpdatedAt,
    this.applicationId,
    this.personalDetails,
    this.professionalDetails,
    this.membershipDetails,
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
      case RegistrationStep.personalDetails:
        return personalDetails?.isComplete ?? false;
      case RegistrationStep.professionalDetails:
        return professionalDetails?.isComplete ?? false;
      case RegistrationStep.addressDetails:
        return addressDetails?.isComplete ?? false;
      case RegistrationStep.documentUploads:
        return documentUploads?.isComplete ?? false;
      case RegistrationStep.payment:
        return paymentDetails?.isComplete ?? false;
      case RegistrationStep.membershipDetails:
        // DEPRECATED: Old flow
        return membershipDetails?.isComplete ?? false;
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
      case RegistrationStep.personalDetails:
      case RegistrationStep.membershipDetails:
        // No previous steps
        return true;

      case RegistrationStep.professionalDetails:
        // Must have valid personal details
        return personalDetails?.isComplete ?? false;

      case RegistrationStep.addressDetails:
        // Must have valid personal + professional details OR membership details (old flow)
        if (personalDetails != null && professionalDetails != null) {
          return (personalDetails?.isComplete ?? false) &&
              (professionalDetails?.isComplete ?? false);
        }
        // Old flow compatibility
        return membershipDetails?.isComplete ?? false;

      case RegistrationStep.documentUploads:
        // Must have valid personal + professional + address details
        if (personalDetails != null && professionalDetails != null) {
          return (personalDetails?.isComplete ?? false) &&
              (professionalDetails?.isComplete ?? false) &&
              (addressDetails?.isComplete ?? false);
        }
        // Old flow compatibility
        return (membershipDetails?.isComplete ?? false) &&
            (addressDetails?.isComplete ?? false);

      case RegistrationStep.payment:
        // Must have valid personal + professional + address + documents
        if (personalDetails != null && professionalDetails != null) {
          return (personalDetails?.isComplete ?? false) &&
              (professionalDetails?.isComplete ?? false) &&
              (addressDetails?.isComplete ?? false) &&
              (documentUploads?.isComplete ?? false);
        }
        // Old flow compatibility
        return (membershipDetails?.isComplete ?? false) &&
            (addressDetails?.isComplete ?? false) &&
            (documentUploads?.isComplete ?? false);
    }
  }

  /// Check if entire registration is complete (5 steps for new flow, 3 for old)
  bool get isComplete {
    // New flow: Personal → Professional → Address → Documents → Payment
    if (personalDetails != null && professionalDetails != null) {
      return personalDetails != null &&
          professionalDetails != null &&
          addressDetails != null &&
          documentUploads != null &&
          paymentDetails != null;
    }
    // Old flow: Membership → Address → Documents
    return membershipDetails != null &&
        addressDetails != null &&
        documentUploads != null;
  }

  /// Get completion percentage (0.0 to 1.0)
  double get completionPercentage {
    int completedSteps = 0;

    // Count completed steps based on flow
    if (personalDetails != null || professionalDetails != null) {
      // New flow (5 steps)
      if (personalDetails?.isComplete == true) completedSteps++;
      if (professionalDetails?.isComplete == true) completedSteps++;
      if (addressDetails?.isComplete == true) completedSteps++;
      if (documentUploads?.isComplete == true) completedSteps++;
      if (paymentDetails?.isComplete == true) completedSteps++;
    } else {
      // Old flow (3 steps)
      if (membershipDetails?.isComplete == true) completedSteps++;
      if (addressDetails?.isComplete == true) completedSteps++;
      if (documentUploads?.isComplete == true) completedSteps++;
    }

    return completedSteps / RegistrationStep.totalSteps;
  }

  PractitionerRegistration copyWith({
    String? registrationId,
    RegistrationStep? currentStep,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
    String? applicationId,
    PersonalDetails? personalDetails,
    ProfessionalDetails? professionalDetails,
    MembershipDetails? membershipDetails,
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
      personalDetails: personalDetails ?? this.personalDetails,
      professionalDetails: professionalDetails ?? this.professionalDetails,
      membershipDetails: membershipDetails ?? this.membershipDetails,
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
