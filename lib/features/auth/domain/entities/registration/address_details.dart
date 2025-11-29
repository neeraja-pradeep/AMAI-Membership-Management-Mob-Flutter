/// Address details entity for Step 3
///
/// Contains user's address information
///
/// API Endpoint: POST https://amai.nexogms.com/api/accounts/addresses/
///
/// Required fields:
/// - address_line1 (House No. / Building Name)
/// - address_line2 (Street / Locality / Area)
/// - city (Post Office)
/// - postal_code (Post Code)
/// - country (Country ID)
/// - state (State ID)
/// - district (District ID)
/// - is_primary (Boolean - default true)
///
/// REQUIREMENT: Dependent dropdowns - validate parent selection first
/// - Country → State → District hierarchy
/// - State selection requires valid countryId
/// - District selection requires valid stateId
class AddressDetails {
  final String addressLine1; // House No. / Building Name
  final String addressLine2; // Street / Locality / Area
  final String city; // Post Office
  final String postalCode; // Post Code (renamed from pincode)
  final String countryId; // Country ID
  final String stateId; // State ID (depends on countryId)
  final String districtId; // District ID (depends on stateId)
  final bool isPrimary; // Is primary address

  const AddressDetails({
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.postalCode,
    required this.countryId,
    required this.stateId,
    required this.districtId,
    this.isPrimary = true, // Default to primary address
  });

  /// Get full address as single string
  String get fullAddress {
    final parts = [
      addressLine1,
      addressLine2,
      city,
      districtId, // District name will be displayed in UI
      stateId, // State name will be displayed in UI
      postalCode,
      countryId, // Country name will be displayed in UI
    ];
    return parts.where((p) => p.isNotEmpty).join(', ');
  }

  /// Check if all required fields are filled
  ///
  /// REQUIREMENT: Dependent dropdowns validated in order
  /// - Country must be selected first
  /// - State requires country
  /// - District requires state
  bool get isComplete {
    return addressLine1.isNotEmpty &&
        addressLine2.isNotEmpty &&
        countryId.isNotEmpty && // Parent selection
        stateId.isNotEmpty && // Depends on countryId
        districtId.isNotEmpty && // Depends on stateId
        city.isNotEmpty &&
        postalCode.isNotEmpty;
  }

  /// Validate dependent dropdown hierarchy
  ///
  /// REQUIREMENT: Always validate parent selection first
  bool validateDependentDropdowns() {
    // Country must be selected (no parent)
    if (countryId.isEmpty) return false;

    // State requires country to be selected
    if (stateId.isNotEmpty && countryId.isEmpty) return false;

    // District requires state to be selected
    if (districtId.isNotEmpty && stateId.isEmpty) return false;

    return true;
  }

  AddressDetails copyWith({
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? postalCode,
    String? countryId,
    String? stateId,
    String? districtId,
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
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  /// Convert to JSON for API
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
    };
  }

  /// Create from JSON
  factory AddressDetails.fromJson(Map<String, dynamic> json) {
    return AddressDetails(
      addressLine1: json['address_line1'] as String,
      addressLine2: json['address_line2'] as String,
      city: json['city'] as String,
      postalCode: json['postal_code'] as String,
      countryId: json['country'] as String,
      stateId: json['state'] as String,
      districtId: json['district'] as String,
      isPrimary: json['is_primary'] as bool? ?? true,
    );
  }

  /// Clear dependent dropdowns when parent changes
  ///
  /// REQUIREMENT: When parent dropdown changes, clear children
  /// - Country changes → clear state + district
  /// - State changes → clear district
  AddressDetails clearDependentDropdowns(String changedField) {
    switch (changedField) {
      case 'country':
        // Country changed - clear state and district
        return copyWith(
          stateId: '',
          districtId: '',
        );

      case 'state':
        // State changed - clear district
        return copyWith(
          districtId: '',
        );

      default:
        return this;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressDetails &&
          runtimeType == other.runtimeType &&
          addressLine1 == other.addressLine1 &&
          addressLine2 == other.addressLine2 &&
          city == other.city &&
          postalCode == other.postalCode &&
          countryId == other.countryId &&
          stateId == other.stateId &&
          districtId == other.districtId &&
          isPrimary == other.isPrimary;

  @override
  int get hashCode =>
      addressLine1.hashCode ^
      addressLine2.hashCode ^
      city.hashCode ^
      postalCode.hashCode ^
      countryId.hashCode ^
      stateId.hashCode ^
      districtId.hashCode ^
      isPrimary.hashCode;

  @override
  String toString() {
    return 'AddressDetails(city: $city, country: $countryId, state: $stateId, district: $districtId, postalCode: $postalCode, isPrimary: $isPrimary)';
  }
}
