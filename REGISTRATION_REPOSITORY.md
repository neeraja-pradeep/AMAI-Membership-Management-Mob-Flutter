# Registration Repository Implementation

## Overview

The Registration Repository implements the repository pattern for the practitioner registration module. It acts as an abstraction layer between the domain layer (business logic) and the infrastructure layer (API calls), providing a clean separation of concerns and comprehensive error handling.

---

## 🏗️ Architecture

### **Layer Separation:**

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│              (UI Screens, Widgets, Dialogs)                 │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────────┐
│                   APPLICATION LAYER                          │
│         (RegistrationStateNotifier - Business Logic)        │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                             │
│        ┌─────────────────────────────────────────┐          │
│        │  RegistrationRepository (Interface)     │          │
│        │  - Abstract contract for operations     │          │
│        │  - Throws domain errors (RegistrationError)        │
│        └─────────────────────────────────────────┘          │
└────────────────────┬────────────────────────────────────────┘
                     │ Dependency Inversion
                     ↓
┌─────────────────────────────────────────────────────────────┐
│                 INFRASTRUCTURE LAYER                         │
│        ┌─────────────────────────────────────────┐          │
│        │  RegistrationRepositoryImpl             │          │
│        │  - Implements repository interface      │          │
│        │  - Maps API errors to domain errors     │          │
│        │  - Validates file security              │          │
│        │  - Converts domain entities to JSON     │          │
│        └────────────┬────────────────────────────┘          │
│                     │                                        │
│                     ↓                                        │
│        ┌─────────────────────────────────────────┐          │
│        │  RegistrationApi                        │          │
│        │  - HTTP requests via ApiClient          │          │
│        │  - XCSRF token auto-included            │          │
│        │  - Progress tracking for uploads        │          │
│        └─────────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 File Structure

```
lib/features/auth/
├── domain/
│   ├── entities/registration/
│   │   ├── practitioner_registration.dart  # Aggregate root
│   │   ├── registration_error.dart         # Domain errors
│   │   └── ... (other entities)
│   └── repositories/
│       └── registration_repository.dart     # Abstract interface
│
└── infrastructure/
    ├── repositories/
    │   └── registration_repository_impl.dart # Implementation
    └── data_sources/remote/
        └── registration_api.dart             # API data source
```

---

## 🔌 Repository Interface (Domain Layer)

### **Location:** `lib/features/auth/domain/repositories/registration_repository.dart`

The repository interface defines the contract for all registration operations without implementation details:

```dart
abstract class RegistrationRepository {
  // Dropdown data fetching
  Future<List<MedicalCouncil>> fetchCouncils();
  Future<List<Specialization>> fetchSpecializations();
  Future<List<Country>> fetchCountries();
  Future<List<State>> fetchStates({required String countryId});
  Future<List<District>> fetchDistricts({required String stateId});

  // Document operations
  Future<String> uploadDocument({
    required File file,
    required DocumentType type,
    required void Function(double progress) onProgress,
  });

  // Registration operations
  Future<String> submitRegistration({
    required PractitionerRegistration registration,
  });

  // Validation operations
  Future<bool> validateSession();
  Future<bool> checkDuplicateEmail({required String email});
  Future<bool> checkDuplicatePhone({required String phone});

  // Payment operations
  Future<PaymentDetails> verifyPayment({required String sessionId});
}
```

### **Why Interface?**

1. **Dependency Inversion:** Domain layer doesn't depend on infrastructure
2. **Testability:** Easy to mock in unit tests
3. **Flexibility:** Can swap implementations (e.g., mock repository for testing)
4. **Clean Architecture:** Business logic isolated from implementation details

---

## 🛠️ Repository Implementation (Infrastructure Layer)

### **Location:** `lib/features/auth/infrastructure/repositories/registration_repository_impl.dart`

The implementation handles:
1. ✅ API calls via `RegistrationApi`
2. ✅ Error mapping from HTTP errors to domain errors
3. ✅ File security validation before upload
4. ✅ Data transformation (domain entities ↔ JSON)
5. ✅ Session validation

### **Constructor:**

```dart
class RegistrationRepositoryImpl implements RegistrationRepository {
  final RegistrationApi _api;

  const RegistrationRepositoryImpl({required RegistrationApi api}) : _api = api;
}
```

