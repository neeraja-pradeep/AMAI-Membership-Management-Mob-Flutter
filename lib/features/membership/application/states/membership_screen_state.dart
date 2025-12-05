import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/features/membership/domain/entities/membership_status.dart';

part 'membership_screen_state.freezed.dart';

/// State for the Membership Screen
/// Handles loading, loaded, and error states with support for cached data
@freezed
class MembershipScreenState with _$MembershipScreenState {
  /// Initial state before any data is loaded
  const factory MembershipScreenState.initial() = _Initial;

  /// Loading state - can hold previous data for graceful loading
  const factory MembershipScreenState.loading({
    MembershipStatus? previousData,
  }) = _Loading;

  /// Loaded state with membership status data
  const factory MembershipScreenState.loaded({
    required MembershipStatus membershipStatus,
  }) = _Loaded;

  /// Empty state when no membership data exists
  const factory MembershipScreenState.empty() = _Empty;

  /// Error state - can hold cached data for graceful degradation
  const factory MembershipScreenState.error({
    required Failure failure,
    MembershipStatus? cachedData,
  }) = _Error;

  const MembershipScreenState._();

  /// Get the current membership data if available
  MembershipStatus? get currentData => maybeWhen(
        loaded: (membershipStatus) => membershipStatus,
        loading: (previousData) => previousData,
        error: (_, cachedData) => cachedData,
        orElse: () => null,
      );

  /// Check if currently loading
  bool get isLoading => maybeWhen(
        loading: (_) => true,
        orElse: () => false,
      );

  /// Check if there's an error
  bool get hasError => maybeWhen(
        error: (_, __) => true,
        orElse: () => false,
      );

  /// Get the failure if in error state
  Failure? get failure => maybeWhen(
        error: (failure, _) => failure,
        orElse: () => null,
      );

  /// Check if should show renewal button
  bool get shouldShowRenewalButton =>
      currentData?.shouldShowRenewalButton ?? false;
}
