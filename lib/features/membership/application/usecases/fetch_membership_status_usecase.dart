import 'package:fpdart/fpdart.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/features/membership/domain/entities/membership_status.dart';
import 'package:myapp/features/membership/domain/repositories/membership_repository.dart';

/// Usecase for fetching membership status
/// Handles the if-modified-since logic for efficient data fetching
class FetchMembershipStatusUsecase {
  const FetchMembershipStatusUsecase({required this.repository});

  final MembershipRepository repository;

  /// Fetches membership status without using if-modified-since
  /// Used for initial load on app launch
  ///
  /// Returns:
  /// - Right(MembershipStatus) on success
  /// - Right(null) if no membership found
  /// - Left(Failure) on error
  Future<Either<Failure, MembershipStatus?>> call({
    required int userId,
  }) async {
    return repository.getMembershipStatus(
      userId: userId,
      ifModifiedSince: null,
    );
  }

  /// Refreshes membership status using if-modified-since header
  /// Used for pull-to-refresh
  ///
  /// Returns:
  /// - Right(MembershipStatus) on 200 OK with new data
  /// - Right(null) on 304 Not Modified (use in-memory data)
  /// - Left(Failure) on error
  Future<Either<Failure, MembershipStatus?>> refresh({
    required int userId,
  }) async {
    // Get stored timestamp
    final timestamp = await repository.getStoredTimestamp();

    return repository.getMembershipStatus(
      userId: userId,
      ifModifiedSince: timestamp,
    );
  }
}
