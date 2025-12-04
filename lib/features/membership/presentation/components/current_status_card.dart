import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/core/widgets/app_button.dart';
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
          // Header row: "Current Status" and Active badge
          _buildHeaderRow(),
          SizedBox(height: 16.h),

          // Valid until
          _buildValidUntil(),

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
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
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

  /// Builds the valid until row
  Widget _buildValidUntil() {
    return Row(
      children: [
        Text(
          'Valid Until: ',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          membershipStatus.formattedValidUntil,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: membershipStatus.isExpired
                ? AppColors.error
                : membershipStatus.isExpiringSoon
                    ? AppColors.warning
                    : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// Builds the renewal button
  Widget _buildRenewalButton() {
    return SizedBox(
      width: double.infinity,
      child: AppButton(
        text: membershipStatus.isActive ? 'Renew Membership' : 'Renew Now',
        onPressed: onRenewalPressed ?? () {},
        variant: AppButtonVariant.primary,
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
              _buildShimmerBox(width: 100.w, height: 20.h),
              _buildShimmerBox(width: 60.w, height: 24.h),
            ],
          ),
          SizedBox(height: 16.h),

          // Valid until shimmer
          _buildShimmerBox(width: 180.w, height: 16.h),
          SizedBox(height: 16.h),

          // Button shimmer
          _buildShimmerBox(width: double.infinity, height: 44.h),
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
