import 'package:json_annotation/json_annotation.dart';
import 'package:myapp/features/aswas_plus/domain/entities/nominee.dart';

part 'nominee_model.g.dart';

/// Infrastructure model for Nominee with JSON serialization
/// Maps API response to domain entity
@JsonSerializable()
class NomineeModel {
  const NomineeModel({
    required this.id,
    required this.nomineeName,
    required this.relationship,
    required this.contactNumber,
    this.email,
    this.address,
    this.dateOfBirth,
    this.allocationPercentage,
    this.isPrimary,
    this.createdAt,
    this.updatedAt,
    this.policy,
  });

  /// Creates model from JSON map
  factory NomineeModel.fromJson(Map<String, dynamic> json) =>
      _$NomineeModelFromJson(json);

  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'nominee_name')
  final String nomineeName;

  @JsonKey(name: 'relationship')
  final String relationship;

  @JsonKey(name: 'contact_number')
  final String contactNumber;

  @JsonKey(name: 'email')
  final String? email;

  @JsonKey(name: 'address')
  final String? address;

  @JsonKey(name: 'date_of_birth')
  final String? dateOfBirth;

  @JsonKey(name: 'allocation_percentage')
  final String? allocationPercentage;

  @JsonKey(name: 'is_primary')
  final bool? isPrimary;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @JsonKey(name: 'policy')
  final int? policy;

  /// Converts model to JSON map
  Map<String, dynamic> toJson() => _$NomineeModelToJson(this);

  /// Converts to domain entity
  Nominee toDomain() {
    return Nominee(
      id: id,
      nomineeName: nomineeName,
      relationship: relationship,
      contactNumber: contactNumber,
      email: email,
      address: address,
      dateOfBirth: dateOfBirth,
      allocationPercentage: allocationPercentage,
      isPrimary: isPrimary ?? false,
    );
  }
}
