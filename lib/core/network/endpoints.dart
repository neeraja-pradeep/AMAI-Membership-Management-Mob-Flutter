/// API endpoint paths for AMAI application
class Endpoints {
  Endpoints._();

  /// Base URL for API
  static const String baseUrl = 'https://amai.nexogms.com';

  /// API version prefix
  static const String apiPrefix = '/api';

  // ============== Membership Endpoints ==============

  /// Memberships list/create endpoint
  /// GET: List all memberships
  /// POST: Create new membership
  static const String memberships = '$apiPrefix/membership/memberships/';

  /// Single membership endpoint
  /// GET: Retrieve membership by ID
  /// PUT/PATCH: Update membership
  /// DELETE: Delete membership
  static String membershipById(int id) =>
      '$apiPrefix/membership/memberships/$id/';

  // ============== Insurance Endpoints ==============

  /// Insurance policies list/create endpoint
  static const String insurancePolicies =
      '$apiPrefix/membership/insurance-policies/';

  /// Single insurance policy endpoint
  static String insurancePolicyById(int id) =>
      '$apiPrefix/membership/insurance-policies/$id/';

  // ============== Events Endpoints ==============

  /// Events list/create endpoint
  static const String events = '$apiPrefix/bookings/events/';

  /// Single event endpoint
  static String eventById(int id) => '$apiPrefix/bookings/events/$id/';

  // ============== Library Endpoints ==============

  /// Announcements list endpoint
  static const String announcements = '$apiPrefix/library/announcements/';

  /// Single announcement endpoint
  static String announcementById(int id) => '$apiPrefix/library/announcements/$id/';
}
