import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/membership/domain/entities/membership_status.dart';

/// Current Status Card widget for the Membership screen
/// Displays membership status, type, validity with icon
class CurrentStatusCard extends ConsumerWidget {
  const CurrentStatusCard({
    required this.membershipStatus,
    this.onRenewalPressed,
    super.key,
  });

  /// Membership status data to display
  final MembershipStatus membershipStatus;

  /// Callback when renewal button is pressed
  final VoidCallback? onRenewalPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      height: 170.h,
      padding: EdgeInsets.symmetric(vertical: 20.w, horizontal: 13.w),
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: "Current Status" and Active badge
          _buildHeaderRow(),
          SizedBox(height: 20.h),
          // Bottom section with icon and details
          _buildBottomSection(),
        ],
      ),
    );
  }

  /// Builds the header row with title and status badge
  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Current Status',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  /// Builds the outlined status badge
  Widget _buildStatusBadge() {
    String label;
    Color backgroundColor;
    Color textColor;

    if (!membershipStatus.isActive) {
      label = 'Inactive';
      backgroundColor = AppColors.grey200;
      textColor = AppColors.grey600;
    } else if (membershipStatus.isExpired) {
      label = 'Expired';
      backgroundColor = AppColors.errorLight;
      textColor = AppColors.error;
    } else if (membershipStatus.isExpiringSoon) {
      label = 'Expiring Soon';
      backgroundColor = AppColors.warningLight;
      textColor = AppColors.warning;
    } else {
      label = 'Active';
      backgroundColor = const Color(0xFFFCE4EC);
      textColor = AppColors.primary;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
      ),
    );
  }

  /// Builds the bottom section with icon and membership details
  Widget _buildBottomSection() {
    return Row(
      children: [
        // Icon container
        Container(
          width: 56.w,
          height: 56.h,
          decoration: BoxDecoration(
            color: const Color(0xFFFCE4EC),
            borderRadius: BorderRadius.circular(50.r),
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/svg/member.svg',
              width: 32.w,
              height: 32.h,
            ),
          ),
        ),
        SizedBox(width: 16.w),
        // Membership details
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              membershipStatus.displayMembershipType,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Valid till ${membershipStatus.formattedValidUntil}',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Shimmer loading state for CurrentStatusCard
class CurrentStatusCardShimmer extends StatelessWidget {
  const CurrentStatusCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 170.h,
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
          // Header row shimmer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildShimmerBox(width: 120.w, height: 22.h),
              _buildShimmerBox(width: 70.w, height: 32.h),
            ],
          ),
          const Spacer(),
          // Bottom section shimmer
          Row(
            children: [
              _buildShimmerBox(width: 56.w, height: 56.h),
              SizedBox(width: 16.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerBox(width: 80.w, height: 14.h),
                  SizedBox(height: 4.h),
                  _buildShimmerBox(width: 140.w, height: 18.h),
                ],
              ),
            ],
          ),
        ],
      ),
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