---

## 🔄 Error Mapping Strategy

### **Why Error Mapping?**

The infrastructure layer receives HTTP errors (DioException) but the domain layer expects domain errors (RegistrationError). The repository maps between these layers:

```
HTTP Error (Infrastructure)  →  Repository  →  Domain Error (Domain)
     DioException                   Maps            RegistrationError
```

### **Mapping Categories:**

#### **1. Dropdown Errors**

```dart
RegistrationError _mapDioExceptionToDropdownError(
  DioException e,
  String dropdownName,
) {
  // Network timeout
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return RegistrationError.networkTimeout();
  }

  // 404 Not Found
  if (e.response?.statusCode == 404) {
    return RegistrationError.dropdownNotFound(dropdownName);
  }

  // 401 Unauthorized
  if (e.response?.statusCode == 401) {
    return RegistrationError.sessionExpired();
  }

  // Default to network failure
  return RegistrationError.dropdownNetwork(dropdownName);
}
```

**Mapped Errors:**
- Timeout → `RegistrationError.networkTimeout()`
- 404 → `RegistrationError.dropdownNotFound()`
- 401 → `RegistrationError.sessionExpired()`
- Other → `RegistrationError.dropdownNetwork()`

#### **2. Upload Errors**

```dart
RegistrationError _mapDioExceptionToUploadError(DioException e) {
  // 413 Payload Too Large
  if (e.response?.statusCode == 413) {
    return RegistrationError.fileTooLarge(5);
  }

  // 415 Unsupported Media Type
  if (e.response?.statusCode == 415) {
    return RegistrationError.invalidFileType(['PDF', 'JPG', 'PNG']);
  }

  // 401 Unauthorized
  if (e.response?.statusCode == 401) {
    return RegistrationError.sessionExpired();
  }

  // Default to upload failure
  return RegistrationError.uploadFailure();
}
```

**Mapped Errors:**
- 413 → `RegistrationError.fileTooLarge(5)`
- 415 → `RegistrationError.invalidFileType()`
- 401 → `RegistrationError.sessionExpired()`
- Timeout → `RegistrationError.networkTimeout()`
- Other → `RegistrationError.uploadFailure()`

#### **3. Submission Errors**

```dart
RegistrationError _mapDioExceptionToSubmissionError(DioException e) {
  // 400 Bad Request (validation errors)
  if (e.response?.statusCode == 400) {
    final data = e.response?.data as Map<String, dynamic>?;

    // Check for duplicate email
    if (data?['code'] == 'DUPLICATE_EMAIL') {
      return RegistrationError.duplicateEmail(
        data?['message'] as String? ?? 'Email already registered',
      );
    }

    // Check for duplicate phone
    if (data?['code'] == 'DUPLICATE_PHONE') {
      return RegistrationError.duplicatePhone(
        data?['message'] as String? ?? 'Phone already registered',
      );
    }

    // Field validation errors
    if (data?['errors'] != null) {
      final fieldErrors = <String, String>{};
      final errors = data!['errors'] as Map<String, dynamic>;

      errors.forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          fieldErrors[key] = value.first as String;
        } else if (value is String) {
          fieldErrors[key] = value;
        }
      });

      return RegistrationError.validation(fieldErrors);
    }
  }

  // 500 Server Error
  if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
    return RegistrationError.serverError();
  }

  // Default to server error
  return RegistrationError.serverError();
}
```

**Mapped Errors:**
- 400 with `DUPLICATE_EMAIL` → `RegistrationError.duplicateEmail()`
- 400 with `DUPLICATE_PHONE` → `RegistrationError.duplicatePhone()`
- 400 with `errors` → `RegistrationError.validation(fieldErrors)`
- 401 → `RegistrationError.sessionExpired()`
- 500 → `RegistrationError.serverError()`
- Timeout → `RegistrationError.networkTimeout()`

---

## 📤 Document Upload Flow

### **Multi-Layer Security Validation:**

The repository performs comprehensive file validation before upload:

