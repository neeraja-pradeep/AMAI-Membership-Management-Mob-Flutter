Membership Module - Enterprise Flutter Implementation Prompt
Module Overview
Module Name: Membership Description: Comprehensive membership management screen displaying current membership status, digital membership card with QR code, renewal flow, payment processing, and payment receipts.Entry Point: Quick Actions > Membership from Homescreen Sub-screens:
Membership Screen (main)
Renew Membership/Policy Screen
Select Payment Method Screen
Full-size QR View Screen

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
Prompt: Membership Domain Entities
Implement the membership domain layer entities.

**Files to create:**

1. `lib/features/membership/domain/entities/membership_status.dart`
   - MembershipStatus entity using Freezed
   - Fields: isActive (bool), membershipType (String), validUntil (DateTime), isRenewalDue (bool), daysUntilExpiry (int)
   - Getter: bool get isExpired => validUntil.isBefore(DateTime.now())
   - Getter: bool get shouldShowRenewalButton => isRenewalDue
   - Getter: String get formattedValidUntil (formatted date string)
   - No JSON serialization (domain layer is pure)

2. `lib/features/membership/domain/entities/digital_card.dart`
   - DigitalCard entity using Freezed
   - Fields: qrCodeData (String), cardHolderName (String), membershipId (String)
   - Getter: bool get hasValidQrData => qrCodeData.isNotEmpty

3. `lib/features/membership/domain/entities/payment_receipt.dart`
   - PaymentReceipt entity using Freezed
   - Fields: id (String), receiptNumber (String), amount (double), paymentDate (DateTime), paymentMethod (String), description (String), downloadUrl (String)
   - Getter: String get formattedAmount (currency formatted)
   - Getter: String get formattedDate

4. `lib/features/membership/domain/entities/membership_data.dart`
   - MembershipData aggregate entity using Freezed
   - Fields: currentStatus (MembershipStatus), digitalCard (DigitalCard), paymentReceipts (List<PaymentReceipt>), timestamp (String)
   - Factory: MembershipData.empty() for initial/loading state
   - Getter: bool get hasReceipts => paymentReceipts.isNotEmpty

5. `lib/features/membership/domain/entities/renewal_plan.dart`
   - RenewalPlan entity using Freezed
   - Fields: id (String), name (String), amountPerYear (double), isSelected (bool)
   - Getter: String get formattedAmount (currency formatted with "/year" suffix)

6. `lib/features/membership/domain/entities/aswas_plus_plan.dart`
   - AswasePlusPlan entity using Freezed
   - Fields: id (String), name (String), amountPerYear (double), isAvailable (bool), userHasAswasPlus (bool), isSelected (bool)
   - Getter: bool get shouldShow => isAvailable || userHasAswasPlus
   - Getter: String get formattedAmount

7. `lib/features/membership/domain/entities/renewal_user_details.dart`
   - RenewalUserDetails entity using Freezed
   - Fields: fullName (String), membershipId (String), emailAddress (String)

8. `lib/features/membership/domain/entities/renewal_options.dart`
   - RenewalOptions aggregate entity using Freezed
   - Fields: currentPlan (RenewalPlan), aswasePlusPlan (AswasePlusPlan?), userDetails (RenewalUserDetails), timestamp (String)
   - Getter: bool get hasAswasePlusOption => aswasePlusPlan != null && aswasePlusPlan!.shouldShow
   - Getter: List<String> get selectedPlanIds (returns list of selected plan IDs)
   - Method: RenewalOptions togglePlanSelection(String planId) (returns new instance with toggled selection)

9. `lib/features/membership/domain/entities/payment_summary.dart`
   - PaymentSummary entity using Freezed
   - Fields: subtotal (double), gst (double), gstPercentage (double), totalPayable (double), selectedPlans (List<SelectedPlanItem>)
   - Getter: String get formattedSubtotal
   - Getter: String get formattedGst
   - Getter: String get formattedTotal

10. `lib/features/membership/domain/entities/selected_plan_item.dart`
    - SelectedPlanItem entity using Freezed
    - Fields: id (String), name (String), amount (double)

11. `lib/features/membership/domain/repositories/membership_repository.dart`
    - Abstract class: MembershipRepository
    - Methods (all return Future<Either<Failure, T>>):
      - getMembershipData({required String ifModifiedSince}) -> MembershipData?
        // Returns MembershipData on 200, null on 304
      - getRenewalOptions({required String ifModifiedSince}) -> RenewalOptions?
        // Returns RenewalOptions on 200, null on 304
      - getPaymentSummary({required List<String> selectedPlanIds, required String xcsrfToken}) -> PaymentSummary
      - Future<String?> getStoredTimestamp(String key)
      - Future<void> storeTimestamp(String key, String timestamp)
      - Future<MembershipData?> getCachedMembershipData()
      - Future<RenewalOptions?> getCachedRenewalOptions()

**Requirements:**
- Domain entities have no dependencies on external packages except Freezed
- Repository is abstract (contract only)
- Use fpdart Either for error handling
- Entities are immutable
- Handle 304 Not Modified scenario in repository contract
- Separate timestamps for membership data and renewal options

Phase 2: Infrastructure Layer
Prompt: Membership Infrastructure - Models
Implement the membership infrastructure models.

