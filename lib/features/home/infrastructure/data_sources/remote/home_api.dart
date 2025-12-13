import 'package:myapp/core/network/api_client.dart';
import 'package:myapp/core/network/endpoints.dart';
import 'package:myapp/features/aswas_plus/infrastructure/models/digital_product_model.dart';
import 'package:myapp/features/aswas_plus/infrastructure/models/nominee_model.dart';
import 'package:myapp/features/aswas_plus/infrastructure/models/renewal_response_model.dart';
import 'package:myapp/features/home/infrastructure/models/announcement_model.dart';
import 'package:myapp/features/home/infrastructure/models/area_admin_model.dart';
import 'package:myapp/features/home/infrastructure/models/aswas_card_model.dart';
import 'package:myapp/features/home/infrastructure/models/event_model.dart';
import 'package:myapp/features/home/infrastructure/models/membership_card_model.dart';

/// API response wrapper for home data with timestamp
class HomeApiResponse<T> {
  const HomeApiResponse({
    required this.data,
    required this.statusCode,
    this.timestamp,
    this.isPendingApplication = false,
    this.isRejectedApplication = false,
    this.applicationDate,
  });

  final T? data;
  final int statusCode;
  final String? timestamp;
  final bool isPendingApplication;
  final bool isRejectedApplication;
  final String? applicationDate;

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

  /// Fetches ongoing events
  ///
  /// [ifModifiedSince] - Timestamp for conditional request
  ///
  /// Returns HomeApiResponse containing:
  /// - List<EventModel> on success (200)
  /// - null data on not modified (304)
  Future<HomeApiResponse<List<EventModel>>> fetchOngoingEvents({
    required String ifModifiedSince,
  });

  /// Fetches past events
  ///
  /// [ifModifiedSince] - Timestamp for conditional request
  ///
  /// Returns HomeApiResponse containing:
  /// - List<EventModel> on success (200)
  /// - null data on not modified (304)
  Future<HomeApiResponse<List<EventModel>>> fetchPastEvents({
    required String ifModifiedSince,
  });

  /// Fetches a single event by ID
  ///
  /// [eventId] - The ID of the event to fetch
  ///
  /// Returns HomeApiResponse containing:
  /// - EventModel on success (200)
  /// - null data on error
  Future<HomeApiResponse<EventModel>> fetchEventById({
    required int eventId,
  });

  /// Registers for an event
  ///
  /// [eventId] - The ID of the event to register for
  /// [paymentMode] - Payment mode (online or offline)
  ///
  /// Returns HomeApiResponse containing:
  /// - Registration response on success (200)
  /// - null data on error
  Future<HomeApiResponse<Map<String, dynamic>>> registerForEvent({
    required int eventId,
    required String paymentMode,
  });

  /// Verifies event payment after Razorpay payment
  ///
  /// [razorpayOrderId] - The Razorpay order ID
  /// [razorpayPaymentId] - The Razorpay payment ID
  /// [razorpaySignature] - The Razorpay signature
  ///
  /// Returns HomeApiResponse containing:
  /// - Verification response on success (200)
  /// - null data on error
  Future<HomeApiResponse<Map<String, dynamic>>> verifyEventPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
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

  /// Fetches insurance nominees for the authenticated user
  ///
  /// [ifModifiedSince] - Timestamp for conditional request
  ///
  /// Returns HomeApiResponse containing:
  /// - List<NomineeModel> on success (200)
  /// - null data on not modified (304)
  Future<HomeApiResponse<List<NomineeModel>>> fetchNominees({
    required String ifModifiedSince,
  });

  /// Fetches a digital product by ID
  ///
  /// [productId] - The ID of the digital product
  ///
  /// Returns HomeApiResponse containing:
  /// - DigitalProductModel on success (200)
  /// - null data on error
  Future<HomeApiResponse<DigitalProductModel>> fetchDigitalProduct({
    required int productId,
  });

