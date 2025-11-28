# Practitioner Registration Module - Implementation Guide

## Overview
Multi-step registration flow for practitioners with state persistence, auto-save, and 24-hour session recovery.

---

## ✅ Completed Components

### Domain Layer (lib/features/registration/domain/entities/)

1. **registration_step.dart** - Enum for 5-step flow
   - `RegistrationStep` with stepNumber, displayName
   - Navigation helpers: `next`, `previous`, `isFirst`, `isLast`
   - Progress calculation: `progress`, `totalSteps`

2. **personal_details.dart** - Step 1 entity
   - Fields: firstName, lastName, email, phone, dateOfBirth, gender, profileImagePath
   - Computed: `fullName`, `age`, `isComplete`

3. **professional_details.dart** - Step 2 entity
   - Fields: medicalCouncilRegistrationNumber, medicalCouncil, registrationDate, qualification, specialization, yearsOfExperience, etc.
   - Validation: `isComplete`

4. **address_details.dart** - Step 3 entity
   - Fields: addressLine1, addressLine2, city, state, pincode, country
   - Computed: `fullAddress`, `isComplete`

5. **document_upload.dart** - Step 4 entities
   - `DocumentType` enum with required/optional flags
   - `DocumentUpload` entity with file metadata
   - `DocumentUploads` collection with validation

6. **practitioner_registration.dart** - Main entity
   - Combines all step entities
   - Tracks: registrationId (UUID), currentStep, createdAt, lastUpdatedAt
   - Validation: `isStepComplete()`, `canProceedToNext`, `isComplete`
   - State: `isExpired` (>24h check), `completionPercentage`
   - Payment: `PaymentDetails` with status tracking

### Application Layer (lib/features/registration/application/states/)

1. **registration_state.dart** - Sealed state classes
   - `RegistrationStateInitial` - Checking for existing registration
   - `RegistrationStateLoading` - Saving or API call
   - `RegistrationStateInProgress` - Active registration
     - Tracks `hasUnsavedChanges` flag
     - Helpers: `canGoBack`, `canGoForward`, `canSubmit`
   - `RegistrationStateResumePrompt` - Found incomplete registration
   - `RegistrationStateValidationError` - Cannot proceed
   - `RegistrationStateError` - API or save error
   - `RegistrationStateSuccess` - Completed

---

## 📋 Implementation Plan

### Phase 1: Data Models & Infrastructure

#### 1.1 Create DTOs (lib/features/registration/infrastructure/models/)

**Use json_serializable (NOT freezed)**

```dart
// personal_details_model.dart
@JsonSerializable()
class PersonalDetailsModel {
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String email;
  final String phone;
  @JsonKey(name: 'date_of_birth')
  final String dateOfBirth; // ISO 8601 string
  final String gender;
  @JsonKey(name: 'profile_image_url')
  final String? profileImageUrl; // Server URL after upload

  // fromJson, toJson, copyWith, ==, hashCode
  PersonalDetails toEntity();
  factory PersonalDetailsModel.fromEntity(PersonalDetails entity);
}
```

Similar models for:
- `ProfessionalDetailsModel`
- `AddressDetailsModel`
- `DocumentUploadModel`
- `PaymentDetailsModel`
- `RegistrationModel` (combines all)

#### 1.2 Create Local Data Source (lib/features/registration/infrastructure/data_sources/local/)

```dart
// registration_local_ds.dart
class RegistrationLocalDs {
  /// Save registration state to encrypted Hive
  Future<void> saveRegistrationState(RegistrationModel registration) async {
    final box = await SecureHiveStorage.openEncryptedBox(HiveBoxes.registrationBox);
    await box.put('current_registration', registration.toJson());
    await box.put('last_updated', DateTime.now().toIso8601String());
  }

  /// Get saved registration state
  Future<RegistrationModel?> getRegistrationState() async {
    final box = await SecureHiveStorage.openEncryptedBox(HiveBoxes.registrationBox);
    final data = box.get('current_registration') as Map<dynamic, dynamic>?;

    if (data == null) return null;

    // Check if expired (>24h)
    final lastUpdatedStr = box.get('last_updated') as String?;
    if (lastUpdatedStr != null) {
      final lastUpdated = DateTime.parse(lastUpdatedStr);
      final now = DateTime.now();
      if (now.difference(lastUpdated).inHours > 24) {
        await clearRegistrationState();
        return null;
      }
    }

    return RegistrationModel.fromJson(Map<String, dynamic>.from(data));
  }

  /// Clear registration state (on success or cancellation)
  Future<void> clearRegistrationState() async {
    final box = await SecureHiveStorage.openEncryptedBox(HiveBoxes.registrationBox);
    await box.delete('current_registration');
    await box.delete('last_updated');
  }
}
```

