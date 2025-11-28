# Registration Performance & Security Requirements

## Overview
Comprehensive performance optimization and security hardening requirements for the 5-step practitioner registration flow.

---

## ⚡ Performance Requirements

### **Screen Load Times**

| Screen | Target | With Cached Data | Data Source |
|--------|--------|------------------|-------------|
| Screen 1 (Personal Details) | < 2s | < 500ms | Hive cache + API |
| Screen 2 (Professional Details) | < 500ms | N/A | Memory |
| Screen 3 (Address Details) | < 500ms | N/A | Memory |
| Screen 4 (Document Uploads) | < 500ms | N/A | Memory |
| Screen 5 (Payment) | < 500ms | N/A | Memory |
| Dependent Dropdown Load | < 1s | N/A | API |

**Implementation:**

```dart
// Screen 1: Use cached dropdown data
class PersonalDetailsScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<PersonalDetailsScreen> createState() =>
      _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends ConsumerState<PersonalDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    final startTime = DateTime.now();

    // Load from cache first (< 500ms)
    final cachedData = await _dropdownCache.getGenders();
    if (cachedData != null && !_dropdownCache.isStale(cachedData)) {
      setState(() => _genders = cachedData.items);

      final loadTime = DateTime.now().difference(startTime);
      _analytics.logPerformance('dropdown_load_cached', loadTime.inMilliseconds);

      // Refresh in background
      _refreshDropdownDataInBackground();
      return;
    }

    // Load from API (< 2s total)
    try {
      final apiData = await _api.getGenders().timeout(
        const Duration(seconds: 2),
        onTimeout: () => throw TimeoutException('Dropdown load timeout'),
      );

      setState(() => _genders = apiData);

      // Cache for next time
      await _dropdownCache.saveGenders(apiData);

      final loadTime = DateTime.now().difference(startTime);
      _analytics.logPerformance('dropdown_load_api', loadTime.inMilliseconds);
    } catch (e) {
      // Handle error (see REGISTRATION_ERROR_HANDLING.md)
    }
  }

  Future<void> _refreshDropdownDataInBackground() async {
    try {
      final fresh = await _api.getGenders();
      await _dropdownCache.saveGenders(fresh);
    } catch (e) {
      // Silent failure - user already has cached data
    }
  }
}
```

---

### **File Upload Performance**

| Operation | Target | Notes |
|-----------|--------|-------|
| Image compression (5MB) | < 2s | Use isolate |
| Upload progress updates | Every 100ms | Don't block UI |
| Preview generation | < 500ms | Thumbnail only |

**Implementation:**

```dart
// File upload with performance tracking
class FileUploadService {
  final Dio _dio;
  final ImageCompressionService _compressionService;

  Future<String> uploadDocument({
    required File file,
    required DocumentType type,
    required Function(double) onProgress,
  }) async {
    final startTime = DateTime.now();

    // 1. Compress image if needed (< 2s, in isolate)
    File fileToUpload = file;
    if (_isImage(file) && file.lengthSync() > 1024 * 1024) {
      final compressionStart = DateTime.now();

      fileToUpload = await _compressionService.compressInIsolate(
        file,
        maxSizeMB: 2,
      );

      final compressionTime = DateTime.now().difference(compressionStart);
      _analytics.logPerformance('image_compression', compressionTime.inMilliseconds);

      // Must be < 2s
      assert(compressionTime.inMilliseconds < 2000);
    }

    // 2. Upload with progress (every 100ms)
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        fileToUpload.path,
        filename: fileToUpload.path.split('/').last,
      ),
      'type': type.name,
    });

    final response = await _dio.post(
      '/api/upload',
      data: formData,
      onSendProgress: (sent, total) {
        final progress = sent / total;
        onProgress(progress); // Update every 100ms via throttle
      },
    );

    final totalTime = DateTime.now().difference(startTime);
    _analytics.logPerformance('file_upload', totalTime.inMilliseconds);

    return response.data['url'] as String;
  }

  bool _isImage(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png'].contains(ext);
  }
}

// Image compression in isolate (don't block main thread)
class ImageCompressionService {
  Future<File> compressInIsolate(File file, {required int maxSizeMB}) async {
    // Run compression in separate isolate
    final result = await compute(_compressImage, {
      'path': file.path,
      'maxSizeMB': maxSizeMB,
    });

    return File(result as String);
  }

  static Future<String> _compressImage(Map<String, dynamic> params) async {
    final path = params['path'] as String;
    final maxSizeMB = params['maxSizeMB'] as int;

    final bytes = await File(path).readAsBytes();
    final image = img.decodeImage(bytes)!;

    // Compress
    final compressed = img.encodeJpg(image, quality: 85);

    // Save compressed file
    final compressedPath = path.replaceAll('.', '_compressed.');
    await File(compressedPath).writeAsBytes(compressed);

    return compressedPath;
  }
}

// Preview generation (< 500ms)
Future<Uint8List> generatePreview(File file) async {
  final startTime = DateTime.now();

  final bytes = await file.readAsBytes();
  final image = img.decodeImage(bytes)!;

  // Generate thumbnail (max 200x200)
  final thumbnail = img.copyResize(
    image,
    width: 200,
    height: 200,
    interpolation: img.Interpolation.linear,
  );

  final thumbnailBytes = img.encodeJpg(thumbnail, quality: 80);

  final previewTime = DateTime.now().difference(startTime);
  _analytics.logPerformance('preview_generation', previewTime.inMilliseconds);

  // Must be < 500ms
  assert(previewTime.inMilliseconds < 500);

  return Uint8List.fromList(thumbnailBytes);
}
```

