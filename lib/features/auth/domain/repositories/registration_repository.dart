import 'dart:io';
import '../entities/registration/practitioner_registration.dart';
import '../entities/registration/document_upload.dart';
import '../entities/registration/registration_error.dart';

/// Registration repository interface
///
/// Defines all operations needed for practitioner registration flow
abstract class RegistrationRepository {
  /// Fetch list of medical councils
  ///
  /// Returns list of councils or throws [RegistrationError]
  Future<List<MedicalCouncil>> fetchCouncils();

  /// Fetch list of specializations
  ///
  /// Returns list of specializations or throws [RegistrationError]
  Future<List<Specialization>> fetchSpecializations();

  /// Fetch list of countries
  ///
  /// Returns list of countries or throws [RegistrationError]
  Future<List<Country>> fetchCountries();

  /// Fetch states for a specific country
  ///
  /// Returns list of states or throws [RegistrationError]
  Future<List<State>> fetchStates({required String countryId});

  /// Fetch districts for a specific state
  ///
  /// Returns list of districts or throws [RegistrationError]
  Future<List<District>> fetchDistricts({required String stateId});

  /// Upload document file
  ///
  /// Returns document URL on success or throws [RegistrationError]
  /// Handles multipart upload with progress tracking

  /// Submit complete registration
  ///
  /// Returns registration ID on success or throws [RegistrationError]
  /// Validates session before submission
  Future<String> submitRegistration({
    required PractitionerRegistration registration,
  });

  Future<Map<String, dynamic>> submitDocument({
    required File documentFile,
    required int application,
    required String documentType,
  });

  /// Validate current session
  ///
  /// Returns true if session is valid, false otherwise
  /// Used before critical operations (document upload, final submission)
  Future<bool> validateSession();

  Future<Map<String, dynamic>> submitAddress(Map<String, dynamic> data);

  /// Check if email is already registered
  ///
  /// Returns true if duplicate found, false otherwise
  /// Throws [RegistrationError] on network failure
  Future<bool> checkDuplicateEmail({required String email});

  /// Check if phone is already registered
  ///
  /// Returns true if duplicate found, false otherwise
  /// Throws [RegistrationError] on network failure
  Future<bool> checkDuplicatePhone({required String phone});

  /// Submit membership registration (NEW: Step 1)
  ///
  /// POST /api/membership/register/
  /// Submits combined Personal + Professional data
  /// Returns backend response with application ID
  /// Throws [RegistrationError] on failure
  Future<Map<String, dynamic>> submitMembershipRegistration(
    Map<String, dynamic> membershipData,
  );

  /// Verify payment status
  ///
  /// Returns payment details or throws [RegistrationError]
  /// Used after payment gateway redirect
  Future<PaymentDetails> verifyPayment({required String sessionId});
}

/// Medical council entity for dropdown
class MedicalCouncil {
  final String id;
  final String name;
  final String countryCode;

  const MedicalCouncil({
    required this.id,
    required this.name,
    required this.countryCode,
  });

  factory MedicalCouncil.fromJson(Map<String, dynamic> json) {
    return MedicalCouncil(
      id: json['id'] as String,
      name: json['name'] as String,
      countryCode: json['country_code'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'country_code': countryCode};
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalCouncil &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Specialization entity for dropdown
class Specialization {
  final String id;
  final String name;
  final String category; // e.g., 'Medical', 'Surgical', 'Diagnostic'

  const Specialization({
    required this.id,
    required this.name,
    required this.category,
  });

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'category': category};
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Specialization &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Country entity for dropdown
class Country {
  final String id;
  final String name;
  final String code; // ISO 3166-1 alpha-2 code

  const Country({required this.id, required this.name, required this.code});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'code': code};
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Country && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// State/Province entity for dropdown
class State {
  final String id;
  final String name;
  final String countryId;

  const State({required this.id, required this.name, required this.countryId});

  factory State.fromJson(Map<String, dynamic> json) {
    return State(
      id: json['id'] as String,
      name: json['name'] as String,
      countryId: json['country_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'country_id': countryId};
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is State && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// District entity for dropdown
class District {
  final String id;
  final String name;
  final String stateId;

  const District({required this.id, required this.name, required this.stateId});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'] as String,
      name: json['name'] as String,
      stateId: json['state_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'state_id': stateId};
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is District && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
