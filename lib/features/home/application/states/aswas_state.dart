import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/features/home/domain/entities/aswas_plus.dart';

part 'aswas_state.freezed.dart';

/// State for Aswas Plus insurance data on homescreen
@freezed
class AswasState with _$AswasState {
  /// Initial state before any data is loaded
  const factory AswasState.initial() = _Initial;

  /// Loading state - can optionally show previous data while loading
  const factory AswasState.loading({
    AswasPlus? previousData,
  }) = _Loading;

  /// Loaded state with Aswas Plus data
  const factory AswasState.loaded({
    required AswasPlus aswasPlus,
  }) = _Loaded;

  /// Error state - can optionally show cached data alongside error
  const factory AswasState.error({
    required Failure failure,
    AswasPlus? cachedData,
  }) = _Error;

  /// No active policy found state
  const factory AswasState.empty() = _Empty;

  const AswasState._();

  /// Gets current Aswas Plus data from any state that has it
  AswasPlus? get currentData {
    return maybeWhen(
      loading: (previousData) => previousData,
      loaded: (aswasPlus) => aswasPlus,
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

  /// Whether Aswas Plus data is available
  bool get hasAswasPlus => currentData != null;

  /// Whether policy is active (if data available)
  bool get isActive => currentData?.isActive ?? false;

  /// Whether policy is expired (if data available)
  bool get isExpired => currentData?.isExpired ?? false;
}
