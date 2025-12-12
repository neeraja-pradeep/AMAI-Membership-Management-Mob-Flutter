/// API endpoint constants
///
/// All endpoint paths for the AMAI API
class Endpoints {
  Endpoints._();

  /// Base URL for API
  static const String baseUrl = 'https://amai.nexogms.com';

  /// API version prefix
  static const String apiPrefix = '/api';

  // ==================== Authentication ====================

  /// POST /api/accounts/login/
  /// Login with email and password
  static const String login = '/api/accounts/v1/login/';

  /// POST /api/accounts/logout/
  /// Logout current user
  static const String logout = '/api/accounts/v1/logout/';

  /// POST /api/accounts/send-otp/
  /// Send OTP for forgot password
  static const String otpSignIn = '/api/accounts/v1/otp-signin/';

  /// POST /api/accounts/verify-otp/
  /// Verify OTP for forgot password
  static const String verifyOtp = '/api/accounts/v1/verify-otp/';

  /// POST /api/accounts/reset-password/
  /// Reset password after OTP verification
  static const String resetPassword = '/api/accounts/v1/reset-password/';

  /// POST /api/membership/register/
  /// Register new user (includes role selection)
  static const String register = '/api/membership/v1/register/';

  /// GET /api/session/validate/
  /// Validate current session
  static const String sessionValidate = '/api/session/validate/';

  // ==================== Membership ====================

  /// GET /api/membership/membership-applications/
  /// Fetch membership applications
  static const String membershipApplications =
      '/api/membership/v1/membership-applications/';

  /// POST /api/membership/application-documents/
  /// Upload application documents
  static const String applicationDocuments =
      '/api/membership/v1/application-documents/';

  /// Membership detail endpoint for current user
  /// GET: Retrieve membership details for the authenticated user
  static const String membershipMe = '$apiPrefix/membership/v1/memberships/me/';

  /// Single membership endpoint (legacy)
  static String membershipById(int id) =>
      '$apiPrefix/membership/v1/memberships/$id/';

  /// Area admins endpoint
  /// GET: Retrieve area admins for the authenticated user
  static const String areaAdmins = '$apiPrefix/membership/v1/area-admins/';

  // ==================== Accounts ====================

  /// POST /api/accounts/addresses/
  /// Add user address
  static const String addresses = '/api/accounts/v1/addresses/';

  /// GET /api/accounts/addresses/
  /// Get user addresses
  static const String getAddresses = '/api/accounts/v1/addresses/';

  /// GET /api/accounts/addresses/me/
  /// Get current user's addresses
  static const String addressesMe = '/api/accounts/v1/addresses/me/';

  /// User profile endpoint (session-based)
  /// GET: Retrieve user profile for authenticated user
  static const String userProfileMe = '$apiPrefix/accounts/v1/users/me/';

  /// User profile endpoint by ID (legacy)
  /// GET: Retrieve user profile by ID
  static String userProfile(int userId) => '$apiPrefix/accounts/v1/users/$userId/';

  // ==================== Registration ====================

  /// GET /api/registration/councils/
  /// Fetch medical councils for dropdown
  static const String councils = '/api/registration/v1/councils/';

  /// GET /api/registration/specializations/
  /// Fetch specializations for dropdown
  static const String specializations = '/api/registration/v1/specializations/';

  /// GET /api/registration/countries/
  /// Fetch countries for dropdown
  static const String countries = '/api/registration/v1/countries/';

  /// GET /api/registration/states/
  /// Fetch states for dropdown (requires country_id query param)
  static const String states = '/api/registration/v1/states/';

  /// GET /api/registration/districts/
  /// Fetch districts for dropdown (requires state_id query param)
  static const String districts = '/api/registration/v1/districts/';

  /// POST /api/registration/upload/
  /// Upload registration document
  static const String registrationUpload = '/api/registration/v1/upload/';

  /// POST /api/registration/submit/
  /// Submit complete registration
  static const String registrationSubmit = '/api/registration/v1/submit/';