**Files to create:**

1. `lib/features/membership/infrastructure/models/membership_status_model.dart`
   - MembershipStatusModel with JSON serialization
   - Factory: fromJson, toJson
   - Method: toDomain() -> MembershipStatus
   - Handle date parsing from ISO8601 string
   - Use json_serializable

2. `lib/features/membership/infrastructure/models/digital_card_model.dart`
   - DigitalCardModel with JSON serialization
   - Factory: fromJson, toJson
   - Method: toDomain() -> DigitalCard

3. `lib/features/membership/infrastructure/models/payment_receipt_model.dart`
   - PaymentReceiptModel with JSON serialization
   - Handle date parsing and decimal amounts
   - Method: toDomain() -> PaymentReceipt

4. `lib/features/membership/infrastructure/models/membership_data_model.dart`
   - MembershipDataModel aggregate with JSON serialization
   - Contains: MembershipStatusModel, DigitalCardModel, List<PaymentReceiptModel>
   - Method: toDomain() -> MembershipData
   - Handle timestamp extraction

5. `lib/features/membership/infrastructure/models/renewal_plan_model.dart`
   - RenewalPlanModel with JSON serialization
   - Method: toDomain() -> RenewalPlan

6. `lib/features/membership/infrastructure/models/aswas_plus_plan_model.dart`
   - AswasePlusPlanModel with JSON serialization
   - Handle nullable fields
   - Method: toDomain() -> AswasePlusPlan

7. `lib/features/membership/infrastructure/models/renewal_user_details_model.dart`
   - RenewalUserDetailsModel with JSON serialization
   - Method: toDomain() -> RenewalUserDetails

8. `lib/features/membership/infrastructure/models/renewal_options_model.dart`
   - RenewalOptionsModel aggregate with JSON serialization
   - Contains: RenewalPlanModel, AswasePlusPlanModel?, RenewalUserDetailsModel
   - Method: toDomain() -> RenewalOptions

9. `lib/features/membership/infrastructure/models/payment_summary_model.dart`
   - PaymentSummaryModel with JSON serialization
   - Contains: List<SelectedPlanItemModel>
   - Method: toDomain() -> PaymentSummary

10. `lib/features/membership/infrastructure/models/selected_plan_item_model.dart`
    - SelectedPlanItemModel with JSON serialization
    - Method: toDomain() -> SelectedPlanItem

11. `lib/features/membership/infrastructure/models/payment_summary_request.dart`
    - PaymentSummaryRequest for POST body
    - Fields: selectedPlanIds (List<String>)
    - Method: toJson()

**Requirements:**
- Models handle null safety for optional fields
- Date parsing must handle ISO8601 format
- Decimal amounts handled properly (avoid floating point issues)
- All models are separate from domain entities
- Use json_serializable annotations

Prompt: Membership Infrastructure - Data Sources
Implement the membership data sources.

**Files to create:**

1. `lib/features/membership/infrastructure/data_sources/remote/membership_api.dart`
   - Abstract class: MembershipApi
   - Implementation: MembershipApiImpl
   - Constructor takes DioClient
   - Methods:
     - Future<ApiResponse<MembershipDataModel?>> fetchMembershipData({required String ifModifiedSince})
       // Returns MembershipDataModel on 200, null on 304
     - Future<ApiResponse<RenewalOptionsModel?>> fetchRenewalOptions({required String ifModifiedSince})
       // Returns RenewalOptionsModel on 200, null on 304
     - Future<PaymentSummaryModel> fetchPaymentSummary({required List<String> selectedPlanIds, required String xcsrfToken})
       // POST request, requires X-CSRF-Token header
   - Must pass if-modified-since header for GET requests
   - Must pass X-CSRF-Token header for POST requests
   - Must handle 304 response code without throwing error
   - Extract new timestamp from response headers on 200

2. `lib/features/membership/infrastructure/data_sources/local/membership_local_ds.dart`
   - Abstract class: MembershipLocalDataSource
   - Implementation: MembershipLocalDataSourceImpl
   - Constructor takes Hive box
   - Methods:
     - Future<void> cacheMembershipData(MembershipDataModel data)
     - Future<MembershipDataModel?> getCachedMembershipData()
     - Future<void> cacheRenewalOptions(RenewalOptionsModel data)
     - Future<RenewalOptionsModel?> getCachedRenewalOptions()
     - Future<void> storeTimestamp(String key, String timestamp)
     - Future<String?> getTimestamp(String key)
     - Future<void> clearCache()
   - Separate keys for membership data and renewal options timestamps
   - Store in Hive with appropriate keys

**Requirements:**
- API must not throw on 304 - treat as valid response
- POST requests include X-CSRF-Token in headers
- Local data source uses Hive for caching
- Separate timestamps for different data types
- Handle Dio response interceptor for 304 status

Prompt: Membership Infrastructure - Repository Implementation

Implement the membership repository.

**Files to create:**

