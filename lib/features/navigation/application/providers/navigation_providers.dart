import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for managing the current tab index in MainNavigationScreen
/// Allows child screens to trigger tab changes programmatically
final currentTabIndexProvider = StateProvider<int>((ref) => 0);
