/// Hive box key constants
///
/// Keys used to store/retrieve specific values within Hive boxes
class HiveKeys {
  HiveKeys._();

  // Auth Box Keys
  /// Access token key
  static const String accessToken = 'access_token';

  /// Refresh token key
  static const String refreshToken = 'refresh_token';

  /// User ID key
  static const String userId = 'user_id';

  /// Last login timestamp
  static const String lastLogin = 'last_login';

  // Settings Box Keys
  /// Theme mode (light/dark)
  static const String themeMode = 'theme_mode';

  /// App language code
  static const String languageCode = 'language_code';

  /// Notification enabled flag
  static const String notificationsEnabled = 'notifications_enabled';
}
