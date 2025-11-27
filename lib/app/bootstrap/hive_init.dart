import 'package:hive_flutter/hive_flutter.dart';
import '../../core/storage/hive/cache_entry.dart';
import '../../core/storage/hive/hive_provider.dart';

/// Initializes Hive storage system
///
/// Call this once at app startup in main.dart:
/// ```dart
/// await HiveInit.initialize();
/// ```
class HiveInit {
  HiveInit._();

  static bool _isInitialized = false;

  /// Initializes Hive and registers all type adapters
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize Hive Flutter
    await Hive.initFlutter();

    // Register all type adapters
    _registerAdapters();

    // Initialize HiveProvider
    await HiveProvider.initialize();

    _isInitialized = true;
  }

  /// Registers all Hive type adapters
  static void _registerAdapters() {
    // Register CacheEntry adapter (typeId: 1)
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CacheEntryAdapter());
    }

    // TODO: Register other adapters as needed
    // Example:
    // if (!Hive.isAdapterRegistered(2)) {
    //   Hive.registerAdapter(UserAdapter());
    // }
  }

  /// Closes all Hive boxes
  static Future<void> close() async {
    await HiveProvider.close();
    await Hive.close();
  }

  /// Deletes all Hive data (useful for logout)
  static Future<void> deleteAllData() async {
    await Hive.deleteFromDisk();
  }
}
