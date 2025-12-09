import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myapp/app/theme/colors.dart';

import '../../application/providers/forgot_password_provider.dart';

/// Password Reset Success Dialog
///
/// Displayed after successful password reset
/// Shows a centered container with success message
class PasswordResetSuccessDialog extends ConsumerWidget {
  const PasswordResetSuccessDialog({super.key});

  void _navigateToLogin(BuildContext context, WidgetRef ref) {
    // Reset the forgot password provider state
    ref.read(forgotPasswordProvider.notifier).reset();
    // Pop until we reach the login screen
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success title
            Text(
              'Password Reset Successfully',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            SizedBox(height: 8.h),

            // Success message
            Text(
              'You can now log in with your new password',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),

            SizedBox(height: 24.h),

            // Success icon
            SvgPicture.asset(
              'assets/svg/sucess.svg',
              width: 80.w,
              height: 80.w,
            ),

            SizedBox(height: 32.h),

            // Back to Login button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () => _navigateToLogin(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Back to Login',
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
    );
  }
}
