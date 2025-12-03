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
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 24.h),

        // Card container
        Container(
          width: double.infinity,
          height: 358.h,
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
            children: [
              // Card title
              Text(
                'AMAI Digital Membership Card',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),

              // Subtitle
              Text(
                'Show at events and check-ins',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),

              // QR Code
              QrCodeWidget(
                data: membershipStatus.membershipNumber,
                size: 121.w,
              ),
              SizedBox(height: 20.h),

              // Action section
              _buildActionSection(),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the action section with view full screen text and download button
  Widget _buildActionSection() {
    return Column(
      children: [
        // View Full Screen QR text link
        GestureDetector(
          onTap: onViewFullSize,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fullscreen, size: 20.sp, color: AppColors.textPrimary),
              SizedBox(width: 8.w),
              Text(
                'View Full Screen QR',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),

        // Download as PDF button
        GestureDetector(
          onTap: onDownloadPdf,
          child: Container(
            width: double.infinity,
            height: 44.h,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(25.r),
              border: Border.all(
                color: AppColors.newPrimaryLight, // Border color
                width: 2, // Border thickness
              ),
            ),
            child: Center(
              child: Text(
                'Download as PDF',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.aswasCardText,
                ),
              ),
            ),
          ),
        ),
      ],
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
        _buildShimmerBox(width: 180.w, height: 20.h),
        SizedBox(height: 12.h),

        // Card container shimmer
        Container(
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
            children: [
              // Title shimmer
              _buildShimmerBox(width: 220.w, height: 22.h),
              SizedBox(height: 8.h),

              // Subtitle shimmer
              _buildShimmerBox(width: 160.w, height: 16.h),
              SizedBox(height: 20.h),

              // QR code shimmer
              _buildShimmerBox(width: 180.w, height: 180.w),
              SizedBox(height: 20.h),

              // Buttons shimmer
              Row(
                children: [
                  Expanded(
                    child: _buildShimmerBox(
                      width: double.infinity,
                      height: 44.h,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildShimmerBox(
                      width: double.infinity,
                      height: 44.h,
                    ),
                  ),
                ],
              ),
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
