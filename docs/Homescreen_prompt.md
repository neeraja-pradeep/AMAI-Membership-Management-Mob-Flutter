Homescreen Module - Enterprise Flutter Implementation Prompt
Module Overview
Module Name: Homescreen Description: The primary landing screen after authentication for admin-approved users. Displays user greeting, membership card, quick actions, optional Aswas Plus insurance card, upcoming events, and announcements. Position: First icon in bottom navigation bar Access Condition: User must be authenticated AND admin-approved
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
Prompt: Homescreen Domain Entities
Implement the homescreen domain layer entities.

**Files to create:**

1. `lib/features/home/domain/entities/home_user.dart`
   - HomeUser entity using Freezed
   - Fields: id (String), name (String), profileImageUrl (String?)
   - No JSON serialization (domain layer is pure)

2. `lib/features/home/domain/entities/membership_card.dart`
   - MembershipCard entity using Freezed
   - Fields: holderName (String), membershipNumber (String), validUntil (DateTime), isActive (bool)
   - Getter: bool get isExpired => validUntil.isBefore(DateTime.now())
   - Getter: String get displayValidUntil (formatted date string)

3. `lib/features/home/domain/entities/aswas_plus.dart`
   - AswasPlus entity using Freezed
   - Fields: hasSubscription (bool), policyNumber (String?), validUntil (DateTime?), isActive (bool), isRenewalDue (bool)
   - Getter: bool get shouldShowCard => hasSubscription
   - Getter: bool get shouldShowRenewButton => isRenewalDue

4. `lib/features/home/domain/entities/upcoming_event.dart`
   - UpcomingEvent entity using Freezed
   - Fields: id (String), name (String), imageUrl (String), eventDate (DateTime), eventTime (String), location (String)
   - Getter: String get formattedDate
   - Getter: String get formattedDateTime

5. `lib/features/home/domain/entities/announcement.dart`
   - Announcement entity using Freezed
   - Fields: id (String), title (String), content (String), createdAt (DateTime)

6. `lib/features/home/domain/entities/home_data.dart`
   - HomeData aggregate entity using Freezed
   - Fields: user (HomeUser), membershipCard (MembershipCard), aswasPlus (AswasPlus), upcomingEvents (List<UpcomingEvent>), announcements (List<Announcement>), timestamp (String)
   - Factory: HomeData.empty() for initial/loading state

7. `lib/features/home/domain/repositories/home_repository.dart`
   - Abstract class: HomeRepository
   - Methods:
     - Future<Either<Failure, HomeData?>> getHomeData({required String ifModifiedSince}) 
       // Returns HomeData on 200, null on 304
     - Future<String?> getStoredTimestamp()
     - Future<void> storeTimestamp(String timestamp)
     - Future<HomeData?> getCachedHomeData()

**Requirements:**
- Domain entities have no dependencies on external packages except Freezed
- Repository is abstract (contract only)
- Use fpdart Either for error handling
- Entities are immutable
- Handle 304 Not Modified scenario in repository contract

Phase 2: Infrastructure Layer
Prompt: Homescreen Infrastructure - Models
Implement the homescreen infrastructure models.

**Files to create:**

1. `lib/features/home/infrastructure/models/home_user_model.dart`
   - HomeUserModel with JSON serialization
   - Factory: fromJson, toJson
   - Method: toDomain() -> HomeUser
   - Use json_serializable

2. `lib/features/home/infrastructure/models/membership_card_model.dart`
   - MembershipCardModel with JSON serialization
   - Handle date parsing from ISO8601 string
   - Method: toDomain() -> MembershipCard

3. `lib/features/home/infrastructure/models/aswas_plus_model.dart`
   - AswasePlusModel with JSON serialization
   - Handle nullable fields properly
   - Method: toDomain() -> AswasPlus

4. `lib/features/home/infrastructure/models/upcoming_event_model.dart`
   - UpcomingEventModel with JSON serialization
   - Handle date/time parsing
   - Method: toDomain() -> UpcomingEvent