1. `lib/features/membership/infrastructure/repositories/membership_repository_impl.dart`
   - MembershipRepositoryImpl implements MembershipRepository
   - Constructor takes: MembershipApi, MembershipLocalDataSource, ConnectivityChecker, SecureStore (for XCSRF token)
   - 
   - Implement getMembershipData:
     1. Check connectivity
     2. If online: call API with if-modified-since header
        - On 200: map to domain, cache data, store new timestamp, return Right(MembershipData)
        - On 304: return Right(null) to indicate use cached data
        - On error: return Left(Failure)
     3. If offline: return cached data or NetworkFailure
   
   - Implement getRenewalOptions:
     1. Same pattern as getMembershipData
     2. Uses separate timestamp key
   
   - Implement getPaymentSummary:
     1. Get XCSRF token from SecureStore
     2. Call POST API with token in header
     3. Map response to domain
     4. No caching (always fresh calculation)
     5. Return Right(PaymentSummary) or Left(Failure)
   
   - Implement timestamp methods: delegate to local data source
   - Implement cache methods: get from local, map to domain

**Requirements:**
- Repository handles online/offline logic
- 304 response returns null (not failure)
- All API errors mapped to typed Failures
- Caching only on 200 response for GET endpoints
- POST requests always require XCSRF token
- Payment summary not cached (dynamic calculation)
- Separate timestamp management for different endpoints


Phase 3: Application Layer
Prompt: Membership Application - States
Implement the membership application states.

**Files to create:**

1. `lib/features/membership/application/states/membership_state.dart`
   - MembershipState using Freezed
   - States:
     - initial()
     - loading(MembershipData? previousData)
     - loaded(MembershipData data)
     - error(Failure failure, MembershipData? cachedData)
   - Helpers:
     - MembershipData? get currentData
     - bool get isLoading
     - bool get hasError
     - bool get shouldShowRenewalButton
     - bool get hasDigitalCard
     - bool get hasPaymentReceipts

2. `lib/features/membership/application/states/renewal_state.dart`
   - RenewalState using Freezed
   - States:
     - initial()
     - loading(RenewalOptions? previousData)
     - loaded(RenewalOptions data)
     - error(Failure failure, RenewalOptions? cachedData)
   - Helpers:
     - RenewalOptions? get currentData
     - bool get isLoading
     - bool get hasAswasePlusOption
     - List<String> get selectedPlanIds

3. `lib/features/membership/application/states/payment_state.dart`
   - PaymentState using Freezed
   - States:
     - initial()
     - loading()
     - loaded(PaymentSummary summary)
     - processing() // For future payment processing
     - success() // For future payment success
     - error(Failure failure)
   - Helpers:
     - PaymentSummary? get summary
     - bool get isLoading
     - bool get canProceed

**Requirements:**
- States support showing cached/previous data during loading
- States support showing cached data on error (graceful degradation)
- Helpers make UI logic simple
- Separate states for each screen/flow

Prompt: Membership Application - Usecases
Implement the membership usecases.

**Files to create:**

1. `lib/features/membership/application/usecases/fetch_membership_data_usecase.dart`
   - FetchMembershipDataUsecase class
   - Takes MembershipRepository
   - call() method:
     1. Get stored timestamp for membership data (use empty string if none)
     2. Call repository.getMembershipData(ifModifiedSince: timestamp)
     3. If Right(MembershipData): data was updated, return it
     4. If Right(null): 304, get cached data and return
     5. If Left(Failure): return failure
   - Returns Future<Either<Failure, MembershipData>>

2. `lib/features/membership/application/usecases/fetch_renewal_options_usecase.dart`
   - FetchRenewalOptionsUsecase class
   - Takes MembershipRepository
   - call() method:
     1. Get stored timestamp for renewal options
     2. Call repository.getRenewalOptions(ifModifiedSince: timestamp)
     3. Handle 200/304/error same pattern
   - Returns Future<Either<Failure, RenewalOptions>>

3. `lib/features/membership/application/usecases/fetch_payment_summary_usecase.dart`
   - FetchPaymentSummaryUsecase class
   - Takes MembershipRepository
   - call({required List<String> selectedPlanIds}) method:
     1. Validate at least one plan selected
     2. Call repository.getPaymentSummary(selectedPlanIds: selectedPlanIds)
     3. Return Right(PaymentSummary) or Left(Failure)
   - Returns Future<Either<Failure, PaymentSummary>>

4. `lib/features/membership/application/usecases/get_cached_membership_data_usecase.dart`
   - GetCachedMembershipDataUsecase class
   - Takes MembershipRepository
   - call() -> Future<Either<Failure, MembershipData?>>
   - Used for initial load before API call

5. `lib/features/membership/application/usecases/get_cached_renewal_options_usecase.dart`
   - GetCachedRenewalOptionsUsecase class
   - Takes MembershipRepository
   - call() -> Future<Either<Failure, RenewalOptions?>>

**Requirements:**
- Usecases encapsulate the if-modified-since logic
- Single responsibility per usecase
- Payment summary usecase validates input
- Proper error propagation

Prompt: Membership Application - Providers
Implement the membership providers.

**Files to create:**

1. `lib/features/membership/application/providers/membership_providers.dart`
   - Provider for MembershipRepository (impl with dependencies)
   - Provider for each usecase
   - membershipStateProvider: AsyncNotifierProvider<MembershipNotifier, MembershipState>
   - renewalStateProvider: AsyncNotifierProvider<RenewalNotifier, RenewalState>
   - paymentStateProvider: StateNotifierProvider<PaymentNotifier, PaymentState>
   - selectedPlansProvider: StateProvider<List<String>> (tracks selected plan IDs in renewal flow)

