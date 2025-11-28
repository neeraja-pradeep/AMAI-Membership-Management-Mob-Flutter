# Backend Integration Plan - 3-Step Registration

## Overview
Restructuring the app to match the backend's 3-step registration flow.

## Backend Requirements

### Step 1: Membership Registration
**Endpoint:** `POST /api/membership/register/`

**Required Fields:**
- `email` (string) - User's email
- `password` (string) - Account password
- `phone` (string) - Primary phone number
- `wa_phone` (string) - WhatsApp phone number
- `first_name` (string) - First name
- `last_name` (string) - Last name
- `membership_type` (enum) - student | practitioner | house_surgeon | honorary
- `blood_group` (string) - Blood group
- `bams_start_year` (number) - BAMS start year
- `institution_name` (string) - Institution name

**Returns:** Application ID

---

### Step 2: Address Information
**Endpoint:** `POST /api/accounts/addresses/`

**Required Fields:**
- `address_line1` (string) - House No. / Building Name
- `address_line2` (string) - Street / Locality / Area
- `city` (string) - Post Office
- `postal_code` (string) - Post Code
- `country` (string) - Country
- `state` (string) - State
- `district` (string) - District
- `is_primary` (boolean) - Is primary address

---

### Step 3: Document Upload
**Endpoint:** `POST /api/membership/application-documents/`

**Required Fields:**
- `application` (string) - Application ID from Step 1
- `document_file` (file) - Document file (multipart)
- `document_type` (string) - Type of document

---

## Current vs New Structure

### Current (5 Steps):
1. Personal Details (name, email, phone, DOB, gender)
2. Professional Details (medical council, qualification, experience)
3. Address Details
4. Document Uploads
5. Payment

### New (3 Steps + Payment):
1. **Membership Form** - All personal + membership info
2. **Address Form** - Address details
3. **Documents Form** - Upload required documents
4. **Payment** - Payment processing

---

## Implementation Steps

### 1. Update Entities ✓
- Add `password` field
- Add `wa_phone` field
- Add `membership_type` field
- Add `blood_group` field
- Add `bams_start_year` field
- Remove/consolidate professional details

### 2. Create New Registration Screens
- `membership_form_screen.dart` - Step 1
- `address_form_screen.dart` - Step 2 (reuse existing with modifications)
- `documents_form_screen.dart` - Step 3 (reuse existing)
- Update `payment_screen.dart` - Step 4

### 3. Update Repository
- Implement 3-step submission:
  1. Submit membership → get application_id
  2. Submit address with user session
  3. Upload documents with application_id
- Update state management

### 4. Update Routing
- Remove old 5-step routes
- Add new 3-step routes
- Update navigation flow

### 5. Update State Management
- Update `RegistrationState` to track application_id
- Update notifier methods
- Handle multi-step submission

---

## Fields Mapping

### Old → New

**Keep:**
- first_name, last_name ✓
- email ✓
- phone ✓
- address_line1, address_line2 ✓
- city, postal_code (was pincode) ✓
- country, state, district ✓

**Add:**
- password (new)
- wa_phone (new)
- membership_type (new)
- blood_group (new)
- bams_start_year (new)
- institution_name (new)
- is_primary (new)

**Remove/Consolidate:**
- date_of_birth (not required by backend)
- gender (not required by backend)
- professional_details (combine with membership)
- profile_image (not required initially)

---

## Status
🔄 In Progress - Updating entities and screens
