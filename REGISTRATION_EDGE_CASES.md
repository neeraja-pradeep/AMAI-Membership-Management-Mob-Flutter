# Registration Edge Cases & Handling - Implementation Guide

## Overview
Comprehensive edge case handling for the practitioner registration flow covering dependent dropdowns, file uploads, payment gateway, data consistency, and error recovery scenarios.

---

## 🔄 Edge Case Categories

### **1. Dependent Dropdown Changes**
### **2. App Backgrounding During Upload**
### **3. Multiple File Uploads**
### **4. Payment Gateway Redirect**
### **5. User Edits Earlier Screens**
### **6. Duplicate Registration Attempt**
### **7. File Deleted from Temp Directory**
### **8. Stale Dropdown Data**

---

## 📊 Dependent Dropdown Changes

### **Scenario: User Changes Parent Dropdown**

**Affected Dropdowns:**
- Country → State → District
- Medical Council → Council State
- Membership District → Area

**Implementation:**

```dart
class AddressDetailsScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<AddressDetailsScreen> createState() =>
      _AddressDetailsScreenState();
}

class _AddressDetailsScreenState
    extends ConsumerState<AddressDetailsScreen> {
  String? _selectedCountry;
  String? _selectedState;
  String? _selectedDistrict;

  List<String> _states = [];
  List<String> _districts = [];

  bool _loadingStates = false;
  bool _loadingDistricts = false;

  /// Handle country change
  void _onCountryChanged(String? country) async {
    if (country == null || country == _selectedCountry) return;

    setState(() {
      _selectedCountry = country;

      // Clear dependent fields
      _selectedState = null;
      _selectedDistrict = null;
      _states = [];
      _districts = [];

      // Show loading for child dropdown
      _loadingStates = true;
    });

    // Re-fetch states for new country
    try {
      final states = await _dropdownApi.getStates(country: country);

      if (mounted) {
        setState(() {
          _states = states;
          _loadingStates = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingStates = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to load states'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _onCountryChanged(country),
            ),
          ),
        );
      }
    }
  }

  /// Handle state change
  void _onStateChanged(String? state) async {
    if (state == null || state == _selectedState) return;

    setState(() {
      _selectedState = state;

      // Clear dependent district
      _selectedDistrict = null;
      _districts = [];

      // Show loading for child dropdown
      _loadingDistricts = true;
    });

    // Re-fetch districts for new state
    try {
      final districts = await _dropdownApi.getDistricts(
        country: _selectedCountry!,
        state: state,
      );

      if (mounted) {
        setState(() {
          _districts = districts;
          _loadingDistricts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingDistricts = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load districts'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Country dropdown
        DropdownButtonFormField<String>(
          value: _selectedCountry,
          decoration: const InputDecoration(labelText: 'Country'),
          items: _countries.map((country) {
            return DropdownMenuItem(value: country, child: Text(country));
          }).toList(),
          onChanged: _onCountryChanged,
        ),

        SizedBox(height: 16.h),

        // State dropdown (dependent on country)
        DropdownButtonFormField<String>(
          value: _selectedState,
          decoration: InputDecoration(
            labelText: 'State',
            suffixIcon: _loadingStates
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
          items: _states.map((state) {
            return DropdownMenuItem(value: state, child: Text(state));
          }).toList(),
          onChanged: _selectedCountry == null || _loadingStates
              ? null // Disabled until country selected and states loaded
              : _onStateChanged,
        ),

        SizedBox(height: 16.h),

        // District dropdown (dependent on state)
        DropdownButtonFormField<String>(
          value: _selectedDistrict,
          decoration: InputDecoration(
            labelText: 'District',
            suffixIcon: _loadingDistricts
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
          items: _districts.map((district) {
            return DropdownMenuItem(value: district, child: Text(district));
          }).toList(),
          onChanged: _selectedState == null || _loadingDistricts
              ? null // Disabled until state selected and districts loaded
              : (value) => setState(() => _selectedDistrict = value),
        ),
      ],
    );
  }
}
```

**Key Points:**
- ✅ Clear child dropdowns when parent changes
- ✅ Show loading indicator in child dropdown during re-fetch
- ✅ Disable child dropdown until parent is selected and data loaded
- ✅ Handle errors with retry option
- ✅ Check `mounted` before calling `setState`