5. `lib/features/home/infrastructure/models/announcement_model.dart`
   - AnnouncementModel with JSON serialization
   - Method: toDomain() -> Announcement

6. `lib/features/home/infrastructure/models/home_data_model.dart`
   - HomeDataModel aggregate with JSON serialization
   - Contains all above models
   - Method: toDomain() -> HomeData
   - Handle timestamp extraction from response

**Requirements:**
- Models handle null safety for optional fields
- Date parsing must handle ISO8601 format
- All models are separate from domain entities
- Use json_serializable annotations
Prompt: Homescreen Infrastructure - Data Sources
Implement the homescreen data sources.

**Files to create:**

1. `lib/features/home/infrastructure/data_sources/remote/home_api.dart`
   - Abstract class: HomeApi
   - Implementation: HomeApiImpl
   - Constructor takes DioClient
   - Method: 
     Future<ApiResponse<HomeDataModel?>> fetchHomeData({required String ifModifiedSince})
     // Returns HomeDataModel on 200, null on 304
   - Must pass if-modified-since header
   - Must handle 304 response code without throwing error
   - Extract new timestamp from response headers on 200

2. `lib/features/home/infrastructure/data_sources/local/home_local_ds.dart`
   - Abstract class: HomeLocalDataSource
   - Implementation: HomeLocalDataSourceImpl
   - Constructor takes Hive box
   - Methods:
     - Future<void> cacheHomeData(HomeDataModel data)
     - Future<HomeDataModel?> getCachedHomeData()
     - Future<void> storeTimestamp(String timestamp)
     - Future<String?> getTimestamp()
     - Future<void> clearCache()
   - Store in Hive with appropriate keys

3. `lib/features/home/infrastructure/data_sources/remote/api_response.dart`
   - Generic ApiResponse<T> class
   - Fields: data (T?), statusCode (int), timestamp (String?)
   - Getter: bool get isNotModified => statusCode == 304
   - Getter: bool get isSuccess => statusCode == 200

**Requirements:**
- API must not throw on 304 - treat as valid response
- Local data source uses Hive for caching
- Timestamp stored separately for easy access
- Handle Dio response interceptor for 304 status
Prompt: Homescreen Infrastructure - Repository Implementation
Implement the homescreen repository.

**Files to create:**

1. `lib/features/home/infrastructure/repositories/home_repository_impl.dart`
   - HomeRepositoryImpl implements HomeRepository
   - Constructor takes: HomeApi, HomeLocalDataSource, ConnectivityChecker
   - Implement getHomeData:
     1. Check connectivity
     2. If online: call API with if-modified-since header
        - On 200: map to domain, cache data, store new timestamp, return Right(HomeData)
        - On 304: return Right(null) to indicate use cached data
        - On error: return Left(Failure)
     3. If offline: return cached data or NetworkFailure
   - Implement getStoredTimestamp: delegate to local data source
   - Implement storeTimestamp: delegate to local data source  
   - Implement getCachedHomeData: get from local, map to domain

**Requirements:**
- Repository handles online/offline logic
- 304 response returns null (not failure)
- All API errors mapped to typed Failures
- Caching only on 200 response
- Timestamp management encapsulated in repository

Phase 3: Application Layer
Prompt: Homescreen Application - State
Implement the homescreen application state.

**Files to create:**

1. `lib/features/home/application/states/home_state.dart`
   - HomeState using Freezed
   - States:
     - initial()
     - loading(HomeData? previousData) // Show previous data while loading
     - loaded(HomeData data)
     - error(Failure failure, HomeData? cachedData) // Can show cached data on error
   - Helpers:
     - HomeData? get currentData // Returns data from any state that has it
     - bool get isLoading
     - bool get hasError
     - bool get hasMembershipCard
     - bool get hasAswasPlus
     - bool get hasEvents
     - bool get hasAnnouncements

