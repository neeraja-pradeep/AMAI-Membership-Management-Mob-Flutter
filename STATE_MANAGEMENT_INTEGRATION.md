# State Management Integration - Implementation Guide

> **⚠️ IMPORTANT - FILE PATHS UPDATED:**
> Registration is now part of the Auth module. All file paths in this document reflect the OLD structure.
> **See [REGISTRATION_ARCHITECTURE.md](REGISTRATION_ARCHITECTURE.md) for updated paths and imports.**

## Overview
Complete guide for integrating `RegistrationStateNotifier` with UI screens to enable multi-step registration with automatic form caching, 24-hour expiry, and resume functionality.

---

## 📁 Files Created

### **Core State Management:**
1. `lib/features/registration/application/notifiers/registration_state_notifier.dart`
   - Main state notifier with auto-save logic
   - JSON conversion helpers
   - Resume/fresh start logic
   - All 5 caching scenarios implemented

2. `lib/features/registration/presentation/widgets/resume_registration_dialog.dart`
   - Dialog shown when incomplete registration found
   - Progress indicator, stale data warning
   - "Continue" vs "Start Fresh" options

---

## 🔄 State Flow Diagram

```
[App Start]
    │
    ├─ RegistrationStateNotifier._checkExistingRegistration()
    │       │
    │       ├─ hasIncompleteRegistration() = false
    │       │       └─> RegistrationStateInitial
    │       │
    │       └─ hasIncompleteRegistration() = true
    │               └─> RegistrationStateResumePrompt
    │                       │
    │                       ├─ User clicks "Continue"
    │                       │       └─> resumeRegistration()
    │                       │               └─> RegistrationStateInProgress
    │                       │
    │                       └─ User clicks "Start Fresh"
    │                               └─> startFreshRegistration()
    │                                       └─> RegistrationStateInProgress
    │
[Registration In Progress]
    │
    ├─ User fills Step 1 → updatePersonalDetails()
    ├─ User clicks "Next" → goToNextStep()
    │       ├─ Validate current step
    │       ├─ Auto-save to Hive
    │       └─ Move to next step
    │
    ├─ User clicks "Back" → goToPreviousStep()
    │       └─ No validation, no save
    │
    └─ User exits app → dispose() calls autoSaveProgress()
            └─> Data saved to Hive with reg_incomplete_flag = true

[Final Submission]
    │
    ├─ submitRegistration()
    │       │
    │       ├─ Success
    │       │       └─> markRegistrationComplete()
    │       │               └─> Clear all reg_* keys
    │       │                       └─> RegistrationStateSuccess
    │       │
    │       └─ Failure
    │               └─> markSubmissionFailed()
    │                       └─> Keep data in Hive
    │                               └─> RegistrationStateError
    │                                       └─> User can retry
```

---

## 🎯 Using RegistrationStateNotifier in UI

### **1. Listen to State Changes**

```dart
// In your registration screen widget
@override
Widget build(BuildContext context, WidgetRef ref) {
  // Listen to state changes
  ref.listen<RegistrationState>(registrationProvider, (previous, next) {
    switch (next) {
      case RegistrationStateResumePrompt(:final existingRegistration):
        // Show resume dialog
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showResumeRegistrationDialog(context, existingRegistration);
        });

      case RegistrationStateValidationError(:final message):
        // Show validation error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );

      case RegistrationStateError(:final message, :final currentRegistration):
        // Show error with retry option
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                ref.read(registrationProvider.notifier).retrySubmission();
              },
            ),
          ),
        );

      case RegistrationStateSuccess(:final registrationId):
        // Navigate to success screen
        Navigator.pushReplacementNamed(
          context,
          '/registration/success',
          arguments: registrationId,
        );
    }
  });

  // Watch current state
  final state = ref.watch(registrationProvider);

  return switch (state) {
    RegistrationStateInitial() => _buildInitialScreen(),
    RegistrationStateLoading(:final message) => _buildLoadingScreen(message),
    RegistrationStateInProgress(:final registration) =>
      _buildRegistrationForm(registration),
    _ => const SizedBox.shrink(),
  };
}
```

---

### **2. Personal Details Screen (Step 1)**