---

## 📱 App Backgrounding During Upload

### **Scenario: User Backgrounds App During File Upload**

**Requirements:**
- Pause upload if multipart
- Resume on app resume (if < 5 minutes)
- If > 5 minutes: Show "Upload interrupted. Retry?"

**Implementation:**

```dart
class FileUploadService with WidgetsBindingObserver {
  final Dio _dio;

  // Track ongoing uploads
  final Map<String, UploadState> _activeUploads = {};

  // Cancellation tokens for pausing
  final Map<String, CancelToken> _cancelTokens = {};

  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        // App backgrounded - pause uploads
        _pauseAllUploads();
        break;

      case AppLifecycleState.resumed:
        // App resumed - check if we should resume uploads
        _resumeUploadsIfRecent();
        break;

      default:
        break;
    }
  }

  /// Pause all active uploads
  void _pauseAllUploads() {
    for (final uploadId in _activeUploads.keys) {
      final state = _activeUploads[uploadId]!;

      if (state.status == UploadStatus.uploading) {
        // Cancel the upload
        _cancelTokens[uploadId]?.cancel('App backgrounded');

        // Update state
        _activeUploads[uploadId] = state.copyWith(
          status: UploadStatus.paused,
          pausedAt: DateTime.now(),
        );
      }
    }
  }

  /// Resume uploads if paused for < 5 minutes
  void _resumeUploadsIfRecent() {
    final now = DateTime.now();

    for (final uploadId in _activeUploads.keys) {
      final state = _activeUploads[uploadId]!;

      if (state.status == UploadStatus.paused) {
        final pauseDuration = now.difference(state.pausedAt!);

        if (pauseDuration.inMinutes < 5) {
          // Resume upload
          _resumeUpload(uploadId);
        } else {
          // Too long - mark as interrupted
          _activeUploads[uploadId] = state.copyWith(
            status: UploadStatus.interrupted,
          );

          // Show notification to user
          _showUploadInterruptedNotification(uploadId);
        }
      }
    }
  }

  /// Resume a specific upload
  Future<void> _resumeUpload(String uploadId) async {
    final state = _activeUploads[uploadId]!;

    _activeUploads[uploadId] = state.copyWith(
      status: UploadStatus.uploading,
    );

    // Re-upload from where we left off (if server supports ranges)
    await _uploadFile(
      uploadId: uploadId,
      file: state.file,
      uploadedBytes: state.uploadedBytes,
    );
  }

  /// Show notification for interrupted upload
  void _showUploadInterruptedNotification(String uploadId) {
    // Show in-app notification or dialog
    // "Upload interrupted. Retry?"
  }

  Future<String> uploadDocument({
    required File file,
    required DocumentType type,
    required Function(double) onProgress,
  }) async {
    final uploadId = const Uuid().v4();
    final cancelToken = CancelToken();

    _cancelTokens[uploadId] = cancelToken;
    _activeUploads[uploadId] = UploadState(
      uploadId: uploadId,
      file: file,
      type: type,
      status: UploadStatus.uploading,
      uploadedBytes: 0,
      totalBytes: file.lengthSync(),
    );

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'type': type.name,
      });

      final response = await _dio.post(
        '/api/upload',
        data: formData,
        cancelToken: cancelToken,
        onSendProgress: (sent, total) {
          // Update progress
          _activeUploads[uploadId] = _activeUploads[uploadId]!.copyWith(
            uploadedBytes: sent,
          );

          onProgress(sent / total);
        },
      );

      // Upload complete
      _activeUploads[uploadId] = _activeUploads[uploadId]!.copyWith(
        status: UploadStatus.completed,
      );

      return response.data['url'] as String;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        // Upload was paused (app backgrounded)
        return '';
      }

      // Upload failed
      _activeUploads[uploadId] = _activeUploads[uploadId]!.copyWith(
        status: UploadStatus.failed,
      );

      rethrow;
    }
  }
}

enum UploadStatus {
  uploading,
  paused,
  interrupted,
  completed,
  failed,
}

class UploadState {
  final String uploadId;
  final File file;
  final DocumentType type;
  final UploadStatus status;
  final int uploadedBytes;
  final int totalBytes;
  final DateTime? pausedAt;

  const UploadState({
    required this.uploadId,
    required this.file,
    required this.type,
    required this.status,
    required this.uploadedBytes,
    required this.totalBytes,
    this.pausedAt,
  });

  UploadState copyWith({
    UploadStatus? status,
    int? uploadedBytes,
    DateTime? pausedAt,
  }) {
    return UploadState(
      uploadId: uploadId,
      file: file,
      type: type,
      status: status ?? this.status,
      uploadedBytes: uploadedBytes ?? this.uploadedBytes,
      totalBytes: totalBytes,
      pausedAt: pausedAt ?? this.pausedAt,
    );
  }
}

// UI: Show interrupted upload dialog
void _showInterruptedUploadDialog(String uploadId) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Upload Interrupted'),
      content: const Text(
        'Your upload was interrupted. Would you like to retry?',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            // Clear the upload
            _uploadService.clearUpload(uploadId);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // Retry upload
            _uploadService.retryUpload(uploadId);
          },
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}
```

