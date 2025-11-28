import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client_provider.dart';
import '../data_sources/local/registration_local_ds.dart';
import '../data_sources/remote/registration_api.dart';
import 'registration_repository_impl.dart';

/// Registration API provider
final registrationApiProvider = Provider<RegistrationApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RegistrationApi(apiClient: apiClient);
});

/// Registration local data source provider
final registrationLocalDsProvider = Provider<RegistrationLocalDs>((ref) {
  return RegistrationLocalDs();
});

/// Registration repository provider (singleton)
///
/// Usage:
/// ```dart
/// final registrationRepository = ref.watch(registrationRepositoryProvider);
/// ```
final registrationRepositoryProvider =
    Provider<RegistrationRepositoryImpl>((ref) {
  final registrationApi = ref.watch(registrationApiProvider);

  return RegistrationRepositoryImpl(api: registrationApi);
});
