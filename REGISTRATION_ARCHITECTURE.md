# Registration Architecture - Auth Module Integration

## Overview
Registration functionality is integrated within the Auth feature module (`lib/features/auth/`) as practitioner registration is part of the authentication flow. All routing is centralized in `lib/app/router/app_router.dart`.

---

## 📁 Updated File Structure

```
lib/
├── app/
│   └── router/
│       └── app_router.dart                 # ALL routing (auth + registration)
│
└── features/
    └── auth/
        ├── domain/
        │   └── entities/
        │       ├── user.dart
        │       ├── session.dart
        │       ├── user_role.dart
        │       └── registration/           # Registration entities
        │           ├── personal_details.dart
        │           ├── professional_details.dart
        │           ├── address_details.dart
        │           ├── document_upload.dart
        │           ├── practitioner_registration.dart
        │           └── registration_step.dart
        │
        ├── application/
        │   ├── states/
        │   │   ├── auth_state.dart
        │   │   └── registration_state.dart
        │   ├── notifiers/
        │   │   └── registration_state_notifier.dart
        │   ├── usecases/
        │   │   ├── login_usecase.dart
        │   │   └── ...
        │   └── providers/
        │       └── auth_provider.dart
        │
        ├── infrastructure/
        │   ├── data_sources/
        │   │   ├── local/
        │   │   │   ├── auth_local_ds.dart
        │   │   │   └── registration_local_ds.dart
        │   │   └── remote/
        │   │       └── auth_api.dart
        │   ├── models/
        │   │   └── ...
        │   └── repositories/
        │       └── ...
        │
        └── presentation/
            ├── screens/
            │   ├── login_screen.dart
            │   └── (registration screens will go here)
            ├── widgets/
            │   ├── exit_confirmation_dialog.dart
            │   ├── resume_registration_dialog.dart
            │   └── ...
            └── components/
                └── ...
```

---

## 🛣️ Routing (AppRouter)

All routes are now defined in `lib/app/router/app_router.dart`:

### **Route Constants:**

```dart
// Auth routes
AppRouter.login = '/login'
AppRouter.register = '/register'

// Registration flow routes (part of auth)
AppRouter.registrationPersonal = '/registration/personal'
AppRouter.registrationProfessional = '/registration/professional'
AppRouter.registrationAddress = '/registration/address'
AppRouter.registrationDocuments = '/registration/documents'
AppRouter.registrationPayment = '/registration/payment'
AppRouter.registrationSuccess = '/registration/success'

// Dashboard
AppRouter.dashboard = '/dashboard'
AppRouter.home = '/home'
```

### **Helper Methods:**

```dart
// Get route by step number
AppRouter.getRouteByStep(1) // → '/registration/personal'
AppRouter.getRouteByStep(5) // → '/registration/payment'

// Get step from route
AppRouter.getStepFromRoute('/registration/personal') // → 1

// Check if registration route
AppRouter.isRegistrationRoute('/registration/personal') // → true
```

### **Usage in MaterialApp:**

```dart
MaterialApp(
  onGenerateRoute: AppRouter.generateRoute,
  // ...
)
```

---

## 📦 Import Paths

### **Old Paths (DEPRECATED):**
```dart
// ❌ OLD - Do NOT use
import 'package:app/features/registration/domain/entities/...';
import 'package:app/features/registration/presentation/routes/registration_routes.dart';
```

### **New Paths (CORRECT):**

```dart
// ✅ Registration entities
import 'package:app/features/auth/domain/entities/registration/personal_details.dart';
import 'package:app/features/auth/domain/entities/registration/practitioner_registration.dart';
import 'package:app/features/auth/domain/entities/registration/registration_step.dart';

// ✅ Registration state management
import 'package:app/features/auth/application/states/registration_state.dart';
import 'package:app/features/auth/application/notifiers/registration_state_notifier.dart';

// ✅ Registration data sources
import 'package:app/features/auth/infrastructure/data_sources/local/registration_local_ds.dart';

// ✅ Registration widgets
import 'package:app/features/auth/presentation/widgets/resume_registration_dialog.dart';
import 'package:app/features/auth/presentation/widgets/exit_confirmation_dialog.dart';

// ✅ Routing (use AppRouter instead of RegistrationRoutes)
import 'package:app/lib/app/router/app_router.dart';
```

---

## 🔄 Migration Guide

