# Authentication Module Refactoring - freezed to json_serializable

## 🎯 Refactoring Overview

This document outlines the complete refactoring from `freezed` to `json_serializable` with enhanced error handling and cookie-based session management.

---

## ✅ Changes Completed

### 1. Models Refactored (2/6)

#### ✅ LoginRequest
- **Before:** Freezed with `@freezed` annotation
- **After:** json_serializable with manual `copyWith`, `==`, `hashCode`
- **File:** `login_request.dart`
- **Status:** COMPLETE

#### ✅ ErrorResponse
- **Before:** Freezed with single error message
- **After:** json_serializable with comprehensive error parsing
- **Features Added:**
  - Multiple error message fields (message, errorMessage, detail)
  - Field-specific error extraction
  - Better fallback logic
  - `getFieldError(fieldName)` method
- **File:** `error_response.dart`
- **Status:** COMPLETE

---

## 🔄 Models To Be Refactored (4/6)

### 2. LoginResponse
**File:** `login_response.dart`

**Current (Freezed):**
```dart
@freezed
class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required bool success,
    @JsonKey(name: 'session_id') required String sessionId,
    @JsonKey(name: 'xcsrf_token') required String xcsrfToken,
    required UserModel user,
    @JsonKey(name: 'expires_at') required String expiresAt,
    @JsonKey(name: 'if_modified_since') String? ifModifiedSince,
  }) = _LoginResponse;
}
```

**Target (json_serializable):**
```dart
@JsonSerializable()
class LoginResponse {
  final bool success;
  @JsonKey(name: 'session_id')
  final String? sessionId; // Made optional - will use cookie
  @JsonKey(name: 'xcsrf_token')
  final String xcsrfToken;
  final UserModel user;
  @JsonKey(name: 'expires_at')
  final String expiresAt;
  @JsonKey(name: 'if_modified_since')
  final String? ifModifiedSince;

  // Add constructor, fromJson, toJson, copyWith, ==, hashCode
}
```

### 3. UserModel
**File:** `user_model.dart`

**Change:** Remove `freezed`, add manual methods

### 4. SessionModel
**File:** `session_model.dart`

**CRITICAL CHANGE:** Remove session_id storage
```dart
@JsonSerializable()
class SessionModel {
  // REMOVE: sessionId field
  @JsonKey(name: 'xcsrf_token')
  final String xcsrfToken;
  @JsonKey(name: 'expires_at')
  final String expiresAt;
  @JsonKey(name: 'if_modified_since')
  final String? ifModifiedSince;
}
```

### 5. RegistrationRequest
**File:** `registration_request.dart`

**Change:** Simple freezed → json_serializable conversion

### 6. AuthState
**File:** `auth_state.dart`

**Current:** Freezed union type
**Target:** Regular classes with sealed class pattern

```dart
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final User user;
  final Session session;
  final bool isStale;
  final bool isOffline;

  const AuthAuthenticated({
    required this.user,
    required this.session,
    this.isStale = false,
    this.isOffline = false,
  });
}

// ... other states
```

---

## 🚨 Comprehensive Error Handling

### Error Class Hierarchy

Create new file: `lib/core/error/auth_exception.dart`

```dart
/// Base authentication exception
abstract class AuthException implements Exception {
  final String message;
  final String? code;
  final Map<String, String>? fieldErrors;

  const AuthException(this.message, {this.code, this.fieldErrors});

  @override
  String toString() => message;
}

/// Network exceptions
class NoInternetException extends AuthException {
  const NoInternetException()
    : super('No internet connection', code: 'NO_INTERNET');
}

class TimeoutException extends AuthException {
  const TimeoutException()
    : super('Request timed out', code: 'TIMEOUT');
}

class DnsException extends AuthException {
  const DnsException()
    : super('Cannot reach server', code: 'DNS_FAILURE');
}

/// HTTP exceptions
class BadRequestException extends AuthException {
  const BadRequestException(String message, {Map<String, String>? fieldErrors})
    : super(message, code: '400', fieldErrors: fieldErrors);
}

class UnauthorizedException extends AuthException {
  const UnauthorizedException()
    : super('Invalid credentials', code: '401');
}

class ForbiddenException extends AuthException {
  const ForbiddenException()
    : super('Session expired, please login again', code: '403');
}

class UnprocessableEntityException extends AuthException {
  const UnprocessableEntityException(
    String message,
    {Map<String, String>? fieldErrors}
  ) : super(message, code: '422', fieldErrors: fieldErrors);
}

class TooManyRequestsException extends AuthException {
  final int retryAfter; // seconds

  const TooManyRequestsException(this.retryAfter)
    : super(
        'Too many attempts. Try again in $retryAfter seconds',
        code: '429',
      );
}

class ServerException extends AuthException {
  const ServerException()
    : super('Something went wrong, please try again', code: '500');
}

class UnknownHttpException extends AuthException {
  final int statusCode;

  const UnknownHttpException(this.statusCode)
    : super(
        'An unexpected error occurred',
        code: statusCode.toString(),
      );
}

/// Parsing exceptions
class JsonParsingException extends AuthException {
  const JsonParsingException()
    : super('Invalid response format', code: 'PARSING_ERROR');
}

class MissingFieldException extends AuthException {
  final String fieldName;

  const MissingFieldException(this.fieldName)
    : super(
        'Required field missing: $fieldName',
        code: 'MISSING_FIELD',
      );
}
```

