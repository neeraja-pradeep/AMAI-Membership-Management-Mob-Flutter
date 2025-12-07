import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/auth_exception.dart';
import '../../infrastructure/repositories/auth_repository_provider.dart';
import '../states/forgot_password_state.dart';

/// Forgot password state notifier
///
/// Manages the forgot password flow:
/// 1. Send OTP to phone number
/// 2. Verify OTP and reset password
class ForgotPasswordNotifier extends StateNotifier<ForgotPasswordState> {
  final Ref _ref;

  ForgotPasswordNotifier(this._ref) : super(const ForgotPasswordInitial());

  /// Send OTP to phone number
  ///
  /// POST /api/accounts/send-otp/
  /// Payload: { "phone_number": "+919497883832" }
  Future<void> sendOtp({required String phoneNumber}) async {
    state = const ForgotPasswordLoading();

    try {
      final repo = _ref.read(authRepositoryProvider);
      final success = await repo.sendOtp(phoneNumber: phoneNumber);

      if (success) {
        state = ForgotPasswordOtpSent(phoneNumber: phoneNumber);
      } else {
        state = const ForgotPasswordError(
          message: 'Failed to send OTP. Please try again.',
        );
      }
    } on AuthException catch (e) {
      state = ForgotPasswordError(message: e.message);
    } catch (e) {
      state = ForgotPasswordError(message: e.toString());
    }
  }

  /// Verify OTP
  ///
  /// POST /api/accounts/verify-otp/
  /// Payload: { "phone_number": "+919497883832", "otp_code": "123456" }
  Future<bool> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    state = const ForgotPasswordLoading();

    try {
      final repo = _ref.read(authRepositoryProvider);
      final success = await repo.verifyOtp(
        phoneNumber: phoneNumber,
        otpCode: otpCode,
      );

      if (success) {
        state = ForgotPasswordOtpVerified(
          phoneNumber: phoneNumber,
          otpCode: otpCode,
        );
        return true;
      } else {
        state = const ForgotPasswordError(
          message: 'Invalid OTP. Please try again.',
        );
        return false;
      }
    } on AuthException catch (e) {
      state = ForgotPasswordError(message: e.message);
      return false;
    } catch (e) {
      state = ForgotPasswordError(message: e.toString());
      return false;
    }
  }

  /// Reset password after OTP verification
  ///
  /// POST /api/accounts/reset-password/
  /// Payload: { "new_password": "newpassword123" }
  Future<void> resetPassword({required String newPassword}) async {
    state = const ForgotPasswordLoading();

    try {
      final repo = _ref.read(authRepositoryProvider);
      final success = await repo.resetPassword(newPassword: newPassword);

      if (success) {
        state = const ForgotPasswordSuccess();
      } else {
        state = const ForgotPasswordError(
          message: 'Failed to reset password. Please try again.',
        );
      }
    } on AuthException catch (e) {
      state = ForgotPasswordError(message: e.message);
    } catch (e) {
      state = ForgotPasswordError(message: e.toString());
    }
  }

  /// Reset state to initial
  void reset() {
    state = const ForgotPasswordInitial();
  }
}

/// Forgot password provider
final forgotPasswordProvider =
    StateNotifierProvider<ForgotPasswordNotifier, ForgotPasswordState>((ref) {
  return ForgotPasswordNotifier(ref);
});
