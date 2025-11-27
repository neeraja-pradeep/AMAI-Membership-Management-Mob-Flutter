# HIVE Cache Architecture - Setup & Usage Guide

## 📋 Overview

This project implements a **production-ready 3-layer cache system** as specified in `docs/HIVE implementation.md`:

- **Layer 1 (L1)**: Memory Cache - LRU, 50MB max, 500 entries max
- **Layer 2 (L2)**: Hive Cache - LRU, 200MB max, auto-eviction at 90%
- **Layer 3 (L3)**: Network - API with conditional requests (HTTP 304)

## 🏗️ Architecture Components

### Core Files Created

```
lib/core/storage/hive/
├── cache_config.dart          # Configuration constants
├── cache_entry.dart            # Hive model with @HiveType
├── cache_entry.g.dart          # Generated adapter (after build_runner)
├── cache_manager.dart          # Main orchestrator (L1 → L2 → L3)
├── cache_utils.dart            # SHA256 key generation & helpers
├── hive_provider.dart          # Thread-safe Hive operations
├── memory_cache.dart           # L1 cache with LRU eviction
├── request_pool.dart           # Request deduplication
├── retry_policy.dart           # Exponential backoff retry
├── boxes.dart                  # Box name constants
└── keys.dart                   # Key constants

lib/app/bootstrap/
└── hive_init.dart              # Hive initialization
```

## 🚀 Setup Instructions

### Step 1: Generate Hive Adapters

Run the build_runner to generate the `cache_entry.g.dart` file:

```bash
# Clean previous builds (optional)
flutter pub run build_runner clean

# Generate adapters
flutter pub run build_runner build --delete-conflicting-outputs
```

You should see output like:
```
[INFO] Generating build script completed, took 2.1s
[INFO] Building new asset graph completed, took 1.3s
[INFO] Succeeded after 2.5s with 2 outputs
```

### Step 2: Initialize Hive in main.dart

Update your `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/bootstrap/hive_init.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await HiveInit.initialize();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AMAI',
      home: HomeScreen(),
    );
  }
}
```

### Step 3: Create a Riverpod Provider for CacheManager

Create `lib/core/storage/hive/cache_manager_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cache_manager.dart';

/// Global CacheManager provider
final cacheManagerProvider = Provider<CacheManager>((ref) {
  return CacheManager();
});
```

## 📖 Usage Examples

### Example 1: Basic API Call with Cache

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/storage/hive/cache_manager.dart';
import '../../core/storage/hive/cache_manager_provider.dart';
import '../../core/storage/hive/cache_utils.dart';

class UserRepository {
  final CacheManager _cacheManager;
  final Dio _dio;

  UserRepository(this._cacheManager, this._dio);

  Future<User> fetchUser(int userId) async {
    // Generate cache key
    final cacheKey = CacheUtils.generateCacheKey(
      endpoint: '/api/users/$userId',
      method: 'GET',
    );

    // Fetch with cache
    final result = await _cacheManager.get<Map<String, dynamic>>(
      cacheKey: cacheKey,
      networkFetch: () async {
        final response = await _dio.get('/api/users/$userId');
        return response.data;
      },
    );

    // Parse response
    return User.fromJson(result.data!);
  }
}

