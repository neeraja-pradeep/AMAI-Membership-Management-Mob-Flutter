// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_card_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MembershipCardModel _$MembershipCardModelFromJson(Map<String, dynamic> json) =>
    MembershipCardModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      membershipNumber: json['membership_number'] as String,
      userFirstName: json['user_first_name'] as String,
      endDate: json['end_date'] as String,
      status: json['status'] as String,
      user: (json['user'] as num?)?.toInt(),
      membershipType: json['membership_type'] as String?,
      startDate: json['start_date'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      academicDetails: (json['academic_details'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      professionalDetails: (json['professional_details'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      medicalCouncilState: json['medical_council_state'] as String?,
      medicalCouncilNo: json['medical_council_no'] as String?,
      centralCouncilNo: json['central_council_no'] as String?,
      ugCollege: json['ug_college'] as String?,
    );

Map<String, dynamic> _$MembershipCardModelToJson(
        MembershipCardModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'membership_number': instance.membershipNumber,
      'user_first_name': instance.userFirstName,
      'end_date': instance.endDate,
      'status': instance.status,
      'user': instance.user,
      'membership_type': instance.membershipType,
      'start_date': instance.startDate,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'academic_details': instance.academicDetails,
      'professional_details': instance.professionalDetails,
      'medical_council_state': instance.medicalCouncilState,
      'medical_council_no': instance.medicalCouncilNo,
      'central_council_no': instance.centralCouncilNo,
      'ug_college': instance.ugCollege,
    };

MembershipDetailResponse _$MembershipDetailResponseFromJson(
        Map<String, dynamic> json) =>
    MembershipDetailResponse(
      membership: json['membership'] == null
          ? null
          : MembershipCardModel.fromJson(
              json['membership'] as Map<String, dynamic>),
      error: json['error'] as String?,
      applicationStatus: json['application_status'] as String?,
      applicationDate: json['application_date'] as String?,
    );

Map<String, dynamic> _$MembershipDetailResponseToJson(
        MembershipDetailResponse instance) =>
    <String, dynamic>{
      'membership': instance.membership,
      'error': instance.error,
      'application_status': instance.applicationStatus,
      'application_date': instance.applicationDate,
    };
