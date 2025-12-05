import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/core/network/endpoints.dart';
import 'package:myapp/features/aswas_plus/infrastructure/models/registration_response_model.dart';
import 'package:myapp/features/home/application/providers/home_providers.dart';

/// Provider for insurance registration API call
/// Takes payload and returns Either<Failure, RegistrationResponseModel>
final insuranceRegistrationProvider = FutureProvider.autoDispose
    .family<Either<Failure, RegistrationResponseModel>, Map<String, dynamic>>(
  (ref, payload) async {
    final apiClient = ref.watch(apiClientProvider);

    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        Endpoints.insuranceRegister,
        data: payload,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        final registrationResponse =
            RegistrationResponseModel.fromJson(response.data!);
        return Right(registrationResponse);
      } else {
        return const Left(
          ServerFailure(
            message: 'Registration failed. Please try again.',
          ),
        );
      }
    } catch (e) {
      return Left(
        ServerFailure(
          message: e.toString(),
        ),
      );
    }
  },
);

/// Provider for insurance payment verification API call
/// Takes payload with razorpay details and returns Either<Failure, bool>
final insuranceVerificationProvider =
    FutureProvider.autoDispose.family<Either<Failure, bool>, Map<String, dynamic>>(
  (ref, payload) async {
    final apiClient = ref.watch(apiClientProvider);

    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        Endpoints.insuranceVerify,
        data: payload,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.isSuccess) {
        return const Right(true);
      } else {
        return const Left(
          ServerFailure(
            message: 'Payment verification failed. Please try again.',
          ),
        );
      }
    } catch (e) {
      return Left(
        ServerFailure(
          message: e.toString(),
        ),
      );
    }
  },
);

/// Parameters for nominee update request
class NomineeUpdateParams {
  const NomineeUpdateParams({
    required this.nomineeId,
    required this.payload,
  });

  final int nomineeId;
  final Map<String, dynamic> payload;
}

/// Provider for insurance nominee update API call
/// Takes NomineeUpdateParams and returns Either<Failure, bool>
final nomineeUpdateProvider =
    FutureProvider.autoDispose.family<Either<Failure, bool>, NomineeUpdateParams>(
  (ref, params) async {
    final apiClient = ref.watch(apiClientProvider);

    try {
      final response = await apiClient.patch<Map<String, dynamic>>(
        Endpoints.insuranceNomineeById(params.nomineeId),
        data: params.payload,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.isSuccess) {
        return const Right(true);
      } else {
        return const Left(
          ServerFailure(
            message: 'Failed to update nominee. Please try again.',
          ),
        );
      }
    } catch (e) {
      return Left(
        ServerFailure(
          message: e.toString(),
        ),
      );
    }
  },
);
