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

  // ==================== Helpers ====================

  /// Build full URL from path
  static String fullUrl(String path) {
    return 'https://amai.nexogms.com$path';
  }
}
