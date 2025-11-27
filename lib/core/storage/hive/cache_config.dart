/// Configuration constants for the 3-layer cache system
/// (Memory L1 → Hive L2 → Network L3)
class CacheConfig {
  CacheConfig._();

  /// Memory cache maximum size: 50MB
  static const memoryCacheMaxSize = 50 * 1024 * 1024;

  /// Maximum number of entries in memory cache
  static const memoryCacheMaxEntries = 500;

  /// Hive cache maximum size: 200MB
  static const hiveCacheMaxSize = 200 * 1024 * 1024;

  /// Cache is considered stale after 24 hours
  static const staleCacheThreshold = Duration(hours: 24);

  /// Cache is considered valid for 12 hours
  static const validCacheThreshold = Duration(hours: 12);

  /// API request timeout
  static const apiTimeout = Duration(seconds: 10);

  /// Maximum retry attempts for failed requests
  static const maxRetryAttempts = 4;

  /// Base delay for exponential backoff retry
  static const retryBaseDelay = Duration(seconds: 2);

  /// Threshold for triggering Hive eviction (90% of max size)
  static const hiveEvictionThreshold = 0.9;

  /// Percentage of entries to evict when threshold reached
  static const evictionPercentage = 0.2;

  /// Interval for periodic cache size monitoring
  static const cacheMonitorInterval = Duration(minutes: 5);

  /// Maximum consecutive write failures before disabling Hive
  static const maxConsecutiveWriteFailures = 10;

  /// Time-to-live for corruption markers
  static const corruptionMarkerTtl = Duration(minutes: 5);

  /// Maximum corruption count before disabling cache for a key
  static const maxCorruptionCount = 3;
}
