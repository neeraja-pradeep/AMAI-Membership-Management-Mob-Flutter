// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upcoming_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$UpcomingEvent {
  /// Unique identifier
  String get id => throw _privateConstructorUsedError;

  /// Event title
  String get title => throw _privateConstructorUsedError;

  /// Event description
  String get description => throw _privateConstructorUsedError;

  /// Event type (conference, workshop, etc.)
  String get eventType => throw _privateConstructorUsedError;

  /// Event start date and time
  DateTime get eventDate => throw _privateConstructorUsedError;

  /// Event end date and time
  DateTime get eventEndDate => throw _privateConstructorUsedError;

  /// Venue name
  String get venue => throw _privateConstructorUsedError;

  /// Venue address
  String? get venueAddress => throw _privateConstructorUsedError;

  /// Maximum capacity
  int get maxCapacity => throw _privateConstructorUsedError;

  /// Current number of bookings
  int get currentBookings => throw _privateConstructorUsedError;

  /// Ticket price (as string for currency formatting)
  String get ticketPrice => throw _privateConstructorUsedError;

  /// Whether registration is open
  bool get isPublished => throw _privateConstructorUsedError;

  /// Registration start date
  DateTime? get registrationStartDate => throw _privateConstructorUsedError;

  /// Registration end date
  DateTime? get registrationEndDate => throw _privateConstructorUsedError;

  /// Banner image URL
  String? get bannerImage => throw _privateConstructorUsedError;

  /// Whether event is fully booked
  bool get isFull => throw _privateConstructorUsedError;

  /// Available slots
  int get availableSlots => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $UpcomingEventCopyWith<UpcomingEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpcomingEventCopyWith<$Res> {
  factory $UpcomingEventCopyWith(
          UpcomingEvent value, $Res Function(UpcomingEvent) then) =
      _$UpcomingEventCopyWithImpl<$Res, UpcomingEvent>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String eventType,
      DateTime eventDate,
      DateTime eventEndDate,
      String venue,
      String? venueAddress,
      int maxCapacity,
      int currentBookings,
      String ticketPrice,
      bool isPublished,
      DateTime? registrationStartDate,
      DateTime? registrationEndDate,
      String? bannerImage,
      bool isFull,
      int availableSlots});
}

/// @nodoc
class _$UpcomingEventCopyWithImpl<$Res, $Val extends UpcomingEvent>
    implements $UpcomingEventCopyWith<$Res> {
  _$UpcomingEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? eventType = null,
    Object? eventDate = null,
    Object? eventEndDate = null,
    Object? venue = null,
    Object? venueAddress = freezed,
    Object? maxCapacity = null,
    Object? currentBookings = null,
    Object? ticketPrice = null,
    Object? isPublished = null,
    Object? registrationStartDate = freezed,
    Object? registrationEndDate = freezed,
    Object? bannerImage = freezed,
    Object? isFull = null,
    Object? availableSlots = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      eventType: null == eventType
          ? _value.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as String,
      eventDate: null == eventDate
          ? _value.eventDate
          : eventDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      eventEndDate: null == eventEndDate
          ? _value.eventEndDate
          : eventEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      venue: null == venue
          ? _value.venue
          : venue // ignore: cast_nullable_to_non_nullable
              as String,
      venueAddress: freezed == venueAddress
          ? _value.venueAddress
          : venueAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      maxCapacity: null == maxCapacity
          ? _value.maxCapacity
          : maxCapacity // ignore: cast_nullable_to_non_nullable
              as int,
      currentBookings: null == currentBookings
          ? _value.currentBookings
          : currentBookings // ignore: cast_nullable_to_non_nullable
              as int,
      ticketPrice: null == ticketPrice
          ? _value.ticketPrice
          : ticketPrice // ignore: cast_nullable_to_non_nullable
              as String,
      isPublished: null == isPublished
          ? _value.isPublished
          : isPublished // ignore: cast_nullable_to_non_nullable
              as bool,
      registrationStartDate: freezed == registrationStartDate
          ? _value.registrationStartDate
          : registrationStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      registrationEndDate: freezed == registrationEndDate
          ? _value.registrationEndDate
          : registrationEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      bannerImage: freezed == bannerImage
          ? _value.bannerImage
          : bannerImage // ignore: cast_nullable_to_non_nullable
              as String?,
      isFull: null == isFull
          ? _value.isFull
          : isFull // ignore: cast_nullable_to_non_nullable
              as bool,
      availableSlots: null == availableSlots
          ? _value.availableSlots
          : availableSlots // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UpcomingEventImplCopyWith<$Res>
    implements $UpcomingEventCopyWith<$Res> {
  factory _$$UpcomingEventImplCopyWith(
          _$UpcomingEventImpl value, $Res Function(_$UpcomingEventImpl) then) =
      __$$UpcomingEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String eventType,
      DateTime eventDate,
      DateTime eventEndDate,
      String venue,
      String? venueAddress,
      int maxCapacity,
      int currentBookings,
      String ticketPrice,
      bool isPublished,
      DateTime? registrationStartDate,
      DateTime? registrationEndDate,
      String? bannerImage,
      bool isFull,
      int availableSlots});
}

