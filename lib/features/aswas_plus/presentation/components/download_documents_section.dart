import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/home/application/providers/home_providers.dart';
import 'package:url_launcher/url_launcher.dart';

/// Download Documents Section for ASWAS Plus screen
/// Provides buttons to download policy documents, claim forms, etc.
class DownloadDocumentsSection extends ConsumerWidget {
  const DownloadDocumentsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(aswasDocumentsProvider);

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
          child: documentsAsync.when(
            loading: () => _buildLoadingState(),
            error: (error, stack) => _buildErrorState(context, ref),
            data: (documents) => _buildDocumentsList(context, documents),
          ),
        ),
      ],
    );
  }

  /// Builds the documents list from API data
  Widget _buildDocumentsList(BuildContext context, List<Map<String, dynamic>> documents) {
    // Find documents by title
    final policyDoc = _findDocumentByTitle(documents, 'Policy Document');
    final claimDoc = _findDocumentByTitle(documents, 'Claim Form');
    final renewalDoc = _findDocumentByTitle(documents, 'Renewal Guidelines');

    return Column(
      children: [
        _buildDocumentItem(
          context: context,
          icon: Icons.description_outlined,
          label: 'Policy Document',
          fileUrl: policyDoc?['file_url'] as String?,
        ),
        Divider(height: 24.h, color: AppColors.grey200),
        _buildDocumentItem(
          context: context,
          icon: Icons.assignment_outlined,
          label: 'Claim Form',
          fileUrl: claimDoc?['file_url'] as String?,
        ),
        Divider(height: 24.h, color: AppColors.grey200),
        _buildDocumentItem(
          context: context,
          icon: Icons.article_outlined,
          label: 'Renewal Guidelines',
          fileUrl: renewalDoc?['file_url'] as String?,
        ),
      ],
    );
  }

  /// Finds a document by its title (case-insensitive)
  Map<String, dynamic>? _findDocumentByTitle(List<Map<String, dynamic>> documents, String title) {
    for (final doc in documents) {
      final docTitle = doc['title'] as String?;
      if (docTitle != null && docTitle.toLowerCase() == title.toLowerCase()) {
        return doc;
      }
    }
    return null;
  }

  /// Builds loading state
  Widget _buildLoadingState() {
    return Column(
      children: [
        _buildDocumentItemShimmer(),
        SizedBox(height: 16.h),
        _buildDocumentItemShimmer(),
        SizedBox(height: 16.h),
        _buildDocumentItemShimmer(),
      ],
    );
  }

  /// Builds error state
  Widget _buildErrorState(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Icon(Icons.error_outline, color: AppColors.error, size: 32.sp),
        SizedBox(height: 8.h),
        Text(
          'Failed to load documents',
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        SizedBox(height: 8.h),
        TextButton(
          onPressed: () => ref.invalidate(aswasDocumentsProvider),
          child: Text('Retry', style: TextStyle(color: AppColors.primary)),
        ),
      ],
    );
  }

  /// Builds a document download item
  Widget _buildDocumentItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String? fileUrl,
  }) {
    final isAvailable = fileUrl != null && fileUrl.isNotEmpty;

    return InkWell(
      onTap: isAvailable ? () => _handleDownload(context, label, fileUrl) : null,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: isAvailable
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.grey200,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: isAvailable ? AppColors.primary : AppColors.grey400,
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
                  color: isAvailable ? AppColors.textPrimary : AppColors.grey400,
                ),
              ),
            ),
            Icon(
              Icons.download_outlined,
              color: isAvailable ? AppColors.primary : AppColors.grey400,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds shimmer for document item
  Widget _buildDocumentItemShimmer() {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: AppColors.grey200,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Container(
            height: 16.h,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Container(
          width: 24.w,
          height: 24.h,
          decoration: BoxDecoration(
            color: AppColors.grey200,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ],
    );
  }

  /// Handles document download using url_launcher
  Future<void> _handleDownload(BuildContext context, String documentName, String fileUrl) async {
    // Ensure URL has https:// prefix
    String fullUrl = fileUrl;
    if (!fileUrl.startsWith('http://') && !fileUrl.startsWith('https://')) {
      fullUrl = 'https://$fileUrl';
    }

    final uri = Uri.parse(fullUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open $documentName'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening $documentName'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
