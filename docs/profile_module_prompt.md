Profile Module - Enterprise Flutter Implementation Prompt
Module Overview
Module Name: Profile Description: Comprehensive user profile management screen with conditional UI based on membership type (Practitioner, House Surgeon, Student). Displays user information, membership details, and provides access to edit various profile sections including personal information, addresses, academic details, professional details, and ASWAS Plus nominee information. Entry Point: 4th icon in Bottom Navigation Bar (Profile icon) User Types:
Practitioner - Full access to all profile sections
House Surgeon - Access to Personal Information, Saved Addresses, Professional Details
Student - Access to Personal Information, Saved Addresses only
Sub-screens:
Profile Screen (main - conditional UI based on membership_type)
Edit Personal Information Screen
Edit Saved Addresses Screen
Edit Academic Details Screen (Practitioner only)
Edit Professional Details Screen (Practitioner, House Surgeon)
Edit Nominee Details Screen (Practitioner only)
Privacy & Security Screen (static for now)
Help & Support Screen (static for now)
Terms & Policies Screen (static for now)
Phase 1: Domain Layer
Prompt: Profile Domain Entities - Core
Implement the Profile domain layer core entities.

**Files to create:**

1. `lib/features/profile/domain/entities/membership_type.dart`
   - MembershipType enum using Freezed or standard Dart enum
   - Values: practitioner, houseSurgeon, student
   - Factory: fromString(String value) to parse API response
   - Getter: String get displayName
   - No JSON serialization (domain layer is pure)

2. `lib/features/profile/domain/entities/membership_info.dart`
   - MembershipInfo entity using Freezed
   - Fields: id (int), membershipNumber (String), membershipType (MembershipType), status (String), validUntil (DateTime), startDate (DateTime), autoRenewal (bool), isHonorary (bool), feeWaived (bool), subscriptionFee (double?), professionalDetails (List<String>), academicDetails (List<String>), medicalCouncilState (String?), medicalCouncilNo (String?), centralCouncilNo (String?), ugCollege (String?)
   - Getter: bool get isActive => status == 'active'
   - Getter: bool get isExpired => validUntil.isBefore(DateTime.now())
   - Getter: String get formattedValidUntil

3. `lib/features/profile/domain/entities/user_info.dart`
   - UserInfo entity using Freezed
   - Fields: id (int), email (String), phone (String), firstName (String), lastName (String?), dateOfBirth (DateTime?), gender (String?), profilePicture (String?), profilePicturePath (String?), isActive (bool), isVerified (bool), bloodGroup (String?), parentName (String?), maritalStatus (String?)
   - Getter: String get fullName
   - Getter: String get displayName (firstName or fullName)
   - Getter: bool get hasProfilePicture

4. `lib/features/profile/domain/entities/user_address.dart`
   - UserAddress entity using Freezed
   - Fields: id (int), addressLine1 (String), addressLine2 (String?), city (String), district (String), state (String), postalCode (String), country (String), type (String?), latitude (double?), longitude (double?)
   - Getter: String get formattedAddress (multi-line)
   - Getter: String get shortAddress (single line)
   - Getter: bool get isAptaAddress => type == 'apta'
   - Getter: bool get isCommunicationsAddress => type == 'communications'
   - Getter: bool get isPermanentAddress => type == 'permanent' || type == null

5. `lib/features/profile/domain/entities/user_document.dart`
   - UserDocument entity using Freezed
   - Fields: id (int), documentType (String), documentName (String), documentUrl (String), path (String), fileSize (int), mimeType (String), verificationStatus (String), verifiedAt (DateTime?), uploadedAt (DateTime)
   - Getter: bool get isVerified => verificationStatus == 'verified'
   - Getter: bool get isPending => verificationStatus == 'pending'
   - Getter: bool get isPhoto => documentType == 'photo'

6. `lib/features/profile/domain/entities/profile_update_request.dart`
   - ProfileUpdateRequest entity using Freezed
   - Fields: id (int), profileData (Map<String, dynamic>?), insuranceData (Map<String, dynamic>?), notes (String), isVerified (bool), createdAt (DateTime), approvedBy (String?)
   - Getter: bool get isPending => !isVerified
   - Getter: bool get isApproved => isVerified

**Requirements:**
- Domain entities have no dependencies on external packages except Freezed
- Use fpdart Either for error handling where applicable
- Entities are immutable
- MembershipType enum is the key discriminator for conditional UI
Prompt: Profile Domain Entities - Aggregate and Repository
Implement the Profile domain layer aggregate entity and repository.

**Files to create:**

1. `lib/features/profile/domain/entities/profile_data.dart`
   - ProfileData aggregate entity using Freezed
   - Fields: membershipInfo (MembershipInfo), userInfo (UserInfo), addresses (List<UserAddress>), documents (List<UserDocument>), profileUpdates (List<ProfileUpdateRequest>), timestamp (String)
   - Factory: ProfileData.empty() for initial/loading state
   - Getter: MembershipType get membershipType => membershipInfo.membershipType
   - Getter: bool get isPractitioner => membershipType == MembershipType.practitioner
   - Getter: bool get isHouseSurgeon => membershipType == MembershipType.houseSurgeon
   - Getter: bool get isStudent => membershipType == MembershipType.student
   - Getter: UserAddress? get primaryAddress (first address or null)
   - Getter: UserAddress? get aptaAddress
   - Getter: UserAddress? get communicationsAddress
   - Getter: UserDocument? get profilePhoto
   - Getter: bool get hasPendingUpdates

2. `lib/features/profile/domain/entities/dropdown_options.dart`
   - DropdownOptions entity using Freezed
   - Fields: bloodGroups (List<DropdownOption>), genders (List<DropdownOption>), states (List<DropdownOption>), countries (List<DropdownOption>), relations (List<DropdownOption>), academicTypes (List<DropdownOption>), professionalTypes (List<DropdownOption>), timestamp (String)
   - Reuse DropdownOption from shared entities or create here

3. `lib/features/profile/domain/entities/personal_info_form.dart`
   - PersonalInfoForm entity using Freezed
   - Fields: firstName (String), lastName (String?), email (String), phone (String), whatsappNumber (String?), whatsappSameAsPhone (bool), dateOfBirth (DateTime?), gender (String?), aptaMagazineType (String?), bloodGroup (String?)
   - Factory: fromUserInfo(UserInfo) to pre-populate form
   - Getter: bool get isValid
   - Method: Map<String, dynamic> toProfileData()