2. `lib/features/membership/application/providers/membership_notifier.dart`
   - MembershipNotifier extends AsyncNotifier<MembershipState>
   - build(): Initialize with cached data if available, then fetch fresh
   - Methods:
     - Future<void> fetchMembershipData():
       1. Set loading state (preserve previous data)
       2. Execute FetchMembershipDataUsecase
       3. On success: set loaded state with new data
       4. On failure: set error state (preserve cached data for display)
     - Future<void> refresh(): Force fetch (user pull-to-refresh)

3. `lib/features/membership/application/providers/renewal_notifier.dart`
   - RenewalNotifier extends AsyncNotifier<RenewalState>
   - build(): Initialize with cached data if available, then fetch fresh
   - Methods:
     - Future<void> fetchRenewalOptions(): Same pattern as membership
     - void togglePlanSelection(String planId): Update selected plans
     - void resetSelections(): Clear all selections
   - Sync selected plans with selectedPlansProvider

4. `lib/features/membership/application/providers/payment_notifier.dart`
   - PaymentNotifier extends StateNotifier<PaymentState>
   - Constructor takes FetchPaymentSummaryUsecase
   - Methods:
     - Future<void> fetchPaymentSummary(List<String> selectedPlanIds):
       1. Set loading state
       2. Execute usecase
       3. Set loaded or error state
     - void reset(): Reset to initial state
     - Future<void> processPayment(): Placeholder for future implementation

**Requirements:**
- Use riverpod_generator annotations where beneficial
- Providers properly scoped and documented
- State changes are atomic
- Selected plans state shared between renewal and payment screens
- Side effects (storage, API) in usecases, not notifier directly

Phase 4: Presentation Layer
Prompt: Membership Presentation - Main Screen
Implement the membership main screen.

**Files to create:**

1. `lib/features/membership/presentation/screens/membership_screen.dart`
   - MembershipScreen (ConsumerStatefulWidget)
   - Uses AppScaffold with custom AppBar
   - AppBar: Back button (left), "Membership" title (center), Notification icon (right, static)
   - Triggers fetchMembershipData on initState/navigation
   - Pull-to-refresh support (RefreshIndicator)
   - Handles all states: loading, loaded, error
   - Shows cached data during loading
   - Shows cached data on error with error banner
   - SingleChildScrollView with Column layout

**Screen Layout Structure (top to bottom):**
1. CurrentStatusCard
2. DigitalMembershipCard (with QR code)
3. PaymentReceiptsSection

**Navigation:**
- Back button navigates to HomeScreen
- Renewal button (when visible) navigates to RenewMembershipScreen
- View Full QR navigates to FullQrScreen
- Receipt items navigate to receipt detail (future, static for now)

**Requirements:**
- Fully responsive using ScreenUtil
- Proper loading/error state handling
- Graceful degradation (show cached data on error)
- Pull-to-refresh triggers full data fetch
- Each section is a separate component
Prompt: Membership Presentation - Current Status Components
Implement the current status card components.

**Files to create:**

1. `lib/features/membership/presentation/components/current_status_card.dart`
   - CurrentStatusCard widget (ConsumerWidget)
   - Props: membershipStatus (MembershipStatus entity)
   - Card design:
     - Top row: "Current Status" heading (left), ActiveBadge (right, based on isActive)
     - Below: Membership type text (prominent)
     - Below: "Valid Until: {formatted date}" text
     - Bottom: Renewal button (conditional, only if shouldShowRenewalButton is true)
   - Use AppCard with consistent styling
   - Renewal button uses AppButton primary variant
   - On renewal button tap: navigate to RenewMembershipScreen

2. `lib/features/membership/presentation/components/membership_info_row.dart`
   - Reusable row widget for label-value display
   - Props: label (String), value (String), valueStyle (TextStyle?)
   - Used for membership type, valid until, etc.

**Requirements:**
- All text uses theme typography
- All colors from AppColors
- ScreenUtil for all dimensions
- Renewal button visibility controlled by entity
- Semantic labels for accessibility
- Reuse ActiveBadge from home module or create shared widget
Prompt: Membership Presentation - Digital Card Components
Implement the digital membership card components.

**Files to create:**

1. `lib/features/membership/presentation/components/digital_membership_card.dart`
   - DigitalMembershipCard widget (StatelessWidget)
   - Props: digitalCard (DigitalCard entity)
   - Card design:
     - Heading: "Digital Membership Card"
     - Below: Card container with:
       - "AMAI Digital Membership Card" title
       - Subtitle: "Show at events and check-ins"
       - QR Code generated from qrCodeData string
       - Card holder name display
       - Membership ID display
     - Below QR: Action buttons row
   - Generate QR code from string data using qr_flutter package

2. `lib/features/membership/presentation/components/qr_code_widget.dart`
   - QrCodeWidget widget (StatelessWidget)
   - Props: data (String), size (double)
   - Uses qr_flutter package to generate QR from string
   - Error correction level: medium or high
   - Proper sizing with ScreenUtil
   - Handle empty/invalid data gracefully