  /// GET /api/registration/check-duplicate/
  /// Check for duplicate email or phone
  static const String registrationCheckDuplicate =
      '/api/registration/v1/check-duplicate/';

  /// POST /api/registration/verify-payment/
  /// Verify payment status after gateway redirect
  static const String registrationVerifyPayment =
      '/api/registration/v1/verify-payment/';

  /// Registration payment initiation
  static const String initiatePayment =
      "/api/membership/v1/membership/register/payment/";

  /// Registration payment verification
  static const String verifyPayment =
      "/api/membership/v1/membership/register/verify/";

  // ==================== Insurance Endpoints ====================

  /// Insurance policies endpoint for current user
  /// GET: Retrieve insurance policies for the authenticated user
  static const String insurancePoliciesMe =
      '$apiPrefix/membership/v1/insurance-policies/me/';

  /// Insurance nominees endpoint for current user
  /// GET: Retrieve insurance nominees for the authenticated user
  static const String insuranceNomineesMe =
      '$apiPrefix/membership/v1/insurance-nominees/me/';

  /// Single insurance policy endpoint (legacy)
  static String insurancePolicyById(int id) =>
      '$apiPrefix/membership/v1/insurance-policies/$id/';

  /// Insurance registration endpoint
  /// POST: Register for ASWAS Plus insurance
  static const String insuranceRegister =
      '$apiPrefix/membership/v1/insurance/register/';

  /// Insurance verification endpoint
  /// POST: Verify Razorpay payment for insurance registration
  static const String insuranceVerify =
      '$apiPrefix/membership/v1/insurance/verify/';

  /// Insurance nominee update endpoint
  /// PATCH: Update insurance nominee details
  static String insuranceNomineeById(int nomineeId) =>
      '$apiPrefix/membership/v1/insurance-nominees/$nomineeId/';

  /// Insurance renewal endpoint
  /// POST: Initiate insurance policy renewal
  static const String insuranceRenewal =
      '$apiPrefix/membership/v1/insurance/renewal/';

  /// Insurance renewal verification endpoint
  /// POST: Verify payment after Razorpay payment success
  static const String insuranceRenewalVerify =
      '$apiPrefix/membership/v1/insurance/renewal/verify/';

  // ==================== Digital Products Endpoints ====================

  /// Digital product by ID endpoint
  /// GET: Retrieve digital product details
  static String digitalProductById(int id) =>
      '$apiPrefix/membership/v1/digital-products/$id/';

  // ==================== Events Endpoints ====================

  /// Upcoming events list endpoint
  static const String events = '$apiPrefix/bookings/v1/events/upcoming/';

  /// Single event endpoint
  static String eventById(int id) => '$apiPrefix/bookings/v1/events/$id/';

  // ==================== Library Endpoints ====================

  /// Library documents endpoint
  /// GET: Retrieve library documents (filter by doc_type)
  static const String libraryDocuments = '$apiPrefix/library/v1/documents/';

  /// Announcements list endpoint
  static const String announcements = '$apiPrefix/library/v1/announcements/';

  /// Single announcement endpoint
  static String announcementById(int id) =>
      '$apiPrefix/library/v1/announcements/$id/';

  // ==================== Membership Payment Endpoints ====================

  /// Membership payment initiation endpoint
  /// POST: Initiate membership renewal payment
  static const String membershipPayment =
      '$apiPrefix/membership/membership/v1/payment/';

  /// Membership payment verification endpoint
  /// POST: Verify Razorpay payment for membership renewal
  static const String membershipPaymentVerify =
      '$apiPrefix/membership/membership/v1/verify/';

  // ==================== Payment History Endpoints ====================

  /// Payment history endpoint
  /// GET: Retrieve payment receipts for the authenticated user
  static const String paymentHistory = '$apiPrefix/payments/v1/my-receipts/';

  // ==================== Helpers ====================

  /// Build full URL from path
  static String fullUrl(String path) {
    return '$baseUrl$path';
  }
}