4. `lib/features/profile/domain/entities/address_form.dart`
   - AddressForm entity using Freezed
   - Fields: addressLine1 (String), addressLine2 (String?), city (String), postOffice (String), postalCode (String), country (String), state (String), district (String), isAptaMailing (bool), isPermanent (bool)
   - Factory: fromUserAddress(UserAddress) to pre-populate form
   - Getter: bool get isValid

5. `lib/features/profile/domain/entities/academic_details_form.dart`
   - AcademicDetailsForm entity using Freezed
   - Fields: ug (bool), pg (bool), phd (bool), ccras (bool), pgDiploma (bool), other (bool)
   - Factory: fromAcademicDetails(List<String>) to pre-populate
   - Getter: List<String> get selectedTypes
   - Method: Map<String, dynamic> toProfileData()

6. `lib/features/profile/domain/entities/professional_details_form.dart`
   - ProfessionalDetailsForm entity using Freezed
   - Fields: researcher (bool), pgScholar (bool), pgDiplomaScholar (bool), deptOfIsm (bool), deptOfNam (bool), deptOfNhm (bool), aidedCollege (bool), govtCollege (bool), pvtCollege (bool), pvtSectorCollege (bool), retd (bool), pvtPractice (bool), manufacturer (bool), militaryService (bool), centralGovt (bool), esi (bool), other (bool), medicalCouncilState (String?), medicalCouncilNo (String?), centralCouncilNo (String?), ugCollege (String?)
   - Factory: fromProfessionalDetails(List<String>, MembershipInfo) to pre-populate
   - Getter: List<String> get selectedTypes
   - Method: Map<String, dynamic> toProfileData()

7. `lib/features/profile/domain/entities/nominee_details_form.dart`
   - NomineeDetailsForm entity using Freezed
   - Fields: name (String), relation (String), contact (String)
   - Factory: NomineeDetailsForm.empty()
   - Getter: bool get isValid
   - Method: Map<String, dynamic> toInsuranceData()

8. `lib/features/profile/domain/repositories/profile_repository.dart`
   - Abstract class: ProfileRepository
   - Methods (all return Future<Either<Failure, T>>):
     - getProfileData({required String ifModifiedSince}) -> ProfileData?
     - getDropdownOptions({required String ifModifiedSince}) -> DropdownOptions?
     - updatePersonalInfo({required PersonalInfoForm form, required String xcsrfToken}) -> UpdateResult
     - updateAddress({required int addressId, required AddressForm form, required String xcsrfToken}) -> UpdateResult
     - updateAcademicDetails({required AcademicDetailsForm form, required String xcsrfToken}) -> UpdateResult
     - updateProfessionalDetails({required ProfessionalDetailsForm form, required String xcsrfToken}) -> UpdateResult
     - updateNomineeDetails({required NomineeDetailsForm form, required String xcsrfToken}) -> UpdateResult
     - Future<String?> getStoredTimestamp(String key)
     - Future<void> storeTimestamp(String key, String timestamp)
     - Future<ProfileData?> getCachedProfileData()
     - Future<DropdownOptions?> getCachedDropdownOptions()

9. `lib/features/profile/domain/entities/update_result.dart`
   - UpdateResult entity using Freezed
   - Fields: id (int), message (String), status (String)
   - Getter: bool get isPending => status == 'pending'
   - Getter: bool get isApproved => status == 'approved'

**Requirements:**
- Repository is abstract (contract only)
- Use fpdart Either for error handling
- Entities are immutable
- Form entities support pre-population from existing data
- Handle 304 Not Modified scenario in repository contract

Phase 2: Infrastructure Layer
Prompt: Profile Infrastructure - Models (Part 1)
Implement the Profile infrastructure models - Part 1.

**Files to create:**

1. `lib/features/profile/infrastructure/models/membership_info_model.dart`
   - MembershipInfoModel with JSON serialization
   - Factory: fromJson, toJson
   - Method: toDomain() -> MembershipInfo
   - Handle date parsing, nullable fields
   - Map membership_type string to enum
   - Use json_serializable

2. `lib/features/profile/infrastructure/models/user_info_model.dart`
   - UserInfoModel with JSON serialization
   - Factory: fromJson, toJson
   - Method: toDomain() -> UserInfo
   - Handle all nullable fields properly

3. `lib/features/profile/infrastructure/models/user_address_model.dart`
   - UserAddressModel with JSON serialization
   - Factory: fromJson, toJson
   - Method: toDomain() -> UserAddress
   - Handle nullable coordinates and type

4. `lib/features/profile/infrastructure/models/user_document_model.dart`
   - UserDocumentModel with JSON serialization
   - Factory: fromJson, toJson
   - Method: toDomain() -> UserDocument
   - Handle nullable verification fields

5. `lib/features/profile/infrastructure/models/profile_update_request_model.dart`
   - ProfileUpdateRequestModel with JSON serialization
   - Factory: fromJson, toJson
   - Method: toDomain() -> ProfileUpdateRequest
   - Handle nested user and approved_by objects

6. `lib/features/profile/infrastructure/models/profile_data_model.dart`
   - ProfileDataModel aggregate with JSON serialization
   - Contains all above models
   - Method: toDomain() -> ProfileData
   - Handle complex nested structure from API response

**Requirements:**
- Models handle null safety for optional fields
- Date parsing must handle ISO8601 format
- All models are separate from domain entities
- Use json_serializable annotations
- Handle complex API response structure
Prompt: Profile Infrastructure - Models (Part 2)
Implement the Profile infrastructure models - Part 2.

**Files to create:**

1. `lib/features/profile/infrastructure/models/dropdown_options_model.dart`
   - DropdownOptionsModel with JSON serialization
   - Contains lists of DropdownOptionModel
   - Method: toDomain() -> DropdownOptions

2. `lib/features/profile/infrastructure/models/dropdown_option_model.dart`
   - DropdownOptionModel with JSON serialization
   - Fields: value, label
   - Method: toDomain() -> DropdownOption
   - Reuse from shared if already exists

3. `lib/features/profile/infrastructure/models/personal_info_request.dart`
   - PersonalInfoRequest for POST body
   - Fields matching API request structure
   - Method: toJson()
   - Factory: fromForm(PersonalInfoForm)

4. `lib/features/profile/infrastructure/models/address_request.dart`
   - AddressRequest for PUT body
   - Method: toJson()
   - Factory: fromForm(AddressForm)

5. `lib/features/profile/infrastructure/models/academic_details_request.dart`
   - AcademicDetailsRequest for POST body
   - Method: toJson()
   - Factory: fromForm(AcademicDetailsForm)

