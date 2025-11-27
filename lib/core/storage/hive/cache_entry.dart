import 'package:hive/hive.dart';
import 'cache_config.dart';

part 'cache_entry.g.dart';

/// Cache entry model for storing API responses with metadata
/// Supports conditional requests (HTTP 304) and LRU eviction
@HiveType(typeId: 1)
class CacheEntry {
  /// Unique cache key (SHA256 hash of request parameters)
  @HiveField(0)
  final String key;

  /// Cached data (JSON-decoded response)
  @HiveField(1)
  final dynamic data;

  /// Last-Modified header from server response (for HTTP 304)
  @HiveField(2)
  final String? lastModified;

  /// Timestamp when data was cached (milliseconds since epoch)
  @HiveField(3)
  final int cachedAt;

  /// Timestamp when entry was last accessed (for LRU)
  @HiveField(4)
  final int lastAccessed;

  /// Number of times this entry has been accessed
  @HiveField(5)
  final int accessCount;

  /// Size of the cached data in bytes
  @HiveField(6)
  final int size;

  CacheEntry({
    required this.key,
    required this.data,
    this.lastModified,
    required this.cachedAt,
    required this.lastAccessed,
    required this.accessCount,
    required this.size,
  });

  /// Returns true if cache is older than 24 hours (stale)
  bool get isStale {
    final now = DateTime.now().millisecondsSinceEpoch;
    return now - cachedAt > CacheConfig.staleCacheThreshold.inMilliseconds;
  }

  /// Returns true if cache is younger than 12 hours (valid)
  bool get isValid {
    final now = DateTime.now().millisecondsSinceEpoch;
    return now - cachedAt < CacheConfig.validCacheThreshold.inMilliseconds;
  }

  /// Returns age of cache in hours
  double get ageInHours {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - cachedAt) / (1000 * 60 * 60);
  }

  /// Creates a copy with updated access metadata
  CacheEntry copyWithAccess() {
    return CacheEntry(
      key: key,
      data: data,
      lastModified: lastModified,
      cachedAt: cachedAt,
      lastAccessed: DateTime.now().millisecondsSinceEpoch,
      accessCount: accessCount + 1,
      size: size,
    );
  }

  /// Creates a copy with updated data
  CacheEntry copyWithData({
    required dynamic data,
    String? lastModified,
    required int size,
  }) {
    return CacheEntry(
      key: key,
      data: data,
      lastModified: lastModified,
      cachedAt: DateTime.now().millisecondsSinceEpoch,
      lastAccessed: DateTime.now().millisecondsSinceEpoch,
      accessCount: accessCount,
      size: size,
    );
  }

  /// Creates a new cache entry
  factory CacheEntry.create({
    required String key,
    required dynamic data,
    String? lastModified,
    required int size,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return CacheEntry(
      key: key,
      data: data,
      lastModified: lastModified,
      cachedAt: now,
      lastAccessed: now,
      accessCount: 1,
      size: size,
    );
  }
}
