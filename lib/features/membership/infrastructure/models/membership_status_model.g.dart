// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_status_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MembershipStatusModel _$MembershipStatusModelFromJson(
        Map<String, dynamic> json) =>
    MembershipStatusModel(
      id: (json['id'] as num).toInt(),
      membershipNumber: json['membership_number'] as String,
      userFirstName: json['user_first_name'] as String,
      endDate: json['end_date'] as String,
      status: json['status'] as String,
      membershipType: json['membership_type'] as String?,
      startDate: json['start_date'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      user: (json['user'] as num?)?.toInt(),
      membershipPdfUrl: json['membership_pdf_url'] as String?,
    );

Map<String, dynamic> _$MembershipStatusModelToJson(
        MembershipStatusModel instance) =>
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
      'user': instance.user,
      'membership_pdf_url': instance.membershipPdfUrl,
    };
