import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/core/network/api_client.dart';
import 'package:myapp/core/network/endpoints.dart';
import 'package:myapp/features/home/application/providers/home_providers.dart';
import 'package:myapp/features/profile/application/states/profile_state.dart';
import 'package:myapp/features/profile/domain/repositories/profile_repository.dart';
import 'package:myapp/features/profile/infrastructure/data_sources/remote/profile_api.dart';
import 'package:myapp/features/profile/infrastructure/repositories/profile_repository_impl.dart';

// ============== Data Source Providers ==============

/// Provider for Profile API
final profileApiProvider = Provider<ProfileApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileApiImpl(apiClient: apiClient);
});

// ============== Repository Providers ==============

/// Provider for Profile Repository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final profileApi = ref.watch(profileApiProvider);
  final homeApi = ref.watch(homeApiProvider);
  final connectivity = ref.watch(connectivityProvider);

  return ProfileRepositoryImpl(
    profileApi: profileApi,
    homeApi: homeApi,
    connectivity: connectivity,
  );
});

// ============== State Providers ==============

/// Provider for Profile State
final profileStateProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref);
});

/// Notifier for managing profile state
class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier(this._ref) : super(const ProfileState.initial());

  final Ref _ref;

  /// Initialize by fetching fresh data from API
  Future<void> initialize() async {
    state = const ProfileState.loading();

    final repository = _ref.read(profileRepositoryProvider);
    final userId = _ref.read(userIdProvider);

    final result = await repository.getProfileData(userId: userId);

    result.fold(
      (failure) {
        state = ProfileState.error(failure: failure);
      },
      (profileData) {
        state = ProfileState.loaded(data: profileData);
      },
    );
  }

  /// Refresh profile data
  Future<void> refresh() async {
    final previousData = state.currentData;
    state = ProfileState.loading(previousData: previousData);

    final repository = _ref.read(profileRepositoryProvider);
    final userId = _ref.read(userIdProvider);

    final result = await repository.getProfileData(userId: userId);

    result.fold(
      (failure) {
        state = ProfileState.error(
          failure: failure,
          cachedData: previousData,
        );
      },
      (profileData) {
        state = ProfileState.loaded(data: profileData);
      },
    );
  }

  /// Clear state
  void clear() {
    state = const ProfileState.initial();
  }
}

// ============== Profile Picture Upload ==============

/// Parameters for profile picture upload
class ProfilePictureUploadParams {
  const ProfilePictureUploadParams({
    required this.userId,
    required this.imagePath,
  });

  final int userId;
  final String imagePath;
}

/// Provider for uploading profile picture
final profilePictureUploadProvider = FutureProvider.autoDispose
    .family<Either<Failure, bool>, ProfilePictureUploadParams>(
  (ref, params) async {
    final apiClient = ref.watch(apiClientProvider);

    try {
      final formData = FormData.fromMap({
        'profile_picture_file': await MultipartFile.fromFile(
          params.imagePath,
          filename: params.imagePath.split('/').last,
        ),
      });

      final response = await apiClient.patch<Map<String, dynamic>>(
        Endpoints.userProfile(params.userId),
        data: formData,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.isSuccess) {
        return const Right(true);
      } else {
        return const Left(
          ServerFailure(message: 'Failed to upload profile picture'),
        );
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  },
);
