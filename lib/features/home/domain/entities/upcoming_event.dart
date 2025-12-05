import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'upcoming_event.freezed.dart';

/// Domain entity representing an Upcoming Event
/// Used to display event information on the homescreen
@freezed
class UpcomingEvent with _$UpcomingEvent {
  const factory UpcomingEvent({
    /// Unique identifier
    required String id,

    /// Event title
    required String title,

    /// Event description
    required String description,

    /// Event type (conference, workshop, etc.)
    required String eventType,

    /// Event start date and time
    required DateTime eventDate,

    /// Event end date and time
    required DateTime eventEndDate,

    /// Venue name
    required String venue,

    /// Venue address
    String? venueAddress,

    /// Maximum capacity
    required int maxCapacity,

    /// Current number of bookings
    required int currentBookings,

    /// Ticket price (as string for currency formatting)
    required String ticketPrice,

    /// Whether registration is open
    required bool isPublished,

    /// Registration start date
    DateTime? registrationStartDate,

    /// Registration end date
    DateTime? registrationEndDate,

    /// Banner image URL
    String? bannerImage,

    /// Whether event is fully booked
    required bool isFull,

    /// Available slots
    required int availableSlots,
  }) = _UpcomingEvent;

  const UpcomingEvent._();

  /// Check if event has already started
  bool get hasStarted => DateTime.now().isAfter(eventDate);

  /// Check if event has ended
  bool get hasEnded => DateTime.now().isAfter(eventEndDate);

  /// Check if registration is currently open
  bool get isRegistrationOpen {
    final now = DateTime.now();
    if (registrationStartDate == null || registrationEndDate == null) {
      return isPublished && !isFull && !hasStarted;
    }
    return isPublished &&
        !isFull &&
        now.isAfter(registrationStartDate!) &&
        now.isBefore(registrationEndDate!);
  }

  /// Formatted event date for display (e.g., "01 Dec 2025")
  String get displayDate => DateFormat('dd MMM yyyy').format(eventDate);

  /// Formatted event time for display (e.g., "10:00 AM")
  String get displayTime => DateFormat('hh:mm a').format(eventDate);

  /// Formatted date and time for display (e.g., "01 Dec 2025, 10:00 AM")
  String get displayDateTime =>
      '${DateFormat('dd MMM yyyy').format(eventDate)}, ${DateFormat('hh:mm a').format(eventDate)}';

  /// Formatted time range (e.g., "10:00 AM - 12:00 PM")
  String get displayTimeRange =>
      '${DateFormat('hh:mm a').format(eventDate)} - ${DateFormat('hh:mm a').format(eventEndDate)}';

  /// Formatted ticket price with currency
  String get displayTicketPrice {
    final price = double.tryParse(ticketPrice) ?? 0;
    if (price == 0) return 'Free';
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(price);
  }

  /// Days until event
  int get daysUntilEvent => eventDate.difference(DateTime.now()).inDays;

  /// Display event type in readable format
  String get displayEventType {
    switch (eventType.toLowerCase()) {
      case 'conference':
        return 'Conference';
      case 'workshop':
        return 'Workshop';
      case 'seminar':
        return 'Seminar';
      case 'webinar':
        return 'Webinar';
      case 'other':
        return 'Event';
      default:
        return eventType;
    }
  }

  /// Full banner image URL with https prefix
  String? get fullBannerImageUrl {
    if (bannerImage == null || bannerImage!.isEmpty) return null;
    if (bannerImage!.startsWith('http')) return bannerImage;
    return 'https://$bannerImage';
  }
}