**Requirements:**
- State supports showing cached/previous data during loading
- State supports showing cached data on error (graceful degradation)
- Helpers make UI logic simple
Prompt: Homescreen Application - Usecases
Implement the homescreen usecases.

**Files to create:**

1. `lib/features/home/application/usecases/fetch_home_data_usecase.dart`
   - FetchHomeDataUsecase class
   - Takes HomeRepository
   - call() method:
     1. Get stored timestamp (use empty string if none)
     2. Call repository.getHomeData(ifModifiedSince: timestamp)
     3. If Right(HomeData): data was updated, return it
     4. If Right(null): 304, get cached data and return
     5. If Left(Failure): return failure
   - Returns Future<Either<Failure, HomeData>>

2. `lib/features/home/application/usecases/get_cached_home_data_usecase.dart`
   - GetCachedHomeDataUsecase class
   - Takes HomeRepository
   - call() -> Future<Either<Failure, HomeData?>>
   - Used for initial load before API call

**Requirements:**
- Usecases encapsulate the if-modified-since logic
- Single responsibility per usecase
- Proper error propagation
Prompt: Homescreen Application - Providers
Implement the homescreen providers.

**Files to create:**

1. `lib/features/home/application/providers/home_providers.dart`
   - Provider for HomeRepository (impl with dependencies)
   - Provider for FetchHomeDataUsecase
   - Provider for GetCachedHomeDataUsecase
   - homeStateProvider: AsyncNotifierProvider<HomeNotifier, HomeState>

2. `lib/features/home/application/providers/home_notifier.dart`
   - HomeNotifier extends AsyncNotifier<HomeState>
   - build(): Initialize with cached data if available, then fetch fresh
   - Methods:
     - Future<void> fetchHomeData(): 
       1. Set loading state (preserve previous data)
       2. Execute FetchHomeDataUsecase
       3. On success: set loaded state with new data
       4. On failure: set error state (preserve cached data for display)
     - Future<void> refresh(): Force fetch (user pull-to-refresh)
   - Auto-fetch on screen navigation (handled by UI)

**Requirements:**
- Notifier preserves data during loading/error for smooth UX
- Use riverpod_generator annotations
- Proper error handling with cached data fallback
- State transitions are atomic

Phase 4: Presentation Layer
Prompt: Homescreen Presentation - Screen
Implement the homescreen screen.

**Files to create:**

1. `lib/features/home/presentation/screens/home_screen.dart`
   - HomeScreen (ConsumerStatefulWidget)
   - Uses AppScaffold
   - Triggers fetchHomeData on initState/navigation
   - Pull-to-refresh support (RefreshIndicator)
   - Handles all states: loading, loaded, error
   - Shows cached data during loading (shimmer overlay optional)
   - Shows cached data on error with error banner
   - SingleChildScrollView with Column layout
   - Composed of separate components

**Screen Layout Structure (top to bottom):**
1. HomeHeader (greeting + notification + profile icons)
2. MembershipCardWidget
3. QuickActionsSection
4. AswasePlusCardWidget (conditional)
5. UpcomingEventsSection
6. AnnouncementsSection

**Requirements:**
- Fully responsive using ScreenUtil
- Proper loading/error state handling
- Graceful degradation (show cached data on error)
- Pull-to-refresh triggers full data fetch
- Each section is a separate component
Prompt: Homescreen Presentation - Components (Part 1)
Implement the homescreen header and membership card components.

**Files to create:**

1. `lib/features/home/presentation/components/home_header.dart`
   - HomeHeader widget (StatelessWidget)
   - Props: userName (String)
   - Layout:
     - Left: "Hi, {userName}" text (use AppTypography.headlineMedium)
     - Right: Row with notification icon button (static) and profile icon button (static)
   - Icons use AppColors, proper touch targets (48x48 minimum)
   - Responsive spacing using ScreenUtil

