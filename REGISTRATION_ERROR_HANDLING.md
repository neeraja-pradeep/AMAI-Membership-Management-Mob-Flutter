# Registration Error Handling Strategy - Implementation Guide

## Overview
Comprehensive error handling strategy for the 5-step practitioner registration flow covering dropdown loading, form validation, file uploads, and final submission errors.

---

## 📋 Error Categories

### **1. Dropdown Loading Errors**
### **2. Form Validation Errors** (Client-Side & Server-Side)
### **3. File Upload Errors**
### **4. Submission Errors**

---

## 🔽 Dropdown Loading Errors

### **Scenario 1: Network Failure**

**Trigger:** Network unavailable or timeout while fetching dropdown data

**UI Behavior:**
```dart
// Dropdown with error state
DropdownButtonFormField(
  decoration: InputDecoration(
    labelText: 'Medical Council',
    errorText: isError ? 'Failed to load medical councils' : null,
    suffixIcon: isError
        ? IconButton(
            icon: const Icon(Icons.refresh, color: Colors.red),
            onPressed: () => _retryLoadDropdown(),
          )
        : null,
  ),
  items: [], // Empty when error
  onChanged: null, // Disabled when error
)
```

**Implementation:**
```dart
// In Screen widget
class _ProfessionalDetailsScreenState extends ConsumerState {
  bool _councilsLoading = true;
  bool _councilsError = false;
  List<String> _medicalCouncils = [];

  @override
  void initState() {
    super.initState();
    _loadMedicalCouncils();
  }

  Future<void> _loadMedicalCouncils() async {
    setState(() {
      _councilsLoading = true;
      _councilsError = false;
    });

    try {
      final councils = await ref
          .read(registrationDropdownProvider)
          .getMedicalCouncils();

      setState(() {
        _medicalCouncils = councils;
        _councilsLoading = false;
      });
    } catch (e) {
      setState(() {
        _councilsError = true;
        _councilsLoading = false;
      });

      // Show inline error (already in UI via errorText)
      // Don't block other dropdowns
    }
  }

  Future<void> _retryLoadDropdown() async {
    await _loadMedicalCouncils();
  }
}
```

**Key Points:**
- ✅ Show inline error with retry button
- ✅ Don't block other dropdowns
- ✅ Keep form functional
- ❌ Don't show modal dialogs

---

### **Scenario 2: 404 Not Found (Dropdown Endpoint)**

**Trigger:** API endpoint for dropdown data doesn't exist

**UI Behavior:**
```dart
DropdownButtonFormField(
  decoration: const InputDecoration(
    labelText: 'Specialization',
    errorText: 'Data not available at the moment',
  ),
  items: const [],
  onChanged: null, // Disabled
)
```

**Implementation:**
```dart
Future<void> _loadSpecializations() async {
  try {
    final specializations = await _api.getSpecializations();
    setState(() => _specializations = specializations);
  } on NotFoundException catch (e) {
    // Log to analytics
    _analytics.logError('dropdown_404', {
      'endpoint': e.endpoint,
      'dropdown': 'specializations',
    });

    setState(() {
      _specializationsError = true;
      _specializationErrorMessage = 'Data not available at the moment';
    });

    // Disable dependent fields
    _disableDependentFields();
  }
}

void _disableDependentFields() {
  // If specialization dropdown fails, disable sub-specialization
  setState(() {
    _subSpecializationEnabled = false;
  });
}
```

**Key Points:**
- ✅ Log error to analytics
- ✅ Show user-friendly message
- ✅ Disable dependent fields
- ❌ Don't retry automatically

---

### **Scenario 3: Empty Dropdown**

**Trigger:** API returns empty array (no data available)

**UI Behavior:**
```dart
DropdownButtonFormField(
  decoration: const InputDecoration(
    labelText: 'Sub-Specialization',
    hintText: 'No options available',
  ),
  items: const [], // Empty but not error styling
  onChanged: null,
)
```

**Implementation:**
```dart
Future<void> _loadSubSpecializations() async {
  final subSpecs = await _api.getSubSpecializations();

  if (subSpecs.isEmpty) {
    setState(() {
      _subSpecializations = [];
      _subSpecializationHint = 'No options available';
    });

    // Allow proceeding if field is optional
    // Don't show error styling
  } else {
    setState(() => _subSpecializations = subSpecs);
  }
}
```

**Key Points:**
- ✅ Show "No options available"
- ❌ Don't show error styling
- ✅ Allow proceeding if optional

---

## ✅ Form Validation Errors

### **Client-Side Validation**

