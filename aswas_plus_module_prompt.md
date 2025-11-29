ASWAS PLUS Module - Enterprise Flutter Implementation Prompt
Module Overview
Module Name: ASWAS PLUS Description: Insurance policy management module with two distinct flows based on user enrollment status. Non-enrolled users see registration flow, enrolled users see policy details with renewal capability.Entry Point: Quick Actions > ASWAS PLUS from Homescreen Sub-screens:
ASWAS Plus Screen (main - conditional UI based on enrollment)
Register Here Screen (registration form for non-enrolled)
Registration Payment Screen (payment summary after registration)
Renew Membership/Policy Screen (reuse from Membership module)
Payment Method Screen (reuse from Membership module)
API Specifications
Headers Configuration (Apply to ALL endpoints)
**Required Headers for ALL requests:**
- Authorization: Bearer {access_token}
- if-modified-since: {stored_timestamp}

**Required Headers for POST/PUT/DELETE/PATCH requests:**
- X-CSRF-Token: {xcsrf_token}

**Conditional Response Handling:**
- Response 200 OK: Data present in body, extract new timestamp from response headers, replace stored timestamp, update UI with new data
- Response 304 Not Modified: No data in body, retain existing cached data and timestamp, display cached data in UI
Phase 1: Domain Layer
Prompt: ASWAS Plus Domain Entities
Implement the ASWAS Plus domain layer entities.

**Files to create:**

1. `lib/features/aswas_plus/domain/entities/aswas_plus_status.dart`
   - AswasePlusStatus entity using Freezed
   - Fields: isEnrolled (bool)
   - This is the root discriminator for conditional UI
   - No JSON serialization (domain layer is pure)

2. `lib/features/aswas_plus/domain/entities/enrollment_data.dart`
   - EnrollmentData entity using Freezed (for non-enrolled users)
   - Fields: schemeDetails (String), benefitsSummary (String), policyDocumentUrl (String), claimFormUrl (String), renewalGuidelinesUrl (String)
   - Getter: bool get hasDownloadableDocuments

3. `lib/features/aswas_plus/domain/entities/policy_data.dart`
   - PolicyData entity using Freezed (for enrolled users)
   - Fields: policyHolderName (String), policyNumber (String), nomineeCount (int), validUntil (DateTime), isActive (bool), isRenewalDue (bool), daysUntilExpiry (int), policyCardPdfUrl (String), schemeDetails (String), policyDocumentUrl (String), claimFormUrl (String), renewalGuidelinesUrl (String)
   - Getter: bool get isExpired => validUntil.isBefore(DateTime.now())
   - Getter: bool get shouldShowRenewalButton => isRenewalDue
   - Getter: String get formattedValidUntil

4. `lib/features/aswas_plus/domain/entities/nominee.dart`
   - Nominee entity using Freezed
   - Fields: id (String), name (String), relation (String), contactNumber (String)

5. `lib/features/aswas_plus/domain/entities/aswas_plus_data.dart`
   - AswasePlusData aggregate entity using Freezed
   - Fields: isEnrolled (bool), enrollmentData (EnrollmentData?), policyData (PolicyData?), nominees (List<Nominee>?), timestamp (String)
   - Factory: AswasePlusData.empty() for initial/loading state
   - Getter: bool get hasPolicy => isEnrolled && policyData != null
   - Getter: bool get canRegister => !isEnrolled
   - Getter: bool get hasNominees => nominees != null && nominees!.isNotEmpty

6. `lib/features/aswas_plus/domain/entities/dropdown_option.dart`
   - DropdownOption entity using Freezed
   - Fields: value (String), label (String)
   - Reusable for marital status and relation dropdowns

7. `lib/features/aswas_plus/domain/entities/registration_form_data.dart`
   - RegistrationFormData entity using Freezed
   - Fields: preFilledName (String?), preFilledParentName (String?), maritalStatusOptions (List<DropdownOption>), relationOptions (List<DropdownOption>), policyAmount (double), gstPercentage (double), timestamp (String)
   - Getter: double get estimatedTotal (policyAmount + GST calculation)

8. `lib/features/aswas_plus/domain/entities/nominee_form_data.dart`
   - NomineeFormData entity using Freezed
   - Fields: name (String), relation (String), address (String), mobileNumber (String)
   - Factory: NomineeFormData.empty() for new nominee entry
   - Getter: bool get isValid (basic validation)

9. `lib/features/aswas_plus/domain/entities/registration_request.dart`
   - RegistrationRequest entity using Freezed
   - Fields: name (String), parentName (String), maritalStatus (String), nominees (List<NomineeFormData>), ageProofCertificate (File path or bytes reference)
   - Getter: bool get isValid
   - Getter: int get nomineeCount

10. `lib/features/aswas_plus/domain/entities/registration_result.dart`
    - RegistrationResult entity using Freezed
    - Fields: registrationId (String), subtotal (double), gst (double), gstPercentage (double), totalPayable (double)
    - Getter: String get formattedTotal

11. `lib/features/aswas_plus/domain/repositories/aswas_plus_repository.dart`
    - Abstract class: AswasePlusRepository
    - Methods (all return Future<Either<Failure, T>>):
      - getAswasePlusData({required String ifModifiedSince}) -> AswasePlusData?
        // Returns AswasePlusData on 200, null on 304
      - getRegistrationFormData({required String ifModifiedSince}) -> RegistrationFormData?
        // Returns RegistrationFormData on 200, null on 304
      - submitRegistration({required RegistrationRequest request, required String xcsrfToken}) -> RegistrationResult
      - downloadPolicyCard() -> String (returns file path or URL)
      - Future<String?> getStoredTimestamp(String key)
      - Future<void> storeTimestamp(String key, String timestamp)
      - Future<AswasePlusData?> getCachedAswasePlusData()
      - Future<RegistrationFormData?> getCachedRegistrationFormData()

