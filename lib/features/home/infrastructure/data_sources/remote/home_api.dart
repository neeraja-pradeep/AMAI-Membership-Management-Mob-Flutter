import 'package:myapp/core/network/api_client.dart';
import 'package:myapp/core/network/endpoints.dart';
import 'package:myapp/features/home/infrastructure/models/announcement_model.dart';
import 'package:myapp/features/home/infrastructure/models/aswas_card_model.dart';
import 'package:myapp/features/home/infrastructure/models/event_model.dart';
import 'package:myapp/features/home/infrastructure/models/membership_card_model.dart';

/// API response wrapper for home data with timestamp
class HomeApiResponse<T> {
  const HomeApiResponse({
    required this.data,
    required this.statusCode,
    this.timestamp,
  });

  final T? data;
  final int statusCode;
  final String? timestamp;

  /// Check if response is 304 Not Modified
  bool get isNotModified => statusCode == 304;

  /// Check if response is successful
  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

/// Abstract interface for Home API operations
abstract class HomeApi {
  /// Fetches membership data for a specific user
  ///
  /// [userId] - The user ID to fetch membership for
  /// [ifModifiedSince] - Timestamp for conditional request
  ///
  /// Returns HomeApiResponse containing:
  /// - MembershipCardModel on success (200)
  /// - null data on not modified (304)
  Future<HomeApiResponse<MembershipCardModel>> fetchMembershipCard({
    required String ifModifiedSince,
  });

  /// Fetches insurance policies (Aswas Plus) for the authenticated user
  ///
  /// [ifModifiedSince] - Timestamp for conditional request
  ///
  /// Returns HomeApiResponse containing:
  /// - AswasCardModel on success (200) - only if active policy exists
  /// - null data on not modified (304) or no active policy
  Future<HomeApiResponse<AswasCardModel>> fetchAswasPlus({
    required String ifModifiedSince,
  });

  /// Fetches upcoming events
  ///
  /// [ifModifiedSince] - Timestamp for conditional request
  ///
  /// Returns HomeApiResponse containing:
  /// - List<EventModel> on success (200)
  /// - null data on not modified (304)
  Future<HomeApiResponse<List<EventModel>>> fetchEvents({
    required String ifModifiedSince,
  });

  /// Fetches announcements
  ///
  /// [ifModifiedSince] - Timestamp for conditional request
  ///
  /// Returns HomeApiResponse containing:
  /// - List<AnnouncementModel> on success (200)
  /// - null data on not modified (304)
  Future<HomeApiResponse<List<AnnouncementModel>>> fetchAnnouncements({
    required String ifModifiedSince,
  });
}

/// Implementation of HomeApi using ApiClient
class HomeApiImpl implements HomeApi {
  const HomeApiImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<HomeApiResponse<MembershipCardModel>> fetchMembershipCard({
    required String ifModifiedSince,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      Endpoints.membershipMe,
      ifModifiedSince: ifModifiedSince.isNotEmpty ? ifModifiedSince : null,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    // Handle 304 Not Modified
    if (response.isNotModified) {
      return HomeApiResponse<MembershipCardModel>(
        data: null,
        statusCode: response.statusCode,
        timestamp: null,
      );
    }

    // Parse the response
    MembershipCardModel? membershipCard;

    if (response.data != null) {
      // API returns membership detail with nested membership object
      final detailResponse = MembershipDetailResponse.fromJson(response.data!);
      membershipCard = detailResponse.membership;
    }

    return HomeApiResponse<MembershipCardModel>(
      data: membershipCard,
      statusCode: response.statusCode,
      timestamp: response.timestamp,
    );
  }

  @override
  Future<HomeApiResponse<AswasCardModel>> fetchAswasPlus({
    required String ifModifiedSince,
  }) async {
    final response = await apiClient.get<List<dynamic>>(
      Endpoints.insurancePoliciesMe,
      ifModifiedSince: ifModifiedSince.isNotEmpty ? ifModifiedSince : null,
      fromJson: (json) => json as List<dynamic>,
    );

    // Handle 304 Not Modified
    if (response.isNotModified) {
      return HomeApiResponse<AswasCardModel>(
        data: null,
        statusCode: response.statusCode,
        timestamp: null,
      );
    }

    // Parse the response - API returns direct array of insurance policies
    AswasCardModel? aswasCard;

    if (response.data != null && response.data!.isNotEmpty) {
      // Get the first ACTIVE policy from the array
      final policies = response.data!
          .map((json) => AswasCardModel.fromJson(json as Map<String, dynamic>))
          .where((policy) => policy.policyStatus.toLowerCase() == 'active')
          .toList();

      if (policies.isNotEmpty) {
        aswasCard = policies.first;
      }
    }

    return HomeApiResponse<AswasCardModel>(
      data: aswasCard,
      statusCode: response.statusCode,
      timestamp: response.timestamp,
    );
  }

  @override
  Future<HomeApiResponse<List<EventModel>>> fetchEvents({
    required String ifModifiedSince,
  }) async {
    final response = await apiClient.get<List<dynamic>>(
      Endpoints.events,
      ifModifiedSince: ifModifiedSince.isNotEmpty ? ifModifiedSince : null,
      fromJson: (json) => json as List<dynamic>,
    );

    // Handle 304 Not Modified
    if (response.isNotModified) {
      return HomeApiResponse<List<EventModel>>(
        data: null,
        statusCode: response.statusCode,
        timestamp: null,
      );
    }

    // Parse the response - API returns direct array of upcoming events
    List<EventModel>? events;

    if (response.data != null) {
      events = response.data!
          .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
          .where((event) => event.isPublished)
          .toList()
        ..sort((a, b) {
          final dateA = DateTime.tryParse(a.eventDate) ?? DateTime.now();
          final dateB = DateTime.tryParse(b.eventDate) ?? DateTime.now();
          return dateA.compareTo(dateB);
        });
    }

    return HomeApiResponse<List<EventModel>>(
      data: events ?? [],
      statusCode: response.statusCode,
      timestamp: response.timestamp,
    );
  }

  @override
  Future<HomeApiResponse<List<AnnouncementModel>>> fetchAnnouncements({
    required String ifModifiedSince,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      Endpoints.announcements,
      ifModifiedSince: ifModifiedSince.isNotEmpty ? ifModifiedSince : null,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    // Handle 304 Not Modified
    if (response.isNotModified) {
      return HomeApiResponse<List<AnnouncementModel>>(
        data: null,
        statusCode: response.statusCode,
        timestamp: null,
      );
    }

    // Parse the response
    List<AnnouncementModel>? announcements;

    if (response.data != null) {
      // API returns paginated list, get active announcements only
      final listResponse = AnnouncementListResponse.fromJson(response.data!);
      announcements = listResponse.activeAnnouncements;
    }

    return HomeApiResponse<List<AnnouncementModel>>(
      data: announcements ?? [],
      statusCode: response.statusCode,
      timestamp: response.timestamp,
    );
  }
}
