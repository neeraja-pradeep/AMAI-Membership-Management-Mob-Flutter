import 'package:hive/hive.dart';
import 'package:myapp/features/home/infrastructure/models/membership_card_model.dart';

/// Box keys for home feature caching
class HomeBoxKeys {
  HomeBoxKeys._();

  static const String boxName = 'home_box';
  static const String membershipCardKey = 'membership_card';
  static const String timestampKey = 'home_timestamp';
}

/// Abstract interface for home local data source operations
abstract class HomeLocalDataSource {
  /// Caches membership card data
  Future<void> cacheMembershipCard(MembershipCardModel card);

  /// Retrieves cached membership card
  Future<MembershipCardModel?> getCachedMembershipCard();

  /// Stores timestamp for If-Modified-Since header
  Future<void> storeTimestamp(String timestamp);

  /// Gets stored timestamp
  Future<String?> getTimestamp();

  /// Clears all cached home data
  Future<void> clearCache();
}

/// Implementation of HomeLocalDataSource using Hive
class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  const HomeLocalDataSourceImpl({required this.box});

  final Box<dynamic> box;

  @override
  Future<void> cacheMembershipCard(MembershipCardModel card) async {
    await box.put(HomeBoxKeys.membershipCardKey, card.toJson());
  }

  @override
  Future<MembershipCardModel?> getCachedMembershipCard() async {
    final data = box.get(HomeBoxKeys.membershipCardKey);

    if (data == null) return null;

    try {
      // Data is stored as Map<String, dynamic>
      if (data is Map) {
        return MembershipCardModel.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      // If parsing fails, clear corrupted cache
      await box.delete(HomeBoxKeys.membershipCardKey);
      return null;
    }
  }

  @override
  Future<void> storeTimestamp(String timestamp) async {
    await box.put(HomeBoxKeys.timestampKey, timestamp);
  }

  @override
  Future<String?> getTimestamp() async {
    final timestamp = box.get(HomeBoxKeys.timestampKey);
    return timestamp as String?;
  }

  @override
  Future<void> clearCache() async {
    await box.delete(HomeBoxKeys.membershipCardKey);
    await box.delete(HomeBoxKeys.timestampKey);
  }
}
