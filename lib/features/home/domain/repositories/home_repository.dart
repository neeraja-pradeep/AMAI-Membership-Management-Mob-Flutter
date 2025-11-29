import 'package:fpdart/fpdart.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/features/home/domain/entities/membership_card.dart';

/// Abstract repository contract for home feature data operations
/// Implementations handle the actual data fetching and caching logic
abstract class HomeRepository {
  /// Fetches membership card data
  ///
  /// [ifModifiedSince] - Timestamp for conditional request (304 handling)
  ///
  /// Returns:
  /// - Right(MembershipCard) on 200 OK with fresh data
  /// - Right(null) on 304 Not Modified (use cached data)
  /// - Left(Failure) on error
  Future<Either<Failure, MembershipCard?>> getMembershipCard({
    required String ifModifiedSince,
  });

  /// Gets cached membership card from local storage
  Future<Either<Failure, MembershipCard?>> getCachedMembershipCard();

  /// Caches membership card to local storage
  Future<Either<Failure, Unit>> cacheMembershipCard(MembershipCard card);

  /// Gets stored timestamp for If-Modified-Since header
  Future<String?> getStoredTimestamp();

  /// Stores timestamp from successful API response
  Future<void> storeTimestamp(String timestamp);

  /// Clears all cached home data
  Future<void> clearCache();
}