---

### **Form Validation Performance**

| Validation Type | Target | Debounce |
|-----------------|--------|----------|
| Synchronous (regex, length) | < 1ms | N/A |
| Async (uniqueness check) | < 2s | 500ms |

**Implementation:**

```dart
class RegistrationFormValidator {
  final Dio _dio;
  Timer? _debounceTimer;

  // Synchronous validation (< 1ms per field)
  String? validateEmail(String email) {
    final startTime = DateTime.now().microsecondsSinceEpoch;

    if (email.isEmpty) return 'Email is required';

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) return 'Invalid email format';

    final duration = DateTime.now().microsecondsSinceEpoch - startTime;
    assert(duration < 1000); // < 1ms

    return null;
  }

  String? validatePhone(String phone) {
    final startTime = DateTime.now().microsecondsSinceEpoch;

    if (phone.isEmpty) return 'Phone is required';

    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    if (!phoneRegex.hasMatch(phone)) return 'Invalid phone format';

    final duration = DateTime.now().microsecondsSinceEpoch - startTime;
    assert(duration < 1000); // < 1ms

    return null;
  }

  // Async validation with debounce (500ms)
  Future<String?> validateEmailUnique(String email) async {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Wait 500ms before making API call
    return await Future.delayed(const Duration(milliseconds: 500), () async {
      final startTime = DateTime.now();

      try {
        final response = await _dio.get(
          '/api/check-email',
          queryParameters: {'email': email},
        ).timeout(const Duration(seconds: 2));

        final duration = DateTime.now().difference(startTime);
        _analytics.logPerformance('async_validation', duration.inMilliseconds);

        // Must be < 2s
        assert(duration.inMilliseconds < 2000);

        final exists = response.data['exists'] as bool;
        return exists ? 'Email already registered' : null;
      } on TimeoutException {
        return null; // Don't block user on timeout
      }
    });
  }

  void dispose() {
    _debounceTimer?.cancel();
  }
}
```

---

### **Memory Management**

**Requirements:**
- ✅ Dispose all controllers in `dispose()`
- ✅ Cancel API calls on screen exit
- ✅ Clear file previews on successful submission
- ✅ Image compression uses isolate (not block main thread)

**Implementation:**