/// @nodoc
class __$$UpcomingEventImplCopyWithImpl<$Res>
    extends _$UpcomingEventCopyWithImpl<$Res, _$UpcomingEventImpl>
    implements _$$UpcomingEventImplCopyWith<$Res> {
  __$$UpcomingEventImplCopyWithImpl(
      _$UpcomingEventImpl _value, $Res Function(_$UpcomingEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? eventType = null,
    Object? eventDate = null,
    Object? eventEndDate = null,
    Object? venue = null,
    Object? venueAddress = freezed,
    Object? maxCapacity = null,
    Object? currentBookings = null,
    Object? ticketPrice = null,
    Object? isPublished = null,
    Object? registrationStartDate = freezed,
    Object? registrationEndDate = freezed,
    Object? bannerImage = freezed,
    Object? isFull = null,
    Object? availableSlots = null,
  }) {
    return _then(_$UpcomingEventImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      eventType: null == eventType
          ? _value.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as String,
      eventDate: null == eventDate
          ? _value.eventDate
          : eventDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      eventEndDate: null == eventEndDate
          ? _value.eventEndDate
          : eventEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      venue: null == venue
          ? _value.venue
          : venue // ignore: cast_nullable_to_non_nullable
              as String,
      venueAddress: freezed == venueAddress
          ? _value.venueAddress
          : venueAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      maxCapacity: null == maxCapacity
          ? _value.maxCapacity
          : maxCapacity // ignore: cast_nullable_to_non_nullable
              as int,
      currentBookings: null == currentBookings
          ? _value.currentBookings
          : currentBookings // ignore: cast_nullable_to_non_nullable
              as int,
      ticketPrice: null == ticketPrice
          ? _value.ticketPrice
          : ticketPrice // ignore: cast_nullable_to_non_nullable
              as String,
      isPublished: null == isPublished
          ? _value.isPublished
          : isPublished // ignore: cast_nullable_to_non_nullable
              as bool,
      registrationStartDate: freezed == registrationStartDate
          ? _value.registrationStartDate
          : registrationStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      registrationEndDate: freezed == registrationEndDate
          ? _value.registrationEndDate
          : registrationEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      bannerImage: freezed == bannerImage
          ? _value.bannerImage
          : bannerImage // ignore: cast_nullable_to_non_nullable
              as String?,
      isFull: null == isFull
          ? _value.isFull
          : isFull // ignore: cast_nullable_to_non_nullable
              as bool,
      availableSlots: null == availableSlots
          ? _value.availableSlots
          : availableSlots // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$UpcomingEventImpl extends _UpcomingEvent {
  const _$UpcomingEventImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.eventType,
      required this.eventDate,
      required this.eventEndDate,
      required this.venue,
      this.venueAddress,
      required this.maxCapacity,
      required this.currentBookings,
      required this.ticketPrice,
      required this.isPublished,
      this.registrationStartDate,
      this.registrationEndDate,
      this.bannerImage,
      required this.isFull,
      required this.availableSlots})
      : super._();

  /// Unique identifier
  @override
  final String id;

  /// Event title
  @override
  final String title;

  /// Event description
  @override
  final String description;

  /// Event type (conference, workshop, etc.)
  @override
  final String eventType;

  /// Event start date and time
  @override
  final DateTime eventDate;

  /// Event end date and time
  @override
  final DateTime eventEndDate;

  /// Venue name
  @override
  final String venue;

  /// Venue address
  @override
  final String? venueAddress;

  /// Maximum capacity
  @override
  final int maxCapacity;

  /// Current number of bookings
  @override
  final int currentBookings;

  /// Ticket price (as string for currency formatting)
  @override
  final String ticketPrice;

  /// Whether registration is open
  @override
  final bool isPublished;

  /// Registration start date
  @override
  final DateTime? registrationStartDate;

  /// Registration end date
  @override
  final DateTime? registrationEndDate;

  /// Banner image URL
  @override
  final String? bannerImage;

  /// Whether event is fully booked
  @override
  final bool isFull;

  /// Available slots
  @override
  final int availableSlots;

  @override
  String toString() {
    return 'UpcomingEvent(id: $id, title: $title, description: $description, eventType: $eventType, eventDate: $eventDate, eventEndDate: $eventEndDate, venue: $venue, venueAddress: $venueAddress, maxCapacity: $maxCapacity, currentBookings: $currentBookings, ticketPrice: $ticketPrice, isPublished: $isPublished, registrationStartDate: $registrationStartDate, registrationEndDate: $registrationEndDate, bannerImage: $bannerImage, isFull: $isFull, availableSlots: $availableSlots)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpcomingEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.eventType, eventType) ||
                other.eventType == eventType) &&
            (identical(other.eventDate, eventDate) ||
                other.eventDate == eventDate) &&
            (identical(other.eventEndDate, eventEndDate) ||
                other.eventEndDate == eventEndDate) &&
            (identical(other.venue, venue) || other.venue == venue) &&
            (identical(other.venueAddress, venueAddress) ||
                other.venueAddress == venueAddress) &&
            (identical(other.maxCapacity, maxCapacity) ||
                other.maxCapacity == maxCapacity) &&
            (identical(other.currentBookings, currentBookings) ||
                other.currentBookings == currentBookings) &&
            (identical(other.ticketPrice, ticketPrice) ||
                other.ticketPrice == ticketPrice) &&
            (identical(other.isPublished, isPublished) ||
                other.isPublished == isPublished) &&
            (identical(other.registrationStartDate, registrationStartDate) ||
                other.registrationStartDate == registrationStartDate) &&
            (identical(other.registrationEndDate, registrationEndDate) ||
                other.registrationEndDate == registrationEndDate) &&
            (identical(other.bannerImage, bannerImage) ||
                other.bannerImage == bannerImage) &&
            (identical(other.isFull, isFull) || other.isFull == isFull) &&
            (identical(other.availableSlots, availableSlots) ||
                other.availableSlots == availableSlots));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      eventType,
      eventDate,
      eventEndDate,
      venue,
      venueAddress,
      maxCapacity,
      currentBookings,
      ticketPrice,
      isPublished,
      registrationStartDate,
      registrationEndDate,
      bannerImage,
      isFull,
      availableSlots);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UpcomingEventImplCopyWith<_$UpcomingEventImpl> get copyWith =>
      __$$UpcomingEventImplCopyWithImpl<_$UpcomingEventImpl>(this, _$identity);
}

