import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/app/theme/typography.dart';

/// Individual quick action item widget
/// Displays an icon with a label, tappable for navigation
class QuickActionItem extends StatelessWidget {
  const QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
    this.iconColor,
    this.backgroundColor,
  });

  /// Icon to display
  final IconData icon;

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
      child: Container(
        width: 80.w,
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
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow.withOpacity(0.05),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 28.sp,
        color: iconColor ?? AppColors.primary,
      ),
    );
  }

  /// Builds the label text
  Widget _buildLabel() {
    return Text(
      label,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.labelSmall.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
