import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/aswas_plus/domain/entities/nominee.dart';

/// Nominee Information Card for ASWAS Plus screen
/// Shows nominee details including name, relationship, and contact number
class NomineeInfoCard extends StatelessWidget {
  const NomineeInfoCard({
    required this.nominees,
    this.onRequestChange,
    super.key,
  });

  /// List of nominees to display
  final List<Nominee> nominees;

  /// Callback when request change button is pressed
  final VoidCallback? onRequestChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section heading
        Text(
          'Nominee Information',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),

        // Nominee details card
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
              // Display all nominees
              ...nominees.asMap().entries.map((entry) {
                final index = entry.key;
                final nominee = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (index > 0) ...[
                      Divider(
                        color: AppColors.grey200,
                        height: 24.h,
                      ),
                    ],
                    _buildNomineeDetails(nominee),
                  ],
                );
              }),

              SizedBox(height: 20.h),

              // Request Change button
              _buildRequestChangeButton(),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds nominee details section
  Widget _buildNomineeDetails(Nominee nominee) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nominee name
        Text(
          nominee.nomineeName,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),

        // Relationship
        _buildDetailRow('Relationship', nominee.relationship),
        SizedBox(height: 6.h),

        // Contact number
        _buildDetailRow('Contact', nominee.contactNumber),
      ],
    );
  }

  /// Builds a detail row with label and value
  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the request change button
  Widget _buildRequestChangeButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onRequestChange,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          side: BorderSide(color: AppColors.primary, width: 1.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Text(
          'Request Change',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

/// Shimmer loading state for NomineeInfoCard
class NomineeInfoCardShimmer extends StatelessWidget {
  const NomineeInfoCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading shimmer
        _buildShimmerBox(width: 140.w, height: 20.h),
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
              // Name shimmer
              _buildShimmerBox(width: 150.w, height: 18.h),
              SizedBox(height: 12.h),

              // Detail rows shimmer
              _buildShimmerRow(),
              SizedBox(height: 8.h),
              _buildShimmerRow(),
              SizedBox(height: 20.h),

              // Button shimmer
              _buildShimmerBox(width: double.infinity, height: 44.h),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerRow() {
    return Row(
      children: [
        _buildShimmerBox(width: 80.w, height: 14.h),
        SizedBox(width: 20.w),
        _buildShimmerBox(width: 120.w, height: 14.h),
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
