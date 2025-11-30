import 'package:fpdart/fpdart.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/features/home/domain/entities/membership_card.dart';
import 'package:myapp/features/home/domain/repositories/home_repository.dart';

/// Usecase for fetching membership card data
/// Data is kept in-memory (Riverpod state), only timestamp persisted
class FetchMembershipUsecase {
  const FetchMembershipUsecase({required this.repository});

  final HomeRepository repository;

  /// Fetches membership card (fresh fetch, no if-modified-since)
  /// Used on app launch
  ///
  /// Returns:
  /// - Right(MembershipCard) on success
  /// - Left(Failure) on error
  Future<Either<Failure, MembershipCard?>> call() async {
    // Fresh fetch without if-modified-since
    return repository.getMembershipCard();
  }

  /// Refreshes membership card using if-modified-since
  /// Used for pull-to-refresh within a session
  ///
  /// Returns:
  /// - Right(MembershipCard) with fresh data if modified
  /// - Right(null) if 304 Not Modified (use in-memory data)
  /// - Left(Failure) on error
  Future<Either<Failure, MembershipCard?>> refresh() async {
    // Get stored timestamp for conditional request
    final timestamp = await repository.getStoredTimestamp();

    // Fetch with if-modified-since
    return repository.getMembershipCard(ifModifiedSince: timestamp);
  }
}
