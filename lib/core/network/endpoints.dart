/// API endpoint paths for AMAI application
class Endpoints {
  Endpoints._();

  /// Base URL for API
  static const String baseUrl = 'https://amai.nexogms.com';

  /// API version prefix
  static const String apiPrefix = '/api';

  // ============== Membership Endpoints ==============

  /// Membership detail endpoint by user ID
  /// GET: Retrieve membership details for a specific user
  static String membershipByUserId(int userId) =>
      '$apiPrefix/membership/memberships/$userId/';

  /// Single membership endpoint (legacy)
  static String membershipById(int id) =>
      '$apiPrefix/membership/memberships/$id/';

  // ============== Insurance Endpoints ==============

  /// Insurance policies by user ID endpoint
  /// GET: Retrieve insurance policies for a specific user
  static String insurancePoliciesByUserId(int userId) =>
      '$apiPrefix/membership/insurance-policies/$userId/';

  /// Single insurance policy endpoint (legacy)
  static String insurancePolicyById(int id) =>
      '$apiPrefix/membership/insurance-policies/$id/';

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
}
