// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nominee_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NomineeModel _$NomineeModelFromJson(Map<String, dynamic> json) => NomineeModel(
      id: (json['id'] as num).toInt(),
      nomineeName: json['nominee_name'] as String,
      relationship: json['relationship'] as String,
      contactNumber: json['contact_number'] as String,
      email: json['email'] as String?,
      address: json['address'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      allocationPercentage: json['allocation_percentage'] as String?,
      isPrimary: json['is_primary'] as bool?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      policy: (json['policy'] as num?)?.toInt(),
    );

Map<String, dynamic> _$NomineeModelToJson(NomineeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nominee_name': instance.nomineeName,
      'relationship': instance.relationship,
      'contact_number': instance.contactNumber,
      'email': instance.email,
      'address': instance.address,
      'date_of_birth': instance.dateOfBirth,
      'allocation_percentage': instance.allocationPercentage,
      'is_primary': instance.isPrimary,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'policy': instance.policy,
    };