// Riverpod provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final cacheManager = ref.watch(cacheManagerProvider);
  final dio = Dio(BaseOptions(baseUrl: 'https://amai.nexogms.com'));
  return UserRepository(cacheManager, dio);
});
```

### Example 2: POST Request with Cache

```dart
Future<LoginResponse> login({
  required String email,
  required String password,
}) async {
  final cacheKey = CacheUtils.generateCacheKey(
    endpoint: '/api/accounts/login/',
    method: 'POST',
    requestBody: {'email': email, 'password': password},
  );

  final result = await _cacheManager.get<Map<String, dynamic>>(
    cacheKey: cacheKey,
    networkFetch: () async {
      final response = await _dio.post(
        '/api/accounts/login/',
        data: {
          'email': email,
          'password': password,
        },
      );
      return response.data;
    },
  );

  return LoginResponse.fromJson(result.data!);
}
```

### Example 3: Force Refresh (Skip Cache)

```dart
Future<List<Product>> refreshProducts() async {
  final cacheKey = CacheUtils.generateCacheKey(
    endpoint: '/api/products',
    method: 'GET',
  );

  final result = await _cacheManager.get<List<dynamic>>(
    cacheKey: cacheKey,
    forceRefresh: true, // Skip all cache layers
    networkFetch: () async {
      final response = await _dio.get('/api/products');
      return response.data;
    },
  );

  return result.data!.map((e) => Product.fromJson(e)).toList();
}
```

### Example 4: Handling Stale Cache

```dart
Future<void> loadDashboard() async {
  final cacheKey = CacheUtils.generateCacheKey(
    endpoint: '/api/dashboard',
    method: 'GET',
  );

  final result = await _cacheManager.get<Map<String, dynamic>>(
    cacheKey: cacheKey,
    networkFetch: () async {
      final response = await _dio.get('/api/dashboard');
      return response.data;
    },
  );

  // Check if data is stale
  if (result.isStale) {
    // Show warning banner
    showStaleCacheWarning(result.lastModified);
  }

  // Use the data anyway
  final dashboard = Dashboard.fromJson(result.data!);
  updateUI(dashboard);
}
```

### Example 5: Clear Cache on Logout

```dart
Future<void> logout() async {
  // Clear all cache
  final cacheManager = ref.read(cacheManagerProvider);
  await cacheManager.clearAll();

  // Delete all Hive data
  await HiveInit.deleteAllData();

  // Navigate to login
  context.go('/login');
}
```

## 📊 Cache Statistics

Monitor cache performance:

```dart
void printCacheStats() {
  final cacheManager = ref.read(cacheManagerProvider);
  final stats = cacheManager.getStats();

  print('Cache Statistics:');
  print('  Memory Cache: ${stats['memory']}');
  print('  Hive Disabled: ${stats['hiveDisabled']}');
  print('  Active Requests: ${stats['activeRequests']}');
}
```

## 🎯 Cache Scenarios Handled

### ✅ Cold Start (No Cache, Network Available)
1. Check Memory → Miss
2. Check Hive → Miss
3. Fetch from Network → Success
4. Save to Memory + Hive
5. Display data

### ✅ Warm Start (Valid Cache < 12h)
1. Check Memory → Miss
2. Check Hive → Hit (8h old)
3. Display cached data **immediately**
4. Fetch from Network in **background**
5. Update cache if changed (200 OK) or keep if unchanged (304)

### ✅ Offline Mode
1. Check Hive → Hit
2. Display cached data
3. Show offline indicator
4. Listen for connectivity
5. Auto-retry when online

### ✅ Stale Cache (> 24h old)
1. Display cached data with warning banner
2. Fetch from Network with retry logic
3. Update on success

### ✅ Concurrent Requests
1. Same endpoint called twice → Deduplicate
2. Share single Future between callers
3. No duplicate network calls

## 🔧 Configuration

Modify `lib/core/storage/hive/cache_config.dart` to adjust:

```dart
static const memoryCacheMaxSize = 50 * 1024 * 1024;  // 50MB
static const memoryCacheMaxEntries = 500;
static const hiveCacheMaxSize = 200 * 1024 * 1024;   // 200MB
static const staleCacheThreshold = Duration(hours: 24);
static const validCacheThreshold = Duration(hours: 12);
static const maxRetryAttempts = 4;
```

## 🐛 Troubleshooting

### Issue: "Missing adapter" error

**Solution**: Run build_runner to generate adapters:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: "Box already open" error

**Solution**: Use `HiveProvider.getBox()` instead of `Hive.openBox()` directly.

### Issue: Cache not working

**Solution**: Ensure `HiveInit.initialize()` is called in `main()` before `runApp()`.

## 📝 Notes

- **Never** use `const` with ScreenUtil extensions (`.w`, `.h`, `.sp`, `.r`)
- **Always** generate cache keys using `CacheUtils.generateCacheKey()`
- **Never** call `Hive.openBox()` directly - use `HiveProvider.getBox()`
- Cache keys are SHA256 hashes ensuring uniqueness across endpoints

## 🎉 Done!

Your HIVE cache architecture is now fully implemented and ready to use!

For questions, refer to `docs/HIVE implementation.md`.