3. `lib/features/membership/presentation/components/digital_card_actions.dart`
   - DigitalCardActions widget (StatelessWidget)
   - Props: onViewFullSize (VoidCallback), onDownloadPdf (VoidCallback)
   - Two buttons/links:
     - "View Full Size" - navigates to FullQrScreen
     - "Download as PDF" - static for now (show toast or disabled)
   - Horizontal layout with proper spacing

**Requirements:**
- QR code generated client-side from backend string
- QR code sized appropriately for scanning
- View full size opens dedicated QR screen
- Download PDF is static placeholder
- Card styling consistent with other cards
Prompt: Membership Presentation - Payment Receipts Components
Implement the payment receipts section components.

**Files to create:**

1. `lib/features/membership/presentation/components/payment_receipts_section.dart`
   - PaymentReceiptsSection widget (StatelessWidget)
   - Props: receipts (List<PaymentReceipt>)
   - Layout:
     - Section heading: "Payment Receipt" (note: singular as per UI spec)
     - List of receipt items
   - Handle empty state (no receipts message or hide section)

2. `lib/features/membership/presentation/components/payment_receipt_item.dart`
   - PaymentReceiptItem widget (StatelessWidget)
   - Props: receipt (PaymentReceipt entity), onTap (VoidCallback?)
   - Card/tile design:
     - Receipt number
     - Amount (formatted currency)
     - Payment date (formatted)
     - Payment method
     - Description (if available)
     - Download/view icon (static for now)
   - Tappable for future detail view

3. `lib/features/membership/presentation/components/empty_receipts_view.dart`
   - EmptyReceiptsView widget (StatelessWidget)
   - Message indicating no payment history
   - Optional icon

**Requirements:**
- Receipts displayed in reverse chronological order (most recent first)
- Currency formatting consistent
- Date formatting consistent
- Empty state handled gracefully
- Individual receipt taps static for now
Prompt: Membership Presentation - Renew Membership Screen
Implement the renew membership/policy screen.

**Files to create:**

1. `lib/features/membership/presentation/screens/renew_membership_screen.dart`
   - RenewMembershipScreen (ConsumerStatefulWidget)
   - Uses AppScaffold with custom AppBar
   - AppBar: Back button (left), "Renew Membership/Policy" title (center)
   - Triggers fetchRenewalOptions on initState
   - Handles loading, loaded, error states
   - SingleChildScrollView with Column layout

**Screen Layout Structure (top to bottom):**
1. CurrentPlanCard (membership plan with selection)
2. AswasePlusCard (conditional, only if available/user has it)
3. ConfirmDetailsSection
4. ActionButtonsRow (Cancel, Proceed to Payment)

**Navigation:**
- Back button navigates to MembershipScreen
- Cancel button navigates to MembershipScreen
- Proceed to Payment navigates to PaymentMethodScreen (only if at least one plan selected)

**Requirements:**
- Plan cards are selectable (toggle selection state)
- At least one plan must be selected to proceed
- User details displayed for confirmation
- Proper state management for selections
Prompt: Membership Presentation - Renewal Plan Components
Implement the renewal plan selection components.

**Files to create:**

1. `lib/features/membership/presentation/components/current_plan_card.dart`
   - CurrentPlanCard widget (ConsumerWidget)
   - Props: plan (RenewalPlan entity)
   - Card design:
     - Plan name (prominent)
     - Amount per year
     - Selection indicator (checkbox or radio style)
   - Tappable to toggle selection
   - Updates selectedPlansProvider on tap
   - Visual feedback for selected state

2. `lib/features/membership/presentation/components/aswas_plus_renewal_card.dart`
   - AswasePlusRenewalCard widget (ConsumerWidget)
   - Props: plan (AswasePlusPlan entity)
   - Only rendered if plan.shouldShow is true
   - Card design:
     - "ASWAS PLUS" heading
     - Amount per year
     - Selection indicator
   - Same selection behavior as CurrentPlanCard
   - Distinct styling to differentiate from membership plan

3. `lib/features/membership/presentation/components/plan_selection_card.dart`
   - Generic PlanSelectionCard widget (StatelessWidget)
   - Props: title (String), subtitle (String), amount (String), isSelected (bool), onTap (VoidCallback)
   - Reusable base component for both plan cards
   - Selected state styling (border color, background, check icon)

**Requirements:**
- Only one card can be selected at a time (radio behavior) OR multiple selection allowed
  (clarify with requirements - treating as single selection based on "opt any one")
- Selected state clearly visible
- Smooth selection animation
- Proper touch feedback
Prompt: Membership Presentation - Confirm Details Components
Implement the confirm details section components.

**Files to create:**

1. `lib/features/membership/presentation/components/confirm_details_section.dart`
   - ConfirmDetailsSection widget (StatelessWidget)
   - Props: userDetails (RenewalUserDetails entity)
   - Layout:
     - Heading: "Confirm Details"
     - Full Name row
     - Membership ID row
     - Email Address row
   - Read-only display (not editable)
   - Consistent row styling

2. `lib/features/membership/presentation/components/detail_row.dart`
   - DetailRow widget (StatelessWidget)
   - Props: label (String), value (String)
   - Label on left, value on right (or stacked for long values)
   - Reusable for various detail displays

