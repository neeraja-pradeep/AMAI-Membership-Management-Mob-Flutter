import 'package:fpdart/fpdart.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/features/membership/domain/entities/membership_status.dart';

/// Abstract repository interface for membership operations
/// Defines the contract for fetching and caching membership data
abstract class MembershipRepository {
  /// Fetches membership status for a user
  ///
  /// [userId] - The user ID to fetch membership for
  /// [ifModifiedSince] - Optional timestamp for conditional request
  ///
  /// Returns:
  /// - Right(MembershipStatus) on 200 OK with data
  /// - Right(null) on 304 Not Modified (use cached data)
  /// - Left(Failure) on error
  Future<Either<Failure, MembershipStatus?>> getMembershipStatus({
    required int userId,
    String? ifModifiedSince,
  });

  /// Gets the stored timestamp for membership data
  Future<String?> getStoredTimestamp();

  /// Stores the timestamp from the API response
  Future<void> storeTimestamp(String timestamp);

  /// Clears the stored timestamp
  Future<void> clearTimestamp();
}
