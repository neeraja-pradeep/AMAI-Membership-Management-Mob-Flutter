/// Forgot password state
///
/// Represents the different states of the forgot password flow
sealed class ForgotPasswordState {
  const ForgotPasswordState();
}

/// Initial state
class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

/// Loading state - API call in progress
class ForgotPasswordLoading extends ForgotPasswordState {
  const ForgotPasswordLoading();
}

/// OTP sent successfully
class ForgotPasswordOtpSent extends ForgotPasswordState {
  final String phoneNumber;

  const ForgotPasswordOtpSent({required this.phoneNumber});
}

/// OTP verified successfully - ready for password reset
class ForgotPasswordOtpVerified extends ForgotPasswordState {
  final String phoneNumber;
  final String otpCode;

  const ForgotPasswordOtpVerified({
    required this.phoneNumber,
    required this.otpCode,
  });
}

/// OTP verified and password reset successful
class ForgotPasswordSuccess extends ForgotPasswordState {
  const ForgotPasswordSuccess();
}

/// Error state
class ForgotPasswordError extends ForgotPasswordState {
  final String message;

  const ForgotPasswordError({required this.message});
}
