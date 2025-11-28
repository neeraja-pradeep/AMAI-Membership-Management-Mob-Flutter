import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/registration/practitioner_registration.dart';
import '../../domain/entities/registration/registration_step.dart';
import '../../domain/entities/registration/personal_details.dart';
import '../../domain/entities/registration/professional_details.dart';
import '../../domain/entities/registration/address_details.dart';
import '../../domain/entities/registration/document_upload.dart';
import '../../infrastructure/data_sources/local/registration_local_ds.dart';
import '../states/registration_state.dart';

/// Registration state notifier with auto-save to Hive
///
/// FORM DATA CACHING INTEGRATION:
/// - Auto-saves to Hive on every "Next" button
/// - Checks for incomplete registration on init
/// - Shows resume prompt if incomplete registration exists (<24h)
/// - Clears cache on successful submission
/// - Preserves data on failed submission for retry
class RegistrationStateNotifier extends StateNotifier<RegistrationState> {
  final RegistrationLocalDs _localDs;
  final Uuid _uuid = const Uuid();

  RegistrationStateNotifier({
    required RegistrationLocalDs localDs,
  })  : _localDs = localDs,
        super(const RegistrationStateInitial()) {
    _checkExistingRegistration();
  }

  /// Check for existing incomplete registration on initialization
  ///
  /// SCENARIO 2: User re-enters registration
  /// - Check reg_incomplete_flag
  /// - If true: Show dialog "Continue previous registration?"
  Future<void> _checkExistingRegistration() async {
    final hasIncomplete = await _localDs.hasIncompleteRegistration();

    if (hasIncomplete) {
      try {
        // Load timestamps and current step
        final timestamps = await _localDs.getRegistrationTimestamps();
        final currentStep = await _localDs.getCurrentStep() ?? 1;
        final registrationId =
            await _localDs.getRegistrationId() ?? _uuid.v4();

        // Load all step data
        final personalData = await _localDs.getPersonalDetails();
        final professionalData = await _localDs.getProfessionalDetails();
        final addressData = await _localDs.getAddressDetails();
        final documentData = await _localDs.getDocumentUploads();
        final paymentData = await _localDs.getPaymentDetails();

        // Convert to entities
        final registration = PractitionerRegistration(
          registrationId: registrationId,
          currentStep: RegistrationStep.values[currentStep - 1],
          createdAt: timestamps!['createdAt']!,
          lastUpdatedAt: timestamps['lastUpdatedAt']!,
          personalDetails:
              personalData != null ? _personalFromJson(personalData) : null,
          professionalDetails: professionalData != null
              ? _professionalFromJson(professionalData)
              : null,
          addressDetails:
              addressData != null ? _addressFromJson(addressData) : null,
          documentUploads:
              documentData != null ? _documentsFromJson(documentData) : null,
          paymentDetails:
              paymentData != null ? _paymentFromJson(paymentData) : null,
        );

        // Show resume prompt
        state = RegistrationStateResumePrompt(
          existingRegistration: registration,
        );
      } catch (e) {
        // If error loading data, clear and start fresh
        await _localDs.clearAllRegistrationData();
        state = const RegistrationStateInitial();
      }
    }
  }

  /// Resume existing registration
  ///
  /// SCENARIO 2: User chooses "Continue" on resume dialog
  /// - Load all reg_* keys from Hive
  /// - Populate all form fields from cached data
  /// - Navigate to reg_current_step screen
  void resumeRegistration(PractitionerRegistration existingRegistration) {
    state = RegistrationStateInProgress(
      registration: existingRegistration,
      hasUnsavedChanges: false,
    );
  }

  /// Start fresh registration (clear cache)
  ///
  /// SCENARIO 2: User chooses "Start Fresh" on resume dialog
  /// - Clear all reg_* keys from Hive
  /// - Set reg_incomplete_flag = false
  /// - Start fresh from Screen 1
  Future<void> startFreshRegistration() async {
    await _localDs.clearAllRegistrationData();

    final now = DateTime.now();
    final registration = PractitionerRegistration(
      registrationId: _uuid.v4(),
      currentStep: RegistrationStep.personalDetails,
      createdAt: now,
      lastUpdatedAt: now,
    );

    state = RegistrationStateInProgress(
      registration: registration,
      hasUnsavedChanges: false,
    );
  }

