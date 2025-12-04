import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/core/network/endpoints.dart';
import 'package:myapp/features/home/application/providers/home_providers.dart';

/// Provider for insurance registration API call
/// Takes payload and returns Either<Failure, bool>
final insuranceRegistrationProvider =
    FutureProvider.autoDispose.family<Either<Failure, bool>, Map<String, dynamic>>(
  (ref, payload) async {
    final apiClient = ref.watch(apiClientProvider);

    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        Endpoints.insuranceRegister,
        data: payload,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.isSuccess) {
        return const Right(true);
      } else {
        return Left(
          ServerFailure(
            message: response.errorMessage ?? 'Registration failed. Please try again.',
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
