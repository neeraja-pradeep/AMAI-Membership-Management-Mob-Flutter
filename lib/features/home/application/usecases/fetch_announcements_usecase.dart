import 'package:fpdart/fpdart.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/features/home/domain/entities/announcement.dart';
import 'package:myapp/features/home/domain/repositories/home_repository.dart';

/// Usecase for fetching announcements data
/// Data is kept in-memory (Riverpod state), only timestamp persisted
class FetchAnnouncementsUsecase {
  const FetchAnnouncementsUsecase({required this.repository});

  final HomeRepository repository;

  /// Fetches announcements (fresh fetch, no if-modified-since)
  /// Used on app launch
  ///
  /// Returns:
  /// - Right(List<Announcement>) on success
  /// - Left(Failure) on error
  Future<Either<Failure, List<Announcement>?>> call() async {
    // Fresh fetch without if-modified-since
    return repository.getAnnouncements();
  }

  /// Refreshes announcements using if-modified-since
  /// Used for pull-to-refresh within a session
  ///
  /// Returns:
  /// - Right(List<Announcement>) with fresh data if modified
  /// - Right(null) if 304 Not Modified (use in-memory data)
  /// - Left(Failure) on error
  Future<Either<Failure, List<Announcement>?>> refresh() async {
    // Get stored timestamp for conditional request
    final timestamp = await repository.getAnnouncementsTimestamp();

    // Fetch with if-modified-since
    return repository.getAnnouncements(ifModifiedSince: timestamp);
  }
}