```dart
class PersonalDetailsScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<PersonalDetailsScreen> createState() =>
      _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends ConsumerState<PersonalDetailsScreen> {
  // Controllers
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  // Focus nodes
  late final FocusNode _emailFocus;
  late final FocusNode _phoneFocus;

  // Cancellation tokens
  final List<CancelToken> _cancelTokens = [];

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _emailFocus = FocusNode();
    _phoneFocus = FocusNode();
  }

  @override
  void dispose() {
    // 1. Dispose all controllers
    _emailController.dispose();
    _phoneController.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();

    // 2. Cancel all API calls
    for (final token in _cancelTokens) {
      token.cancel('Screen disposed');
    }

    super.dispose();
  }

  Future<void> _loadDropdownData() async {
    final cancelToken = CancelToken();
    _cancelTokens.add(cancelToken);

    try {
      final data = await _dio.get(
        '/api/dropdowns',
        cancelToken: cancelToken,
      );

      if (mounted) {
        setState(() => _dropdownData = data);
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        // Screen disposed, don't update state
        return;
      }
      // Handle other errors
    }
  }
}

// Clear file previews on success
ref.listen<RegistrationState>(registrationProvider, (previous, next) {
  if (next is RegistrationStateSuccess) {
    // Clear all file previews from memory
    _filePreviews.clear();

    // Delete files from temp directory
    _deleteTemporaryFiles();

    // Force garbage collection (optional)
    // Note: Dart GC is automatic, this is just a hint
  }
});

Future<void> _deleteTemporaryFiles() async {
  final tempDir = await getTemporaryDirectory();
  final files = tempDir.listSync();

  for (final file in files) {
    if (file is File && file.path.contains('upload_preview_')) {
      await file.delete();
    }
  }
}
```

---

### **Build Performance**

**Requirements:**
- ✅ Dropdown rebuilds only when data changes
- ✅ Form fields don't rebuild on unrelated state changes
- ✅ File preview widgets use const constructors where possible

**Implementation:**

```dart
// Dropdown with selective rebuilds
class GenderDropdown extends ConsumerWidget {
  const GenderDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only rebuild when dropdown data changes, not entire state
    final genders = ref.watch(
      dropdownProvider.select((state) => state.genders),
    );

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Gender'),
      items: genders
          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
          .toList(),
      onChanged: (value) {
        // Update state
      },
    );
  }
}

// Form field with selective rebuilds
class EmailField extends ConsumerWidget {
  const EmailField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only rebuild when email error changes
    final emailError = ref.watch(
      registrationProvider.select((state) {
        if (state is RegistrationStateValidationError) {
          return state.getFieldError('email');
        }
        return null;
      }),
    );

    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Email',
        errorText: emailError,
      ),
      // Don't rebuild on every state change
    );
  }
}

// File preview with const constructor
class FilePreviewTile extends StatelessWidget {
  final String fileName;
  final int fileSizeBytes;
  final VoidCallback onRemove;

  const FilePreviewTile({
    super.key,
    required this.fileName,
    required this.fileSizeBytes,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.insert_drive_file), // const
      title: Text(fileName),
      subtitle: Text(_formatFileSize(fileSizeBytes)),
      trailing: IconButton(
        icon: const Icon(Icons.close), // const
        onPressed: onRemove,
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
```

---

## 🔒 Security Requirements

### **Sensitive Data Handling**

| Data Type | Storage | Logging | Transmission |
|-----------|---------|---------|--------------|
| Council Numbers | Encrypted Hive | ❌ Never | HTTPS only |
| Documents | App private dir | ❌ Never | Delete after upload |
| Payment Info | ❌ Never stored | ❌ Never | Direct to gateway |
| User Data | Encrypted Hive | Sanitized only | HTTPS only |

**Implementation:**

```dart
// Never log sensitive data
class RegistrationLogger {
  final AnalyticsService _analytics;

  void logFormSubmission(PractitionerRegistration registration) {
    _analytics.log('registration_submit', {
      'registration_id': registration.registrationId,
      'step': registration.currentStep.name,
      'timestamp': DateTime.now().toIso8601String(),

      // ❌ NEVER log these:
      // 'council_number': registration.professionalDetails.councilNumber,
      // 'email': registration.personalDetails.email,
      // 'phone': registration.personalDetails.phone,
    });
  }
}

// Store documents in app private directory
class DocumentStorageService {
  Future<String> saveDocument(File file, DocumentType type) async {
    // Get app private directory (not accessible by other apps)
    final appDir = await getApplicationDocumentsDirectory();
    final privateDir = Directory('${appDir.path}/temp_uploads');

    if (!await privateDir.exists()) {
      await privateDir.create(recursive: true);
    }

    // Save with secure filename
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = file.path.split('.').last;
    final secureName = '${type.name}_$timestamp.$extension';
    final privatePath = '${privateDir.path}/$secureName';

    await file.copy(privatePath);

    return privatePath;
  }

  Future<void> deleteAllDocuments() async {
    final appDir = await getApplicationDocumentsDirectory();
    final privateDir = Directory('${appDir.path}/temp_uploads');

    if (await privateDir.exists()) {
      await privateDir.delete(recursive: true);
    }
  }
}

// Never store payment info locally
class PaymentService {
  Future<PaymentResult> processPayment({
    required double amount,
    required String currency,
  }) async {
    // ❌ NEVER do this:
    // await hive.put('payment_card', cardNumber);
    // await hive.put('payment_cvv', cvv);

    // ✅ Send directly to payment gateway
    final result = await _paymentGateway.charge(
      amount: amount,
      currency: currency,
      // Payment details from gateway SDK, never stored locally
    );

    return result;
  }
}
```