6. `lib/features/profile/infrastructure/models/professional_details_request.dart`
   - ProfessionalDetailsRequest for POST body
   - Method: toJson()
   - Factory: fromForm(ProfessionalDetailsForm)

7. `lib/features/profile/infrastructure/models/nominee_details_request.dart`
   - NomineeDetailsRequest for POST body
   - Method: toJson()
   - Factory: fromForm(NomineeDetailsForm)

8. `lib/features/profile/infrastructure/models/update_result_model.dart`
   - UpdateResultModel with JSON serialization
   - Method: toDomain() -> UpdateResult

**Requirements:**
- Request models convert domain forms to API structure
- Handle profile_data and insurance_data wrapping
- All models use json_serializable
Prompt: Profile Infrastructure - Data Sources
Implement the Profile data sources.

**Files to create:**

1. `lib/features/profile/infrastructure/data_sources/remote/profile_api.dart`
   - Abstract class: ProfileApi
   - Implementation: ProfileApiImpl
   - Constructor takes DioClient
   - Methods:
     - Future<ApiResponse<ProfileDataModel?>> fetchProfileData({required String ifModifiedSince})
       // GET /api/membership/memberships/me/
       // Returns ProfileDataModel on 200, null on 304
     - Future<ApiResponse<DropdownOptionsModel?>> fetchDropdownOptions({required String ifModifiedSince})
       // GET /api/membership/options/
     - Future<UpdateResultModel> updatePersonalInfo({required PersonalInfoRequest request, required String xcsrfToken})
       // POST /api/membership/profile-updates/
     - Future<UpdateResultModel> updateAddress({required int addressId, required AddressRequest request, required String xcsrfToken})
       // PUT /api/membership/addresses/{id}/
     - Future<UpdateResultModel> updateAcademicDetails({required AcademicDetailsRequest request, required String xcsrfToken})
       // POST /api/membership/profile-updates/
     - Future<UpdateResultModel> updateProfessionalDetails({required ProfessionalDetailsRequest request, required String xcsrfToken})
       // POST /api/membership/profile-updates/
     - Future<UpdateResultModel> updateNomineeDetails({required NomineeDetailsRequest request, required String xcsrfToken})
       // POST /api/membership/profile-updates/
   - Must pass if-modified-since header for GET requests
   - Must pass X-CSRF-Token header for POST/PUT requests
   - Must handle 304 response code without throwing error
   - Extract new timestamp from response headers on 200

2. `lib/features/profile/infrastructure/data_sources/local/profile_local_ds.dart`
   - Abstract class: ProfileLocalDataSource
   - Implementation: ProfileLocalDataSourceImpl
   - Constructor takes Hive box
   - Methods:
     - Future<void> cacheProfileData(ProfileDataModel data)
     - Future<ProfileDataModel?> getCachedProfileData()
     - Future<void> cacheDropdownOptions(DropdownOptionsModel data)
     - Future<DropdownOptionsModel?> getCachedDropdownOptions()
     - Future<void> storeTimestamp(String key, String timestamp)
     - Future<String?> getTimestamp(String key)
     - Future<void> clearCache()
   - Separate keys for profile data and dropdown options timestamps

**Requirements:**
- API must not throw on 304 - treat as valid response
- POST/PUT requests include X-CSRF-Token in headers
- Local data source uses Hive for caching
- Separate timestamps for different data types
- Handle complex nested API response parsing
Prompt: Profile Infrastructure - Repository Implementation
Implement the Profile repository.

**Files to create:**

1. `lib/features/profile/infrastructure/repositories/profile_repository_impl.dart`
   - ProfileRepositoryImpl implements ProfileRepository
   - Constructor takes: ProfileApi, ProfileLocalDataSource, ConnectivityChecker, SecureStore
   
   - Implement getProfileData:
     1. Check connectivity
     2. If online: call API with if-modified-since header
        - On 200: map to domain, cache data, store new timestamp, return Right(ProfileData)
        - On 304: return Right(null) to indicate use cached data
        - On error: return Left(Failure)
     3. If offline: return cached data or NetworkFailure
   
   - Implement getDropdownOptions:
     1. Same pattern as getProfileData
     2. Uses separate timestamp key
   
   - Implement updatePersonalInfo:
     1. Check connectivity (required - no offline support)
     2. Get XCSRF token from SecureStore
     3. Convert form to request model
     4. Call POST API with token in header
     5. Map response to domain UpdateResult
     6. Return Right(UpdateResult) or Left(Failure)
   
   - Implement updateAddress:
     1. Same pattern as updatePersonalInfo
     2. Use PUT with address ID
   
   - Implement updateAcademicDetails, updateProfessionalDetails, updateNomineeDetails:
     1. Same pattern as updatePersonalInfo
     2. Different request body structure
   
   - Implement timestamp and cache methods

**Requirements:**
- Repository handles online/offline logic
- 304 response returns null (not failure)
- All API errors mapped to typed Failures
- Caching only on 200 response for GET endpoints
- POST/PUT requests always require XCSRF token
- Updates require connectivity (no offline submission)

Phase 3: Application Layer
Prompt: Profile Application - States
Implement the Profile application states.

**Files to create:**

1. `lib/features/profile/application/states/profile_state.dart`
   - ProfileState using Freezed
   - States:
     - initial()
     - loading(ProfileData? previousData)
     - loaded(ProfileData data)
     - error(Failure failure, ProfileData? cachedData)
   - Helpers:
     - ProfileData? get currentData
     - bool get isLoading
     - bool get hasError
     - MembershipType? get membershipType
     - bool get isPractitioner
     - bool get isHouseSurgeon
     - bool get isStudent
     - UserInfo? get userInfo
     - MembershipInfo? get membershipInfo
     - List<UserAddress> get addresses

2. `lib/features/profile/application/states/dropdown_options_state.dart`
   - DropdownOptionsState using Freezed
   - States:
     - initial()
     - loading()
     - loaded(DropdownOptions options)
     - error(Failure failure, DropdownOptions? cached)
   - Helpers for accessing specific option lists

3. `lib/features/profile/application/states/personal_info_form_state.dart`
   - PersonalInfoFormState using Freezed
   - States:
     - initial()
     - editing(PersonalInfoForm form, bool isValid)
     - submitting(PersonalInfoForm form)
     - success(UpdateResult result)
     - error(Failure failure, PersonalInfoForm form)
   - Helpers:
     - PersonalInfoForm? get currentForm
     - bool get isSubmitting
     - bool get canSubmit

