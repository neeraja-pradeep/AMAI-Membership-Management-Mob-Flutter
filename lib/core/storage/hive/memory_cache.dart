import 'cache_config.dart';
import 'cache_entry.dart';

/// In-memory cache (L1) with LRU (Least Recently Used) eviction
///
/// Limits:
/// - Maximum entries: 500
/// - Maximum size: 50MB
///
/// Eviction strategy: Remove least recently used entries when limits exceeded
class MemoryCache {
  /// Cache storage: key → CacheEntry
  final Map<String, CacheEntry> _cache = {};

  /// Current total size of cached data in bytes
  int _currentSize = 0;

  /// Gets a value from memory cache
  /// Returns null if not found
  /// Updates access timestamp and count
  CacheEntry? get(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    // Update access metadata (LRU tracking)
    final updatedEntry = entry.copyWithAccess();
    _cache[key] = updatedEntry;

    return updatedEntry;
  }

  /// Puts a value into memory cache
  /// Triggers eviction if limits exceeded
  void put(CacheEntry entry) {
    // Remove old entry if exists (to update size correctly)
    if (_cache.containsKey(entry.key)) {
      final oldEntry = _cache[entry.key]!;
      _currentSize -= oldEntry.size;
    }

    // Add new entry
    _cache[entry.key] = entry;
    _currentSize += entry.size;

    // Check if eviction needed
    _evictIfNeeded();
  }

  /// Removes a specific entry from cache
  void remove(String key) {
    final entry = _cache.remove(key);
    if (entry != null) {
      _currentSize -= entry.size;
    }
  }

  /// Clears all entries from memory cache
  void clear() {
    _cache.clear();
    _currentSize = 0;
  }

  /// Checks if a key exists in cache
  bool containsKey(String key) {
    return _cache.containsKey(key);
  }

  /// Gets all cache keys
  List<String> get keys => _cache.keys.toList();

  /// Gets number of entries in cache
  int get entryCount => _cache.length;

  /// Gets current total size in bytes
  int get currentSize => _currentSize;

  /// Gets current size in megabytes
  double get currentSizeMB => _currentSize / (1024 * 1024);

  /// Checks if cache is full
  bool get isFull {
    return entryCount >= CacheConfig.memoryCacheMaxEntries ||
        _currentSize >= CacheConfig.memoryCacheMaxSize;
  }

  /// Evicts entries if limits exceeded
  void _evictIfNeeded() {
    while (entryCount > CacheConfig.memoryCacheMaxEntries ||
        _currentSize > CacheConfig.memoryCacheMaxSize) {
      _evictLruEntry();
    }
  }

  /// Evicts the least recently used entry
  void _evictLruEntry() {
    if (_cache.isEmpty) return;

    // Find entry with oldest lastAccessed timestamp
    String? lruKey;
    int oldestAccess = DateTime.now().millisecondsSinceEpoch;

    for (final entry in _cache.entries) {
      if (entry.value.lastAccessed < oldestAccess) {
        oldestAccess = entry.value.lastAccessed;
        lruKey = entry.key;
      }
    }

    // Remove LRU entry
    if (lruKey != null) {
      remove(lruKey);
    }
  }

  /// Gets cache statistics for monitoring
  Map<String, dynamic> getStats() {
    return {
      'entryCount': entryCount,
      'currentSizeMB': currentSizeMB.toStringAsFixed(2),
      'maxEntries': CacheConfig.memoryCacheMaxEntries,
      'maxSizeMB': (CacheConfig.memoryCacheMaxSize / (1024 * 1024))
          .toStringAsFixed(2),
      'utilizationPercent':
          ((entryCount / CacheConfig.memoryCacheMaxEntries) * 100)
              .toStringAsFixed(1),
    };
  }
}
