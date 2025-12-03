/// Address model supporting multiple address types:
/// - Primary (Communication)
/// - APTA Mailing
/// - Permanent Address
///
/// All three share the same fields but differ in how they are saved.
class AddressDetails {
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String postalCode;
  final String countryId;
  final String stateId;
  final String districtId;

  /// NEW → Address type: communication, apta, permanent
  /// This helps backend and caching logic differentiate.
  final AddressType type;

  /// Only the communication address should be primary
  final bool isPrimary;

  const AddressDetails({
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.postalCode,
    required this.countryId,
    required this.stateId,
    required this.districtId,
    required this.type,
    this.isPrimary = false,
  });

  /// Readable single-line formatted address
  String get fullAddress => [
    addressLine1,
    addressLine2,
    city,
    districtId,
    stateId,
    postalCode,
    countryId,
  ].where((p) => p.isNotEmpty).join(', ');

  /// Validation (dropdown dependency logic)
  bool get isComplete =>
      addressLine1.isNotEmpty &&
      addressLine2.isNotEmpty &&
      countryId.isNotEmpty &&
      stateId.isNotEmpty &&
      districtId.isNotEmpty &&
      city.isNotEmpty &&
      postalCode.isNotEmpty;

  AddressDetails copyWith({
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? postalCode,
    String? countryId,
    String? stateId,
    String? districtId,
    AddressType? type,
    bool? isPrimary,
  }) {
    return AddressDetails(
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      countryId: countryId ?? this.countryId,
      stateId: stateId ?? this.stateId,
      districtId: districtId ?? this.districtId,
      type: type ?? this.type,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'postal_code': postalCode,
      'country': countryId,
      'state': stateId,
      'district': districtId,
      'is_primary': isPrimary,
      'type': type.name, // send this to identify address purpose
    };
  }

  factory AddressDetails.fromJson(Map<String, dynamic> json) {
    return AddressDetails(
      addressLine1: json['address_line1'],
      addressLine2: json['address_line2'],
      city: json['city'],
      postalCode: json['postal_code'],
      countryId: json['country'],
      stateId: json['state'],
      districtId: json['district'],
      type: AddressType.values.firstWhere(
        (e) => e.name == (json['type'] ?? 'communication'),
      ),
      isPrimary: json['is_primary'] ?? false,
    );
  }
}

/// Supported address types to avoid confusion:
enum AddressType {
  communication, // Primary
  apta, // Same or new
  permanent, // Same or new
}
