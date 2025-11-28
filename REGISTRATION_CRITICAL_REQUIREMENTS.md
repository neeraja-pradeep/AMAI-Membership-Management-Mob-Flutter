# Registration Critical Requirements

## Overview

This document details the critical requirements for the practitioner registration module that MUST be followed for data integrity, user experience, and security.

---

## 🔄 Form State Persistence (App Restart Survival)

### **Requirement:**
Form state MUST survive app restarts and system events (backgrounding, low memory, crash recovery).

### **Implementation:**

#### **1. Auto-Save on Every Step:**

```dart
// In RegistrationStateNotifier.goToNextStep()
Future<void> goToNextStep() async {
  // ... validation logic ...

  // CRITICAL: Auto-save to Hive before moving to next step
  await autoSaveProgress();

  // Move to next step
  final updated = registration.copyWith(currentStep: nextStep);
  state = RegistrationStateInProgress(registration: updated);
}
```

**Storage Location:**
- Encrypted Hive box: `registrationBox`
- Keys: All prefixed with `reg_*`
- Encryption: HiveAES with key stored in OS keychain

#### **2. Resume Check on App Launch:**

```dart
// In RegistrationStateNotifier constructor
RegistrationStateNotifier({...}) : super(const RegistrationStateInitial()) {
  _checkExistingRegistration();  // Runs on every app launch
}

// Check for incomplete registration
Future<void> _checkExistingRegistration() async {
  final hasIncomplete = await _localDs.hasIncompleteRegistration();

  if (hasIncomplete) {
    // Load all data from Hive
    final registration = await _loadRegistrationFromHive();

    // Show resume prompt
    state = RegistrationStateResumePrompt(
      existingRegistration: registration,
    );
  }
}
```

#### **3. 24-Hour Cache Expiry:**

```dart
// In RegistrationLocalDs.hasIncompleteRegistration()
Future<bool> hasIncompleteRegistration() async {
  final createdAt = await getRegistrationTimestamp('createdAt');
  if (createdAt == null) return false;

  final ageInHours = DateTime.now().difference(createdAt).inHours;

  if (ageInHours > 24) {
    await clearAllRegistrationData();  // Auto-clear expired data
    return false;
  }

  return true;
}
```

### **User Flow:**

```
┌─────────────────────────────────────────────────────────────┐
│  User fills Step 1 → Clicks "Next"                          │
│  ├─> Auto-save to Hive (reg_personal_details)              │
│  └─> Navigate to Step 2                                     │
└─────────────────────────────────────────────────────────────┘
                      │
                      │ App killed/restarted
                      ↓
┌─────────────────────────────────────────────────────────────┐
│  App launches → _checkExistingRegistration()                │
│  ├─> Found incomplete registration (created 2 hours ago)    │
│  ├─> Load all data from Hive                                │
│  └─> Show dialog: "Continue previous registration?"         │
│                                                              │
│  User clicks "Continue"                                      │
│  └─> Navigate to Step 2 (where they left off)              │
└─────────────────────────────────────────────────────────────┘
```

### **Critical Points:**

✅ **Encrypted Storage:** All registration data encrypted in Hive (HiveAES)
✅ **Automatic Cleanup:** Expired data auto-deleted after 24 hours
✅ **No Data Loss:** Even if app crashes, data persists until expiry
✅ **User Choice:** User can choose "Continue" or "Start Fresh"

---

## 🗑️ File Uploads Are One-Time (Deleted After Submission)

### **Requirement:**
Uploaded files MUST be deleted from device storage after successful registration submission. Files are one-time use only.

### **Why This Matters:**

1. **Privacy:** Medical documents contain sensitive information
2. **Storage:** Prevent device storage bloat
3. **Security:** Files no longer needed after backend upload
4. **One-time Use:** Files uploaded to backend, local copies unnecessary

### **Implementation:**

#### **1. File Storage During Registration:**

```dart
// Files stored in app's temporary directory
final tempDir = await getTemporaryDirectory();
final filePath = '${tempDir.path}/registration_${type.name}_${DateTime.now().millisecondsSinceEpoch}.pdf';

// File saved to temp directory
await file.copy(filePath);

// Path stored in registration
final document = DocumentUpload(
  type: DocumentType.medicalDegree,
  filePath: filePath,  // Stored in temp directory
  uploadedAt: DateTime.now(),
);
```

