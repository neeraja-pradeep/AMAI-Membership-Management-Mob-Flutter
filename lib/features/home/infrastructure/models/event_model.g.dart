// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventModel _$EventModelFromJson(Map<String, dynamic> json) => EventModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      eventType: json['event_type'] as String,
      eventDate: json['event_date'] as String,
      eventEndDate: json['event_end_date'] as String?,
      venue: json['venue'] as String,
      maxCapacity: (json['max_capacity'] as num?)?.toInt(),
      currentBookings: (json['current_bookings'] as num).toInt(),
      ticketPrice: json['ticket_price'] as String,
      isPublished: json['is_published'] as bool,
      isFull: json['is_full'] as bool,
      availableSlots: (json['available_slots'] as num?)?.toInt(),
      venueAddress: json['venue_address'] as String?,
      registrationStartDate: json['registration_start_date'] as String?,
      registrationEndDate: json['registration_end_date'] as String?,
      bannerImage: json['banner_image'] as String?,
      bannerImagePath: json['banner_image_path'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$EventModelToJson(EventModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'event_type': instance.eventType,
      'event_date': instance.eventDate,
      'event_end_date': instance.eventEndDate,
      'venue': instance.venue,
      'venue_address': instance.venueAddress,
      'max_capacity': instance.maxCapacity,
      'current_bookings': instance.currentBookings,
      'ticket_price': instance.ticketPrice,
      'is_published': instance.isPublished,
      'registration_start_date': instance.registrationStartDate,
      'registration_end_date': instance.registrationEndDate,
      'banner_image': instance.bannerImage,
      'banner_image_path': instance.bannerImagePath,
      'is_full': instance.isFull,
      'available_slots': instance.availableSlots,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

EventListResponse _$EventListResponseFromJson(Map<String, dynamic> json) =>
    EventListResponse(
      count: (json['count'] as num).toInt(),
      results: (json['results'] as List<dynamic>)
          .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      next: json['next'] as String?,
      previous: json['previous'] as String?,
    );

Map<String, dynamic> _$EventListResponseToJson(EventListResponse instance) =>
    <String, dynamic>{
      'count': instance.count,
      'results': instance.results,
      'next': instance.next,
      'previous': instance.previous,
    };
