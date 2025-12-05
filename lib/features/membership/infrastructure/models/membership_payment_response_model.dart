import 'package:json_annotation/json_annotation.dart';
import 'package:myapp/features/membership/domain/entities/membership_payment_response.dart';

part 'membership_payment_response_model.g.dart';

/// Infrastructure model for MembershipPaymentResponse with JSON serialization
@JsonSerializable()
class MembershipPaymentResponseModel {
  const MembershipPaymentResponseModel({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.membershipId,
    required this.membershipFee,
    this.fine = 0,
    this.delayedMonths = 0,
    this.finePerMonth = 0,
  });

  factory MembershipPaymentResponseModel.fromJson(Map<String, dynamic> json) =>
      _$MembershipPaymentResponseModelFromJson(json);

  @JsonKey(name: 'order_id')
  final String orderId;

  @JsonKey(name: 'amount')
  final int amount;

  @JsonKey(name: 'currency')
  final String currency;

  @JsonKey(name: 'membership_id')
  final int membershipId;

  @JsonKey(name: 'membership_fee')
  final int membershipFee;

  @JsonKey(name: 'fine')
  final int fine;

  @JsonKey(name: 'delayed_months')
  final int delayedMonths;

  @JsonKey(name: 'fine_per_month')
  final int finePerMonth;

  Map<String, dynamic> toJson() => _$MembershipPaymentResponseModelToJson(this);

  MembershipPaymentResponse toDomain() {
    return MembershipPaymentResponse(
      orderId: orderId,
      amount: amount,
      currency: currency,
      membershipId: membershipId,
      membershipFee: membershipFee,
      fine: fine,
      delayedMonths: delayedMonths,
      finePerMonth: finePerMonth,
    );
  }
}