4. `lib/features/profile/application/states/address_form_state.dart`
   - AddressFormState using Freezed
   - Same pattern as PersonalInfoFormState

5. `lib/features/profile/application/states/academic_form_state.dart`
   - AcademicFormState using Freezed
   - Same pattern

6. `lib/features/profile/application/states/professional_form_state.dart`
   - ProfessionalFormState using Freezed
   - Same pattern

7. `lib/features/profile/application/states/nominee_form_state.dart`
   - NomineeFormState using Freezed
   - Same pattern

**Requirements:**
- States support showing cached/previous data during loading
- Form states track editing, submitting, success, error
- Helpers make UI logic simple
- Separate states for main screen and each edit screen
Prompt: Profile Application - Usecases
Implement the Profile usecases.

**Files to create:**

1. `lib/features/profile/application/usecases/fetch_profile_data_usecase.dart`
   - FetchProfileDataUsecase class
   - Takes ProfileRepository
   - call() method:
     1. Get stored timestamp (use empty string if none)
     2. Call repository.getProfileData(ifModifiedSince: timestamp)
     3. If Right(ProfileData): data was updated, return it
     4. If Right(null): 304, get cached data and return
     5. If Left(Failure): return failure
   - Returns Future<Either<Failure, ProfileData>>

2. `lib/features/profile/application/usecases/fetch_dropdown_options_usecase.dart`
   - FetchDropdownOptionsUsecase class
   - Same pattern as above

3. `lib/features/profile/application/usecases/update_personal_info_usecase.dart`
   - UpdatePersonalInfoUsecase class
   - Takes ProfileRepository
   - call({required PersonalInfoForm form}) method:
     1. Validate form
     2. If invalid: return Left(ValidationFailure)
     3. Call repository.updatePersonalInfo(form: form)
     4. Return Right(UpdateResult) or Left(Failure)

4. `lib/features/profile/application/usecases/update_address_usecase.dart`
   - UpdateAddressUsecase class
   - call({required int addressId, required AddressForm form})
   - Same pattern with validation

5. `lib/features/profile/application/usecases/update_academic_details_usecase.dart`
   - UpdateAcademicDetailsUsecase class
   - call({required AcademicDetailsForm form})

6. `lib/features/profile/application/usecases/update_professional_details_usecase.dart`
   - UpdateProfessionalDetailsUsecase class
   - call({required ProfessionalDetailsForm form})

7. `lib/features/profile/application/usecases/update_nominee_details_usecase.dart`
   - UpdateNomineeDetailsUsecase class
   - call({required NomineeDetailsForm form})

8. `lib/features/profile/application/usecases/get_cached_profile_data_usecase.dart`
   - GetCachedProfileDataUsecase class
   - For initial load before API call

**Requirements:**
- Usecases encapsulate the if-modified-since logic
- Update usecases validate before API call
- Single responsibility per usecase
- Proper error propagation
Prompt: Profile Application - Providers
Implement the Profile providers.

**Files to create:**

1. `lib/features/profile/application/providers/profile_providers.dart`
   - Provider for ProfileRepository (impl with dependencies)
   - Provider for each usecase
   - profileStateProvider: AsyncNotifierProvider<ProfileNotifier, ProfileState>
   - dropdownOptionsStateProvider: AsyncNotifierProvider<DropdownOptionsNotifier, DropdownOptionsState>
   - personalInfoFormStateProvider: StateNotifierProvider<PersonalInfoFormNotifier, PersonalInfoFormState>
   - addressFormStateProvider: StateNotifierProvider<AddressFormNotifier, AddressFormState>
   - academicFormStateProvider: StateNotifierProvider<AcademicFormNotifier, AcademicFormState>
   - professionalFormStateProvider: StateNotifierProvider<ProfessionalFormNotifier, ProfessionalFormState>
   - nomineeFormStateProvider: StateNotifierProvider<NomineeFormNotifier, NomineeFormState>

2. `lib/features/profile/application/providers/profile_notifier.dart`
   - ProfileNotifier extends AsyncNotifier<ProfileState>
   - build(): Initialize with cached data if available, then fetch fresh
   - Methods:
     - Future<void> fetchProfileData(): Standard fetch pattern
     - Future<void> refresh(): Force fetch

3. `lib/features/profile/application/providers/dropdown_options_notifier.dart`
   - DropdownOptionsNotifier extends AsyncNotifier<DropdownOptionsState>
   - Same pattern as ProfileNotifier

4. `lib/features/profile/application/providers/personal_info_form_notifier.dart`
   - PersonalInfoFormNotifier extends StateNotifier<PersonalInfoFormState>
   - Methods:
     - void initializeForm(UserInfo userInfo): Pre-populate from existing data
     - void updateField(String field, dynamic value): Update individual field
     - void updateWhatsappSameAsPhone(bool value): Handle checkbox logic
     - Future<void> submit(): Validate and submit
     - void reset(): Reset to initial state

5. `lib/features/profile/application/providers/address_form_notifier.dart`
   - AddressFormNotifier extends StateNotifier<AddressFormState>
   - Methods:
     - void initializeForm(UserAddress? address): Pre-populate or empty
     - void updateField(String field, dynamic value)
     - Future<void> submit(int? addressId): Create or update
     - void reset()

6. `lib/features/profile/application/providers/academic_form_notifier.dart`
   - AcademicFormNotifier extends StateNotifier<AcademicFormState>
   - Methods:
     - void initializeForm(List<String> existingDetails): Pre-populate
     - void toggleOption(String type, bool value): Toggle checkbox
     - Future<void> submit()
     - void reset()

7. `lib/features/profile/application/providers/professional_form_notifier.dart`
   - ProfessionalFormNotifier extends StateNotifier<ProfessionalFormState>
   - Same pattern with medical council fields

8. `lib/features/profile/application/providers/nominee_form_notifier.dart`
   - NomineeFormNotifier extends StateNotifier<NomineeFormState>
   - Methods:
     - void initializeForm(): Empty form
     - void updateField(String field, String value)
     - Future<void> submit()
     - void reset()

**Requirements:**
- Form notifiers handle initialization from existing data
- Form notifiers handle validation
- State changes are atomic
- Side effects in usecases, not notifiers

Phase 4: Presentation Layer
Prompt: Profile Presentation - Main Screen
Implement the Profile main screen with conditional UI.

**Files to create:**

