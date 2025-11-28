# Registration Validation Requirements

## Overview

This document details the validation requirements for the practitioner registration module, focusing on multi-step validation and dependent dropdown validation.

---

## 🔍 Multi-Step Validation (Current + All Previous Screens)

### **Requirement:**
When validating any step, the system MUST validate:
1. **Current step** - All required fields completed
2. **All previous steps** - All previous steps remain valid

### **Why This Matters:**

1. **Data Integrity:** Ensures no data corruption as user progresses
2. **Consistency:** User cannot proceed if earlier steps become invalid
3. **User Experience:** Clear error messages if previous steps need correction
4. **Backend Validation:** Ensures complete data when final submission occurs

### **Implementation:**

#### **1. Validation in Domain Entity:**

```dart
// In PractitionerRegistration entity
bool get canProceedToNext {
  // Current step must be complete
  if (!isStepComplete(currentStep)) return false;

  // REQUIREMENT: Validate all previous steps
  return arePreviousStepsValid();
}

bool arePreviousStepsValid() {
  switch (currentStep) {
    case RegistrationStep.personalDetails:
      // No previous steps
      return true;

    case RegistrationStep.professionalDetails:
      // Must have valid personal details
      return personalDetails?.isComplete ?? false;

    case RegistrationStep.addressDetails:
      // Must have valid personal + professional details
      return (personalDetails?.isComplete ?? false) &&
          (professionalDetails?.isComplete ?? false);

    case RegistrationStep.documentUploads:
      // Must have valid personal + professional + address details
      return (personalDetails?.isComplete ?? false) &&
          (professionalDetails?.isComplete ?? false) &&
          (addressDetails?.isComplete ?? false);

    case RegistrationStep.payment:
      // Must have all previous steps valid
      return (personalDetails?.isComplete ?? false) &&
          (professionalDetails?.isComplete ?? false) &&
          (addressDetails?.isComplete ?? false) &&
          (documentUploads?.isComplete ?? false);
  }
}
```

#### **2. Usage in State Notifier:**

```dart
// In RegistrationStateNotifier.goToNextStep()
Future<void> goToNextStep() async {
  final current = state;
  if (current is! RegistrationStateInProgress) return;

  final registration = current.registration;

  // MULTI-STEP VALIDATION
  if (!registration.canProceedToNext) {
    // Check if current step is incomplete
    if (!registration.isStepComplete(registration.currentStep)) {
      state = RegistrationStateValidationError(
        message: 'Please complete all required fields',
        currentRegistration: registration,
      );
      return;
    }

    // Previous steps are invalid
    state = RegistrationStateValidationError(
      message: 'Previous registration steps are incomplete. Please review earlier screens',
      currentRegistration: registration,
    );
    return;
  }

  // Auto-save and proceed
  await autoSaveProgress();
  final nextStep = registration.currentStep.next;
  // ... proceed to next step
}
```

### **Validation Flow Diagram:**

```
┌─────────────────────────────────────────────────────────────┐
│  User on Step 3 (Address Details) → Clicks "Next"          │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────────┐
│  VALIDATION SEQUENCE                                         │
│                                                              │
│  1. Check Step 3 complete?                                  │
│     ├─> addressDetails.isComplete == true? ✅               │
│     └─> If false → Show "Complete all required fields"      │
│                                                              │
│  2. Check Step 1 (Personal) still valid?                    │
│     ├─> personalDetails.isComplete == true? ✅              │
│     └─> If false → Show "Review earlier screens"            │
│                                                              │
│  3. Check Step 2 (Professional) still valid?                │
│     ├─> professionalDetails.isComplete == true? ✅          │
│     └─> If false → Show "Review earlier screens"            │
│                                                              │
│  4. All validations passed → Proceed to Step 4              │
└─────────────────────────────────────────────────────────────┘
```

### **Edge Case: User Edits Earlier Screen:**

```
┌─────────────────────────────────────────────────────────────┐
│  User on Step 4 → Clicks "Back" → Goes to Step 2           │
│  User edits professional details → Deletes council number   │
│  User clicks "Next" → Try to go to Step 3                  │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────────┐
│  VALIDATION FAILS                                            │
│                                                              │
│  Step 2 (Professional) validation:                          │
│  ├─> councilNumber.isEmpty → INVALID                        │
│  └─> professionalDetails.isComplete == false                │
│                                                              │
│  Cannot proceed to Step 3                                    │
│  Show error: "Please complete all required fields"          │
└─────────────────────────────────────────────────────────────┘
                     │
                     │ User re-enters council number
                     ↓
┌─────────────────────────────────────────────────────────────┐
│  VALIDATION PASSES                                           │
│  ├─> Step 2 complete ✅                                     │
│  ├─> Step 1 still valid ✅                                  │
│  └─> Can proceed to Step 3                                  │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔗 Dependent Dropdowns (Always Validate Parent First)

### **Requirement:**
For dependent dropdown hierarchies (Country → State → District), the system MUST:
1. **Validate parent selection** before allowing child selection
2. **Clear child selections** when parent changes
3. **Prevent invalid states** where child is selected without parent

### **Dropdown Hierarchy:**

```
Country (Root - no parent)
   ↓
