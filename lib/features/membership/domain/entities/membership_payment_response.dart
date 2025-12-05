import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'membership_payment_response.freezed.dart';

/// Domain entity representing membership payment initiation response
@freezed
class MembershipPaymentResponse with _$MembershipPaymentResponse {
  const factory MembershipPaymentResponse({
    /// Razorpay order ID
    required String orderId,

    /// Payment amount
    required int amount,

    /// Currency code (e.g., "INR")
    required String currency,

    /// Membership ID
    required int membershipId,

    /// Membership fee amount
    required int membershipFee,

    /// Fine amount (if any)
    @Default(0) int fine,

    /// Number of delayed months
    @Default(0) int delayedMonths,

    /// Fine per month
    @Default(0) int finePerMonth,
  }) = _MembershipPaymentResponse;

  const MembershipPaymentResponse._();

  /// Formatted amount for display
  String get displayAmount {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(amount);
  }

  /// Formatted membership fee for display
  String get displayMembershipFee {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(membershipFee);
  }

  /// Formatted fine for display
  String get displayFine {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(fine);
  }

  /// Check if there is any fine
  bool get hasFine => fine > 0;
}
