import 'dart:io';
import 'package:dio/dio.dart';
import '../../domain/entities/registration/practitioner_registration.dart';
import '../../domain/entities/registration/document_upload.dart';
import '../../domain/entities/registration/registration_error.dart';
import '../../domain/repositories/registration_repository.dart';
import '../data_sources/remote/registration_api.dart';
import '../utils/file_security_validator.dart';

/// Registration repository implementation
///
/// Handles all registration operations with comprehensive error mapping
class RegistrationRepositoryImpl implements RegistrationRepository {
  final RegistrationApi _api;

  // Backend is now ready - using real API
  static const bool _useMockMode = false;

  const RegistrationRepositoryImpl({required RegistrationApi api}) : _api = api;

  @override
  Future<List<MedicalCouncil>> fetchCouncils() async {
    try {
      return await _api.fetchCouncils();
    } on DioException catch (e) {
      throw _mapDioExceptionToDropdownError(e, 'Medical Councils');
    } catch (e) {
      throw RegistrationError.dropdownNetwork('Medical Councils');
    }
  }

  @override
  Future<List<Specialization>> fetchSpecializations() async {
    try {
      return await _api.fetchSpecializations();
    } on DioException catch (e) {
      throw _mapDioExceptionToDropdownError(e, 'Specializations');
    } catch (e) {
      throw RegistrationError.dropdownNetwork('Specializations');
    }
  }

  @override
  Future<List<Country>> fetchCountries() async {
    try {
      return await _api.fetchCountries();
    } on DioException catch (e) {
      throw _mapDioExceptionToDropdownError(e, 'Countries');
    } catch (e) {
      throw RegistrationError.dropdownNetwork('Countries');
    }
  }

  @override
  Future<List<State>> fetchStates({required String countryId}) async {
    try {
      return await _api.fetchStates(countryId: countryId);
    } on DioException catch (e) {
      throw _mapDioExceptionToDropdownError(e, 'States');
    } catch (e) {
      throw RegistrationError.dropdownNetwork('States');
    }
  }

  @override
  Future<List<District>> fetchDistricts({required String stateId}) async {
    try {
      return await _api.fetchDistricts(stateId: stateId);
    } on DioException catch (e) {
      throw _mapDioExceptionToDropdownError(e, 'Districts');
    } catch (e) {
      throw RegistrationError.dropdownNetwork('Districts');
    }
  }

  @override
  Future<String> uploadDocument({
    required File file,
    required DocumentType type,
    required void Function(double progress) onProgress,
  }) async {
    // 1. Validate file security
    final validationResult = await FileSecurityValidator.validateFile(file);
    if (!validationResult.isValid) {
      throw RegistrationError(
        type: RegistrationErrorType.invalidFileType,
        message: validationResult.error ?? 'Invalid file',
        code: 'INVALID_FILE',
        canRetry: false,
      );
    }

    // 2. Validate file size (5MB limit)
    final sizeError = await FileSecurityValidator.validateFileSize(
      file,
      maxSizeMB: 5,
    );
    if (sizeError != null) {
      throw RegistrationError.fileTooLarge(5);
    }

    // 3. Upload file
    try {
      return await _api.uploadDocument(
        file: file,
        type: type,
        onProgress: onProgress,
      );
    } on DioException catch (e) {
      throw _mapDioExceptionToUploadError(e);
    } catch (e) {
      throw RegistrationError.uploadFailure();
    }
  }

  @override
  Future<String> submitRegistration({
    required PractitionerRegistration registration,
  }) async {
    try {
      // Convert registration to JSON
      final registrationData = _convertRegistrationToJson(registration);

      // Submit to API
      return await _api.submitRegistration(registrationData: registrationData);
    } on DioException catch (e) {
      throw _mapDioExceptionToSubmissionError(e);
    } catch (e) {
      throw RegistrationError.serverError();
    }
  }

