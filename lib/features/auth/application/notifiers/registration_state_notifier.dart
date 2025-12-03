import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/registration/practitioner_registration.dart';
import '../../domain/entities/registration/registration_step.dart';
import '../../domain/entities/registration/membership_details.dart';
import '../../domain/entities/registration/personal_details.dart';
import '../../domain/entities/registration/professional_details.dart';
import '../../domain/entities/registration/address_details.dart';
import '../../domain/entities/registration/document_upload.dart';
import '../../domain/entities/registration/registration_error.dart';
import '../../domain/repositories/registration_repository.dart';
import '../../infrastructure/data_sources/local/registration_local_ds.dart';
import '../../infrastructure/repositories/registration_repository_provider.dart';
import '../states/registration_state.dart';

/// Registration state notifier with auto-save to Hive
///
/// FORM DATA CACHING INTEGRATION:
/// - Auto-saves to Hive on every "Next" button
/// - Checks for incomplete registration on init (survives app restarts)
/// - Shows resume prompt if incomplete registration exists (<24h)
/// - Clears cache on successful submission
/// - Preserves data on failed submission for retry
///
/// FILE UPLOAD REQUIREMENTS:
/// - File uploads are one-time (deleted after successful submission)
/// - Files stored in app temporary directory during registration
/// - Files deleted from temp after successful submission
///
/// PAYMENT FLOW REQUIREMENTS:
/// - Payment is one-way (no retry after success)
/// - Once payment succeeds, submission cannot be retried
/// - Payment status validated before final submission
class RegistrationStateNotifier extends StateNotifier<RegistrationState> {
  final RegistrationRepository _repository;
  final RegistrationLocalDs _localDs;
  final Uuid _uuid = const Uuid();

  RegistrationStateNotifier({
    required RegistrationRepository repository,
    required RegistrationLocalDs localDs,
  }) : _repository = repository,
       _localDs = localDs,
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
        final registrationId = await _localDs.getRegistrationId() ?? _uuid.v4();

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
          personalDetails: personalData != null
              ? _personalFromJson(personalData)
              : null,
          professionalDetails: professionalData != null
              ? _professionalFromJson(professionalData)
              : null,
          addressDetails: addressData != null
              ? _addressFromJson(addressData)
              : null,
          documentUploads: documentData != null
              ? _documentsFromJson(documentData)
              : null,
          paymentDetails: paymentData != null
              ? _paymentFromJson(paymentData)
              : null,
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

  /// Update membership details (NEW Step 1 for 3-step flow)
  void updateMembershipDetails(MembershipDetails details) {
    final current = state;
    if (current is! RegistrationStateInProgress) return;

    final updated = current.registration.copyWith(
      membershipDetails: details,
      lastUpdatedAt: DateTime.now(),
    );

    state = current.copyWith(registration: updated, hasUnsavedChanges: true);
  }

  /// Update application ID (returned from Step 1 backend)
  void updateApplicationId(String applicationId) {
    final current = state;
    if (current is! RegistrationStateInProgress) return;

    final updated = current.registration.copyWith(
      applicationId: applicationId,
      lastUpdatedAt: DateTime.now(),
    );

    state = current.copyWith(registration: updated, hasUnsavedChanges: true);
  }

  /// Update personal details (DEPRECATED - old Step 1)
  void updatePersonalDetails(PersonalDetails details) {
    final current = state;
    if (current is! RegistrationStateInProgress) return;

    final updated = current.registration.copyWith(
      personalDetails: details,
      lastUpdatedAt: DateTime.now(),
    );

    state = current.copyWith(registration: updated, hasUnsavedChanges: true);
  }

  /// Update professional details (DEPRECATED - old Step 2)
  void updateProfessionalDetails(ProfessionalDetails details) {
    final current = state;
    if (current is! RegistrationStateInProgress) return;

    final updated = current.registration.copyWith(
      professionalDetails: details,
      lastUpdatedAt: DateTime.now(),
    );

    state = current.copyWith(registration: updated, hasUnsavedChanges: true);
  }