```dart
// lib/features/registration/presentation/screens/personal_details_screen.dart

class PersonalDetailsScreen extends ConsumerStatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  ConsumerState<PersonalDetailsScreen> createState() =>
      _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends ConsumerState<PersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _dateOfBirth;
  String? _gender;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  /// Load existing data if resuming registration
  void _loadExistingData() {
    final state = ref.read(registrationProvider);
    if (state case RegistrationStateInProgress(:final registration)) {
      final details = registration.personalDetails;
      if (details != null) {
        _firstNameController.text = details.firstName;
        _lastNameController.text = details.lastName;
        _emailController.text = details.email;
        _phoneController.text = details.phone;
        _dateOfBirth = details.dateOfBirth;
        _gender = details.gender;
      }
    }
  }

  @override
  void dispose() {
    // Auto-save on screen exit
    _saveCurrentData();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Save current form data to state (NOT to Hive yet)
  void _saveCurrentData() {
    if (_dateOfBirth != null && _gender != null) {
      final personalDetails = PersonalDetails(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        dateOfBirth: _dateOfBirth!,
        gender: _gender!,
      );

      ref.read(registrationProvider.notifier).updatePersonalDetails(
            personalDetails,
          );
    }
  }

  /// Handle "Next" button click
  Future<void> _onNextPressed() async {
    if (!_formKey.currentState!.validate()) return;

    // Save to state
    _saveCurrentData();

    // Auto-save to Hive and move to next step
    await ref.read(registrationProvider.notifier).goToNextStep();

    // Navigate to next screen if validation passed
    final state = ref.read(registrationProvider);
    if (state case RegistrationStateInProgress()) {
      if (mounted) {
        Navigator.pushNamed(context, '/registration/professional');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registrationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Save before going back
            _saveCurrentData();
            Navigator.pop(context);
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              if (state case RegistrationStateInProgress(:final registration))
                LinearProgressIndicator(
                  value: registration.completionPercentage,
                ),
              SizedBox(height: 16.h),

              Text(
                'Step 1 of 5',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24.h),

              // Form fields
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) =>
                    value?.isEmpty == true ? 'Required' : null,
                onChanged: (_) => _saveCurrentData(),
              ),
              SizedBox(height: 16.h),

              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) =>
                    value?.isEmpty == true ? 'Required' : null,
                onChanged: (_) => _saveCurrentData(),
              ),
              SizedBox(height: 16.h),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Required';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value!)) {
                    return 'Invalid email';
                  }
                  return null;
                },
                onChanged: (_) => _saveCurrentData(),
              ),
              SizedBox(height: 16.h),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value?.isEmpty == true ? 'Required' : null,
                onChanged: (_) => _saveCurrentData(),
              ),
              SizedBox(height: 16.h),

              // Date of Birth picker
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dateOfBirth ?? DateTime(1990),
                    firstDate: DateTime(1940),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _dateOfBirth = date);
                    _saveCurrentData();
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date of Birth'),
                  child: Text(
                    _dateOfBirth != null
                        ? DateFormat.yMd().format(_dateOfBirth!)
                        : 'Select date',
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Gender dropdown
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: ['male', 'female', 'other']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (value) {
                  setState(() => _gender = value);
                  _saveCurrentData();
                },
                validator: (value) => value == null ? 'Required' : null,
              ),
              SizedBox(height: 32.h),

              // Next button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state is RegistrationStateLoading
                      ? null
                      : _onNextPressed,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  child: Text(
                    state is RegistrationStateLoading ? 'Saving...' : 'Next',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### **3. Payment Screen (Step 5) - Final Submission**

```dart
// lib/features/registration/presentation/screens/payment_screen.dart

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  @override
  void initState() {
    super.initState();
    _listenToStateChanges();
  }

  void _listenToStateChanges() {
    ref.listen<RegistrationState>(registrationProvider, (previous, next) {
      switch (next) {
        case RegistrationStateSuccess(:final registrationId):
          // Navigate to success screen
          Navigator.pushReplacementNamed(
            context,
            '/registration/success',
            arguments: registrationId,
          );

        case RegistrationStateError(:final message):
          // Show error with retry
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () {
                  ref.read(registrationProvider.notifier).retrySubmission();
                },
              ),
            ),
          );
      }
    });
  }

  Future<void> _handlePayment() async {
    // TODO: Integrate payment gateway

    // Mock payment
    final paymentDetails = PaymentDetails(
      amount: 1000.0,
      currency: 'INR',
      status: PaymentStatus.completed,
      transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      paymentMethod: 'card',
      paymentDate: DateTime.now(),
    );

    // Update payment details
    ref.read(registrationProvider.notifier).updatePaymentDetails(
          paymentDetails,
        );

    // Submit registration
    await ref.read(registrationProvider.notifier).submitRegistration();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registrationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(registrationProvider.notifier).goToPreviousStep();
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            if (state case RegistrationStateInProgress(:final registration))
              LinearProgressIndicator(
                value: registration.completionPercentage,
              ),
            SizedBox(height: 16.h),

            Text(
              'Step 5 of 5',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24.h),

            // Payment details
            const Text(
              'Registration Fee',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),

            const Text(
              '₹1,000',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32.h),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    state is RegistrationStateLoading ? null : _handlePayment,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
                child: Text(
                  state is RegistrationStateLoading
                      ? 'Processing...'
                      : 'Pay and Submit',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🔑 Key Implementation Notes

### **Auto-Save Pattern:**
```dart
@override
void dispose() {
  // ALWAYS auto-save on screen exit
  _saveCurrentStepData();
  super.dispose();
}

Future<void> _saveCurrentStepData() async {
  // 1. Create entity from form fields
  final details = PersonalDetails(...);

  // 2. Update state (in-memory)
  ref.read(registrationProvider.notifier).updatePersonalDetails(details);

  // 3. Auto-save to Hive (happens in goToNextStep or manually)
  await ref.read(registrationProvider.notifier).autoSaveProgress();
}
```

### **Navigation Pattern:**
```dart
// Forward navigation (with validation + save)
await ref.read(registrationProvider.notifier).goToNextStep();

// Backward navigation (no validation, no save)
ref.read(registrationProvider.notifier).goToPreviousStep();
```

### **Error Handling:**
```dart
ref.listen<RegistrationState>(registrationProvider, (previous, next) {
  if (next case RegistrationStateError(:final message, :final currentRegistration)) {
    // Show error + retry option
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () {
            ref.read(registrationProvider.notifier).retrySubmission();
          },
        ),
      ),
    );
  }
});
```

---

## 🧪 Testing Checklist

### **Test Scenario 1: New Registration**
- [ ] Open app → No dialog shown (fresh state)
- [ ] Start registration → Fill Step 1 → Click "Next"
- [ ] Verify Hive contains `reg_personal_details`
- [ ] Verify `reg_incomplete_flag = true`
- [ ] Verify `reg_current_step = 1`

### **Test Scenario 2: Resume Flow**
- [ ] Complete Step 1 & 2 → Close app
- [ ] Reopen app → Dialog appears with "Step 2 of 5, X% complete"
- [ ] Click "Continue" → Navigate to Step 3
- [ ] Verify all previous data populated in forms

### **Test Scenario 3: Start Fresh**
- [ ] Complete Step 1 → Close app
- [ ] Reopen app → Dialog appears
- [ ] Click "Start Fresh" → All `reg_*` keys deleted
- [ ] Navigate to Step 1 → All fields empty

### **Test Scenario 4: Successful Submit**
- [ ] Complete all 5 steps → Submit payment
- [ ] API returns success
- [ ] Check Hive → All `reg_*` keys deleted
- [ ] Verify `reg_incomplete_flag = false`

### **Test Scenario 5: Failed Submit with Retry**
- [ ] Complete all 5 steps → Submit
- [ ] Simulate API error
- [ ] Check Hive → All data preserved
- [ ] Tap "Retry" → All fields still populated
- [ ] Fix error → Submit → Success

### **Test Scenario 6: 24-Hour Expiry**
- [ ] Complete Step 1 → Close app
- [ ] Change device time to +25 hours
- [ ] Reopen app → No dialog appears
- [ ] Check Hive → All `reg_*` keys auto-cleared

### **Test Scenario 7: Stale Data Warning**
- [ ] Complete Step 1 → Close app
- [ ] Change device time to +21 hours
- [ ] Reopen app → Dialog shows warning: "About to expire"
- [ ] Data still loads correctly

---

## 📦 Dependencies Required

All dependencies already in `pubspec.yaml`:
- ✅ `flutter_riverpod: ^2.6.1`
- ✅ `uuid: ^4.5.1`
- ✅ `hive: ^2.2.3`
- ✅ `flutter_secure_storage: ^9.2.2`
- ✅ `flutter_screenutil: ^5.9.3`
- ✅ `intl: ^0.19.0`

---

## 🎯 Next Steps

1. **Implement UI Screens:**
   - PersonalDetailsScreen (Step 1)
   - ProfessionalDetailsScreen (Step 2)
   - AddressDetailsScreen (Step 3)
   - DocumentUploadScreen (Step 4)
   - PaymentScreen (Step 5)

2. **Implement API Integration:**
   - Create `RegistrationApi` for backend calls
   - Create `RegistrationRepository`
   - Update `submitRegistration()` to call real API

3. **Add Navigation:**
   - Set up routes for all registration screens
   - Implement navigation logic in `_navigateToStep()`

4. **Testing:**
   - Unit tests for state notifier
   - Widget tests for UI screens
   - Integration tests for end-to-end flow

---

**Implementation Status:**
- ✅ RegistrationLocalDs (Hive caching layer)
- ✅ RegistrationStateNotifier (State management)
- ✅ ResumeRegistrationDialog (UI component)
- ✅ All 5 caching scenarios implemented
- ⏳ UI screens (not started)
- ⏳ API integration (not started)
- ⏳ Testing (not started)
