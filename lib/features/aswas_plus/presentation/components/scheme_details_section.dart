import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';

/// Scheme Details Section for ASWAS Plus screen
/// Shows information about the ASWAS Plus scheme
class SchemeDetailsSection extends StatelessWidget {
  const SchemeDetailsSection({
    this.productDescription,
    super.key,
  });

  /// Product description from API
  final String? productDescription;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section heading
        Text(
          'Scheme Details',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),

        // Scheme details card
        Container(
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
          child: Text(
            productDescription ?? _defaultSchemeDetails,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  /// Default scheme details if not available from API
  static const String _defaultSchemeDetails =
      'The Aswas Plus scheme is a social security scheme designed for AMAI family members, launched in 2017. '
      'This family protection scheme has death claim settlement of 7 working days. '
      'It has lock in period of 2 years (except for accident deaths). '
      'More than 5,000 AMAI members are already part of this scheme.';
}

/// Shimmer loading state for SchemeDetailsSection
class SchemeDetailsSectionShimmer extends StatelessWidget {
  const SchemeDetailsSectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading shimmer
        _buildShimmerBox(width: 120.w, height: 20.h),
        SizedBox(height: 12.h),

        // Content card shimmer
        Container(
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
              _buildShimmerBox(width: double.infinity, height: 14.h),
              SizedBox(height: 8.h),
              _buildShimmerBox(width: double.infinity, height: 14.h),
              SizedBox(height: 8.h),
              _buildShimmerBox(width: double.infinity, height: 14.h),
              SizedBox(height: 8.h),
              _buildShimmerBox(width: 200.w, height: 14.h),
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
