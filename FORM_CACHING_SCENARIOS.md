# Form Data Caching Scenarios - Implementation Documentation

> **⚠️ IMPORTANT - FILE PATHS UPDATED:**
> Registration is now part of the Auth module. All file paths in this document reflect the OLD structure.
> **See [REGISTRATION_ARCHITECTURE.md](REGISTRATION_ARCHITECTURE.md) for updated paths and imports.**

## Overview
Detailed implementation of Hive-based form data caching for practitioner registration with 24-hour expiry and incomplete registration recovery.

---

## 📋 Caching Scenarios

### **SCENARIO 1: User Exits Mid-Registration**

**Trigger:** User presses back button, closes app, or navigates away during registration

**Implementation:**
```dart
// On screen exit (in every registration screen)
@override
void dispose() {
  // Auto-save current form data before disposal
  _saveCurrentStepData();
  super.dispose();
}

Future<void> _saveCurrentStepData() async {
  final personalDetails = PersonalDetails(
    firstName: _firstNameController.text.trim(),
    lastName: _lastNameController.text.trim(),
    // ... all fields
  );

  // Update state
  ref.read(registrationProvider.notifier).updatePersonalDetails(personalDetails);

  // Auto-save to Hive (repository handles this)
  await ref.read(registrationProvider.notifier).autoSaveProgress();
}
```

**Hive Keys Set:**
```
reg_incomplete_flag = true
reg_current_step = 1 (or current step number)
reg_created_at = "2025-01-28T10:30:00.000Z"
reg_last_updated_at = "2025-01-28T10:35:00.000Z"
reg_registration_id = "uuid-v4-string"
reg_personal_details = { JSON data }
```

**Result:** All form data persists in encrypted Hive, user can resume later

---

### **SCENARIO 2: User Re-enters Registration**

**Trigger:** User opens app and navigates to registration

**Flow:**
```
1. App starts
2. RegistrationStateNotifier checks Hive
3. Finds reg_incomplete_flag = true
4. Validates cache age (<24h)
5. Shows "Continue previous registration?" dialog
```

**Implementation:**
```dart
// In RegistrationStateNotifier.initState()
Future<void> _checkExistingRegistration() async {
  final hasIncomplete = await _localDs.hasIncompleteRegistration();

  if (hasIncomplete) {
    // Load timestamps to show user
    final timestamps = await _localDs.getRegistrationTimestamps();
    final currentStep = await _localDs.getCurrentStep() ?? 1;

    // Load all step data
    final personalData = await _localDs.getPersonalDetails();
    final professionalData = await _localDs.getProfessionalDetails();
    // ... load all steps

    // Convert to entities
    final registration = PractitionerRegistration(
      registrationId: await _localDs.getRegistrationId() ?? _uuid.v4(),
      currentStep: RegistrationStep.values[currentStep - 1],
      createdAt: timestamps!['createdAt']!,
      lastUpdatedAt: timestamps['lastUpdatedAt']!,
      personalDetails: personalData != null
          ? PersonalDetailsModel.fromJson(personalData).toEntity()
          : null,
      // ... all steps
    );

    // Show resume prompt
    state = RegistrationStateResumePrompt(existingRegistration: registration);
  }
}
```

**Dialog Implementation:**
```dart
// resume_registration_dialog.dart
AlertDialog(
  title: const Text('Continue Registration?'),
  content: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('You have an incomplete registration from ${DateFormat.yMd().format(lastUpdated)}'),
      SizedBox(height: 16.h),
      LinearProgressIndicator(value: completionPercentage),
      SizedBox(height: 8.h),
      Text('${(completionPercentage * 100).toStringAsFixed(0)}% complete'),
      SizedBox(height: 8.h),
      Text('Step ${currentStep} of 5: ${stepName}'),
    ],
  ),
  actions: [
    // OPTION 1: Start Fresh
    TextButton(
      onPressed: () {
        // Clear all reg_* keys
        ref.read(registrationProvider.notifier).startFreshRegistration();
        Navigator.of(context).pop();
      },
      child: const Text('Start Fresh'),
    ),

    // OPTION 2: Continue
    ElevatedButton(
      onPressed: () {
        // Load all reg_* keys, navigate to reg_current_step
        ref.read(registrationProvider.notifier).resumeRegistration(existingRegistration);
        Navigator.of(context).pop();

        // Navigate to the saved step
        switch (currentStep) {
          case RegistrationStep.personalDetails:
            Navigator.pushNamed(context, '/registration/personal');
          case RegistrationStep.professionalDetails:
            Navigator.pushNamed(context, '/registration/professional');
          // ... all steps
        }
      },
      child: const Text('Continue'),
    ),
  ],
);
```