1. `lib/features/profile/presentation/screens/profile_screen.dart`
   - ProfileScreen (ConsumerStatefulWidget)
   - Uses AppScaffold with custom AppBar
   - AppBar: "Profile" title (center), Notification icon (right, static)
   - No back button (bottom nav screen)
   - Triggers fetchProfileData on initState/navigation
   - Handles all states: loading, loaded, error
   - Shows cached data during loading/error
   - SingleChildScrollView with Column layout

**Screen Layout Structure (top to bottom):**
1. ProfileHeaderSection (picture, name, email)
2. PersonalInformationCard (member ID, specialization, gender, valid until, DOB)
3. EditProfileOptionsCard (conditional based on membershipType)
4. SupportPreferencesSection
5. LogoutButton (static)

**Conditional UI based on membershipType:**
- Practitioner: All edit options visible
- House Surgeon: Personal Info, Saved Addresses, Professional Details only
- Student: Personal Info, Saved Addresses only

**Navigation:**
- Edit Personal Information -> EditPersonalInfoScreen
- Saved Addresses -> EditAddressScreen
- Academic Details -> EditAcademicDetailsScreen (Practitioner only)
- Professional Details -> EditProfessionalDetailsScreen (Practitioner, House Surgeon)
- ASWAS Plus Nominee -> EditNomineeScreen (Practitioner only)
- Privacy & Security -> static screen
- Help & Support -> static screen
- Terms & Policies -> static screen

**Requirements:**
- Fully responsive using ScreenUtil
- Proper loading/error state handling
- Graceful degradation
- Conditional rendering based on membership type
- Bottom navigation compatible (4th tab)
Prompt: Profile Presentation - Header Components
Implement the Profile header and personal info components.

**Files to create:**

1. `lib/features/profile/presentation/components/profile_header_section.dart`
   - ProfileHeaderSection widget (StatelessWidget)
   - Props: userInfo (UserInfo), onEditPicture (VoidCallback, static for now)
   - Layout:
     - Profile picture (circular, with placeholder if none)
     - Edit icon overlay on picture (static)
     - User full name below picture
     - Email below name
   - Profile picture from URL or default avatar
   - Centered layout

2. `lib/features/profile/presentation/components/profile_avatar.dart`
   - ProfileAvatar widget (StatelessWidget)
   - Props: imageUrl (String?), name (String), size (double), onEditTap (VoidCallback?)
   - Circular avatar with image or initials fallback
   - Edit icon positioned at bottom-right corner
   - Network image with loading and error states

3. `lib/features/profile/presentation/components/personal_information_card.dart`
   - PersonalInformationCard widget (StatelessWidget)
   - Props: membershipInfo (MembershipInfo), userInfo (UserInfo)
   - Card design:
     - Heading: "Personal Information"
     - Member ID row
     - Specialization row (membership type display name)
     - Gender row
     - Valid Until row
     - Date of Birth row
   - Use ProfileInfoRow for consistent styling

4. `lib/features/profile/presentation/components/profile_info_row.dart`
   - ProfileInfoRow widget (StatelessWidget)
   - Props: label (String), value (String?)
   - Label on left, value on right
   - Handle null/empty values gracefully
   - Consistent styling

**Requirements:**
- Profile picture handles loading, error, and missing states
- Information displayed cleanly in card format
- All text uses theme typography
- ScreenUtil for all dimensions
Prompt: Profile Presentation - Edit Options Components
Implement the edit profile options components with conditional visibility.

**Files to create:**

1. `lib/features/profile/presentation/components/edit_profile_options_card.dart`
   - EditProfileOptionsCard widget (ConsumerWidget)
   - Props: membershipType (MembershipType)
   - Card design:
     - Heading: "Edit Profile Information"
     - List of edit options (conditional based on membership type)
   - Uses EditProfileOption for each item

2. `lib/features/profile/presentation/components/edit_profile_option.dart`
   - EditProfileOption widget (StatelessWidget)
   - Props: title (String), onTap (VoidCallback), icon (IconData?)
   - Layout:
     - Option title (left)
     - Edit/chevron icon (right)
   - InkWell for tap handling
   - Consistent row height and padding

3. `lib/features/profile/presentation/components/practitioner_edit_options.dart`
   - PractitionerEditOptions widget (StatelessWidget)
   - All options visible:
     - Personal Information
     - Saved Addresses
     - Academic Details
     - Professional Details
     - Apta Options (static)
     - ASWAS Plus Nominee
   - Passes appropriate navigation callbacks

4. `lib/features/profile/presentation/components/house_surgeon_edit_options.dart`
   - HouseSurgeonEditOptions widget (StatelessWidget)
   - Options visible:
     - Personal Information
     - Saved Addresses
     - Professional Details

5. `lib/features/profile/presentation/components/student_edit_options.dart`
   - StudentEditOptions widget (StatelessWidget)
   - Options visible:
     - Personal Information
     - Saved Addresses

**Alternative approach:**
Use single component with conditional list building based on membershipType

**Requirements:**
- Edit options conditional based on membership type
- Each option navigates to appropriate edit screen
- Consistent visual styling
- Edit icons clearly indicate tappable items
Prompt: Profile Presentation - Support Section Components
Implement the support and preferences section components.

**Files to create:**

1. `lib/features/profile/presentation/components/support_preferences_section.dart`
   - SupportPreferencesSection widget (StatelessWidget)
   - Props: navigation callbacks for each option
   - Layout:
     - Heading: "Support & Preferences"
     - Privacy & Security option
     - Help & Support option
     - Terms & Policies option
   - Each option navigates to respective screen (static for now)

2. `lib/features/profile/presentation/components/support_option_item.dart`
   - SupportOptionItem widget (StatelessWidget)
   - Props: title (String), icon (IconData), onTap (VoidCallback)
   - Similar to EditProfileOption but with leading icon
   - Consistent styling

3. `lib/features/profile/presentation/components/logout_button.dart`
   - LogoutButton widget (StatelessWidget)
   - Props: onLogout (VoidCallback)
   - Full-width or prominent button
   - Red/danger color scheme
   - Static for now (shows confirmation dialog placeholder)

4. `lib/features/profile/presentation/screens/privacy_security_screen.dart`
   - Static screen with placeholder content
   - AppBar with back button and "Privacy & Security" title
   - Body with static text about privacy

5. `lib/features/profile/presentation/screens/help_support_screen.dart`
   - Static screen with placeholder content
   - May include contact information or FAQs

6. `lib/features/profile/presentation/screens/terms_policies_screen.dart`
   - Static screen with terms and policies text
   - Scrollable content

**Requirements:**
- Support options clearly organized
- Logout button prominent but not accidentally tappable
- Static screens provide placeholder content
- Consistent navigation pattern
Prompt: Profile Presentation - Edit Personal Information Screen
Implement the Edit Personal Information screen.

