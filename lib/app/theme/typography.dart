import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';

/// App typography styles for AMAI application
/// All font sizes use .sp for responsive scaling
class AppTypography {
  AppTypography._();

  // ============== Display Styles ==============
  static TextStyle get displayLarge => TextStyle(
        fontSize: 57.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: AppColors.textPrimary,
      );

  static TextStyle get displayMedium => TextStyle(
        fontSize: 45.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get displaySmall => TextStyle(
        fontSize: 36.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  // ============== Headline Styles ==============
  static TextStyle get headlineLarge => TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineMedium => TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineSmall => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  // ============== Title Styles ==============
  static TextStyle get titleLarge => TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleMedium => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleSmall => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: AppColors.textPrimary,
      );

  // ============== Body Styles ==============
  static TextStyle get bodyLarge => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: AppColors.textSecondary,
      );

  // ============== Label Styles ==============
  static TextStyle get labelLarge => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelMedium => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelSmall => TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: AppColors.textSecondary,
      );

  // ============== Button Styles ==============
  static TextStyle get buttonLarge => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: AppColors.textOnPrimary,
      );

  static TextStyle get buttonMedium => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: AppColors.textOnPrimary,
      );

  static TextStyle get buttonSmall => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: AppColors.textOnPrimary,
      );

  // ============== Caption Styles ==============
  static TextStyle get caption => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: AppColors.textSecondary,
      );

  static TextStyle get overline => TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
        color: AppColors.textSecondary,
      );
}
