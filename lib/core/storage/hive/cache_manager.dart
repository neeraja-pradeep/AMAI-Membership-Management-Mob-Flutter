import 'dart:async';

import 'cache_config.dart';
import 'cache_entry.dart';
import 'cache_utils.dart';
import 'hive_provider.dart';
import 'memory_cache.dart';
import 'request_pool.dart';
import 'retry_policy.dart';

/// Result of a cache fetch operation
class CacheResult<T> {
  final T? data;
  final CacheSource source;
  final bool isStale;
  final String? lastModified;

  CacheResult({
    this.data,
    required this.source,
    this.isStale = false,
    this.lastModified,
  });
}

/// Source of cached data
enum CacheSource { memory, hive, network, none }

/// Orchestrates the 3-layer cache system
///
/// Flow:
/// 1. Check Memory Cache (L1) - fastest (1-5ms)
/// 2. Check Hive Cache (L2) - fast (50ms)
/// 3. Fetch from Network (L3) - slow (100-500ms)
class CacheManager {
  final MemoryCache _memoryCache = MemoryCache();
  final RequestPool _requestPool = RequestPool();
  final RetryPolicy _retryPolicy = RetryPolicy();

  /// Tracks corruption for cache keys
  final Map<String, int> _corruptionTracker = {};

  /// Tracks consecutive write failures
  int _consecutiveWriteFailures = 0;

  /// Flag to disable Hive if too many failures
  bool _isHiveDisabled = false;

  /// Gets data from cache or network
  ///
  /// Strategy:
  /// 1. Check Memory → if hit, return immediately
  /// 2. Check Hive → if hit, update Memory and return
  /// 3. If cache valid (< 12h), fetch in background for update
  /// 4. If cache stale (> 24h) or miss, fetch immediately
  Future<CacheResult<T>> get<T>({
    required String cacheKey,
    required Future<T> Function() networkFetch,
    Map<String, dynamic>? headers,
    bool forceRefresh = false,
  }) async {
    // Skip all cache if force refresh
    if (forceRefresh) {
      return _fetchFromNetwork(
        cacheKey: cacheKey,
        networkFetch: networkFetch,
        headers: headers,
      );
    }

    // Step 1: Check Memory Cache (L1)
    final memoryCacheEntry = _memoryCache.get(cacheKey);
    if (memoryCacheEntry != null) {
      // If cache is valid, return and optionally refresh in background
      if (memoryCacheEntry.isValid) {
        _refreshInBackground(
          cacheKey: cacheKey,
          networkFetch: networkFetch,
          lastModified: memoryCacheEntry.lastModified,
          headers: headers,
        );
        return CacheResult<T>(
          data: memoryCacheEntry.data as T?,
          source: CacheSource.memory,
          isStale: false,
          lastModified: memoryCacheEntry.lastModified,
        );
      }
    }

    // Step 2: Check Hive Cache (L2)
    if (!_isHiveDisabled) {
      try {
        final hiveCacheEntry = await _getFromHive(cacheKey);
        if (hiveCacheEntry != null) {
          // Load to memory cache
          _memoryCache.put(hiveCacheEntry);

          // If valid, return and refresh in background
          if (hiveCacheEntry.isValid) {
            _refreshInBackground(
              cacheKey: cacheKey,
              networkFetch: networkFetch,
              lastModified: hiveCacheEntry.lastModified,
              headers: headers,
            );
            return CacheResult<T>(
              data: hiveCacheEntry.data as T?,
              source: CacheSource.hive,
              isStale: false,
              lastModified: hiveCacheEntry.lastModified,
            );
          }

          // If stale but exists, return and fetch in foreground
          if (hiveCacheEntry.isStale) {
            return CacheResult<T>(
              data: hiveCacheEntry.data as T?,
              source: CacheSource.hive,
              isStale: true,
              lastModified: hiveCacheEntry.lastModified,
            );
          }
        }
      } catch (e) {
        _handleHiveError(cacheKey, e);
      }
    }

    // Step 3: Fetch from Network (L3)
    return _fetchFromNetwork(
      cacheKey: cacheKey,
      networkFetch: networkFetch,
      headers: headers,
    );
  }

