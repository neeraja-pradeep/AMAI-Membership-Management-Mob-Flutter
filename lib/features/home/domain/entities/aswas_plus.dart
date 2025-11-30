import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'aswas_plus.freezed.dart';

/// Domain entity representing an Aswas Plus insurance policy
/// Used to display insurance information on the homescreen
@freezed
class AswasPlus with _$AswasPlus {
  const factory AswasPlus({
    /// Unique identifier
    required String id,

    /// Policy number for display
    required String policyNumber,

    /// Policy validity end date
    required DateTime validUntil,

    /// Policy status (active, inactive, expired, etc.)
    required String policyStatus,

    /// Product description
    String? productDescription,

    /// Coverage amount
    String? coverageAmount,

    /// Premium amount
    String? premiumAmount,

    /// Policy start date
    DateTime? startDate,
  }) = _AswasPlus;

  const AswasPlus._();

  /// Check if policy is active
  bool get isActive => policyStatus.toLowerCase() == 'active';

  /// Check if policy has expired based on date
  bool get isExpired => validUntil.isBefore(DateTime.now());

  /// Check if policy is expiring soon (within 30 days)
  bool get isExpiringSoon {
    final daysUntilExpiry = validUntil.difference(DateTime.now()).inDays;
    return daysUntilExpiry > 0 && daysUntilExpiry <= 30;
  }

  /// Days remaining until expiry (negative if expired)
  int get daysRemaining => validUntil.difference(DateTime.now()).inDays;

  /// Formatted validity date string for display (e.g., "31 Dec 2025")
  String get displayValidUntil => DateFormat('dd MMM yyyy').format(validUntil);

  /// Formatted coverage amount for display
  String get displayCoverageAmount {
    if (coverageAmount == null) return '';
    final amount = double.tryParse(coverageAmount!) ?? 0;
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(amount);
  }

  /// Status text based on policy state
  String get statusText {
    if (!isActive) return policyStatus.toUpperCase();
    if (isExpired) return 'EXPIRED';
    if (isExpiringSoon) return 'EXPIRING SOON';
    return 'ACTIVE';
  }
}
