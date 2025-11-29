Academy & Contacts Module - Enterprise Flutter Implementation Prompt
Module Overview
Module Name: Academy & Contacts Description: Two simple static information screens displaying contact details with click-to-call functionality. Academy shows academy-related information and contact, Contacts shows general organization contacts. Entry Points:
Quick Actions > Academy from Homescreen
Quick Actions > Contacts from Homescreen Sub-screens:
Academy Screen
Contacts Screen
Note: These are primarily static screens with minimal API interaction. The if-modified-since pattern applies if contact data is fetched from backend, otherwise data can be bundled locally or fetched once.
Phase 1: Domain Layer
Prompt: Academy & Contacts Domain Entities
Implement the Academy and Contacts domain layer entities.

**Files to create:**

1. `lib/features/academy/domain/entities/academy_info.dart`
   - AcademyInfo entity using Freezed
   - Fields: title (String), description (String), contactNumbers (List<ContactNumber>), additionalInfo (String?), timestamp (String)
   - Factory: AcademyInfo.empty() for initial/loading state
   - Getter: bool get hasContacts => contactNumbers.isNotEmpty
   - Getter: ContactNumber? get primaryContact (first where isPrimary or first in list)
   - No JSON serialization (domain layer is pure)

2. `lib/features/academy/domain/entities/contact_number.dart`
   - ContactNumber entity using Freezed
   - Fields: id (String), label (String), phoneNumber (String), isPrimary (bool)
   - Getter: String get displayNumber (formatted phone number)
   - Getter: String get dialableNumber (stripped for tel: URI)

3. `lib/features/academy/domain/repositories/academy_repository.dart`
   - Abstract class: AcademyRepository
   - Methods (all return Future<Either<Failure, T>>):
     - getAcademyInfo({required String ifModifiedSince}) -> AcademyInfo?
       // Returns AcademyInfo on 200, null on 304
     - Future<String?> getStoredTimestamp()
     - Future<void> storeTimestamp(String timestamp)
     - Future<AcademyInfo?> getCachedAcademyInfo()
   
   **Alternative if static:**
   - getAcademyInfo() -> AcademyInfo (no API, returns local data)

4. `lib/features/contacts/domain/entities/contacts_info.dart`
   - ContactsInfo entity using Freezed
   - Fields: title (String), description (String?), contacts (List<ContactPerson>), timestamp (String)
   - Factory: ContactsInfo.empty() for initial/loading state
   - Getter: bool get hasContacts => contacts.isNotEmpty
   - Getter: List<ContactPerson> getByCategory(String category)

5. `lib/features/contacts/domain/entities/contact_person.dart`
   - ContactPerson entity using Freezed
   - Fields: id (String), name (String), designation (String?), phoneNumber (String), email (String?), category (String?)
   - Getter: String get displayNumber
   - Getter: String get dialableNumber
   - Getter: bool get hasEmail => email != null && email!.isNotEmpty

6. `lib/features/contacts/domain/repositories/contacts_repository.dart`
   - Abstract class: ContactsRepository
   - Methods (all return Future<Either<Failure, T>>):
     - getContactsInfo({required String ifModifiedSince}) -> ContactsInfo?
       // Returns ContactsInfo on 200, null on 304
     - Future<String?> getStoredTimestamp()
     - Future<void> storeTimestamp(String timestamp)
     - Future<ContactsInfo?> getCachedContactsInfo()
   
   **Alternative if static:**
   - getContactsInfo() -> ContactsInfo (no API, returns local data)

**Requirements:**
- Domain entities have no dependencies on external packages except Freezed
- Repository is abstract (contract only)
- Use fpdart Either for error handling
- Entities are immutable
- Handle both API-based and static data scenarios
- Phone numbers stored in dialable format

Phase 2: Infrastructure Layer
Prompt: Academy & Contacts Infrastructure - Models
Implement the Academy and Contacts infrastructure models.

**Files to create:**

1. `lib/features/academy/infrastructure/models/academy_info_model.dart`
   - AcademyInfoModel with JSON serialization
   - Factory: fromJson, toJson
   - Method: toDomain() -> AcademyInfo
   - Use json_serializable

2. `lib/features/academy/infrastructure/models/contact_number_model.dart`
   - ContactNumberModel with JSON serialization
   - Factory: fromJson, toJson
   - Method: toDomain() -> ContactNumber

