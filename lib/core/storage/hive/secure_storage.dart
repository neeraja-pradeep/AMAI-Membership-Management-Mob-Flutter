import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'dart:typed_data';

/// Secure storage for Hive encryption keys
///
/// SECURITY REQUIREMENTS:
/// - Session tokens encrypted in Hive (using HiveAES encryption)
/// - XCSRF token encrypted in Hive
/// - Encryption keys stored in Flutter Secure Storage (OS keychain)
class SecureHiveStorage {
  static const String _encryptionKeyName = 'hive_encryption_key';
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Get or generate encryption key for Hive
  ///
  /// The key is stored in the OS keychain via flutter_secure_storage:
  /// - iOS: Keychain
  /// - Android: EncryptedSharedPreferences
  static Future<List<int>> getEncryptionKey() async {
    // Try to read existing key
    final existingKey = await _secureStorage.read(key: _encryptionKeyName);

    if (existingKey != null) {
      // Decode existing key
      return base64Decode(existingKey);
    }

    // Generate new 256-bit encryption key
    final newKey = Hive.generateSecureKey();

    // Store key in secure storage
    await _secureStorage.write(
      key: _encryptionKeyName,
      value: base64Encode(newKey),
    );

    return newKey;
  }

  /// Open encrypted Hive box
  ///
  /// SECURITY: All sensitive data (session, XCSRF token) stored encrypted
  static Future<Box<T>> openEncryptedBox<T>(String boxName) async {
    final encryptionKey = await getEncryptionKey();

    return await Hive.openBox<T>(
      boxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  /// Clear encryption key (use on logout/uninstall)
  ///
  /// WARNING: This will make all encrypted boxes unreadable
  static Future<void> clearEncryptionKey() async {
    await _secureStorage.delete(key: _encryptionKeyName);
  }

  /// Check if encryption key exists
  static Future<bool> hasEncryptionKey() async {
    final key = await _secureStorage.read(key: _encryptionKeyName);
    return key != null;
  }
}
