import 'membership_details.dart';
import 'personal_details.dart';
import 'professional_details.dart';
import 'address_details.dart';
import 'document_upload.dart';
import 'registration_step.dart';

/// Payment status
enum PaymentStatus { pending, processing, completed, failed }

/// Payment details entity for Step 5
class PaymentDetails {
  final String sessionId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final String? transactionId;
  final String? paymentMethod;
  final DateTime? completedAt;

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
}

/// Main practitioner registration entity
class PractitionerRegistration {
  final String registrationId;
  final RegistrationStep currentStep;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;

  /// 🔹 Backend IDs
  final int? userId;
  final int? applicationId;

  final PersonalDetails? personalDetails;
  final ProfessionalDetails? professionalDetails;

  final MembershipDetails? membershipDetails;

  /// 👇 Multiple addresses supported
  final AddressDetails? addressDetails; // Communication Address
  final AddressDetails? aptaAddress; // APTA Mailing Address
  final AddressDetails? permanentAddress; // Permanent Address

  final DocumentUploads? documentUploads;
  final PaymentDetails? paymentDetails;

  const PractitionerRegistration({
    required this.registrationId,
    this.currentStep = RegistrationStep.personalDetails,
    required this.createdAt,
    required this.lastUpdatedAt,
    this.userId,
    this.applicationId,
    this.personalDetails,
    this.professionalDetails,
    this.membershipDetails,
    this.addressDetails,
    this.aptaAddress,
    this.permanentAddress,
    this.documentUploads,
    this.paymentDetails,
  });

  bool get isExpired {
    final now = DateTime.now();
    return now.isAfter(createdAt.add(const Duration(hours: 24)));
  }

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
        return membershipDetails?.isComplete ?? false;
    }
  }

  bool get canProceedToNext {
    if (!isStepComplete(currentStep)) return false;
    return arePreviousStepsValid();
  }

  bool arePreviousStepsValid() {
    switch (currentStep) {
      case RegistrationStep.personalDetails:
      case RegistrationStep.membershipDetails:
        return true;
      case RegistrationStep.professionalDetails:
        return personalDetails?.isComplete ?? false;
      case RegistrationStep.addressDetails:
        return (personalDetails?.isComplete ?? false) &&
            (professionalDetails?.isComplete ?? false);
      case RegistrationStep.documentUploads:
        return (personalDetails?.isComplete ?? false) &&
            (professionalDetails?.isComplete ?? false) &&
            (addressDetails?.isComplete ?? false);
      case RegistrationStep.payment:
        return (personalDetails?.isComplete ?? false) &&
            (professionalDetails?.isComplete ?? false) &&
            (addressDetails?.isComplete ?? false) &&
            (documentUploads?.isComplete ?? false);
    }
  }

  bool get isComplete {
    return personalDetails != null &&
        professionalDetails != null &&
        addressDetails != null &&
        documentUploads != null &&
        paymentDetails != null;
  }

  double get completionPercentage {
    int completed = 0;

    if (personalDetails?.isComplete == true) completed++;
    if (professionalDetails?.isComplete == true) completed++;
    if (addressDetails?.isComplete == true) completed++;
    if (documentUploads?.isComplete == true) completed++;
    if (paymentDetails?.isComplete == true) completed++;

    return completed / RegistrationStep.totalSteps;
  }

  PractitionerRegistration copyWith({
    String? registrationId,
    RegistrationStep? currentStep,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,

    int? userId,
    int? applicationId,

    PersonalDetails? personalDetails,
    ProfessionalDetails? professionalDetails,
    MembershipDetails? membershipDetails,

    AddressDetails? addressDetails,
    AddressDetails? aptaAddress,
    AddressDetails? permanentAddress,

    DocumentUploads? documentUploads,
    PaymentDetails? paymentDetails,
  }) {
    return PractitionerRegistration(
      registrationId: registrationId ?? this.registrationId,
      currentStep: currentStep ?? this.currentStep,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      userId: userId ?? this.userId,
      applicationId: applicationId ?? this.applicationId,
      personalDetails: personalDetails ?? this.personalDetails,
      professionalDetails: professionalDetails ?? this.professionalDetails,
      membershipDetails: membershipDetails ?? this.membershipDetails,
      addressDetails: addressDetails ?? this.addressDetails,
      aptaAddress: aptaAddress ?? this.aptaAddress,
      permanentAddress: permanentAddress ?? this.permanentAddress,
      documentUploads: documentUploads ?? this.documentUploads,
      paymentDetails: paymentDetails ?? this.paymentDetails,
    );
  }

  @override
  String toString() {
    return 'Registration(id: $registrationId, '
        'step: $currentStep, '
        'userId: $userId, appId: $applicationId, '
        'address: ${addressDetails != null}, '
        'apta: ${aptaAddress != null}, '
        'perm: ${permanentAddress != null})';
  }
}