**Requirements:**
- Domain entities have no dependencies on external packages except Freezed
- Repository is abstract (contract only)
- Use fpdart Either for error handling
- Entities are immutable
- Handle 304 Not Modified scenario in repository contract
- Separate entities for enrolled vs non-enrolled data
- Nominee form data supports dynamic add/remove

Phase 2: Infrastructure Layer
Prompt: ASWAS Plus Infrastructure - Models
Implement the ASWAS Plus infrastructure models.

**Files to create:**

1. `lib/features/aswas_plus/infrastructure/models/enrollment_data_model.dart`
   - EnrollmentDataModel with JSON serialization
   - Factory: fromJson, toJson
   - Method: toDomain() -> EnrollmentData
   - Use json_serializable

2. `lib/features/aswas_plus/infrastructure/models/policy_data_model.dart`
   - PolicyDataModel with JSON serialization
   - Handle date parsing from ISO8601 string
   - Method: toDomain() -> PolicyData

3. `lib/features/aswas_plus/infrastructure/models/nominee_model.dart`
   - NomineeModel with JSON serialization
   - Method: toDomain() -> Nominee

4. `lib/features/aswas_plus/infrastructure/models/aswas_plus_data_model.dart`
   - AswasePlusDataModel aggregate with JSON serialization
   - Contains: isEnrolled, EnrollmentDataModel?, PolicyDataModel?, List<NomineeModel>?
   - Method: toDomain() -> AswasePlusData
   - Handle conditional fields based on isEnrolled

5. `lib/features/aswas_plus/infrastructure/models/dropdown_option_model.dart`
   - DropdownOptionModel with JSON serialization
   - Method: toDomain() -> DropdownOption

6. `lib/features/aswas_plus/infrastructure/models/registration_form_data_model.dart`
   - RegistrationFormDataModel with JSON serialization
   - Contains: preFilledData, List<DropdownOptionModel> for each dropdown
   - Method: toDomain() -> RegistrationFormData

7. `lib/features/aswas_plus/infrastructure/models/nominee_form_data_model.dart`
   - NomineeFormDataModel with JSON serialization
   - Method: toDomain() -> NomineeFormData
   - Factory: fromDomain(NomineeFormData) for request building

8. `lib/features/aswas_plus/infrastructure/models/registration_request_model.dart`
   - RegistrationRequestModel for multipart form data
   - Fields: name, parentName, maritalStatus, List<NomineeFormDataModel>, ageProofCertificatePath
   - Method: toFormData() -> FormData (for Dio multipart request)
   - Factory: fromDomain(RegistrationRequest)

9. `lib/features/aswas_plus/infrastructure/models/registration_result_model.dart`
   - RegistrationResultModel with JSON serialization
   - Contains payment summary fields
   - Method: toDomain() -> RegistrationResult

**Requirements:**
- Models handle null safety for optional/conditional fields
- Date parsing must handle ISO8601 format
- Decimal amounts handled properly
- All models are separate from domain entities
- Use json_serializable annotations
- Registration request model handles multipart form data for file upload
Prompt: ASWAS Plus Infrastructure - Data Sources
Implement the ASWAS Plus data sources.

**Files to create:**

1. `lib/features/aswas_plus/infrastructure/data_sources/remote/aswas_plus_api.dart`
   - Abstract class: AswasePlusApi
   - Implementation: AswasePlusApiImpl
   - Constructor takes DioClient
   - Methods:
     - Future<ApiResponse<AswasePlusDataModel?>> fetchAswasePlusData({required String ifModifiedSince})
       // Returns AswasePlusDataModel on 200, null on 304
     - Future<ApiResponse<RegistrationFormDataModel?>> fetchRegistrationFormData({required String ifModifiedSince})
       // Returns RegistrationFormDataModel on 200, null on 304
     - Future<RegistrationResultModel> submitRegistration({required RegistrationRequestModel request, required String xcsrfToken})
       // POST multipart/form-data, requires X-CSRF-Token header
     - Future<String> downloadPolicyCard()
       // Returns download URL or triggers download
   - Must pass if-modified-since header for GET requests
   - Must pass X-CSRF-Token header for POST requests
   - Must handle 304 response code without throwing error
   - Extract new timestamp from response headers on 200
   - Handle multipart form data for file upload

2. `lib/features/aswas_plus/infrastructure/data_sources/local/aswas_plus_local_ds.dart`
   - Abstract class: AswasePlusLocalDataSource
   - Implementation: AswasePlusLocalDataSourceImpl
   - Constructor takes Hive box
   - Methods:
     - Future<void> cacheAswasePlusData(AswasePlusDataModel data)
     - Future<AswasePlusDataModel?> getCachedAswasePlusData()
     - Future<void> cacheRegistrationFormData(RegistrationFormDataModel data)
     - Future<RegistrationFormDataModel?> getCachedRegistrationFormData()
     - Future<void> storeTimestamp(String key, String timestamp)
     - Future<String?> getTimestamp(String key)
     - Future<void> clearCache()
   - Separate keys for different data types
   - Store in Hive with appropriate keys

**Requirements:**
- API must not throw on 304 - treat as valid response
- POST requests include X-CSRF-Token in headers
- File upload uses multipart/form-data content type
- Local data source uses Hive for caching
- Separate timestamps for different data types
- Handle Dio response interceptor for 304 status
Prompt: ASWAS Plus Infrastructure - Repository Implementation
Implement the ASWAS Plus repository.

**Files to create:**

1. `lib/features/aswas_plus/infrastructure/repositories/aswas_plus_repository_impl.dart`
   - AswasePlusRepositoryImpl implements AswasePlusRepository
   - Constructor takes: AswasePlusApi, AswasePlusLocalDataSource, ConnectivityChecker, SecureStore (for XCSRF token)
   
   - Implement getAswasePlusData:
     1. Check connectivity
     2. If online: call API with if-modified-since header
        - On 200: map to domain, cache data, store new timestamp, return Right(AswasePlusData)
        - On 304: return Right(null) to indicate use cached data
        - On error: return Left(Failure)
     3. If offline: return cached data or NetworkFailure
   
   - Implement getRegistrationFormData:
     1. Same pattern as getAswasePlusData
     2. Uses separate timestamp key
   
   - Implement submitRegistration:
     1. Check connectivity (required - no offline support for registration)
     2. Get XCSRF token from SecureStore
     3. Convert domain request to model with FormData
     4. Call POST API with token in header and multipart data
     5. Map response to domain
     6. Return Right(RegistrationResult) or Left(Failure)
   
   - Implement downloadPolicyCard:
     1. Call API to get download URL or file
     2. Return file path or URL for UI to handle download
   
   - Implement timestamp methods: delegate to local data source
   - Implement cache methods: get from local, map to domain