  @override
  Future<bool> validateSession() async {
    // MOCK MODE: Always return true for development
    if (_useMockMode) {
      return true;
    }

    try {
      return await _api.validateSession();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> checkDuplicateEmail({required String email}) async {
    // MOCK MODE: Always return false (no duplicates) for development
    if (_useMockMode) {
      return false;
    }

    try {
      return await _api.checkDuplicateEmail(email: email);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw RegistrationError.networkTimeout();
      }
      throw RegistrationError.serverError();
    } catch (e) {
      throw RegistrationError.serverError();
    }
  }

  @override
  Future<bool> checkDuplicatePhone({required String phone}) async {
    // MOCK MODE: Always return false (no duplicates) for development
    if (_useMockMode) {
      return false;
    }

    try {
      return await _api.checkDuplicatePhone(phone: phone);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw RegistrationError.networkTimeout();
      }
      throw RegistrationError.serverError();
    } catch (e) {
      throw RegistrationError.serverError();
    }
  }

  @override
  Future<Map<String, dynamic>> submitMembershipRegistration(
    Map<String, dynamic> membershipData,
  ) async {
    // MOCK MODE: For development without backend
    if (_useMockMode) {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Return mock response with application ID
      return {
        'id': 'APP_${DateTime.now().millisecondsSinceEpoch}',
        'status': 'success',
        'message': 'Registration submitted successfully',
      };
    }

    try {
      // Submit to API
      return await _api.submitMembershipRegistration(data: membershipData);
    } on DioException catch (e) {
      throw _mapDioExceptionToSubmissionError(e);
    } catch (e) {
      throw RegistrationError.serverError();
    }
  }

  @override
  Future<PaymentDetails> verifyPayment({required String sessionId}) async {
    try {
      final response = await _api.verifyPayment(sessionId: sessionId);

      return PaymentDetails(
        sessionId: sessionId,
        amount: (response['amount'] as num).toDouble(),
        currency: response['currency'] as String,
        status: PaymentStatus.values.firstWhere(
          (s) => s.name == response['status'],
          orElse: () => PaymentStatus.pending,
        ),
        transactionId: response['transaction_id'] as String?,
        paymentMethod: response['payment_method'] as String?,
        completedAt: response['completed_at'] != null
            ? DateTime.parse(response['completed_at'] as String)
            : null,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw RegistrationError.paymentFailed('Payment session not found');
      }
      throw _mapDioExceptionToPaymentError(e);
    } catch (e) {
      throw RegistrationError.paymentFailed('Unable to verify payment');
    }
  }

  // ==================== Error Mapping ====================

  /// Map DioException to dropdown error
  RegistrationError _mapDioExceptionToDropdownError(
    DioException e,
    String dropdownName,
  ) {
    // Network timeout
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return RegistrationError.networkTimeout();
    }

    // 404 Not Found
    if (e.response?.statusCode == 404) {
      return RegistrationError.dropdownNotFound(dropdownName);
    }

    // 401 Unauthorized
    if (e.response?.statusCode == 401) {
      return RegistrationError.sessionExpired();
    }