#### 1.3 Create Remote Data Source (lib/features/registration/infrastructure/data_sources/remote/)

```dart
// registration_api.dart
class RegistrationApi {
  final ApiClient _apiClient;

  /// Submit complete registration
  /// POST /api/membership/practitioner/register/
  Future<RegistrationResponseModel> submitRegistration({
    required RegistrationModel registration,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        Endpoints.practitionerRegistration,
        data: registration.toJson(),
      );

      return RegistrationResponseModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Upload document
  /// POST /api/membership/documents/upload/
  Future<String> uploadDocument({
    required String filePath,
    required String documentType,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'type': documentType,
    });

    final response = await _apiClient.post<Map<String, dynamic>>(
      Endpoints.documentUpload,
      data: formData,
    );

    return response.data!['url'] as String; // Server URL
  }

  /// Process payment
  /// POST /api/membership/payment/initiate/
  Future<PaymentResponseModel> initiatePayment({
    required String registrationId,
    required double amount,
  }) async {
    // Payment gateway integration
  }
}
```

#### 1.4 Create Repository (lib/features/registration/infrastructure/repositories/)

```dart
// registration_repository_impl.dart
class RegistrationRepositoryImpl implements RegistrationRepository {
  final RegistrationApi _api;
  final RegistrationLocalDs _localDs;

  /// Check for existing registration state
  Future<PractitionerRegistration?> getExistingRegistration() async {
    final model = await _localDs.getRegistrationState();
    return model?.toEntity();
  }

  /// Save current step data (auto-save on "Next")
  Future<void> saveStepData({
    required PractitionerRegistration registration,
  }) async {
    final model = RegistrationModel.fromEntity(registration);
    await _localDs.saveRegistrationState(model);
  }

  /// Upload document to server
  Future<String> uploadDocument({
    required String filePath,
    required DocumentType type,
  }) async {
    return await _api.uploadDocument(
      filePath: filePath,
      documentType: type.name,
    );
  }

  /// Submit final registration (with payment)
  Future<String> submitRegistration({
    required PractitionerRegistration registration,
  }) async {
    final response = await _api.submitRegistration(
      registration: RegistrationModel.fromEntity(registration),
    );

    // Clear Hive on success
    await _localDs.clearRegistrationState();

    return response.registrationId;
  }

  /// Cancel registration (clear Hive)
  Future<void> cancelRegistration() async {
    await _localDs.clearRegistrationState();
  }
}
```

---

### Phase 2: State Management

#### 2.1 Create State Notifier (lib/features/registration/application/providers/)