3. `lib/features/membership/presentation/components/renewal_action_buttons.dart`
   - RenewalActionButtons widget (ConsumerWidget)
   - Props: onCancel (VoidCallback), onProceed (VoidCallback)
   - Two buttons:
     - Cancel: secondary/outline variant, navigates back
     - Proceed to Payment: primary variant, validates selection, navigates forward
   - Proceed button disabled if no plan selected
   - Horizontal layout with equal sizing or proper spacing

**Requirements:**
- Proceed button validates at least one plan selected
- Show error/toast if proceeding without selection
- Cancel clears selection state
- Proper button states (enabled/disabled)
Prompt: Membership Presentation - Payment Method Screen
Implement the select payment method screen.

**Files to create:**

1. `lib/features/membership/presentation/screens/payment_method_screen.dart`
   - PaymentMethodScreen (ConsumerStatefulWidget)
   - Uses AppScaffold with custom AppBar
   - AppBar: Back button (left), "Select Payment Method" title (center)
   - Triggers fetchPaymentSummary on initState with selected plan IDs
   - Handles loading, loaded, error states
   - Column layout

**Screen Layout Structure (top to bottom):**
1. PaymentSummarySection (subtotal, GST, total)
2. PaymentMethodSelector (future - static for now)
3. PayNowButton (static for now)

**Navigation:**
- Back button navigates to RenewMembershipScreen
- Pay Now button static (future payment integration)

**Requirements:**
- Payment summary calculated via POST API with XCSRF token
- Summary displayed clearly with proper currency formatting
- Pay Now button prominent but static
- Loading state while fetching summary
Prompt: Membership Presentation - Payment Summary Components
Implement the payment summary components.

**Files to create:**

1. `lib/features/membership/presentation/components/payment_summary_section.dart`
   - PaymentSummarySection widget (StatelessWidget)
   - Props: summary (PaymentSummary entity)
   - Layout:
     - Selected plans list (name and amount for each)
     - Divider
     - Subtotal row
     - GST row (with percentage if available)
     - Divider
     - Total Payable row (prominent styling)
   - Clear currency formatting
   - Proper alignment (labels left, amounts right)

2. `lib/features/membership/presentation/components/summary_line_item.dart`
   - SummaryLineItem widget (StatelessWidget)
   - Props: label (String), amount (String), isTotal (bool, for styling)
   - Reusable for subtotal, GST, total rows
   - Total row has bolder/larger styling

3. `lib/features/membership/presentation/components/pay_now_button.dart`
   - PayNowButton widget (StatelessWidget)
   - Props: onPressed (VoidCallback?), isLoading (bool)
   - Full-width primary button
   - "Pay Now" label
   - Shows loading indicator when processing (future)
   - Currently static (onPressed shows "Coming soon" or similar)

**Requirements:**
- Currency formatting consistent across app
- GST percentage displayed (e.g., "GST (18%)")
- Total amount visually prominent
- Proper decimal handling for currency
Prompt: Membership Presentation - Full QR Screen
Implement the full-size QR view screen.

**Files to create:**

1. `lib/features/membership/presentation/screens/full_qr_screen.dart`
   - FullQrScreen (StatelessWidget)
   - Receives qrCodeData via route parameter or provider
   - Uses AppScaffold with simple AppBar
   - AppBar: Back button (left), "Membership QR" title (center)
   - Centered large QR code
   - Card holder name and membership ID below QR
   - Optional: Instructions text "Show this QR at events"

**Screen Layout:**
- Full screen focus on QR code
- QR code sized for easy scanning (large)
- Minimal distractions
- Dark/light mode consideration for QR contrast

2. `lib/features/membership/presentation/components/full_size_qr.dart`
   - FullSizeQr widget (StatelessWidget)
   - Props: data (String), holderName (String), membershipId (String)
   - Large QR code (80% of screen width or appropriate size)
   - Name and ID below
   - High contrast for scanning

**Requirements:**
- QR code large enough for easy scanning
- Proper contrast (white background for QR)
- Simple, focused interface
- Screen brightness could be increased (future enhancement)
Prompt: Membership Presentation - Loading and Error States
Implement loading and error state components for membership.

**Files to create:**

1. `lib/features/membership/presentation/components/membership_loading_shimmer.dart`
   - MembershipLoadingShimmer widget (StatelessWidget)
   - Shimmer/skeleton loading matching membership screen layout
   - Placeholders for: status card, digital card, receipts section
   - Matches actual component sizes

2. `lib/features/membership/presentation/components/renewal_loading_shimmer.dart`
   - RenewalLoadingShimmer widget (StatelessWidget)
   - Shimmer for renewal screen: plan cards, details section

3. `lib/features/membership/presentation/components/payment_loading_indicator.dart`
   - PaymentLoadingIndicator widget (StatelessWidget)
   - Centered loading for payment summary calculation
   - Message: "Calculating total..." or similar

4. `lib/features/membership/presentation/components/membership_error_view.dart`
   - MembershipErrorView widget (StatelessWidget)
   - Props: failure (Failure), onRetry (VoidCallback), hasCachedData (bool)
   - If hasCachedData: show banner at top, cached data below
   - If no cached data: full error state with retry

