import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
  Future<Map<String, dynamic>> initiatePayment({required int userId}) async {
    try {
      final response = await _api.initiatePayment(userId: userId);

      return response;
    } on DioException catch (e) {
      throw _mapDioExceptionToPaymentError(e);
    } catch (_) {
      throw RegistrationError.paymentFailed("Unable to initiate payment");
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
  Future<bool> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    try {
      debugPrint("reached imple");
      final body = {
        "razorpay_order_id": orderId,
        "razorpay_payment_id": paymentId,
        "razorpay_signature": signature,
      };

      final response = await _api.verifyPayment(data: body);

      // ignore: avoid_print
      debugPrint(" The Response Is $response");
      // ignore: avoid_print
      print(" HIIIII");

      return response["message"] == "Membership payment verified successfully";
    } on DioException catch (e) {
      throw _mapDioExceptionToPaymentError(e);
    } catch (_) {
      throw RegistrationError.paymentFailed("Payment verification failed");
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
  Future<Map<String, dynamic>> submitAddress(Map<String, dynamic> data) async {
    try {
      // Submit to API
      return await _api.submitAddress(data: data);
    } on DioException catch (e) {
      throw _mapDioExceptionToSubmissionError(e);
    } catch (e) {
      throw RegistrationError.serverError();
    }
  }

  @override
  Future<Map<String, dynamic>> submitDocument({
    required File documentFile,
    required int application, // <-- CHANGE TYPE HERE
    required String documentType,
  }) async {
    try {
      // Submit to API
      return await _api.uploadApplicationDocument(
        application: application,
        documentFile: documentFile,
        documentType: documentType,
      );
    } on DioException catch (e) {
      throw _mapDioExceptionToSubmissionError(e);
    } catch (e) {
      throw RegistrationError.serverError();
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
      final data = e.response?.data;

      // Handle Map response
      if (data is Map<String, dynamic>) {
        // Check for 'detail' field (common in DRF)
        if (data['detail'] != null) {
          final detail = data['detail'];
          if (detail is String) {
            return RegistrationError(
              type: RegistrationErrorType.serverValidation,
              message: detail,
              canRetry: false,
            );
          }
        }

        // Check for 'code' field
        if (data['code'] == 'DUPLICATE_EMAIL') {
          return RegistrationError.duplicateEmail(
            data['message'] as String? ?? 'Email already registered',
          );
        }
        if (data['code'] == 'DUPLICATE_PHONE') {
          return RegistrationError.duplicatePhone(
            data['message'] as String? ?? 'Phone already registered',
          );
        }

        // Check for 'non_field_errors' (common in DRF)
        if (data['non_field_errors'] != null) {
          final errors = data['non_field_errors'];
          if (errors is List && errors.isNotEmpty) {
            return RegistrationError(
              type: RegistrationErrorType.serverValidation,
              message: errors.first.toString(),
              canRetry: false,
            );
          }
        }

        // Check for field-specific errors (e.g., {"email": ["This email already exists"]})
        final fieldErrors = <String, String>{};
        final errorMessages = <String>[];

        data.forEach((key, value) {
          if (key == 'code' || key == 'message') return;

          if (value is List && value.isNotEmpty) {
            final errorMsg = value.first.toString();
            fieldErrors[key] = errorMsg;

            // Check for duplicate indicators in the error message
            final lowerError = errorMsg.toLowerCase();
            if (key == 'email' && (lowerError.contains('exist') || lowerError.contains('already') || lowerError.contains('duplicate'))) {
              errorMessages.add('Email already registered');
            } else if (key == 'phone' && (lowerError.contains('exist') || lowerError.contains('already') || lowerError.contains('duplicate'))) {
              errorMessages.add('Phone number already registered');
            } else {
              // Format field name for display
              final fieldName = key.replaceAll('_', ' ').split(' ').map((word) =>
                word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
              ).join(' ');
              errorMessages.add('$fieldName: $errorMsg');
            }
          } else if (value is String) {
            fieldErrors[key] = value;
            final fieldName = key.replaceAll('_', ' ').split(' ').map((word) =>
              word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
            ).join(' ');
            errorMessages.add('$fieldName: $value');
          }
        });

        if (errorMessages.isNotEmpty) {
          return RegistrationError(
            type: RegistrationErrorType.serverValidation,
            message: errorMessages.join('\n'),
            fieldErrors: fieldErrors.isNotEmpty ? fieldErrors : null,
            canRetry: false,
          );
        }
      }

      // Handle string response
      if (data is String && data.isNotEmpty) {
        return RegistrationError(
          type: RegistrationErrorType.serverValidation,
          message: data,
          canRetry: false,
        );
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
