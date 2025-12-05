import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/features/home/domain/entities/membership_card.dart';

part 'membership_state.freezed.dart';

/// State for membership card data on homescreen
@freezed
class MembershipState with _$MembershipState {
  /// Initial state before any data is loaded
  const factory MembershipState.initial() = _Initial;

  /// Loading state - can optionally show previous data while loading
  const factory MembershipState.loading({
    MembershipCard? previousData,
  }) = _Loading;

  /// Loaded state with membership card data
  const factory MembershipState.loaded({
    required MembershipCard membershipCard,
  }) = _Loaded;

  /// Error state - can optionally show cached data alongside error
  const factory MembershipState.error({
    required Failure failure,
    MembershipCard? cachedData,
  }) = _Error;

  /// No membership found state
  const factory MembershipState.empty() = _Empty;

  /// Pending approval state - membership application is under review
  const factory MembershipState.pending() = _Pending;

  /// Rejected state - membership application was rejected
  const factory MembershipState.rejected() = _Rejected;

  const MembershipState._();

  /// Gets current membership card data from any state that has it
  MembershipCard? get currentData {
    return maybeWhen(
      loading: (previousData) => previousData,
      loaded: (membershipCard) => membershipCard,
      error: (_, cachedData) => cachedData,
      orElse: () => null,
    );
  }

  /// Whether state is currently loading
  bool get isLoading => maybeWhen(
        loading: (_) => true,
        orElse: () => false,
      );

  /// Whether state has an error
  bool get hasError => maybeWhen(
        error: (_, __) => true,
        orElse: () => false,
      );

  /// Gets the current failure if in error state
  Failure? get currentFailure => maybeWhen(
        error: (failure, _) => failure,
        orElse: () => null,
      );

  /// Whether membership card data is available
  bool get hasMembershipCard => currentData != null;

  /// Whether membership is active (if data available)
  bool get isActive => currentData?.isActive ?? false;

  /// Whether membership is expired (if data available)
  bool get isExpired => currentData?.isExpired ?? false;

  /// Whether membership application is pending approval
  bool get isPending => maybeWhen(
        pending: () => true,
        orElse: () => false,
      );

  /// Whether membership application was rejected
  bool get isRejected => maybeWhen(
        rejected: () => true,
        orElse: () => false,
      );
}