**Requirements:**
- Repository handles online/offline logic
- 304 response returns null (not failure)
- All API errors mapped to typed Failures
- Caching only on 200 response for GET endpoints
- POST requests always require XCSRF token
- Registration requires connectivity (no offline submission)
- File upload handled via multipart form data
- Separate timestamp management for different endpoints

Phase 3: Application Layer
Prompt: ASWAS Plus Application - States
Implement the ASWAS Plus application states.

**Files to create:**

1. `lib/features/aswas_plus/application/states/aswas_plus_state.dart`
   - AswasePlusState using Freezed
   - States:
     - initial()
     - loading(AswasePlusData? previousData)
     - loaded(AswasePlusData data)
     - error(Failure failure, AswasePlusData? cachedData)
   - Helpers:
     - AswasePlusData? get currentData
     - bool get isLoading
     - bool get hasError
     - bool get isEnrolled => currentData?.isEnrolled ?? false
     - bool get canRegister => currentData?.canRegister ?? false
     - bool get shouldShowRenewalButton => currentData?.policyData?.shouldShowRenewalButton ?? false

2. `lib/features/aswas_plus/application/states/registration_form_state.dart`
   - RegistrationFormState using Freezed
   - States:
     - initial()
     - loading(RegistrationFormData? previousData)
     - loaded(RegistrationFormData data)
     - error(Failure failure, RegistrationFormData? cachedData)
   - Helpers:
     - RegistrationFormData? get currentData
     - bool get isLoading
     - List<DropdownOption> get maritalStatusOptions
     - List<DropdownOption> get relationOptions

3. `lib/features/aswas_plus/application/states/registration_submission_state.dart`
   - RegistrationSubmissionState using Freezed
   - States:
     - initial()
     - validating()
     - submitting()
     - success(RegistrationResult result)
     - error(Failure failure)
   - Helpers:
     - bool get isSubmitting
     - bool get isSuccess
     - RegistrationResult? get result

4. `lib/features/aswas_plus/application/states/nominee_form_state.dart`
   - NomineeFormState using Freezed
   - Fields: nominees (List<NomineeFormData>), currentIndex (int for focused nominee)
   - Helpers:
     - int get nomineeCount
     - bool get canAddMore (limit check if applicable)
     - bool get canRemove => nomineeCount > 1
     - NomineeFormData get currentNominee
     - bool get isValid (all nominees valid)

**Requirements:**
- States support showing cached/previous data during loading
- States support showing cached data on error (graceful degradation)
- Helpers make UI logic simple
- Separate states for different flows
- Nominee form state supports dynamic list management
Prompt: ASWAS Plus Application - Usecases
Implement the ASWAS Plus usecases.

**Files to create:**

1. `lib/features/aswas_plus/application/usecases/fetch_aswas_plus_data_usecase.dart`
   - FetchAswasePlusDataUsecase class
   - Takes AswasePlusRepository
   - call() method:
     1. Get stored timestamp for ASWAS Plus data (use empty string if none)
     2. Call repository.getAswasePlusData(ifModifiedSince: timestamp)
     3. If Right(AswasePlusData): data was updated, return it
     4. If Right(null): 304, get cached data and return
     5. If Left(Failure): return failure
   - Returns Future<Either<Failure, AswasePlusData>>

2. `lib/features/aswas_plus/application/usecases/fetch_registration_form_data_usecase.dart`
   - FetchRegistrationFormDataUsecase class
   - Takes AswasePlusRepository
   - call() method:
     1. Get stored timestamp for registration form data
     2. Call repository.getRegistrationFormData(ifModifiedSince: timestamp)
     3. Handle 200/304/error same pattern
   - Returns Future<Either<Failure, RegistrationFormData>>

3. `lib/features/aswas_plus/application/usecases/submit_registration_usecase.dart`
   - SubmitRegistrationUsecase class
   - Takes AswasePlusRepository
   - call({required RegistrationRequest request}) method:
     1. Validate request (name not empty, at least one nominee, file attached)
     2. If invalid: return Left(ValidationFailure)
     3. Call repository.submitRegistration(request: request)
     4. Return Right(RegistrationResult) or Left(Failure)
   - Returns Future<Either<Failure, RegistrationResult>>

4. `lib/features/aswas_plus/application/usecases/download_policy_card_usecase.dart`
   - DownloadPolicyCardUsecase class
   - Takes AswasePlusRepository
   - call() method:
     1. Call repository.downloadPolicyCard()
     2. Return file path or URL
   - Returns Future<Either<Failure, String>>

5. `lib/features/aswas_plus/application/usecases/get_cached_aswas_plus_data_usecase.dart`
   - GetCachedAswasePlusDataUsecase class
   - Takes AswasePlusRepository
   - call() -> Future<Either<Failure, AswasePlusData?>>
   - Used for initial load before API call

**Requirements:**
- Usecases encapsulate the if-modified-since logic
- Single responsibility per usecase
- Submit registration usecase validates input before API call
- Proper error propagation
- Validation errors return typed ValidationFailure
Prompt: ASWAS Plus Application - Providers
Implement the ASWAS Plus providers.

**Files to create:**