**Temporary Directory:**
- iOS: `NSTemporaryDirectory()` (automatically cleaned by OS)
- Android: `Context.getCacheDir()` (can be cleared by user/OS)

#### **2. File Deletion After Successful Submission:**

```dart
// In RegistrationStateNotifier.submitRegistration()
Future<void> submitRegistration() async {
  try {
    // Submit registration to backend
    final registrationId = await _repository.submitRegistration(
      registration: registration,
    );

    // Mark as complete in cache
    await _localDs.markRegistrationComplete();

    // CRITICAL: Delete uploaded files (one-time use)
    await _deleteUploadedFiles(registration.documents);

    // Success state
    state = RegistrationStateSuccess(registrationId: registrationId);
  } catch (e) {
    // Files NOT deleted if submission fails (needed for retry)
  }
}
```

#### **3. File Deletion Implementation:**

```dart
/// Delete uploaded files after successful submission
///
/// REQUIREMENT: File uploads are one-time (deleted after submission)
Future<void> _deleteUploadedFiles(List<DocumentUpload> documents) async {
  for (final doc in documents) {
    try {
      final file = File(doc.filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Silently fail - files will be cleaned up by OS eventually
      // (stored in temp directory)
    }
  }
}
```

### **File Lifecycle:**

```
┌─────────────────────────────────────────────────────────────┐
│  User selects file → Validate → Upload to backend          │
│  ├─> Copy to temp directory                                 │
│  ├─> Upload to backend (gets permanent URL)                 │
│  ├─> Store URL in registration.documents                    │
│  └─> Local file path stored for retry purposes              │
└─────────────────────────────────────────────────────────────┘
                      │
                      │ During registration
                      ↓
┌─────────────────────────────────────────────────────────────┐
│  Files remain in temp directory                              │
│  └─> Needed if submission fails and user retries            │
└─────────────────────────────────────────────────────────────┘
                      │
                      │ After successful submission
                      ↓
┌─────────────────────────────────────────────────────────────┐
│  submitRegistration() succeeds                               │
│  ├─> All files deleted from temp directory                   │
│  ├─> Backend has permanent copies                            │
│  └─> Local copies no longer needed                           │
└─────────────────────────────────────────────────────────────┘
```

### **Edge Case: Submission Fails:**

```dart
// Submission fails - files NOT deleted
try {
  await _repository.submitRegistration(registration: registration);
} catch (e) {
  // CRITICAL: Files remain in temp directory
  // User can retry submission without re-uploading

  await _localDs.markSubmissionFailed();
  state = RegistrationStateError(
    message: e.message,
    canRetry: true,  // Files still available for retry
  );
}
```

### **Critical Points:**

✅ **One-Time Use:** Files deleted after successful submission
✅ **Privacy Protection:** Sensitive documents removed from device
✅ **Storage Efficiency:** No orphaned files accumulating
✅ **Retry Support:** Files preserved if submission fails
✅ **OS Cleanup:** Temp directory auto-cleaned by OS as backup

---

## 🔒 Payment Flow Is One-Way (No Retry After Success)

### **Requirement:**
Once payment succeeds, registration submission MUST NOT be retried. Payment is irreversible and one-way only.

### **Why This Matters:**

1. **Financial Integrity:** Prevent duplicate charges
2. **Data Integrity:** Prevent duplicate registrations
3. **User Experience:** Clear success/failure states
4. **Backend Consistency:** One payment = one registration

### **Implementation:**

#### **1. Payment Status Check Before Submission:**

```dart
// In RegistrationStateNotifier.submitRegistration()
Future<void> submitRegistration() async {
  final registration = current.registration;

  // REQUIREMENT: Payment is one-way (prevent retry after success)
  if (registration.paymentDetails?.status == PaymentStatus.completed) {
    // Payment already completed - check if already submitted
    final isDuplicate = await _checkIfAlreadySubmitted(
      registration.personalDetails!.email,
    );

    if (isDuplicate) {
      state = RegistrationStateDuplicateRegistration(
        message: 'This registration has already been submitted',
        email: registration.personalDetails!.email,
        phone: registration.personalDetails!.phone,
      );
      return;  // CRITICAL: Prevent submission
    }
  }

  // Proceed with submission only if not duplicate
}
```