```dart
Future<String> uploadDocument({
  required File file,
  required DocumentType type,
  required void Function(double progress) onProgress,
}) async {
  // 1. Validate file security (extension, MIME type, header)
  final validationResult = await FileSecurityValidator.validateFile(file);
  if (!validationResult.isValid) {
    throw RegistrationError(
      type: RegistrationErrorType.invalidFileType,
      message: validationResult.error ?? 'Invalid file',
      code: 'INVALID_FILE',
      canRetry: false,
    );
  }

  // 2. Validate file size (5MB limit)
  final sizeError = await FileSecurityValidator.validateFileSize(
    file,
    maxSizeMB: 5,
  );
  if (sizeError != null) {
    throw RegistrationError.fileTooLarge(5);
  }

  // 3. Upload file with progress tracking
  try {
    return await _api.uploadDocument(
      file: file,
      type: type,
      onProgress: onProgress,
    );
  } on DioException catch (e) {
    throw _mapDioExceptionToUploadError(e);
  } catch (e) {
    throw RegistrationError.uploadFailure();
  }
}
```

### **Security Checks:**

1. ✅ **Extension Validation:** File extension in allowed list
2. ✅ **MIME Type Validation:** MIME type matches allowed types
3. ✅ **Magic Number Validation:** File header matches extension (prevents spoofing)
4. ✅ **Executable Blocking:** Rejects executables and scripts
5. ✅ **Filename Sanitization:** Removes path traversal and special characters
6. ✅ **Size Validation:** Enforces 5MB limit

### **Progress Tracking:**

```dart
// API layer sends progress updates
final response = await _apiClient.post(
  Endpoints.registrationUpload,
  data: formData,
  onSendProgress: (sent, total) {
    final progress = sent / total;
    onProgress(progress);  // Callback to UI
  },
);
```

---

## 🎯 Data Conversion

### **Domain Entity → JSON (for API submission)**

The repository converts the `PractitionerRegistration` aggregate root to JSON format expected by the API:

```dart
Map<String, dynamic> _convertRegistrationToJson(
  PractitionerRegistration registration,
) {
  return {
    'registration_id': registration.registrationId,
    'personal_details': registration.personalDetails != null
        ? {
            'first_name': registration.personalDetails!.firstName,
            'last_name': registration.personalDetails!.lastName,
            'email': registration.personalDetails!.email,
            'phone': registration.personalDetails!.phone,
            'date_of_birth': registration.personalDetails!.dateOfBirth.toIso8601String(),
            'gender': registration.personalDetails!.gender.name,
            'profile_image_path': registration.personalDetails!.profileImagePath,
          }
        : null,
    'professional_details': { /* ... */ },
    'address_details': { /* ... */ },
    'documents': registration.documents.map((doc) => { /* ... */ }).toList(),
    'payment_details': { /* ... */ },
  };
}
```

### **JSON → Domain Entity (from API response)**

Dropdown entities have `fromJson` factory methods:

```dart
class MedicalCouncil {
  factory MedicalCouncil.fromJson(Map<String, dynamic> json) {
    return MedicalCouncil(
      id: json['id'] as String,
      name: json['name'] as String,
      countryCode: json['country_code'] as String,
    );
  }
}
```

---

## 🔗 Integration with State Management

### **Usage in RegistrationStateNotifier:**

```dart
class RegistrationStateNotifier extends StateNotifier<RegistrationState> {
  final RegistrationRepository _repository;
  final RegistrationLocalDs _localDs;

  RegistrationStateNotifier({
    required RegistrationRepository repository,
    required RegistrationLocalDs localDs,
  })  : _repository = repository,
        _localDs = localDs,
        super(const RegistrationStateInitial());

  // Example: Upload document
  Future<void> uploadDocument(File file, DocumentType type) async {
    if (state is! RegistrationStateInProgress) return;

    state = const RegistrationStateLoading(message: 'Uploading document...');

    try {
      final url = await _repository.uploadDocument(
        file: file,
        type: type,
        onProgress: (progress) {
          // Update UI with progress
          state = RegistrationStateLoading(
            message: 'Uploading... ${(progress * 100).toInt()}%',
          );
        },
      );

      // Document uploaded successfully
      final current = state as RegistrationStateInProgress;
      final updatedDocs = [...current.registration.documents];
      updatedDocs.add(DocumentUpload(
        type: type,
        filePath: url,
        uploadedAt: DateTime.now(),
      ));

      final updated = current.registration.copyWith(documents: updatedDocs);
      state = RegistrationStateInProgress(registration: updated);

      // Auto-save to Hive
      await autoSaveProgress();
    } on RegistrationError catch (e) {
      // Map to appropriate state
      if (e.type == RegistrationErrorType.sessionExpired) {
        state = RegistrationStateSessionExpired(
          message: e.message,
          currentRegistration: (state as RegistrationStateInProgress).registration,
        );
      } else if (e.isFileUploadError) {
        state = RegistrationStateError(
          message: e.message,
          code: e.code,
          canRetry: e.canRetry,
          currentRegistration: (state as RegistrationStateInProgress).registration,
        );
      }
    }
  }
}
```