  /// Start new registration
  void startNewRegistration() {
    final now = DateTime.now();
    final registration = PractitionerRegistration(
      registrationId: _uuid.v4(),
      currentStep: RegistrationStep.personalDetails,
      createdAt: now,
      lastUpdatedAt: now,
    );

    state = RegistrationStateInProgress(
      registration: registration,
      hasUnsavedChanges: false,
    );
  }

  /// Update personal details (Step 1)
  void updatePersonalDetails(PersonalDetails details) {
    final current = state;
    if (current is! RegistrationStateInProgress) return;

    final updated = current.registration.copyWith(
      personalDetails: details,
      lastUpdatedAt: DateTime.now(),
    );

    state = current.copyWith(
      registration: updated,
      hasUnsavedChanges: true,
    );
  }

  /// Update professional details (Step 2)
  void updateProfessionalDetails(ProfessionalDetails details) {
    final current = state;
    if (current is! RegistrationStateInProgress) return;

    final updated = current.registration.copyWith(
      professionalDetails: details,
      lastUpdatedAt: DateTime.now(),
    );

    state = current.copyWith(
      registration: updated,
      hasUnsavedChanges: true,
    );
  }

  /// Update address details (Step 3)
  void updateAddressDetails(AddressDetails details) {
    final current = state;
    if (current is! RegistrationStateInProgress) return;

    final updated = current.registration.copyWith(
      addressDetails: details,
      lastUpdatedAt: DateTime.now(),
    );

    state = current.copyWith(
      registration: updated,
      hasUnsavedChanges: true,
    );
  }

  /// Update document uploads (Step 4)
  void updateDocumentUploads(DocumentUploads documents) {
    final current = state;
    if (current is! RegistrationStateInProgress) return;

    final updated = current.registration.copyWith(
      documentUploads: documents,
      lastUpdatedAt: DateTime.now(),
    );

    state = current.copyWith(
      registration: updated,
      hasUnsavedChanges: true,
    );
  }

  /// Update payment details (Step 5)
  void updatePaymentDetails(PaymentDetails payment) {
    final current = state;
    if (current is! RegistrationStateInProgress) return;

    final updated = current.registration.copyWith(
      paymentDetails: payment,
      lastUpdatedAt: DateTime.now(),
    );

    state = current.copyWith(
      registration: updated,
      hasUnsavedChanges: true,
    );
  }

  /// Go to next step (with validation and auto-save)
  ///
  /// SCENARIO 1: User clicks "Next"
  /// - Validate current step
  /// - Save to Hive (auto-save)
  /// - Navigate to next step
  Future<void> goToNextStep() async {
    final current = state;
    if (current is! RegistrationStateInProgress) return;

    final registration = current.registration;

    // Validate current step
    if (!registration.canProceedToNext) {
      state = RegistrationStateValidationError(
        message: 'Please complete all required fields in ${registration.currentStep.displayName}',
        currentRegistration: registration,
      );
      return;
    }

    // Auto-save to Hive
    await autoSaveProgress();

    // Move to next step
    final nextStep = registration.currentStep.next;
    if (nextStep == null) return; // Already on last step

    final updated = registration.copyWith(
      currentStep: nextStep,
      lastUpdatedAt: DateTime.now(),
    );

    state = RegistrationStateInProgress(
      registration: updated,
      hasUnsavedChanges: false,
    );
  }

  /// Go to previous step (no validation, no save)
  ///
  /// Back navigation: Allowed on all screens without validation
  void goToPreviousStep() {
    final current = state;
    if (current is! RegistrationStateInProgress) return;

    final registration = current.registration;
    final prevStep = registration.currentStep.previous;
    if (prevStep == null) return; // Already on first step

    final updated = registration.copyWith(
      currentStep: prevStep,
      lastUpdatedAt: DateTime.now(),
    );

    state = RegistrationStateInProgress(
      registration: updated,
      hasUnsavedChanges: current.hasUnsavedChanges,
    );
  }