2. `lib/features/home/presentation/components/membership_card_widget.dart`
   - MembershipCardWidget (StatelessWidget)
   - Props: membershipCard (MembershipCard entity)
   - Card design:
     - Top row: "AMAI MEMBERSHIP CARD" text (left), "ACTIVE" badge (right, conditional on isActive)
     - Middle: Holder name (prominent)
     - Bottom row: Membership number (left), "Valid Till: {date}" (right)
   - Use AppCard with custom styling
   - Active badge: Green background with white text, rounded corners
   - Proper elevation and border radius
   - Responsive sizing

3. `lib/features/home/presentation/components/active_badge.dart`
   - Reusable ActiveBadge widget
   - Props: isActive (bool), label (String, default "ACTIVE")
   - Green when active, grey when inactive
   - Consistent styling across membership and Aswas Plus cards

**Requirements:**
- All text uses theme typography
- All colors from AppColors
- ScreenUtil for all dimensions
- Semantic labels for accessibility
Prompt: Homescreen Presentation - Components (Part 2)
Implement the quick actions and Aswas Plus card components.

**Files to create:**

1. `lib/features/home/presentation/components/quick_actions_section.dart`
   - QuickActionsSection widget (StatelessWidget)
   - No props (static for now)
   - Layout:
     - Header row: "Quick Actions" title (left), "View All" button (right, static)
     - Grid/Row of action items: Memberships, Aswas Plus, Academy, Contacts
   - Each action item: icon + label, tappable (static onTap for now)
   - Use consistent icon style
   - Horizontal scrollable or grid layout

2. `lib/features/home/presentation/components/quick_action_item.dart`
   - QuickActionItem widget (StatelessWidget)
   - Props: icon (IconData), label (String), onTap (VoidCallback)
   - Consistent sizing and spacing
   - Tap feedback

3. `lib/features/home/presentation/components/aswas_plus_card_widget.dart`
   - AswasePlusCardWidget (StatelessWidget)
   - Props: aswasPlus (AswasPlus entity)
   - Only renders if aswasPlus.shouldShowCard is true
   - Card design:
     - Top row: "ASWAS PLUS Insurance" heading (left), "ACTIVE" badge (right, conditional)
     - Middle: Policy number display
     - Middle: "Valid Until: {date}" display
     - Bottom row: "Renew Policy" button (conditional on isRenewalDue, static), "View Details" button (static)
   - Similar styling to membership card but distinct
   - Buttons use AppButton variants

**Requirements:**
- AswasePlus card visibility controlled by entity flag
- Renew button visibility controlled by entity flag
- Consistent card styling with membership card
- All actions static (placeholder callbacks)
Prompt: Homescreen Presentation - Components (Part 3)
Implement the upcoming events and announcements components.

**Files to create:**

1. `lib/features/home/presentation/components/upcoming_events_section.dart`
   - UpcomingEventsSection widget (StatelessWidget)
   - Props: events (List<UpcomingEvent>)
   - Layout:
     - Section header: "Upcoming Events" title
     - Horizontal scrollable list of event cards
   - Handle empty state (no events message or hide section)

2. `lib/features/home/presentation/components/event_card.dart`
   - EventCard widget (StatelessWidget)
   - Props: event (UpcomingEvent entity)
   - Card design:
     - Top: Event image (network image with placeholder/error handling)
     - Below image: Event name (prominent)
     - Below name: Date and time row
     - Below date: Location with icon
     - Bottom: "Register Now" button (static)
   - Fixed width for horizontal scroll
   - Proper image aspect ratio
   - Rounded corners, elevation

3. `lib/features/home/presentation/components/announcements_section.dart`
   - AnnouncementsSection widget (StatelessWidget)  
   - Props: announcements (List<Announcement>)
   - Layout:
     - Header row: "Announcements" title (left), "View All" button (right, static)
     - Vertical list of announcement items (show first 3-5)
   - Handle empty state

