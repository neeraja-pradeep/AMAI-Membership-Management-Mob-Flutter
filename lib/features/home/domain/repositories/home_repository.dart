import 'package:fpdart/fpdart.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/features/home/domain/entities/aswas_plus.dart';
import 'package:myapp/features/home/domain/entities/membership_card.dart';

/// Abstract repository contract for home feature data operations
/// Data is kept in-memory (Riverpod state), only timestamp is persisted
abstract class HomeRepository {
  // ============== Membership Card ==============

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

  /// Gets stored membership timestamp for If-Modified-Since header
  Future<String?> getMembershipTimestamp();

  /// Stores membership timestamp from successful API response
  Future<void> storeMembershipTimestamp(String timestamp);

  /// Clears stored membership timestamp
  Future<void> clearMembershipTimestamp();

  // ============== Aswas Plus ==============

  /// Fetches Aswas Plus data from API
  ///
  /// [ifModifiedSince] - Timestamp for conditional request (304 handling)
  ///
  /// Returns:
  /// - Right(AswasPlus) on 200 OK with active policy
  /// - Right(null) on 304 Not Modified or no active policy
  /// - Left(Failure) on error
  Future<Either<Failure, AswasPlus?>> getAswasPlus({
    String? ifModifiedSince,
  });

  /// Gets stored aswas timestamp for If-Modified-Since header
  Future<String?> getAswasTimestamp();

  /// Stores aswas timestamp from successful API response
  Future<void> storeAswasTimestamp(String timestamp);

  /// Clears stored aswas timestamp
  Future<void> clearAswasTimestamp();

  // ============== Clear All ==============

  /// Clears all stored timestamps
  Future<void> clearAllTimestamps();
}