---

### **File Upload Security**

**Requirements:**
- ✅ Validate file extension AND MIME type
- ✅ Scan file headers to prevent extension spoofing
- ✅ Reject executable files (.exe, .apk, .sh)
- ✅ Sanitize file names before upload

**Implementation:**

```dart
class FileSecurityValidator {
  // Allowed MIME types
  static const _allowedMimeTypes = {
    'image/jpeg',
    'image/png',
    'application/pdf',
  };

  // Blocked extensions
  static const _blockedExtensions = {
    'exe', 'apk', 'sh', 'bat', 'cmd', 'com',
    'msi', 'jar', 'app', 'dmg', 'deb', 'rpm',
  };

  /// Comprehensive file validation
  Future<FileValidationResult> validateFile(File file) async {
    // 1. Validate extension
    final extension = file.path.split('.').last.toLowerCase();

    if (_blockedExtensions.contains(extension)) {
      return FileValidationResult.failure(
        'Executable files are not allowed',
      );
    }

    // 2. Validate MIME type
    final mimeType = lookupMimeType(file.path);

    if (mimeType == null || !_allowedMimeTypes.contains(mimeType)) {
      return FileValidationResult.failure(
        'Invalid file type. Allowed: PDF, JPG, PNG',
      );
    }

    // 3. Scan file header (prevent extension spoofing)
    final headerValid = await _validateFileHeader(file, extension);

    if (!headerValid) {
      return FileValidationResult.failure(
        'File appears to be corrupted or has wrong extension',
      );
    }

    // 4. Sanitize filename
    final sanitizedName = _sanitizeFilename(file.path.split('/').last);

    return FileValidationResult.success(sanitizedName);
  }

  /// Validate file header (magic numbers)
  Future<bool> _validateFileHeader(File file, String extension) async {
    final bytes = await file.readAsBytes();

    if (bytes.isEmpty) return false;

    switch (extension) {
      case 'pdf':
        // PDF: %PDF (0x25 0x50 0x44 0x46)
        return bytes.length >= 4 &&
               bytes[0] == 0x25 &&
               bytes[1] == 0x50 &&
               bytes[2] == 0x44 &&
               bytes[3] == 0x46;

      case 'jpg':
      case 'jpeg':
        // JPEG: 0xFF 0xD8
        return bytes.length >= 2 &&
               bytes[0] == 0xFF &&
               bytes[1] == 0xD8;

      case 'png':
        // PNG: 0x89 0x50 0x4E 0x47 0x0D 0x0A 0x1A 0x0A
        return bytes.length >= 8 &&
               bytes[0] == 0x89 &&
               bytes[1] == 0x50 &&
               bytes[2] == 0x4E &&
               bytes[3] == 0x47 &&
               bytes[4] == 0x0D &&
               bytes[5] == 0x0A &&
               bytes[6] == 0x1A &&
               bytes[7] == 0x0A;

      default:
        return false;
    }
  }

  /// Sanitize filename (prevent path traversal, injection)
  String _sanitizeFilename(String filename) {
    // Remove path traversal attempts
    String sanitized = filename.replaceAll('..', '');
    sanitized = sanitized.replaceAll('/', '');
    sanitized = sanitized.replaceAll('\\', '');

    // Remove special characters
    sanitized = sanitized.replaceAll(RegExp(r'[<>:"|?*]'), '');

    // Limit length
    if (sanitized.length > 100) {
      final ext = sanitized.split('.').last;
      sanitized = '${sanitized.substring(0, 95)}.$ext';
    }

    return sanitized;
  }
}

class FileValidationResult {
  final bool isValid;
  final String? error;
  final String? sanitizedFilename;

  const FileValidationResult._({
    required this.isValid,
    this.error,
    this.sanitizedFilename,
  });

  factory FileValidationResult.success(String sanitizedFilename) {
    return FileValidationResult._(
      isValid: true,
      sanitizedFilename: sanitizedFilename,
    );
  }

  factory FileValidationResult.failure(String error) {
    return FileValidationResult._(
      isValid: false,
      error: error,
    );
  }
}
```

