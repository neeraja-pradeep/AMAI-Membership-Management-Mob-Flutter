# Registration Navigation & Routing - Implementation Guide

> **⚠️ IMPORTANT - FILE PATHS AND ROUTING UPDATED:**
> Registration is now part of the Auth module and routing is centralized in `app_router.dart`.
> **See [REGISTRATION_ARCHITECTURE.md](REGISTRATION_ARCHITECTURE.md) for updated paths, imports, and routing.**

## Overview
Complete guide for implementing navigation flow across all 5 registration screens with exit confirmation, back button handling, and success navigation.

---

## 📁 Files Created

### **Navigation Infrastructure:**
1. `lib/features/registration/presentation/routes/registration_routes.dart`
   - Route name constants for all 5 screens
   - Helper methods for route/step conversion
   - Route validation

2. `lib/features/registration/presentation/widgets/exit_confirmation_dialog.dart`
   - Exit confirmation dialog with auto-save
   - "Stay" vs "Exit" options
   - Auto-saves progress to Hive on exit

3. Updated `resume_registration_dialog.dart`
   - Proper route-based navigation
   - Uses RegistrationRoutes for navigation

---

## 🛣️ Route Names

```dart
/// All registration routes (use these constants)
RegistrationRoutes.personal       // '/registration/personal'
RegistrationRoutes.professional   // '/registration/professional'
RegistrationRoutes.address        // '/registration/address'
RegistrationRoutes.documents      // '/registration/documents'
RegistrationRoutes.payment        // '/registration/payment'
RegistrationRoutes.success        // '/registration/success'
```

---

## 🔄 Navigation Flow

### **Forward Navigation: Always Push**

```dart
// From Screen 1 → Screen 2
await ref.read(registrationProvider.notifier).goToNextStep();

if (mounted) {
  Navigator.pushNamed(context, RegistrationRoutes.professional);
}

// From Screen 2 → Screen 3
await ref.read(registrationProvider.notifier).goToNextStep();

if (mounted) {
  Navigator.pushNamed(context, RegistrationRoutes.address);
}

// From Screen 3 → Screen 4
await ref.read(registrationProvider.notifier).goToNextStep();

if (mounted) {
  Navigator.pushNamed(context, RegistrationRoutes.documents);
}

// From Screen 4 → Screen 5
await ref.read(registrationProvider.notifier).goToNextStep();

if (mounted) {
  Navigator.pushNamed(context, RegistrationRoutes.payment);
}
```

**Key Points:**
- Always call `goToNextStep()` first (validates + auto-saves)
- Then push to next route
- Check `mounted` before navigation
- User can use back button to return

---

### **Backward Navigation: Pop Stack**

```dart
// From Screen 2-5 → Previous Screen
Navigator.pop(context);

// Optionally update state
ref.read(registrationProvider.notifier).goToPreviousStep();
```

**Key Points:**
- Simple `pop()` - no validation, no save
- State notifier optional (for tracking current step)
- Back navigation allowed on all screens except during API calls

---

### **Success Navigation: Replace Entire Stack**

```dart
// After successful registration
ref.listen<RegistrationState>(registrationProvider, (previous, next) {
  if (next case RegistrationStateSuccess(:final registrationId)) {
    // Replace entire navigation stack with dashboard
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/dashboard', // or '/home'
      (route) => false, // Remove all previous routes
      arguments: registrationId,
    );
  }
});
```

**Key Points:**
- `pushNamedAndRemoveUntil` clears entire stack
- Prevents user from going back to registration
- Pass `registrationId` as argument

---

## 🔙 Back Button Behavior

### **Screen 1 (Personal Details): Exit Confirmation**