---

## 📤 Multiple File Uploads Simultaneously

### **Scenario: User Tries to Upload Multiple Files at Once**

**Requirements:**
- Not allowed (disable other upload buttons while one in progress)
- Queue if triggered (but UI should prevent this)

**Implementation:**

```dart
class DocumentUploadScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<DocumentUploadScreen> createState() =>
      _DocumentUploadScreenState();
}

class _DocumentUploadScreenState
    extends ConsumerState<DocumentUploadScreen> {
  // Track which document is currently uploading
  DocumentType? _uploadingDocument;

  // Upload progress for current upload
  double _uploadProgress = 0.0;

  Future<void> _pickAndUploadDocument(DocumentType type) async {
    // Check if another upload is in progress
    if (_uploadingDocument != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please wait for ${_uploadingDocument!.name} upload to complete',
          ),
        ),
      );
      return;
    }

    // Pick file
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result == null) return;

    final file = File(result.files.single.path!);

    // Validate file
    final validation = await FileSecurityValidator.validateFile(file);
    if (!validation.isValid) {
      _showError(validation.error!);
      return;
    }

    // Start upload
    setState(() {
      _uploadingDocument = type;
      _uploadProgress = 0.0;
    });

    try {
      final url = await _uploadService.uploadDocument(
        file: file,
        type: type,
        onProgress: (progress) {
          setState(() => _uploadProgress = progress);
        },
      );

      // Upload complete
      setState(() {
        _uploadedDocuments[type] = DocumentUpload(
          type: type,
          localFilePath: file.path,
          fileName: validation.sanitizedFilename!,
          fileSizeBytes: file.lengthSync(),
          uploadedAt: DateTime.now(),
          serverUrl: url,
        );
        _uploadingDocument = null;
        _uploadProgress = 0.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document uploaded successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _uploadingDocument = null;
        _uploadProgress = 0.0;
      });

      _showError('Upload failed. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Medical Council Certificate
        _buildDocumentUploadTile(
          type: DocumentType.councilCertificate,
          label: 'Medical Council Certificate',
          isUploading: _uploadingDocument == DocumentType.councilCertificate,
          isDisabled: _uploadingDocument != null &&
              _uploadingDocument != DocumentType.councilCertificate,
        ),

        // Degree Certificate
        _buildDocumentUploadTile(
          type: DocumentType.degreeCertificate,
          label: 'Degree Certificate',
          isUploading: _uploadingDocument == DocumentType.degreeCertificate,
          isDisabled: _uploadingDocument != null &&
              _uploadingDocument != DocumentType.degreeCertificate,
        ),

        // Show upload progress
        if (_uploadingDocument != null)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Column(
              children: [
                Text('Uploading ${_uploadingDocument!.name}...'),
                SizedBox(height: 8.h),
                LinearProgressIndicator(value: _uploadProgress),
                SizedBox(height: 4.h),
                Text('${(_uploadProgress * 100).toStringAsFixed(0)}%'),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDocumentUploadTile({
    required DocumentType type,
    required String label,
    required bool isUploading,
    required bool isDisabled,
  }) {
    final isUploaded = _uploadedDocuments.containsKey(type);

    return ListTile(
      title: Text(label),
      subtitle: isUploaded
          ? Text('Uploaded: ${_uploadedDocuments[type]!.fileName}')
          : null,
      trailing: isUploading
          ? const CircularProgressIndicator()
          : ElevatedButton(
              onPressed: isDisabled ? null : () => _pickAndUploadDocument(type),
              child: Text(isUploaded ? 'Replace' : 'Upload'),
            ),
    );
  }
}
```

