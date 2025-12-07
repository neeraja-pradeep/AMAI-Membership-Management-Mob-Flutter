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
  static const String login = '/api/accounts/login/';

  /// POST /api/accounts/logout/
  /// Logout current user
  static const String logout = '/api/accounts/logout/';

  /// POST /api/accounts/send-otp/
  /// Send OTP for forgot password
  static const String otpSignIn = '/api/accounts/send-otp/';

  /// POST /api/accounts/verify-otp/
  /// Verify OTP for forgot password
  static const String verifyOtp = '/api/accounts/verify-otp/';

  /// POST /api/membership/register/
  /// Register new user (includes role selection)
  static const String register = '/api/membership/register/';

  /// GET /api/session/validate/
  /// Validate current session
  static const String sessionValidate = '/api/session/validate/';

  // ==================== Membership ====================

  /// GET /api/membership/membership-applications/
  /// Fetch membership applications
  static const String membershipApplications =
      '/api/membership/membership-applications/';

  /// POST /api/membership/application-documents/
  /// Upload application documents
  static const String applicationDocuments =
      '/api/membership/application-documents/';

  /// Membership detail endpoint for current user
  /// GET: Retrieve membership details for the authenticated user
  static const String membershipMe = '$apiPrefix/membership/memberships/me/';

  /// Single membership endpoint (legacy)
  static String membershipById(int id) =>
      '$apiPrefix/membership/memberships/$id/';

  // ==================== Accounts ====================

  /// POST /api/accounts/addresses/
  /// Add user address
  static const String addresses = '/api/accounts/addresses/';

  /// GET /api/accounts/addresses/
  /// Get user addresses
  static const String getAddresses = '/api/accounts/addresses/';

  /// GET /api/accounts/addresses/me/
  /// Get current user's addresses
  static const String addressesMe = '/api/accounts/addresses/me/';

  /// User profile endpoint (session-based)
  /// GET: Retrieve user profile for authenticated user
  static const String userProfileMe = '$apiPrefix/accounts/users/';

  /// User profile endpoint by ID (legacy)
  /// GET: Retrieve user profile by ID
  static String userProfile(int userId) => '$apiPrefix/accounts/users/$userId/';

  // ==================== Registration ====================

  /// GET /api/registration/councils/
  /// Fetch medical councils for dropdown
  static const String councils = '/api/registration/councils/';

  /// GET /api/registration/specializations/
  /// Fetch specializations for dropdown
  static const String specializations = '/api/registration/specializations/';

  /// GET /api/registration/countries/
  /// Fetch countries for dropdown
  static const String countries = '/api/registration/countries/';

  /// GET /api/registration/states/
  /// Fetch states for dropdown (requires country_id query param)
  static const String states = '/api/registration/states/';

  /// GET /api/registration/districts/
  /// Fetch districts for dropdown (requires state_id query param)
  static const String districts = '/api/registration/districts/';

  /// POST /api/registration/upload/
  /// Upload registration document
  static const String registrationUpload = '/api/registration/upload/';

  /// POST /api/registration/submit/
  /// Submit complete registration
  static const String registrationSubmit = '/api/registration/submit/';

  /// GET /api/registration/check-duplicate/
  /// Check for duplicate email or phone
  static const String registrationCheckDuplicate =
      '/api/registration/check-duplicate/';

  /// POST /api/registration/verify-payment/
  /// Verify payment status after gateway redirect
  static const String registrationVerifyPayment =
      '/api/registration/verify-payment/';

  /// Registration payment initiation
  static const String initiatePayment =
      "/api/membership/membership/register/payment/";

  /// Registration payment verification
  static const String verifyPayment =
      "/api/membership/membership/register/verify/";

  // ==================== Insurance Endpoints ====================

  /// Insurance policies endpoint for current user
  /// GET: Retrieve insurance policies for the authenticated user
  static const String insurancePoliciesMe =
      '$apiPrefix/membership/insurance-policies/me/';

  /// Insurance nominees endpoint for current user
  /// GET: Retrieve insurance nominees for the authenticated user
  static const String insuranceNomineesMe =
      '$apiPrefix/membership/insurance-nominees/me/';

  /// Single insurance policy endpoint (legacy)
  static String insurancePolicyById(int id) =>
      '$apiPrefix/membership/insurance-policies/$id/';

  /// Insurance registration endpoint
  /// POST: Register for ASWAS Plus insurance
  static const String insuranceRegister =
      '$apiPrefix/membership/insurance/register/';

  /// Insurance verification endpoint
  /// POST: Verify Razorpay payment for insurance registration
  static const String insuranceVerify =
      '$apiPrefix/membership/insurance/verify/';

  /// Insurance nominee update endpoint
  /// PATCH: Update insurance nominee details
  static String insuranceNomineeById(int nomineeId) =>
      '$apiPrefix/membership/insurance-nominees/$nomineeId/';

  /// Insurance renewal endpoint
  /// POST: Initiate insurance policy renewal
  static const String insuranceRenewal =
      '$apiPrefix/membership/insurance/renewal/';

  /// Insurance renewal verification endpoint
  /// POST: Verify payment after Razorpay payment success
  static const String insuranceRenewalVerify =
      '$apiPrefix/membership/insurance/renewal/verify/';

  // ==================== Digital Products Endpoints ====================

  /// Digital product by ID endpoint
  /// GET: Retrieve digital product details
  static String digitalProductById(int id) =>
      '$apiPrefix/membership/digital-products/$id/';

  // ==================== Events Endpoints ====================

  /// Upcoming events list endpoint
  static const String events = '$apiPrefix/bookings/events/upcoming/';

  /// Single event endpoint
  static String eventById(int id) => '$apiPrefix/bookings/events/$id/';

  // ==================== Library Endpoints ====================

  /// Announcements list endpoint
  static const String announcements = '$apiPrefix/library/announcements/';

  /// Single announcement endpoint
  static String announcementById(int id) =>
      '$apiPrefix/library/announcements/$id/';

  // ==================== Membership Payment Endpoints ====================

  /// Membership payment initiation endpoint
  /// POST: Initiate membership renewal payment
  static const String membershipPayment =
      '$apiPrefix/membership/membership/payment/';

  /// Membership payment verification endpoint
  /// POST: Verify Razorpay payment for membership renewal
  static const String membershipPaymentVerify =
      '$apiPrefix/membership/membership/verify/';

  // ==================== Payment History Endpoints ====================

  /// Payment history endpoint
  /// GET: Retrieve payment receipts for the authenticated user
  static const String paymentHistory = '$apiPrefix/payments/payment/';

  // ==================== Helpers ====================

  /// Build full URL from path
  static String fullUrl(String path) {
    return '$baseUrl$path';
  }
}