3. `lib/features/contacts/infrastructure/models/contacts_info_model.dart`
   - ContactsInfoModel with JSON serialization
   - Factory: fromJson, toJson
   - Method: toDomain() -> ContactsInfo

4. `lib/features/contacts/infrastructure/models/contact_person_model.dart`
   - ContactPersonModel with JSON serialization
   - Handle nullable fields (designation, email, category)
   - Method: toDomain() -> ContactPerson

**Requirements:**
- Models handle null safety for optional fields
- All models are separate from domain entities
- Use json_serializable annotations
- Phone numbers preserved as-is from API
Prompt: Academy & Contacts Infrastructure - Data Sources
Implement the Academy and Contacts data sources.

**Files to create:**

1. `lib/features/academy/infrastructure/data_sources/remote/academy_api.dart`
   - Abstract class: AcademyApi
   - Implementation: AcademyApiImpl
   - Constructor takes DioClient
   - Methods:
     - Future<ApiResponse<AcademyInfoModel?>> fetchAcademyInfo({required String ifModifiedSince})
       // Returns AcademyInfoModel on 200, null on 304
   - Must pass if-modified-since header
   - Must handle 304 response code without throwing error
   - Extract new timestamp from response headers on 200

2. `lib/features/academy/infrastructure/data_sources/local/academy_local_ds.dart`
   - Abstract class: AcademyLocalDataSource
   - Implementation: AcademyLocalDataSourceImpl
   - Constructor takes Hive box
   - Methods:
     - Future<void> cacheAcademyInfo(AcademyInfoModel data)
     - Future<AcademyInfoModel?> getCachedAcademyInfo()
     - Future<void> storeTimestamp(String timestamp)
     - Future<String?> getTimestamp()
     - Future<void> clearCache()

3. `lib/features/academy/infrastructure/data_sources/local/academy_static_data.dart`
   - **Alternative for static data approach**
   - Static class: AcademyStaticData
   - Method: AcademyInfoModel getData() -> returns hardcoded academy info
   - Contains all static text and contact numbers
   - Used if no API endpoint exists

4. `lib/features/contacts/infrastructure/data_sources/remote/contacts_api.dart`
   - Abstract class: ContactsApi
   - Implementation: ContactsApiImpl
   - Constructor takes DioClient
   - Methods:
     - Future<ApiResponse<ContactsInfoModel?>> fetchContactsInfo({required String ifModifiedSince})
       // Returns ContactsInfoModel on 200, null on 304
   - Same patterns as AcademyApi

5. `lib/features/contacts/infrastructure/data_sources/local/contacts_local_ds.dart`
   - Abstract class: ContactsLocalDataSource
   - Implementation: ContactsLocalDataSourceImpl
   - Same patterns as AcademyLocalDataSource

6. `lib/features/contacts/infrastructure/data_sources/local/contacts_static_data.dart`
   - **Alternative for static data approach**
   - Static class: ContactsStaticData
   - Method: ContactsInfoModel getData() -> returns hardcoded contacts info
   - Contains all static contact information

**Requirements:**
- API must not throw on 304 - treat as valid response
- Local data source uses Hive for caching
- Static data classes provided as alternative
- Handle Dio response interceptor for 304 status
- No POST requests needed (read-only modules)
Prompt: Academy & Contacts Infrastructure - Repository Implementation
Implement the Academy and Contacts repositories.

**Files to create:**

1. `lib/features/academy/infrastructure/repositories/academy_repository_impl.dart`
   - AcademyRepositoryImpl implements AcademyRepository
   - Constructor takes: AcademyApi, AcademyLocalDataSource, ConnectivityChecker
   
   - Implement getAcademyInfo:
     1. Check connectivity
     2. If online: call API with if-modified-since header
        - On 200: map to domain, cache data, store new timestamp, return Right(AcademyInfo)
        - On 304: return Right(null) to indicate use cached data
        - On error: return Left(Failure)
     3. If offline: return cached data or NetworkFailure
   
   - Implement timestamp methods: delegate to local data source
   - Implement cache methods: get from local, map to domain

2. `lib/features/academy/infrastructure/repositories/academy_static_repository_impl.dart`
   - **Alternative for static data approach**
   - AcademyStaticRepositoryImpl implements AcademyRepository
   - getAcademyInfo: return Right(AcademyStaticData.getData().toDomain())
   - No caching needed (data is bundled)
   - No network calls

