import 'package:hive/hive.dart';

/// Box keys for home feature
class HomeBoxKeys {
  HomeBoxKeys._();

  static const String boxName = 'home_box';
  static const String timestampKey = 'home_timestamp';
}

/// Abstract interface for home local data source operations
/// Only handles timestamp storage for if-modified-since pattern
abstract class HomeLocalDataSource {
  /// Stores timestamp for If-Modified-Since header
  Future<void> storeTimestamp(String timestamp);

  /// Gets stored timestamp
  Future<String?> getTimestamp();

  /// Clears timestamp
  Future<void> clearTimestamp();
}

/// Implementation of HomeLocalDataSource using Hive
/// Only stores timestamp for if-modified-since optimization
class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  const HomeLocalDataSourceImpl({required this.box});

  final Box<dynamic> box;

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
  Future<void> clearTimestamp() async {
    await box.delete(HomeBoxKeys.timestampKey);
  }
}