---

### **Session Management**

**Requirements:**
- ✅ XCSRF token sent with all POST requests
- ✅ Session validated before final submission
- ✅ If session expired: Prompt re-login, restore flow

**Implementation:**

```dart
class SecureApiClient {
  final Dio _dio;
  final SecureStorage _secureStorage;

  SecureApiClient(this._dio, this._secureStorage) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add XCSRF token to all POST requests
        if (options.method == 'POST' || options.method == 'PUT') {
          final xcsrfToken = await _secureStorage.getXCSRFToken();

          if (xcsrfToken != null) {
            options.headers['X-CSRF-Token'] = xcsrfToken;
          }
        }

        return handler.next(options);
      },
      onError: (error, handler) async {
        // Handle session expiry (401)
        if (error.response?.statusCode == 401) {
          // Session expired
          await _handleSessionExpired();
          return handler.reject(error);
        }

        return handler.next(error);
      },
    ));
  }

  Future<void> _handleSessionExpired() async {
    // Clear local session data
    await _secureStorage.clearSession();

    // Notify app to show login
    // (This will be handled by RegistrationStateNotifier)
  }

  /// Validate session before final submission
  Future<bool> validateSession() async {
    try {
      final response = await _dio.get('/api/session/validate');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

// In RegistrationStateNotifier
Future<void> submitRegistration() async {
  // Validate session before submission
  final sessionValid = await _apiClient.validateSession();

  if (!sessionValid) {
    state = RegistrationStateSessionExpired(
      message: 'Your session expired. Please login again',
      currentRegistration: registration,
    );
    return;
  }

  // Proceed with submission
  try {
    final registrationId = await _repository.submitRegistration(
      registration: registration,
    );

    await _localDs.markRegistrationComplete();
    state = RegistrationStateSuccess(registrationId: registrationId);
  } on UnauthorizedException {
    // Session expired during submission
    state = RegistrationStateSessionExpired(
      message: 'Your session expired. Please login again',
      currentRegistration: registration,
    );
  }
}
```

---

### **Input Sanitization**

**Requirements:**
- ✅ Escape special characters in text fields
- ✅ Prevent SQL injection (API responsibility, but still sanitize)
- ✅ Limit input lengths strictly

**Implementation:**

```dart
class InputSanitizer {
  /// Sanitize text input (escape special characters)
  static String sanitizeText(String input) {
    String sanitized = input.trim();

    // Escape HTML special characters
    sanitized = sanitized
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');

    // Remove null bytes
    sanitized = sanitized.replaceAll('\x00', '');

    return sanitized;
  }

  /// Sanitize for SQL (prevent injection, though API should handle)
  static String sanitizeForSQL(String input) {
    String sanitized = input.trim();

    // Escape single quotes
    sanitized = sanitized.replaceAll("'", "''");

    // Remove SQL keywords (additional safety)
    final sqlKeywords = [
      'SELECT', 'INSERT', 'UPDATE', 'DELETE', 'DROP',
      'CREATE', 'ALTER', 'EXEC', 'EXECUTE', '--', '/*', '*/',
    ];

    for (final keyword in sqlKeywords) {
      sanitized = sanitized.replaceAll(
        RegExp(keyword, caseSensitive: false),
        '',
      );
    }

    return sanitized;
  }

  /// Validate and enforce length limits
  static String? enforceLength(
    String input, {
    int? minLength,
    int? maxLength,
  }) {
    if (minLength != null && input.length < minLength) {
      return 'Minimum length is $minLength characters';
    }

    if (maxLength != null && input.length > maxLength) {
      return 'Maximum length is $maxLength characters';
    }

    return null;
  }

  /// Sanitize email (additional validation)
  static String sanitizeEmail(String email) {
    String sanitized = email.trim().toLowerCase();

    // Remove spaces
    sanitized = sanitized.replaceAll(' ', '');

    // Basic format check
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!emailRegex.hasMatch(sanitized)) {
      throw ArgumentError('Invalid email format');
    }

    return sanitized;
  }

  /// Sanitize phone (remove non-digits, validate format)
  static String sanitizePhone(String phone) {
    // Remove all non-digit characters except +
    String sanitized = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Validate format
    if (sanitized.startsWith('+')) {
      // International format: +[country code][number]
      if (sanitized.length < 10 || sanitized.length > 15) {
        throw ArgumentError('Invalid phone format');
      }
    } else {
      // Local format: 10 digits
      if (sanitized.length != 10) {
        throw ArgumentError('Invalid phone format');
      }
    }

    return sanitized;
  }
}

// Usage in form fields
class PersonalDetailsForm extends StatelessWidget {
  final _emailController = TextEditingController();

  String? _validateAndSanitizeEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    try {
      final sanitized = InputSanitizer.sanitizeEmail(value);

      // Enforce length (max 100 characters)
      final lengthError = InputSanitizer.enforceLength(
        sanitized,
        maxLength: 100,
      );

      if (lengthError != null) return lengthError;

      // Update controller with sanitized value
      _emailController.text = sanitized;

      return null;
    } on ArgumentError catch (e) {
      return e.message;
    }
  }
}

// Strict length limits
class InputLengthLimits {
  static const int maxEmailLength = 100;
  static const int maxNameLength = 50;
  static const int maxPhoneLength = 15;
  static const int maxAddressLength = 200;
  static const int maxCouncilNumberLength = 50;
  static const int maxTextFieldLength = 500;
}
```