  /// Update address details (Step 3)
  void updateAddressDetails(AddressDetails details) {
    final current = state;
    if (current is! RegistrationStateInProgress) return;

    final updated = current.registration.copyWith(
      addressDetails: details,
      lastUpdatedAt: DateTime.now(),
    );

    state = current.copyWith(registration: updated, hasUnsavedChanges: true);
  }

  void updateAptaAddress(AddressDetails details) {
    final current = state;
    if (current is! RegistrationStateInProgress) return;

    final updated = current.registration.copyWith(
      aptaAddress: details,
      lastUpdatedAt: DateTime.now(),
    );

    state = current.copyWith(registration: updated, hasUnsavedChanges: true);
  }

  void updatePermanentAddress(AddressDetails details) {
    final current = state;
    if (current is! RegistrationStateInProgress) return;

    final updated = current.registration.copyWith(
      permanentAddress: details,
      lastUpdatedAt: DateTime.now(),
    );

    state = current.copyWith(registration: updated, hasUnsavedChanges: true);
  }

  /// Update document uploads (Step 4)
  void updateDocumentUploads(DocumentUploads documents) {
    final current = state;
    if (current is! RegistrationStateInProgress) return;

    final updated = current.registration.copyWith(
      documentUploads: documents,
      lastUpdatedAt: DateTime.now(),
    );

    state = current.copyWith(registration: updated, hasUnsavedChanges: true);
  }

  /// Update payment details (Step 5)
  void updatePaymentDetails(PaymentDetails payment) {
    final current = state;
    if (current is! RegistrationStateInProgress) return;

    final updated = current.registration.copyWith(
      paymentDetails: payment,
      lastUpdatedAt: DateTime.now(),
    );

    state = current.copyWith(registration: updated, hasUnsavedChanges: true);
  }

  /// Submit membership registration to backend (NEW: Combined Personal + Professional)
  /// Calls POST /api/membership/register/ with all required data
  Future<Map<String, dynamic>> submitMembershipRegistration(
    Map<String, dynamic> membershipData,
  ) async {
    return await _repository.submitMembershipRegistration(membershipData);
  }

  Future<Map<String, dynamic>> submitDocuments({
    required File documentFile,
    required int application,
    required String documentType,
  }) async {
    return await _repository.submitDocument(
      application: application,
      documentFile: documentFile,
      documentType: documentType,
    );
  }

  Future<Map<String, dynamic>> submitAddress({
    required Map<String, dynamic> data,
  }) async {
    return await _repository.submitAddress(data);
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
        message:
            'Please complete all required fields in ${registration.currentStep.displayName}',
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
  /// SCENARIO 3: Successful registration → Clear cache + delete files
  /// SCENARIO 4: Failed submission → Keep data for retry
  ///
  /// CRITICAL REQUIREMENTS:
  /// 1. Payment is one-way (no retry after success)
  /// 2. Files deleted after successful submission
  /// 3. Session validated before submission
  Future<void> submitRegistration() async {
    final current = state;
    if (current is! RegistrationStateInProgress) return;

    final registration = current.registration;

    // REQUIREMENT: Payment is one-way (prevent retry after success)
    if (registration.paymentDetails?.status == PaymentStatus.completed) {
      // Payment already completed - check if already submitted
      final isDuplicate = await _checkIfAlreadySubmitted(
        registration.personalDetails!.email,
      );
      if (isDuplicate) {
        state = RegistrationStateDuplicateRegistration(
          message: 'This registration has already been submitted',
          email: registration.personalDetails!.email,
          phone: registration.personalDetails!.phone,
        );
        return;
      }
    }

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
      // CRITICAL: Validate session before submission
      final sessionValid = await _repository.validateSession();
      if (!sessionValid) {
        state = RegistrationStateSessionExpired(
          message: 'Your session expired. Please login again',
          currentRegistration: registration,
        );
        return;
      }

      // Submit registration via repository
      final registrationId = await _repository.submitRegistration(
        registration: registration,
      );

      // SCENARIO 3: Successful registration
      // 1. Mark as complete in cache
      await _localDs.markRegistrationComplete();

      // 2. REQUIREMENT: Delete uploaded files (one-time use)
      await _deleteUploadedFiles(registration.documentUploads?.documents ?? []);

      // 3. Set success state
      state = RegistrationStateSuccess(
        registrationId: registrationId,
        message: 'Registration completed successfully!',
      );
    } on RegistrationError catch (e) {
      // SCENARIO 4: Failed submission - keep data for retry
      await _localDs.markSubmissionFailed();

      // Map error to appropriate state
      _handleRegistrationError(e, registration);
    } catch (e) {
      // Unexpected error
      await _localDs.markSubmissionFailed();

      state = RegistrationStateError(
        message: 'An unexpected error occurred. Please try again',
        code: 'UNKNOWN_ERROR',
        currentRegistration: registration,
        canRetry: true,
      );
    }
  }

