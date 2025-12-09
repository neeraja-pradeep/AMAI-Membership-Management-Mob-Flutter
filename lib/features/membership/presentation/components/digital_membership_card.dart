import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/membership/domain/entities/membership_status.dart';
import 'package:myapp/features/membership/presentation/components/qr_code_widget.dart';

/// Digital Membership Card widget displaying QR code and member details
/// Shows at events and check-ins
class DigitalMembershipCard extends StatelessWidget {
  const DigitalMembershipCard({
    required this.membershipStatus,
    this.onViewFullSize,
    this.onDownloadPdf,
    super.key,
  });

  /// Membership status containing member details
  final MembershipStatus membershipStatus;

  /// Callback when View Full Size button is pressed
  final VoidCallback? onViewFullSize;

  /// Callback when Download as PDF button is pressed
  final VoidCallback? onDownloadPdf;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section heading
        Text(
          'Digital Membership Card',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),

        // Card container - show unavailable message if membership is inactive
        if (!membershipStatus.isActive)
          _buildUnavailableCard()
        else
          _buildActiveCard(),
      ],
    );
  }

  /// Builds the unavailable card message for inactive membership
  Widget _buildUnavailableCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
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
        children: [
          Icon(
            Icons.credit_card_off_outlined,
            size: 48.sp,
            color: AppColors.grey400,
          ),
          SizedBox(height: 16.h),
          Text(
            'Digital card is unavailable because your membership has expired. Renew to regain access.',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds the active card with QR code
  Widget _buildActiveCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
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
        children: [
          // Card title
          Text(
            'AMAI Digital Membership',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),

          // Subtitle
          Text(
            'Show at events and check-ins',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),

          // QR Code
          QrCodeWidget(
            data: membershipStatus.membershipNumber,
            size: 120.w,
          ),
          SizedBox(height: 16.h),

          // View Full Screen QR button
          GestureDetector(
            onTap: onViewFullSize ?? () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fullscreen,
                  size: 18.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 6.w),
                Text(
                  'View Full Screen QR',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Download as PDF button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onDownloadPdf ?? () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.grey300),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.r),
                ),
              ),
              child: Text(
                'Download as PDF',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer loading state for DigitalMembershipCard
class DigitalMembershipCardShimmer extends StatelessWidget {
  const DigitalMembershipCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section heading shimmer
        _buildShimmerBox(width: 160.w, height: 16.h),
        SizedBox(height: 12.h),

        // Card container shimmer
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
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
            children: [
              // Title shimmer
              _buildShimmerBox(width: 180.w, height: 16.h),
              SizedBox(height: 6.h),

              // Subtitle shimmer
              _buildShimmerBox(width: 140.w, height: 12.h),
              SizedBox(height: 16.h),

              // QR code shimmer
              _buildShimmerBox(width: 120.w, height: 120.w),
              SizedBox(height: 16.h),

              // View full screen shimmer
              _buildShimmerBox(width: 120.w, height: 14.h),
              SizedBox(height: 16.h),

              // Button shimmer
              _buildShimmerBox(width: double.infinity, height: 44.h),
            ],
          ),
        ),
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