  /// Fetches data from network with retry logic
  Future<CacheResult<T>> _fetchFromNetwork<T>({
    required String cacheKey,
    required Future<T> Function() networkFetch,
    Map<String, dynamic>? headers,
  }) async {
    try {
      // Deduplicate concurrent requests
      final data = await _requestPool.dedupe<T>(
        cacheKey,
        () => _retryPolicy.executeWithRetry(networkFetch),
      );

      // Validate and cache the data
      if (CacheUtils.isValidCacheData(data)) {
        final size = CacheUtils.calculateDataSize(data);
        final lastModified = CacheUtils.extractLastModified(headers);

        final entry = CacheEntry.create(
          key: cacheKey,
          data: data,
          lastModified: lastModified,
          size: size,
        );

        // Save to memory and Hive
        _memoryCache.put(entry);
        await _saveToHive(entry);

        return CacheResult<T>(
          data: data,
          source: CacheSource.network,
          lastModified: lastModified,
        );
      }

      return CacheResult<T>(data: data, source: CacheSource.network);
    } catch (e) {
      // Return cached data if available on error
      final cachedEntry = _memoryCache.get(cacheKey);
      if (cachedEntry != null) {
        return CacheResult<T>(
          data: cachedEntry.data as T?,
          source: CacheSource.memory,
          isStale: true,
        );
      }

      rethrow;
    }
  }

  /// Refreshes cache in background (non-blocking)
  void _refreshInBackground<T>({
    required String cacheKey,
    required Future<T> Function() networkFetch,
    String? lastModified,
    Map<String, dynamic>? headers,
  }) {
    // Execute refresh without waiting
    _fetchFromNetwork(
      cacheKey: cacheKey,
      networkFetch: networkFetch,
      headers: headers,
    ).catchError((e) {
      // Silently fail background refresh
    });
  }

  /// Gets entry from Hive
  Future<CacheEntry?> _getFromHive(String cacheKey) async {
    try {
      final box = await HiveProvider.getBox();
      return box.get(cacheKey);
    } catch (e) {
      _handleHiveError(cacheKey, e);
      return null;
    }
  }

  /// Saves entry to Hive
  Future<void> _saveToHive(CacheEntry entry) async {
    if (_isHiveDisabled) return;

    try {
      final box = await HiveProvider.getBox();
      await box.put(entry.key, entry);
      _consecutiveWriteFailures = 0;

      // Trigger eviction check if needed
      _checkAndEvictHive();
    } catch (e) {
      _consecutiveWriteFailures++;

      if (_consecutiveWriteFailures >=
          CacheConfig.maxConsecutiveWriteFailures) {
        _isHiveDisabled = true;
      }
    }
  }

  /// Handles Hive read/write errors
  void _handleHiveError(String cacheKey, dynamic error) {
    // Track corruption
    _corruptionTracker[cacheKey] = (_corruptionTracker[cacheKey] ?? 0) + 1;

    // If corrupted too many times, delete entry
    if (_corruptionTracker[cacheKey]! >= CacheConfig.maxCorruptionCount) {
      _deleteFromHive(cacheKey);
      _corruptionTracker.remove(cacheKey);
    }
  }

  /// Deletes entry from Hive
  Future<void> _deleteFromHive(String cacheKey) async {
    try {
      final box = await HiveProvider.getBox();
      await box.delete(cacheKey);
    } catch (e) {
      // Silently fail deletion
    }
  }

  /// Checks Hive size and evicts if needed
  Future<void> _checkAndEvictHive() async {
    try {
      final currentSize = await HiveProvider.getBoxSize();

      if (currentSize >=
          CacheConfig.hiveCacheMaxSize * CacheConfig.hiveEvictionThreshold) {
        await _evictHiveEntries();
      }
    } catch (e) {
      // Silently fail eviction check
    }
  }

  /// Evicts oldest 20% of Hive entries
  Future<void> _evictHiveEntries() async {
    try {
      final box = await HiveProvider.getBox();
      final entries = box.values.toList();

      // Sort by lastAccessed (LRU)
      entries.sort((a, b) => a.lastAccessed.compareTo(b.lastAccessed));

      // Delete oldest 20%
      final deleteCount = (entries.length * CacheConfig.evictionPercentage)
          .toInt();
      for (int i = 0; i < deleteCount && i < entries.length; i++) {
        await box.delete(entries[i].key);
      }

      // Compact box
      await HiveProvider.compact();
    } catch (e) {
      // Silently fail eviction
    }
  }

  /// Clears all cache (Memory + Hive)
  Future<void> clearAll() async {
    _memoryCache.clear();
    await HiveProvider.clearAll();
    _corruptionTracker.clear();
    _consecutiveWriteFailures = 0;
    _isHiveDisabled = false;
  }

  /// Gets cache statistics
  Map<String, dynamic> getStats() {
    return {
      'memory': _memoryCache.getStats(),
      'hiveDisabled': _isHiveDisabled,
      'activeRequests': _requestPool.activeRequestCount,
      'consecutiveWriteFailures': _consecutiveWriteFailures,
    };
  }
}
