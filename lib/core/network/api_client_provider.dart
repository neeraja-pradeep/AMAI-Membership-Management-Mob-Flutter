import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

/// Global API client provider (singleton)
///
/// Usage:
/// ```dart
/// final apiClient = ref.watch(apiClientProvider);
/// ```
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});