4. `lib/features/home/presentation/components/announcement_item.dart`
   - AnnouncementItem widget (StatelessWidget)
   - Props: announcement (Announcement entity)
   - Layout: Title, truncated content preview, date
   - Tappable (static, for future detail navigation)

**Requirements:**
- Event images use cached network image with loading/error states
- Lists handle empty states gracefully
- Horizontal scroll has proper padding and snap behavior
- Announcement content truncated with ellipsis
- All spacing responsive with ScreenUtil
Prompt: Homescreen Presentation - Loading and Error States
Implement loading and error state components for homescreen.

**Files to create:**

1. `lib/features/home/presentation/components/home_loading_shimmer.dart`
   - HomeLoadingShimmer widget (StatelessWidget)
   - Shimmer/skeleton loading that matches home screen layout
   - Placeholder for: header, membership card, quick actions, events, announcements
   - Use shimmer package or custom implementation
   - Matches actual component sizes

2. `lib/features/home/presentation/components/home_error_banner.dart`
   - HomeErrorBanner widget (StatelessWidget)
   - Props: failure (Failure), onRetry (VoidCallback)
   - Displayed at top of screen when error occurs but cached data shown
   - User-friendly error message from failure.toUserMessage()
   - Retry button
   - Dismissible optional

3. `lib/features/home/presentation/components/home_empty_state.dart`
   - HomeEmptyState widget (StatelessWidget)
   - For case when no cached data and API fails
   - Error illustration/icon
   - Message explaining the issue
   - Retry button

**Requirements:**
- Shimmer matches actual layout for smooth transition
- Error states don't block cached data display
- Retry actions trigger fetchHomeData
- Accessible error messages

Phase 5: Hive Configuration
Prompt: Homescreen Hive Setup
Implement Hive configuration for homescreen caching.

**Files to create:**

1. `lib/features/home/infrastructure/hive/home_box_keys.dart`
   - Static class: HomeBoxKeys
   - Constants:
     - static const boxName = 'home_box'
     - static const homeDataKey = 'home_data'
     - static const timestampKey = 'home_timestamp'

2. `lib/features/home/infrastructure/hive/adapters/home_data_adapter.dart`
   - Hive TypeAdapter for HomeDataModel
   - TypeId: [assign unique number]
   - Handle all nested models

3. `lib/features/home/infrastructure/hive/adapters/` (all model adapters)
   - Individual adapters for each model that needs caching:
     - HomeUserModelAdapter
     - MembershipCardModelAdapter
     - AswasePlusModelAdapter
     - UpcomingEventModelAdapter
     - AnnouncementModelAdapter

4. Update `lib/app/bootstrap/hive_init.dart`
   - Register all home feature adapters
   - Open home box

**Requirements:**
- TypeIds must be unique across entire app
- Adapters handle nullable fields
- Box opened lazily or during bootstrap
- Models stored as-is (not domain entities)

Phase 6: Integration
Prompt: Homescreen Route and Navigation Integration
Integrate homescreen into app routing.

**Files to update:**

1. `lib/app/router/routes.dart`
   - Add: static const home = '/home'

2. `lib/app/router/app_router.dart`
   - Add home route inside main shell (bottom navigation)
   - Home is first tab/index 0
   - Route should trigger data fetch on navigation (GoRouter listener or screen initState)

3. `lib/app/router/guards/auth_guard.dart`
   - Ensure authenticated + admin-approved users go to home
   - Redirect unapproved users to pending approval screen

**Requirements:**
- Home is default destination after auth for approved users
- Bottom navigation properly configured with home as first item
- Navigation triggers data refresh
Prompt: Homescreen Provider Integration
Integrate homescreen providers with app-level providers.

**Files to create/update:**

1. `lib/features/home/application/providers/home_providers.dart`
   - Ensure all dependencies are properly injected:
     - DioClient from core providers
     - Hive box for home
     - ConnectivityChecker from core
   - Export all public providers

