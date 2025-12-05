import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/app/theme/typography.dart';

/// Individual quick action item widget
/// Displays an icon with a label, tappable for navigation
class QuickActionItem extends StatelessWidget {
  const QuickActionItem({
    required this.svgAsset,
    required this.label,
    required this.onTap,
    super.key,
    this.iconColor,
    this.backgroundColor,
  });

  /// SVG asset path to display
  final String svgAsset;

  /// Label text below the icon
  final String label;

  /// Callback when item is tapped
  final VoidCallback onTap;

  /// Custom icon color (optional)
  final Color? iconColor;

  /// Custom background color for icon container (optional)
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIconContainer(),
            SizedBox(height: 8.h),
            _buildLabel(),
          ],
        ),
      ),
    );
  }

  /// Builds the circular icon container
  Widget _buildIconContainer() {
    return Container(
      width: 56.w,
      height: 56.h,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(50.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow.withOpacity(0.05),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Center(
        child: SvgPicture.asset(
          svgAsset,
          width: 26.w,
          height: 26.h,
          colorFilter: ColorFilter.mode(
            iconColor ?? AppColors.primary,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  /// Builds the label text
  Widget _buildLabel() {
    return Text(
      label,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.labelSmall.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w400,
        fontSize: 16.sp,
      ),
    );
  }
}
