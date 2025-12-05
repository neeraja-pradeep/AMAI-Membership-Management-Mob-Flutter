// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'digital_product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DigitalProductModel _$DigitalProductModelFromJson(Map<String, dynamic> json) =>
    DigitalProductModel(
      id: (json['id'] as num).toInt(),
      productName: json['product_name'] as String,
      productType: json['product_type'] as String,
      description: json['description'] as String?,
      fixedPrice: json['fixed_price'] as String,
      basePrice: json['base_price'] as String?,
      fine: json['fine'] as String?,
      validityPeriodMonths: (json['validity_period_months'] as num?)?.toInt(),
      isActive: json['is_active'] as bool?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$DigitalProductModelToJson(
        DigitalProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_name': instance.productName,
      'product_type': instance.productType,
      'description': instance.description,
      'fixed_price': instance.fixedPrice,
      'base_price': instance.basePrice,
      'fine': instance.fine,
      'validity_period_months': instance.validityPeriodMonths,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
