import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/app/theme/typography.dart';
import 'package:myapp/features/home/domain/entities/membership_card.dart';

/// Widget displaying the AMAI Membership Card on homescreen
/// Shows membership details with background image and status badge
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
        height: 180.h,
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          image: const DecorationImage(
            image: AssetImage('assets/home/membership_card.png'),
            fit: BoxFit.cover,
          ),
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
              const Spacer(),
              _buildBottomSection(),
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
            fontWeight: FontWeight.w500,
            color: AppColors.membershipCardText.withOpacity(0.9),
            letterSpacing: 1.0,
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  /// Builds the outlined status badge
  Widget _buildStatusBadge() {
    String label;
    if (!membershipCard.isActive) {
      label = 'Inactive';
    } else if (membershipCard.isExpired) {
      label = 'Expired';
    } else if (membershipCard.isExpiringSoon) {
      label = 'Expiring Soon';
    } else {
      label = 'Active';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.membershipCardText.withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.membershipCardText,
        ),
      ),
    );
  }

  /// Builds the bottom section with name, valid till, ID and date
  Widget _buildBottomSection() {
    return Column(
      children: [
        // Line 1: Name (left) | Valid Till (right)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                membershipCard.holderName,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.membershipCardText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              'Valid Till',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w300,
                color: AppColors.membershipCardText,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        // Line 2: Membership ID (left) | Date (right)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  'assets/svg/membership.svg',
                  width: 18.w,
                  height: 18.h,
                  colorFilter: ColorFilter.mode(
                    AppColors.membershipCardText.withOpacity(0.8),
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  membershipCard.membershipNumber,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.membershipCardText,
                  ),
                ),
              ],
            ),
            Text(
              membershipCard.displayValidUntil,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.membershipCardText,
              ),
            ),
          ],
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