```dart
// In PersonalDetailsScreen
@override
Widget build(BuildContext context, WidgetRef ref) {
  return WillPopScope(
    onWillPop: () async {
      // Show exit confirmation dialog
      final shouldExit = await showExitConfirmationDialog(
        context,
        onExit: () {
          // Navigate to role selection or home
          Navigator.pop(context);
        },
      );

      // Return true to allow pop, false to prevent
      return shouldExit ?? false;
    },
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Personal Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            // Same logic as WillPopScope
            final shouldExit = await showExitConfirmationDialog(
              context,
              onExit: () {
                Navigator.pop(context);
              },
            );

            if (shouldExit == true && mounted) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: _buildBody(),
    ),
  );
}
```

**Dialog Flow:**
1. User presses back button
2. Show dialog: "Your progress will be saved. Exit registration?"
3. Auto-save to Hive when user clicks "Exit"
4. Navigate to previous screen (role selection or home)
5. If "Stay", dialog closes and user remains on screen

---

### **Screen 2-5: Simple Back Navigation**

```dart
// In ProfessionalDetailsScreen, AddressDetailsScreen, etc.
@override
Widget build(BuildContext context, WidgetRef ref) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Professional Details'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          // Optional: Update state
          ref.read(registrationProvider.notifier).goToPreviousStep();

          // Navigate back
          Navigator.pop(context);
        },
      ),
    ),
    body: _buildBody(),
  );
}
```

**Key Points:**
- No confirmation dialog
- Simple `pop()` back to previous screen
- Optional state update

---

### **During API Calls: Disable Back Button**

```dart
// In PaymentScreen (during submission)
@override
Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.watch(registrationProvider);

  return WillPopScope(
    onWillPop: () async {
      // Disable back button during API calls
      if (state is RegistrationStateLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please wait while we process your registration...'),
          ),
        );
        return false; // Prevent navigation
      }

      return true; // Allow navigation
    },
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        leading: state is RegistrationStateLoading
            ? null // Hide back button during loading
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: _buildBody(),
    ),
  );
}
```

---

## 🎯 Complete Screen Implementation Example

### **Screen 1: Personal Details (with Exit Confirmation)**