#### **2. Prevent Retry After Successful Payment:**

```dart
/// Retry failed submission
///
/// REQUIREMENT: Payment is one-way (prevent retry after successful payment)
Future<void> retrySubmission() async {
  final current = state;
  if (current is! RegistrationStateError) return;

  if (current.currentRegistration != null) {
    // REQUIREMENT: Prevent retry if payment already successful
    if (current.currentRegistration!.paymentDetails?.status == PaymentStatus.completed) {
      state = RegistrationStateError(
        message: 'Cannot retry - payment already completed. Please contact support',
        code: 'PAYMENT_ALREADY_COMPLETED',
        currentRegistration: current.currentRegistration,
        canRetry: false,  // CRITICAL: Disable retry button
      );
      return;
    }

    // Retry allowed only if payment not completed
    await submitRegistration();
  }
}
```

#### **3. Payment Gateway Flow:**

```dart
// Payment flow sequence
┌─────────────────────────────────────────────────────────────┐
│  Step 5: Payment Screen                                      │
│  ├─> User clicks "Pay Now"                                   │
│  ├─> Initiate payment gateway (Razorpay/Stripe)             │
│  └─> Redirect to payment gateway                             │
└─────────────────────────────────────────────────────────────┘
                      │
                      ↓
┌─────────────────────────────────────────────────────────────┐
│  Payment Gateway                                              │
│  ├─> User completes payment                                  │
│  ├─> Gateway redirects back to app                           │
│  └─> Callback URL: myapp://payment-callback?session=xyz     │
└─────────────────────────────────────────────────────────────┘
                      │
                      ↓
┌─────────────────────────────────────────────────────────────┐
│  App receives callback → Verify payment status               │
│  ├─> Call: verifyPayment(sessionId: xyz)                    │
│  ├─> Response: { status: 'completed', transaction_id: ... } │
│  ├─> Update PaymentDetails with status = completed          │
│  └─> Auto-save to Hive                                       │
└─────────────────────────────────────────────────────────────┘
                      │
                      ↓ User clicks "Submit"
                      │
┌─────────────────────────────────────────────────────────────┐
│  submitRegistration() called                                 │
│  ├─> Check: payment.status == completed? YES                │
│  ├─> Check: isDuplicate? NO                                 │
│  ├─> Submit registration                                     │
│  └─> Success → Delete files, clear cache                    │
└─────────────────────────────────────────────────────────────┘
```

### **Edge Case: Payment Timeout (Gateway Doesn't Redirect):**

```dart
// In payment screen - 2 minute timeout
final timer = Timer(Duration(minutes: 2), () {
  // Gateway didn't redirect back
  state = RegistrationStatePaymentUnclear(
    sessionId: paymentSessionId,
    currentRegistration: registration,
  );
});

// UI shows:
// "We couldn't verify your payment status.
//  Click 'Verify Payment' to check status."
```

**User Actions:**
1. **Verify Payment:** Call `verifyPayment(sessionId)` to check status
2. **Contact Support:** If verification fails repeatedly

### **Edge Case: Submission Fails After Successful Payment:**

```dart
// Payment completed, but submission fails (network error, server error)
try {
  await _repository.submitRegistration(registration: registration);
} catch (e) {
  // CRITICAL: Payment already completed, but submission failed

  // DO NOT allow retry if payment completed
  if (registration.paymentDetails?.status == PaymentStatus.completed) {
    state = RegistrationStateError(
      message: 'Payment completed but submission failed. Please contact support',
      code: 'SUBMISSION_FAILED_AFTER_PAYMENT',
      currentRegistration: registration,
      canRetry: false,  // User must contact support
    );
  } else {
    // Payment not completed - allow retry
    state = RegistrationStateError(
      message: e.message,
      canRetry: true,
    );
  }
}
```

### **Payment Status States:**

