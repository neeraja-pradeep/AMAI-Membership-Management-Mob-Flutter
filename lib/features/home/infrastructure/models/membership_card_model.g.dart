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
      status: json['status'] as String,
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
      'status': instance.status,
      'membership_type': instance.membershipType,
      'start_date': instance.startDate,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

MembershipDetailResponse _$MembershipDetailResponseFromJson(
        Map<String, dynamic> json) =>
    MembershipDetailResponse(
      membership: json['membership'] == null
          ? null
          : MembershipCardModel.fromJson(
              json['membership'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MembershipDetailResponseToJson(
        MembershipDetailResponse instance) =>
    <String, dynamic>{
      'membership': instance.membership,
    };
