// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_payment_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MembershipPaymentResponseModel _$MembershipPaymentResponseModelFromJson(
        Map<String, dynamic> json) =>
    MembershipPaymentResponseModel(
      orderId: json['order_id'] as String,
      amount: (json['amount'] as num).toInt(),
      currency: json['currency'] as String,
      membershipId: (json['membership_id'] as num).toInt(),
      membershipFee: (json['membership_fee'] as num).toInt(),
      fine: (json['fine'] as num?)?.toInt() ?? 0,
      delayedMonths: (json['delayed_months'] as num?)?.toInt() ?? 0,
      finePerMonth: (json['fine_per_month'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$MembershipPaymentResponseModelToJson(
        MembershipPaymentResponseModel instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'amount': instance.amount,
      'currency': instance.currency,
      'membership_id': instance.membershipId,
      'membership_fee': instance.membershipFee,
      'fine': instance.fine,
      'delayed_months': instance.delayedMonths,
      'fine_per_month': instance.finePerMonth,
    };
