// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'renewal_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PolicyPreviewModel _$PolicyPreviewModelFromJson(Map<String, dynamic> json) =>
    PolicyPreviewModel(
      policyNumber: json['policy_number'] as String,
      policyStatus: json['policy_status'] as String,
      basePremium: (json['base_premium'] as num).toInt(),
      fineAmount: (json['fine_amount'] as num).toInt(),
      delayedMonths: (json['delayed_months'] as num).toInt(),
      totalPremium: (json['total_premium'] as num).toInt(),
      coverageAmount: (json['coverage_amount'] as num).toInt(),
      currentEndDate: json['current_end_date'] as String,
      newStartDate: json['new_start_date'] as String,
      newEndDate: json['new_end_date'] as String,
      age: (json['age'] as num?)?.toInt(),
      ageSlab: json['age_slab'] as String?,
      premiumMultiplier: (json['premium_multiplier'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PolicyPreviewModelToJson(PolicyPreviewModel instance) =>
    <String, dynamic>{
      'policy_number': instance.policyNumber,
      'policy_status': instance.policyStatus,
      'base_premium': instance.basePremium,
      'fine_amount': instance.fineAmount,
      'delayed_months': instance.delayedMonths,
      'total_premium': instance.totalPremium,
      'coverage_amount': instance.coverageAmount,
      'current_end_date': instance.currentEndDate,
      'new_start_date': instance.newStartDate,
      'new_end_date': instance.newEndDate,
      'age': instance.age,
      'age_slab': instance.ageSlab,
      'premium_multiplier': instance.premiumMultiplier,
    };

RenewalResponseModel _$RenewalResponseModelFromJson(
        Map<String, dynamic> json) =>
    RenewalResponseModel(
      orderId: json['order_id'] as String,
      amount: (json['amount'] as num).toInt(),
      currency: json['currency'] as String,
      policyPreview: PolicyPreviewModel.fromJson(
          json['policy_preview'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RenewalResponseModelToJson(
        RenewalResponseModel instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'amount': instance.amount,
      'currency': instance.currency,
      'policy_preview': instance.policyPreview,
    };