abstract class _UpcomingEvent extends UpcomingEvent {
  const factory _UpcomingEvent(
      {required final String id,
      required final String title,
      required final String description,
      required final String eventType,
      required final DateTime eventDate,
      required final DateTime eventEndDate,
      required final String venue,
      final String? venueAddress,
      required final int maxCapacity,
      required final int currentBookings,
      required final String ticketPrice,
      required final bool isPublished,
      final DateTime? registrationStartDate,
      final DateTime? registrationEndDate,
      final String? bannerImage,
      required final bool isFull,
      required final int availableSlots}) = _$UpcomingEventImpl;
  const _UpcomingEvent._() : super._();

  @override

  /// Unique identifier
  String get id;
  @override

  /// Event title
  String get title;
  @override

  /// Event description
  String get description;
  @override

  /// Event type (conference, workshop, etc.)
  String get eventType;
  @override

  /// Event start date and time
  DateTime get eventDate;
  @override

  /// Event end date and time
  DateTime get eventEndDate;
  @override

  /// Venue name
  String get venue;
  @override

  /// Venue address
  String? get venueAddress;
  @override

  /// Maximum capacity
  int get maxCapacity;
  @override

  /// Current number of bookings
  int get currentBookings;
  @override

  /// Ticket price (as string for currency formatting)
  String get ticketPrice;
  @override

  /// Whether registration is open
  bool get isPublished;
  @override

  /// Registration start date
  DateTime? get registrationStartDate;
  @override

  /// Registration end date
  DateTime? get registrationEndDate;
  @override

  /// Banner image URL
  String? get bannerImage;
  @override

  /// Whether event is fully booked
  bool get isFull;
  @override

  /// Available slots
  int get availableSlots;
  @override
  @JsonKey(ignore: true)
  _$$UpcomingEventImplCopyWith<_$UpcomingEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
