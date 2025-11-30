import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/features/home/domain/entities/announcement.dart';

part 'announcements_state.freezed.dart';

/// State for announcements data on homescreen
@freezed
class AnnouncementsState with _$AnnouncementsState {
  /// Initial state before any data is loaded
  const factory AnnouncementsState.initial() = _Initial;

  /// Loading state - can optionally show previous data while loading
  const factory AnnouncementsState.loading({
    List<Announcement>? previousData,
  }) = _Loading;

  /// Loaded state with announcements data
  const factory AnnouncementsState.loaded({
    required List<Announcement> announcements,
  }) = _Loaded;

  /// Error state - can optionally show cached data alongside error
  const factory AnnouncementsState.error({
    required Failure failure,
    List<Announcement>? cachedData,
  }) = _Error;

  /// No announcements found state
  const factory AnnouncementsState.empty() = _Empty;

  const AnnouncementsState._();

  /// Gets current announcements data from any state that has it
  List<Announcement>? get currentData {
    return maybeWhen(
      loading: (previousData) => previousData,
      loaded: (announcements) => announcements,
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

  /// Whether announcements data is available
  bool get hasAnnouncements => currentData != null && currentData!.isNotEmpty;

  /// Number of announcements available
  int get announcementCount => currentData?.length ?? 0;
}
