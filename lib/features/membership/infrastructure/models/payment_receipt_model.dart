import 'package:json_annotation/json_annotation.dart';

part 'payment_receipt_model.g.dart';

/// Infrastructure model for PaymentReceipt with JSON serialization
/// Maps API response from /api/payments/payment/ endpoint
@JsonSerializable()
class PaymentReceiptModel {
  const PaymentReceiptModel({
    required this.id,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    required this.paymentDate,
    this.orderId,
    this.razorpayPaymentId,
    this.gatewayResponse,
  });

  /// Creates model from JSON map
  factory PaymentReceiptModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentReceiptModelFromJson(json);

  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'amount')
  final String amount;

  @JsonKey(name: 'currency')
  final String currency;

  @JsonKey(name: 'payment_method')
  final String paymentMethod;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'payment_date')
  final String paymentDate;

  @JsonKey(name: 'order_id')
  final String? orderId;

  @JsonKey(name: 'razorpay_payment_id')
  final String? razorpayPaymentId;

  @JsonKey(name: 'gateway_response')
  final GatewayResponseModel? gatewayResponse;

  /// Converts model to JSON map
  Map<String, dynamic> toJson() => _$PaymentReceiptModelToJson(this);

  /// Gets the product name from gateway response notes
  String get productName {
    final notes = gatewayResponse?.notes;
    if (notes != null && notes.containsKey('product_name')) {
      return notes['product_name']?.toString() ?? 'Payment';
    }
    return gatewayResponse?.description ?? 'Payment';
  }

  /// Gets the description from gateway response
  String get description {
    return gatewayResponse?.description ?? 'Payment';
  }
}

/// Model for gateway_response nested object
@JsonSerializable()
class GatewayResponseModel {
  const GatewayResponseModel({
    this.description,
    this.notes,
  });

  factory GatewayResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GatewayResponseModelFromJson(json);

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'notes')
  final Map<String, dynamic>? notes;

  Map<String, dynamic> toJson() => _$GatewayResponseModelToJson(this);
}
