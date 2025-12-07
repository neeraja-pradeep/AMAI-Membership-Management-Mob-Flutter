import '../entities/session.dart';
import '../entities/user.dart';
import '../entities/user_role.dart';

/// Authentication repository interface (domain layer)
///
/// Defines the contract for all authentication operations
abstract class AuthRepository {
  /// Login with email and password
  ///
  /// Returns user ID on success, null if user data not in response
  /// If rememberMe is true, saves credentials securely for auto-fill
  /// Throws exception on failure
  Future<int?> login({
    required String email,
    required String password,
    bool rememberMe = false,
  });

  /// Get saved "Remember Me" credentials
  ///
  /// Returns email and password if saved, null otherwise
  Future<({String? email, String? password})> getRememberMeCredentials();

  /// Clear "Remember Me" credentials
  Future<void> clearRememberMeCredentials();

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

  /// Verify OTP for forgot password
  ///
  /// Verifies OTP before allowing password reset
  /// Returns true on success
  Future<bool> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  });

  /// Reset password after OTP verification
  ///
  /// Resets password after successful OTP verification
  /// Returns true on success
  Future<bool> resetPassword({required String newPassword});
}
