import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';

import '../../../application/providers/forgot_password_provider.dart';
import '../../../application/states/forgot_password_state.dart';
import 'reset_password_screen.dart';

/// OTP Verification Screen
///
/// Second step in the password reset flow
/// User enters the 6-digit OTP received on their phone
class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({required this.phoneNumber, super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isResending = false;
  bool _isVerifying = false;
  bool _canResend = false;
  int _resendTimer = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendTimer = 30;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  Future<void> _handleResendOtp() async {
    if (!_canResend || _isResending) return;

    setState(() {
      _isResending = true;
    });

    try {
      await ref
          .read(forgotPasswordProvider.notifier)
          .sendOtp(phoneNumber: widget.phoneNumber);

      if (mounted) {
        final state = ref.read(forgotPasswordProvider);
        if (state is ForgotPasswordOtpSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP sent successfully'),
              backgroundColor: Colors.white,
              contentTextStyle: TextStyle(color: Colors.black),
            ),
          );
          _startResendTimer();
        } else if (state is ForgotPasswordError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Color(0xFF60212E)),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  String get _otpValue {
    return _otpControllers.map((c) => c.text).join();
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpValue;

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete 6-digit OTP'),
          backgroundColor: Color(0xFF60212E),
        ),
      );
      return;
    }

    if (_isVerifying) return;

    setState(() {
      _isVerifying = true;
    });

    try {
      // Verify OTP with backend
      final success = await ref
          .read(forgotPasswordProvider.notifier)
          .verifyOtp(phoneNumber: widget.phoneNumber, otpCode: otp);

      if (!mounted) return;

      if (success) {
        // OTP verified - navigate to reset password screen
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
        );
      } else {
        // Show error from state
        final state = ref.read(forgotPasswordProvider);
        if (state is ForgotPasswordError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Color(0xFF60212E)),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    // Auto-submit when all fields are filled
    if (_otpValue.length == 6) {
      _handleVerifyOtp();
    }
  }

  void _onOtpKeyDown(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _otpControllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Verification',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.lightBackgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20.h),

                  // Subtitle with phone number
                  Text(
                    "We've sent a 6-digit OTP to your Phone Number.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
                  ),

                  SizedBox(height: 32.h),
                  Text(
                    "Enter OTP",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 48.w,
                        height: 48.w,
                        child: RawKeyboardListener(
                          focusNode: FocusNode(),
                          onKey: (event) => _onOtpKeyDown(index, event),
                          child: TextFormField(
                            controller: _otpControllers[index],
                            focusNode: _focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: const BorderSide(
                                  color: AppColors.brown,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 12.h,
                              ),
                            ),
                            onChanged: (value) => _onOtpChanged(index, value),
                          ),
                        ),
                      );
                    }),
                  ),

                  SizedBox(height: 32.h),

                  // Resend OTP
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive the code? ",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      TextButton(
                        onPressed: _canResend && !_isResending
                            ? _handleResendOtp
                            : null,
                        child: _isResending
                            ? SizedBox(
                                width: 16.w,
                                height: 16.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.brown,
                                  ),
                                ),
                              )
                            : Text(
                                _canResend
                                    ? 'Resend OTP'
                                    : 'Resend in ${_resendTimer}s',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: _canResend
                                      ? AppColors.brown
                                      : Colors.grey,
                                ),
                              ),
                      ),
                    ],
                  ),

                  SizedBox(height: 40.h),

                  // Verify button
                  SizedBox(
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: _isVerifying ? null : _handleVerifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        elevation: 0,
                      ),
                      child: _isVerifying
                          ? SizedBox(
                              width: 24.w,
                              height: 24.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Verify',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