```dart
// lib/features/registration/presentation/screens/personal_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../application/notifiers/registration_state_notifier.dart';
import '../../application/states/registration_state.dart';
import '../../domain/entities/personal_details.dart';
import '../routes/registration_routes.dart';
import '../widgets/exit_confirmation_dialog.dart';

class PersonalDetailsScreen extends ConsumerStatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  ConsumerState<PersonalDetailsScreen> createState() =>
      _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState
    extends ConsumerState<PersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  // ... form controllers

  @override
  void dispose() {
    // Auto-save on screen exit
    _saveCurrentData();
    // ... dispose controllers
    super.dispose();
  }

  void _saveCurrentData() {
    // Create entity and update state
    final personalDetails = PersonalDetails(/* ... */);
    ref.read(registrationProvider.notifier).updatePersonalDetails(
          personalDetails,
        );
  }

  Future<void> _onNextPressed() async {
    if (!_formKey.currentState!.validate()) return;

    _saveCurrentData();

    // Auto-save to Hive and validate
    await ref.read(registrationProvider.notifier).goToNextStep();

    // Navigate if validation passed
    final state = ref.read(registrationProvider);
    if (state case RegistrationStateInProgress()) {
      if (mounted) {
        Navigator.pushNamed(context, RegistrationRoutes.professional);
      }
    }
  }

  Future<bool> _onWillPop() async {
    final shouldExit = await showExitConfirmationDialog(
      context,
      onExit: () {
        // Navigate to previous screen (role selection or home)
        if (mounted) {
          Navigator.pop(context);
        }
      },
    );

    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registrationProvider);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Personal Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final shouldExit = await showExitConfirmationDialog(
                context,
                onExit: () {
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
              );

              if (shouldExit == true && mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Progress indicator
                if (state case RegistrationStateInProgress(:final registration))
                  LinearProgressIndicator(
                    value: registration.completionPercentage,
                  ),
                SizedBox(height: 16.h),

                Text('Step 1 of 5'),
                SizedBox(height: 24.h),

                // Form fields...

                SizedBox(height: 32.h),

                // Next button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state is RegistrationStateLoading
                        ? null
                        : _onNextPressed,
                    child: Text(
                      state is RegistrationStateLoading ? 'Saving...' : 'Next',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

### **Screen 5: Payment (with Success Navigation)**

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
          // Navigate to success screen (replace entire stack)
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              RegistrationRoutes.success,
              (route) => false, // Remove all routes
              arguments: registrationId,
            );
          }

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
    // Mock payment
    final paymentDetails = PaymentDetails(/* ... */);

    ref.read(registrationProvider.notifier).updatePaymentDetails(
          paymentDetails,
        );

    // Submit registration
    await ref.read(registrationProvider.notifier).submitRegistration();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registrationProvider);

    return WillPopScope(
      onWillPop: () async {
        // Disable back button during loading
        if (state is RegistrationStateLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please wait while we process your registration...'),
            ),
          );
          return false;
        }

        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment'),
          leading: state is RegistrationStateLoading
              ? null
              : IconButton(
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
            children: [
              // Payment UI...

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state is RegistrationStateLoading
                      ? null
                      : _handlePayment,
                  child: Text(
                    state is RegistrationStateLoading
                        ? 'Processing...'
                        : 'Pay and Submit',
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

## 📊 Navigation Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                     REGISTRATION NAVIGATION                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  [App Start / Role Selection]                                   │
│         │                                                        │
│         └─> Navigate to Screen 1 (Personal)                     │
│                     │                                            │
│  ┌──────────────────┴──────────────────┐                        │
│  │   Screen 1: Personal Details        │                        │
│  │   Route: /registration/personal     │                        │
│  ├─────────────────────────────────────┤                        │
│  │  Back Button: Exit Confirmation     │                        │
│  │  • "Stay" → Remain on screen        │                        │
│  │  • "Exit" → Save + pop to home      │                        │
│  │  Next Button: Validate + Save       │                        │
│  └─────────────────┬───────────────────┘                        │
│                    │                                             │
│                    ├─> Push Screen 2 (Professional)             │
│                    │                                             │
│  ┌─────────────────┴───────────────────┐                        │
│  │   Screen 2: Professional Details    │                        │
│  │   Route: /registration/professional │                        │
│  ├─────────────────────────────────────┤                        │
│  │  Back: Pop to Screen 1              │                        │
│  │  Next: Validate + Save              │                        │
│  └─────────────────┬───────────────────┘                        │
│                    │                                             │
│                    ├─> Push Screen 3 (Address)                  │
│                    │                                             │
│  ┌─────────────────┴───────────────────┐                        │
│  │   Screen 3: Address Details         │                        │
│  │   Route: /registration/address      │                        │
│  ├─────────────────────────────────────┤                        │
│  │  Back: Pop to Screen 2              │                        │
│  │  Next: Validate + Save              │                        │
│  └─────────────────┬───────────────────┘                        │
│                    │                                             │
│                    ├─> Push Screen 4 (Documents)                │
│                    │                                             │
│  ┌─────────────────┴───────────────────┐                        │
│  │   Screen 4: Document Uploads        │                        │
│  │   Route: /registration/documents    │                        │
│  ├─────────────────────────────────────┤                        │
│  │  Back: Pop to Screen 3              │                        │
│  │  Next: Validate + Save              │                        │
│  └─────────────────┬───────────────────┘                        │
│                    │                                             │
│                    ├─> Push Screen 5 (Payment)                  │
│                    │                                             │
│  ┌─────────────────┴───────────────────┐                        │
│  │   Screen 5: Payment                 │                        │
│  │   Route: /registration/payment      │                        │
│  ├─────────────────────────────────────┤                        │
│  │  Back: Pop to Screen 4              │                        │
│  │  Submit: Final validation           │                        │
│  └─────────────────┬───────────────────┘                        │
│                    │                                             │
│                    ├─ Success ─> Clear Stack + Navigate to      │
│                    │              Success Screen                 │
│                    │                                             │
│                    └─ Failure ─> Show Retry Snackbar            │
│                                  (Stay on Screen 5)              │
│                                                                  │
│  [Success Screen]                                                │
│         │                                                        │
│         └─> Navigate to Dashboard (Remove all routes)           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🧪 Testing Checklist

### **Navigation Tests:**

- [ ] **Screen 1 Back Button**
  - [ ] Shows exit confirmation dialog
  - [ ] "Stay" keeps user on screen
  - [ ] "Exit" auto-saves and navigates to home
  - [ ] Progress saved in Hive

- [ ] **Screen 2-4 Back Button**
  - [ ] Simple pop to previous screen
  - [ ] No confirmation dialog
  - [ ] State updates to previous step

- [ ] **Screen 5 Back Button**
  - [ ] Disabled during payment processing
  - [ ] Shows snackbar if pressed during loading
  - [ ] Enabled after processing complete

- [ ] **Forward Navigation (Next)**
  - [ ] Validates current step
  - [ ] Shows error if validation fails
  - [ ] Auto-saves to Hive on success
  - [ ] Navigates to next screen

- [ ] **Success Navigation**
  - [ ] Replaces entire navigation stack
  - [ ] Back button does NOT return to registration
  - [ ] Navigates to dashboard/home

- [ ] **Resume Flow**
  - [ ] Dialog appears with correct route
  - [ ] "Continue" navigates to saved step
  - [ ] All previous data populated

---

## 🎯 Route Registration in Main App

```dart
// lib/main.dart or lib/router.dart