1. `lib/features/aswas_plus/application/providers/aswas_plus_providers.dart`
   - Provider for AswasePlusRepository (impl with dependencies)
   - Provider for each usecase
   - aswasePlusStateProvider: AsyncNotifierProvider<AswasePlusNotifier, AswasePlusState>
   - registrationFormStateProvider: AsyncNotifierProvider<RegistrationFormNotifier, RegistrationFormState>
   - registrationSubmissionStateProvider: StateNotifierProvider<RegistrationSubmissionNotifier, RegistrationSubmissionState>
   - nomineeFormStateProvider: StateNotifierProvider<NomineeFormNotifier, NomineeFormState>
   - registrationFormDataProvider: StateProvider<RegistrationFormInputs> (tracks form field values)

2. `lib/features/aswas_plus/application/providers/aswas_plus_notifier.dart`
   - AswasePlusNotifier extends AsyncNotifier<AswasePlusState>
   - build(): Initialize with cached data if available, then fetch fresh
   - Methods:
     - Future<void> fetchAswasePlusData():
       1. Set loading state (preserve previous data)
       2. Execute FetchAswasePlusDataUsecase
       3. On success: set loaded state with new data
       4. On failure: set error state (preserve cached data for display)
     - Future<void> refresh(): Force fetch
     - Future<void> downloadPolicyCard(): Trigger download usecase

3. `lib/features/aswas_plus/application/providers/registration_form_notifier.dart`
   - RegistrationFormNotifier extends AsyncNotifier<RegistrationFormState>
   - build(): Initialize with cached data if available, then fetch fresh
   - Methods:
     - Future<void> fetchFormData(): Same pattern as above

4. `lib/features/aswas_plus/application/providers/registration_submission_notifier.dart`
   - RegistrationSubmissionNotifier extends StateNotifier<RegistrationSubmissionState>
   - Constructor takes SubmitRegistrationUsecase
   - Methods:
     - Future<void> submitRegistration(RegistrationRequest request):
       1. Set validating state
       2. Set submitting state
       3. Execute usecase
       4. Set success or error state
     - void reset(): Reset to initial state

5. `lib/features/aswas_plus/application/providers/nominee_form_notifier.dart`
   - NomineeFormNotifier extends StateNotifier<NomineeFormState>
   - Methods:
     - void addNominee(): Add new empty NomineeFormData to list
     - void removeNominee(int index): Remove nominee at index (if count > 1)
     - void updateNominee(int index, NomineeFormData data): Update nominee at index
     - void setCurrentIndex(int index): Set focused nominee
     - void reset(): Clear all nominees, add one empty

6. `lib/features/aswas_plus/application/providers/registration_form_inputs.dart`
   - RegistrationFormInputs class (simple data class or Freezed)
   - Fields: name, parentName, maritalStatus, ageProofCertificatePath
   - Used to track form field values across widget rebuilds

**Requirements:**
- Use riverpod_generator annotations where beneficial
- Providers properly scoped and documented
- State changes are atomic
- Nominee form state supports dynamic add/remove
- Form inputs tracked separately from API data
- Side effects (storage, API) in usecases, not notifier directly

Phase 4: Presentation Layer
Prompt: ASWAS Plus Presentation - Main Screen (Conditional UI)
Implement the ASWAS Plus main screen with conditional UI.

**Files to create:**

1. `lib/features/aswas_plus/presentation/screens/aswas_plus_screen.dart`
   - AswasePlusScreen (ConsumerStatefulWidget)
   - Uses AppScaffold with custom AppBar
   - AppBar: Back button (left), "ASWAS PLUS" title (center), Notification icon (right, static)
   - Triggers fetchAswasePlusData on initState/navigation
   - Pull-to-refresh support (RefreshIndicator)
   - Handles all states: loading, loaded, error
   - **Conditional UI based on isEnrolled:**
     - If NOT enrolled: Show NotEnrolledView
     - If enrolled: Show EnrolledPolicyView
   - Shows cached data during loading
   - Shows cached data on error with error banner

**Navigation:**
- Back button navigates to HomeScreen
- Register for Policy button navigates to RegisterHereScreen (non-enrolled)
- Renew button navigates to RenewMembershipScreen from Membership module (enrolled)

**Requirements:**
- Fully responsive using ScreenUtil
- Proper loading/error state handling
- Graceful degradation (show cached data on error)
- Clean separation between enrolled and non-enrolled views
- Pull-to-refresh triggers full data fetch
Prompt: ASWAS Plus Presentation - Not Enrolled View Components
Implement the not enrolled view components.

**Files to create:**

1. `lib/features/aswas_plus/presentation/components/not_enrolled_view.dart`
   - NotEnrolledView widget (StatelessWidget)
   - Props: enrollmentData (EnrollmentData entity), onRegister (VoidCallback)
   - Layout (top to bottom):
     - NotEnrolledCard
     - SchemeDetailsSection
     - DownloadDocumentsSection
   - SingleChildScrollView wrapper

2. `lib/features/aswas_plus/presentation/components/not_enrolled_card.dart`
   - NotEnrolledCard widget (StatelessWidget)
   - Props: onRegister (VoidCallback)
   - Card design:
     - Message: "You're not yet enrolled in Aswas Plus"
     - Sub-message: "Register now to enjoy member benefits including financial assistance during medical emergencies or accidents"
     - "Register for Policy" button (primary)
   - Prominent card styling
   - Button triggers navigation to registration screen

3. `lib/features/aswas_plus/presentation/components/scheme_details_section.dart`
   - SchemeDetailsSection widget (StatelessWidget)
   - Props: schemeDetails (String)
   - Display static text about ASWAS Plus scheme
   - Proper text formatting and readability
   - May include expandable sections if content is long

4. `lib/features/aswas_plus/presentation/components/download_documents_section.dart`
   - DownloadDocumentsSection widget (StatelessWidget)
   - Props: policyDocumentUrl (String), claimFormUrl (String), renewalGuidelinesUrl (String)
   - Three download buttons:
     - "Download Policy Document"
     - "Download Claim Form"
     - "Download Renewal Guidelines"
   - Each button triggers URL download or opens in browser
   - Use url_launcher or download_manager package