**Key Points:**
- ✅ Only one upload at a time
- ✅ Disable other upload buttons during upload
- ✅ Show progress for current upload
- ✅ Clear message if user tries to upload multiple files

---

## 💳 Payment Gateway Redirect

### **Scenario: Payment Gateway Doesn't Redirect Back**

**Requirements:**
- Implement timeout (2 minutes)
- After timeout: Show "Payment status unclear. Check with support"
- Allow manual verification via transaction ID

**Implementation:**

```dart
class PaymentService {
  final Dio _dio;

  Future<PaymentResult> processPayment({
    required double amount,
    required String currency,
    required Function(PaymentStatus) onStatusChange,
  }) async {
    // Initiate payment with gateway
    final paymentSession = await _initiatePaymentSession(
      amount: amount,
      currency: currency,
    );

    // Redirect to payment gateway (in WebView or browser)
    final redirectCompleted = await _redirectToPaymentGateway(
      paymentSession: paymentSession,
      onStatusChange: onStatusChange,
    );

    if (!redirectCompleted) {
      // Timeout - payment status unclear
      return PaymentResult.unclear(
        sessionId: paymentSession.sessionId,
      );
    }

    // Verify payment status with backend
    final paymentStatus = await _verifyPaymentStatus(
      sessionId: paymentSession.sessionId,
    );

    return PaymentResult.fromStatus(paymentStatus);
  }

  Future<bool> _redirectToPaymentGateway({
    required PaymentSession paymentSession,
    required Function(PaymentStatus) onStatusChange,
  }) async {
    final completer = Completer<bool>();

    // Set timeout (2 minutes)
    final timeout = Timer(const Duration(minutes: 2), () {
      if (!completer.isCompleted) {
        completer.complete(false); // Timeout
      }
    });

    // Listen for redirect callback
    _paymentGateway.onRedirect = (result) {
      timeout.cancel();

      if (!completer.isCompleted) {
        completer.complete(true); // Success redirect
      }

      if (result.status == 'success') {
        onStatusChange(PaymentStatus.completed);
      } else {
        onStatusChange(PaymentStatus.failed);
      }
    };

    // Open payment gateway
    await _paymentGateway.open(paymentSession.redirectUrl);

    return completer.future;
  }

  Future<PaymentStatus> _verifyPaymentStatus({
    required String sessionId,
  }) async {
    final response = await _dio.get(
      '/api/payment/verify',
      queryParameters: {'session_id': sessionId},
    );

    return PaymentStatus.values.firstWhere(
      (status) => status.name == response.data['status'],
    );
  }
}

// UI: Handle unclear payment status
ref.listen<RegistrationState>(registrationProvider, (previous, next) {
  if (next case RegistrationStatePaymentUnclear(:final sessionId)) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Status Unclear'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'We couldn\'t confirm your payment status. This might be due to a network issue.',
            ),
            SizedBox(height: 16.h),
            const Text(
              'If you completed the payment, please contact support with your transaction ID for manual verification.',
            ),
            SizedBox(height: 16.h),
            Text(
              'Session ID: $sessionId',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // User can retry payment
            },
            child: const Text('Try Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Contact support
              _launchSupport();
            },
            child: const Text('Contact Support'),
          ),
        ],
      ),
    );
  }
});

// Add to registration_state.dart
final class RegistrationStatePaymentUnclear extends RegistrationState {
  final String sessionId;
  final PractitionerRegistration currentRegistration;

  const RegistrationStatePaymentUnclear({
    required this.sessionId,
    required this.currentRegistration,
  });
}
```

---

## ✏️ User Edits Earlier Screen After Completing Later Screens

### **Scenario: User Goes Back and Edits Earlier Screen**

**Requirements:**
- Allow editing
- Mark subsequent screens as "needs review" if dependent data changed
- Re-validate entire form on final submission

**Implementation:**