**Trigger:** User input fails local validation rules

**UI Behavior:**
```dart
TextFormField(
  controller: _emailController,
  decoration: InputDecoration(
    labelText: 'Email',
    errorText: _emailError, // Only shown on blur or submit
  ),
  validator: (value) {
    if (value?.isEmpty == true) return 'Email is required';
    if (!_isValidEmail(value!)) return 'Invalid email format';
    return null;
  },
  onChanged: (value) {
    // Don't show errors on every keystroke
    if (_emailError != null) {
      // Clear error if user is typing
      setState(() => _emailError = null);
    }
  },
  onTap: () {
    // Clear error on focus
    setState(() => _emailError = null);
  },
)
```

**Implementation:**
```dart
class _PersonalDetailsScreenState extends ConsumerState {
  final _formKey = GlobalKey<FormState>();
  String? _emailError;
  String? _phoneError;

  // Show errors on blur
  FocusNode _emailFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onEmailFocusChange);
  }

  void _onEmailFocusChange() {
    if (!_emailFocusNode.hasFocus) {
      // Field lost focus (blur) - validate
      _validateEmail();
    } else {
      // Field gained focus - clear error
      setState(() => _emailError = null);
    }
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required');
    } else if (!_isValidEmail(email)) {
      setState(() => _emailError = 'Invalid email format');
    } else {
      setState(() => _emailError = null);
    }
  }

  Future<void> _onNextPressed() async {
    // Show all validation errors on submit
    if (!_formKey.currentState!.validate()) {
      // Scroll to first error
      _scrollToFirstError();
      return;
    }

    // Proceed to next screen
  }
}
```

**Validation Timing:**
- ✅ On blur (field loses focus)
- ✅ On submit button click
- ✅ Clear on focus
- ❌ Not on every keystroke

---

### **Server-Side Validation (400/422)**

**Trigger:** API returns validation errors

**Error Response Format:**
```json
{
  "status": 422,
  "errors": {
    "email": ["Email is already registered"],
    "phone": ["Invalid phone format"],
    "medicalCouncilNumber": ["Number already exists"]
  }
}
```

**Implementation:**
```dart
Future<void> _submitRegistration() async {
  try {
    await ref.read(registrationProvider.notifier).submitRegistration();
  } on ValidationException catch (e) {
    // Parse error response
    final errors = e.fieldErrors; // Map<String, String>

    // Map errors to fields on current screen
    if (errors.containsKey('email')) {
      setState(() => _emailError = errors['email']);
    }
    if (errors.containsKey('phone')) {
      setState(() => _phoneError = errors['phone']);
    }

    // Check for errors on other screens
    final otherScreenErrors = _findErrorsForOtherScreens(errors);

    if (otherScreenErrors.isNotEmpty) {
      // Show notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fix errors in ${otherScreenErrors.first.screenName}'),
          action: SnackBarAction(
            label: 'Go There',
            onPressed: () {
              // Navigate to that screen
              Navigator.pushNamed(context, otherScreenErrors.first.route);
            },
          ),
        ),
      );
    }

    // Scroll to first error on current screen
    _scrollToFirstError();
  }
}

List<ScreenError> _findErrorsForOtherScreens(Map<String, String> errors) {
  final otherErrors = <ScreenError>[];

  // Check if any errors belong to different screens
  for (final field in errors.keys) {
    final screenInfo = _getScreenForField(field);
    if (screenInfo != null && screenInfo.route != _currentRoute) {
      otherErrors.add(screenInfo);
    }
  }

  return otherErrors;
}

ScreenError? _getScreenForField(String field) {
  // Map fields to screens
  const fieldScreenMap = {
    'email': ScreenError('Personal Details', AppRouter.registrationPersonal),
    'phone': ScreenError('Personal Details', AppRouter.registrationPersonal),
    'medicalCouncilNumber': ScreenError('Professional Details', AppRouter.registrationProfessional),
    // ... all fields
  };

  return fieldScreenMap[field];
}
```

**Key Points:**
- ✅ Parse and map errors to fields
- ✅ Show errors on respective fields
- ✅ Navigate to error screen if needed
- ✅ Scroll to first error

---

## 📁 File Upload Errors

### **Scenario 1: File Too Large**

**Trigger:** Selected file exceeds size limit

**UI Behavior:**
```dart
// Show error immediately after selection
if (file.lengthSync() > maxSizeBytes) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('File size exceeds ${maxSizeMB}MB limit'),
      backgroundColor: Colors.red,
    ),
  );

  // Don't upload, clear selection
  setState(() {
    _selectedFile = null;
    _uploadError = 'File too large';
  });

  return;
}
```