**Files to create:**

1. `lib/features/profile/presentation/screens/edit_personal_info_screen.dart`
   - EditPersonalInfoScreen (ConsumerStatefulWidget)
   - Uses AppScaffold with custom AppBar
   - AppBar: Back button (left), "Personal Information" title (center)
   - Initializes form with existing user data on build
   - Fetches dropdown options on initState
   - Handles form states: editing, submitting, success, error
   - Form with validation

**Form Fields (top to bottom):**
1. Name (AppTextField, required)
2. Email (AppTextField, email validation)
3. Phone Number (AppTextField, phone validation)
4. WhatsApp Number (AppTextField)
5. Same as Phone checkbox (updates WhatsApp field)
6. Date of Birth (Date picker)
7. Gender (Dropdown)
8. Apta Magazine Type (static, display only)
9. Blood Group (Dropdown)
10. Submit button

**Form Behavior:**
- Pre-populate from existing UserInfo
- Validate on field change and submit
- Show loading during submission
- Show success message and navigate back on success
- Show error message on failure
- WhatsApp checkbox auto-fills from phone

**Requirements:**
- Form validation before submission
- Dropdown options from API
- Date picker for DOB
- Loading state during submission
- Success/error feedback
- Back navigation on success
Prompt: Profile Presentation - Edit Address Screen
Implement the Edit Saved Addresses screen.

**Files to create:**

1. `lib/features/profile/presentation/screens/edit_address_screen.dart`
   - EditAddressScreen (ConsumerStatefulWidget)
   - Uses AppScaffold with custom AppBar
   - AppBar: Back button (left), "Saved Addresses" title (center)
   - May receive existing address to edit or create new
   - Fetches dropdown options on initState
   - Handles form states

**Form Fields (top to bottom):**
1. House No. / Building Name (AppTextField, required)
2. Street / Locality / Area (AppTextField)
3. Post Office (AppTextField)
4. Post Code (AppTextField, numeric)
5. Country (Dropdown)
6. State (Dropdown)
7. District (AppTextField)
8. Apta Mailing Address (Checkbox, static for now)
9. Permanent Address (Checkbox, static for now)
10. Submit button

**Form Behavior:**
- Pre-populate if editing existing address
- Empty form if creating new
- Validate required fields
- Show loading during submission
- Success/error feedback

2. `lib/features/profile/presentation/components/address_form.dart`
   - AddressFormWidget widget (ConsumerWidget)
   - Props: initialAddress (UserAddress?), onSubmit
   - Reusable form component
   - Contains all field widgets and validation

**Requirements:**
- State dropdown filtered by country selection (future enhancement)
- Proper keyboard types for each field
- Checkboxes static for now
- Form validation
Prompt: Profile Presentation - Edit Academic Details Screen
Implement the Edit Academic Details screen (Practitioner only).

**Files to create:**

1. `lib/features/profile/presentation/screens/edit_academic_details_screen.dart`
   - EditAcademicDetailsScreen (ConsumerStatefulWidget)
   - Uses AppScaffold with custom AppBar
   - AppBar: Back button (left), "Academic Details" title (center)
   - Initializes form with existing academic details
   - Handles form states

**Form Layout:**
- Heading: "Select your academic qualifications"
- List of checkbox options:
  - UG
  - PG
  - PhD
  - CCRAS
  - PG Diploma
  - Other
- Submit button at bottom

**Form Behavior:**
- Pre-populate checkboxes from existing academic_details array
- Multiple selection allowed
- At least one must be selected (validation)
- Show loading during submission
- Success/error feedback

2. `lib/features/profile/presentation/components/academic_checkbox_list.dart`
   - AcademicCheckboxList widget (ConsumerWidget)
   - Props: selectedTypes, onToggle
   - List of AcademicCheckboxItem widgets
   - Handles toggle state

3. `lib/features/profile/presentation/components/academic_checkbox_item.dart`
   - AcademicCheckboxItem widget (StatelessWidget)
   - Props: label, value, isSelected, onChanged
   - Checkbox with label

**Requirements:**
- Only visible for Practitioner membership type
- Checkbox list with multiple selection
- Validation: at least one selected
- Pre-populated from existing data
Prompt: Profile Presentation - Edit Professional Details Screen
Implement the Edit Professional Details screen (Practitioner, House Surgeon).

**Files to create:**

1. `lib/features/profile/presentation/screens/edit_professional_details_screen.dart`
   - EditProfessionalDetailsScreen (ConsumerStatefulWidget)
   - Uses AppScaffold with custom AppBar
   - AppBar: Back button (left), "Professional Details" title (center)
   - Initializes form with existing professional details
   - Handles form states
   - SingleChildScrollView for long form

**Form Layout (top to bottom):**
Section 1: Professional Types (Checkboxes)
- Researcher
- PG Scholar
- PG Diploma Scholar
- Dept of ISM
- Dept of NAM
- Dept of NHM
- Aided College
- Govt College
- PVT College
- PVT Sector College
- RETD
- PVT Practice
- Manufacturer
- Military Service
- Central Govt
- ESI
- Other

Section 2: Medical Council Registration Details (Heading)
- Medical Council State (Dropdown)
- Medical Council Number (AppTextField)
- Central Council Number (AppTextField)
- UG College (AppTextField)

Submit button at bottom

**Form Behavior:**
- Pre-populate from existing data
- Multiple checkbox selection allowed
- Medical council fields optional but validated format if filled
- Show loading during submission
- Success/error feedback

2. `lib/features/profile/presentation/components/professional_checkbox_list.dart`
   - List of professional type checkboxes
   - Grouped or scrollable list

3. `lib/features/profile/presentation/components/medical_council_form.dart`
   - MedicalCouncilForm widget (ConsumerWidget)
   - Contains medical council registration fields
   - State dropdown, text fields

**Requirements:**
- Visible for Practitioner and House Surgeon
- Long form with proper scrolling
- Two sections: checkboxes and text fields
- Validation on submission
Prompt: Profile Presentation - Edit Nominee Details Screen
Implement the Edit Nominee Details screen (Practitioner only, for ASWAS Plus).

**Files to create:**

1. `lib/features/profile/presentation/screens/edit_nominee_screen.dart`
   - EditNomineeScreen (ConsumerStatefulWidget)
   - Uses AppScaffold with custom AppBar
   - AppBar: Back button (left), "Nominee Details" title (center)
   - Handles form states

