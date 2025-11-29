import 'package:fpdart/fpdart.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/features/home/domain/entities/membership_card.dart';
import 'package:myapp/features/home/domain/repositories/home_repository.dart';

/// Usecase for fetching membership card data
/// Encapsulates the if-modified-since logic and cache fallback
class FetchMembershipUsecase {
  const FetchMembershipUsecase({required this.repository});

  final HomeRepository repository;

  /// Executes the usecase to fetch membership card
  ///
  /// Returns:
  /// - Right(MembershipCard) with fresh or cached data
  /// - Left(Failure) on error
  Future<Either<Failure, MembershipCard>> call() async {
    // Get stored timestamp for conditional request
    final timestamp = await repository.getStoredTimestamp() ?? '';

    // Fetch membership card from API
    final result = await repository.getMembershipCard(
      ifModifiedSince: timestamp,
    );

    return result.fold(
      (failure) async {
        // On failure, try to return cached data
        final cachedResult = await repository.getCachedMembershipCard();
        return cachedResult.fold(
          (cacheFailure) => left(failure), // Return original failure
          (cachedCard) {
            if (cachedCard != null) {
              // Return cached data but still indicate there was an error
              // This allows UI to show cached data with error banner
              return right(cachedCard);
            }
            return left(failure);
          },
        );
      },
      (membershipCard) async {
        // Check if 304 Not Modified (null indicates use cache)
        if (membershipCard == null) {
          // Get cached data
          final cachedResult = await repository.getCachedMembershipCard();
          return cachedResult.fold(
            (failure) => left(failure),
            (cachedCard) {
              if (cachedCard != null) {
                return right(cachedCard);
              }
              return left(const CacheFailure(
                message: 'No cached membership data available.',
              ));
            },
          );
        }

        // Return fresh data
        return right(membershipCard);
      },
    );
  }
}

/// Usecase for getting cached membership card only
/// Used for initial load before API call
class GetCachedMembershipUsecase {
  const GetCachedMembershipUsecase({required this.repository});

  final HomeRepository repository;

  /// Gets cached membership card if available
  Future<Either<Failure, MembershipCard?>> call() async {
    return repository.getCachedMembershipCard();
  }
}
