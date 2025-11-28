# Registration & Authentication Module Integration

## Overview
The Registration module builds on the Authentication module's session management and XCSRF token handling. This document details how registration integrates with authentication patterns and ensures consistency across the codebase.

---

## 🔐 Authentication Module Pattern (Foundation)

### **Session Management**

The authentication module establishes the following pattern for session management:

**Session Storage:**
```dart
// Session ID: HTTP-only cookies (managed by Dio's CookieManager)
// Location: app's document directory via path_provider
// File: .cookies/ directory (NOT in Hive)

// Session entity (stored in encrypted Hive):
class Session {
  final String xcsrfToken;        // XCSRF token for CSRF protection
  final DateTime expiresAt;       // Session expiry timestamp
  final String? ifModifiedSince;  // Caching header
}
```

**Cookie Jar Configuration** (`lib/core/network/api_client.dart`):
```dart
Future<void> _initializeCookieJar() async {
  final directory = await getApplicationDocumentsDirectory();
  final cookiePath = '${directory.path}/.cookies/';
  _cookieJar = PersistCookieJar(
    storage: FileStorage(cookiePath),
  );

  _dio.interceptors.add(CookieManager(_cookieJar));
}
```

**Key Principle:**
- ✅ Session ID: HTTP-only cookies (secure, auto-sent by Dio)
- ✅ XCSRF Token: Encrypted Hive storage
- ❌ Session ID is NEVER stored in Hive or local variables
- ❌ XCSRF Token is NEVER logged

---

### **XCSRF Token Handling**

**Extraction on Login** (`lib/features/auth/infrastructure/data_sources/remote/auth_api.dart`):
```dart
Future<LoginResponse> login(...) async {
  final response = await _apiClient.post(Endpoints.login, data: request.toJson());

  // Extract XCSRF token from response headers OR body
  final xcsrfToken = response.headers.value('x-csrftoken') ??
                     response.data?['xcsrf_token'] as String? ??
                     '';

  // Add XCSRF token to ALL future requests
  if (xcsrfToken.isNotEmpty) {
    _apiClient.addHeader('X-CSRFToken', xcsrfToken);
  }

  return loginResponse;
}
```

**Usage in Subsequent Requests:**
```dart
// XCSRF token automatically included in headers for ALL POST/PUT/PATCH/DELETE requests
// No manual intervention needed after login
```

**Cleanup on Logout:**
```dart
Future<bool> logout() async {
  await _apiClient.post(Endpoints.logout);

  // Clear cookies and XCSRF token
  await _apiClient.clearCookies();
  _apiClient.removeHeader('X-CSRFToken');

  return true;
}
```

---

## 🔗 Registration Module Integration

### **How Registration Builds on Authentication**

The registration module inherits and extends the authentication patterns:

#### **1. Session Dependency**

**Registration requires active session:**
```dart
// User flow:
// 1. Login (establishes session + XCSRF token)
// 2. Select role (POST request with XCSRF token)
// 3. Start registration (all POST requests use XCSRF token)
// 4. Submit registration (validates session before final submission)

// RegistrationStateNotifier validates session before submission:
Future<void> submitRegistration() async {
  // CRITICAL: Validate session before final submission
  final sessionValid = await _apiClient.validateSession();

  if (!sessionValid) {
    state = RegistrationStateSessionExpired(
      message: 'Your session expired. Please login again',
      currentRegistration: registration,
    );
    return;
  }

  // Proceed with submission (XCSRF token auto-included)
  final registrationId = await _repository.submitRegistration(
    registration: registration,
  );
}
```

#### **2. XCSRF Token Usage**

**All registration API calls include XCSRF token:**
```dart
// Example: Document upload
Future<String> uploadDocument(File file, DocumentType type) async {
  // XCSRF token automatically included in request headers
  // (added by ApiClient after login)
  final formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(file.path),
    'type': type.name,
  });

  final response = await _dio.post(
    '/api/registration/upload',
    data: formData,
  );
  // Headers automatically include:
  // X-CSRFToken: <token-from-login>

  return response.data['url'];
}
```

**Protected endpoints:**
- POST `/api/registration/submit`
- POST `/api/registration/upload`
- PUT `/api/registration/update/{step}`
- POST `/api/registration/verify`

All automatically include XCSRF token from authentication module.

#### **3. Session Expiry Handling**

