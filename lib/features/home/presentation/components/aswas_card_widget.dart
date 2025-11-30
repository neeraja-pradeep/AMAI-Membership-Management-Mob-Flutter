import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/app/theme/typography.dart';
import 'package:myapp/features/home/domain/entities/aswas_plus.dart';
import 'package:myapp/features/home/presentation/components/status_badge.dart';

/// Widget displaying the Aswas Plus insurance card on homescreen
/// Shows policy details with gradient background and status badge
class AswasCardWidget extends StatelessWidget {
  const AswasCardWidget({
    required this.aswasPlus,
    super.key,
    this.onTap,
  });

  /// Aswas Plus data to display
  final AswasPlus aswasPlus;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.aswasCardGradientStart,
              AppColors.aswasCardGradientEnd,
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 16.h),
              _buildPolicyNumber(),
              SizedBox(height: 16.h),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the card header with title and status badge
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.shield_outlined,
              color: AppColors.aswasCardAccent,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'ASWAS PLUS',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.aswasCardText.withOpacity(0.9),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        AswasStatusBadge(
          isActive: aswasPlus.isActive,
          isExpired: aswasPlus.isExpired,
          isExpiringSoon: aswasPlus.isExpiringSoon,
        ),
      ],
    );
  }

  /// Builds the policy number section
  Widget _buildPolicyNumber() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Policy Number',
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.aswasCardText.withOpacity(0.7),
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          aswasPlus.policyNumber,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.aswasCardText,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  /// Builds the footer with validity
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildInfoColumn(
          label: 'Valid Till',
          value: aswasPlus.displayValidUntil,
          crossAxisAlignment: CrossAxisAlignment.end,
        ),
      ],
    );
  }

  /// Builds an info column with label and value
  Widget _buildInfoColumn({
    required String label,
    required String value,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  }) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.aswasCardText.withOpacity(0.7),
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.aswasCardText,
          ),
        ),
      ],
    );
  }
}

/// Shimmer loading placeholder for Aswas Plus card
class AswasCardShimmer extends StatelessWidget {
  const AswasCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _shimmerBox(width: 120.w, height: 14.h),
                _shimmerBox(width: 60.w, height: 20.h),
              ],
            ),
            SizedBox(height: 20.h),
            _shimmerBox(width: 80.w, height: 10.h),
            SizedBox(height: 4.h),
            _shimmerBox(width: 180.w, height: 22.h),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(width: 60.w, height: 10.h),
                    SizedBox(height: 4.h),
                    _shimmerBox(width: 100.w, height: 16.h),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _shimmerBox(width: 60.w, height: 10.h),
                    SizedBox(height: 4.h),
                    _shimmerBox(width: 100.w, height: 16.h),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.grey300,
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}

/// Status badge specifically for Aswas Plus card
class AswasStatusBadge extends StatelessWidget {
  const AswasStatusBadge({
    required this.isActive,
    required this.isExpired,
    required this.isExpiringSoon,
    super.key,
  });

  final bool isActive;
  final bool isExpired;
  final bool isExpiringSoon;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String text;

    if (isExpired) {
      backgroundColor = AppColors.expiredBadge;
      textColor = AppColors.expiredBadgeText;
      text = 'EXPIRED';
    } else if (isExpiringSoon) {
      backgroundColor = AppColors.expiringSoonBadge;
      textColor = AppColors.expiringSoonBadgeText;
      text = 'EXPIRING SOON';
    } else if (isActive) {
      backgroundColor = AppColors.activeBadge;
      textColor = AppColors.activeBadgeText;
      text = 'ACTIVE';
    } else {
      backgroundColor = AppColors.inactiveBadge;
      textColor = AppColors.inactiveBadgeText;
      text = 'INACTIVE';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