```dart
class RegistrationStateNotifier extends StateNotifier<RegistrationState> {
  // Track which screens need review
  final Set<RegistrationStep> _needsReview = {};

  /// Update personal details (Screen 1)
  void updatePersonalDetails(PersonalDetails newDetails) {
    final current = state;
    if (current is! RegistrationStateInProgress) return;

    final oldDetails = current.registration.personalDetails;

    // Check if dependent fields changed
    if (oldDetails != null) {
      // If email or phone changed, might affect uniqueness validation
      if (oldDetails.email != newDetails.email ||
          oldDetails.phone != newDetails.phone) {
        // Mark all subsequent screens for review
        _markSubsequentStepsForReview(RegistrationStep.personalDetails);
      }
    }

    final updated = current.registration.copyWith(
      personalDetails: newDetails,
      lastUpdatedAt: DateTime.now(),
    );

    state = current.copyWith(
      registration: updated,
      hasUnsavedChanges: true,
    );
  }

  /// Update professional details (Screen 2)
  void updateProfessionalDetails(ProfessionalDetails newDetails) {
    final current = state;
    if (current is! RegistrationStateInProgress) return;

    final oldDetails = current.registration.professionalDetails;

    // Check if dependent fields changed
    if (oldDetails != null) {
      // If council or qualification changed, might affect document requirements
      if (oldDetails.medicalCouncil != newDetails.medicalCouncil ||
          oldDetails.qualification != newDetails.qualification) {
        _markSubsequentStepsForReview(RegistrationStep.professionalDetails);
      }
    }

    final updated = current.registration.copyWith(
      professionalDetails: newDetails,
      lastUpdatedAt: DateTime.now(),
    );

    state = current.copyWith(
      registration: updated,
      hasUnsavedChanges: true,
    );
  }

  /// Mark all subsequent steps as needing review
  void _markSubsequentStepsForReview(RegistrationStep changedStep) {
    for (final step in RegistrationStep.values) {
      if (step.stepNumber > changedStep.stepNumber) {
        _needsReview.add(step);
      }
    }
  }

  /// Check if step needs review
  bool stepNeedsReview(RegistrationStep step) {
    return _needsReview.contains(step);
  }

  /// Clear review flag for step
  void markStepReviewed(RegistrationStep step) {
    _needsReview.remove(step);
  }

  /// Validate entire form before final submission
  Future<void> submitRegistration() async {
    final current = state;
    if (current is! RegistrationStateInProgress) return;

    // Check if any steps need review
    if (_needsReview.isNotEmpty) {
      final stepsText = _needsReview
          .map((step) => step.displayName)
          .join(', ');

      state = RegistrationStateValidationError(
        message: 'Please review: $stepsText',
        currentRegistration: current.registration,
      );
      return;
    }

    // Re-validate entire form
    final validationErrors = _validateEntireForm(current.registration);

    if (validationErrors.isNotEmpty) {
      state = RegistrationStateValidationError(
        message: 'Please fix validation errors',
        fieldErrors: validationErrors,
        currentRegistration: current.registration,
      );
      return;
    }

    // Proceed with submission
    // ...
  }

  Map<String, String> _validateEntireForm(
    PractitionerRegistration registration,
  ) {
    final errors = <String, String>{};

    // Validate all steps
    // ...

    return errors;
  }
}

// UI: Show "needs review" badge
class RegistrationProgressIndicator extends ConsumerWidget {
  const RegistrationProgressIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registrationProvider);

    if (state is! RegistrationStateInProgress) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: RegistrationStep.values.map((step) {
        final isCompleted = state.registration.isStepComplete(step);
        final isCurrent = state.registration.currentStep == step;
        final needsReview =
            ref.read(registrationProvider.notifier).stepNeedsReview(step);

        return _buildStepIndicator(
          step: step,
          isCompleted: isCompleted,
          isCurrent: isCurrent,
          needsReview: needsReview,
        );
      }).toList(),
    );
  }

  Widget _buildStepIndicator({
    required RegistrationStep step,
    required bool isCompleted,
    required bool isCurrent,
    required bool needsReview,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundColor: isCurrent
                  ? Colors.blue
                  : isCompleted
                      ? Colors.green
                      : Colors.grey[300],
              child: Icon(
                isCompleted ? Icons.check : null,
                color: Colors.white,
              ),
            ),

            // "Needs review" badge
            if (needsReview)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning,
                    size: 12.sp,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          step.displayName,
          style: TextStyle(fontSize: 10.sp),
        ),
      ],
    );
  }
}
```