**Form Fields:**
1. Name (AppTextField, required)
2. Relation (Dropdown, required)
3. Contact (AppTextField, phone validation, required)
4. Submit Request button

**Form Behavior:**
- Empty form (nominee details submitted as new request)
- All fields required
- Phone number validation
- Submit creates profile update request with insurance_data
- Success shows "Request submitted" message
- Navigate back on success

2. `lib/features/profile/presentation/components/nominee_form.dart`
   - NomineeFormWidget widget (ConsumerWidget)
   - Contains all nominee fields
   - Validation logic

**Requirements:**
- Only visible for Practitioner membership type
- Links to ASWAS Plus insurance nominee
- Submit creates pending profile update
- Clear success/error feedback
Prompt: Profile Presentation - Loading and Error States
Implement loading and error state components for Profile.

**Files to create:**

1. `lib/features/profile/presentation/components/profile_loading_shimmer.dart`
   - ProfileLoadingShimmer widget (StatelessWidget)
   - Shimmer/skeleton for profile screen layout
   - Placeholders for: avatar, name, email, info card, options

2. `lib/features/profile/presentation/components/edit_form_loading.dart`
   - EditFormLoading widget (StatelessWidget)
   - Shimmer for form fields while loading dropdown options

3. `lib/features/profile/presentation/components/profile_error_view.dart`
   - ProfileErrorView widget (StatelessWidget)
   - Props: failure, onRetry, hasCachedData
   - Standard error handling pattern

4. `lib/features/profile/presentation/components/form_submission_dialog.dart`
   - FormSubmissionDialog widget (StatelessWidget)
   - Props: isLoading, isSuccess, message, onDismiss
   - Shows during form submission
   - Shows success or error message after

5. `lib/features/profile/presentation/components/pending_update_banner.dart`
   - PendingUpdateBanner widget (StatelessWidget)
   - Props: message
   - Displayed when user has pending profile updates
   - Informs user that changes require admin approval

**Requirements:**
- Shimmers match actual layout
- Error states don't block cached data
- Form submission feedback clear
- Pending updates communicated to user

Phase 5: Hive Configuration
Prompt: Profile Hive Setup
Implement Hive configuration for Profile caching.

**Files to create:**

1. `lib/features/profile/infrastructure/hive/profile_box_keys.dart`
   - Static class: ProfileBoxKeys
   - Constants:
     - static const boxName = 'profile_box'
     - static const profileDataKey = 'profile_data'
     - static const profileTimestampKey = 'profile_timestamp'
     - static const dropdownOptionsKey = 'dropdown_options'
     - static const dropdownTimestampKey = 'dropdown_timestamp'

2. `lib/features/profile/infrastructure/hive/adapters/profile_data_adapter.dart`
   - Hive TypeAdapter for ProfileDataModel
   - TypeId: [assign unique number]
   - Handle all nested models

3. `lib/features/profile/infrastructure/hive/adapters/` (all model adapters)
   - MembershipInfoModelAdapter
   - UserInfoModelAdapter
   - UserAddressModelAdapter
   - UserDocumentModelAdapter
   - ProfileUpdateRequestModelAdapter
   - DropdownOptionsModelAdapter
   - DropdownOptionModelAdapter

4. Update `lib/app/bootstrap/hive_init.dart`
   - Register all Profile feature adapters
   - Open Profile box

**Requirements:**
- TypeIds unique across entire app
- Adapters handle nullable fields
- Complex nested structure handled
- Separate timestamps for different data types

Phase 6: Integration
Prompt: Profile Route and Navigation Integration
Integrate Profile into app routing.

**Files to update:**

1. `lib/app/router/routes.dart`
   - Add: static const profile = '/profile'
   - Add: static const editPersonalInfo = '/profile/personal-info'
   - Add: static const editAddress = '/profile/address'
   - Add: static const editAcademicDetails = '/profile/academic'
   - Add: static const editProfessionalDetails = '/profile/professional'
   - Add: static const editNominee = '/profile/nominee'
   - Add: static const privacySecurity = '/profile/privacy'
   - Add: static const helpSupport = '/profile/help'
   - Add: static const termsPolicies = '/profile/terms'

2. `lib/app/router/app_router.dart`
   - Add Profile as 4th tab in bottom navigation shell
   - Add all edit screen routes
   - Routes trigger data fetch on navigation
   - Pass parameters where needed (address ID for edit)

3. `lib/app/router/main_shell.dart` (or equivalent)
   - Update bottom navigation with Profile as 4th item
   - Icons: Home, Library (static), Events (static), Profile
   - Profile icon navigates to Profile screen

**Requirements:**
- Profile is 4th tab in bottom navigation
- Edit screens accessible from profile
- Back navigation returns to profile
- Parameters passed correctly
Prompt: Profile Provider Integration
Integrate Profile providers with app-level providers.

**Files to create/update:**

1. `lib/features/profile/application/providers/profile_providers.dart`
   - Ensure all dependencies injected:
     - DioClient from core providers
     - Hive box for profile
     - ConnectivityChecker from core
     - SecureStore from core (for XCSRF token)
   - Export all public providers

2. `lib/features/profile/profile.dart` (barrel export)
   - Export all public APIs:
     - Entities (ProfileData, MembershipType, UserInfo, etc.)
     - Providers (profileStateProvider, form providers)
     - Screen widgets

**Requirements:**
- Clean public API via barrel exports
- Internal implementation not exposed
- Providers properly scoped

Phase 7: Bottom Navigation Update
Prompt: Bottom Navigation Configuration
Update bottom navigation to include all 4 tabs.

**Files to update:**

1. `lib/app/shell/bottom_navigation_shell.dart` (or equivalent)
   - Configure 4 navigation items:
     1. Home (index 0) - Home icon - HomeScreen
     2. Library (index 1) - Book icon - LibraryScreen (static)
     3. Events (index 2) - Calendar icon - EventsScreen (static)
     4. Profile (index 3) - Person icon - ProfileScreen
   - Handle navigation state
   - Maintain navigation stack per tab

2. `lib/features/library/presentation/screens/library_screen.dart`
   - Static placeholder screen
   - "Library" title
   - "Coming soon" or placeholder content

3. `lib/features/events/presentation/screens/events_screen.dart`
   - Static placeholder screen
   - "Events" title
   - "Coming soon" or placeholder content

**Requirements:**
- 4 tabs visible in bottom navigation
- Profile is 4th tab (index 3)
- Library and Events static for now
- Proper icon selection
- Active/inactive states styled

Testing Prompts
Prompt: Profile Unit Tests
Implement unit tests for Profile feature.