**Requirements:**
- Clear messaging encouraging registration
- Download buttons handle URL launching
- Proper card and section spacing
- Scheme details readable with appropriate typography
Prompt: ASWAS Plus Presentation - Enrolled View Components
Implement the enrolled policy view components.

**Files to create:**

1. `lib/features/aswas_plus/presentation/components/enrolled_policy_view.dart`
   - EnrolledPolicyView widget (ConsumerWidget)
   - Props: policyData (PolicyData entity), nominees (List<Nominee>)
   - Layout (top to bottom):
     - PolicyCardWidget
     - SchemeDetailsSection (with renewal button if applicable)
     - NomineeDetailsSection
     - DownloadDocumentsSection
   - SingleChildScrollView wrapper

2. `lib/features/aswas_plus/presentation/components/policy_card_widget.dart`
   - PolicyCardWidget widget (StatelessWidget)
   - Props: policyData (PolicyData entity), onDownloadPdf (VoidCallback)
   - Card design:
     - Heading: "ASWAS PLUS" with Active badge (if isActive)
     - Policy holder name
     - Policy number
     - Nominee count display (e.g., "2 Nominees")
     - Valid till date
     - "Download PDF" button
   - Premium card styling
   - Download button triggers policy card PDF download

3. `lib/features/aswas_plus/presentation/components/scheme_details_with_renewal.dart`
   - SchemeDetailsWithRenewal widget (ConsumerWidget)
   - Props: schemeDetails (String), isRenewalDue (bool), onRenew (VoidCallback)
   - Display static scheme details text
   - Renewal button (conditional):
     - Only visible if isRenewalDue is true
     - "Renew Policy" button
     - Navigates to RenewMembershipScreen with ASWAS Plus pre-selected

4. `lib/features/aswas_plus/presentation/components/nominee_details_section.dart`
   - NomineeDetailsSection widget (StatelessWidget)
   - Props: nominees (List<Nominee>), onRequestChange (VoidCallback)
   - Section heading: "Nominee Details"
   - List of nominee items showing: name, relation, contact number
   - "Request Change" button at bottom (static for now)
   - Handle multiple nominees display

5. `lib/features/aswas_plus/presentation/components/nominee_detail_item.dart`
   - NomineeDetailItem widget (StatelessWidget)
   - Props: nominee (Nominee entity)
   - Display: Name, Relation, Contact Number
   - Row or card layout for each nominee

**Requirements:**
- Policy card prominent at top
- Renewal button conditional visibility
- Nominee details clearly displayed
- Request Change button static placeholder
- Download buttons functional
- Consistent styling with app theme
Prompt: ASWAS Plus Presentation - Registration Screen
Implement the registration screen.

**Files to create:**

1. `lib/features/aswas_plus/presentation/screens/register_here_screen.dart`
   - RegisterHereScreen (ConsumerStatefulWidget)
   - Uses AppScaffold with custom AppBar
   - AppBar: Back button (left), "Register Here" title (center)
   - Triggers fetchRegistrationFormData on initState
   - Handles form state loading, loaded, error
   - Form with validation
   - SingleChildScrollView for form content

**Screen Layout Structure (top to bottom):**
1. PersonalDetailsSection (name, parent name, marital status)
2. NomineesSection (dynamic list of nominee forms)
3. DocumentUploadSection (age proof certificate)
4. SubmitButton

**Navigation:**
- Back button navigates to AswasePlusScreen
- Submit button (on success) navigates to RegistrationPaymentScreen

**Form Behavior:**
- Pre-fill name and parent name if available from API
- Dropdown for marital status from API options
- Dynamic nominee forms (add/remove)
- File picker for age proof certificate
- Form validation before submission

**Requirements:**
- Form state management via Riverpod
- Dynamic nominee list (add/remove functionality)
- File upload support
- Loading states during form data fetch and submission
- Validation feedback on fields
Prompt: ASWAS Plus Presentation - Registration Form Components
Implement the registration form components.

**Files to create:**

1. `lib/features/aswas_plus/presentation/components/personal_details_section.dart`
   - PersonalDetailsSection widget (ConsumerWidget)
   - Form fields:
     - Name (AppTextField, pre-filled if available)
     - Parent Name (AppTextField, pre-filled if available)
     - Marital Status (dropdown, options from API)
   - Uses Form widget for validation
   - Updates form state provider on changes

2. `lib/features/aswas_plus/presentation/components/marital_status_dropdown.dart`
   - MaritalStatusDropdown widget (StatelessWidget)
   - Props: options (List<DropdownOption>), selectedValue (String?), onChanged (ValueChanged<String?>)
   - Uses DropdownButtonFormField or custom dropdown
   - Validation for required field

3. `lib/features/aswas_plus/presentation/components/nominees_section.dart`
   - NomineesSection widget (ConsumerWidget)
   - Section heading: "Nominee Details"
   - Lists all nominee forms from nomineeFormStateProvider
   - Add/Remove nominee buttons
   - Add button: calls nomineeFormNotifier.addNominee()
   - Remove button: calls nomineeFormNotifier.removeNominee(index)
   - Remove button only visible if nomineeCount > 1

4. `lib/features/aswas_plus/presentation/components/nominee_form_card.dart`
   - NomineeFormCard widget (ConsumerWidget)
   - Props: index (int), nominee (NomineeFormData), relationOptions (List<DropdownOption>), onRemove (VoidCallback?)
   - Card containing:
     - Nominee Name (AppTextField)
     - Relation (dropdown)
     - Nominee Address (AppTextField, multiline)
     - Nominee Mobile Number (AppTextField, phone keyboard)
     - Remove button (if onRemove provided)
   - Updates nomineeFormNotifier on field changes

5. `lib/features/aswas_plus/presentation/components/relation_dropdown.dart`
   - RelationDropdown widget (StatelessWidget)
   - Props: options (List<DropdownOption>), selectedValue (String?), onChanged (ValueChanged<String?>)
   - Same pattern as marital status dropdown

