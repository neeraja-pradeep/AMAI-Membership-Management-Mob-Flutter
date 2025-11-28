/// Address details entity for Step 3
///
/// Contains practitioner's address information
///
/// REQUIREMENT: Dependent dropdowns - validate parent selection first
/// - Country → State → District hierarchy
/// - State selection requires valid countryId
/// - District selection requires valid stateId
class AddressDetails {
  final String addressLine1;
  final String? addressLine2;
  final String countryId; // Selected country ID (for dependent dropdown validation)
  final String stateId; // Selected state ID (depends on countryId)
  final String districtId; // Selected district ID (depends on stateId)
  final String city;
  final String pincode;

  const AddressDetails({
    required this.addressLine1,
    this.addressLine2,
    required this.countryId,
    required this.stateId,
    required this.districtId,
    required this.city,
    required this.pincode,
  });

  /// Get full address as single string
  String get fullAddress {
    final parts = [
      addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2!,
      city,
      districtId, // District name will be displayed in UI
      stateId, // State name will be displayed in UI
      pincode,
      countryId, // Country name will be displayed in UI
    ];
    return parts.join(', ');
  }

  /// Check if all required fields are filled
  ///
  /// REQUIREMENT: Dependent dropdowns validated in order
  /// - Country must be selected first
  /// - State requires country
  /// - District requires state
  bool get isComplete {
    return addressLine1.isNotEmpty &&
        countryId.isNotEmpty && // Parent selection
        stateId.isNotEmpty && // Depends on countryId
        districtId.isNotEmpty && // Depends on stateId
        city.isNotEmpty &&
        pincode.isNotEmpty;
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
    String? countryId,
    String? stateId,
    String? districtId,
    String? city,
    String? pincode,
  }) {
    return AddressDetails(
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      countryId: countryId ?? this.countryId,
      stateId: stateId ?? this.stateId,
      districtId: districtId ?? this.districtId,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
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
          countryId == other.countryId &&
          stateId == other.stateId &&
          districtId == other.districtId &&
          city == other.city &&
          pincode == other.pincode;

  @override
  int get hashCode =>
      addressLine1.hashCode ^
      (addressLine2?.hashCode ?? 0) ^
      countryId.hashCode ^
      stateId.hashCode ^
      districtId.hashCode ^
      city.hashCode ^
      pincode.hashCode;

  @override
  String toString() {
    return 'AddressDetails(city: $city, country: $countryId, state: $stateId, district: $districtId, pincode: $pincode)';
  }
}
