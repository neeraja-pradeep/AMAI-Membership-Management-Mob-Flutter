import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/features/profile/domain/entities/membership_type.dart';
import 'package:myapp/features/profile/domain/entities/profile_data.dart';
import 'package:myapp/features/profile/domain/entities/user_profile.dart';

part 'profile_state.freezed.dart';

/// State for Profile feature
@freezed
class ProfileState with _$ProfileState {
  /// Initial state before any data is loaded
  const factory ProfileState.initial() = _Initial;

  /// Loading state while fetching data
  const factory ProfileState.loading({
    ProfileData? previousData,
  }) = _Loading;

  /// Loaded state with profile data
  const factory ProfileState.loaded({
    required ProfileData data,
  }) = _Loaded;

  /// Error state with optional cached data
  const factory ProfileState.error({
    required Failure failure,
    ProfileData? cachedData,
  }) = _Error;

  const ProfileState._();

  /// Get current profile data (from any state that has it)
  ProfileData? get currentData {
    return when(
      initial: () => null,
      loading: (previousData) => previousData,
      loaded: (data) => data,
      error: (_, cachedData) => cachedData,
    );
  }

  /// Get user profile if available
  UserProfile? get userProfile => currentData?.userProfile;

  /// Get membership type if available
  MembershipType? get membershipType => currentData?.membershipType;

  /// Check if user is a practitioner
  bool get isPractitioner => currentData?.isPractitioner ?? false;

  /// Check if user is a house surgeon
  bool get isHouseSurgeon => currentData?.isHouseSurgeon ?? false;

  /// Check if user is a student
  bool get isStudent => currentData?.isStudent ?? false;

  /// Check if loading
  bool get isLoading => maybeWhen(
        loading: (_) => true,
        orElse: () => false,
      );

  /// Check if has error
  bool get hasError => maybeWhen(
        error: (_, __) => true,
        orElse: () => false,
      );
}
