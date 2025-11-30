import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/features/home/domain/entities/upcoming_event.dart';

part 'events_state.freezed.dart';

/// State for upcoming events data on homescreen
@freezed
class EventsState with _$EventsState {
  /// Initial state before any data is loaded
  const factory EventsState.initial() = _Initial;

  /// Loading state - can optionally show previous data while loading
  const factory EventsState.loading({
    List<UpcomingEvent>? previousData,
  }) = _Loading;

  /// Loaded state with events data
  const factory EventsState.loaded({
    required List<UpcomingEvent> events,
  }) = _Loaded;

  /// Error state - can optionally show cached data alongside error
  const factory EventsState.error({
    required Failure failure,
    List<UpcomingEvent>? cachedData,
  }) = _Error;

  /// No events found state
  const factory EventsState.empty() = _Empty;

  const EventsState._();

  /// Gets current events data from any state that has it
  List<UpcomingEvent>? get currentData {
    return maybeWhen(
      loading: (previousData) => previousData,
      loaded: (events) => events,
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

  /// Whether events data is available
  bool get hasEvents => currentData != null && currentData!.isNotEmpty;

  /// Number of events available
  int get eventCount => currentData?.length ?? 0;
}
