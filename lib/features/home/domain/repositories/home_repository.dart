import 'package:fpdart/fpdart.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/features/aswas_plus/domain/entities/digital_product.dart';
import 'package:myapp/features/aswas_plus/domain/entities/nominee.dart';
import 'package:myapp/features/aswas_plus/domain/entities/renewal_response.dart';
import 'package:myapp/features/home/domain/entities/announcement.dart';
import 'package:myapp/features/home/domain/entities/aswas_plus.dart';
import 'package:myapp/features/home/domain/entities/membership_card.dart';
import 'package:myapp/features/home/domain/entities/upcoming_event.dart';

/// Abstract repository contract for home feature data operations
/// Data is kept in-memory (Riverpod state), only timestamp is persisted
abstract class HomeRepository {
  // ============== Membership Card ==============

  /// Fetches membership card data from API
  ///
  /// [userId] - The user ID to fetch membership for
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

  // ============== Events ==============

  /// Fetches upcoming events from API
  ///
  /// [ifModifiedSince] - Timestamp for conditional request (304 handling)
  ///
  /// Returns:
  /// - Right(List<UpcomingEvent>) on 200 OK with events
  /// - Right(null) on 304 Not Modified (use in-memory data)
  /// - Left(Failure) on error
  Future<Either<Failure, List<UpcomingEvent>?>> getEvents({
    String? ifModifiedSince,
  });

  /// Gets stored events timestamp for If-Modified-Since header
  Future<String?> getEventsTimestamp();

  /// Stores events timestamp from successful API response
  Future<void> storeEventsTimestamp(String timestamp);

  /// Clears stored events timestamp
  Future<void> clearEventsTimestamp();

  // ============== Announcements ==============

  /// Fetches announcements from API
  ///
  /// [ifModifiedSince] - Timestamp for conditional request (304 handling)
  ///
  /// Returns:
  /// - Right(List<Announcement>) on 200 OK with announcements
  /// - Right(null) on 304 Not Modified (use in-memory data)
  /// - Left(Failure) on error
  Future<Either<Failure, List<Announcement>?>> getAnnouncements({
    String? ifModifiedSince,
  });

  /// Gets stored announcements timestamp for If-Modified-Since header
  Future<String?> getAnnouncementsTimestamp();

  /// Stores announcements timestamp from successful API response
  Future<void> storeAnnouncementsTimestamp(String timestamp);

  /// Clears stored announcements timestamp
  Future<void> clearAnnouncementsTimestamp();

  // ============== Nominees ==============

  /// Fetches nominees from API
  ///
  /// [ifModifiedSince] - Timestamp for conditional request (304 handling)
  ///
  /// Returns:
  /// - Right(List<Nominee>) on 200 OK with nominees
  /// - Right(null) on 304 Not Modified (use in-memory data)
  /// - Left(Failure) on error
  Future<Either<Failure, List<Nominee>?>> getNominees({
    String? ifModifiedSince,
  });

  /// Gets stored nominees timestamp for If-Modified-Since header
  Future<String?> getNomineesTimestamp();

  /// Stores nominees timestamp from successful API response
  Future<void> storeNomineesTimestamp(String timestamp);

  /// Clears stored nominees timestamp
  Future<void> clearNomineesTimestamp();

  // ============== Digital Products ==============

  /// Fetches a digital product by ID
  ///
  /// [productId] - The ID of the digital product
  ///
  /// Returns:
  /// - Right(DigitalProduct) on success
  /// - Left(Failure) on error
  Future<Either<Failure, DigitalProduct?>> getDigitalProduct({
    required int productId,
  });

  /// Initiates insurance renewal
  ///
  /// Returns:
  /// - Right(RenewalResponse) on success
  /// - Left(Failure) on error
  Future<Either<Failure, RenewalResponse?>> initiateInsuranceRenewal();

  /// Verifies Razorpay payment after successful payment
  ///
  /// [razorpayOrderId] - The Razorpay order ID
  /// [razorpayPaymentId] - The Razorpay payment ID
  /// [razorpaySignature] - The Razorpay signature
  ///
  /// Returns:
  /// - Right(true) on success
  /// - Left(Failure) on error
  Future<Either<Failure, bool>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  });

  // ============== Clear All ==============

  /// Clears all stored timestamps
  Future<void> clearAllTimestamps();
}