**User Chooses "Yes" (Continue):**
```
1. Load all reg_* keys from Hive
2. Populate all form fields from cached data
3. Navigate to reg_current_step screen
4. User continues from where they left off
```

**User Chooses "No" (Start Fresh):**
```
1. Clear all reg_* keys from Hive
2. Set reg_incomplete_flag = false
3. Start fresh from Screen 1
4. Generate new reg_registration_id
```

---

### **SCENARIO 3: Successful Registration**

**Trigger:** Payment completed successfully, API returns 200 OK

**Implementation:**
```dart
// In RegistrationStateNotifier.submitRegistration()
Future<void> submitRegistration() async {
  try {
    final registrationId = await _repository.submitRegistration(
      registration: registration,
    );

    // CRITICAL: Clear all reg_* keys on success
    await _localDs.markRegistrationComplete();
    // This internally calls:
    // - clearAllRegistrationData()
    // - set reg_incomplete_flag = false

    state = RegistrationStateSuccess(registrationId: registrationId);
  } catch (e) {
    // Keep data for retry (see SCENARIO 4)
  }
}
```

**Hive Keys After Success:**
```
reg_incomplete_flag = false
All other reg_* keys = DELETED
```

**Result:** Clean state, user starts fresh if they register again

---

### **SCENARIO 4: Failed Submission**

**Trigger:** API call fails (network error, validation error, payment failed)

**Implementation:**
```dart
// In RegistrationStateNotifier.submitRegistration()
Future<void> submitRegistration() async {
  try {
    final registrationId = await _repository.submitRegistration(
      registration: registration,
    );

    await _localDs.markRegistrationComplete();
    state = RegistrationStateSuccess(registrationId: registrationId);
  } on AuthException catch (e) {
    // KEEP all form data in Hive for retry
    await _localDs.markSubmissionFailed();
    // This updates reg_last_updated_at but keeps all data

    state = RegistrationStateError(
      message: e.message,
      code: e.code,
      currentRegistration: registration, // Keep registration in state
    );
  }
}
```

**Hive Keys After Failure:**
```
reg_incomplete_flag = true (still incomplete)
reg_last_updated_at = updated to current time
All reg_* data = PRESERVED (unchanged)
```

**UI Behavior:**
```dart
// In payment_screen.dart
ref.listen<RegistrationState>(registrationProvider, (previous, next) {
  if (next case RegistrationStateError(:final message, :final currentRegistration)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () {
            // All data still in state, just retry submission
            ref.read(registrationProvider.notifier).submitRegistration();
          },
        ),
      ),
    );
  }
});
```

**Result:** User can retry without re-entering data

---

### **SCENARIO 5: Cache Expiry**

**Trigger:** User re-enters app after >24 hours since registration creation

**Implementation:**
```dart
// In RegistrationLocalDs.hasIncompleteRegistration()
Future<bool> hasIncompleteRegistration() async {
  final box = await SecureHiveStorage.openEncryptedBox(HiveBoxes.registrationBox);

  final incompleteFlag = box.get('reg_incomplete_flag') as bool?;
  if (incompleteFlag != true) return false;

  // Check 24-hour expiry
  final createdAtStr = box.get('reg_created_at') as String?;
  if (createdAtStr == null) return false;

  final createdAt = DateTime.parse(createdAtStr);
  final now = DateTime.now();
  final ageInHours = now.difference(createdAt).inHours;

  if (ageInHours > 24) {
    // EXPIRED - Auto-clear all data
    await clearAllRegistrationData();
    return false;
  }

  return true;
}
```

**Flow:**
```
1. User opens app after 24+ hours
2. hasIncompleteRegistration() checks age
3. Finds ageInHours = 25 (>24)
4. Auto-clears all reg_* keys
5. Returns false (no incomplete registration)
6. User starts fresh registration
```

**No Dialog Shown:** Cache silently cleared, user unaware

**Alternative (with warning):**
```dart
// Show stale data warning if age is 20-24 hours
if (ageInHours >= 20 && ageInHours < 24) {
  // Warn user: "This registration is about to expire"
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Registration Expiring Soon'),
      content: Text('This registration will expire in ${24 - ageInHours} hours. Please complete it or start fresh.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
```

---

## 🔑 Hive Keys Reference

### **Core Keys:**
| Key | Type | Purpose | Example |
|-----|------|---------|---------|
| `reg_incomplete_flag` | bool | Indicates incomplete registration exists | `true` |
| `reg_current_step` | int | Current step number (1-5) | `3` |
| `reg_created_at` | String | ISO 8601 timestamp of registration start | `"2025-01-28T10:30:00.000Z"` |
| `reg_last_updated_at` | String | ISO 8601 timestamp of last update | `"2025-01-28T11:45:00.000Z"` |
| `reg_registration_id` | String | UUID for tracking | `"550e8400-e29b-41d4-a716-446655440000"` |