**Implementation:**
```dart
Future<void> _pickDocument(DocumentType type) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf', 'jpg', 'png'],
  );

  if (result == null) return;

  final file = File(result.files.single.path!);
  final fileSizeBytes = file.lengthSync();

  // Check size limit (5MB for documents, 2MB for photos)
  final maxSizeBytes = type == DocumentType.profilePhoto
      ? 2 * 1024 * 1024  // 2MB
      : 5 * 1024 * 1024; // 5MB

  if (fileSizeBytes > maxSizeBytes) {
    final maxSizeMB = maxSizeBytes / (1024 * 1024);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('File size exceeds ${maxSizeMB.toStringAsFixed(0)}MB limit'),
        backgroundColor: Colors.red,
      ),
    );

    // Don't upload, clear selection
    return;
  }

  // Proceed with upload
  await _uploadDocument(file, type);
}
```

---

### **Scenario 2: Invalid File Type**

**Trigger:** Selected file has unsupported extension

**Implementation:**
```dart
final allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png'];
final fileExtension = result.files.single.extension?.toLowerCase();

if (!allowedExtensions.contains(fileExtension)) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Invalid file type. Allowed: ${allowedExtensions.join(", ")}'),
      backgroundColor: Colors.red,
    ),
  );

  return;
}
```

---

### **Scenario 3: Upload Failure (Network)**

**Trigger:** Network error during file upload

**Implementation:**
```dart
Future<void> _uploadDocument(File file, DocumentType type) async {
  setState(() {
    _uploading = true;
    _uploadError = null;
  });

  // Auto-retry 3 times with 2s delay
  int attempts = 0;
  const maxAttempts = 3;
  const retryDelay = Duration(seconds: 2);

  while (attempts < maxAttempts) {
    try {
      final uploadedUrl = await _api.uploadDocument(file, type);

      setState(() {
        _uploadedDocuments[type] = DocumentUpload(
          type: type,
          localFilePath: file.path,
          fileName: file.path.split('/').last,
          fileSizeBytes: file.lengthSync(),
          uploadedAt: DateTime.now(),
          serverUrl: uploadedUrl,
        );
        _uploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File uploaded successfully'),
          backgroundColor: Colors.green,
        ),
      );

      return; // Success
    } catch (e) {
      attempts++;

      if (attempts < maxAttempts) {
        // Wait before retry
        await Future.delayed(retryDelay);
      } else {
        // Max attempts reached
        setState(() {
          _uploading = false;
          _uploadError = 'Upload failed. Please try again.';
        });

        // Show retry button
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Upload failed. Please try again.'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _uploadDocument(file, type),
            ),
          ),
        );
      }
    }
  }
}
```

**Key Points:**
- ✅ Auto-retry 3 times with 2s delay
- ✅ Keep file in temp directory
- ✅ Show retry button after max attempts

---

### **Scenario 4: Corrupted File**

**Trigger:** File cannot be read or parsed

**Implementation:**
```dart
try {
  // Attempt to read file
  final bytes = await file.readAsBytes();

  // Validate file header (magic numbers)
  if (!_isValidFileHeader(bytes, fileExtension)) {
    throw const FileCorruptedException();
  }

  // Proceed with upload
} on FileCorruptedException {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('File is corrupted or unreadable'),
      backgroundColor: Colors.red,
      action: SnackBarAction(
        label: 'Re-upload',
        onPressed: () => _pickDocument(type),
      ),
    ),
  );
} on FileSystemException {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Cannot read file. Please try again.'),
      backgroundColor: Colors.red,
    ),
  );
}

bool _isValidFileHeader(List<int> bytes, String extension) {
  // Check file magic numbers
  switch (extension) {
    case 'pdf':
      return bytes.length >= 4 &&
             bytes[0] == 0x25 &&
             bytes[1] == 0x50 &&
             bytes[2] == 0x44 &&
             bytes[3] == 0x46; // %PDF
    case 'jpg':
    case 'jpeg':
      return bytes.length >= 2 &&
             bytes[0] == 0xFF &&
             bytes[1] == 0xD8; // JPEG
    case 'png':
      return bytes.length >= 8 &&
             bytes[0] == 0x89 &&
             bytes[1] == 0x50 &&
             bytes[2] == 0x4E &&
             bytes[3] == 0x47; // PNG
    default:
      return true;
  }
}
```

---

## 🚨 Submission Errors

### **Scenario 1: Network Timeout**

**Trigger:** API call exceeds timeout duration

