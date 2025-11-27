/// Hive box name constants
///
/// All box names must follow these rules:
/// - Declared as: static const String
/// - Identifier: camelCase
/// - Value: snake_case
///
/// Example: static const String userBox = 'user_box';
class HiveBoxes {
  HiveBoxes._();

  /// Cache box for storing API responses with metadata
  static const String cacheBox = 'cache';

  /// Authentication box for storing user session data
  static const String authBox = 'auth';

  /// Settings box for app preferences
  static const String settingsBox = 'settings';
}
