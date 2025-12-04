import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/app/theme/typography.dart';
import 'package:myapp/features/home/domain/entities/aswas_plus.dart';
import 'package:myapp/features/home/presentation/components/status_badge.dart';

/// Widget displaying the Aswas Plus insurance card on homescreen
/// Shows policy details with gradient background and status badge
class AswasCardWidget extends StatelessWidget {
  const AswasCardWidget({required this.aswasPlus, super.key, this.onTap});

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
          color: AppColors.white,

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
              SizedBox(height: 8.h),
              _buildValidity(),
              SizedBox(height: 40.h),
              _buildActionButtons(),
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
            Text(
              'Aswas Plus Insurance',
              style: TextStyle(
                fontSize: 18.sp,
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
          isPending: aswasPlus.isPending,
        ),
      ],
    );
  }

  /// Builds the policy number section (inline)
  Widget _buildPolicyNumber() {
    return Row(
      children: [
        Text(
          'Policy No : ',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.aswasCardText.withOpacity(0.7),
            letterSpacing: 0.5,
          ),
        ),
        Text(
          aswasPlus.policyNumber,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.aswasCardText,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  /// Builds the validity section (inline)
  Widget _buildValidity() {
    return Row(
      children: [
        Text(
          'Valid Until : ',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.aswasCardText.withOpacity(0.7),
            letterSpacing: 0.5,
          ),
        ),
        Text(
          aswasPlus.displayValidUntil,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.aswasCardText,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  /// Builds the action buttons row
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: AswasCardButton(
            label: 'Renew Policy',
            svgAsset: 'assets/svg/renew.svg',
            isFilled: true,
            onTap: () {
              // TODO: Navigate to renew policy
            },
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: AswasCardButton(
            label: 'View Details',
            svgAsset: 'assets/svg/details.svg',
            isFilled: false,
            onTap: onTap,
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
    this.isPending = false,
    super.key,
  });

  final bool isActive;
  final bool isExpired;
  final bool isExpiringSoon;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String text;

    if (isExpired) {
      backgroundColor = AppColors.expiredBadge;
      textColor = AppColors.expiredBadgeText;
      text = 'Expired';
    } else if (isExpiringSoon) {
      backgroundColor = AppColors.expiringSoonBadge;
      textColor = AppColors.expiringSoonBadgeText;
      text = 'Expiring Soon';
    } else if (isActive) {
      backgroundColor = AppColors.activeBadge;
      textColor = AppColors.activeBadgeText;
      text = 'Active';
    } else if (isPending) {
      backgroundColor = AppColors.pendingBadge;
      textColor = AppColors.pendingBadgeText;
      text = 'Pending';
    } else {
      backgroundColor = AppColors.inactiveBadge;
      textColor = AppColors.inactiveBadgeText;
      text = 'Inactive';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Reusable button widget for Aswas Plus card
/// Supports filled and outlined variants
class AswasCardButton extends StatelessWidget {
  const AswasCardButton({
    required this.label,
    required this.svgAsset,
    required this.isFilled,
    super.key,
    this.onTap,
  });

  /// Button label text
  final String label;

  /// SVG asset path for the icon
  final String svgAsset;

  /// Whether the button is filled (true) or outlined (false)
  final bool isFilled;

  /// Callback when button is tapped
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isFilled ? AppColors.aswasCardText : Colors.transparent,
          border: isFilled
              ? null
              : Border.all(color: AppColors.aswasCardText, width: 1),
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              svgAsset,
              width: 20.w,
              height: 20.h,
              colorFilter: ColorFilter.mode(
                isFilled ? AppColors.white : AppColors.aswasCardText,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isFilled ? AppColors.white : AppColors.aswasCardText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