**Implementation:**
```dart
Future<void> submitRegistration() async {
  state = const RegistrationStateLoading(
    message: 'Submitting registration...',
  );

  try {
    final registrationId = await _repository
        .submitRegistration(registration: registration)
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('Request timed out');
          },
        );

    // Success
    await _localDs.markRegistrationComplete();
    state = RegistrationStateSuccess(registrationId: registrationId);
  } on TimeoutException {
    state = RegistrationStateError(
      message: 'Request timed out. Check internet and retry',
      code: 'TIMEOUT',
      currentRegistration: registration,
      canRetry: true,
    );

    // Don't clear form data
  }
}
```

**UI Behavior:**
```dart
ref.listen<RegistrationState>(registrationProvider, (previous, next) {
  if (next case RegistrationStateError(:final message, :final canRetry)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: canRetry
            ? SnackBarAction(
                label: 'Retry',
                onPressed: () {
                  ref.read(registrationProvider.notifier).retrySubmission();
                },
              )
            : null,
      ),
    );
  }
});
```

---

### **Scenario 2: Duplicate Email/Mobile (422)**

**Trigger:** Email or phone already registered

**Error Response:**
```json
{
  "status": 422,
  "errors": {
    "email": ["This email is already registered"]
  }
}
```

**Implementation:**
```dart
Future<void> submitRegistration() async {
  try {
    final registrationId = await _repository.submitRegistration(
      registration: registration,
    );

    await _localDs.markRegistrationComplete();
    state = RegistrationStateSuccess(registrationId: registrationId);
  } on ValidationException catch (e) {
    if (e.fieldErrors.containsKey('email') ||
        e.fieldErrors.containsKey('phone')) {
      // Navigate back to Screen 1
      state = RegistrationStateDuplicateFound(
        message: e.fieldErrors.values.first,
        duplicateField: e.fieldErrors.keys.first,
        currentRegistration: registration,
      );
    } else {
      state = RegistrationStateValidationError(
        message: 'Please fix the errors',
        fieldErrors: e.fieldErrors,
        currentRegistration: registration,
      );
    }
  }
}
```

**UI Behavior:**
```dart
ref.listen<RegistrationState>(registrationProvider, (previous, next) {
  if (next case RegistrationStateDuplicateFound(:final message, :final duplicateField)) {
    // Navigate to Screen 1
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.registrationPersonal,
      (route) => false,
    );

    // Show error dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Already Registered'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 16),
            const Text('This email/phone is already registered.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Highlight the duplicate field
            },
            child: const Text('Fix'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to login
              Navigator.pushNamed(context, AppRouter.login);
            },
            child: const Text('Login Instead'),
          ),
        ],
      ),
    );
  }
});
```

---

### **Scenario 3: Invalid Session (401)**

**Trigger:** Session expired during registration

**Implementation:**
```dart
Future<void> submitRegistration() async {
  try {
    final registrationId = await _repository.submitRegistration(
      registration: registration,
    );

    await _localDs.markRegistrationComplete();
    state = RegistrationStateSuccess(registrationId: registrationId);
  } on UnauthorizedException catch (e) {
    // Clear session data
    await _authRepository.logout();

    state = RegistrationStateSessionExpired(
      message: 'Your session expired. Please login again',
      currentRegistration: registration, // Preserve for restore
    );
  }
}
```

**UI Behavior:**
```dart
ref.listen<RegistrationState>(registrationProvider, (previous, next) {
  if (next case RegistrationStateSessionExpired(:final message)) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Session Expired'),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () async {
              // Navigate to login
              final loggedIn = await Navigator.pushNamed(
                context,
                AppRouter.login,
              );

              if (loggedIn == true && context.mounted) {
                // Restore registration flow
                ref.read(registrationProvider.notifier).retrySubmission();
              }
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
});
```

---

### **Scenario 4: Payment Gateway Error**

**Trigger:** Payment processing fails

**Implementation:**
```dart
Future<void> processPayment(PaymentDetails paymentDetails) async {
  state = const RegistrationStateLoading(
    message: 'Processing payment...',
  );

  try {
    final paymentResult = await _paymentGateway.processPayment(
      amount: paymentDetails.amount,
      currency: paymentDetails.currency,
      // ...
    );

    if (paymentResult.status == PaymentStatus.completed) {
      // Update payment details
      final updatedReg = registration.copyWith(
        paymentDetails: paymentDetails.copyWith(
          status: PaymentStatus.completed,
          transactionId: paymentResult.transactionId,
        ),
      );

      // Submit registration
      await submitRegistration();
    } else {
      state = RegistrationStatePaymentFailed(
        message: paymentResult.errorMessage ?? 'Payment failed',
        currentRegistration: registration,
        paymentDetails: paymentDetails,
      );
    }
  } on PaymentException catch (e) {
    state = RegistrationStatePaymentFailed(
      message: e.message,
      currentRegistration: registration,
      paymentDetails: paymentDetails,
    );
  }
}
```