6. `lib/features/aswas_plus/presentation/components/document_upload_section.dart`
   - DocumentUploadSection widget (ConsumerWidget)
   - Section heading: "Age Proof Certificate"
   - File picker button
   - Shows selected file name or "No file selected"
   - Preview if image, icon if PDF
   - Clear/change file option
   - Uses file_picker or image_picker package
   - Updates form state with file path

7. `lib/features/aswas_plus/presentation/components/submit_registration_button.dart`
   - SubmitRegistrationButton widget (ConsumerWidget)
   - Props: onSubmit (VoidCallback)
   - Full-width primary button
   - "Submit Registration" label
   - Disabled if form invalid
   - Shows loading indicator during submission
   - Watches registrationSubmissionStateProvider for loading state

**Requirements:**
- All fields have proper validation
- Dropdowns populated from API data
- Dynamic nominee add/remove working
- File picker functional
- Form state preserved during rebuilds
- Clear validation error messages
- Loading state during submission blocks interaction
Prompt: ASWAS Plus Presentation - Registration Payment Screen
Implement the registration payment screen.

**Files to create:**

1. `lib/features/aswas_plus/presentation/screens/registration_payment_screen.dart`
   - RegistrationPaymentScreen (ConsumerWidget)
   - Uses AppScaffold with custom AppBar
   - AppBar: Back button (left), "Payment" title (center)
   - Receives RegistrationResult via route parameter or from provider
   - No API call needed (data from registration submission)

**Screen Layout Structure (top to bottom):**
1. PaymentSummaryCard (showing subtotal, GST, total)
2. PayNowButton (static for now)

**Navigation:**
- Back button navigates to RegisterHereScreen (or AswasePlusScreen)
- Pay Now button static (future payment integration)

2. `lib/features/aswas_plus/presentation/components/registration_payment_summary.dart`
   - RegistrationPaymentSummary widget (StatelessWidget)
   - Props: result (RegistrationResult entity)
   - Card showing:
     - Registration ID (for reference)
     - Subtotal
     - GST (with percentage)
     - Total Payable (prominent)
   - Clear currency formatting

3. `lib/features/aswas_plus/presentation/components/registration_pay_button.dart`
   - RegistrationPayButton widget (StatelessWidget)
   - Props: onPressed (VoidCallback?)
   - Full-width primary button
   - "Pay Now" label
   - Static for now (shows "Coming soon" toast or similar)

**Requirements:**
- Payment summary clearly displayed
- Currency formatting consistent
- Registration ID shown for user reference
- Pay Now button static placeholder
- Proper back navigation handling
Prompt: ASWAS Plus Presentation - Loading and Error States
Implement loading and error state components for ASWAS Plus.

**Files to create:**

1. `lib/features/aswas_plus/presentation/components/aswas_plus_loading_shimmer.dart`
   - AswasePlusLoadingShimmer widget (StatelessWidget)
   - Shimmer/skeleton loading
   - Generic enough to work for both enrolled and non-enrolled (or separate shimmers)
   - Matches actual component sizes

2. `lib/features/aswas_plus/presentation/components/registration_form_loading.dart`
   - RegistrationFormLoading widget (StatelessWidget)
   - Shimmer for form fields while loading dropdown options
   - Shows field placeholders

3. `lib/features/aswas_plus/presentation/components/aswas_plus_error_view.dart`
   - AswasePlusErrorView widget (StatelessWidget)
   - Props: failure (Failure), onRetry (VoidCallback), hasCachedData (bool)
   - If hasCachedData: show banner at top, cached data below
   - If no cached data: full error state with retry

4. `lib/features/aswas_plus/presentation/components/submission_error_dialog.dart`
   - SubmissionErrorDialog widget (StatelessWidget)
   - Props: failure (Failure), onRetry (VoidCallback), onCancel (VoidCallback)
   - Dialog shown when registration submission fails
   - User-friendly error message
   - Retry and Cancel buttons

**Requirements:**
- Shimmers match actual layout for smooth transition
- Error states don't block cached data display
- Retry actions trigger appropriate fetch
- Submission errors shown as dialog, not inline
- Accessible error messages

Phase 5: Hive Configuration
Prompt: ASWAS Plus Hive Setup
Implement Hive configuration for ASWAS Plus caching.

**Files to create:**

1. `lib/features/aswas_plus/infrastructure/hive/aswas_plus_box_keys.dart`
   - Static class: AswasePlusBoxKeys
   - Constants:
     - static const boxName = 'aswas_plus_box'
     - static const aswasePlusDataKey = 'aswas_plus_data'
     - static const aswasePlusTimestampKey = 'aswas_plus_timestamp'
     - static const registrationFormDataKey = 'registration_form_data'
     - static const registrationFormTimestampKey = 'registration_form_timestamp'

2. `lib/features/aswas_plus/infrastructure/hive/adapters/aswas_plus_data_adapter.dart`
   - Hive TypeAdapter for AswasePlusDataModel
   - TypeId: [assign unique number, different from home and membership modules]
   - Handle all nested models and conditional fields

3. `lib/features/aswas_plus/infrastructure/hive/adapters/` (all model adapters)
   - Individual adapters for each model that needs caching:
     - EnrollmentDataModelAdapter
     - PolicyDataModelAdapter
     - NomineeModelAdapter
     - RegistrationFormDataModelAdapter
     - DropdownOptionModelAdapter

4. Update `lib/app/bootstrap/hive_init.dart`
   - Register all ASWAS Plus feature adapters
   - Open ASWAS Plus box

**Requirements:**
- TypeIds must be unique across entire app (coordinate with home and membership modules)
- Adapters handle nullable/conditional fields properly
- Box opened lazily or during bootstrap
- Models stored as-is (not domain entities)
- Separate timestamp keys for different data types

Phase 6: Integration
Prompt: ASWAS Plus Route and Navigation Integration
Integrate ASWAS Plus into app routing.

**Files to update:**