---

## 📊 Performance Monitoring

```dart
class PerformanceMonitor {
  final AnalyticsService _analytics;

  /// Track screen load time
  void trackScreenLoad(String screenName, int milliseconds) {
    _analytics.log('screen_load', {
      'screen': screenName,
      'duration_ms': milliseconds,
    });

    // Alert if exceeds target
    if (screenName == 'personal_details' && milliseconds > 2000) {
      _analytics.logWarning('slow_screen_load', {
        'screen': screenName,
        'duration_ms': milliseconds,
        'target_ms': 2000,
      });
    }
  }

  /// Track file upload performance
  void trackFileUpload({
    required String fileName,
    required int fileSizeBytes,
    required int compressionMs,
    required int uploadMs,
  }) {
    _analytics.log('file_upload', {
      'file_size_bytes': fileSizeBytes,
      'compression_ms': compressionMs,
      'upload_ms': uploadMs,
      'total_ms': compressionMs + uploadMs,
    });

    // Alert if compression too slow
    if (compressionMs > 2000) {
      _analytics.logWarning('slow_compression', {
        'duration_ms': compressionMs,
        'target_ms': 2000,
      });
    }
  }

  /// Track validation performance
  void trackValidation(String fieldName, int microseconds) {
    final milliseconds = microseconds / 1000;

    _analytics.log('field_validation', {
      'field': fieldName,
      'duration_ms': milliseconds,
    });

    // Alert if sync validation too slow (> 1ms)
    if (microseconds > 1000) {
      _analytics.logWarning('slow_validation', {
        'field': fieldName,
        'duration_us': microseconds,
        'target_us': 1000,
      });
    }
  }
}
```

---

## ✅ Implementation Checklist

### **Performance:**
- [ ] Screen load times meet targets (< 2s / < 500ms)
- [ ] Dropdown caching implemented
- [ ] Image compression in isolate
- [ ] Upload progress updates every 100ms
- [ ] Preview generation < 500ms
- [ ] Sync validation < 1ms
- [ ] Async validation debounced (500ms)
- [ ] All controllers disposed
- [ ] API calls cancelled on exit
- [ ] File previews cleared on success
- [ ] Selective widget rebuilds

### **Security:**
- [ ] Sensitive data never logged
- [ ] Documents in app private directory
- [ ] Payment info never stored
- [ ] File extension validated
- [ ] MIME type validated
- [ ] File header scanned
- [ ] Executable files rejected
- [ ] Filenames sanitized
- [ ] XCSRF token on POST requests
- [ ] Session validated before submission
- [ ] Text input sanitized
- [ ] Input lengths enforced

---

**Implementation Status:**
- ✅ Performance requirements documented
- ✅ Security requirements documented
- ⏳ Utility classes (pending creation)
- ⏳ Integration with screens (pending)
- ⏳ Performance monitoring (pending analytics setup)