**Requirements:**
- Shimmers match actual layout for smooth transition
- Error states don't block cached data display
- Retry actions trigger appropriate fetch
- Accessible error messages

Phase 5: Hive Configuration
Prompt: Membership Hive Setup
Implement Hive configuration for membership caching.

**Files to create:**

1. `lib/features/membership/infrastructure/hive/membership_box_keys.dart`
   - Static class: MembershipBoxKeys
   - Constants:
     - static const boxName = 'membership_box'
     - static const membershipDataKey = 'membership_data'
     - static const membershipTimestampKey = 'membership_timestamp'
     - static const renewalOptionsKey = 'renewal_options'
     - static const renewalTimestampKey = 'renewal_timestamp'

2. `lib/features/membership/infrastructure/hive/adapters/membership_data_adapter.dart`
   - Hive TypeAdapter for MembershipDataModel
   - TypeId: [assign unique number, different from home module]
   - Handle all nested models

3. `lib/features/membership/infrastructure/hive/adapters/` (all model adapters)
   - Individual adapters for each model that needs caching:
     - MembershipStatusModelAdapter
     - DigitalCardModelAdapter
     - PaymentReceiptModelAdapter
     - RenewalOptionsModelAdapter
     - RenewalPlanModelAdapter
     - AswasePlusPlanModelAdapter
     - RenewalUserDetailsModelAdapter

4. Update `lib/app/bootstrap/hive_init.dart`
   - Register all membership feature adapters
   - Open membership box

**Requirements:**
- TypeIds must be unique across entire app (coordinate with home module)
- Adapters handle nullable fields
- Box opened lazily or during bootstrap
- Models stored as-is (not domain entities)
- Separate timestamp keys for membership data and renewal options

Phase 6: Integration
Prompt: Membership Route and Navigation Integration
Integrate membership into app routing.

**Files to update:**

1. `lib/app/router/routes.dart`
   - Add: static const membership = '/membership'
   - Add: static const renewMembership = '/membership/renew'
   - Add: static const paymentMethod = '/membership/payment'
   - Add: static const fullQr = '/membership/qr'

2. `lib/app/router/app_router.dart`
   - Add membership route (navigable from home quick actions)
   - Add renew membership route
   - Add payment method route
   - Add full QR route
   - Routes should trigger data fetch on navigation (GoRouter listener or screen initState)
   - Pass necessary parameters between screens (selected plans, QR data)

3. `lib/features/home/presentation/components/quick_actions_section.dart`
   - Update Memberships quick action to navigate to membership screen
   - Use GoRouter navigation

**Requirements:**
- Proper back navigation stack
- Parameters passed correctly between screens
- Navigation triggers data refresh where needed
- Deep linking support for membership routes
Prompt: Membership Provider Integration
Integrate membership providers with app-level providers.

**Files to create/update:**

1. `lib/features/membership/application/providers/membership_providers.dart`
   - Ensure all dependencies are properly injected:
     - DioClient from core providers
     - Hive box for membership
     - ConnectivityChecker from core
     - SecureStore from core (for XCSRF token)
   - Export all public providers

2. `lib/features/membership/membership.dart` (barrel export)
   - Export all public APIs:
     - Entities
     - Providers (only public state providers for external use)
     - Screen widgets (MembershipScreen, RenewMembershipScreen, PaymentMethodScreen, FullQrScreen)

3. `lib/core/storage/secure_store_keys.dart`
   - Add XCSRF token key if not already present:
     - static const xcsrfToken = 'xcsrf_token';

**Requirements:**
- Clean public API via barrel exports
- Internal implementation details not exposed
- Providers properly scoped
- XCSRF token accessible from secure storage

Phase 7: Dependencies
Prompt: Additional Package Dependencies
Add required dependencies for membership module.

**Update pubspec.yaml:**
```yaml
dependencies:
  # Existing dependencies...
  
  # QR Code generation
  qr_flutter: ^4.1.0
  
  # Currency formatting (if not already present)
  intl: ^0.19.0
```

**Usage notes:**

1. qr_flutter:
   - Used in QrCodeWidget to generate QR from string
   - Import: import 'package:qr_flutter/qr_flutter.dart';
   - Widget: QrImageView(data: qrData, size: size)

2. intl:
   - Used for currency formatting in payment amounts
   - NumberFormat.currency(locale: 'en_IN', symbol: '₹')
   - Or appropriate currency based on app requirements

**Requirements:**
- Run flutter pub get after adding
- Verify package compatibility with existing dependencies

Testing Prompts
Prompt: Membership Unit Tests
Implement unit tests for membership feature.

**Test files to create:**

1. `test/features/membership/domain/entities/membership_status_test.dart`
   - Test isExpired getter
   - Test shouldShowRenewalButton getter
   - Test formattedValidUntil formatting

2. `test/features/membership/domain/entities/renewal_options_test.dart`
   - Test selectedPlanIds getter
   - Test togglePlanSelection method
   - Test hasAswasePlusOption getter