---

## 🍪 Session Storage with Cookies

### Update AuthApi to Extract Session from Cookies

**File:** `auth_api.dart`

```dart
Future<LoginResponse> login({
  required String email,
  required String password,
  required bool rememberMe,
}) async {
  try {
    final deviceId = _uuid.v4();

    final request = LoginRequest(
      email: email,
      password: password,
      rememberMe: rememberMe,
      deviceId: deviceId,
    );

    final response = await _apiClient.post<Map<String, dynamic>>(
      Endpoints.login,
      data: request.toJson(),
    );

    // Session ID automatically stored in cookies by Dio
    // No need to extract and store manually

    // Extract XCSRF token from response headers
    final xcsrfToken = response.headers.value('x-csrftoken') ??
        response.data?['xcsrf_token'] as String? ??
        '';

    // Extract If-Modified-Since header
    final ifModifiedSince = response.headers.value('last-modified');

    // Build login response WITHOUT session_id
    final loginResponse = LoginResponse.fromJson({
      ...response.data!,
      'xcsrf_token': xcsrfToken,
      'if_modified_since': ifModifiedSince,
    });

    // Add XCSRF token to future requests
    if (xcsrfToken.isNotEmpty) {
      _apiClient.addHeader('X-CSRFToken', xcsrfToken);
    }

    return loginResponse;
  } on DioException catch (e) {
    throw _handleDioException(e);
  }
}

/// Handle Dio exceptions and convert to AuthExceptions
AuthException _handleDioException(DioException e) {
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return const TimeoutException();
  }

  if (e.type == DioExceptionType.connectionError) {
    return const NoInternetException();
  }

  if (e.type == DioExceptionType.badResponse) {
    final statusCode = e.response?.statusCode;

    switch (statusCode) {
      case 400:
        final errorResponse = _parseErrorResponse(e.response?.data);
        return BadRequestException(
          errorResponse.userMessage,
          fieldErrors: _extractFieldErrors(errorResponse),
        );

      case 401:
        return const UnauthorizedException();

      case 403:
        return const ForbiddenException();

      case 422:
        final errorResponse = _parseErrorResponse(e.response?.data);
        return UnprocessableEntityException(
          errorResponse.userMessage,
          fieldErrors: _extractFieldErrors(errorResponse),
        );

      case 429:
        final retryAfter = e.response?.headers.value('retry-after');
        final seconds = int.tryParse(retryAfter ?? '60') ?? 60;
        return TooManyRequestsException(seconds);

      case 500:
      case 502:
      case 503:
        return const ServerException();

      default:
        return UnknownHttpException(statusCode ?? 0);
    }
  }

  return const ServerException();
}

ErrorResponse _parseErrorResponse(dynamic data) {
  try {
    if (data is Map<String, dynamic>) {
      return ErrorResponse.fromJson(data);
    }
    return const ErrorResponse();
  } catch (e) {
    return const ErrorResponse();
  }
}

Map<String, String>? _extractFieldErrors(ErrorResponse errorResponse) {
  if (errorResponse.fieldErrors == null) return null;

  final Map<String, String> result = {};
  errorResponse.fieldErrors!.forEach((key, value) {
    if (value.isNotEmpty) {
      result[key] = value.first;
    }
  });

  return result.isNotEmpty ? result : null;
}
```

---

## 📦 Update AuthLocalDs

**File:** `auth_local_ds.dart`

**Remove session_id storage:**

```dart
class AuthLocalDs {
  /// Save user to Hive
  Future<void> saveUser(UserModel user) async {
    final box = await Hive.openBox(HiveBoxes.authBox);
    await box.put('user', user.toJson());
  }

  /// Get user from Hive
  Future<UserModel?> getUser() async {
    final box = await Hive.openBox(HiveBoxes.authBox);
    final userData = box.get('user') as Map<dynamic, dynamic>?;

    if (userData == null) return null;

    return UserModel.fromJson(
      Map<String, dynamic>.from(userData),
    );
  }

  /// Save session to Hive (NO session_id - stored in cookies)
  Future<void> saveSession(SessionModel session) async {
    final box = await Hive.openBox(HiveBoxes.authBox);
    await box.put('session', session.toJson());
  }

  /// Get session from Hive
  Future<SessionModel?> getSession() async {
    final box = await Hive.openBox(HiveBoxes.authBox);
    final sessionData = box.get('session') as Map<dynamic, dynamic>?;

    if (sessionData == null) return null;

    return SessionModel.fromJson(
      Map<String, dynamic>.from(sessionData),
    );
  }

  /// Save XCSRF token
  Future<void> saveXcsrfToken(String token) async {
    final box = await Hive.openBox(HiveBoxes.authBox);
    await box.put('xcsrf_token', token);
  }

  /// Get XCSRF token
  Future<String?> getXcsrfToken() async {
    final box = await Hive.openBox(HiveBoxes.authBox);
    return box.get('xcsrf_token') as String?;
  }

  /// Check if authenticated (check cookies + session expiry)
  Future<bool> isAuthenticated() async {
    // Session expiry check
    final session = await getSession();
    if (session == null) return false;

    final expiresAt = DateTime.parse(session.expiresAt);
    if (DateTime.now().isAfter(expiresAt)) {
      return false;
    }

    // Cookie existence is checked by Dio automatically
    return true;
  }

  /// Clear all auth data
  Future<void> clearAll() async {
    final box = await Hive.openBox(HiveBoxes.authBox);
    await box.clear();
  }

  /// Delete user only
  Future<void> deleteUser() async {
    final box = await Hive.openBox(HiveBoxes.authBox);
    await box.delete('user');
  }

  /// Delete session only
  Future<void> deleteSession() async {
    final box = await Hive.openBox(HiveBoxes.authBox);
    await box.delete('session');
    await box.delete('xcsrf_token');
  }
}
```

