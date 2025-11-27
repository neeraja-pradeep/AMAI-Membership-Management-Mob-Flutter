import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'cache_entry.dart';

/// Thread-safe Hive box provider
///
/// Ensures single Hive instance across the app
/// Prevents concurrent access issues
class HiveProvider {
  static Box<CacheEntry>? _box;
  static final _lock = _AsyncLock();
  static bool _isInitialized = false;

  /// Gets or opens the cache box (thread-safe)
  static Future<Box<CacheEntry>> getBox() async {
    return await _lock.synchronized(() async {
      if (_box != null && _box!.isOpen) {
        return _box!;
      }

      _box = await Hive.openBox<CacheEntry>('cache');
      return _box!;
    });
  }

  /// Initializes Hive (call once at app startup)
  static Future<void> initialize() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    // Register CacheEntry adapter
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CacheEntryAdapter());
    }

    _isInitialized = true;
  }

  /// Closes the cache box
  static Future<void> close() async {
    await _lock.synchronized(() async {
      if (_box != null && _box!.isOpen) {
        await _box!.close();
        _box = null;
      }
    });
  }

  /// Deletes all data in the cache box
  static Future<void> clearAll() async {
    final box = await getBox();
    await box.clear();
  }

  /// Compacts the Hive box to reclaim space
  static Future<void> compact() async {
    final box = await getBox();
    await box.compact();
  }

  /// Gets the size of the Hive box in bytes
  static Future<int> getBoxSize() async {
    final box = await getBox();
    int totalSize = 0;

    for (final entry in box.values) {
      totalSize += entry.size;
    }

    return totalSize;
  }

  /// Checks if Hive is initialized
  static bool get isInitialized => _isInitialized;
}

/// Simple async lock implementation for Dart
class _AsyncLock {
  Completer<void>? _completer;

  /// Executes a function with exclusive access
  Future<T> synchronized<T>(Future<T> Function() func) async {
    // Wait for any existing operation to complete
    while (_completer != null) {
      await _completer!.future;
    }

    // Acquire lock
    _completer = Completer<void>();

    try {
      // Execute the function
      final result = await func();
      return result;
    } finally {
      // Release lock
      final completer = _completer;
      _completer = null;
      completer?.complete();
    }
  }
}
