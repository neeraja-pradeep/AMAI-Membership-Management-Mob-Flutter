/// Address details entity for Step 3
///
/// Contains practitioner's address information
class AddressDetails {
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String pincode;
  final String country;

  const AddressDetails({
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
  });

  /// Get full address as single string
  String get fullAddress {
    final parts = [
      addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2!,
      city,
      state,
      pincode,
      country,
    ];
    return parts.join(', ');
  }

  /// Check if all required fields are filled
  bool get isComplete {
    return addressLine1.isNotEmpty &&
        city.isNotEmpty &&
        state.isNotEmpty &&
        pincode.isNotEmpty &&
        country.isNotEmpty;
  }

  AddressDetails copyWith({
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? pincode,
    String? country,
  }) {
    return AddressDetails(
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      country: country ?? this.country,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressDetails &&
          runtimeType == other.runtimeType &&
          addressLine1 == other.addressLine1 &&
          addressLine2 == other.addressLine2 &&
          city == other.city &&
          state == other.state &&
          pincode == other.pincode &&
          country == other.country;

  @override
  int get hashCode =>
      addressLine1.hashCode ^
      (addressLine2?.hashCode ?? 0) ^
      city.hashCode ^
      state.hashCode ^
      pincode.hashCode ^
      country.hashCode;

  @override
  String toString() {
    return 'AddressDetails(city: $city, state: $state, pincode: $pincode)';
  }
}
