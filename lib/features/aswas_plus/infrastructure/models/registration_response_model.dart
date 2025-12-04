import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';

part 'registration_response_model.g.dart';

/// Infrastructure model for Insurance Registration Response
/// Contains order information for payment processing
@JsonSerializable()
class RegistrationResponseModel {
  const RegistrationResponseModel({
    required this.orderId,
    required this.amount,
    required this.currency,
    this.message,
  });

  factory RegistrationResponseModel.fromJson(Map<String, dynamic> json) =>
      _$RegistrationResponseModelFromJson(json);

  @JsonKey(name: 'order_id')
  final String orderId;

  @JsonKey(name: 'amount')
  final num amount;

  @JsonKey(name: 'currency', defaultValue: 'INR')
  final String currency;

  @JsonKey(name: 'message')
  final String? message;

  Map<String, dynamic> toJson() => _$RegistrationResponseModelToJson(this);

  /// Formatted amount for display
  String get displayAmount {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(amount);
  }
}