**UI Behavior:**
```dart
ref.listen<RegistrationState>(registrationProvider, (previous, next) {
  if (next case RegistrationStatePaymentFailed(:final message)) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Allow changing payment method
              _showPaymentMethodPicker();
            },
            child: const Text('Change Method'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Try again with same method
              ref.read(registrationProvider.notifier).retryPayment();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
});
```

---

### **Scenario 5: Server Error (500)**

**Trigger:** Internal server error

**Implementation:**
```dart
Future<void> submitRegistration() async {
  try {
    final registrationId = await _repository.submitRegistration(
      registration: registration,
    );

    await _localDs.markRegistrationComplete();
    state = RegistrationStateSuccess(registrationId: registrationId);
  } on ServerException catch (e) {
    // Log error with full context
    _analytics.logError('registration_submit_500', {
      'registration_id': registration.registrationId,
      'current_step': registration.currentStep.name,
      'error': e.message,
      'timestamp': DateTime.now().toIso8601String(),
    });

    state = RegistrationStateError(
      message: 'Something went wrong. Please try again',
      code: 'SERVER_ERROR',
      currentRegistration: registration,
      canRetry: true,
    );
  }
}
```

---

## 🛠️ Error State Classes

```dart
// Additional registration states for error handling

/// Duplicate email/phone found
final class RegistrationStateDuplicateFound extends RegistrationState {
  final String message;
  final String duplicateField; // 'email' or 'phone'
  final PractitionerRegistration currentRegistration;

  const RegistrationStateDuplicateFound({
    required this.message,
    required this.duplicateField,
    required this.currentRegistration,
  });
}

/// Session expired during registration
final class RegistrationStateSessionExpired extends RegistrationState {
  final String message;
  final PractitionerRegistration currentRegistration;

  const RegistrationStateSessionExpired({
    required this.message,
    required this.currentRegistration,
  });
}

/// Payment failed
final class RegistrationStatePaymentFailed extends RegistrationState {
  final String message;
  final PractitionerRegistration currentRegistration;
  final PaymentDetails paymentDetails;

  const RegistrationStatePaymentFailed({
    required this.message,
    required this.currentRegistration,
    required this.paymentDetails,
  });
}

/// Updated error state with retry flag
final class RegistrationStateError extends RegistrationState {
  final String message;
  final String? code;
  final PractitionerRegistration? currentRegistration;
  final bool canRetry;

  const RegistrationStateError({
    required this.message,
    this.code,
    this.currentRegistration,
    this.canRetry = true,
  });
}
```

---

## 📊 Error Logging

```dart
// Error logging utility
class RegistrationErrorLogger {
  final AnalyticsService _analytics;

  void logDropdownError(String dropdownName, String errorType) {
    _analytics.logError('registration_dropdown_error', {
      'dropdown': dropdownName,
      'error_type': errorType,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void logValidationError(String field, String error) {
    _analytics.logError('registration_validation_error', {
      'field': field,
      'error': error,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void logUploadError(DocumentType type, String errorType) {
    _analytics.logError('registration_upload_error', {
      'document_type': type.name,
      'error_type': errorType,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void logSubmissionError(String code, String message) {
    _analytics.logError('registration_submission_error', {
      'code': code,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
```

---

## ✅ Implementation Checklist

- [ ] **Dropdown Errors:**
  - [ ] Network failure with retry button
  - [ ] 404 with analytics logging
  - [ ] Empty dropdown handling

- [ ] **Form Validation:**
  - [ ] Client-side validation on blur
  - [ ] Server-side error mapping
  - [ ] Navigation to error screens

- [ ] **File Uploads:**
  - [ ] File size validation
  - [ ] File type validation
  - [ ] Auto-retry with 3 attempts
  - [ ] Corrupted file detection

- [ ] **Submission:**
  - [ ] Network timeout handling
  - [ ] Duplicate email/phone detection
  - [ ] Session expiry handling
  - [ ] Payment gateway errors
  - [ ] Server error handling

---

**Implementation Status:**
- ✅ Error handling strategy documented
- ⏳ Error state classes (pending)
- ⏳ Error utilities (pending)
- ⏳ UI implementations (pending)
