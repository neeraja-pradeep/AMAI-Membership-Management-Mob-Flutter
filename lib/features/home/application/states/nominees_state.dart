import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/features/aswas_plus/domain/entities/nominee.dart';

part 'nominees_state.freezed.dart';

/// State for insurance nominees data on ASWAS Plus screen
@freezed
class NomineesState with _$NomineesState {
  /// Initial state before any data is loaded
  const factory NomineesState.initial() = _Initial;

  /// Loading state - can optionally show previous data while loading
  const factory NomineesState.loading({
    List<Nominee>? previousData,
  }) = _Loading;

  /// Loaded state with nominees data
  const factory NomineesState.loaded({
    required List<Nominee> nominees,
  }) = _Loaded;

  /// Error state - can optionally show cached data alongside error
  const factory NomineesState.error({
    required Failure failure,
    List<Nominee>? cachedData,
  }) = _Error;

  /// No nominees found state
  const factory NomineesState.empty() = _Empty;

  const NomineesState._();

  /// Gets current nominees data from any state that has it
  List<Nominee>? get currentData {
    return maybeWhen(
      loading: (previousData) => previousData,
      loaded: (nominees) => nominees,
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

  /// Whether nominees data is available
  bool get hasNominees => currentData != null && currentData!.isNotEmpty;

  /// Gets the count of nominees
  int get nomineeCount => currentData?.length ?? 0;
}