State (Depends on Country)
   ↓
District (Depends on State)
```

### **Implementation:**

#### **1. Address Details Entity with IDs:**

```dart
class AddressDetails {
  final String countryId;   // Parent selection (root)
  final String stateId;     // Depends on countryId
  final String districtId;  // Depends on stateId

  // Validate dependent dropdown hierarchy
  bool validateDependentDropdowns() {
    // Country must be selected (no parent)
    if (countryId.isEmpty) return false;

    // State requires country to be selected
    if (stateId.isNotEmpty && countryId.isEmpty) return false;

    // District requires state to be selected
    if (districtId.isNotEmpty && stateId.isEmpty) return false;

    return true;
  }

  // Clear dependent dropdowns when parent changes
  AddressDetails clearDependentDropdowns(String changedField) {
    switch (changedField) {
      case 'country':
        // Country changed - clear state and district
        return copyWith(stateId: '', districtId: '');

      case 'state':
        // State changed - clear district
        return copyWith(districtId: '');

      default:
        return this;
    }
  }
}
```

#### **2. UI Screen Logic:**

```dart
// In AddressDetailsScreen

// Country dropdown changed
void onCountryChanged(String newCountryId) {
  // REQUIREMENT: Clear dependent dropdowns
  final updatedAddress = currentAddress
      .copyWith(countryId: newCountryId)
      .clearDependentDropdowns('country');  // Clears state + district

  // Fetch states for new country
  ref.read(addressStatesProvider.notifier).fetchStates(countryId: newCountryId);

  // Update state
  updateAddressDetails(updatedAddress);
}

// State dropdown changed
void onStateChanged(String newStateId) {
  // REQUIREMENT: Validate parent selection first
  if (currentAddress.countryId.isEmpty) {
    // PREVENT state selection without country
    showError('Please select a country first');
    return;
  }

  // REQUIREMENT: Clear dependent dropdowns
  final updatedAddress = currentAddress
      .copyWith(stateId: newStateId)
      .clearDependentDropdowns('state');  // Clears district

  // Fetch districts for new state
  ref.read(addressDistrictsProvider.notifier).fetchDistricts(stateId: newStateId);

  // Update state
  updateAddressDetails(updatedAddress);
}

// District dropdown changed
void onDistrictChanged(String newDistrictId) {
  // REQUIREMENT: Validate parent selections first
  if (currentAddress.countryId.isEmpty) {
    showError('Please select a country first');
    return;
  }

  if (currentAddress.stateId.isEmpty) {
    showError('Please select a state first');
    return;
  }

  // Update district
  final updatedAddress = currentAddress.copyWith(districtId: newDistrictId);
  updateAddressDetails(updatedAddress);
}
```

#### **3. UI Widget State:**

```dart
// Dropdown widgets with parent validation

// State dropdown
DropdownButton<String>(
  items: states,
  onChanged: currentAddress.countryId.isEmpty
      ? null  // DISABLED if no country selected
      : onStateChanged,
  hint: currentAddress.countryId.isEmpty
      ? Text('Select country first')
      : Text('Select state'),
)

// District dropdown
DropdownButton<String>(
  items: districts,
  onChanged: currentAddress.stateId.isEmpty
      ? null  // DISABLED if no state selected
      : onDistrictChanged,
  hint: currentAddress.stateId.isEmpty
      ? Text('Select state first')
      : Text('Select district'),
)
```

### **Dependent Dropdown Flow:**

```
┌─────────────────────────────────────────────────────────────┐
│  STEP 1: User selects Country                               │
│  ├─> countryId = "IN" (India)                               │
│  ├─> Fetch states for countryId="IN"                        │
│  ├─> State dropdown: ENABLED                                │
│  └─> District dropdown: DISABLED (no state selected)        │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────────┐
│  STEP 2: User selects State                                 │
│  ├─> Validate: countryId.isNotEmpty? ✅                     │
│  ├─> stateId = "KA" (Karnataka)                             │
│  ├─> Fetch districts for stateId="KA"                       │
│  └─> District dropdown: ENABLED                             │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────────┐
│  STEP 3: User selects District                              │
│  ├─> Validate: countryId.isNotEmpty? ✅                     │
│  ├─> Validate: stateId.isNotEmpty? ✅                       │
│  ├─> districtId = "BLR" (Bangalore)                         │
│  └─> All selections valid ✅                                │
└─────────────────────────────────────────────────────────────┘
```

### **Edge Case: User Changes Country After Selecting State:**

```
┌─────────────────────────────────────────────────────────────┐
│  Initial State:                                              │
│  ├─> countryId = "IN" (India)                               │
│  ├─> stateId = "KA" (Karnataka)                             │
│  └─> districtId = "BLR" (Bangalore)                         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     │ User changes country to "US"
                     ↓
