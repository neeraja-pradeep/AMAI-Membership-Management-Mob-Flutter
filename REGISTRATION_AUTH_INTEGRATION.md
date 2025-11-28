# Registration & Authentication Module Integration

## Overview
The Registration module builds on the Authentication module's session management and CSRF token handling. This document details how registration integrates with authentication patterns and ensures consistency across the codebase.

---

## 🔐 Authentication Module Pattern (Foundation)

### **CRITICAL PATTERN: Cookie-Based Session & CSRF**

**Session & CSRF Storage (BOTH in cookies):**
```dart
// Session ID: HTTP-only cookies (managed by Dio's CookieManager)
// CSRF Token: HTTP-only cookies (managed by Dio's CookieManager)
// Location: app's document directory via path_provider
// File: .cookies/ directory
//
// CRITICAL: NO Hive storage for session or CSRF token
// CRITICAL: NO manual token extraction from response headers/body
// CRITICAL: Tokens come from cookies ONLY
```

**Cookie Jar Configuration** (`lib/core/network/api_client.dart`):
```dart
Future<void> _initializeCookieJar() async {
  final directory = await getApplicationDocumentsDirectory();
  final cookiePath = '${directory.path}/.cookies/';
  _cookieJar = PersistCookieJar(
    storage: FileStorage(cookiePath),
  );

  // CRITICAL: CookieManager automatically handles session cookies
  _dio.interceptors.add(CookieManager(_cookieJar));
}
```

**Key Principle:**
- ✅ Session ID: HTTP-only cookies (secure, auto-sent by Dio)
- ✅ CSRF Token: HTTP-only cookies (extracted automatically)
- ❌ Session ID is NEVER stored in Hive or local variables
- ❌ CSRF Token is NEVER stored in Hive
- ❌ CSRF Token is NEVER manually extracted from response headers/body
- ❌ CSRF Token is NEVER logged

---

### **CSRF Token Handling (Cookie-Based)**

**Auto-Extraction via Interceptor** (`lib/core/network/api_client.dart`):
```dart
// CSRF interceptor - auto-extracts from cookies
void _setupInterceptors() {
  _dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // CRITICAL: Extract CSRF from cookies, NOT from Hive or response
        final csrf = await _getCsrfToken();
        if (csrf != null) {
          options.headers['X-CSRFToken'] = csrf;
        }
        return handler.next(options);
      },
    ),
  );
}

// CRITICAL: Token comes from cookies ONLY
Future<String?> _getCsrfToken() async {
  final cookies = await _cookieJar.loadForRequest(
    Uri.parse(_dio.options.baseUrl),
  );

  final csrfCookie = cookies.firstWhere(
    (c) => c.name.toLowerCase() == 'csrftoken',
    orElse: () => Cookie('', ''),
  );

  return csrfCookie.value.isEmpty ? null : csrfCookie.value;
}
```

**Usage in Subsequent Requests:**
```dart
// CSRF token automatically included in headers for ALL POST/PUT/PATCH/DELETE requests
// Extracted from cookies on EVERY request via interceptor
// No manual intervention needed - fully automatic
```

