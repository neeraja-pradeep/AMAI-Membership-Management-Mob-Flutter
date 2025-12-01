import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/endpoints.dart';
import '../../../domain/entities/registration/practitioner_registration.dart';
import '../../../domain/entities/registration/document_upload.dart';
import '../../../domain/repositories/registration_repository.dart';
import 'package:http_parser/http_parser.dart';

/// Registration API data source
///
/// Handles all HTTP requests for registration flow
/// XCSRF token automatically included by ApiClient
class RegistrationApi {
  final ApiClient _apiClient;

  const RegistrationApi({required ApiClient apiClient})
    : _apiClient = apiClient;

  /// Fetch medical councils
  Future<List<MedicalCouncil>> fetchCouncils() async {
    final response = await _apiClient.get(Endpoints.councils);

    final data = response.data as List<dynamic>;
    return data
        .map((json) => MedicalCouncil.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch specializations
  Future<List<Specialization>> fetchSpecializations() async {
    final response = await _apiClient.get(Endpoints.specializations);

    final data = response.data as List<dynamic>;
    return data
        .map((json) => Specialization.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch countries
  Future<List<Country>> fetchCountries() async {
    final response = await _apiClient.get(Endpoints.countries);

    final data = response.data as List<dynamic>;
    return data
        .map((json) => Country.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch states for country
  Future<List<State>> fetchStates({required String countryId}) async {
    final response = await _apiClient.get(
      Endpoints.states,
      queryParameters: {'country_id': countryId},
    );

    final data = response.data as List<dynamic>;
    return data
        .map((json) => State.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch districts for state
  Future<List<District>> fetchDistricts({required String stateId}) async {
    final response = await _apiClient.get(
      Endpoints.districts,
      queryParameters: {'state_id': stateId},
    );

    final data = response.data as List<dynamic>;
    return data
        .map((json) => District.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Upload document file
  ///
  /// XCSRF token automatically included in request headers by ApiClient

  /// Submit complete registration (old endpoint - kept for compatibility)
  ///
  /// XCSRF token automatically included in request headers by ApiClient
  Future<String> submitRegistration({
    required Map<String, dynamic> registrationData,
  }) async {
    final response = await _apiClient.post(
      Endpoints.registrationSubmit,
      data: registrationData,
    );

    // Return registration ID

    return response.data['registration_id'] as String;
  }

  /// Submit membership registration (Form 1)
  /// POST /api/membership/register/
  /// Returns application ID
  Future<Map<String, dynamic>> submitMembershipRegistration({
    required Map<String, dynamic> data,
  }) async {
    final response = await _apiClient.post(Endpoints.register, data: data);

    return response.data as Map<String, dynamic>;
  }

  /// Submit address (Form 2)
  /// POST /api/accounts/addresses/
  Future<Map<String, dynamic>> submitAddress({
    required Map<String, dynamic> data,
  }) async {
    final response = await _apiClient.post(Endpoints.addresses, data: data);

    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> uploadApplicationDocument({
    required File documentFile,
    required int application,
    required String documentType,
  }) async {
    final ext = documentFile.path.split('.').last.toLowerCase();

    // ignore: avoid_print
    print("======== 📂 DOCUMENT UPLOAD INVOKED ========");
    // ignore: avoid_print
    print("Application ID: $application");
    // ignore: avoid_print
    print("Detected Extension: .$ext");
    // ignore: avoid_print
    print("Sending document_type: $documentType");

    final mimeType = switch (ext) {
      'png' => 'image/png',
      'pdf' => 'application/pdf',
      'jpg' || 'jpeg' => 'image/jpeg',
      _ => 'application/octet-stream',
    };

    // ignore: avoid_print
    print("MIME Type: $mimeType");

    final formData = FormData.fromMap({
      'application': application,
      'document_type': documentType,
      'document_file': await MultipartFile.fromFile(
        documentFile.path,
        filename: documentFile.path.split('/').last,
        contentType: MediaType.parse(mimeType),
      ),
    });

    // ignore: avoid_print
    print("🚀 Uploading...");

    final response = await _apiClient.post(
      Endpoints.applicationDocuments,
      data: formData,
    );

    // ignore: avoid_print
    print("📥 Response: ${response.data}");

    return response.data as Map<String, dynamic>;
  }

  /// Validate current session
  Future<bool> validateSession() async {
    try {
      await _apiClient.get(Endpoints.sessionValidate);
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return false;
      }
      rethrow;
    }
  }

  /// Check duplicate email
  Future<bool> checkDuplicateEmail({required String email}) async {
    final response = await _apiClient.get(
      Endpoints.registrationCheckDuplicate,
      queryParameters: {'email': email},
    );

    return response.data['exists'] as bool? ?? false;
  }

  /// Check duplicate phone
  Future<bool> checkDuplicatePhone({required String phone}) async {
    final response = await _apiClient.get(
      Endpoints.registrationCheckDuplicate,
      queryParameters: {'phone': phone},
    );

    return response.data['exists'] as bool? ?? false;
  }

  /// Verify payment status
  Future<Map<String, dynamic>> verifyPayment({
    required String sessionId,
  }) async {
    final response = await _apiClient.post(
      Endpoints.registrationVerifyPayment,
      data: {'session_id': sessionId},
    );

    return response.data as Map<String, dynamic>;
  }
}
