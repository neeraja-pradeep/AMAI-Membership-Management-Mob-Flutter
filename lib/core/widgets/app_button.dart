import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';

/// Button variants for AppButton
enum AppButtonVariant {
  primary,
  secondary,
  outline,
  text,
}

/// Reusable button widget with consistent styling
class AppButton extends StatelessWidget {
  const AppButton({
    required this.text,
    required this.onPressed,
    super.key,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.width,
    this.height,
  });

  /// Button text
  final String text;

  /// Callback when button is pressed
  final VoidCallback onPressed;

  /// Button variant for styling
  final AppButtonVariant variant;

  /// Whether to show loading indicator
  final bool isLoading;

  /// Whether button is disabled
  final bool isDisabled;

  /// Optional leading icon
  final IconData? icon;

  /// Optional fixed width
  final double? width;

  /// Optional fixed height
  final double? height;

  @override
  Widget build(BuildContext context) {
    final buttonHeight = height ?? 48.h;
    final isEnabled = !isDisabled && !isLoading;

    return SizedBox(
      width: width,
      height: buttonHeight,
      child: _buildButton(isEnabled),
    );
  }

  Widget _buildButton(bool isEnabled) {
    switch (variant) {
      case AppButtonVariant.primary:
        return _buildPrimaryButton(isEnabled);
      case AppButtonVariant.secondary:
        return _buildSecondaryButton(isEnabled);
      case AppButtonVariant.outline:
        return _buildOutlineButton(isEnabled);
      case AppButtonVariant.text:
        return _buildTextButton(isEnabled);
    }
  }

  Widget _buildPrimaryButton(bool isEnabled) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        disabledBackgroundColor: AppColors.grey300,
        disabledForegroundColor: AppColors.grey500,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        elevation: 0,
      ),
      child: _buildButtonContent(AppColors.textOnPrimary),
    );
  }

  Widget _buildSecondaryButton(bool isEnabled) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textOnSecondary,
        disabledBackgroundColor: AppColors.grey300,
        disabledForegroundColor: AppColors.grey500,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        elevation: 0,
      ),
      child: _buildButtonContent(AppColors.textOnSecondary),
    );
  }

  Widget _buildOutlineButton(bool isEnabled) {
    return OutlinedButton(
      onPressed: isEnabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(
          color: isEnabled ? AppColors.primary : AppColors.grey300,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
      child: _buildButtonContent(AppColors.primary),
    );
  }

  Widget _buildTextButton(bool isEnabled) {
    return TextButton(
      onPressed: isEnabled ? onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
      child: _buildButtonContent(AppColors.primary),
    );
  }

  Widget _buildButtonContent(Color textColor) {
    if (isLoading) {
      return SizedBox(
        width: 20.w,
        height: 20.h,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18.sp),
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
