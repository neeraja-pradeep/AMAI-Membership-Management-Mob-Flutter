import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/home/presentation/components/status_badge.dart';
import 'package:myapp/features/membership/domain/entities/membership_status.dart';

/// Current Status Card widget for the Membership screen
/// Displays membership status, type, validity, and renewal button
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
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
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
          // Header row: "Current Status" and Active badge
          _buildHeaderRow(),
          SizedBox(height: 16.h),

          // Membership type and validity row
          _buildMembershipInfo(),

          // Renewal button (conditional)
          if (membershipStatus.shouldShowRenewalButton) ...[
            SizedBox(height: 16.h),
            _buildRenewalButton(),
          ],
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
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        MembershipStatusBadge(
          isActive: membershipStatus.isActive,
          isExpired: membershipStatus.isExpired,
          isExpiringSoon: membershipStatus.isExpiringSoon,
        ),
      ],
    );
  }

  /// Builds the membership info row with icon, type, and validity
  Widget _buildMembershipInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Card SVG icon
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: AppColors.activeBadge.withOpacity(0.5),
            borderRadius: BorderRadius.circular(100.r),
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/svg/card.svg',
              width: 24.w,
              height: 24.w,
            ),
          ),
        ),
        SizedBox(width: 12.w),

        // Membership type and validity
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                membershipStatus.membershipType.isNotEmpty
                    ? membershipStatus.membershipType
                    : 'Regular',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Valid till ${membershipStatus.formattedValidUntil}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: membershipStatus.isExpired
                      ? AppColors.error
                      : membershipStatus.isExpiringSoon
                      ? AppColors.warning
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the renewal button
  Widget _buildRenewalButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onRenewalPressed ?? () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          elevation: 0,
        ),
        child: Text(
          membershipStatus.isActive ? 'Renew Membership' : 'Renew Now',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
      ),
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
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
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
              _buildShimmerBox(width: 100.w, height: 18.h),
              _buildShimmerBox(width: 60.w, height: 24.h),
            ],
          ),
          SizedBox(height: 16.h),

          // Membership info shimmer
          Row(
            children: [
              _buildShimmerBox(width: 40.w, height: 40.w),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerBox(width: 80.w, height: 14.h),
                  SizedBox(height: 4.h),
                  _buildShimmerBox(width: 140.w, height: 12.h),
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