**Registration handles 401 errors:**
```dart
// In RegistrationStateNotifier
try {
  await _repository.submitRegistration(registration: registration);
} on UnauthorizedException {
  // Session expired during registration
  state = RegistrationStateSessionExpired(
    message: 'Your session expired. Please login again',
    currentRegistration: registration,
  );
}

// UI flow on session expiry:
ref.listen<RegistrationState>(registrationProvider, (previous, next) {
  if (next case RegistrationStateSessionExpired(:final currentRegistration)) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Session Expired'),
        content: const Text('Your session expired. Please login again'),
        actions: [
          ElevatedButton(
            onPressed: () async {
              // Navigate to login
              final loggedIn = await Navigator.pushNamed(context, AppRouter.login);

              if (loggedIn == true && context.mounted) {
                // IMPORTANT: After re-login, XCSRF token is refreshed
                // Resume registration flow
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

**Session restoration flow:**
1. User logs in again → New XCSRF token added to ApiClient headers
2. Registration data preserved in Hive
3. User can retry submission with fresh session

---

## 📋 Integration Checklist

### **Authentication Module Responsibilities:**

- [x] Store session ID in HTTP-only cookies via Dio
- [x] Store XCSRF token in encrypted Hive
- [x] Add XCSRF token to request headers on login
- [x] Remove XCSRF token on logout
- [x] Clear cookies on logout
- [x] Provide session validation endpoint
- [x] Handle 401 errors with UnauthorizedException

### **Registration Module Responsibilities:**

- [x] Depend on active session from authentication
- [x] Use XCSRF token automatically (via ApiClient)
- [x] Handle session expiry (401 errors)
- [x] Preserve registration data on session expiry
- [x] Restore registration flow after re-login
- [x] Never manually handle XCSRF token (trust ApiClient)
- [x] Never store session ID locally

---

## 🔒 Security Alignment

### **What Registration Module MUST Follow:**

| Aspect | Auth Pattern | Registration Compliance |
|--------|-------------|------------------------|
| **Session ID Storage** | HTTP-only cookies via Dio | ✅ Never stored in Hive or variables |
| **XCSRF Token Storage** | Encrypted Hive | ✅ Uses same SecureHiveStorage |
| **XCSRF in Requests** | Auto-added by ApiClient | ✅ All POST requests include it |
| **Sensitive Data Logging** | NEVER logged | ✅ Council numbers, docs never logged |
| **Password Handling** | NEVER stored | ✅ N/A (registration post-login) |
| **Session Validation** | Before critical operations | ✅ Before final submission |
| **401 Handling** | Prompt re-login | ✅ RegistrationStateSessionExpired |
| **Data Preservation** | Restore on re-login | ✅ Registration data in Hive |

---

## 🔄 Complete Flow Diagram

```
┌────────────────────────────────────────────────────────────────┐
│                   AUTHENTICATION MODULE                         │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  [User Login]                                                   │
│      │                                                          │
│      ├─> POST /api/accounts/login/                             │
│      │   Request: { email, password, deviceId }                │
│      │   Response: { user, xcsrf_token }                       │
│      │                                                          │
│      ├─> Extract session ID from cookies (auto-handled by Dio) │
│      │   Cookie: sessionid=<session-id>; HttpOnly; Secure      │
│      │                                                          │
│      ├─> Extract XCSRF token from response                     │
│      │   Header: x-csrftoken: <token>                          │
│      │   OR Body: { xcsrf_token: <token> }                     │
│      │                                                          │
│      ├─> Store in encrypted Hive:                              │
│      │   Session(xcsrfToken, expiresAt, ifModifiedSince)       │
│      │                                                          │
│      └─> Add to ApiClient headers:                             │
│          ApiClient.addHeader('X-CSRFToken', xcsrfToken)         │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
                              │
                              │ Session Active
                              ↓
┌────────────────────────────────────────────────────────────────┐
│                   REGISTRATION MODULE                           │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  [Step 1: Personal Details]                                    │
│      │                                                          │
│      ├─> Fill form data                                        │
│      ├─> Save to Hive (encrypted)                              │
│      └─> Click "Next"                                          │
│                                                                 │
│  [Step 2: Professional Details]                                │
│      │                                                          │
│      ├─> Load dropdowns: GET /api/councils                     │
│      │   Headers: { X-CSRFToken: <token> } ← Auto-included     │
│      │                                                          │
│      ├─> Fill form data                                        │
│      └─> Save to Hive                                          │
│                                                                 │
│  [Step 3: Address Details]                                     │
│      │                                                          │
│      ├─> Cascade dropdowns: GET /api/states?country=India      │
│      │   Headers: { X-CSRFToken: <token> }                     │
│      │                                                          │
│      └─> Save to Hive                                          │
│                                                                 │
│  [Step 4: Document Upload]                                     │
│      │                                                          │
│      ├─> Upload file: POST /api/registration/upload            │
│      │   Headers: { X-CSRFToken: <token> } ← Auto-included     │
│      │   Multipart: { file, type }                             │
│      │                                                          │
│      ├─> IF 401 Unauthorized:                                  │
│      │   └─> RegistrationStateSessionExpired                   │
│      │       └─> Navigate to login                             │
│      │           └─> After re-login: Retry upload              │
│      │                                                          │
│      └─> Save document URL to Hive                             │
│                                                                 │
│  [Step 5: Payment]                                             │
│      │                                                          │
│      ├─> Validate session: GET /api/session/validate           │
│      │   Headers: { X-CSRFToken: <token> }                     │
│      │                                                          │
│      ├─> IF session expired:                                   │
│      │   └─> RegistrationStateSessionExpired                   │
│      │       └─> Navigate to login → Retry submission          │
│      │                                                          │
│      ├─> Process payment with gateway                          │
│      │                                                          │
│      └─> Submit registration: POST /api/registration/submit    │
│          Headers: { X-CSRFToken: <token> } ← Auto-included     │
│          Body: { all registration data }                       │
│                                                                 │
│  [Success]                                                      │
│      │                                                          │
│      ├─> Clear registration data from Hive                     │
│      ├─> Navigate to dashboard                                 │
│      └─> Session remains active (no logout)                    │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Implementation Guidelines

