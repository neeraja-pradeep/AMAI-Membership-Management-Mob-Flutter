import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/endpoints.dart';
import '../../../domain/entities/registration/practitioner_registration.dart';
import '../../../domain/entities/registration/document_upload.dart';
import '../../../domain/repositories/registration_repository.dart';

/// Registration API data source
///
/// Handles all HTTP requests for registration flow
/// XCSRF token automatically included by ApiClient
class RegistrationApi {
  final ApiClient _apiClient;

  const RegistrationApi({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Fetch medical councils
  Future<List<MedicalCouncil>> fetchCouncils() async {
    final response = await _apiClient.get(Endpoints.councils);

    final data = response.data as List<dynamic>;
    return data.map((json) => MedicalCouncil.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Fetch specializations
  Future<List<Specialization>> fetchSpecializations() async {
    final response = await _apiClient.get(Endpoints.specializations);

    final data = response.data as List<dynamic>;
    return data.map((json) => Specialization.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Fetch countries
  Future<List<Country>> fetchCountries() async {
    final response = await _apiClient.get(Endpoints.countries);

    final data = response.data as List<dynamic>;
    return data.map((json) => Country.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Fetch states for country
  Future<List<State>> fetchStates({required String countryId}) async {
    final response = await _apiClient.get(
      Endpoints.states,
      queryParameters: {'country_id': countryId},
    );

    final data = response.data as List<dynamic>;
    return data.map((json) => State.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Fetch districts for state
  Future<List<District>> fetchDistricts({required String stateId}) async {
    final response = await _apiClient.get(
      Endpoints.districts,
      queryParameters: {'state_id': stateId},
    );

    final data = response.data as List<dynamic>;
    return data.map((json) => District.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Upload document file
  ///
  /// XCSRF token automatically included in request headers by ApiClient
  Future<String> uploadDocument({
    required File file,
    required DocumentType type,
    required void Function(double progress) onProgress,
  }) async {
    // Create multipart form data
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
      'type': type.name,
    });

    // Upload with progress tracking
    final response = await _apiClient.post(
      Endpoints.registrationUpload,
      data: formData,
      onSendProgress: (sent, total) {
        final progress = sent / total;
        onProgress(progress);
      },
    );

    // Return document URL
    return response.data['url'] as String;
  }

  /// Submit complete registration
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
  Future<Map<String, dynamic>> verifyPayment({required String sessionId}) async {
    final response = await _apiClient.post(
      Endpoints.registrationVerifyPayment,
      data: {'session_id': sessionId},
    );

    return response.data as Map<String, dynamic>;
  }
}
