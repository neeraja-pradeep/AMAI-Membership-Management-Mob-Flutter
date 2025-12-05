import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';

part 'registration_response_model.g.dart';

/// Policy preview model for registration response
@JsonSerializable()
class PolicyPreviewModel {
  const PolicyPreviewModel({
    this.policyNumber,
    this.premiumAmount,
    this.coverageAmount,
    this.startDate,
    this.endDate,
    this.age,
    this.ageSlab,
    this.premiumMultiplier,
  });

  factory PolicyPreviewModel.fromJson(Map<String, dynamic> json) =>
      _$PolicyPreviewModelFromJson(json);

  @JsonKey(name: 'policy_number')
  final String? policyNumber;

  @JsonKey(name: 'premium_amount')
  final num? premiumAmount;

  @JsonKey(name: 'coverage_amount')
  final num? coverageAmount;

  @JsonKey(name: 'start_date')
  final String? startDate;

  @JsonKey(name: 'end_date')
  final String? endDate;

  @JsonKey(name: 'age')
  final int? age;

  @JsonKey(name: 'age_slab')
  final String? ageSlab;

  @JsonKey(name: 'premium_multiplier')
  final int? premiumMultiplier;

  Map<String, dynamic> toJson() => _$PolicyPreviewModelToJson(this);
}

/// Infrastructure model for Insurance Registration Response
/// Contains order information for payment processing
@JsonSerializable()
class RegistrationResponseModel {
  const RegistrationResponseModel({
    required this.orderId,
    required this.amount,
    required this.currency,
    this.message,
    this.policyPreview,
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

  @JsonKey(name: 'policy_preview')
  final PolicyPreviewModel? policyPreview;

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
