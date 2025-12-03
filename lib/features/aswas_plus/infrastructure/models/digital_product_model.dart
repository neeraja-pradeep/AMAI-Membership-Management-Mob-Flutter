import 'package:json_annotation/json_annotation.dart';
import 'package:myapp/features/aswas_plus/domain/entities/digital_product.dart';

part 'digital_product_model.g.dart';

/// Infrastructure model for DigitalProduct with JSON serialization
@JsonSerializable()
class DigitalProductModel {
  const DigitalProductModel({
    required this.id,
    required this.productName,
    required this.productType,
    this.description,
    required this.fixedPrice,
    this.basePrice,
    this.fine,
    this.validityPeriodMonths,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates model from JSON map
  factory DigitalProductModel.fromJson(Map<String, dynamic> json) =>
      _$DigitalProductModelFromJson(json);

  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'product_name')
  final String productName;

  @JsonKey(name: 'product_type')
  final String productType;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'fixed_price')
  final String fixedPrice;

  @JsonKey(name: 'base_price')
  final String? basePrice;

  @JsonKey(name: 'fine')
  final String? fine;

  @JsonKey(name: 'validity_period_months')
  final int? validityPeriodMonths;

  @JsonKey(name: 'is_active')
  final bool? isActive;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  /// Converts model to JSON map
  Map<String, dynamic> toJson() => _$DigitalProductModelToJson(this);

  /// Converts to domain entity
  DigitalProduct toDomain() {
    return DigitalProduct(
      id: id,
      productName: productName,
      productType: productType,
      description: description,
      fixedPrice: fixedPrice,
      basePrice: basePrice,
      fine: fine,
      validityPeriodMonths: validityPeriodMonths,
      isActive: isActive ?? true,
    );
  }
}
