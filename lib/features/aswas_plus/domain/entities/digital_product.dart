import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'digital_product.freezed.dart';

/// Domain entity representing a digital product for renewal
@freezed
class DigitalProduct with _$DigitalProduct {
  const factory DigitalProduct({
    /// Unique identifier
    required int id,

    /// Product name (e.g., "Membership", "Aswas Plus")
    required String productName,

    /// Product type (e.g., "membership", "insurance")
    required String productType,

    /// Product description
    String? description,

    /// Fixed price for the product
    required String fixedPrice,

    /// Base price
    String? basePrice,

    /// Fine amount
    String? fine,

    /// Validity period in months
    int? validityPeriodMonths,

    /// Whether the product is active
    @Default(true) bool isActive,
  }) = _DigitalProduct;

  const DigitalProduct._();

  /// Formatted fixed price for display
  String get displayPrice {
    final amount = double.tryParse(fixedPrice) ?? 0;
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(amount);
  }

  /// Check if this is a membership product
  bool get isMembership => productType.toLowerCase() == 'membership';

  /// Check if this is an insurance product
  bool get isInsurance => productType.toLowerCase() == 'insurance';
}