  /// Initiates insurance renewal
  ///
  /// Returns HomeApiResponse containing:
  /// - RenewalResponseModel on success (200)
  /// - null data on error
  Future<HomeApiResponse<RenewalResponseModel>> initiateInsuranceRenewal();

  /// Verifies Razorpay payment after successful payment
  ///
  /// [razorpayOrderId] - The Razorpay order ID
  /// [razorpayPaymentId] - The Razorpay payment ID
  /// [razorpaySignature] - The Razorpay signature
  ///
  /// Returns HomeApiResponse containing:
  /// - bool (true) on success (200)
  /// - null data on error
  Future<HomeApiResponse<bool>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  });

  /// Fetches ASWAS library documents
  ///
  /// Returns HomeApiResponse containing:
  /// - List of document maps on success (200)
  /// - null data on error
  Future<HomeApiResponse<List<Map<String, dynamic>>>> fetchAswasDocuments();

  /// Fetches area admins for the authenticated user
  ///
  /// Returns HomeApiResponse containing:
  /// - AreaAdminsResponse on success (200)
  /// - null data on error
  Future<HomeApiResponse<AreaAdminsResponse>> fetchAreaAdmins();
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
    bool isPendingApplication = false;
    bool isRejectedApplication = false;
    String? applicationDate;

    if (response.data != null) {
      // API returns membership detail with nested membership object
      final detailResponse = MembershipDetailResponse.fromJson(response.data!);

      // Check if this is a pending application response
      if (detailResponse.isPendingApplication) {
        isPendingApplication = true;
        applicationDate = detailResponse.applicationDate;
      } else if (detailResponse.isRejectedApplication) {
        isRejectedApplication = true;
      } else {
        membershipCard = detailResponse.membership;
      }
    }

    return HomeApiResponse<MembershipCardModel>(
      data: membershipCard,
      statusCode: response.statusCode,
      timestamp: response.timestamp,
      isPendingApplication: isPendingApplication,
      isRejectedApplication: isRejectedApplication,
      applicationDate: applicationDate,
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
      // Get the first ACTIVE, INACTIVE, or PENDING policy from the array
      final policies = response.data!
          .map((json) => AswasCardModel.fromJson(json as Map<String, dynamic>))
          .where((policy) {
            final status = policy.policyStatus.toLowerCase();
            return status == 'active' || status == 'inactive' || status == 'pending';
          })
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
  Future<HomeApiResponse<List<EventModel>>> fetchOngoingEvents({
    required String ifModifiedSince,
  }) async {
    final response = await apiClient.get<List<dynamic>>(
      Endpoints.ongoingEvents,
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

    // Parse the response - API returns direct array of ongoing events
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
  Future<HomeApiResponse<List<EventModel>>> fetchPastEvents({
    required String ifModifiedSince,
  }) async {
    final response = await apiClient.get<List<dynamic>>(
      Endpoints.pastEvents,
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

    // Parse the response - API returns direct array of past events
    List<EventModel>? events;

    if (response.data != null) {
      events = response.data!
          .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
          .where((event) => event.isPublished)
          .toList()
        ..sort((a, b) {
          final dateA = DateTime.tryParse(a.eventDate) ?? DateTime.now();
          final dateB = DateTime.tryParse(b.eventDate) ?? DateTime.now();
          return dateB.compareTo(dateA); // Reverse sort for past events (most recent first)
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

  @override
  Future<HomeApiResponse<List<NomineeModel>>> fetchNominees({
    required String ifModifiedSince,
  }) async {
    final response = await apiClient.get<List<dynamic>>(
      Endpoints.insuranceNomineesMe,
      ifModifiedSince: ifModifiedSince.isNotEmpty ? ifModifiedSince : null,
      fromJson: (json) => json as List<dynamic>,
    );

    // Handle 304 Not Modified
    if (response.isNotModified) {
      return HomeApiResponse<List<NomineeModel>>(
        data: null,
        statusCode: response.statusCode,
        timestamp: null,
      );
    }

    // Parse the response - API returns direct array of nominees
    List<NomineeModel>? nominees;

    if (response.data != null) {
      nominees = response.data!
          .map((json) => NomineeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    return HomeApiResponse<List<NomineeModel>>(
      data: nominees ?? [],
      statusCode: response.statusCode,
      timestamp: response.timestamp,
    );
  }

  @override
  Future<HomeApiResponse<DigitalProductModel>> fetchDigitalProduct({
    required int productId,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      Endpoints.digitalProductById(productId),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    // Parse the response
    DigitalProductModel? product;

    if (response.data != null) {
      product = DigitalProductModel.fromJson(response.data!);
    }

    return HomeApiResponse<DigitalProductModel>(
      data: product,
      statusCode: response.statusCode,
      timestamp: response.timestamp,
    );
  }

  @override
  Future<HomeApiResponse<RenewalResponseModel>> initiateInsuranceRenewal() async {
    final response = await apiClient.post<Map<String, dynamic>>(
      Endpoints.insuranceRenewal,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    // Parse the response
    RenewalResponseModel? renewalResponse;

    if (response.data != null) {
      renewalResponse = RenewalResponseModel.fromJson(response.data!);
    }

    return HomeApiResponse<RenewalResponseModel>(
      data: renewalResponse,
      statusCode: response.statusCode,
      timestamp: response.timestamp,
    );
  }

  @override
  Future<HomeApiResponse<bool>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      Endpoints.insuranceRenewalVerify,
      data: {
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return HomeApiResponse<bool>(
      data: response.isSuccess,
      statusCode: response.statusCode,
      timestamp: response.timestamp,
    );
  }

  @override
  Future<HomeApiResponse<List<Map<String, dynamic>>>> fetchAswasDocuments() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      Endpoints.libraryDocuments,
      queryParameters: {'doc_type': 'aswas'},
      fromJson: (json) => json as Map<String, dynamic>,
    );

    List<Map<String, dynamic>>? documents;

    if (response.data != null) {
      final results = response.data!['results'] as List<dynamic>?;
      if (results != null) {
        documents = results
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
    }

    return HomeApiResponse<List<Map<String, dynamic>>>(
      data: documents ?? [],
      statusCode: response.statusCode,
      timestamp: response.timestamp,
    );
  }

  @override
  Future<HomeApiResponse<AreaAdminsResponse>> fetchAreaAdmins() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      Endpoints.areaAdmins,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    // Parse the response
    AreaAdminsResponse? areaAdmins;

    if (response.data != null) {
      areaAdmins = AreaAdminsResponse.fromJson(response.data!);
    }

    return HomeApiResponse<AreaAdminsResponse>(
      data: areaAdmins,
      statusCode: response.statusCode,
      timestamp: response.timestamp,
    );
  }

  @override
  Future<HomeApiResponse<EventModel>> fetchEventById({
    required int eventId,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      Endpoints.eventById(eventId),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    // Parse the response
    EventModel? event;

    if (response.data != null) {
      event = EventModel.fromJson(response.data!);
    }

    return HomeApiResponse<EventModel>(
      data: event,
      statusCode: response.statusCode,
      timestamp: response.timestamp,
    );
  }

  @override
  Future<HomeApiResponse<Map<String, dynamic>>> registerForEvent({
    required int eventId,
    required String paymentMode,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      Endpoints.eventRegister,
      data: {
        'event': eventId,
        'payment_mode': paymentMode,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return HomeApiResponse<Map<String, dynamic>>(
      data: response.data,
      statusCode: response.statusCode,
      timestamp: response.timestamp,
    );
  }

  @override
  Future<HomeApiResponse<Map<String, dynamic>>> verifyEventPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      Endpoints.eventVerifyPayment,
      data: {
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return HomeApiResponse<Map<String, dynamic>>(
      data: response.data,
      statusCode: response.statusCode,
      timestamp: response.timestamp,
    );
  }
}