1. `lib/app/router/routes.dart`
   - Add: static const aswasePlus = '/aswas-plus'
   - Add: static const aswasePlusRegister = '/aswas-plus/register'
   - Add: static const aswasePlusRegistrationPayment = '/aswas-plus/registration-payment'

2. `lib/app/router/app_router.dart`
   - Add ASWAS Plus route (navigable from home quick actions)
   - Add registration route
   - Add registration payment route
   - Routes should trigger data fetch on navigation
   - Pass necessary parameters between screens (RegistrationResult to payment screen)
   - Configure renewal flow to reuse Membership module's RenewMembershipScreen with ASWAS Plus pre-selected

3. `lib/features/home/presentation/components/quick_actions_section.dart`
   - Update ASWAS Plus quick action to navigate to ASWAS Plus screen
   - Use GoRouter navigation

4. `lib/features/membership/presentation/screens/renew_membership_screen.dart`
   - Accept optional parameter for pre-selected plan
   - If navigated from ASWAS Plus with pre-selection, auto-select ASWAS Plus plan
   - Route parameter: preSelectedPlanId or preSelectAswasePlus boolean

**Requirements:**
- Proper back navigation stack
- Parameters passed correctly between screens
- Navigation triggers data refresh where needed
- Renewal flow reuses Membership module screens
- Pre-selection parameter handled in renewal screen
Prompt: ASWAS Plus Provider Integration
Integrate ASWAS Plus providers with app-level providers.

**Files to create/update:**

1. `lib/features/aswas_plus/application/providers/aswas_plus_providers.dart`
   - Ensure all dependencies are properly injected:
     - DioClient from core providers
     - Hive box for ASWAS Plus
     - ConnectivityChecker from core
     - SecureStore from core (for XCSRF token)
   - Export all public providers

2. `lib/features/aswas_plus/aswas_plus.dart` (barrel export)
   - Export all public APIs:
     - Entities (AswasePlusData, PolicyData, EnrollmentData, Nominee)
     - Providers (only public state providers for external use)
     - Screen widgets (AswasePlusScreen, RegisterHereScreen, RegistrationPaymentScreen)

**Requirements:**
- Clean public API via barrel exports
- Internal implementation details not exposed
- Providers properly scoped
- XCSRF token accessible from secure storage

Phase 7: Dependencies
Prompt: Additional Package Dependencies
Add required dependencies for ASWAS Plus module.

**Update pubspec.yaml:**
```yaml
dependencies:
  # Existing dependencies...
  
  # File picker for document upload
  file_picker: ^6.1.1
  
  # URL launcher for document downloads
  url_launcher: ^6.2.5
  
  # Image picker (alternative for photos)
  image_picker: ^1.0.7  # Optional, if preferred over file_picker for images
```

**Usage notes:**

1. file_picker:
   - Used in DocumentUploadSection for age proof certificate
   - Import: import 'package:file_picker/file_picker.dart';
   - Allow PDF and image types
   - Example: FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'png']);

2. url_launcher:
   - Used for downloading policy documents, claim forms, guidelines
   - Import: import 'package:url_launcher/url_launcher.dart';
   - Example: await launchUrl(Uri.parse(documentUrl));

**Platform Configuration:**

iOS (Info.plist):
- Add file picker and photo library permissions if using image_picker
- Add LSApplicationQueriesSchemes for URL launcher

Android (AndroidManifest.xml):
- Add internet permission (usually already present)
- Add file read permissions for file picker
- Add queries for URL launcher

**Requirements:**
- Run flutter pub get after adding
- Verify package compatibility with existing dependencies
- Configure platform-specific settings

Testing Prompts
Prompt: ASWAS Plus Unit Tests
Implement unit tests for ASWAS Plus feature.

**Test files to create:**

1. `test/features/aswas_plus/domain/entities/aswas_plus_data_test.dart`
   - Test isEnrolled variations
   - Test hasPolicy getter
   - Test canRegister getter
   - Test conditional data presence

2. `test/features/aswas_plus/domain/entities/policy_data_test.dart`
   - Test isExpired getter
   - Test shouldShowRenewalButton getter
   - Test formattedValidUntil

3. `test/features/aswas_plus/domain/entities/nominee_form_data_test.dart`
   - Test isValid getter
   - Test empty factory

4. `test/features/aswas_plus/infrastructure/repositories/aswas_plus_repository_impl_test.dart`
   - Test getAswasePlusData:
     - 200 response with enrolled user: policy data present
     - 200 response with non-enrolled user: enrollment data present
     - 304 response: returns null
     - Error: returns failure
     - Offline: returns cached data
   - Test getRegistrationFormData: same patterns
   - Test submitRegistration:
     - Success with XCSRF token and multipart data
     - Validation failure for invalid request
     - Server failure
     - Offline failure (no offline support)
   - Mock AswasePlusApi, AswasePlusLocalDataSource, ConnectivityChecker, SecureStore

5. `test/features/aswas_plus/application/usecases/fetch_aswas_plus_data_usecase_test.dart`
   - Test success path with enrolled user
   - Test success path with non-enrolled user
   - Test 304 path returns cached data
   - Test failure path

6. `test/features/aswas_plus/application/usecases/submit_registration_usecase_test.dart`
   - Test success with valid request
   - Test validation failure: empty name
   - Test validation failure: no nominees
   - Test validation failure: no file attached
   - Test API failure

7. `test/features/aswas_plus/application/providers/aswas_plus_notifier_test.dart`
   - Test initial state
   - Test loading preserves previous data
   - Test loaded state with enrolled user
   - Test loaded state with non-enrolled user
   - Test error state preserves cached data

8. `test/features/aswas_plus/application/providers/nominee_form_notifier_test.dart`
   - Test initial state has one empty nominee
   - Test addNominee increases count
   - Test removeNominee decreases count (if > 1)
   - Test removeNominee blocked if count is 1
   - Test updateNominee updates specific nominee

9. `test/features/aswas_plus/application/providers/registration_submission_notifier_test.dart`
   - Test initial state
   - Test submitting state during API call
   - Test success state with result
   - Test error state on failure

**Test fixtures:**