3. `lib/features/contacts/infrastructure/repositories/contacts_repository_impl.dart`
   - ContactsRepositoryImpl implements ContactsRepository
   - Same pattern as AcademyRepositoryImpl

4. `lib/features/contacts/infrastructure/repositories/contacts_static_repository_impl.dart`
   - **Alternative for static data approach**
   - Same pattern as AcademyStaticRepositoryImpl

**Requirements:**
- Repository handles online/offline logic
- 304 response returns null (not failure)
- All API errors mapped to typed Failures
- Caching only on 200 response
- Static repository alternatives provided for purely static data
- Choose appropriate implementation based on backend availability

Phase 3: Application Layer
Prompt: Academy & Contacts Application - States
Implement the Academy and Contacts application states.

**Files to create:**

1. `lib/features/academy/application/states/academy_state.dart`
   - AcademyState using Freezed
   - States:
     - initial()
     - loading(AcademyInfo? previousData)
     - loaded(AcademyInfo data)
     - error(Failure failure, AcademyInfo? cachedData)
   - Helpers:
     - AcademyInfo? get currentData
     - bool get isLoading
     - bool get hasError
     - bool get hasContacts => currentData?.hasContacts ?? false
     - ContactNumber? get primaryContact => currentData?.primaryContact

2. `lib/features/contacts/application/states/contacts_state.dart`
   - ContactsState using Freezed
   - States:
     - initial()
     - loading(ContactsInfo? previousData)
     - loaded(ContactsInfo data)
     - error(Failure failure, ContactsInfo? cachedData)
   - Helpers:
     - ContactsInfo? get currentData
     - bool get isLoading
     - bool get hasError
     - bool get hasContacts => currentData?.hasContacts ?? false
     - List<ContactPerson> get allContacts => currentData?.contacts ?? []

**Requirements:**
- States support showing cached/previous data during loading
- States support showing cached data on error (graceful degradation)
- Helpers make UI logic simple
- Simple state structure for simple screens
Prompt: Academy & Contacts Application - Usecases
Implement the Academy and Contacts usecases.

**Files to create:**

1. `lib/features/academy/application/usecases/fetch_academy_info_usecase.dart`
   - FetchAcademyInfoUsecase class
   - Takes AcademyRepository
   - call() method:
     1. Get stored timestamp (use empty string if none)
     2. Call repository.getAcademyInfo(ifModifiedSince: timestamp)
     3. If Right(AcademyInfo): data was updated, return it
     4. If Right(null): 304, get cached data and return
     5. If Left(Failure): return failure
   - Returns Future<Either<Failure, AcademyInfo>>

2. `lib/features/academy/application/usecases/get_cached_academy_info_usecase.dart`
   - GetCachedAcademyInfoUsecase class
   - Takes AcademyRepository
   - call() -> Future<Either<Failure, AcademyInfo?>>
   - Used for initial load before API call

3. `lib/features/contacts/application/usecases/fetch_contacts_info_usecase.dart`
   - FetchContactsInfoUsecase class
   - Takes ContactsRepository
   - Same pattern as FetchAcademyInfoUsecase
   - Returns Future<Either<Failure, ContactsInfo>>

4. `lib/features/contacts/application/usecases/get_cached_contacts_info_usecase.dart`
   - GetCachedContactsInfoUsecase class
   - Same pattern as GetCachedAcademyInfoUsecase

**Requirements:**
- Usecases encapsulate the if-modified-since logic
- Single responsibility per usecase
- Proper error propagation
- Simple usecases for simple data fetching
Prompt: Academy & Contacts Application - Providers
Implement the Academy and Contacts providers.

**Files to create:**

1. `lib/features/academy/application/providers/academy_providers.dart`
   - Provider for AcademyRepository (impl with dependencies)
   - Provider for FetchAcademyInfoUsecase
   - Provider for GetCachedAcademyInfoUsecase
   - academyStateProvider: AsyncNotifierProvider<AcademyNotifier, AcademyState>

2. `lib/features/academy/application/providers/academy_notifier.dart`
   - AcademyNotifier extends AsyncNotifier<AcademyState>
   - build(): Initialize with cached data if available, then fetch fresh
   - Methods:
     - Future<void> fetchAcademyInfo():
       1. Set loading state (preserve previous data)
       2. Execute FetchAcademyInfoUsecase
       3. On success: set loaded state with new data
       4. On failure: set error state (preserve cached data for display)
     - Future<void> refresh(): Force fetch

