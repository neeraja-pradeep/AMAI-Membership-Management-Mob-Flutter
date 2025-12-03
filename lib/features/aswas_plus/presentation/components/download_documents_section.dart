import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myapp/app/theme/colors.dart';

/// Download Documents Section for ASWAS Plus screen
/// Provides buttons to download policy documents, claim forms, etc.
class DownloadDocumentsSection extends StatelessWidget {
  const DownloadDocumentsSection({
    this.policyDocumentUrl,
    this.claimFormUrl,
    this.renewalGuidelinesUrl,
    super.key,
  });

  /// URL for policy document download
  final String? policyDocumentUrl;

  /// URL for claim form download
  final String? claimFormUrl;

  /// URL for renewal guidelines download
  final String? renewalGuidelinesUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section heading
        Text(
          'Download Documents',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),

        // Documents list
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
            children: [
              _buildDocumentItem(
                context: context,
                icon: Icons.description_outlined,
                label: 'Policy Document',
                onTap: () => _handleDownload(context, 'Policy Document'),
              ),
              Divider(height: 24.h, color: AppColors.grey200),
              _buildDocumentItem(
                context: context,
                icon: Icons.assignment_outlined,
                label: 'Claim Form',
                onTap: () => _handleDownload(context, 'Claim Form'),
              ),
              Divider(height: 24.h, color: AppColors.grey200),
              _buildDocumentItem(
                context: context,
                icon: Icons.article_outlined,
                label: 'Renewal Guidelines',
                onTap: () => _handleDownload(context, 'Renewal Guidelines'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds a document download item
  Widget _buildDocumentItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.download_outlined,
              color: AppColors.primary,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  /// Handles document download
  void _handleDownload(BuildContext context, String documentName) {
    // Static for now - will integrate with url_launcher later
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$documentName download coming soon'),
      ),
    );
  }
}

/// Shimmer loading state for DownloadDocumentsSection
class DownloadDocumentsSectionShimmer extends StatelessWidget {
  const DownloadDocumentsSectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading shimmer
        _buildShimmerBox(width: 160.w, height: 20.h),
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
            children: [
              _buildDocumentItemShimmer(),
              SizedBox(height: 16.h),
              _buildDocumentItemShimmer(),
              SizedBox(height: 16.h),
              _buildDocumentItemShimmer(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentItemShimmer() {
    return Row(
      children: [
        _buildShimmerBox(width: 40.w, height: 40.h),
        SizedBox(width: 12.w),
        Expanded(child: _buildShimmerBox(width: 120.w, height: 16.h)),
        _buildShimmerBox(width: 24.w, height: 24.h),
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