```dart
// registration_state_notifier.dart
class RegistrationStateNotifier extends StateNotifier<RegistrationState> {
  final RegistrationRepository _repository;
  final Uuid _uuid = const Uuid();

  RegistrationStateNotifier({
    required RegistrationRepository repository,
  })  : _repository = repository,
        super(const RegistrationStateInitial()) {
    _checkExistingRegistration();
  }

  /// Check for incomplete registration on app start
  Future<void> _checkExistingRegistration() async {
    try {
      final existing = await _repository.getExistingRegistration();

      if (existing != null && !existing.isExpired) {
        // Prompt to resume
        state = RegistrationStateResumePrompt(existingRegistration: existing);
      } else {
        // Start fresh
        state = const RegistrationStateInitial();
      }
    } catch (e) {
      state = const RegistrationStateInitial();
    }
  }

  /// Start new registration
  void startNewRegistration() {
    final registration = PractitionerRegistration(
      registrationId: _uuid.v4(),
      createdAt: DateTime.now(),
      lastUpdatedAt: DateTime.now(),
    );

    state = RegistrationStateInProgress(registration: registration);
  }

  /// Resume existing registration
  void resumeRegistration(PractitionerRegistration existing) {
    state = RegistrationStateInProgress(registration: existing);
  }

  /// Update personal details (Step 1)
  void updatePersonalDetails(PersonalDetails details) {
    if (state case RegistrationStateInProgress(:final registration)) {
      final updated = registration.copyWith(
        personalDetails: details,
        lastUpdatedAt: DateTime.now(),
      );

      state = RegistrationStateInProgress(
        registration: updated,
        hasUnsavedChanges: true,
      );
    }
  }

  /// Update professional details (Step 2)
  void updateProfessionalDetails(ProfessionalDetails details) {
    if (state case RegistrationStateInProgress(:final registration)) {
      final updated = registration.copyWith(
        professionalDetails: details,
        lastUpdatedAt: DateTime.now(),
      );

      state = RegistrationStateInProgress(
        registration: updated,
        hasUnsavedChanges: true,
      );
    }
  }

  // Similar for addressDetails, documentUploads, paymentDetails

  /// Navigate to next step (with auto-save)
  Future<void> goToNextStep() async {
    if (state case RegistrationStateInProgress(:final registration)) {
      // Validate current step
      if (!registration.canProceedToNext) {
        state = RegistrationStateValidationError(
          message: 'Please complete all required fields',
          currentRegistration: registration,
        );
        return;
      }

      state = const RegistrationStateLoading(message: 'Saving progress...');

      try {
        // Auto-save to Hive
        await _repository.saveStepData(registration: registration);

        // Move to next step
        final nextStep = registration.currentStep.next;
        if (nextStep != null) {
          final updated = registration.copyWith(
            currentStep: nextStep,
            lastUpdatedAt: DateTime.now(),
          );

          state = RegistrationStateInProgress(
            registration: updated,
            hasUnsavedChanges: false,
          );
        }
      } catch (e) {
        state = RegistrationStateError(
          message: 'Failed to save progress',
          currentRegistration: registration,
        );
      }
    }
  }

  /// Navigate to previous step
  void goToPreviousStep() {
    if (state case RegistrationStateInProgress(:final registration)) {
      final prevStep = registration.currentStep.previous;
      if (prevStep != null) {
        final updated = registration.copyWith(currentStep: prevStep);
        state = RegistrationStateInProgress(registration: updated);
      }
    }
  }

  /// Submit final registration
  Future<void> submitRegistration() async {
    if (state case RegistrationStateInProgress(:final registration)) {
      if (!registration.isComplete) {
        state = RegistrationStateValidationError(
          message: 'Please complete all steps',
          currentRegistration: registration,
        );
        return;
      }

      state = const RegistrationStateLoading(message: 'Submitting registration...');

      try {
        final registrationId = await _repository.submitRegistration(
          registration: registration,
        );

        state = RegistrationStateSuccess(registrationId: registrationId);
      } on AuthException catch (e) {
        state = RegistrationStateError(
          message: e.message,
          code: e.code,
          currentRegistration: registration,
        );
      } catch (e) {
        state = RegistrationStateError(
          message: 'Registration failed. Please try again.',
          currentRegistration: registration,
        );
      }
    }
  }

  /// Cancel registration
  Future<void> cancelRegistration() async {
    state = const RegistrationStateLoading(message: 'Cancelling...');

    await _repository.cancelRegistration();
    state = const RegistrationStateInitial();
  }
}

// Provider
final registrationProvider =
    StateNotifierProvider<RegistrationStateNotifier, RegistrationState>((ref) {
  final repository = ref.watch(registrationRepositoryProvider);
  return RegistrationStateNotifier(repository: repository);
});
```

---

### Phase 3: UI Screens

#### 3.1 Screen Structure (lib/features/registration/presentation/screens/)

Create 5 screens, all following this pattern:

