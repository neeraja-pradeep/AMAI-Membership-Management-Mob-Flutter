import '../../domain/entities/practitioner_registration.dart';
import '../../domain/entities/registration_step.dart';

/// Registration state for multi-step form
///
/// Tracks current step, validation status, and data persistence
sealed class RegistrationState {
  const RegistrationState();
}

/// Initial state (checking for existing registration)
final class RegistrationStateInitial extends RegistrationState {
  const RegistrationStateInitial();

  @override
  String toString() => 'RegistrationState.initial()';
}

/// Loading state (saving to Hive or calling API)
final class RegistrationStateLoading extends RegistrationState {
  final String? message;

  const RegistrationStateLoading({this.message});

  @override
  String toString() => 'RegistrationState.loading(message: $message)';
}

/// In-progress state (actively filling out registration)
final class RegistrationStateInProgress extends RegistrationState {
  final PractitionerRegistration registration;
  final bool hasUnsavedChanges;

  const RegistrationStateInProgress({
    required this.registration,
    this.hasUnsavedChanges = false,
  });

  /// Get current step
  RegistrationStep get currentStep => registration.currentStep;

  /// Check if can go back
  bool get canGoBack => !currentStep.isFirst;

  /// Check if can go forward
  bool get canGoForward =>
      registration.canProceedToNext && !currentStep.isLast;

  /// Check if can submit (on payment step with payment complete)
  bool get canSubmit =>
      currentStep.isLast && registration.paymentDetails?.isComplete == true;

  RegistrationStateInProgress copyWith({
    PractitionerRegistration? registration,
    bool? hasUnsavedChanges,
  }) {
    return RegistrationStateInProgress(
      registration: registration ?? this.registration,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }

  @override
  String toString() {
    return 'RegistrationState.inProgress(step: ${currentStep.displayName}, unsaved: $hasUnsavedChanges, completion: ${(registration.completionPercentage * 100).toStringAsFixed(0)}%)';
  }
}

/// Resume prompt state (incomplete registration found in Hive)
final class RegistrationStateResumePrompt extends RegistrationState {
  final PractitionerRegistration existingRegistration;

  const RegistrationStateResumePrompt({
    required this.existingRegistration,
  });

  @override
  String toString() {
    return 'RegistrationState.resumePrompt(completion: ${(existingRegistration.completionPercentage * 100).toStringAsFixed(0)}%)';
  }
}

/// Validation error state (cannot proceed to next step)
final class RegistrationStateValidationError extends RegistrationState {
  final String message;
  final Map<String, String>? fieldErrors;
  final PractitionerRegistration currentRegistration;

  const RegistrationStateValidationError({
    required this.message,
    this.fieldErrors,
    required this.currentRegistration,
  });

  /// Get error for specific field
  String? getFieldError(String fieldName) {
    return fieldErrors?[fieldName];
  }

  @override
  String toString() {
    return 'RegistrationState.validationError(message: $message, fieldErrors: ${fieldErrors?.length ?? 0})';
  }
}

/// Error state (API or save error)
final class RegistrationStateError extends RegistrationState {
  final String message;
  final String? code;
  final PractitionerRegistration? currentRegistration;

  const RegistrationStateError({
    required this.message,
    this.code,
    this.currentRegistration,
  });

  @override
  String toString() {
    return 'RegistrationState.error(message: $message, code: $code)';
  }
}

/// Success state (registration complete)
final class RegistrationStateSuccess extends RegistrationState {
  final String registrationId;
  final String message;

  const RegistrationStateSuccess({
    required this.registrationId,
    this.message = 'Registration completed successfully!',
  });

  @override
  String toString() {
    return 'RegistrationState.success(id: $registrationId, message: $message)';
  }
}