---

## 🔒 Updated Cache Invalidation Rules

### 1. User Logout → Delete ALL auth_* keys + Cookies

```dart
@override
Future<void> logout() async {
  try {
    // Call logout API
    await _authApi.logout();
  } catch (e) {
    // Continue with local cleanup even if API fails
  }

  // Delete ALL Hive auth keys
  await _authLocalDs.clearAll();

  // Delete ALL cookies (session_id included)
  await _apiClient.clearCookies();

  // Remove XCSRF token header
  _apiClient.removeHeader('X-CSRFToken');

  // Clear cache
  await _cacheManager.clearAll();

  // Clear in-memory cache
  _cachedUser = null;
  _cachedSession = null;
}
```

### 2. Session Expired → Delete session tokens only, keep user profile

```dart
Future<void> handleSessionExpired() async {
  // Delete session from Hive
  await _authLocalDs.deleteSession();

  // Clear cookies (session_id)
  await _apiClient.clearCookies();

  // Remove XCSRF token
  _apiClient.removeHeader('X-CSRFToken');

  // Keep user profile in Hive (for display purposes)
  // Do NOT call deleteUser()

  // Clear in-memory session only
  _cachedSession = null;
}
```

### 3. Failed Login → Do NOT clear old session data

```dart
@override
Future<({User user, Session session})> login({
  required String email,
  required String password,
  required bool rememberMe,
}) async {
  try {
    final loginResponse = await _authApi.login(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );

    // ... success handling

  } catch (e) {
    // Do NOT clear old session on failed login
    // Just rethrow the exception
    rethrow;
  }
}
```

### 4. Successful Login → Overwrite all keys

```dart
// After successful login
await _authLocalDs.clearAll(); // Clear old data
await _cacheManager.clearAll(); // Clear old cache
await _authLocalDs.saveUser(user); // Save new user
await _authLocalDs.saveSession(session); // Save new session
// Session cookie automatically saved by Dio
```

---

## 📄 Files That Need Updates

### Critical Files:
1. ✅ `login_request.dart` - DONE
2. ✅ `error_response.dart` - DONE
3. ⬜ `login_response.dart` - Remove session_id field
4. ⬜ `user_model.dart` - Convert to json_serializable
5. ⬜ `session_model.dart` - Remove session_id, only keep XCSRF + expiry
6. ⬜ `registration_request.dart` - Convert to json_serializable
7. ⬜ `auth_state.dart` - Convert to sealed classes
8. ⬜ `auth_api.dart` - Add comprehensive error handling
9. ⬜ `auth_local_ds.dart` - Remove session_id storage
10. ⬜ `auth_repository_impl.dart` - Update for new session handling
11. ⬜ `login_screen.dart` - Add field-specific error display
12. ⬜ Create `lib/core/error/auth_exception.dart` - New file

### Dependencies to Remove:
```yaml
# Remove from pubspec.yaml
# freezed: ^2.5.7
# freezed_annotation: ^2.4.4
```

### Dependencies to Keep:
```yaml
json_annotation: ^4.9.0
json_serializable: ^6.8.0
```

---

## ⚙️ Build Commands

After all changes:

```bash
# Clean old generated files
find lib -name "*.freezed.dart" -delete
find lib -name "*.g.dart" -delete

# Install dependencies
flutter pub get

# Generate json_serializable files
flutter pub run build_runner build --delete-conflicting-outputs

# Verify
flutter analyze
```

---

## 🎯 Next Steps

1. ✅ Complete remaining model conversions (4/6 remaining)
2. ✅ Create auth_exception.dart with all error types
3. ✅ Update auth_api.dart with error handling
4. ✅ Update auth_local_ds.dart to remove session_id
5. ✅ Update auth_repository_impl.dart
6. ✅ Update UI components for field-specific errors
7. ✅ Test all error scenarios
8. ✅ Generate code and commit

---

**Status:** 2/6 models refactored, error handling designed
**Next:** Complete model conversions + auth_exception.dart