**Cleanup on Logout:**
```dart
Future<bool> logout() async {
  await _apiClient.post(Endpoints.logout);

  // CRITICAL: Clear ALL cookies (session + CSRF)
  await _apiClient.clearCookies();
  // No manual token removal needed - cookies handle everything

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

#### **2. CSRF Token Usage**

**All registration API calls include CSRF token:**
```dart
// Example: Document upload
Future<String> uploadDocument(File file, DocumentType type) async {
  // CRITICAL: CSRF token automatically extracted from cookies and included
  // (via ApiClient interceptor - NO manual handling)
  final formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(file.path),
    'type': type.name,
  });

  final response = await _dio.post(
    '/api/registration/upload',
    data: formData,
  );
  // Headers automatically include:
  // X-CSRFToken: <token-from-cookies>

  return response.data['url'];
}
```

**Protected endpoints:**
- POST `/api/registration/submit`
- POST `/api/registration/upload`
- PUT `/api/registration/update/{step}`
- POST `/api/registration/verify`

All automatically include CSRF token extracted from cookies by ApiClient interceptor.

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
- [x] Store CSRF token in HTTP-only cookies via Dio
- [x] Auto-extract CSRF token from cookies on every request
- [x] Auto-add CSRF token to request headers via interceptor
- [x] Clear cookies on logout (clears both session + CSRF)
- [x] Provide session validation endpoint
- [x] Handle 401 errors with UnauthorizedException

### **Registration Module Responsibilities:**

- [x] Depend on active session from authentication
- [x] Use CSRF token automatically (via ApiClient interceptor)
- [x] Handle session expiry (401 errors)
- [x] Preserve registration data on session expiry
- [x] Restore registration flow after re-login
- [x] **NEVER manually handle CSRF token** (trust ApiClient interceptor)
- [x] **NEVER store CSRF token in Hive** (comes from cookies only)
- [x] **NEVER store session ID locally** (comes from cookies only)

---

## 🔒 Security Alignment

### **What Registration Module MUST Follow:**

| Aspect | Auth Pattern | Registration Compliance |
|--------|-------------|------------------------|
| **Session ID Storage** | HTTP-only cookies via Dio | ✅ Never stored in Hive or variables |
| **CSRF Token Storage** | HTTP-only cookies via Dio | ✅ Never stored in Hive or variables |
| **CSRF Extraction** | Auto from cookies via interceptor | ✅ Never manual extraction |
| **CSRF in Requests** | Auto-added by ApiClient interceptor | ✅ All POST requests include it |
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
│      │   Response: { user, ... }                               │
│      │                                                          │
│      ├─> Backend sets cookies (auto-handled by Dio):          │
│      │   Cookie: sessionid=<session-id>; HttpOnly; Secure      │
│      │   Cookie: csrftoken=<csrf-token>; HttpOnly; Secure      │
│      │                                                          │
│      ├─> Cookies stored in app directory:                      │
│      │   Path: /app-documents/.cookies/                        │
│      │   Managed by: PersistCookieJar + path_provider          │
│      │                                                          │
│      └─> CRITICAL: NO manual token extraction or storage       │
│          - CSRF token comes from cookies ONLY                  │
│          - NO Hive storage for session or CSRF                 │
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
│      │   Headers: { X-CSRFToken: <from-cookies> } ← Auto      │
│      │   (CSRF extracted from cookies by interceptor)         │
│      │                                                          │
│      ├─> Fill form data                                        │
│      └─> Save to Hive                                          │
│                                                                 │
│  [Step 3: Address Details]                                     │
│      │                                                          │
│      ├─> Cascade dropdowns: GET /api/states?country=India      │
│      │   Headers: { X-CSRFToken: <from-cookies> }             │
│      │   (CSRF extracted from cookies by interceptor)         │
│      │                                                          │
│      └─> Save to Hive                                          │
│                                                                 │
│  [Step 4: Document Upload]                                     │
│      │                                                          │
│      ├─> Upload file: POST /api/registration/upload            │
│      │   Headers: { X-CSRFToken: <from-cookies> } ← Auto      │
│      │   (CSRF extracted from cookies by interceptor)         │
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
│      │   Headers: { X-CSRFToken: <from-cookies> }             │
│      │   (CSRF extracted from cookies by interceptor)         │
│      │                                                          │
│      ├─> IF session expired:                                   │
│      │   └─> RegistrationStateSessionExpired                   │
│      │       └─> Navigate to login → Retry submission          │
│      │                                                          │
│      ├─> Process payment with gateway                          │
│      │                                                          │
│      └─> Submit registration: POST /api/registration/submit    │
│          Headers: { X-CSRFToken: <from-cookies> } ← Auto      │
│          (CSRF extracted from cookies by interceptor)         │
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
✅ **CSRF Token**: Never stored in Hive, extracted from cookies by interceptor
✅ **API Calls**: All use shared ApiClient with automatic CSRF header injection
✅ **CSRF Handling**: Fully automatic via cookie-based interceptor pattern
✅ **Session Validation**: Done before critical operations
✅ **401 Handling**: Prompts re-login and preserves data
✅ **Security**: No sensitive data logged, no manual token handling
✅ **Documentation**: All docs reference correct cookie-based patterns

### **Critical Pattern Enforced:**

The registration module follows the **cookie-based session and CSRF pattern**:
- **NO** manual CSRF token extraction from response headers/body
- **NO** CSRF token storage in Hive
- **NO** manual `addHeader()` calls for CSRF token
- **YES** automatic CSRF extraction from cookies via interceptor
- **YES** automatic CSRF inclusion in all requests via interceptor

---

## 🎯 Future Considerations

### **If Backend Changes Session Management:**

If the backend changes how sessions or CSRF tokens work, update ApiClient ONLY:

1. **Update ApiClient** (`lib/core/network/api_client.dart`):
   - Update `_getCsrfToken()` if cookie name changes
   - Update interceptor if header name changes
   - Update cookie jar configuration if storage changes

2. **Registration Module Auto-Adapts**:
   - **NO** changes needed in registration code
   - **NO** changes needed in repository or API layers
   - All registration API calls use ApiClient interceptor
   - Fully automatic adaptation to ApiClient changes

### **Testing Integration:**

```dart
// Test that registration uses cookie-based CSRF
test('Registration includes CSRF token from cookies', () async {
  // 1. Login (backend sets session + CSRF cookies)
  await authApi.login(email: 'test@test.com', password: 'password');

  // 2. Verify cookies are stored
  final cookies = await apiClient.getCookies(Uri.parse(baseUrl));
  final csrfCookie = cookies.firstWhere((c) => c.name == 'csrftoken');
  expect(csrfCookie.value, isNotEmpty);

  // 3. Call registration endpoint
  await registrationApi.submitStep(data);

  // 4. Verify request included CSRF token from cookies
  // (automatically added by interceptor)
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

The Registration module correctly follows the **cookie-based session and CSRF pattern** established by the ApiClient. All session and CSRF handling is automatic via Dio's cookie manager and ApiClient's CSRF interceptor. No manual token handling is required anywhere in the registration code.