**Test files to create:**

1. `test/features/profile/domain/entities/membership_type_test.dart`
   - Test fromString factory
   - Test all enum values
   - Test displayName getter

2. `test/features/profile/domain/entities/profile_data_test.dart`
   - Test isPractitioner, isHouseSurgeon, isStudent getters
   - Test address getters (primary, apta, communications)
   - Test hasPendingUpdates

3. `test/features/profile/domain/entities/personal_info_form_test.dart`
   - Test fromUserInfo factory
   - Test isValid getter
   - Test toProfileData method

4. `test/features/profile/infrastructure/repositories/profile_repository_impl_test.dart`
   - Test getProfileData:
     - 200 response: data cached, timestamp stored
     - 304 response: returns null
     - Error: returns failure
     - Offline: returns cached data
   - Test updatePersonalInfo:
     - Success with XCSRF token
     - Validation failure
     - Server failure
   - Test all update methods
   - Mock ProfileApi, ProfileLocalDataSource, ConnectivityChecker, SecureStore

5. `test/features/profile/application/usecases/fetch_profile_data_usecase_test.dart`
   - Test success path
   - Test 304 path
   - Test failure path

6. `test/features/profile/application/usecases/update_personal_info_usecase_test.dart`
   - Test success
   - Test validation failure
   - Test API failure

7. `test/features/profile/application/providers/profile_notifier_test.dart`
   - Test initial state
   - Test loading state
   - Test loaded state
   - Test error state with cached data

8. `test/features/profile/application/providers/personal_info_form_notifier_test.dart`
   - Test initializeForm
   - Test updateField
   - Test updateWhatsappSameAsPhone
   - Test submit success
   - Test submit failure

**Test fixtures:**

9. `test/fixtures/profile_fixtures.dart`
   - Sample ProfileData for each membership type
   - Sample UserInfo
   - Sample form data
   - Sample API responses

**Requirements:**
- Use mocktail for mocks
- Test all state transitions
- Test if-modified-since logic
- Test XCSRF token in updates
- Test conditional logic based on membership type
Prompt: Profile Widget Tests
Implement widget tests for Profile.

**Test files to create:**

1. `test/features/profile/presentation/screens/profile_screen_test.dart`
   - Test loading state shows shimmer
   - Test loaded state for Practitioner (all options)
   - Test loaded state for House Surgeon (limited options)
   - Test loaded state for Student (minimal options)
   - Test error state with cached data
   - Mock providers

2. `test/features/profile/presentation/components/edit_profile_options_card_test.dart`
   - Test Practitioner sees all options
   - Test House Surgeon sees limited options
   - Test Student sees minimal options
   - Test option taps trigger navigation

3. `test/features/profile/presentation/screens/edit_personal_info_screen_test.dart`
   - Test form pre-population
   - Test WhatsApp same as phone checkbox
   - Test validation errors shown
   - Test submit button disabled when invalid
   - Test loading during submission
   - Mock providers

4. `test/features/profile/presentation/screens/edit_address_screen_test.dart`
   - Test form fields displayed
   - Test validation
   - Test submission

5. `test/features/profile/presentation/screens/edit_academic_details_screen_test.dart`
   - Test checkboxes displayed
   - Test pre-population
   - Test toggle functionality
   - Test validation (at least one selected)

6. `test/features/profile/presentation/screens/edit_professional_details_screen_test.dart`
   - Test both sections displayed
   - Test checkboxes
   - Test medical council fields
   - Test submission

7. `test/features/profile/presentation/screens/edit_nominee_screen_test.dart`
   - Test form fields
   - Test validation
   - Test submission creates insurance_data request

**Requirements:**
- Use ProviderScope with overrides
- Test conditional rendering based on membership type
- Test form validation
- Verify accessibility

Critical Implementation Rules
**ALWAYS FOLLOW THESE RULES FOR PROFILE MODULE:**

1. **if-modified-since pattern:**
   - Store separate timestamps for profile data and dropdown options
   - Send stored timestamp in header on every GET request
   - On 304: use cached data, do NOT update timestamp
   - On 200: update cache AND timestamp

2. **X-CSRF-Token:**
   - Required for all POST/PUT requests (updates)
   - Retrieve from SecureStore before requests
   - Include in request headers

3. **Membership Type Conditional UI:**
   - Practitioner: All edit options visible
     - Personal Information, Saved Addresses, Academic Details, Professional Details, Apta Options (static), ASWAS Plus Nominee
   - House Surgeon: Limited options
     - Personal Information, Saved Addresses, Professional Details
   - Student: Minimal options
     - Personal Information, Saved Addresses only
   - Use membershipType from API response to determine

4. **Profile Updates Require Approval:**
   - Updates to personal info, academic, professional, nominee create profile_updates
   - These are pending until admin approves
   - Show banner/message informing user updates are pending
   - Check is_verified status in profile_updates

5. **Graceful degradation:**
   - Always show cached data if available
   - Loading state overlays cached data
   - Error state shows banner but displays cached data

6. **Form Pre-population:**
   - Edit screens pre-populate from existing data
   - Personal Info: from UserInfo
   - Address: from selected UserAddress
   - Academic: from academic_details array
   - Professional: from professional_details array and membership fields
   - Nominee: empty form (new request each time)

7. **Static elements (for now):**
   - Profile picture edit icon: static
   - Apta Options: static
   - Apta Mailing Address checkbox: static
   - Permanent Address checkbox: static
   - Logout button: static
   - Privacy & Security: static screen
   - Help & Support: static screen
   - Terms & Policies: static screen
   - Library tab: static screen
   - Events tab: static screen

8. **Form Validation:**
   - Personal Info: name, email required; email format; phone format
   - Address: address_line1, city, state, postal_code, country required
   - Academic: at least one option selected
   - Professional: no required fields but format validation on council numbers
   - Nominee: all fields required; phone format

9. **Data refresh triggers:**
   - Screen navigation
   - After successful form submission (refresh profile data)
   - Manual retry from error state

10. **Navigation:**
    - Profile is 4th tab in bottom navigation
    - Edit screens push on top of Profile
    - Back navigation returns to Profile
    - Success after form submission navigates back

11. **API Response Structure:**
    - Main endpoint returns complex nested structure
    - Parse membership, user, addresses, documents, profile_updates
    - Handle all nullable fields
    - membership_type is key discriminator

12. **Bottom Navigation:**
    - Home (index 0)
    - Library (index 1) - static
    - Events (index 2) - static
    - Profile (index 3)

