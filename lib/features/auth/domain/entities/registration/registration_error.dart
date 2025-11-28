/// Registration error types
///
/// Categorizes all possible errors during registration flow
enum RegistrationErrorType {
  /// Dropdown loading errors
  dropdownNetworkFailure,
  dropdownNotFound,
  dropdownEmpty,

  /// Form validation errors
  clientValidation,
  serverValidation,

  /// File upload errors
  fileTooLarge,
  invalidFileType,
  uploadNetworkFailure,
  fileCorrupted,

  /// Submission errors
  networkTimeout,
  duplicateEmail,
  duplicatePhone,
  sessionExpired,
  paymentFailed,
  serverError,
  unknownError,
}

/// Registration error entity
///
/// Contains error details for display and handling
class RegistrationError {
  final RegistrationErrorType type;
  final String message;
  final String? code;
  final Map<String, String>? fieldErrors;
  final bool canRetry;
  final String? duplicateField;

  const RegistrationError({
    required this.type,
    required this.message,
    this.code,
    this.fieldErrors,
    this.canRetry = false,
    this.duplicateField,
  });

  /// Create network timeout error
  factory RegistrationError.networkTimeout() {
    return const RegistrationError(
      type: RegistrationErrorType.networkTimeout,
      message: 'Request timed out. Check internet and retry',
      code: 'TIMEOUT',
      canRetry: true,
    );
  }

  /// Create duplicate email error
  factory RegistrationError.duplicateEmail(String message) {
    return RegistrationError(
      type: RegistrationErrorType.duplicateEmail,
      message: message,
      code: 'DUPLICATE_EMAIL',
      canRetry: false,
      duplicateField: 'email',
    );
  }

  /// Create duplicate phone error
  factory RegistrationError.duplicatePhone(String message) {
    return RegistrationError(
      type: RegistrationErrorType.duplicatePhone,
      message: message,
      code: 'DUPLICATE_PHONE',
      canRetry: false,
      duplicateField: 'phone',
    );
  }

  /// Create session expired error
  factory RegistrationError.sessionExpired() {
    return const RegistrationError(
      type: RegistrationErrorType.sessionExpired,
      message: 'Your session expired. Please login again',
      code: 'UNAUTHORIZED',
      canRetry: false,
    );
  }

  /// Create payment failed error
  factory RegistrationError.paymentFailed(String message) {
    return RegistrationError(
      type: RegistrationErrorType.paymentFailed,
      message: message,
      code: 'PAYMENT_FAILED',
      canRetry: true,
    );
  }

  /// Create server error
  factory RegistrationError.serverError() {
    return const RegistrationError(
      type: RegistrationErrorType.serverError,
      message: 'Something went wrong. Please try again',
      code: 'SERVER_ERROR',
      canRetry: true,
    );
  }

  /// Create validation error with field errors
  factory RegistrationError.validation(Map<String, String> fieldErrors) {
    return RegistrationError(
      type: RegistrationErrorType.serverValidation,
      message: 'Please fix the errors',
      code: 'VALIDATION_ERROR',
      fieldErrors: fieldErrors,
      canRetry: false,
    );
  }

  /// Create dropdown network error
  factory RegistrationError.dropdownNetwork(String dropdownName) {
    return RegistrationError(
      type: RegistrationErrorType.dropdownNetworkFailure,
      message: 'Failed to load $dropdownName',
      code: 'DROPDOWN_NETWORK_ERROR',
      canRetry: true,
    );
  }

  /// Create dropdown not found error
  factory RegistrationError.dropdownNotFound(String dropdownName) {
    return RegistrationError(
      type: RegistrationErrorType.dropdownNotFound,
      message: 'Data not available at the moment',
      code: 'DROPDOWN_NOT_FOUND',
      canRetry: false,
    );
  }

  /// Create file too large error
  factory RegistrationError.fileTooLarge(int maxSizeMB) {
    return RegistrationError(
      type: RegistrationErrorType.fileTooLarge,
      message: 'File size exceeds ${maxSizeMB}MB limit',
      code: 'FILE_TOO_LARGE',
      canRetry: false,
    );
  }

  /// Create invalid file type error
  factory RegistrationError.invalidFileType(List<String> allowedTypes) {
    return RegistrationError(
      type: RegistrationErrorType.invalidFileType,
      message: 'Invalid file type. Allowed: ${allowedTypes.join(", ")}',
      code: 'INVALID_FILE_TYPE',
      canRetry: false,
    );
  }

  /// Create upload failure error
  factory RegistrationError.uploadFailure() {
    return const RegistrationError(
      type: RegistrationErrorType.uploadNetworkFailure,
      message: 'Upload failed. Please try again',
      code: 'UPLOAD_FAILED',
      canRetry: true,
    );
  }

  /// Create corrupted file error
  factory RegistrationError.fileCorrupted() {
    return const RegistrationError(
      type: RegistrationErrorType.fileCorrupted,
      message: 'File is corrupted or unreadable',
      code: 'FILE_CORRUPTED',
      canRetry: false,
    );
  }

  /// Check if error is for duplicate registration
  bool get isDuplicate =>
      type == RegistrationErrorType.duplicateEmail ||
      type == RegistrationErrorType.duplicatePhone;

  /// Check if error requires navigation to different screen
  bool get requiresNavigation =>
      isDuplicate || type == RegistrationErrorType.sessionExpired;

  /// Check if error is related to file upload
  bool get isFileUploadError =>
      type == RegistrationErrorType.fileTooLarge ||
      type == RegistrationErrorType.invalidFileType ||
      type == RegistrationErrorType.uploadNetworkFailure ||
      type == RegistrationErrorType.fileCorrupted;

  /// Check if error is related to dropdown
  bool get isDropdownError =>
      type == RegistrationErrorType.dropdownNetworkFailure ||
      type == RegistrationErrorType.dropdownNotFound ||
      type == RegistrationErrorType.dropdownEmpty;

  @override
  String toString() {
    return 'RegistrationError(type: $type, message: $message, code: $code, canRetry: $canRetry)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegistrationError &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          message == other.message &&
          code == other.code;

  @override
  int get hashCode => type.hashCode ^ message.hashCode ^ (code?.hashCode ?? 0);
}

/// Dropdown error for specific dropdown field
class DropdownError {
  final String dropdownName;
  final RegistrationError error;
  final DateTime occurredAt;

  const DropdownError({
    required this.dropdownName,
    required this.error,
    required this.occurredAt,
  });

  bool get canRetry => error.canRetry;
  String get message => error.message;

  @override
  String toString() {
    return 'DropdownError(dropdown: $dropdownName, error: ${error.message})';
  }
}

/// File upload error for specific document
class FileUploadError {
  final String fileName;
  final RegistrationError error;
  final DateTime occurredAt;
  final int attemptCount;

  const FileUploadError({
    required this.fileName,
    required this.error,
    required this.occurredAt,
    this.attemptCount = 1,
  });

  bool get canRetry => error.canRetry && attemptCount < 3;
  String get message => error.message;

  FileUploadError incrementAttempt() {
    return FileUploadError(
      fileName: fileName,
      error: error,
      occurredAt: occurredAt,
      attemptCount: attemptCount + 1,
    );
  }

  @override
  String toString() {
    return 'FileUploadError(file: $fileName, error: ${error.message}, attempts: $attemptCount)';
  }
}
