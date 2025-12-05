// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PolicyPreviewModel _$PolicyPreviewModelFromJson(Map<String, dynamic> json) =>
    PolicyPreviewModel(
      policyNumber: json['policy_number'] as String?,
      premiumAmount: json['premium_amount'] as num?,
      coverageAmount: json['coverage_amount'] as num?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      age: (json['age'] as num?)?.toInt(),
      ageSlab: json['age_slab'] as String?,
      premiumMultiplier: (json['premium_multiplier'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PolicyPreviewModelToJson(PolicyPreviewModel instance) =>
    <String, dynamic>{
      'policy_number': instance.policyNumber,
      'premium_amount': instance.premiumAmount,
      'coverage_amount': instance.coverageAmount,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'age': instance.age,
      'age_slab': instance.ageSlab,
      'premium_multiplier': instance.premiumMultiplier,
    };

RegistrationResponseModel _$RegistrationResponseModelFromJson(
        Map<String, dynamic> json) =>
    RegistrationResponseModel(
      orderId: json['order_id'] as String,
      amount: json['amount'] as num,
      currency: json['currency'] as String? ?? 'INR',
      message: json['message'] as String?,
      policyPreview: json['policy_preview'] == null
          ? null
          : PolicyPreviewModel.fromJson(
              json['policy_preview'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RegistrationResponseModelToJson(
        RegistrationResponseModel instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'amount': instance.amount,
      'currency': instance.currency,
      'message': instance.message,
      'policy_preview': instance.policyPreview,
    };
