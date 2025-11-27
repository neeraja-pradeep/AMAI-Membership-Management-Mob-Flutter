import 'package:hive/hive.dart';
import '../../../../../core/storage/hive/boxes.dart';
import '../../../../../core/storage/hive/keys.dart';
import '../../models/session_model.dart';
import '../../models/user_model.dart';

/// Auth local data source (Hive layer)
///
/// Handles storing and retrieving authentication data from Hive
class AuthLocalDs {
  /// Save user to Hive
  Future<void> saveUser(UserModel user) async {
    final box = await Hive.openBox(HiveBoxes.authBox);
    await box.put('user', user.toJson());
  }

  /// Get user from Hive
  Future<UserModel?> getUser() async {
    final box = await Hive.openBox(HiveBoxes.authBox);
    final userData = box.get('user') as Map<dynamic, dynamic>?;

    if (userData == null) return null;

    return UserModel.fromJson(
      Map<String, dynamic>.from(userData),
    );
  }

  /// Save session to Hive
  Future<void> saveSession(SessionModel session) async {
    final box = await Hive.openBox(HiveBoxes.authBox);
    await box.put('session', session.toJson());
  }

  /// Get session from Hive
  Future<SessionModel?> getSession() async {
    final box = await Hive.openBox(HiveBoxes.authBox);
    final sessionData = box.get('session') as Map<dynamic, dynamic>?;

    if (sessionData == null) return null;

    return SessionModel.fromJson(
      Map<String, dynamic>.from(sessionData),
    );
  }

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    final box = await Hive.openBox(HiveBoxes.authBox);
    await box.put(HiveKeys.accessToken, token);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    final box = await Hive.openBox(HiveBoxes.authBox);
    return box.get(HiveKeys.accessToken) as String?;
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    final box = await Hive.openBox(HiveBoxes.authBox);
    await box.put(HiveKeys.refreshToken, token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    final box = await Hive.openBox(HiveBoxes.authBox);
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

  /// Clear all auth data
  Future<void> clearAll() async {
    final box = await Hive.openBox(HiveBoxes.authBox);
    await box.clear();
  }

  /// Delete user
  Future<void> deleteUser() async {
    final box = await Hive.openBox(HiveBoxes.authBox);
    await box.delete('user');
  }

  /// Delete session
  Future<void> deleteSession() async {
    final box = await Hive.openBox(HiveBoxes.authBox);
    await box.delete('session');
  }
}
