import 'package:fpdart/fpdart.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/features/home/domain/entities/aswas_plus.dart';
import 'package:myapp/features/home/domain/repositories/home_repository.dart';

/// Usecase for fetching Aswas Plus insurance data
/// Data is kept in-memory (Riverpod state), only timestamp persisted
class FetchAswasUsecase {
  const FetchAswasUsecase({required this.repository});

  final HomeRepository repository;

  /// Fetches Aswas Plus (fresh fetch, no if-modified-since)
  /// Used on app launch
  ///
  /// [userId] - The user ID to fetch insurance policies for
  ///
  /// Returns:
  /// - Right(AswasPlus) on success with active policy
  /// - Right(null) if no active policy
  /// - Left(Failure) on error
  Future<Either<Failure, AswasPlus?>> call({required int userId}) async {
    // Fresh fetch without if-modified-since
    return repository.getAswasPlus(userId: userId);
  }

  /// Refreshes Aswas Plus using if-modified-since
  /// Used for pull-to-refresh within a session
  ///
  /// [userId] - The user ID to fetch insurance policies for
  ///
  /// Returns:
  /// - Right(AswasPlus) with fresh data if modified
  /// - Right(null) if 304 Not Modified (use in-memory data)
  /// - Left(Failure) on error
  Future<Either<Failure, AswasPlus?>> refresh({required int userId}) async {
    // Get stored timestamp for conditional request
    final timestamp = await repository.getAswasTimestamp();

    // Fetch with if-modified-since
    return repository.getAswasPlus(userId: userId, ifModifiedSince: timestamp);
  }
}
