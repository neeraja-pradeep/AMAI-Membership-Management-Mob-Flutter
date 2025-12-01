// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aswas_card_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AswasCardModel _$AswasCardModelFromJson(Map<String, dynamic> json) =>
    AswasCardModel(
      id: (json['id'] as num).toInt(),
      policyNumber: json['policy_number'] as String,
      endDate: json['end_date'] as String,
      policyStatus: json['policy_status'] as String,
      productDescription: json['product_description'] as String?,
      coverageAmount: json['coverage_amount'] as String?,
      premiumAmount: json['premium_amount'] as String?,
      startDate: json['start_date'] as String?,
      userId: (json['user'] as num?)?.toInt(),
      productId: (json['product'] as num?)?.toInt(),
      paymentId: (json['payment'] as num?)?.toInt(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$AswasCardModelToJson(AswasCardModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'policy_number': instance.policyNumber,
      'end_date': instance.endDate,
      'policy_status': instance.policyStatus,
      'product_description': instance.productDescription,
      'coverage_amount': instance.coverageAmount,
      'premium_amount': instance.premiumAmount,
      'start_date': instance.startDate,
      'user': instance.userId,
      'product': instance.productId,
      'payment': instance.paymentId,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

AswasListResponse _$AswasListResponseFromJson(Map<String, dynamic> json) =>
    AswasListResponse(
      count: (json['count'] as num).toInt(),
      results: (json['results'] as List<dynamic>)
          .map((e) => AswasCardModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      next: json['next'] as String?,
      previous: json['previous'] as String?,
    );

Map<String, dynamic> _$AswasListResponseToJson(AswasListResponse instance) =>
    <String, dynamic>{
      'count': instance.count,
      'results': instance.results,
      'next': instance.next,
      'previous': instance.previous,
    };