import 'package:flutter/material.dart';
import 'features/registration/presentation/routes/registration_routes.dart';
import 'features/registration/presentation/screens/personal_details_screen.dart';
import 'features/registration/presentation/screens/professional_details_screen.dart';
import 'features/registration/presentation/screens/address_details_screen.dart';
import 'features/registration/presentation/screens/document_upload_screen.dart';
import 'features/registration/presentation/screens/payment_screen.dart';
import 'features/registration/presentation/screens/registration_success_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RegistrationRoutes.personal:
        return MaterialPageRoute(
          builder: (_) => const PersonalDetailsScreen(),
        );

      case RegistrationRoutes.professional:
        return MaterialPageRoute(
          builder: (_) => const ProfessionalDetailsScreen(),
        );

      case RegistrationRoutes.address:
        return MaterialPageRoute(
          builder: (_) => const AddressDetailsScreen(),
        );

      case RegistrationRoutes.documents:
        return MaterialPageRoute(
          builder: (_) => const DocumentUploadScreen(),
        );

      case RegistrationRoutes.payment:
        return MaterialPageRoute(
          builder: (_) => const PaymentScreen(),
        );

      case RegistrationRoutes.success:
        final registrationId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => RegistrationSuccessScreen(
            registrationId: registrationId,
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}

// In MaterialApp
MaterialApp(
  onGenerateRoute: AppRouter.generateRoute,
  // ...
);
```

---

## 📦 Summary

### **Route Constants:**
- ✅ `RegistrationRoutes` class with all route names
- ✅ Helper methods for route/step conversion
- ✅ Route validation

### **Exit Confirmation:**
- ✅ Dialog with auto-save on exit
- ✅ "Stay" vs "Exit" options
- ✅ Only shown on Screen 1

### **Back Button Handling:**
- ✅ Screen 1: Exit confirmation
- ✅ Screen 2-5: Simple pop
- ✅ Screen 5: Disabled during loading

### **Success Navigation:**
- ✅ Replace entire stack with dashboard
- ✅ Pass registrationId as argument
- ✅ Clear all registration routes

---

**Implementation Status:**
- ✅ Route constants (RegistrationRoutes)
- ✅ Exit confirmation dialog
- ✅ Resume dialog navigation
- ✅ Navigation patterns documented
- ⏳ UI screens (not started)
- ⏳ Route registration in main app (not started)
