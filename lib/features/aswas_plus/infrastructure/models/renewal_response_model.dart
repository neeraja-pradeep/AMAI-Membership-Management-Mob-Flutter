import 'package:json_annotation/json_annotation.dart';
import 'package:myapp/features/aswas_plus/domain/entities/renewal_response.dart';

part 'renewal_response_model.g.dart';

/// Infrastructure model for PolicyPreview with JSON serialization
@JsonSerializable()
class PolicyPreviewModel {
  const PolicyPreviewModel({
    required this.policyNumber,
    required this.policyStatus,
    required this.basePremium,
    required this.fineAmount,
    required this.delayedMonths,
    required this.totalPremium,
    required this.coverageAmount,
    required this.currentEndDate,
    required this.newStartDate,
    required this.newEndDate,
    this.age,
    this.ageSlab,
    this.premiumMultiplier,
  });

  factory PolicyPreviewModel.fromJson(Map<String, dynamic> json) =>
      _$PolicyPreviewModelFromJson(json);

  @JsonKey(name: 'policy_number')
  final String policyNumber;

  @JsonKey(name: 'policy_status')
  final String policyStatus;

  @JsonKey(name: 'base_premium')
  final int basePremium;

  @JsonKey(name: 'fine_amount')
  final int fineAmount;

  @JsonKey(name: 'delayed_months')
  final int delayedMonths;

  @JsonKey(name: 'total_premium')
  final int totalPremium;

  @JsonKey(name: 'coverage_amount')
  final int coverageAmount;

  @JsonKey(name: 'current_end_date')
  final String currentEndDate;

  @JsonKey(name: 'new_start_date')
  final String newStartDate;

  @JsonKey(name: 'new_end_date')
  final String newEndDate;

  @JsonKey(name: 'age')
  final int? age;

  @JsonKey(name: 'age_slab')
  final String? ageSlab;

  @JsonKey(name: 'premium_multiplier')
  final int? premiumMultiplier;

  Map<String, dynamic> toJson() => _$PolicyPreviewModelToJson(this);

  PolicyPreview toDomain() {
    return PolicyPreview(
      policyNumber: policyNumber,
      policyStatus: policyStatus,
      basePremium: basePremium,
      fineAmount: fineAmount,
      delayedMonths: delayedMonths,
      totalPremium: totalPremium,
      coverageAmount: coverageAmount,
      currentEndDate: currentEndDate,
      newStartDate: newStartDate,
      newEndDate: newEndDate,
      age: age,
      ageSlab: ageSlab,
      premiumMultiplier: premiumMultiplier,
    );
  }
}

/// Infrastructure model for RenewalResponse with JSON serialization
@JsonSerializable()
class RenewalResponseModel {
  const RenewalResponseModel({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.policyPreview,
  });

  factory RenewalResponseModel.fromJson(Map<String, dynamic> json) =>
      _$RenewalResponseModelFromJson(json);

  @JsonKey(name: 'order_id')
  final String orderId;

  @JsonKey(name: 'amount')
  final int amount;

  @JsonKey(name: 'currency')
  final String currency;

  @JsonKey(name: 'policy_preview')
  final PolicyPreviewModel policyPreview;

  Map<String, dynamic> toJson() => _$RenewalResponseModelToJson(this);

  RenewalResponse toDomain() {
    return RenewalResponse(
      orderId: orderId,
      amount: amount,
      currency: currency,
      policyPreview: policyPreview.toDomain(),
    );
  }
}