10. `test/fixtures/aswas_plus_fixtures.dart`
    - Sample AswasePlusData for enrolled user
    - Sample AswasePlusData for non-enrolled user
    - Sample RegistrationFormData
    - Sample RegistrationResult
    - Sample API response JSONs
    - Sample 304 response
    - Factory methods for variations

**Requirements:**
- Use mocktail for mocks
- Test all state transitions
- Test if-modified-since logic thoroughly
- Test 304 handling specifically
- Test XCSRF token included in POST requests
- Test conditional data (enrolled vs non-enrolled)
- Test dynamic nominee list operations
Prompt: ASWAS Plus Widget Tests
Implement widget tests for ASWAS Plus.

**Test files to create:**

1. `test/features/aswas_plus/presentation/screens/aswas_plus_screen_test.dart`
   - Test loading state shows shimmer
   - Test loaded state (enrolled) shows EnrolledPolicyView
   - Test loaded state (non-enrolled) shows NotEnrolledView
   - Test error state shows error banner with cached data
   - Test pull-to-refresh triggers fetch
   - Mock providers

2. `test/features/aswas_plus/presentation/components/not_enrolled_card_test.dart`
   - Test message displayed correctly
   - Test Register button triggers callback

3. `test/features/aswas_plus/presentation/components/policy_card_widget_test.dart`
   - Test policy details displayed
   - Test Active badge visibility
   - Test Download PDF button triggers callback

4. `test/features/aswas_plus/presentation/components/scheme_details_with_renewal_test.dart`
   - Test scheme details displayed
   - Test renewal button visible when isRenewalDue is true
   - Test renewal button hidden when isRenewalDue is false

5. `test/features/aswas_plus/presentation/screens/register_here_screen_test.dart`
   - Test form fields displayed
   - Test pre-filled values populated
   - Test dropdown options loaded
   - Test add nominee button adds form
   - Test remove nominee button removes form
   - Test submit button disabled when form invalid
   - Test submit triggers submission
   - Mock providers

6. `test/features/aswas_plus/presentation/components/nominees_section_test.dart`
   - Test initial state has one nominee form
   - Test add button adds another form
   - Test remove button removes form (if > 1)
   - Test remove button hidden if only one nominee

7. `test/features/aswas_plus/presentation/components/document_upload_section_test.dart`
   - Test "No file selected" initial state
   - Test file name displayed after selection
   - Test clear button removes file

8. `test/features/aswas_plus/presentation/screens/registration_payment_screen_test.dart`
   - Test payment summary displayed
   - Test amounts formatted correctly
   - Test Pay Now button present

**Requirements:**
- Use ProviderScope with overrides
- Test all conditional rendering (enrolled vs non-enrolled)
- Test dynamic form elements (add/remove nominee)
- Verify accessibility (semantic labels)
- Test form validation states

Critical Implementation Rules
**ALWAYS FOLLOW THESE RULES FOR ASWAS PLUS MODULE:**

1. **if-modified-since pattern:**
   - Store separate timestamps for ASWAS Plus data and registration form data
   - Send stored timestamp in header on every GET request
   - On 304: use cached data, do NOT update timestamp
   - On 200: update cache AND timestamp

2. **X-CSRF-Token:**
   - Required for POST /api/v1/aswas-plus/register
   - Retrieve from SecureStore before POST requests
   - Include in request headers

3. **Graceful degradation:**
   - Always show cached data if available, even during loading/error
   - Loading state overlays cached data
   - Error state shows banner but displays cached data below

4. **304 is not an error:**
   - Dio interceptor must not throw on 304
   - Repository returns Right(null) for 304
   - Usecase interprets null as "use cached data"

5. **Conditional UI based on enrollment:**
   - isEnrolled = false: Show NotEnrolledView with registration CTA
   - isEnrolled = true: Show EnrolledPolicyView with policy details
   - Clear visual distinction between the two states

6. **Dynamic nominee form:**
   - Minimum 1 nominee required
   - Add nominee: Append new empty NomineeFormData to list
   - Remove nominee: Only allowed if count > 1
   - Each nominee form validates independently
   - All nominees must be valid for form submission

7. **File upload:**
   - Support PDF and image formats (jpg, png)
   - Use multipart/form-data for submission
   - Show file name after selection
   - Allow clearing and re-selecting file
   - Validate file is selected before submission

8. **Static elements (for now):**
   - Notification icon: static, no functionality
   - Request Change button (nominee details): static
   - Pay Now button (registration payment): static
   - Download buttons: functional (open URLs)

9. **Conditional rendering:**
   - Renewal button: only if isRenewalDue is true (enrolled users)
   - Remove nominee button: only if nomineeCount > 1
   - Policy card: only for enrolled users
   - Registration card: only for non-enrolled users

10. **Data refresh triggers:**
    - Screen navigation (initState or GoRouter listener)
    - Pull-to-refresh
    - Manual retry from error state
    - After successful registration (should now show enrolled state)

11. **Renewal flow reuse:**
    - Navigate to Membership module's RenewMembershipScreen
    - Pass parameter to pre-select ASWAS Plus plan
    - Maintain consistent UX with membership renewal

12. **Form validation:**
    - Name: required, non-empty
    - Parent Name: required, non-empty
    - Marital Status: required, must select option
    - Each Nominee: name, relation, address, mobile all required
    - Mobile number: valid phone format
    - Age Proof Certificate: required, file must be selected
    - Show validation errors inline on fields
    - Block submission until all valid

13. **Navigation flow:**
    - Home -> ASWAS Plus -> (Non-enrolled) Register -> Payment
    - Home -> ASWAS Plus -> (Enrolled) Renew -> Membership Renewal Screen -> Payment
    - Back navigation maintains proper stack
    - Successful registration should update enrollment status

14. **Document downloads:**
    - Policy Document, Claim Form, Renewal Guidelines
    - Use url_launcher to open URLs
    - Handle launch failure gracefully
    - Same download options available for both enrolled and non-enrolled (scheme info)

