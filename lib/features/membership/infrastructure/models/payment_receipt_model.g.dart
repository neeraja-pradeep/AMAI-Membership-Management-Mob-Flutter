// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_receipt_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentReceiptModel _$PaymentReceiptModelFromJson(Map<String, dynamic> json) =>
    PaymentReceiptModel(
      id: (json['id'] as num).toInt(),
      amount: json['amount'] as String,
      currency: json['currency'] as String,
      paymentMethod: json['payment_method'] as String,
      status: json['status'] as String,
      paymentDate: json['payment_date'] as String,
      orderId: json['order_id'] as String?,
      razorpayPaymentId: json['razorpay_payment_id'] as String?,
      gatewayResponse: json['gateway_response'] == null
          ? null
          : GatewayResponseModel.fromJson(
              json['gateway_response'] as Map<String, dynamic>),
      receiptPdfUrl: json['receipt_pdf_url'] as String?,
    );

Map<String, dynamic> _$PaymentReceiptModelToJson(PaymentReceiptModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'currency': instance.currency,
      'payment_method': instance.paymentMethod,
      'status': instance.status,
      'payment_date': instance.paymentDate,
      'order_id': instance.orderId,
      'razorpay_payment_id': instance.razorpayPaymentId,
      'gateway_response': instance.gatewayResponse?.toJson(),
      'receipt_pdf_url': instance.receiptPdfUrl,
    };

GatewayResponseModel _$GatewayResponseModelFromJson(Map<String, dynamic> json) =>
    GatewayResponseModel(
      description: json['description'] as String?,
      notes: json['notes'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$GatewayResponseModelToJson(
        GatewayResponseModel instance) =>
    <String, dynamic>{
      'description': instance.description,
      'notes': instance.notes,
    };
