// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegistrationResponseModel _$RegistrationResponseModelFromJson(
        Map<String, dynamic> json) =>
    RegistrationResponseModel(
      orderId: json['order_id'] as String,
      amount: json['amount'] as num,
      currency: json['currency'] as String? ?? 'INR',
      message: json['message'] as String?,
    );

Map<String, dynamic> _$RegistrationResponseModelToJson(
        RegistrationResponseModel instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'amount': instance.amount,
      'currency': instance.currency,
      'message': instance.message,
    };