  /// Check if registration already submitted (for payment retry prevention)
  Future<bool> _checkIfAlreadySubmitted(String email) async {
    try {
      return await _repository.checkDuplicateEmail(email: email);
    } catch (e) {
      // If check fails, allow submission attempt
      return false;
    }
  }

  /// Delete uploaded files after successful submission
  ///
  /// REQUIREMENT: File uploads are one-time (deleted after submission)
  Future<void> _deleteUploadedFiles(List<DocumentUpload> documents) async {
    for (final doc in documents) {
      try {
        final file = File(doc.localFilePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Silently fail - OS will handle cleanup
      }
    }
  }

  /// Handle registration errors and map to appropriate states
  void _handleRegistrationError(
    RegistrationError error,
    PractitionerRegistration registration,
  ) {
    switch (error.type) {
      case RegistrationErrorType.sessionExpired:
        state = RegistrationStateSessionExpired(
          message: error.message,
          currentRegistration: registration,
        );

      case RegistrationErrorType.duplicateEmail:
      case RegistrationErrorType.duplicatePhone:
        state = RegistrationStateDuplicateFound(
          message: error.message,
          duplicateField: error.duplicateField ?? 'email',
          currentRegistration: registration,
        );

      case RegistrationErrorType.serverValidation:
        state = RegistrationStateValidationError(
          message: error.message,
          fieldErrors: error.fieldErrors,
          currentRegistration: registration,
        );

      case RegistrationErrorType.paymentFailed:
        state = RegistrationStatePaymentFailed(
          message: error.message,
          currentRegistration: registration,
          paymentDetails: registration.paymentDetails!,
        );

      default:
        state = RegistrationStateError(
          message: error.message,
          code: error.code,
          currentRegistration: registration,
          canRetry: error.canRetry,
        );
    }
  }

  /// Retry failed submission
  ///
  /// REQUIREMENT: Payment is one-way (prevent retry after successful payment)
  Future<void> retrySubmission() async {
    final current = state;
    if (current is! RegistrationStateError) return;

    if (current.currentRegistration != null) {
      // REQUIREMENT: Prevent retry if payment already successful
      if (current.currentRegistration!.paymentDetails?.status ==
          PaymentStatus.completed) {
        state = RegistrationStateError(
          message:
              'Cannot retry - payment already completed. Please contact support',
          code: 'PAYMENT_ALREADY_COMPLETED',
          currentRegistration: current.currentRegistration,
          canRetry: false,
        );
        return;
      }

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
      'password': details.password,
      'phone': details.phone,
      'waPhone': details.waPhone,
      'dateOfBirth': details.dateOfBirth.toIso8601String(),
      'gender': details.gender,
      'bloodGroup': details.bloodGroup,
      'membershipType': details.membershipType,
      'profileImagePath': details.profileImagePath,
    };
  }

  /// Convert JSON to PersonalDetails entity
  PersonalDetails _personalFromJson(Map<String, dynamic> json) {
    return PersonalDetails(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      phone: json['phone'] as String,
      waPhone: json['waPhone'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      gender: json['gender'] as String,
      bloodGroup: json['bloodGroup'] as String,
      membershipType: json['membershipType'] as String,
      profileImagePath: json['profileImagePath'] as String?,
    );
  }

  /// Convert ProfessionalDetails entity to JSON
  Map<String, dynamic> _professionalToJson(ProfessionalDetails details) {
    return {
      'medicalCouncilState': details.medicalCouncilState,
      'medicalCouncilNo': details.medicalCouncilNo,
      'centralCouncilNo': details.centralCouncilNo,
      'ugCollege': details.ugCollege,

      'professionalDetails1': details.professionalDetails1,
      'professionalDetails2': details.professionalDetails2,
    };
  }

  /// Convert JSON to ProfessionalDetails entity
  ProfessionalDetails _professionalFromJson(Map<String, dynamic> json) {
    return ProfessionalDetails(
      medicalCouncilState: json['medicalCouncilState'] as String,
      medicalCouncilNo: json['medicalCouncilNo'] as String,
      centralCouncilNo: json['centralCouncilNo'] as String,
      ugCollege: json['ugCollege'] as String,

      professionalDetails1: json['professionalDetails1'] as String,
      professionalDetails2: json['professionalDetails2'] as String,
    );
  }

  /// Convert AddressDetails entity to JSON
  Map<String, dynamic> _addressToJson(AddressDetails details) {
    return {
      'addressLine1': details.addressLine1,
      'addressLine2': details.addressLine2,
      'city': details.city,
      'postalCode': details.postalCode,
      'countryId': details.countryId,
      'stateId': details.stateId,
      'districtId': details.districtId,
      'isPrimary': details.isPrimary,
    };
  }

  /// Convert JSON to AddressDetails entity
  AddressDetails _addressFromJson(Map<String, dynamic> json) {
    return AddressDetails(
      addressLine1: json['addressLine1'] as String,
      addressLine2: json['addressLine2'] as String,
      city: json['city'] as String,
      postalCode: json['postalCode'] as String,
      countryId: json['countryId'] as String,
      stateId: json['stateId'] as String,
      districtId: json['districtId'] as String,
      isPrimary: json['isPrimary'] as bool? ?? true,
      type: AddressType.values.firstWhere(
        (e) => e.name == (json['type'] ?? 'communication'),
        orElse: () => AddressType.communication,
      ),
    );
  }

  /// Convert DocumentUploads entity to JSON
  Map<String, dynamic> _documentsToJson(DocumentUploads uploads) {
    return {
      'documents': uploads.documents
          .map(
            (doc) => {
              'type': doc.type.name,
              'localFilePath': doc.localFilePath,
              'fileName': doc.fileName,
              'fileSizeBytes': doc.fileSizeBytes,
              'uploadedAt': doc.uploadedAt.toIso8601String(),
              'serverUrl': doc.serverUrl,
            },
          )
          .toList(),
    };
  }

  /// Convert JSON to DocumentUploads entity
  DocumentUploads _documentsFromJson(Map<String, dynamic> json) {
    final documents =
        (json['documents'] as List<dynamic>?)?.map((doc) {
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
        }).toList() ??
        [];

    return DocumentUploads(documents: documents);
  }

  /// Convert PaymentDetails entity to JSON
  Map<String, dynamic> _paymentToJson(PaymentDetails details) {
    return {
      'sessionId': details.sessionId,
      'amount': details.amount,
      'currency': details.currency,
      'status': details.status.name,
      'transactionId': details.transactionId,
      'paymentMethod': details.paymentMethod,
      'completedAt': details.completedAt?.toIso8601String(),
    };
  }

  /// Convert JSON to PaymentDetails entity
  PaymentDetails _paymentFromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      sessionId: json['sessionId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      status: PaymentStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      transactionId: json['transactionId'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}

/// Provider for RegistrationStateNotifier
final registrationProvider =
    StateNotifierProvider<RegistrationStateNotifier, RegistrationState>((ref) {
      final repository = ref.watch(registrationRepositoryProvider);
      final localDs = ref.watch(registrationLocalDsProvider);

      return RegistrationStateNotifier(
        repository: repository,
        localDs: localDs,
      );
    });