```dart
// personal_details_screen.dart (Step 1 of 5)
class PersonalDetailsScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends ConsumerState<PersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  // ... other controllers

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final state = ref.read(registrationProvider);
    if (state case RegistrationStateInProgress(:final registration)) {
      final personal = registration.personalDetails;
      if (personal != null) {
        _firstNameController.text = personal.firstName;
        _lastNameController.text = personal.lastName;
        // ... populate all fields
      }
    }
  }

  void _handleNext() {
    if (_formKey.currentState?.validate() ?? false) {
      final personalDetails = PersonalDetails(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        // ... all fields
      );

      // Update state
      ref.read(registrationProvider.notifier).updatePersonalDetails(personalDetails);

      // Navigate to next step (triggers auto-save)
      ref.read(registrationProvider.notifier).goToNextStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    final registrationState = ref.watch(registrationProvider);

    // Listen for state changes
    ref.listen<RegistrationState>(registrationProvider, (previous, next) {
      switch (next) {
        case RegistrationStateInProgress(:final registration):
          if (registration.currentStep == RegistrationStep.professionalDetails) {
            // Navigate to next screen
            Navigator.pushNamed(context, '/registration/professional');
          }
        case RegistrationStateValidationError(:final message):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        case RegistrationStateError(:final message):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        default:
          break;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Step 1 of ${RegistrationStep.totalSteps}'),
        // Progress indicator
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: RegistrationStep.personalDetails.progress,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text('Personal Details', style: TextStyle(fontSize: 24.sp)),
              SizedBox(height: 32.h),

              // Form fields
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name *'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'First name is required';
                  }
                  return null;
                },
              ),
              // ... all other fields

              SizedBox(height: 32.h),

              // Next button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: registrationState is RegistrationStateLoading
                      ? null
                      : _handleNext,
                  child: registrationState is RegistrationStateLoading
                      ? const CircularProgressIndicator()
                      : const Text('Next'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}
```

Repeat for:
- `professional_details_screen.dart` (Step 2)
- `address_details_screen.dart` (Step 3)
- `document_upload_screen.dart` (Step 4) - with file picker
- `payment_screen.dart` (Step 5) - with payment gateway integration

#### 3.2 Resume Prompt Dialog

```dart
// resume_registration_dialog.dart
class ResumeRegistrationDialog extends ConsumerWidget {
  final PractitionerRegistration existingRegistration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Continue Registration?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('You have an incomplete registration from ${DateFormat.yMd().format(existingRegistration.lastUpdatedAt)}'),
          SizedBox(height: 16.h),
          LinearProgressIndicator(value: existingRegistration.completionPercentage),
          SizedBox(height: 8.h),
          Text('${(existingRegistration.completionPercentage * 100).toStringAsFixed(0)}% complete'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(registrationProvider.notifier).cancelRegistration();
            Navigator.of(context).pop();
          },
          child: const Text('Start Fresh'),
        ),
        ElevatedButton(
          onPressed: () {
            ref.read(registrationProvider.notifier).resumeRegistration(existingRegistration);
            Navigator.of(context).pop();
            // Navigate to current step screen
          },
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
```

---

## 🔐 Security & Data Handling

### Encrypted Storage
- All registration data stored in **encrypted Hive** (SecureHiveStorage)
- 24-hour expiry enforced on retrieval
- Auto-clear on successful submission or cancellation

### File Uploads
- Documents stored locally first (app documents directory)
- Upload to server in background (Step 4)
- Server URLs stored in registration state
- Retry failed uploads automatically

### State Persistence Rules
1. **Auto-save on "Next":** Save to Hive before proceeding
2. **Manual save:** "Save Draft" button on all screens
3. **On app restart:** Check for existing registration → Show resume prompt
4. **On cancellation:** Clear Hive immediately
5. **On success:** Clear Hive after server confirmation

---

## 📦 Dependencies Required

Add to `pubspec.yaml`:
```yaml
dependencies:
  file_picker: ^8.0.0  # For document selection
  image_picker: ^1.1.2  # For profile photo
  permission_handler: ^11.3.1  # For file/camera permissions
```

---

## 🎯 Next Steps

1. ✅ Create all DTOs with json_serializable
2. ✅ Implement RegistrationLocalDs with encryption
3. ✅ Implement RegistrationApi with endpoints
4. ✅ Implement RegistrationRepositoryImpl
5. ✅ Create RegistrationStateNotifier
6. ✅ Build all 5 UI screens
7. ✅ Test multi-step flow
8. ✅ Test state persistence (kill app, reopen)
9. ✅ Test document uploads
10. ✅ Integrate payment gateway

---

**Status:** Domain entities and application state architecture complete
**Next:** Implement infrastructure layer (DTOs, data sources, repository)
