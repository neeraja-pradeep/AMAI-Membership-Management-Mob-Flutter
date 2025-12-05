import '../entities/session.dart';
import '../entities/user.dart';
import '../entities/user_role.dart';

/// Authentication repository interface (domain layer)
///
/// Defines the contract for all authentication operations
abstract class AuthRepository {
  /// Login with email and password
  ///
  /// Returns User and Session on success
  /// Throws exception on failure
  Future<bool> login({required String email, required String password});

  /// Register with selected role (Phase 1)
  ///
  /// Returns success status
  /// Throws exception on failure
  Future<bool> registerWithRole({required UserRole role});

  /// Get current session from cache
  ///
  /// Returns null if no session exists or session expired
  Future<Session?> getCurrentSession();

  /// Get current user from cache
  ///
  /// Returns null if no user cached
  Future<User?> getCurrentUser();

  /// Check if user is authenticated
  ///
  /// Returns true if valid session exists
  Future<bool> isAuthenticated();

  /// Logout current user
  ///
  /// Clears all session data and cache
  Future<void> logout();

  /// Refresh session if expiring soon
  ///
  /// Returns new session on success
  /// Throws exception on failure
  Future<Session> refreshSession();

  /// Clear all auth cache
  ///
  /// Removes all cached auth data
  Future<void> clearCache();

  /// Send OTP for forgot password
  ///
  /// Sends OTP to the provided phone number
  /// Returns true on success
  Future<bool> sendOtp({required String phoneNumber});

  /// Verify OTP and reset password
  ///
  /// Verifies OTP and sets new password
  /// Returns true on success
  Future<bool> verifyOtpAndResetPassword({
    required String phoneNumber,
    required String otpCode,
    required String newPassword,
  });
}
