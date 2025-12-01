import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/app/theme/typography.dart';
import 'package:myapp/features/home/domain/entities/membership_card.dart';
import 'package:myapp/features/home/presentation/components/status_badge.dart';

/// Widget displaying the AMAI Membership Card on homescreen
/// Shows membership details with gradient background and status badge
class MembershipCardWidget extends StatelessWidget {
  const MembershipCardWidget({
    required this.membershipCard,
    super.key,
    this.onTap,
  });

  /// Membership card data to display
  final MembershipCard membershipCard;

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
              AppColors.membershipCardGradientStart,
              AppColors.membershipCardGradientEnd,
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
              SizedBox(height: 20.h),
              _buildHolderName(),
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
        Text(
          'AMAI MEMBERSHIP CARD',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.membershipCardText.withOpacity(0.9),
            letterSpacing: 1.2,
          ),
        ),
        MembershipStatusBadge(
          isActive: membershipCard.isActive,
          isExpired: membershipCard.isExpired,
          isExpiringSoon: membershipCard.isExpiringSoon,
        ),
      ],
    );
  }

  /// Builds the holder name section
  Widget _buildHolderName() {
    return Text(
      membershipCard.holderName.toUpperCase(),
      style: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.membershipCardText,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Builds the footer with membership number and validity
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          membershipCard.membershipNumber,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.membershipCardText,
          ),
        ),
        _buildInfoColumn(
          label: 'Valid Till',
          value: membershipCard.displayValidUntil,
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
            color: AppColors.membershipCardText.withOpacity(0.7),
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.membershipCardText,
          ),
        ),
      ],
    );
  }
}

/// Shimmer loading placeholder for membership card
class MembershipCardShimmer extends StatelessWidget {
  const MembershipCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180.h,
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
                _shimmerBox(width: 150.w, height: 14.h),
                _shimmerBox(width: 60.w, height: 20.h),
              ],
            ),
            SizedBox(height: 24.h),
            _shimmerBox(width: 200.w, height: 28.h),
            SizedBox(height: 8.h),
            _shimmerBox(width: 100.w, height: 14.h),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(width: 80.w, height: 10.h),
                    SizedBox(height: 4.h),
                    _shimmerBox(width: 120.w, height: 16.h),
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

/// Empty state when no membership card is available
class MembershipCardEmpty extends StatelessWidget {
  const MembershipCardEmpty({
    super.key,
    this.onApply,
  });

  /// Callback when user wants to apply for membership
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.grey300,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_membership_outlined,
            size: 36.sp,
            color: AppColors.grey500,
          ),
          SizedBox(height: 12.h),
          Text(
            'No Membership Found',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Apply for AMAI membership to access exclusive benefits.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textHint,
              fontSize: 12.sp,
            ),
          ),
          if (onApply != null) ...[
            SizedBox(height: 8.h),
            TextButton(
              onPressed: onApply,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Apply Now',
                style: AppTypography.buttonMedium.copyWith(
                  color: AppColors.primary,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
