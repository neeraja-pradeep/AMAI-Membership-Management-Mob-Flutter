/// API endpoint paths for AMAI application
class Endpoints {
  Endpoints._();

  /// Base URL for API
  static const String baseUrl = 'https://amai.nexogms.com';

  /// API version prefix
  static const String apiPrefix = '/api';

  // ============== Membership Endpoints ==============

  /// Membership detail endpoint for current user
  /// GET: Retrieve membership details for the authenticated user
  static const String membershipMe = '$apiPrefix/membership/memberships/me/';

  /// Single membership endpoint (legacy)
  static String membershipById(int id) =>
      '$apiPrefix/membership/memberships/$id/';

  // ============== Insurance Endpoints ==============

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

  // ============== Digital Products Endpoints ==============

  /// Digital product by ID endpoint
  /// GET: Retrieve digital product details
  static String digitalProductById(int id) =>
      '$apiPrefix/membership/digital-products/$id/';

  /// Insurance renewal endpoint
  /// POST: Initiate insurance policy renewal
  static const String insuranceRenewal =
      '$apiPrefix/membership/insurance/renewal/';

  /// Insurance renewal verification endpoint
  /// POST: Verify payment after Razorpay payment success
  static const String insuranceRenewalVerify =
      '$apiPrefix/membership/insurance/renewal/verify/';

  // ============== Events Endpoints ==============

  /// Upcoming events list endpoint
  static const String events = '$apiPrefix/bookings/events/upcoming/';

  /// Single event endpoint
  static String eventById(int id) => '$apiPrefix/bookings/events/$id/';

  // ============== Library Endpoints ==============

  /// Announcements list endpoint
  static const String announcements = '$apiPrefix/library/announcements/';

  /// Single announcement endpoint
  static String announcementById(int id) => '$apiPrefix/library/announcements/$id/';

  // ============== User/Account Endpoints ==============

  /// User profile endpoint
  /// GET: Retrieve user profile by ID
  static String userProfile(int userId) => '$apiPrefix/accounts/users/$userId/';

  // ============== Membership Payment Endpoints ==============

  /// Membership payment initiation endpoint
  /// POST: Initiate membership renewal payment
  static const String membershipPayment =
      '$apiPrefix/membership/membership/payment/';

  /// Membership payment verification endpoint
  /// POST: Verify Razorpay payment for membership renewal
  static const String membershipPaymentVerify =
      '$apiPrefix/membership/membership/verify/';

  // ============== Payment History Endpoints ==============

  /// Payment history endpoint
  /// GET: Retrieve payment receipts for the authenticated user
  static const String paymentHistory = '$apiPrefix/payments/payment/';

  // ============== Insurance Registration Endpoints ==============

  /// Insurance registration endpoint
  /// POST: Register for ASWAS Plus insurance
  static const String insuranceRegister = '$apiPrefix/membership/insurance/register/';

  /// Insurance verification endpoint
  /// POST: Verify Razorpay payment for insurance registration
  static const String insuranceVerify = '$apiPrefix/membership/insurance/verify/';

  /// Insurance nominee update endpoint
  /// PATCH: Update insurance nominee details
  static String insuranceNomineeById(int nomineeId) =>
      '$apiPrefix/membership/insurance-nominees/$nomineeId/';
}
