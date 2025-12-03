import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/home/domain/entities/aswas_plus.dart';

/// Policy Details Card for ASWAS Plus screen
/// Shows policy holder info, policy number, and validity
class PolicyDetailsCard extends StatelessWidget {
  const PolicyDetailsCard({
    required this.aswasPlus,
    super.key,
  });

  /// ASWAS Plus policy data
  final AswasPlus aswasPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and status badge
          _buildHeader(),
          SizedBox(height: 20.h),

          // Policy Number (displayed without label)
          Text(
            aswasPlus.policyNumber,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),

          // Valid Until
          _buildDetailRow('Valid Until', aswasPlus.displayValidUntil),
        ],
      ),
    );
  }

  /// Builds the header with title and status badge
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Aswas plus',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  /// Builds the status badge
  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;
    String text;

    if (aswasPlus.isExpired) {
      backgroundColor = AppColors.expiredBadge;
      textColor = AppColors.expiredBadgeText;
      text = 'Expired';
    } else if (aswasPlus.isExpiringSoon) {
      backgroundColor = AppColors.expiringSoonBadge;
      textColor = AppColors.expiringSoonBadgeText;
      text = 'Expiring Soon';
    } else if (aswasPlus.isActive) {
      backgroundColor = AppColors.activeBadge;
      textColor = AppColors.activeBadgeText;
      text = 'Active';
    } else {
      backgroundColor = AppColors.inactiveBadge;
      textColor = AppColors.inactiveBadgeText;
      text = 'Inactive';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  /// Builds a detail row with label and value
  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Shimmer loading state for PolicyDetailsCard
class PolicyDetailsCardShimmer extends StatelessWidget {
  const PolicyDetailsCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header shimmer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildShimmerBox(width: 120.w, height: 20.h),
              _buildShimmerBox(width: 80.w, height: 28.h),
            ],
          ),
          SizedBox(height: 20.h),

          // Detail rows shimmer
          _buildShimmerRow(),
          SizedBox(height: 12.h),
          _buildShimmerRow(),
          SizedBox(height: 12.h),
          _buildShimmerRow(),
          SizedBox(height: 20.h),

          // Button shimmer
          _buildShimmerBox(width: double.infinity, height: 48.h),
        ],
      ),
    );
  }

  Widget _buildShimmerRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildShimmerBox(width: 100.w, height: 16.h),
        _buildShimmerBox(width: 120.w, height: 16.h),
      ],
    );
  }

  Widget _buildShimmerBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}