┌─────────────────────────────────────────────────────────────┐
│  Country Changed Handler:                                    │
│  ├─> countryId = "US" (United States)                       │
│  ├─> CLEAR stateId (KA no longer valid for US)             │
│  ├─> CLEAR districtId (BLR no longer valid)                │
│  ├─> Fetch states for countryId="US"                        │
│  ├─> State dropdown: ENABLED (empty selection)             │
│  └─> District dropdown: DISABLED (no state)                │
└─────────────────────────────────────────────────────────────┘
                     │
                     │ User must re-select state and district
                     ↓
┌─────────────────────────────────────────────────────────────┐
│  Final State:                                                │
│  ├─> countryId = "US"                                       │
│  ├─> stateId = "CA" (California)                            │
│  └─> districtId = "LA" (Los Angeles)                        │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 Validation Rules Summary

### **Multi-Step Validation:**

| Current Step | Validation Requirements |
|-------------|------------------------|
| Step 1: Personal Details | Current step complete |
| Step 2: Professional Details | Current + Step 1 valid |
| Step 3: Address Details | Current + Steps 1-2 valid |
| Step 4: Document Uploads | Current + Steps 1-3 valid |
| Step 5: Payment | All previous steps valid |

### **Dependent Dropdown Validation:**

| Dropdown | Parent Dependency | Validation |
|----------|------------------|-----------|
| Country | None (root) | Always enabled |
| State | Requires `countryId` | Disabled if `countryId` empty |
| District | Requires `stateId` | Disabled if `stateId` empty |

### **Cascade Clear Rules:**

| Parent Changes | Children Cleared |
|---------------|-----------------|
| Country changes | State + District |
| State changes | District only |
| District changes | None (leaf node) |

---

## 🧪 Testing Checklist

### **Multi-Step Validation:**

- [ ] **Forward Navigation:**
  - [ ] Step 1 → Step 2: Validates Step 1 complete
  - [ ] Step 2 → Step 3: Validates Steps 1-2 complete
  - [ ] Step 3 → Step 4: Validates Steps 1-3 complete
  - [ ] Step 4 → Step 5: Validates Steps 1-4 complete

- [ ] **Backward Editing:**
  - [ ] User on Step 4 → Go back to Step 2 → Delete required field → Try to proceed
  - [ ] Verify: Shows validation error
  - [ ] Verify: Cannot proceed until field re-entered

- [ ] **App Restart:**
  - [ ] Fill Steps 1-3 → Restart app → Resume → Try to proceed from Step 3
  - [ ] Verify: All previous steps still validated

### **Dependent Dropdown Validation:**

- [ ] **Parent Validation:**
  - [ ] Try to select State without Country → Verify dropdown disabled
  - [ ] Try to select District without State → Verify dropdown disabled

- [ ] **Cascade Clear:**
  - [ ] Select Country → State → District → Change Country
  - [ ] Verify: State and District cleared
  - [ ] Select State → District → Change State
  - [ ] Verify: District cleared

- [ ] **Data Integrity:**
  - [ ] Select Country="India", State="Karnataka", District="Bangalore"
  - [ ] Change Country to "US"
  - [ ] Verify: Cannot submit with stale Karnataka/Bangalore data

### **Error Messages:**

- [ ] Current step incomplete → "Please complete all required fields"
- [ ] Previous steps invalid → "Previous registration steps are incomplete. Please review earlier screens"
- [ ] State selected without Country → "Please select a country first"
- [ ] District selected without State → "Please select a state first"

---

## 🚨 Common Pitfalls

### **1. Don't Skip Multi-Step Validation:**

```dart
// ❌ WRONG - Only validates current step
if (registration.isStepComplete(currentStep)) {
  // Proceed without checking previous steps
  goToNextStep();
}

// ✅ CORRECT - Validates current + all previous
if (registration.canProceedToNext) {
  // Ensures current AND all previous steps valid
  goToNextStep();
}
```

### **2. Don't Allow Child Selection Without Parent:**

```dart
// ❌ WRONG - State dropdown always enabled
DropdownButton<String>(
  items: states,
  onChanged: onStateChanged,  // No parent check!
)

// ✅ CORRECT - State dropdown disabled without country
DropdownButton<String>(
  items: states,
  onChanged: address.countryId.isEmpty
      ? null  // DISABLED
      : onStateChanged,
)
```

### **3. Don't Forget to Clear Children When Parent Changes:**

```dart
// ❌ WRONG - Stale state data remains when country changes
void onCountryChanged(String newCountryId) {
  updateAddress(address.copyWith(countryId: newCountryId));
  // State still has old country's state!
}

// ✅ CORRECT - Clear dependent dropdowns
void onCountryChanged(String newCountryId) {
  final updated = address
      .copyWith(countryId: newCountryId)
      .clearDependentDropdowns('country');  // Clears state + district
  updateAddress(updated);
}
```

---

## 📚 Related Documentation

- **REGISTRATION_ERROR_HANDLING.md** - Validation error handling patterns
- **REGISTRATION_EDGE_CASES.md** - Edge case handling for dependent dropdowns
- **REGISTRATION_MODULE.md** - Overall architecture

---

**Last Updated:** 2025-11-28
**Status:** ✅ Implemented and Documented