3. `test/features/membership/infrastructure/repositories/membership_repository_impl_test.dart`
   - Test getMembershipData:
     - 200 response: data cached, timestamp stored, returns data
     - 304 response: returns null, cache not updated
     - Error: returns failure
     - Offline: returns cached data
   - Test getRenewalOptions: same patterns
   - Test getPaymentSummary:
     - Success with XCSRF token in header
     - Failure cases
   - Mock MembershipApi, MembershipLocalDataSource, ConnectivityChecker, SecureStore

4. `test/features/membership/application/usecases/fetch_membership_data_usecase_test.dart`
   - Test success path with fresh data
   - Test 304 path returns cached data
   - Test failure path

5. `test/features/membership/application/usecases/fetch_payment_summary_usecase_test.dart`
   - Test success with valid plan IDs
   - Test failure with empty plan IDs
   - Test API failure

6. `test/features/membership/application/providers/membership_notifier_test.dart`
   - Test initial state
   - Test loading preserves previous data
   - Test loaded state
   - Test error state preserves cached data

7. `test/features/membership/application/providers/renewal_notifier_test.dart`
   - Test plan selection toggle
   - Test state updates on selection change

**Test fixtures:**

8. `test/fixtures/membership_fixtures.dart`
   - Sample MembershipData entity
   - Sample RenewalOptions entity
   - Sample PaymentSummary entity
   - Sample API response JSONs
   - Sample 304 response
   - Factory methods for variations

**Requirements:**
- Use mocktail for mocks
- Test all state transitions
- Test if-modified-since logic thoroughly
- Test 304 handling specifically
- Test XCSRF token included in POST requests
Prompt: Membership Widget Tests
Implement widget tests for membership.

**Test files to create:**

1. `test/features/membership/presentation/screens/membership_screen_test.dart`
   - Test loading state shows shimmer
   - Test loaded state shows all sections
   - Test error state shows error banner with cached data
   - Test pull-to-refresh triggers fetch
   - Test renewal button visibility based on isRenewalDue
   - Test digital card with QR displayed
   - Test receipts section rendered
   - Mock providers

2. `test/features/membership/presentation/screens/renew_membership_screen_test.dart`
   - Test plan cards displayed
   - Test Aswas Plus card conditional visibility
   - Test plan selection toggles
   - Test proceed button disabled when no selection
   - Test proceed button enabled when plan selected
   - Test cancel navigation

3. `test/features/membership/presentation/screens/payment_method_screen_test.dart`
   - Test loading state during summary fetch
   - Test summary displayed correctly
   - Test amounts formatted properly
   - Test pay now button present

4. `test/features/membership/presentation/components/qr_code_widget_test.dart`
   - Test QR generated from valid data
   - Test handles empty data gracefully

5. `test/features/membership/presentation/components/plan_selection_card_test.dart`
   - Test selected state styling
   - Test unselected state styling
   - Test tap triggers callback

**Requirements:**
- Use ProviderScope with overrides
- Test all conditional rendering
- Verify accessibility (semantic labels)
- Test currency formatting in payment summary
- Golden tests for QR code rendering (optional)
Critical Implementation Rules
**ALWAYS FOLLOW THESE RULES FOR MEMBERSHIP MODULE:**

1. **if-modified-since pattern:**
   - Store separate timestamps for membership data and renewal options
   - Send stored timestamp in header on every GET request
   - On 304: use cached data, do NOT update timestamp
   - On 200: update cache AND timestamp

2. **X-CSRF-Token:**
   - Required for POST /api/v1/membership/payment-summary
   - Retrieve from SecureStore before POST requests
   - Include in request headers

3. **Graceful degradation:**
   - Always show cached data if available, even during loading/error
   - Loading state overlays cached data (shimmer or spinner)
   - Error state shows banner but displays cached data below

4. **304 is not an error:**
   - Dio interceptor must not throw on 304
   - Repository returns Right(null) for 304
   - Usecase interprets null as "use cached data"

5. **QR Code generation:**
   - Backend provides string data
   - Flutter generates QR using qr_flutter package
   - Handle empty/invalid data gracefully

6. **Plan selection:**
   - Single plan selection (user can opt for one - membership OR aswas plus)
   - Selection state managed via Riverpod provider
   - Selection persists during renewal flow navigation
   - Clear selection on cancel or successful payment

7. **Static elements (for now):**
   - Notification icon: static, no functionality
   - Renewal button: navigates but actual renewal logic placeholder
   - Download as PDF: static, show "Coming soon" or similar
   - Pay Now button: static, show "Coming soon" or similar
   - Receipt item taps: static

8. **Conditional rendering:**
   - Renewal button: only if isRenewalDue is true
   - Aswas Plus card in renewal: only if shouldShow is true
   - Active badge: reflects isActive boolean
   - Receipts section: hide if empty or show empty state

9. **Data refresh triggers:**
   - Screen navigation (initState or GoRouter listener)
   - Pull-to-refresh (membership screen only)
   - Manual retry from error state

10. **Currency formatting:**
    - Use consistent format throughout (₹ or appropriate symbol)
    - Handle decimal places properly (2 decimal places)
    - Use intl package for locale-aware formatting

11. **Navigation flow:**
    - Home -> Membership -> Renew -> Payment -> (future: Success)
    - Back navigation maintains proper stack
    - Cancel in renewal returns to Membership
    - Selected plans passed to payment screen