### **1. Update Route References:**

**Before:**
```dart
import '../routes/registration_routes.dart';

Navigator.pushNamed(context, RegistrationRoutes.personal);
```

**After:**
```dart
import '../../../../app/router/app_router.dart';

Navigator.pushNamed(context, AppRouter.registrationPersonal);
```

### **2. Update Entity Imports:**

**Before:**
```dart
import '../../domain/entities/personal_details.dart';
import '../../domain/entities/practitioner_registration.dart';
```

**After:**
```dart
import '../../domain/entities/registration/personal_details.dart';
import '../../domain/entities/registration/practitioner_registration.dart';
```

### **3. Update State Management Imports:**

**Before:**
```dart
import '../../features/registration/application/notifiers/registration_state_notifier.dart';
```

**After:**
```dart
import '../../features/auth/application/notifiers/registration_state_notifier.dart';
```

---

## 📚 Documentation Files

### **Updated Documentation:**

1. **FORM_CACHING_SCENARIOS.md**
   - All 5 caching scenarios (unchanged logic)
   - Updated file paths
   - Updated import examples

2. **STATE_MANAGEMENT_INTEGRATION.md**
   - State management patterns (unchanged logic)
   - Updated file paths
   - Updated import examples
   - Updated route references to use `AppRouter`

3. **REGISTRATION_NAVIGATION.md**
   - Navigation patterns (unchanged logic)
   - Updated to use `AppRouter` instead of `RegistrationRoutes`
   - Updated import examples

4. **REGISTRATION_ARCHITECTURE.md** (NEW)
   - This file
   - Complete overview of new structure
   - Migration guide

---

## 🎯 Key Changes Summary

| Aspect | Old Location | New Location |
|--------|-------------|--------------|
| **Entities** | `lib/features/registration/domain/entities/` | `lib/features/auth/domain/entities/registration/` |
| **State** | `lib/features/registration/application/states/` | `lib/features/auth/application/states/` |
| **Notifiers** | `lib/features/registration/application/notifiers/` | `lib/features/auth/application/notifiers/` |
| **Data Sources** | `lib/features/registration/infrastructure/data_sources/` | `lib/features/auth/infrastructure/data_sources/` |
| **Widgets** | `lib/features/registration/presentation/widgets/` | `lib/features/auth/presentation/widgets/` |
| **Routes** | `lib/features/registration/presentation/routes/` | `lib/app/router/app_router.dart` |

---

## ✅ Migration Checklist

- [x] Move registration entities to `lib/features/auth/domain/entities/registration/`
- [x] Move registration state to `lib/features/auth/application/states/`
- [x] Move registration notifier to `lib/features/auth/application/notifiers/`
- [x] Move registration data source to `lib/features/auth/infrastructure/data_sources/local/`
- [x] Move registration widgets to `lib/features/auth/presentation/widgets/`
- [x] Delete old `lib/features/registration/` directory
- [x] Create centralized `lib/app/router/app_router.dart`
- [x] Update all imports in moved files
- [x] Update route references from `RegistrationRoutes` to `AppRouter`
- [ ] Update UI screen imports (when screens are created)
- [ ] Update documentation with new paths

---

## 🔧 Next Steps

1. **Implement UI Screens:**
   - Create screens in `lib/features/auth/presentation/screens/`
   - Use `AppRouter` constants for navigation
   - Follow patterns in STATE_MANAGEMENT_INTEGRATION.md

2. **Update app_router.dart:**
   - Import screen widgets
   - Replace placeholder screens with real implementations

3. **Testing:**
   - Test all navigation flows
   - Test form caching scenarios
   - Test state management

---

**Rationale for Changes:**

1. **Registration as Part of Auth:**
   - Practitioner registration is part of the authentication/onboarding flow
   - Keeps related features together
   - Simplifies feature organization

2. **Centralized Routing:**
   - All app routes in one place (`app_router.dart`)
   - Easier to maintain and overview
   - Follows Flutter best practices
   - Easier to implement deep linking later

3. **Entities Subfolder:**
   - Keeps registration entities organized
   - Clear separation from auth entities (User, Session)
   - Maintains clean architecture

---

**Implementation Status:**
- ✅ File structure reorganized
- ✅ Routes centralized in AppRouter
- ✅ All imports updated
- ✅ Documentation updated
- ⏳ UI screens (not started)
- ⏳ Testing (not started)
