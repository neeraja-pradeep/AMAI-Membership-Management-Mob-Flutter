# AUTHENTICATION & REGISTRATION MODULE SPECIFICATIONS

## Table of Contents
1. [Authentication Module (Login)](#authentication-module-specification)
2. [Practitioner Registration Module](#practitioner-registration-module-specification)

---

# AUTHENTICATION MODULE SPECIFICATION

## MODULE SCOPE FOR LOGIN

Login screen, registration role selection popup, session management, token handling, authentication state persistence, network-aware retry logic.

---

## FLUTTER & DEPENDENCY SPECIFICATIONS

**Flutter SDK:** [SPECIFY_VERSION]  
**Minimum SDK:** [SPECIFY_VERSION]  
**Target Platforms:** iOS, Android, Web

### Required Dependencies:
- `dio`: [VERSION] (HTTP client)
- `hive`: [VERSION] (local storage)
- `hive_flutter`: [VERSION]
- `riverpod/flutter_riverpod`: [VERSION] (state management)
- `cookie_jar`: [VERSION] (cookie persistence)
- `dio_cookie_manager`: [VERSION]

### Package Constraints:
- All dependencies must support null safety
- No deprecated APIs

---

## DATA MODELS & SERIALIZATION

### Required Models

#### Login Request Model:
- Email/username field (string, max 255 chars)
- Password field (string, no length constraint exposed)
- Remember me flag (boolean)
- Device identifier (string, generated once, persisted)

#### Login Response Model:
- Success status (boolean)
- Session ID (string, stored in cookie automatically)
- XCSRF token (string, extracted from response)
- User role (enum: practitioner, house_surgeon, student)
- User profile summary (basic fields only)
- Session expiry timestamp (ISO 8601)
- If-Modified-Since header (extracted, stored separately)

#### Registration Request Model:
- Selected role (enum)
- No other fields in this phase

#### Error Response Model:
- Error code (string)
- Error message (string)
- Field-specific errors (Map<String, List<String>>)
- Retry-after header value (int, seconds)

### Serialization Requirements:
- Use json_serializable OR freezed (specify which)
- fromJson/toJson methods required
- Null safety enforced
- Unknown JSON keys ignored (not error)

---

## CACHE VALIDITY

- **User profile:** 12 hours
- **Session tokens:** Until expiry timestamp
- **Stale threshold:** 24 hours (show warning but use data)

---

## HIVE SCENARIO IMPLEMENTATIONS

### Scenario 1: First Launch (No Cache)
1. Show login screen immediately (no loading spinner)
2. User submits credentials
3. API call → 200 OK
4. Update UI with success
5. Save to Hive asynchronously (don't block navigation)
6. Navigate to next screen

### Scenario 2: App Restart with Internet (12h old cache)
1. Read from Hive immediately
2. Show login screen with "auto-login" if remember_me=true OR show home if session valid
3. Trigger background session validation API call
4. If 200 OK + new data: Update UI silently, update Hive
5. If 304 Not Modified: Keep UI as-is
6. If 401: Clear session, show login screen

### Scenario 3: App Restart No Internet (12h old cache)
1. Read from Hive immediately
2. Auto-login if session not expired by timestamp
3. API call fails (network error)
4. Fail silently, use cached data
5. Show non-blocking "offline mode" indicator
6. Retry on network reconnection (connectivity listener)

### Scenario 4: Navigation Between Screens
1. Keep session state in memory (Riverpod provider)
2. If memory cleared (rare): Fallback to Hive read
3. Never hit API for navigation-triggered reads

### Scenario 5: Expired Cache >24h with Internet
1. Read from Hive
2. Show UI with visible "data may be outdated" warning banner
3. Trigger API call immediately (not background)
4. If 200 OK: Update UI, remove warning, update Hive
5. If API fails: Keep showing stale data + warning
6. Auto-retry every 30 seconds with exponential backoff (max 5 minutes)

### Scenario 6: 304 Not Modified Response
1. API returns 304, empty body
2. Read data from Hive (key: cache for this endpoint)
3. Update UI with Hive data
4. Do NOT update If-Modified-Since timestamp
5. Mark data as "fresh" (reset staleness timer)

---

## CACHE INVALIDATION RULES

- **User logout:** Delete ALL auth_* keys
- **Session expired:** Delete session tokens only, keep user profile
- **Failed login attempt:** Do NOT clear old session data
- **Successful login:** Overwrite all keys

---

## ERROR HANDLING STRATEGY

### Network Errors

#### No Internet Connection:
- Check connectivity before API call
- If offline: Show "No internet connection" snackbar
- Enable "Retry" button
- Don't retry automatically

#### Timeout (>30s):
- Show "Request timed out" error
- Enable "Retry" button
- Log timeout to crash analytics

#### DNS Failure:
- Show "Cannot reach server" error
- Don't expose technical details
- Enable "Retry" button

### HTTP Errors

#### 400 Bad Request:
- Parse error response body
- Show field-specific errors below inputs
- Don't disable form

#### 401 Unauthorized:
- Show "Invalid credentials" error below form
- Clear password field
- Keep email field populated
- Increment failed attempt counter (max 5, then lockout UI for 60s)

#### 403 Forbidden:
- Treat as XCSRF token mismatch
- Clear session, redirect to login
- Show "Session expired, please login again"

#### 422 Unprocessable Entity:
- Parse field-level errors from response
- Show inline below each field
- First error gets focus

#### 429 Too Many Requests:
- Parse Retry-After header (seconds)
- Show lockout message: "Too many attempts. Try again in [X] seconds"
- Disable form
- Show countdown timer
- Auto-enable after countdown

#### 500/502/503 Server Error:
- Show generic "Something went wrong, please try again"
- Enable "Retry" button
- Log error to crash analytics
- Don't expose stack trace

#### Unknown HTTP Status:
- Treat as 500 error
- Log status code

### Parsing Errors

#### Invalid JSON Response:
- Log error
- Show generic error message
- Don't crash app

#### Missing Required Fields:
- Log warning
- Use default values if safe
- Otherwise treat as server error

---

## PERFORMANCE REQUIREMENTS

### Critical Metrics:
- **Login API call:** < 3 seconds acceptable
- **Hive read on app start:** < 100ms
- **UI render after Hive read:** < 16ms (60fps)
- **Form validation:** Synchronous, < 1ms
- **Cookie persistence:** Asynchronous, non-blocking

### Memory Management:
- Dispose all text controllers in dispose()
- Cancel timers in dispose()
- Clear form state on navigation away
- No memory leaks from listeners

### Build Performance:
- Login form rebuilds only on state change
- Password visibility toggle doesn't rebuild entire form
- Error messages don't trigger full form rebuild

---

## SECURITY REQUIREMENTS

### Sensitive Data Handling:
- Passwords never logged
- Passwords never stored (not even encrypted)
- Session tokens encrypted in Hive (use HiveAES encryption)
- XCSRF token encrypted in Hive
- Clear clipboard after password paste (optional)

### SSL/TLS:
- All API calls use HTTPS
- Certificate pinning: [YES/NO - if yes, specify pins]
- Reject self-signed certificates in production

### Input Sanitization:
- SQL injection: Not applicable (API responsibility)
- XSS: Escape user input if shown in WebView
- Path traversal: Not applicable

### Session Security:
- Auto-logout on biometric auth failure (if enabled)
- Session invalidated on device change (compare device_id)
- Logout on app uninstall (backend responsibility)

---

## EDGE CASES & HANDLING

### Simultaneous Login Attempts:
- Debounce submit button (1 second)
- Cancel previous API call if new one triggered

### Device Time Manipulation:
- Don't trust local timestamps for session expiry
- Use server time from response headers

### App Backgrounding During Login:
- Pause timeout timer
- Resume on app resume
- Show "Session may have expired" if >5 minutes in background

### First-Time User:
- No auto-login
- Show onboarding if never completed
- Track first launch in Hive

---
---

# PRACTITIONER REGISTRATION MODULE SPECIFICATION

## MODULE SCOPE

Four-screen practitioner registration flow after role selection, including personal details, professional credentials, address information, document uploads, and payment processing with multi-step state management.

---

## REGISTRATION FLOW ARCHITECTURE

### Multi-Step Form Structure

#### Flow Progression:
1. Screen 1: Personal Details → Next (validate + save state)
2. Screen 2: Professional Details → Next (validate + save state)
3. Screen 3: Address Details → Next (validate + save state)
4. Screen 4: Document Uploads → Next (validate + save state)
5. Screen 5: Payment → Submit (trigger final API call)

#### State Preservation Rules:
- All form data kept in memory (Riverpod StateNotifier) across screens
- Auto-save to Hive on every "Next" button click
- If user exits flow: State persists in Hive for 24 hours
- "Continue Registration" prompt on re-entry if incomplete registration exists
- Clear Hive state only on successful payment OR explicit user cancellation

#### Navigation Pattern:
- Forward navigation: "Next" button at bottom
- Back navigation: Back button/gesture allowed on all screens except during API calls
- Progress indicator: Show "Step X of 5" at top
- Unsaved changes warning: If user tries to exit without saving

---

## FORM DATA CACHING SCENARIOS

### User Exits Mid-Registration:
1. On screen exit: Save current screen data to Hive
2. Set reg_incomplete_flag = true
3. Store reg_current_step = X

### User Re-enters Registration:
1. Check reg_incomplete_flag
2. If true: Show dialog "Continue previous registration?"
3. Yes: Load all reg_* keys from Hive, navigate to reg_current_step
4. No: Clear all reg_* keys, start fresh from Screen 1

### Successful Registration:
1. Clear all reg_* keys from Hive
2. Set reg_incomplete_flag = false

### Failed Submission:
1. Keep all form data in Hive
2. User can retry without re-entering data

### Cache Expiry:
- **Form data:** 24 hours (after this, prompt user to start fresh)
- **Dropdown data:** 24 hours (stale warning after this)
- **File metadata:** 24 hours (files themselves in app temp directory)

---

## NAVIGATION & ROUTING

### Route Names:
- **Registration Screen 1:** [ROUTE_NAME_PERSONAL]
- **Registration Screen 2:** [ROUTE_NAME_PROFESSIONAL]
- **Registration Screen 3:** [ROUTE_NAME_ADDRESS]
- **Registration Screen 4:** [ROUTE_NAME_DOCUMENTS]
- **Registration Screen 5:** [ROUTE_NAME_PAYMENT]

### Navigation Flow:
- Always push next screen (allow back navigation)
- On final success: Replace entire stack with dashboard

### Back Button Behavior:
- Screen 2-5: Navigate to previous screen
- Screen 1: Show exit confirmation dialog
- During API calls: Disabled

### Exit Confirmation:
- Dialog: "Your progress will be saved. Exit registration?"
- Actions: "Stay" and "Exit"
- On exit: Save to Hive, navigate to previous screen (role selection OR home)

---

## ERROR HANDLING STRATEGY

### Dropdown Loading Errors

#### Network Failure:
- Show inline error: "Failed to load [dropdown name]"
- Show retry icon button next to dropdown
- Don't block other dropdowns

#### 404 Not Found (Dropdown endpoint):
- Log error to analytics
- Show: "Data not available at the moment"
- Disable dependent fields

#### Empty Dropdown:
- Show: "No options available"
- Don't show error styling
- Allow proceeding if field is optional

### Form Validation Errors

#### Client-Side Validation:
- Show errors on blur (not on every keystroke)
- Show errors on submit button click
- Clear errors on field focus

#### Server-Side Validation (400/422):
- Parse error response
- Map errors to respective fields
- If error for field not on current screen: Show notification and navigate to that screen
- Scroll to first error field

### File Upload Errors

#### File Too Large:
- Show immediately after selection
- Error: "File size exceeds [X]MB limit"
- Don't upload, clear selection

#### Invalid File Type:
- Show immediately after selection
- Error: "Invalid file type. Allowed: [TYPES]"

#### Upload Failure (Network):
- Show retry button
- Keep file in temp directory
- Auto-retry 3 times with 2s delay

#### Corrupted File:
- Show: "File is corrupted or unreadable"
- Allow re-upload

### Submission Errors

#### Network Timeout:
- Show: "Request timed out. Check internet and retry"
- Enable retry button
- Don't clear form data

#### Duplicate Email/Mobile (422):
- Navigate back to Screen 1
- Highlight email and/or mobile field
- Show error: "This [email/mobile] is already registered"
- Show "Login Instead?" link

#### Invalid Session (401):
- Show: "Your session expired. Please login again"
- Clear session data
- Navigate to login screen
- On successful login: Restore registration flow

#### Payment Gateway Error:
- Show error message from gateway
- Enable "Try Again" button
- Allow changing payment method
- Form data intact

#### Server Error (500):
- Show: "Something went wrong. Please try again"
- Enable retry button
- Log error with full context

---

## PERFORMANCE REQUIREMENTS

### Screen Load Times:
- **Screen 1 with dropdowns:** < 2 seconds (with cached data: < 500ms)
- **Screens 2-5:** < 500ms (data in memory)
- **Dependent dropdown load:** < 1 second

### File Upload:
- **Image compression:** < 2 seconds for 5MB file
- **Upload progress updates:** Every 100ms
- **Preview generation:** < 500ms

### Form Validation:
- **Synchronous validation:** < 1ms per field
- **Async validation (uniqueness check):** < 2 seconds
- **Debounce async validation:** 500ms

### Memory Management:
- Dispose all controllers in dispose()
- Cancel API calls on screen exit
- Clear file previews on successful submission
- Image compression uses isolate (not block main thread)

### Build Performance:
- Dropdown rebuilds only when data changes
- Form fields don't rebuild on unrelated state changes
- File preview widgets use const constructors where possible

---

## SECURITY REQUIREMENTS

### Sensitive Data:
- Council numbers: Not logged
- Documents: Stored in app private directory, deleted after submission
- Payment info: Never stored locally
- User data: Encrypted in Hive

### File Upload Security:
- Validate file extension AND MIME type
- Scan file headers to prevent extension spoofing
- Reject executable files (.exe, .apk, .sh)
- Sanitize file names before upload

### Session Management:
- XCSRF token sent with all POST requests
- Session validated before final submission
- If session expired during flow: Prompt re-login, restore flow

### Input Sanitization:
- Escape special characters in text fields
- Prevent SQL injection (API responsibility, but still sanitize)
- Limit input lengths strictly

---

## EDGE CASES & HANDLING

### User Changes Dependent Dropdown Parent:
- Country changed: Clear state and district, re-fetch states
- State changed: Clear district, re-fetch districts
- Membership district changed: Clear area, re-fetch areas
- Show loading in child dropdown during re-fetch

### App Backgrounded During Upload:
- Pause upload (if multipart)
- Resume on app resume (if <5 minutes)
- If >5 minutes: Show "Upload interrupted. Retry?"

### Multiple File Uploads Simultaneously:
- Not allowed (disable other upload buttons while one in progress)
- Queue if triggered (but UI should prevent this)

### Payment Gateway Doesn't Redirect Back:
- Implement timeout (2 minutes)
- After timeout: Show "Payment status unclear. Check with support"
- Allow manual verification via transaction ID

### User Edits Earlier Screen After Completing Later Screens:
- Allow editing
- Mark subsequent screens as "needs review" if dependent data changed
- Re-validate entire form on final submission

### Duplicate Registration Attempt:
- API returns 422 with "Already registered" error
- Show: "You're already registered. Login instead?"
- Provide login button

### File Deleted from Temp Directory:
- On submission: Check file existence
- If missing: Show error on document screen, request re-upload

### Stale Dropdown Data Selected:
- If selected option ID doesn't exist in refreshed data: Show error
- Force user to re-select from updated list

---

## CRITICAL REMINDERS FOR AI AGENT

- This module builds on authentication module (session, XCSRF)
- All dropdowns follow same caching strategy (Scenarios 1-6)
- Form state must survive app restarts
- File uploads are one-time (deleted after submission)
- Payment flow is one-way (no retry after success)
- Multi-step validation: Current screen + all previous screens
- Dependent dropdowns: Always validate parent selection first
- This document will be updated with actual endpoint URLs, field names, and payment gateway details later

---

**END OF MODULE SPECIFICATIONS**