  /// Auto-save progress to Hive
  ///
  /// SCENARIO 1: User exits mid-registration
  /// - Save current screen data to Hive
  /// - Set reg_incomplete_flag = true
  /// - Store reg_current_step = X
  Future<void> autoSaveProgress() async {
    final current = state;
    if (current is! RegistrationStateInProgress) return;

    final registration = current.registration;

    try {
      await _localDs.saveRegistrationState(
        registrationId: registration.registrationId,
        currentStep: registration.currentStep.stepNumber,
        createdAt: registration.createdAt,
        personalDetails: registration.personalDetails != null
            ? _personalToJson(registration.personalDetails!)
            : null,
        professionalDetails: registration.professionalDetails != null
            ? _professionalToJson(registration.professionalDetails!)
            : null,
        addressDetails: registration.addressDetails != null
            ? _addressToJson(registration.addressDetails!)
            : null,
        documentUploads: registration.documentUploads != null
            ? _documentsToJson(registration.documentUploads!)
            : null,
        paymentDetails: registration.paymentDetails != null
            ? _paymentToJson(registration.paymentDetails!)
            : null,
      );

      // Mark as saved
      state = current.copyWith(hasUnsavedChanges: false);
    } catch (e) {
      // Silently fail - user can retry
    }
  }

  /// Submit registration (final step)
  ///
  /// SCENARIO 3: Successful registration → Clear cache
  /// SCENARIO 4: Failed submission → Keep data for retry
  Future<void> submitRegistration() async {
    final current = state;
    if (current is! RegistrationStateInProgress) return;

    final registration = current.registration;

    // Validate entire registration
    if (!registration.isComplete) {
      state = RegistrationStateValidationError(
        message: 'Please complete all registration steps',
        currentRegistration: registration,
      );
      return;
    }

    state = const RegistrationStateLoading(
      message: 'Submitting registration...',
    );

    try {
      // TODO: Call repository to submit registration
      // final registrationId = await _repository.submitRegistration(
      //   registration: registration,
      // );

      // SCENARIO 3: Successful registration
      await _localDs.markRegistrationComplete();

      // Mock success for now
      await Future.delayed(const Duration(seconds: 2));

      state = RegistrationStateSuccess(
        registrationId: registration.registrationId,
        message: 'Registration completed successfully!',
      );
    } catch (e) {
      // SCENARIO 4: Failed submission - keep data for retry
      await _localDs.markSubmissionFailed();

      state = RegistrationStateError(
        message: e.toString(),
        currentRegistration: registration,
      );
    }
  }

  /// Retry failed submission
  Future<void> retrySubmission() async {
    final current = state;
    if (current is! RegistrationStateError) return;

    if (current.currentRegistration != null) {
      state = RegistrationStateInProgress(
        registration: current.currentRegistration!,
        hasUnsavedChanges: false,
      );

      await submitRegistration();
    }
  }

  // ============================================================================
  // JSON CONVERSION HELPERS
  // ============================================================================

  /// Convert PersonalDetails entity to JSON
  Map<String, dynamic> _personalToJson(PersonalDetails details) {
    return {
      'firstName': details.firstName,
      'lastName': details.lastName,
      'email': details.email,
      'phone': details.phone,
      'dateOfBirth': details.dateOfBirth.toIso8601String(),
      'gender': details.gender,
      'profileImagePath': details.profileImagePath,
    };
  }

  /// Convert JSON to PersonalDetails entity
  PersonalDetails _personalFromJson(Map<String, dynamic> json) {
    return PersonalDetails(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      gender: json['gender'] as String,
      profileImagePath: json['profileImagePath'] as String?,
    );
  }