### **For New Registration Endpoints:**

When adding new API calls in the registration module:

```dart
// ✅ CORRECT - Trust ApiClient to handle XCSRF
class RegistrationApi {
  final ApiClient _apiClient;

  Future<void> submitStep(Map<String, dynamic> data) async {
    // XCSRF token automatically included by ApiClient
    final response = await _apiClient.post(
      '/api/registration/step',
      data: data,
    );

    return response.data;
  }
}

// ❌ INCORRECT - Manual XCSRF handling
class RegistrationApi {
  Future<void> submitStep(Map<String, dynamic> data) async {
    // DON'T DO THIS - token already in headers
    final xcsrfToken = await _getXcsrfToken(); // ❌ Wrong

    final response = await _dio.post(
      '/api/registration/step',
      data: data,
      options: Options(
        headers: {'X-CSRFToken': xcsrfToken}, // ❌ Redundant
      ),
    );
  }
}
```

### **For Session Expiry Handling:**

```dart
// ✅ CORRECT - Handle 401 with state management
Future<void> callApi() async {
  try {
    await _repository.someOperation();
  } on UnauthorizedException {
    state = RegistrationStateSessionExpired(
      message: 'Your session expired. Please login again',
      currentRegistration: registration,
    );
  }
}

// ❌ INCORRECT - Trying to refresh XCSRF manually
Future<void> callApi() async {
  try {
    await _repository.someOperation();
  } on UnauthorizedException {
    // DON'T DO THIS - user must re-login
    final newToken = await _refreshXcsrfToken(); // ❌ No such endpoint
    await _repository.someOperation(); // ❌ Won't work
  }
}
```

---

## 📚 Documentation Updates

### **Files Aligned with Auth Pattern:**

1. **REGISTRATION_PERFORMANCE_SECURITY.md**
   - ✅ Section: "Session Management"
   - ✅ Correctly states: "XCSRF token sent with all POST requests"
   - ✅ Correctly states: "Session validated before final submission"
   - ✅ Correctly states: "Session storage via Dio cookie manager with path_provider"

2. **REGISTRATION_ERROR_HANDLING.md**
   - ✅ Section: "Invalid Session (401)"
   - ✅ Correctly handles: "Clear session data, navigate to login, restore flow"

3. **REGISTRATION_EDGE_CASES.md**
   - ✅ No contradictions with auth pattern
   - ✅ Session expiry handled correctly

---

## ✅ Compliance Summary

### **Registration Module is FULLY COMPLIANT with Auth Module:**

✅ **Session ID**: Never stored locally, managed by Dio cookies
✅ **XCSRF Token**: Stored in encrypted Hive, auto-added to requests
✅ **API Calls**: All use shared ApiClient with automatic header injection
✅ **Session Validation**: Done before critical operations
✅ **401 Handling**: Prompts re-login and preserves data
✅ **Security**: No sensitive data logged, proper encryption
✅ **Documentation**: All docs reference correct patterns

### **No Changes Needed:**

The registration module already follows the authentication module's patterns correctly. All documentation is accurate and aligned.

---

## 🎯 Future Considerations

### **If Backend Changes Session Management:**

If the backend changes how sessions or XCSRF tokens work, update BOTH modules:

1. **Update Auth Module** (`lib/features/auth/`):
   - `auth_api.dart` - Extraction logic
   - `session.dart` - Entity definition
   - `auth_local_ds.dart` - Storage logic

2. **Update ApiClient** (`lib/core/network/api_client.dart`):
   - Header injection logic
   - Cookie management

3. **Registration Module Auto-Adapts**:
   - No changes needed (uses ApiClient)
   - Unless new registration-specific requirements

### **Testing Integration:**

```dart
// Test that registration uses auth session
test('Registration includes XCSRF token from auth', () async {
  // 1. Login (establishes session)
  await authApi.login(email: 'test@test.com', password: 'password');

  // 2. Verify XCSRF token in ApiClient headers
  expect(apiClient.headers['X-CSRFToken'], isNotEmpty);

  // 3. Call registration endpoint
  await registrationApi.submitStep(data);

  // 4. Verify request included XCSRF token
  verify(() => dio.post(
    any(),
    options: argThat(
      hasHeader('X-CSRFToken'),
      named: 'options',
    ),
  )).called(1);
});
```

---

**Conclusion:**

The Registration module correctly builds on the Authentication module's session and XCSRF token management. No code changes are needed. This document serves as a reference for maintaining consistency between the two modules.
