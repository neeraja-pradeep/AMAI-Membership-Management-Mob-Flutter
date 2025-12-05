import 'package:freezed_annotation/freezed_annotation.dart';

part 'nominee.freezed.dart';

/// Domain entity representing a nominee for ASWAS Plus insurance policy
/// Used to display nominee information on the ASWAS Plus details screen
@freezed
class Nominee with _$Nominee {
  const factory Nominee({
    /// Unique identifier
    required int id,

    /// Nominee's full name
    required String nomineeName,

    /// Relationship to policy holder
    required String relationship,

    /// Contact number
    required String contactNumber,

    /// Email address
    String? email,

    /// Address
    String? address,

    /// Date of birth
    String? dateOfBirth,

    /// Allocation percentage
    String? allocationPercentage,

    /// Whether this is the primary nominee
    @Default(false) bool isPrimary,
  }) = _Nominee;

  const Nominee._();
}
