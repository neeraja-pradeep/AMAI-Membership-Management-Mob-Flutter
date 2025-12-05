import 'package:fpdart/fpdart.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/features/home/domain/entities/upcoming_event.dart';
import 'package:myapp/features/home/domain/repositories/home_repository.dart';

/// Usecase for fetching upcoming events data
/// Data is kept in-memory (Riverpod state), only timestamp persisted
class FetchEventsUsecase {
  const FetchEventsUsecase({required this.repository});

  final HomeRepository repository;

  /// Fetches events (fresh fetch, no if-modified-since)
  /// Used on app launch
  ///
  /// Returns:
  /// - Right(List<UpcomingEvent>) on success
  /// - Left(Failure) on error
  Future<Either<Failure, List<UpcomingEvent>?>> call() async {
    // Fresh fetch without if-modified-since
    return repository.getEvents();
  }

  /// Refreshes events using if-modified-since
  /// Used for pull-to-refresh within a session
  ///
  /// Returns:
  /// - Right(List<UpcomingEvent>) with fresh data if modified
  /// - Right(null) if 304 Not Modified (use in-memory data)
  /// - Left(Failure) on error
  Future<Either<Failure, List<UpcomingEvent>?>> refresh() async {
    // Get stored timestamp for conditional request
    final timestamp = await repository.getEventsTimestamp();

    // Fetch with if-modified-since
    return repository.getEvents(ifModifiedSince: timestamp);
  }
}