---

## 🚫 Duplicate Registration Attempt

### **Scenario: User Already Registered**

**Requirements:**
- API returns 422 with "Already registered" error
- Show: "You're already registered. Login instead?"
- Provide login button

**Implementation:**

```dart
// In RegistrationStateNotifier
Future<void> submitRegistration() async {
  try {
    final registrationId = await _repository.submitRegistration(
      registration: registration,
    );

    await _localDs.markRegistrationComplete();
    state = RegistrationStateSuccess(registrationId: registrationId);
  } on ValidationException catch (e) {
    // Check for duplicate registration error
    if (e.code == 'ALREADY_REGISTERED' ||
        e.fieldErrors.containsKey('duplicate')) {
      state = RegistrationStateDuplicateRegistration(
        message: e.message,
        email: registration.personalDetails!.email,
        phone: registration.personalDetails!.phone,
      );
      return;
    }

    // Other validation errors
    state = RegistrationStateValidationError(
      message: e.message,
      fieldErrors: e.fieldErrors,
      currentRegistration: registration,
    );
  }
}

// Add to registration_state.dart
final class RegistrationStateDuplicateRegistration extends RegistrationState {
  final String message;
  final String email;
  final String phone;

  const RegistrationStateDuplicateRegistration({
    required this.message,
    required this.email,
    required this.phone,
  });
}

// UI: Handle duplicate registration
ref.listen<RegistrationState>(registrationProvider, (previous, next) {
  if (next case RegistrationStateDuplicateRegistration(:final email)) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Already Registered'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info_outline,
              size: 48,
              color: Colors.orange,
            ),
            SizedBox(height: 16.h),
            const Text(
              'You are already registered with us.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Email: $email',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 16.h),
            const Text(
              'Please login instead to access your account.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Stay on registration (in case email was wrong)
            },
            child: const Text('Check Details'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to login
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.login,
                (route) => false,
              );
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

## 📁 File Deleted from Temp Directory

### **Scenario: Uploaded File Deleted Before Submission**

**Requirements:**
- On submission: Check file existence
- If missing: Show error on document screen, request re-upload

**Implementation:**

```dart
// In RegistrationStateNotifier
Future<void> submitRegistration() async {
  final current = state;
  if (current is! RegistrationStateInProgress) return;

  // Validate file existence before submission
  final missingFiles = await _validateFileExistence(
    current.registration.documentUploads,
  );

  if (missingFiles.isNotEmpty) {
    state = RegistrationStateFileMissing(
      missingFiles: missingFiles,
      currentRegistration: current.registration,
    );
    return;
  }

  // Proceed with submission
  // ...
}

Future<List<DocumentType>> _validateFileExistence(
  DocumentUploads? documents,
) async {
  if (documents == null || documents.documents.isEmpty) {
    return [];
  }

  final missing = <DocumentType>[];

  for (final doc in documents.documents) {
    final file = File(doc.localFilePath);

    if (!await file.exists()) {
      missing.add(doc.type);
    }
  }

  return missing;
}

// Add to registration_state.dart
final class RegistrationStateFileMissing extends RegistrationState {
  final List<DocumentType> missingFiles;
  final PractitionerRegistration currentRegistration;

  const RegistrationStateFileMissing({
    required this.missingFiles,
    required this.currentRegistration,
  });
}

// UI: Handle missing files
ref.listen<RegistrationState>(registrationProvider, (previous, next) {
  if (next case RegistrationStateFileMissing(:final missingFiles)) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Documents Missing'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The following documents are missing and need to be re-uploaded:',
            ),
            SizedBox(height: 16.h),
            ...missingFiles.map((type) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange, size: 20),
                      SizedBox(width: 8.w),
                      Text(type.displayName),
                    ],
                  ),
                )),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              // Navigate to document upload screen
              Navigator.pushNamed(
                context,
                AppRouter.registrationDocuments,
              );
            },
            child: const Text('Re-upload Documents'),
          ),
        ],
      ),
    );
  }
});
```

---

## 🔄 Stale Dropdown Data Selected

### **Scenario: Selected Option No Longer Exists After Refresh**

**Requirements:**
- If selected option ID doesn't exist in refreshed data: Show error
- Force user to re-select from updated list

**Implementation:**

```dart
class DropdownField<T> extends StatefulWidget {
  final String label;
  final T? value;
  final List<DropdownOption<T>> items;
  final ValueChanged<T?> onChanged;
  final Future<List<DropdownOption<T>>> Function() onRefresh;

