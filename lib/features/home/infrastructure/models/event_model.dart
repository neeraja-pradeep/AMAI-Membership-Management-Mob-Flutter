import 'package:json_annotation/json_annotation.dart';
import 'package:myapp/features/home/domain/entities/upcoming_event.dart';

part 'event_model.g.dart';

/// Infrastructure model for UpcomingEvent with JSON serialization
/// Maps API response to domain entity
@JsonSerializable()
class EventModel {
  const EventModel({
    required this.id,
    required this.title,
    this.description,
    required this.eventType,
    required this.eventDate,
    this.eventEndDate,
    required this.venue,
    this.maxCapacity,
    required this.currentBookings,
    required this.ticketPrice,
    required this.isPublished,
    required this.isFull,
    required this.availableSlots,
    this.venueAddress,
    this.registrationStartDate,
    this.registrationEndDate,
    this.bannerImage,
    this.bannerImagePath,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates model from JSON map
  factory EventModel.fromJson(Map<String, dynamic> json) =>
      _$EventModelFromJson(json);

  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'event_type')
  final String eventType;

  @JsonKey(name: 'event_date')
  final String eventDate;

  @JsonKey(name: 'event_end_date')
  final String? eventEndDate;

  @JsonKey(name: 'venue')
  final String venue;

  @JsonKey(name: 'venue_address')
  final String? venueAddress;

  @JsonKey(name: 'max_capacity')
  final int? maxCapacity;

  @JsonKey(name: 'current_bookings')
  final int currentBookings;

  @JsonKey(name: 'ticket_price')
  final String ticketPrice;

  @JsonKey(name: 'is_published')
  final bool isPublished;

  @JsonKey(name: 'registration_start_date')
  final String? registrationStartDate;

  @JsonKey(name: 'registration_end_date')
  final String? registrationEndDate;

  @JsonKey(name: 'banner_image')
  final String? bannerImage;

  @JsonKey(name: 'banner_image_path')
  final String? bannerImagePath;

  @JsonKey(name: 'is_full')
  final bool isFull;

  @JsonKey(name: 'available_slots')
  final int availableSlots;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  /// Converts model to JSON map
  Map<String, dynamic> toJson() => _$EventModelToJson(this);

  /// Converts to domain entity
  UpcomingEvent toDomain() {
    return UpcomingEvent(
      id: id.toString(),
      title: title,
      description: description ?? '',
      eventType: eventType,
      eventDate: _parseDateTime(eventDate),
      eventEndDate: eventEndDate != null
          ? _parseDateTime(eventEndDate!)
          : _parseDateTime(eventDate),
      venue: venue,
      venueAddress: venueAddress,
      maxCapacity: maxCapacity ?? 0,
      currentBookings: currentBookings,
      ticketPrice: ticketPrice,
      isPublished: isPublished,
      registrationStartDate: registrationStartDate != null
          ? _parseDateTime(registrationStartDate!)
          : null,
      registrationEndDate: registrationEndDate != null
          ? _parseDateTime(registrationEndDate!)
          : null,
      bannerImage: bannerImage,
      isFull: isFull,
      availableSlots: availableSlots,
    );
  }

  /// Parses ISO8601 datetime string from API
  static DateTime _parseDateTime(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      // Return current date as fallback
      return DateTime.now();
    }
  }
}

/// Response wrapper for paginated events list
@JsonSerializable()
class EventListResponse {
  const EventListResponse({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  factory EventListResponse.fromJson(Map<String, dynamic> json) =>
      _$EventListResponseFromJson(json);

  @JsonKey(name: 'count')
  final int count;

  @JsonKey(name: 'results')
  final List<EventModel> results;

  @JsonKey(name: 'next')
  final String? next;

  @JsonKey(name: 'previous')
  final String? previous;

  Map<String, dynamic> toJson() => _$EventListResponseToJson(this);

  /// Gets the upcoming events (published, not ended, sorted by date)
  List<EventModel> get upcomingEvents {
    final now = DateTime.now();
    return results
        .where((event) {
          final endDate = EventModel._parseDateTime(event.eventEndDate ?? event.eventDate);
          return event.isPublished && endDate.isAfter(now);
        })
        .toList()
      ..sort((a, b) {
        final dateA = EventModel._parseDateTime(a.eventDate);
        final dateB = EventModel._parseDateTime(b.eventDate);
        return dateA.compareTo(dateB);
      });
  }
}
