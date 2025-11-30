import 'package:fpdart/fpdart.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/features/home/domain/entities/membership_card.dart';

/// Abstract repository contract for home feature data operations
/// Data is kept in-memory (Riverpod state), only timestamp is persisted
abstract class HomeRepository {
  /// Fetches membership card data from API
  ///
  /// [ifModifiedSince] - Timestamp for conditional request (304 handling)
  ///
  /// Returns:
  /// - Right(MembershipCard) on 200 OK with fresh data
  /// - Right(null) on 304 Not Modified (use in-memory data)
  /// - Left(Failure) on error
  Future<Either<Failure, MembershipCard?>> getMembershipCard({
    String? ifModifiedSince,
  });

  /// Gets stored timestamp for If-Modified-Since header
  Future<String?> getStoredTimestamp();

  /// Stores timestamp from successful API response
  Future<void> storeTimestamp(String timestamp);

  /// Clears stored timestamp
  Future<void> clearTimestamp();
}