  /// Convert ProfessionalDetails entity to JSON
  Map<String, dynamic> _professionalToJson(ProfessionalDetails details) {
    return {
      'medicalCouncilRegistrationNumber':
          details.medicalCouncilRegistrationNumber,
      'medicalCouncil': details.medicalCouncil,
      'registrationDate': details.registrationDate.toIso8601String(),
      'qualification': details.qualification,
      'specialization': details.specialization,
      'instituteName': details.instituteName,
      'yearsOfExperience': details.yearsOfExperience,
      'currentWorkplace': details.currentWorkplace,
      'designation': details.designation,
    };
  }

  /// Convert JSON to ProfessionalDetails entity
  ProfessionalDetails _professionalFromJson(Map<String, dynamic> json) {
    return ProfessionalDetails(
      medicalCouncilRegistrationNumber:
          json['medicalCouncilRegistrationNumber'] as String,
      medicalCouncil: json['medicalCouncil'] as String,
      registrationDate: DateTime.parse(json['registrationDate'] as String),
      qualification: json['qualification'] as String,
      specialization: json['specialization'] as String?,
      instituteName: json['instituteName'] as String?,
      yearsOfExperience: json['yearsOfExperience'] as int,
      currentWorkplace: json['currentWorkplace'] as String?,
      designation: json['designation'] as String?,
    );
  }

  /// Convert AddressDetails entity to JSON
  Map<String, dynamic> _addressToJson(AddressDetails details) {
    return {
      'addressLine1': details.addressLine1,
      'addressLine2': details.addressLine2,
      'city': details.city,
      'state': details.state,
      'pincode': details.pincode,
      'country': details.country,
    };
  }

  /// Convert JSON to AddressDetails entity
  AddressDetails _addressFromJson(Map<String, dynamic> json) {
    return AddressDetails(
      addressLine1: json['addressLine1'] as String,
      addressLine2: json['addressLine2'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      pincode: json['pincode'] as String,
      country: json['country'] as String,
    );
  }

  /// Convert DocumentUploads entity to JSON
  Map<String, dynamic> _documentsToJson(DocumentUploads uploads) {
    return {
      'documents': uploads.documents
          .map((doc) => {
                'type': doc.type.name,
                'localFilePath': doc.localFilePath,
                'fileName': doc.fileName,
                'fileSizeBytes': doc.fileSizeBytes,
                'uploadedAt': doc.uploadedAt.toIso8601String(),
                'serverUrl': doc.serverUrl,
              })
          .toList(),
    };
  }

  /// Convert JSON to DocumentUploads entity
  DocumentUploads _documentsFromJson(Map<String, dynamic> json) {
    final documents = (json['documents'] as List<dynamic>?)
            ?.map((doc) {
              final docMap = doc as Map<String, dynamic>;
              return DocumentUpload(
                type: DocumentType.values.firstWhere(
                  (type) => type.name == docMap['type'],
                ),
                localFilePath: docMap['localFilePath'] as String,
                fileName: docMap['fileName'] as String,
                fileSizeBytes: docMap['fileSizeBytes'] as int,
                uploadedAt: DateTime.parse(docMap['uploadedAt'] as String),
                serverUrl: docMap['serverUrl'] as String?,
              );
            })
            .toList() ??
        [];

    return DocumentUploads(documents: documents);
  }

  /// Convert PaymentDetails entity to JSON
  Map<String, dynamic> _paymentToJson(PaymentDetails details) {
    return {
      'amount': details.amount,
      'currency': details.currency,
      'status': details.status.name,
      'transactionId': details.transactionId,
      'paymentMethod': details.paymentMethod,
      'paymentDate': details.paymentDate?.toIso8601String(),
    };
  }

  /// Convert JSON to PaymentDetails entity
  PaymentDetails _paymentFromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      status: PaymentStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      transactionId: json['transactionId'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'] as String)
          : null,
    );
  }
}

/// Provider for RegistrationStateNotifier
final registrationProvider =
    StateNotifierProvider<RegistrationStateNotifier, RegistrationState>(
  (ref) => RegistrationStateNotifier(
    localDs: RegistrationLocalDs(),
  ),
);
