import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myapp/app/theme/colors.dart';

/// Scheme Details Section for ASWAS Plus screen
/// Shows information about the ASWAS Plus scheme
class SchemeDetailsSection extends StatelessWidget {
  const SchemeDetailsSection({
    this.productDescription,
    this.showRenewButton = false,
    this.onRenewPressed,
    super.key,
  });

  /// Product description from API
  final String? productDescription;

  /// Whether to show the renew button
  final bool showRenewButton;

  /// Callback when renew button is pressed
  final VoidCallback? onRenewPressed;

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
          // Section heading with icon
          Row(
            children: [
              SvgPicture.asset(
                'assets/svg/aswas.svg',
                width: 24.w,
                height: 24.h,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'Aswas Plus Scheme',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Scheme description
          Text(
            _schemeDescription,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          SizedBox(height: 16.h),

          // Eligibility text (bold)
          Text(
            'All AMAI members below the age of 55 years can join this scheme. They need to pay:',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 8.h),

          // Joining fees list
          _buildNumberedItem('1', 'A one-time joining fee (age-dependent)'),
          SizedBox(height: 4.h),
          _buildNumberedItem('2', 'Annual subscription fee of ₹300'),
          SizedBox(height: 16.h),

          // Renewal text
          Text(
            'For renewal, members must pay:',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 8.h),

          // Renewal fees list
          _buildNumberedItem('1', 'Annual subscription fee of ₹300'),

          if (showRenewButton) ...[
            SizedBox(height: 16.h),
            _buildRenewButton(),
          ],
        ],
      ),
    );
  }

  /// Builds a numbered list item
  Widget _buildNumberedItem(String number, String text) {
    return Padding(
      padding: EdgeInsets.only(left: 8.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. ',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the renew button
  Widget _buildRenewButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onRenewPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Text(
          'Renew Policy',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  /// Static scheme description text
  static const String _schemeDescription =
      'The Aswasplus scheme is a social security scheme designed for AMAI family members, '
      'launched in 2017. This family protection scheme has death claim settlement of 7 '
      'working days. It has lock in period of 2 years (except for accident deaths). More than '
      '5,000 AMAI members are already part of this scheme.';
}

/// Shimmer loading state for SchemeDetailsSection
class SchemeDetailsSectionShimmer extends StatelessWidget {
  const SchemeDetailsSectionShimmer({super.key});

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
          // Header shimmer
          Row(
            children: [
              _buildShimmerBox(width: 24.w, height: 24.h),
              SizedBox(width: 8.w),
              _buildShimmerBox(width: 150.w, height: 20.h),
            ],
          ),
          SizedBox(height: 16.h),
          _buildShimmerBox(width: double.infinity, height: 14.h),
          SizedBox(height: 8.h),
          _buildShimmerBox(width: double.infinity, height: 14.h),
          SizedBox(height: 8.h),
          _buildShimmerBox(width: double.infinity, height: 14.h),
          SizedBox(height: 8.h),
          _buildShimmerBox(width: 200.w, height: 14.h),
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