3. `lib/features/contacts/application/providers/contacts_providers.dart`
   - Provider for ContactsRepository (impl with dependencies)
   - Provider for FetchContactsInfoUsecase
   - Provider for GetCachedContactsInfoUsecase
   - contactsStateProvider: AsyncNotifierProvider<ContactsNotifier, ContactsState>

4. `lib/features/contacts/application/providers/contacts_notifier.dart`
   - ContactsNotifier extends AsyncNotifier<ContactsState>
   - Same pattern as AcademyNotifier

**Requirements:**
- Use riverpod_generator annotations where beneficial
- Providers properly scoped and documented
- State changes are atomic
- Simple notifiers for simple screens
- Side effects (storage, API) in usecases, not notifier directly

Phase 4: Presentation Layer
Prompt: Academy Presentation - Screen
Implement the Academy screen.

**Files to create:**

1. `lib/features/academy/presentation/screens/academy_screen.dart`
   - AcademyScreen (ConsumerStatefulWidget)
   - Uses AppScaffold with custom AppBar
   - AppBar: Back button (left), "Academy" title (center)
   - Triggers fetchAcademyInfo on initState/navigation
   - Handles all states: loading, loaded, error
   - Shows cached data during loading
   - Shows cached data on error with error banner
   - SingleChildScrollView with Column layout

**Screen Layout Structure (top to bottom):**
1. AcademyDescriptionSection (static text)
2. AcademyContactSection (phone numbers with click-to-call)

**Navigation:**
- Back button navigates to HomeScreen
- Phone number tap opens phone dialer

**Requirements:**
- Fully responsive using ScreenUtil
- Proper loading/error state handling
- Graceful degradation (show cached data on error)
- Simple, clean layout
- Click-to-call functionality using url_launcher
Prompt: Academy Presentation - Components
Implement the Academy screen components.

**Files to create:**

1. `lib/features/academy/presentation/components/academy_description_section.dart`
   - AcademyDescriptionSection widget (StatelessWidget)
   - Props: description (String), additionalInfo (String?)
   - Display static text about the academy
   - Proper text formatting and readability
   - May include title/heading
   - Appropriate typography from theme

2. `lib/features/academy/presentation/components/academy_contact_section.dart`
   - AcademyContactSection widget (StatelessWidget)
   - Props: contactNumbers (List<ContactNumber>)
   - Display contact numbers with click-to-call
   - Each number shown with phone icon
   - Tapping triggers phone dialer via url_launcher

3. `lib/features/academy/presentation/components/clickable_phone_number.dart`
   - ClickablePhoneNumber widget (StatelessWidget)
   - Props: contactNumber (ContactNumber entity), showLabel (bool)
   - Layout:
     - Phone icon (left)
     - Phone number text (right)
     - Optional label above or beside
   - InkWell/GestureDetector for tap handling
   - onTap: launch tel: URI with url_launcher
   - Visual feedback on tap
   - Proper touch target size (min 48x48)

4. `lib/features/academy/presentation/components/academy_loading_shimmer.dart`
   - AcademyLoadingShimmer widget (StatelessWidget)
   - Simple shimmer for text blocks and contact area
   - Matches actual layout

5. `lib/features/academy/presentation/components/academy_error_view.dart`
   - AcademyErrorView widget (StatelessWidget)
   - Props: failure (Failure), onRetry (VoidCallback), hasCachedData (bool)
   - Standard error handling pattern

