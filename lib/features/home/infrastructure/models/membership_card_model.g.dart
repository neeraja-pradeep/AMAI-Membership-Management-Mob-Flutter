// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_card_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MembershipCardModel _$MembershipCardModelFromJson(Map<String, dynamic> json) =>
    MembershipCardModel(
      id: (json['id'] as num).toInt(),
      membershipNumber: json['membership_number'] as String,
      userFirstName: json['user_first_name'] as String,
      endDate: json['end_date'] as String,
      isActive: json['is_active'] as bool,
      membershipType: json['membership_type'] as String?,
      startDate: json['start_date'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$MembershipCardModelToJson(
        MembershipCardModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'membership_number': instance.membershipNumber,
      'user_first_name': instance.userFirstName,
      'end_date': instance.endDate,
      'is_active': instance.isActive,
      'membership_type': instance.membershipType,
      'start_date': instance.startDate,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

MembershipListResponse _$MembershipListResponseFromJson(
        Map<String, dynamic> json) =>
    MembershipListResponse(
      count: (json['count'] as num).toInt(),
      results: (json['results'] as List<dynamic>)
          .map((e) => MembershipCardModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      next: json['next'] as String?,
      previous: json['previous'] as String?,
    );

Map<String, dynamic> _$MembershipListResponseToJson(
        MembershipListResponse instance) =>
    <String, dynamic>{
      'count': instance.count,
      'results': instance.results,
      'next': instance.next,
      'previous': instance.previous,
    };
