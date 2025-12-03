import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'renewal_response.freezed.dart';

/// Domain entity representing policy preview in renewal response
@freezed
class PolicyPreview with _$PolicyPreview {
  const factory PolicyPreview({
    required String policyNumber,
    required String policyStatus,
    required int basePremium,
    required int fineAmount,
    required int delayedMonths,
    required int totalPremium,
    required int coverageAmount,
    required String currentEndDate,
    required String newStartDate,
    required String newEndDate,
    int? age,
    String? ageSlab,
    int? premiumMultiplier,
  }) = _PolicyPreview;

  const PolicyPreview._();
}

/// Domain entity representing renewal response
@freezed
class RenewalResponse with _$RenewalResponse {
  const factory RenewalResponse({
    required String orderId,
    required int amount,
    required String currency,
    required PolicyPreview policyPreview,
  }) = _RenewalResponse;

  const RenewalResponse._();

  /// Formatted amount for display
  String get displayAmount {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(amount);
  }
}