**Requirements:**
- Click-to-call uses url_launcher with tel: scheme
- Handle launch failure gracefully (show error if can't open dialer)
- Phone numbers clearly tappable
- Accessible (semantic labels for phone actions)
- Simple, focused UI
Prompt: Contacts Presentation - Screen
Implement the Contacts screen.

**Files to create:**

1. `lib/features/contacts/presentation/screens/contacts_screen.dart`
   - ContactsScreen (ConsumerStatefulWidget)
   - Uses AppScaffold with custom AppBar
   - AppBar: Back button (left), "Contacts" title (center)
   - Triggers fetchContactsInfo on initState/navigation
   - Handles all states: loading, loaded, error
   - Shows cached data during loading
   - Shows cached data on error with error banner
   - SingleChildScrollView with Column layout

**Screen Layout Structure (top to bottom):**
1. ContactsDescriptionSection (optional description text)
2. ContactsListSection (list of contacts with phone/email)

**Navigation:**
- Back button navigates to HomeScreen
- Phone number tap opens phone dialer
- Email tap opens email client (if email available)

**Requirements:**
- Fully responsive using ScreenUtil
- Proper loading/error state handling
- Graceful degradation (show cached data on error)
- Multiple contacts displayed in list
- Click-to-call and click-to-email functionality
Prompt: Contacts Presentation - Components
Implement the Contacts screen components.

**Files to create:**

1. `lib/features/contacts/presentation/components/contacts_description_section.dart`
   - ContactsDescriptionSection widget (StatelessWidget)
   - Props: title (String), description (String?)
   - Display optional description/intro text
   - Only rendered if description is not null/empty

2. `lib/features/contacts/presentation/components/contacts_list_section.dart`
   - ContactsListSection widget (StatelessWidget)
   - Props: contacts (List<ContactPerson>)
   - Display list of contact person items
   - May group by category if categories present
   - Handle empty list gracefully

3. `lib/features/contacts/presentation/components/contact_person_card.dart`
   - ContactPersonCard widget (StatelessWidget)
   - Props: contact (ContactPerson entity)
   - Card/tile design:
     - Name (prominent)
     - Designation (if available, below name)
     - Phone number with phone icon (clickable)
     - Email with email icon (clickable, if available)
   - Tapping phone opens dialer
   - Tapping email opens email client

4. `lib/features/contacts/presentation/components/clickable_email.dart`
   - ClickableEmail widget (StatelessWidget)
   - Props: email (String)
   - Layout:
     - Email icon (left)
     - Email address text (right)
   - onTap: launch mailto: URI with url_launcher
   - Visual feedback on tap

5. `lib/features/contacts/presentation/components/contacts_loading_shimmer.dart`
   - ContactsLoadingShimmer widget (StatelessWidget)
   - Shimmer for list of contact cards
   - Matches actual layout

6. `lib/features/contacts/presentation/components/contacts_error_view.dart`
   - ContactsErrorView widget (StatelessWidget)
   - Props: failure (Failure), onRetry (VoidCallback), hasCachedData (bool)
   - Standard error handling pattern

**Requirements:**
- Click-to-call uses url_launcher with tel: scheme
- Click-to-email uses url_launcher with mailto: scheme
- Handle launch failures gracefully
- Contact cards clearly display all available info
- Accessible (semantic labels)
- Reuse ClickablePhoneNumber from academy module if appropriate

Phase 5: Shared Components
Prompt: Shared Click-to-Action Widgets
Create shared clickable action widgets for reuse across Academy and Contacts.

**Files to create:**

1. `lib/core/widgets/clickable_phone.dart`
   - ClickablePhone widget (StatelessWidget)
   - Props: phoneNumber (String), label (String?), showIcon (bool, default true), style (TextStyle?)
   - Layout:
     - Phone icon (optional)
     - Phone number text
     - Label above or beside (optional)
   - onTap: launch tel:{phoneNumber} URI
   - Handle launch failure with snackbar or dialog
   - Proper touch target size
   - Visual feedback on tap

2. `lib/core/widgets/clickable_email.dart`
   - ClickableEmail widget (StatelessWidget)
   - Props: email (String), showIcon (bool, default true), style (TextStyle?)
   - Layout:
     - Email icon (optional)
     - Email address text
   - onTap: launch mailto:{email} URI
   - Handle launch failure
   - Proper touch target size

3. `lib/core/utils/launcher_utils.dart`
   - LauncherUtils utility class
   - Methods:
     - static Future<bool> launchPhone(String phoneNumber)
       // Launches tel: URI, returns success/failure
     - static Future<bool> launchEmail(String email, {String? subject, String? body})
       // Launches mailto: URI with optional subject/body
     - static Future<bool> launchUrl(String url)
       // Generic URL launcher
   - Handle all url_launcher exceptions
   - Log failures

**Requirements:**
- Shared widgets reduce code duplication
- Utility class handles all url_launcher logic
- Proper error handling for launch failures
- Reusable across Academy, Contacts, and future modules
- Accessible with semantic labels

Phase 6: Hive Configuration (If Using API)
Prompt: Academy & Contacts Hive Setup
Implement Hive configuration for Academy and Contacts caching.

**Note:** Only needed if fetching data from API. Skip if using purely static data.

**Files to create:**

1. `lib/features/academy/infrastructure/hive/academy_box_keys.dart`
   - Static class: AcademyBoxKeys
   - Constants:
     - static const boxName = 'academy_box'
     - static const academyInfoKey = 'academy_info'
     - static const timestampKey = 'academy_timestamp'

2. `lib/features/academy/infrastructure/hive/adapters/academy_info_adapter.dart`
   - Hive TypeAdapter for AcademyInfoModel
   - TypeId: [assign unique number, different from other modules]
   - Handle nested ContactNumberModel list

3. `lib/features/academy/infrastructure/hive/adapters/contact_number_adapter.dart`
   - Hive TypeAdapter for ContactNumberModel
   - TypeId: [unique]

4. `lib/features/contacts/infrastructure/hive/contacts_box_keys.dart`
   - Static class: ContactsBoxKeys
   - Constants:
     - static const boxName = 'contacts_box'
     - static const contactsInfoKey = 'contacts_info'
     - static const timestampKey = 'contacts_timestamp'

5. `lib/features/contacts/infrastructure/hive/adapters/contacts_info_adapter.dart`
   - Hive TypeAdapter for ContactsInfoModel
   - TypeId: [unique]
   - Handle nested ContactPersonModel list

6. `lib/features/contacts/infrastructure/hive/adapters/contact_person_adapter.dart`
   - Hive TypeAdapter for ContactPersonModel
   - TypeId: [unique]
   - Handle nullable fields

7. Update `lib/app/bootstrap/hive_init.dart`
   - Register Academy and Contacts adapters (if using API)
   - Open boxes

**Requirements:**
- TypeIds must be unique across entire app
- Adapters handle nullable fields
- Only implement if using API-based data
- Skip entirely if using static data approach

Phase 7: Integration
Prompt: Academy & Contacts Route and Navigation Integration
Integrate Academy and Contacts into app routing.

**Files to update:**

1. `lib/app/router/routes.dart`
   - Add: static const academy = '/academy'
   - Add: static const contacts = '/contacts'

2. `lib/app/router/app_router.dart`
   - Add academy route (navigable from home quick actions)
   - Add contacts route (navigable from home quick actions)
   - Routes should trigger data fetch on navigation (if using API)
   - Simple routes with no parameters

3. `lib/features/home/presentation/components/quick_actions_section.dart`
   - Update Academy quick action to navigate to Academy screen
   - Update Contacts quick action to navigate to Contacts screen
   - Use GoRouter navigation

**Requirements:**
- Simple navigation with no parameters
- Back navigation returns to HomeScreen
- Routes trigger data fetch if using API approach
Prompt: Academy & Contacts Provider Integration
Integrate Academy and Contacts providers with app-level providers.

**Files to create/update:**

1. `lib/features/academy/application/providers/academy_providers.dart`
   - Ensure all dependencies are properly injected:
     - DioClient from core providers (if using API)
     - Hive box for academy (if using API)
     - ConnectivityChecker from core (if using API)
   - Export all public providers

2. `lib/features/academy/academy.dart` (barrel export)
   - Export all public APIs:
     - Entities (AcademyInfo, ContactNumber)
     - Providers (academyStateProvider)
     - Screen widget (AcademyScreen)

3. `lib/features/contacts/application/providers/contacts_providers.dart`
   - Same pattern as academy providers

4. `lib/features/contacts/contacts.dart` (barrel export)
   - Export all public APIs:
     - Entities (ContactsInfo, ContactPerson)
     - Providers (contactsStateProvider)
     - Screen widget (ContactsScreen)

**Requirements:**
- Clean public API via barrel exports
- Internal implementation details not exposed
- Providers properly scoped
- Simpler dependency injection for static data approach

Phase 8: Dependencies
Prompt: Package Dependencies
Ensure required dependencies for Academy and Contacts modules.

**Verify in pubspec.yaml:**
```yaml
dependencies:
  # URL launcher for click-to-call and click-to-email
  url_launcher: ^6.2.5  # Should already be present from ASWAS Plus module
```

**Usage notes:**

1. url_launcher:
   - Used for tel: and mailto: URI schemes
   - Import: import 'package:url_launcher/url_launcher.dart';
   - Phone: await launchUrl(Uri.parse('tel:+1234567890'));
   - Email: await launchUrl(Uri.parse('mailto:email@example.com'));

**Platform Configuration:**

iOS (Info.plist):
- Add LSApplicationQueriesSchemes for tel and mailto:
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>tel</string>
  <string>mailto</string>
</array>
```

Android (AndroidManifest.xml):
- Add queries for tel and mailto intents:
```xml
<queries>
  <intent>
    <action android:name="android.intent.action.DIAL" />
    <data android:scheme="tel" />
  </intent>
  <intent>
    <action android:name="android.intent.action.SENDTO" />
    <data android:scheme="mailto" />
  </intent>
</queries>
```

**Requirements:**
- Verify platform configurations are in place
- Test on both iOS and Android simulators/devices
- Handle cases where phone/email apps are not available

Testing Prompts
Prompt: Academy & Contacts Unit Tests
Implement unit tests for Academy and Contacts features.

**Test files to create:**

1. `test/features/academy/domain/entities/academy_info_test.dart`
   - Test hasContacts getter
   - Test primaryContact getter (returns first isPrimary or first in list)
   - Test empty factory

2. `test/features/academy/domain/entities/contact_number_test.dart`
   - Test displayNumber getter
   - Test dialableNumber getter (strips formatting)

3. `test/features/academy/infrastructure/repositories/academy_repository_impl_test.dart`
   - Test getAcademyInfo:
     - 200 response: data cached, timestamp stored
     - 304 response: returns null
     - Error: returns failure
     - Offline: returns cached data
   - Mock AcademyApi, AcademyLocalDataSource, ConnectivityChecker

4. `test/features/academy/application/usecases/fetch_academy_info_usecase_test.dart`
   - Test success path
   - Test 304 path returns cached data
   - Test failure path

5. `test/features/academy/application/providers/academy_notifier_test.dart`
   - Test initial state
   - Test loading state
   - Test loaded state
   - Test error state with cached data

6. `test/features/contacts/domain/entities/contacts_info_test.dart`
   - Test hasContacts getter
   - Test getByCategory method

7. `test/features/contacts/domain/entities/contact_person_test.dart`
   - Test displayNumber getter
   - Test dialableNumber getter
   - Test hasEmail getter

8. `test/features/contacts/infrastructure/repositories/contacts_repository_impl_test.dart`
   - Same patterns as academy repository tests

9. `test/features/contacts/application/usecases/fetch_contacts_info_usecase_test.dart`
   - Same patterns as academy usecase tests

10. `test/features/contacts/application/providers/contacts_notifier_test.dart`
    - Same patterns as academy notifier tests

11. `test/core/utils/launcher_utils_test.dart`
    - Test launchPhone formats URI correctly
    - Test launchEmail formats URI correctly with optional params
    - Test error handling
    - Mock url_launcher

**Test fixtures:**

12. `test/fixtures/academy_fixtures.dart`
    - Sample AcademyInfo entity
    - Sample ContactNumber entities
    - Sample API response JSONs

13. `test/fixtures/contacts_fixtures.dart`
    - Sample ContactsInfo entity
    - Sample ContactPerson entities
    - Sample API response JSONs

**Requirements:**
- Use mocktail for mocks
- Test all state transitions
- Test if-modified-since logic (if using API)
- Test URL formatting for tel: and mailto: schemes
- Simple test suite for simple modules
Prompt: Academy & Contacts Widget Tests
Implement widget tests for Academy and Contacts.

**Test files to create:**

1. `test/features/academy/presentation/screens/academy_screen_test.dart`
   - Test loading state shows shimmer
   - Test loaded state shows description and contacts
   - Test error state shows error with cached data
   - Mock providers

2. `test/features/academy/presentation/components/clickable_phone_number_test.dart`
   - Test phone number displayed correctly
   - Test tap triggers url_launcher
   - Test icon visibility
   - Mock url_launcher

3. `test/features/contacts/presentation/screens/contacts_screen_test.dart`
   - Test loading state shows shimmer
   - Test loaded state shows contact list
   - Test error state shows error with cached data
   - Mock providers

4. `test/features/contacts/presentation/components/contact_person_card_test.dart`
   - Test contact details displayed
   - Test phone tap triggers dialer
   - Test email tap triggers email client (if email present)
   - Test email hidden when not available

5. `test/core/widgets/clickable_phone_test.dart`
   - Test renders correctly
   - Test tap triggers launchPhone
   - Test accessibility labels

6. `test/core/widgets/clickable_email_test.dart`
   - Test renders correctly
   - Test tap triggers launchEmail
   - Test accessibility labels

**Requirements:**
- Use ProviderScope with overrides
- Mock url_launcher for tap tests
- Verify accessibility (semantic labels)
- Simple widget tests for simple screens

Static Data Alternative
Prompt: Static Data Implementation (If No API)
If Academy and Contacts data is purely static (no backend API), implement simplified static data approach.

**Files to create:**

1. `lib/features/academy/data/academy_static_data.dart`
   - Static class containing all academy information
   - Hardcoded title, description, contact numbers
   - Returns AcademyInfo entity directly
   - Example:
class AcademyStaticData {
   static AcademyInfo getData() {
     return AcademyInfo(
       title: 'AMAI Academy',
       description: 'Your static description text here...',
       contactNumbers: [
         ContactNumber(
           id: '1',
           label: 'Main Office',
           phoneNumber: '+91-XXXXXXXXXX',
           isPrimary: true,
         ),
       ],
       additionalInfo: null,
       timestamp: '',
     );
   }
 }

2. `lib/features/contacts/data/contacts_static_data.dart`
   - Static class containing all contacts information
   - Hardcoded contact list
   - Returns ContactsInfo entity directly

3. `lib/features/academy/application/providers/academy_providers.dart` (simplified)
   - Simple provider returning static data
   - No API calls, no caching needed
   - Example:
final academyInfoProvider = Provider<AcademyInfo>((ref) {
   return AcademyStaticData.getData();
 });

4. `lib/features/contacts/application/providers/contacts_providers.dart` (simplified)
   - Same pattern as academy

**Simplified Screen Implementation:**
- No loading states needed (data always available)
- No error states needed (no network calls)
- Directly use static provider
- Much simpler implementation

**Requirements:**
- Use this approach if backend does not provide these endpoints
- Simpler architecture without repository/usecase layers
- Data bundled with app (no network dependency)
- Easy to update by changing static data class
- Consider moving to API-based approach if data changes frequently

Critical Implementation Rules
**ALWAYS FOLLOW THESE RULES FOR ACADEMY & CONTACTS MODULES:**

1. **if-modified-since pattern (if using API):**
   - Store separate timestamps for academy and contacts data
   - Send stored timestamp in header on every GET request
   - On 304: use cached data, do NOT update timestamp
   - On 200: update cache AND timestamp

2. **No POST requests:**
   - These are read-only modules
   - No X-CSRF-Token needed
   - Simple GET requests only (or no requests if static)

3. **Graceful degradation (if using API):**
   - Always show cached data if available, even during loading/error
   - Loading state overlays cached data
   - Error state shows banner but displays cached data below

4. **Click-to-call functionality:**
   - Use url_launcher with tel: scheme
   - Format: tel:+{country_code}{number} or tel:{number}
   - Handle launch failure gracefully (show snackbar)
   - Ensure proper platform configuration (LSApplicationQueriesSchemes on iOS, queries on Android)

5. **Click-to-email functionality:**
   - Use url_launcher with mailto: scheme
   - Format: mailto:{email}
   - Handle launch failure gracefully
   - Only show email option if email is available

6. **Static vs API approach:**
   - Choose based on whether backend provides endpoints
   - Static approach: simpler, no network dependency, data bundled
   - API approach: data can be updated without app release
   - Can start with static and migrate to API later

7. **Shared components:**
   - ClickablePhone and ClickableEmail should be in core/widgets
   - LauncherUtils should be in core/utils
   - Reusable across all modules that need phone/email actions

8. **Static elements:**
   - All content is read-only
   - No user interactions except navigation and phone/email actions
   - Simple, informational screens

9. **Data refresh triggers (if using API):**
   - Screen navigation (initState or GoRouter listener)
   - No pull-to-refresh needed for such simple screens (optional)

10. **Accessibility:**
    - Phone numbers must have semantic labels indicating action
    - Email addresses must have semantic labels
    - Proper touch target sizes (minimum 48x48)
    - Screen reader friendly

11. **Navigation:**
    - Both screens accessible from HomeScreen quick actions
    - Simple back navigation
    - No deep linking required (simple screens)

12. **Platform configuration:**
    - iOS: LSApplicationQueriesSchemes for tel and mailto
    - Android: queries for DIAL and SENDTO intents
    - Test on both platforms to ensure dialer/email opens