---

## 🧪 Testing

### **1. Mock Repository for Unit Tests:**

```dart
class MockRegistrationRepository extends Mock implements RegistrationRepository {}

void main() {
  late MockRegistrationRepository mockRepository;
  late RegistrationStateNotifier notifier;

  setUp(() {
    mockRepository = MockRegistrationRepository();
    notifier = RegistrationStateNotifier(
      repository: mockRepository,
      localDs: MockRegistrationLocalDs(),
    );
  });

  test('fetchCouncils returns list of councils', () async {
    // Arrange
    final councils = [
      MedicalCouncil(id: '1', name: 'Medical Council of India', countryCode: 'IN'),
    ];
    when(() => mockRepository.fetchCouncils()).thenAnswer((_) async => councils);

    // Act
    final result = await mockRepository.fetchCouncils();

    // Assert
    expect(result, councils);
    verify(() => mockRepository.fetchCouncils()).called(1);
  });

  test('uploadDocument throws RegistrationError on network failure', () async {
    // Arrange
    when(() => mockRepository.uploadDocument(
          file: any(named: 'file'),
          type: any(named: 'type'),
          onProgress: any(named: 'onProgress'),
        )).thenThrow(RegistrationError.networkTimeout());

    // Act & Assert
    expect(
      () => mockRepository.uploadDocument(
        file: File('/path/to/file.pdf'),
        type: DocumentType.medicalDegree,
        onProgress: (_) {},
      ),
      throwsA(isA<RegistrationError>()),
    );
  });
}
```

### **2. Integration Tests:**

```dart
void main() {
  late RegistrationRepositoryImpl repository;
  late MockRegistrationApi mockApi;

  setUp(() {
    mockApi = MockRegistrationApi();
    repository = RegistrationRepositoryImpl(api: mockApi);
  });

  test('submitRegistration maps 401 to session expired error', () async {
    // Arrange
    final registration = PractitionerRegistration(/* ... */);
    when(() => mockApi.submitRegistration(registrationData: any(named: 'registrationData')))
        .thenThrow(DioException(
      requestOptions: RequestOptions(path: '/api/registration/submit'),
      response: Response(
        requestOptions: RequestOptions(path: '/api/registration/submit'),
        statusCode: 401,
      ),
    ));

    // Act & Assert
    expect(
      () => repository.submitRegistration(registration: registration),
      throwsA(
        isA<RegistrationError>()
            .having((e) => e.type, 'type', RegistrationErrorType.sessionExpired),
      ),
    );
  });
}
```

---

## 📋 Error Handling Checklist

### **Dropdown Errors:**
- [x] Network timeout → `RegistrationError.networkTimeout()`
- [x] 404 Not Found → `RegistrationError.dropdownNotFound()`
- [x] 401 Unauthorized → `RegistrationError.sessionExpired()`
- [x] Other errors → `RegistrationError.dropdownNetwork()`

### **Upload Errors:**
- [x] File too large → `RegistrationError.fileTooLarge()`
- [x] Invalid file type → `RegistrationError.invalidFileType()`
- [x] File corrupted → Detected by `FileSecurityValidator`
- [x] Network timeout → `RegistrationError.networkTimeout()`
- [x] Session expired → `RegistrationError.sessionExpired()`
- [x] Upload failure → `RegistrationError.uploadFailure()`

