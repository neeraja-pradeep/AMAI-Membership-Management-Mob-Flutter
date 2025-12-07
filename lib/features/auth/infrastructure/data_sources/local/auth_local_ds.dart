import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import '../../../../../core/storage/hive/boxes.dart';
import '../../../../../core/storage/hive/keys.dart';
import '../../../../../core/storage/hive/secure_storage.dart';
import '../../models/session_model.dart';
import '../../models/user_model.dart';

/// Auth local data source (Hive layer)
///
/// SECURITY REQUIREMENTS IMPLEMENTED:
/// - Session tokens encrypted in Hive (HiveAES encryption)
/// - XCSRF token encrypted in Hive
/// - Passwords never stored (not even encrypted)
/// - Encryption keys stored in OS keychain (flutter_secure_storage)
///
/// Handles storing and retrieving authentication data from encrypted Hive
class AuthLocalDs {
  /// Save user to Hive (ENCRYPTED)
  ///
  /// User data includes sensitive information (email, name, role)
  Future<void> saveUser(UserModel user) async {
    final box = await SecureHiveStorage.openEncryptedBox(HiveBoxes.authBox);
    await box.put('user', user.toJson());
  }

  /// Get user from Hive (ENCRYPTED)
  Future<UserModel?> getUser() async {
    final box = await SecureHiveStorage.openEncryptedBox(HiveBoxes.authBox);
    final userData = box.get('user') as Map<dynamic, dynamic>?;

    if (userData == null) return null;

    return UserModel.fromJson(
      Map<String, dynamic>.from(userData),
    );
  }

  /// Save session to Hive (ENCRYPTED)
  ///
  /// SECURITY: Session contains XCSRF token (encrypted)
  /// Session ID is stored in HTTP-only cookies (via Dio), not in Hive
  Future<void> saveSession(SessionModel session) async {
    final box = await SecureHiveStorage.openEncryptedBox(HiveBoxes.authBox);
    await box.put('session', session.toJson());
  }

  /// Get session from Hive (ENCRYPTED)
  Future<SessionModel?> getSession() async {
    final box = await SecureHiveStorage.openEncryptedBox(HiveBoxes.authBox);
    final sessionData = box.get('session') as Map<dynamic, dynamic>?;

    if (sessionData == null) return null;

    return SessionModel.fromJson(
      Map<String, dynamic>.from(sessionData),
    );
  }

  /// Save access token (ENCRYPTED)
  ///
  /// SECURITY: XCSRF token encrypted with HiveAES
  Future<void> saveAccessToken(String token) async {
    final box = await SecureHiveStorage.openEncryptedBox(HiveBoxes.authBox);
    await box.put(HiveKeys.accessToken, token);
  }

  /// Get access token (ENCRYPTED)
  Future<String?> getAccessToken() async {
    final box = await SecureHiveStorage.openEncryptedBox(HiveBoxes.authBox);
    return box.get(HiveKeys.accessToken) as String?;
  }

  /// Save refresh token (ENCRYPTED)
  Future<void> saveRefreshToken(String token) async {
    final box = await SecureHiveStorage.openEncryptedBox(HiveBoxes.authBox);
    await box.put(HiveKeys.refreshToken, token);
  }

  /// Get refresh token (ENCRYPTED)
  Future<String?> getRefreshToken() async {
    final box = await SecureHiveStorage.openEncryptedBox(HiveBoxes.authBox);
    return box.get(HiveKeys.refreshToken) as String?;
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final session = await getSession();
    if (session == null) return false;

    // Check if session is expired
    final expiresAt = DateTime.parse(session.expiresAt);
    return DateTime.now().isBefore(expiresAt);
  }

  /// Clear all auth data (ENCRYPTED BOX)
  ///
  /// SECURITY: Clears all encrypted data on logout
  Future<void> clearAll() async {
    final box = await SecureHiveStorage.openEncryptedBox(HiveBoxes.authBox);
    await box.clear();
  }

  /// Delete user (ENCRYPTED BOX)
  Future<void> deleteUser() async {
    final box = await SecureHiveStorage.openEncryptedBox(HiveBoxes.authBox);
    await box.delete('user');
  }

  /// Delete session (ENCRYPTED BOX)
  ///
  /// SECURITY: Deletes encrypted session data (XCSRF token)
  /// Session cookies are cleared separately via ApiClient
  Future<void> deleteSession() async {
    final box = await SecureHiveStorage.openEncryptedBox(HiveBoxes.authBox);
    await box.delete('session');
  }

  // ============== REMEMBER ME (Secure Storage) ==============

  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _rememberEmailKey = 'remember_me_email';
  static const _rememberPasswordKey = 'remember_me_password';

  /// Save credentials for "Remember Me" (OS-level encryption)
  ///
  /// SECURITY: Uses flutter_secure_storage which stores in:
  /// - iOS: Keychain (hardware-encrypted)
  /// - Android: EncryptedSharedPreferences (AES encryption)
  Future<void> saveRememberMeCredentials({
    required String email,
    required String password,
  }) async {
    await _secureStorage.write(key: _rememberEmailKey, value: email);
    await _secureStorage.write(key: _rememberPasswordKey, value: password);
  }

  /// Get saved "Remember Me" credentials
  ///
  /// Returns null values if no credentials saved
  Future<({String? email, String? password})> getRememberMeCredentials() async {
    final email = await _secureStorage.read(key: _rememberEmailKey);
    final password = await _secureStorage.read(key: _rememberPasswordKey);
    return (email: email, password: password);
  }

  /// Clear "Remember Me" credentials
  ///
  /// Called when user unchecks "Remember Me" or logs out
  Future<void> clearRememberMeCredentials() async {
    await _secureStorage.delete(key: _rememberEmailKey);
    await _secureStorage.delete(key: _rememberPasswordKey);
  }

  /// Check if "Remember Me" credentials exist
  Future<bool> hasRememberMeCredentials() async {
    final email = await _secureStorage.read(key: _rememberEmailKey);
    return email != null && email.isNotEmpty;
  }
}