  const DropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.onRefresh,
  });

  @override
  State<DropdownField<T>> createState() => _DropdownFieldState<T>();
}

class _DropdownFieldState<T> extends State<DropdownField<T>> {
  List<DropdownOption<T>> _items = [];
  String? _stalDataError;

  @override
  void initState() {
    super.initState();
    _items = widget.items;
    _checkForStaleData();
  }

  @override
  void didUpdateWidget(DropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.items != oldWidget.items) {
      _items = widget.items;
      _checkForStaleData();
    }
  }

  /// Check if currently selected value exists in updated items
  void _checkForStaleData() {
    if (widget.value == null) {
      setState(() => _stalDataError = null);
      return;
    }

    final valueExists = _items.any((item) => item.value == widget.value);

    if (!valueExists) {
      setState(() {
        _stalDataError =
            'Selected option is no longer available. Please select again.';
      });

      // Clear the invalid selection
      widget.onChanged(null);
    } else {
      setState(() => _stalDataError = null);
    }
  }

  Future<void> _handleRefresh() async {
    try {
      final refreshedItems = await widget.onRefresh();

      setState(() {
        _items = refreshedItems;
      });

      _checkForStaleData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to refresh options'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: widget.value,
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: _stalDataError,
        suffixIcon: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _handleRefresh,
          tooltip: 'Refresh options',
        ),
      ),
      items: _items.map((option) {
        return DropdownMenuItem<T>(
          value: option.value,
          child: Text(option.label),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _stalDataError = null);
        widget.onChanged(value);
      },
    );
  }
}

class DropdownOption<T> {
  final T value;
  final String label;

  const DropdownOption({
    required this.value,
    required this.label,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DropdownOption &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          label == other.label;

  @override
  int get hashCode => value.hashCode ^ label.hashCode;
}

// Usage
DropdownField<String>(
  label: 'Medical Council',
  value: _selectedCouncil,
  items: _councilOptions,
  onChanged: (value) => setState(() => _selectedCouncil = value),
  onRefresh: () => _api.getMedicalCouncils(),
)
```

---

## ✅ Edge Case Handling Checklist

- [ ] **Dependent Dropdowns:**
  - [ ] Clear children when parent changes
  - [ ] Show loading in child dropdown
  - [ ] Disable child until parent selected
  - [ ] Handle re-fetch errors with retry

- [ ] **App Backgrounding:**
  - [ ] Pause upload on background
  - [ ] Resume if < 5 minutes
  - [ ] Show "interrupted" dialog if > 5 minutes
  - [ ] Allow manual retry

- [ ] **Multiple Uploads:**
  - [ ] Only one upload at a time
  - [ ] Disable other upload buttons
  - [ ] Show progress for active upload
  - [ ] Queue prevention in UI

- [ ] **Payment Gateway:**
  - [ ] 2-minute timeout
  - [ ] Show "status unclear" dialog
  - [ ] Provide session ID for support
  - [ ] Allow manual verification

- [ ] **Earlier Screen Edits:**
  - [ ] Allow editing previous screens
  - [ ] Mark subsequent screens for review
  - [ ] Show "needs review" badges
  - [ ] Re-validate entire form on submit

- [ ] **Duplicate Registration:**
  - [ ] Detect 422 error
  - [ ] Show "already registered" dialog
  - [ ] Provide login button
  - [ ] Display registered email

- [ ] **File Deletion:**
  - [ ] Validate file existence before submit
  - [ ] Navigate to document screen
  - [ ] List missing documents
  - [ ] Request re-upload

- [ ] **Stale Dropdown Data:**
  - [ ] Check if selected value exists
  - [ ] Show error if stale
  - [ ] Force re-selection
  - [ ] Provide refresh button

---

**Implementation Status:**
- ✅ Edge case handling documented
- ✅ All scenarios with code examples
- ⏳ Utility classes (pending)
- ⏳ UI integration (pending)
- ⏳ Testing (pending)
