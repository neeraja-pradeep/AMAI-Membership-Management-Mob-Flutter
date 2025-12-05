import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

/// Global API client singleton instance
///
/// This is initialized once in main() before runApp()
/// and shared across the entire application.
final ApiClient apiClientInstance = ApiClient();

/// Global API client provider (singleton)
///
/// Usage:
/// ```dart
/// final apiClient = ref.watch(apiClientProvider);
/// ```
///
/// IMPORTANT: Call `await apiClientInstance.initialize()` in main()
/// before runApp() to ensure cookie persistence is set up.
final apiClientProvider = Provider<ApiClient>((ref) {
  return apiClientInstance;
});