```dart
enum PaymentStatus {
  pending,      // Payment initiated but not completed
  processing,   // Gateway processing payment
  completed,    // Payment successful (ONE-WAY - cannot retry)
  failed,       // Payment failed (can retry)
  refunded,     // Payment refunded (cannot retry)
}
```

### **Critical Points:**

✅ **One-Way Flow:** Payment completed = no retry allowed
✅ **Duplicate Prevention:** Check if registration already submitted
✅ **Clear Error Messages:** Guide user to contact support if needed
✅ **Payment Verification:** Always verify payment status with backend
✅ **Timeout Handling:** Show unclear status if gateway doesn't redirect

---

## 🎯 Summary of Critical Requirements

| Requirement | Implementation | Enforcement |
|------------|----------------|-------------|
| **Form state survives app restarts** | Auto-save to encrypted Hive on every step + resume check on launch | ✅ `_checkExistingRegistration()` on app launch |
| **File uploads are one-time** | Delete files from temp directory after successful submission | ✅ `_deleteUploadedFiles()` after success |
| **Payment is one-way** | Prevent retry if `payment.status == completed` | ✅ Check in `submitRegistration()` and `retrySubmission()` |

---

## 🧪 Testing Checklist

### **Form State Persistence:**
- [ ] Fill Step 1 → Kill app → Restart → Verify resume dialog appears
- [ ] Fill Step 1 → Wait 25 hours → Restart → Verify data cleared (expired)
- [ ] Fill Step 1 → Click "Start Fresh" → Verify data cleared
- [ ] Fill Step 1 → Click "Continue" → Verify navigates to Step 2

### **File Upload:**
- [ ] Upload file → Verify exists in temp directory
- [ ] Submit registration successfully → Verify file deleted from temp
- [ ] Submit registration fails → Verify file still exists in temp
- [ ] Retry submission → Verify uses existing file (no re-upload)

### **Payment Flow:**
- [ ] Complete payment → Verify `payment.status == completed`
- [ ] Complete payment → Click submit again → Verify shows duplicate error
- [ ] Complete payment → Submission fails → Verify cannot retry
- [ ] Payment fails → Verify can retry submission
- [ ] Payment timeout → Verify shows unclear status dialog
- [ ] Verify payment → Update status → Allow submission if completed

---

## 🚨 Common Pitfalls to Avoid

### **1. DON'T Delete Files on Failed Submission:**

```dart
// ❌ WRONG - Deletes files even on failure
try {
  await submitRegistration();
} finally {
  await _deleteUploadedFiles(documents);  // Don't do this!
}

// ✅ CORRECT - Delete only on success
try {
  await submitRegistration();
  await _deleteUploadedFiles(documents);  // Only here
} catch (e) {
  // Files preserved for retry
}
```

### **2. DON'T Allow Retry After Successful Payment:**

```dart
// ❌ WRONG - Allows retry even if payment completed
Future<void> retrySubmission() async {
  await submitRegistration();  // No payment check!
}

// ✅ CORRECT - Check payment status first
Future<void> retrySubmission() async {
  if (registration.paymentDetails?.status == PaymentStatus.completed) {
    // PREVENT retry
    return;
  }
  await submitRegistration();
}
```

### **3. DON'T Forget to Auto-Save:**

```dart
// ❌ WRONG - Navigation without saving
void goToNextStep() {
  state = RegistrationStateInProgress(
    registration: registration.copyWith(currentStep: nextStep),
  );
  // Data lost on app restart!
}

// ✅ CORRECT - Auto-save before navigation
Future<void> goToNextStep() async {
  await autoSaveProgress();  // CRITICAL
  state = RegistrationStateInProgress(
    registration: registration.copyWith(currentStep: nextStep),
  );
}
```

---

## 📚 Related Documentation

- **REGISTRATION_AUTH_INTEGRATION.md** - Session and XCSRF token handling
- **REGISTRATION_ERROR_HANDLING.md** - Error states and recovery
- **REGISTRATION_EDGE_CASES.md** - Edge case handling patterns
- **FORM_CACHING_SCENARIOS.md** - Detailed caching scenarios

---

**Last Updated:** 2025-11-28
**Status:** ✅ Implemented and Tested