2. `lib/features/home/home.dart` (barrel export)
   - Export all public APIs:
     - Entities
     - Providers (only homeStateProvider for external use)
     - HomeScreen widget

**Requirements:**
- Clean public API via barrel exports
- Internal implementation details not exposed
- Providers properly scoped

Testing Prompts
Prompt: Homescreen Unit Tests
Implement unit tests for homescreen feature.

**Test files to create:**

1. `test/features/home/domain/entities/membership_card_test.dart`
   - Test isExpired getter
   - Test displayValidUntil formatting

2. `test/features/home/infrastructure/repositories/home_repository_impl_test.dart`
   - Test 200 response handling (data cached, timestamp stored)
   - Test 304 response handling (returns null, cache not updated)
   - Test error handling
   - Test offline scenario (returns cached data)
   - Mock HomeApi, HomeLocalDataSource, ConnectivityChecker

3. `test/features/home/application/usecases/fetch_home_data_usecase_test.dart`
   - Test success path with fresh data
   - Test 304 path returns cached data
   - Test failure path
   - Mock HomeRepository

4. `test/features/home/application/providers/home_notifier_test.dart`
   - Test initial state
   - Test loading preserves previous data
   - Test loaded state
   - Test error state preserves cached data
   - Use ProviderContainer with overrides

**Test fixtures:**

5. `test/fixtures/home_fixtures.dart`
   - Sample HomeData entity
   - Sample API response JSON
   - Sample 304 response
   - Factory methods for variations

**Requirements:**
- Use mocktail for mocks
- Test all state transitions
- Test if-modified-since logic thoroughly
- Test 304 handling specifically
Prompt: Homescreen Widget Tests
Implement widget tests for homescreen.

**Test files to create:**

1. `test/features/home/presentation/screens/home_screen_test.dart`
   - Test loading state shows shimmer
   - Test loaded state shows all sections
   - Test error state shows error banner with cached data
   - Test pull-to-refresh triggers fetch
   - Test conditional Aswas Plus card visibility
   - Mock providers

2. `test/features/home/presentation/components/membership_card_widget_test.dart`
   - Test active badge visibility
   - Test data display
   - Test formatting

3. `test/features/home/presentation/components/aswas_plus_card_widget_test.dart`
   - Test card not shown when hasSubscription is false
   - Test renew button visibility based on isRenewalDue
   - Test data display

**Requirements:**
- Use ProviderScope with overrides
- Test all conditional rendering
- Verify accessibility (semantic labels)
- Golden tests for visual regression (optional)

Critical Implementation Rules
**ALWAYS FOLLOW THESE RULES FOR HOMESCREEN MODULE:**

1. **if-modified-since pattern:**
   - Store timestamp in Hive after every successful 200 response
   - Send stored timestamp in header on every request
   - On 304: use cached data, do NOT update timestamp
   - On 200: update cache AND timestamp

2. **X-CSRF-Token:**
   - Not required for GET /api/v1/home
   - Will be required for future POST endpoints (event registration, etc.)

3. **Graceful degradation:**
   - Always show cached data if available, even during loading/error
   - Loading state overlays cached data (shimmer or spinner)
   - Error state shows banner but displays cached data below

4. **304 is not an error:**
   - Dio interceptor must not throw on 304
   - Repository returns Right(null) for 304
   - Usecase interprets null as "use cached data"

5. **Static elements (for now):**
   - Notification icon: static, no functionality
   - Profile icon: static, no functionality  
   - Quick action items: static onTap callbacks
   - View All buttons: static
   - Register Now buttons: static
   - Renew Policy button: static
   - View Details button: static

6. **Conditional rendering:**
   - Aswas Plus card: only if hasSubscription is true
   - Renew Policy button: only if isRenewalDue is true
   - Active badges: reflect isActive boolean

7. **Data refresh triggers:**
   - Screen navigation (initState or GoRouter listener)
   - Pull-to-refresh
   - Manual retry from error state

