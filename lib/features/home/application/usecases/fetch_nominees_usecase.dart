import 'package:fpdart/fpdart.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/features/aswas_plus/domain/entities/nominee.dart';
import 'package:myapp/features/home/domain/repositories/home_repository.dart';

/// Usecase for fetching insurance nominees data
/// Data is kept in-memory (Riverpod state), only timestamp persisted
class FetchNomineesUsecase {
  const FetchNomineesUsecase({required this.repository});

  final HomeRepository repository;

  /// Fetches nominees (fresh fetch, no if-modified-since)
  /// Used on app launch
  ///
  /// Returns:
  /// - Right(List<Nominee>) on success with nominees
  /// - Right([]) if no nominees
  /// - Left(Failure) on error
  Future<Either<Failure, List<Nominee>?>> call() async {
    // Fresh fetch without if-modified-since
    return repository.getNominees();
  }

  /// Refreshes nominees using if-modified-since
  /// Used for pull-to-refresh within a session
  ///
  /// Returns:
  /// - Right(List<Nominee>) with fresh data if modified
  /// - Right(null) if 304 Not Modified (use in-memory data)
  /// - Left(Failure) on error
  Future<Either<Failure, List<Nominee>?>> refresh() async {
    // Get stored timestamp for conditional request
    final timestamp = await repository.getNomineesTimestamp();

    // Fetch with if-modified-since
    return repository.getNominees(ifModifiedSince: timestamp);
  }
}
