import 'package:hive/hive.dart';

/// Box keys for home feature
class HomeBoxKeys {
  HomeBoxKeys._();

  static const String boxName = 'home_box';
  static const String membershipTimestampKey = 'membership_timestamp';
  static const String aswasTimestampKey = 'aswas_timestamp';
  static const String eventsTimestampKey = 'events_timestamp';
}

/// Abstract interface for home local data source operations
/// Only handles timestamp storage for if-modified-since pattern
abstract class HomeLocalDataSource {
  // ============== Membership Timestamp ==============

  /// Stores membership timestamp for If-Modified-Since header
  Future<void> storeMembershipTimestamp(String timestamp);

  /// Gets stored membership timestamp
  Future<String?> getMembershipTimestamp();

  /// Clears membership timestamp
  Future<void> clearMembershipTimestamp();

  // ============== Aswas Plus Timestamp ==============

  /// Stores aswas plus timestamp for If-Modified-Since header
  Future<void> storeAswasTimestamp(String timestamp);

  /// Gets stored aswas plus timestamp
  Future<String?> getAswasTimestamp();

  /// Clears aswas plus timestamp
  Future<void> clearAswasTimestamp();

  // ============== Events Timestamp ==============

  /// Stores events timestamp for If-Modified-Since header
  Future<void> storeEventsTimestamp(String timestamp);

  /// Gets stored events timestamp
  Future<String?> getEventsTimestamp();

  /// Clears events timestamp
  Future<void> clearEventsTimestamp();

  // ============== Clear All ==============

  /// Clears all timestamps
  Future<void> clearAllTimestamps();
}

/// Implementation of HomeLocalDataSource using Hive
/// Only stores timestamps for if-modified-since optimization
class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  const HomeLocalDataSourceImpl({required this.box});

  final Box<dynamic> box;

  // ============== Membership Timestamp ==============

  @override
  Future<void> storeMembershipTimestamp(String timestamp) async {
    await box.put(HomeBoxKeys.membershipTimestampKey, timestamp);
  }

  @override
  Future<String?> getMembershipTimestamp() async {
    final timestamp = box.get(HomeBoxKeys.membershipTimestampKey);
    return timestamp as String?;
  }

  @override
  Future<void> clearMembershipTimestamp() async {
    await box.delete(HomeBoxKeys.membershipTimestampKey);
  }

  // ============== Aswas Plus Timestamp ==============

  @override
  Future<void> storeAswasTimestamp(String timestamp) async {
    await box.put(HomeBoxKeys.aswasTimestampKey, timestamp);
  }

  @override
  Future<String?> getAswasTimestamp() async {
    final timestamp = box.get(HomeBoxKeys.aswasTimestampKey);
    return timestamp as String?;
  }

  @override
  Future<void> clearAswasTimestamp() async {
    await box.delete(HomeBoxKeys.aswasTimestampKey);
  }

  // ============== Events Timestamp ==============

  @override
  Future<void> storeEventsTimestamp(String timestamp) async {
    await box.put(HomeBoxKeys.eventsTimestampKey, timestamp);
  }

  @override
  Future<String?> getEventsTimestamp() async {
    final timestamp = box.get(HomeBoxKeys.eventsTimestampKey);
    return timestamp as String?;
  }

  @override
  Future<void> clearEventsTimestamp() async {
    await box.delete(HomeBoxKeys.eventsTimestampKey);
  }

  // ============== Clear All ==============

  @override
  Future<void> clearAllTimestamps() async {
    await box.delete(HomeBoxKeys.membershipTimestampKey);
    await box.delete(HomeBoxKeys.aswasTimestampKey);
    await box.delete(HomeBoxKeys.eventsTimestampKey);
  }
}