### **Step Data Keys:**
| Key | Type | Purpose |
|-----|------|---------|
| `reg_personal_details` | Map<String, dynamic> | Step 1 form data (JSON) |
| `reg_professional_details` | Map<String, dynamic> | Step 2 form data (JSON) |
| `reg_address_details` | Map<String, dynamic> | Step 3 form data (JSON) |
| `reg_document_uploads` | Map<String, dynamic> | Step 4 file metadata (JSON) |
| `reg_payment_details` | Map<String, dynamic> | Step 5 payment info (JSON) |

---

## 🔐 Security Considerations

### **Encryption:**
- All `reg_*` keys stored in **encrypted Hive** via `SecureHiveStorage`
- Encryption key stored in OS keychain (flutter_secure_storage)
- HiveAES 256-bit encryption

### **File Storage:**
- Document files stored in app's **temp directory** (not Hive)
- File metadata (paths, names, sizes) stored in Hive
- Files auto-deleted on app uninstall or cache clear

### **Sensitive Data:**
- Payment credentials NOT stored (only transaction IDs)
- Medical council numbers encrypted
- Identity proof metadata encrypted

---

## 🧪 Testing Checklist

### **Test Scenario 1: Mid-Exit Save**
- [ ] Fill Step 1 partially → Close app
- [ ] Reopen app → Check Hive contains `reg_personal_details`
- [ ] Verify `reg_incomplete_flag = true`
- [ ] Verify `reg_current_step = 1`

### **Test Scenario 2: Resume Flow**
- [ ] Complete Step 1 & 2 → Close app
- [ ] Reopen app → Dialog appears with "Step 2 of 5"
- [ ] Click "Continue" → Navigate to Step 3
- [ ] Verify all previous data populated

### **Test Scenario 3: Start Fresh**
- [ ] Complete Step 1 → Close app
- [ ] Reopen app → Dialog appears
- [ ] Click "Start Fresh" → All `reg_*` keys deleted
- [ ] Navigate to Step 1 → All fields empty

### **Test Scenario 4: Successful Submit**
- [ ] Complete all 5 steps → Submit
- [ ] API returns 200 OK
- [ ] Check Hive → All `reg_*` keys deleted
- [ ] Verify `reg_incomplete_flag = false`

### **Test Scenario 5: Failed Submit with Retry**
- [ ] Complete all 5 steps → Submit
- [ ] Simulate API error (network off)
- [ ] Check Hive → All data preserved
- [ ] Tap "Retry" → All fields still populated
- [ ] Turn network on → Submit → Success

### **Test Scenario 6: 24-Hour Expiry**
- [ ] Complete Step 1 → Close app
- [ ] Change device time to +25 hours
- [ ] Reopen app → No dialog appears
- [ ] Check Hive → All `reg_*` keys auto-cleared
- [ ] Navigate to registration → Start fresh

---

## 📊 Cache Metrics

### **Typical Cache Sizes:**
| Data Type | Typical Size | Max Size |
|-----------|--------------|----------|
| Personal Details | 1-2 KB | 5 KB |
| Professional Details | 2-3 KB | 10 KB |
| Address Details | 1 KB | 5 KB |
| Document Metadata | 2-5 KB | 20 KB |
| Payment Details | 1 KB | 5 KB |
| **Total Registration** | **7-12 KB** | **45 KB** |

### **Cache Lifecycle:**
```
[Start] → Save on exit (0h)
        → Auto-save on "Next" (varies)
        → Stale warning (20h)
        → Expired & auto-clear (24h)
        → [End]
```

---

## 🔄 State Diagram

```
┌─────────────────────────────────────────────────────────┐
│                  REGISTRATION FLOW                       │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  [App Start]                                            │
│       │                                                  │
│       ├─ Check reg_incomplete_flag                      │
│       │                                                  │
│       ├─ If true & <24h ────> [Resume Dialog]          │
│       │                              │                   │
│       │                              ├─ "Continue" ──> Load Step X
│       │                              └─ "Start Fresh" ─> Clear All
│       │                                                  │
│       └─ If false or >24h ───> [New Registration]      │
│                                                          │
│  [During Registration]                                   │
│       │                                                  │
│       ├─ On "Next" ──────> Save to Hive                │
│       ├─ On "Back" ──────> Keep in memory only         │
│       └─ On Exit  ──────> Auto-save to Hive           │
│                                                          │
│  [Submit Registration]                                   │
│       │                                                  │
│       ├─ Success ────────> Clear all reg_* keys        │
│       └─ Failure ────────> Keep data for retry         │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

**Implementation Status:** ✅ RegistrationLocalDs created with all caching scenarios
**Next:** Update RegistrationStateNotifier to use these methods
