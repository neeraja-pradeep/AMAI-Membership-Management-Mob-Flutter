import 'package:myapp/core/network/api_client.dart';
import 'package:myapp/core/network/endpoints.dart';
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
  /// Fetches membership data for the current user
  ///
  /// [ifModifiedSince] - Timestamp for conditional request
  ///
  /// Returns HomeApiResponse containing:
  /// - MembershipCardModel on success (200)
  /// - null data on not modified (304)
  Future<HomeApiResponse<MembershipCardModel>> fetchMembershipCard({
    required String ifModifiedSince,
  });

  /// Fetches insurance policies (Aswas Plus) for the current user
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
      Endpoints.memberships,
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
      // API returns paginated list, get the first membership
      final listResponse = MembershipListResponse.fromJson(response.data!);
      membershipCard = listResponse.firstMembership;
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
    final response = await apiClient.get<Map<String, dynamic>>(
      Endpoints.insurancePolicies,
      ifModifiedSince: ifModifiedSince.isNotEmpty ? ifModifiedSince : null,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    // Handle 304 Not Modified
    if (response.isNotModified) {
      return HomeApiResponse<AswasCardModel>(
        data: null,
        statusCode: response.statusCode,
        timestamp: null,
      );
    }

    // Parse the response
    AswasCardModel? aswasCard;

    if (response.data != null) {
      // API returns paginated list, get the first ACTIVE policy only
      final listResponse = AswasListResponse.fromJson(response.data!);
      aswasCard = listResponse.firstActivePolicy;
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
    final response = await apiClient.get<Map<String, dynamic>>(
      Endpoints.events,
      ifModifiedSince: ifModifiedSince.isNotEmpty ? ifModifiedSince : null,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    // Handle 304 Not Modified
    if (response.isNotModified) {
      return HomeApiResponse<List<EventModel>>(
        data: null,
        statusCode: response.statusCode,
        timestamp: null,
      );
    }

    // Parse the response
    List<EventModel>? events;

    if (response.data != null) {
      // API returns paginated list, get upcoming events only
      final listResponse = EventListResponse.fromJson(response.data!);
      events = listResponse.upcomingEvents;
    }

    return HomeApiResponse<List<EventModel>>(
      data: events ?? [],
      statusCode: response.statusCode,
      timestamp: response.timestamp,
    );
  }
}