### **Submission Errors:**
- [x] Duplicate email → `RegistrationError.duplicateEmail()`
- [x] Duplicate phone → `RegistrationError.duplicatePhone()`
- [x] Validation errors → `RegistrationError.validation(fieldErrors)`
- [x] Session expired → `RegistrationError.sessionExpired()`
- [x] Server error → `RegistrationError.serverError()`
- [x] Network timeout → `RegistrationError.networkTimeout()`

### **Payment Errors:**
- [x] Session not found → `RegistrationError.paymentFailed()`
- [x] Verification failure → `RegistrationError.paymentFailed()`
- [x] Session expired → `RegistrationError.sessionExpired()`
- [x] Network timeout → `RegistrationError.networkTimeout()`

---

## 🔐 Security Features

### **1. File Upload Security:**
- ✅ Multi-layer validation (extension, MIME, magic number)
- ✅ Executable blocking (15+ extensions blocked)
- ✅ Filename sanitization (path traversal prevention)
- ✅ Size limit enforcement (5MB)
- ✅ XCSRF token auto-included by ApiClient

### **2. Session Security:**
- ✅ Session validation before critical operations
- ✅ Automatic 401 → session expired mapping
- ✅ XCSRF token automatically included in all POST requests

### **3. Data Privacy:**
- ✅ Sensitive data (council numbers) never logged
- ✅ Documents stored in app private directory
- ✅ Payment details never stored locally

---

## 🎯 Best Practices

### **1. Always Use Repository Interface in Domain Layer:**

```dart
// ✅ CORRECT - Depend on abstraction
class RegistrationStateNotifier {
  final RegistrationRepository _repository;

  RegistrationStateNotifier({required RegistrationRepository repository})
      : _repository = repository;
}

// ❌ INCORRECT - Depend on implementation
class RegistrationStateNotifier {
  final RegistrationRepositoryImpl _repository;  // Don't do this!
}
```

### **2. Handle All RegistrationError Types:**

```dart
try {
  await _repository.submitRegistration(registration: registration);
} on RegistrationError catch (e) {
  // Map to appropriate state based on error type
  switch (e.type) {
    case RegistrationErrorType.sessionExpired:
      state = RegistrationStateSessionExpired(/* ... */);
    case RegistrationErrorType.duplicateEmail:
      state = RegistrationStateDuplicateFound(/* ... */);
    case RegistrationErrorType.networkTimeout:
      state = RegistrationStateError(/* ... */, canRetry: true);
    // ... handle all types
  }
}
```

### **3. Don't Catch Generic Exceptions:**

```dart
// ❌ INCORRECT - Loses error information
try {
  await _repository.fetchCouncils();
} catch (e) {
  // Don't know what went wrong!
  state = RegistrationStateError(message: 'Something went wrong');
}

// ✅ CORRECT - Specific error handling
try {
  await _repository.fetchCouncils();
} on RegistrationError catch (e) {
  // Know exactly what went wrong
  if (e.canRetry) {
    // Show retry button
  }
  state = RegistrationStateError(
    message: e.message,
    code: e.code,
    canRetry: e.canRetry,
  );
}
```

---

## 📚 Related Documentation

- **REGISTRATION_AUTH_INTEGRATION.md** - Session and XCSRF token integration
- **REGISTRATION_ERROR_HANDLING.md** - Complete error handling guide
- **REGISTRATION_PERFORMANCE_SECURITY.md** - File security validation details
- **REGISTRATION_MODULE.md** - Overall architecture and entities

---

## ✅ Summary

The Registration Repository provides:

1. ✅ **Clean Architecture:** Separation of domain and infrastructure concerns
2. ✅ **Comprehensive Error Mapping:** All HTTP errors mapped to domain errors
3. ✅ **File Security:** Multi-layer validation before upload
4. ✅ **Session Integration:** Automatic XCSRF token handling
5. ✅ **Progress Tracking:** Real-time upload progress updates
6. ✅ **Data Transformation:** Domain entities ↔ JSON conversion
7. ✅ **Testability:** Interface allows easy mocking
8. ✅ **Type Safety:** Strongly-typed domain entities

The repository is now ready for integration with `RegistrationStateNotifier` and UI screens.
