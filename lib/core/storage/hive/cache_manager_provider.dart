import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cache_manager.dart';

/// Global CacheManager provider (singleton)
///
/// Usage in repositories:
/// ```dart
/// final cacheManager = ref.read(cacheManagerProvider);
/// ```
final cacheManagerProvider = Provider<CacheManager>((ref) {
  return CacheManager();
});

/// Auto-dispose cache manager for feature-specific caching
///
/// Use this when cache should be cleared when the feature is disposed
final autoDisposeCacheManagerProvider = Provider.autoDispose<CacheManager>((ref) {
  final cacheManager = CacheManager();

  // Cleanup on dispose
  ref.onDispose(() {
    cacheManager.clearAll();
  });

  return cacheManager;
});