    // Default to network failure
    return RegistrationError.dropdownNetwork(dropdownName);
  }

  /// Map DioException to upload error
  RegistrationError _mapDioExceptionToUploadError(DioException e) {
    // Network timeout
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return RegistrationError.networkTimeout();
    }

    // 401 Unauthorized
    if (e.response?.statusCode == 401) {
      return RegistrationError.sessionExpired();
    }

    // 413 Payload Too Large
    if (e.response?.statusCode == 413) {
      return RegistrationError.fileTooLarge(5);
    }

    // 415 Unsupported Media Type
    if (e.response?.statusCode == 415) {
      return RegistrationError.invalidFileType(['PDF', 'JPG', 'PNG']);
    }

    // Default to upload failure
    return RegistrationError.uploadFailure();
  }

  /// Map DioException to submission error
  RegistrationError _mapDioExceptionToSubmissionError(DioException e) {
    // Network timeout
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return RegistrationError.networkTimeout();
    }

    // 401 Unauthorized
    if (e.response?.statusCode == 401) {
      return RegistrationError.sessionExpired();
    }

    // 400 Bad Request (validation errors)
    if (e.response?.statusCode == 400) {
      final data = e.response?.data as Map<String, dynamic>?;

      // Check for duplicate email
      if (data?['code'] == 'DUPLICATE_EMAIL') {
        return RegistrationError.duplicateEmail(
          data?['message'] as String? ?? 'Email already registered',
        );
      }

      // Check for duplicate phone
      if (data?['code'] == 'DUPLICATE_PHONE') {
        return RegistrationError.duplicatePhone(
          data?['message'] as String? ?? 'Phone already registered',
        );
      }

      // Field validation errors
      if (data?['errors'] != null) {
        final fieldErrors = <String, String>{};
        final errors = data!['errors'] as Map<String, dynamic>;

        errors.forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            fieldErrors[key] = value.first as String;
          } else if (value is String) {
            fieldErrors[key] = value;
          }
        });

        return RegistrationError.validation(fieldErrors);
      }
    }

    // 500 Server Error
    if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
      return RegistrationError.serverError();
    }

    // Default to server error
    return RegistrationError.serverError();
  }

  /// Map DioException to payment error
  RegistrationError _mapDioExceptionToPaymentError(DioException e) {
    // Network timeout
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return RegistrationError.networkTimeout();
    }

    // 401 Unauthorized
    if (e.response?.statusCode == 401) {
      return RegistrationError.sessionExpired();
    }

    // Default to payment failed
    return RegistrationError.paymentFailed('Payment verification failed');
  }

  // ==================== Data Conversion ====================

  /// Convert PractitionerRegistration to JSON for API submission
  Map<String, dynamic> _convertRegistrationToJson(
    PractitionerRegistration registration,
  ) {
    return {
      'registration_id': registration.registrationId,
      'personal_details': registration.personalDetails != null
          ? {
              'first_name': registration.personalDetails!.firstName,
              'last_name': registration.personalDetails!.lastName,
              'email': registration.personalDetails!.email,
              'password': registration.personalDetails!.password,
              'phone': registration.personalDetails!.phone,
              'wa_phone': registration.personalDetails!.waPhone,
              'date_of_birth': registration.personalDetails!.dateOfBirth
                  .toIso8601String(),
              'gender': registration.personalDetails!.gender,
              'blood_group': registration.personalDetails!.bloodGroup,
              'membership_type': registration.personalDetails!.membershipType,
              'profile_image_path':
                  registration.personalDetails!.profileImagePath,
            }
          : null,
      'professional_details': registration.professionalDetails != null
          ? {
              'medical_council_state':
                  registration.professionalDetails!.medicalCouncilState,
              'medical_council_no':
                  registration.professionalDetails!.medicalCouncilNo,
              'central_council_no':
                  registration.professionalDetails!.centralCouncilNo,
              'ug_college': registration.professionalDetails!.ugCollege,

              'professional_details1':
                  registration.professionalDetails!.professionalDetails1,
              'professional_details2':
                  registration.professionalDetails!.professionalDetails2,
            }
          : null,
      'address_details': registration.addressDetails != null
          ? {
              'address_line1': registration.addressDetails!.addressLine1,
              'address_line2': registration.addressDetails!.addressLine2,
              'country': registration.addressDetails!.countryId,
              'state': registration.addressDetails!.stateId,
              'district': registration.addressDetails!.districtId,
              'city': registration.addressDetails!.city,
              'postal_code': registration.addressDetails!.postalCode,
              'is_primary': registration.addressDetails!.isPrimary,
            }
          : null,
      'documents':
          registration.documentUploads?.documents
              .map(
                (doc) => {
                  'type': doc.type.name,
                  'local_file_path': doc.localFilePath,
                  'file_name': doc.fileName,
                  'file_size_bytes': doc.fileSizeBytes,
                  'uploaded_at': doc.uploadedAt.toIso8601String(),
                  'server_url': doc.serverUrl,
                },
              )
              .toList() ??
          [],
      'payment_details': registration.paymentDetails != null
          ? {
              'session_id': registration.paymentDetails!.sessionId,
              'amount': registration.paymentDetails!.amount,
              'currency': registration.paymentDetails!.currency,
              'status': registration.paymentDetails!.status.name,
              'transaction_id': registration.paymentDetails!.transactionId,
              'payment_method': registration.paymentDetails!.paymentMethod,
              'completed_at': registration.paymentDetails!.completedAt
                  ?.toIso8601String(),
            }
          : null,
    };
  }
}
