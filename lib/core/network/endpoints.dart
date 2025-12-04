/// API endpoint constants
///
/// All endpoint paths for the AMAI API
class Endpoints {
  Endpoints._();

  // ==================== Authentication ====================

  /// POST /api/accounts/login/
  /// Login with email and password
  static const String login = '/api/accounts/login/';

  /// POST /api/accounts/logout/
  /// Logout current user
  static const String logout = '/api/accounts/logout/';

  /// POST /api/membership/register/
  /// Register new user (includes role selection)
  static const String register = '/api/membership/register/';

  // ==================== Membership ====================

  /// GET /api/membership/membership-applications/
  /// Fetch membership applications
  static const String membershipApplications =
      '/api/membership/membership-applications/';

  /// POST /api/membership/application-documents/
  /// Upload application documents
  static const String applicationDocuments =
      '/api/membership/application-documents/';

  // ==================== Accounts ====================

  /// POST /api/accounts/addresses/
  /// Add user address
  static const String addresses = '/api/accounts/addresses/';

  /// GET /api/accounts/addresses/
  /// Get user addresses
  static const String getAddresses = '/api/accounts/addresses/';

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

  /// GET /api/session/validate/
  /// Validate current session
  static const String sessionValidate = '/api/session/validate/';

  static const String initiatePayment = "/api/membership/membership/payment/";
  static const String verifyPayment = "/api/membership/membership/verify/";

  // ==================== Helpers ====================

  /// Build full URL from path
  static String fullUrl(String path) {
    return 'https://amai.nexogms.com$path';
  }
}
