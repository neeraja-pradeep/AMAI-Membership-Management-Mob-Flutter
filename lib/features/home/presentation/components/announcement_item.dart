import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/app/theme/typography.dart';
import 'package:myapp/features/home/domain/entities/announcement.dart';

/// Widget displaying a single announcement item
/// Shows title, content preview, type badge, and relative time
class AnnouncementItem extends StatelessWidget {
  const AnnouncementItem({
    required this.announcement,
    super.key,
    this.onTap,
  });

  /// Announcement data to display
  final Announcement announcement;

  /// Callback when item is tapped
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured image or icon
            _buildLeading(),
            SizedBox(width: 12.w),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with type badge and time
                  _buildHeader(),
                  SizedBox(height: 8.h),
                  // Title
                  _buildTitle(),
                  SizedBox(height: 4.h),
                  // Content preview
                  _buildContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the leading icon or image
  Widget _buildLeading() {
    if (announcement.featuredImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Image.network(
          announcement.featuredImage!,
          width: 60.w,
          height: 60.h,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildIconPlaceholder(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildIconPlaceholder();
          },
        ),
      );
    }
    return _buildIconPlaceholder();
  }

  /// Builds the icon placeholder
  Widget _buildIconPlaceholder() {
    return Container(
      width: 60.w,
      height: 60.h,
      decoration: BoxDecoration(
        color: _getTypeBackgroundColor(),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(
        child: Icon(
          _getTypeIcon(),
          size: 28.sp,
          color: _getTypeColor(),
        ),
      ),
    );
  }

  /// Builds the header with type badge and time
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Type badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: _getTypeBackgroundColor(),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (announcement.isUrgent) ...[
                Icon(
                  Icons.priority_high_rounded,
                  size: 12.sp,
                  color: _getTypeColor(),
                ),
                SizedBox(width: 2.w),
              ],
              Text(
                announcement.displayType,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: _getTypeColor(),
                ),
              ),
            ],
          ),
        ),
        // Time
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (announcement.isNew)
              Container(
                margin: EdgeInsets.only(right: 6.w),
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'New',
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.info,
                  ),
                ),
              ),
            Text(
              announcement.relativeTime,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the title
  Widget _buildTitle() {
    return Text(
      announcement.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.titleSmall.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Builds the content preview
  Widget _buildContent() {
    return Text(
      announcement.contentPreview,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.bodySmall.copyWith(
        color: AppColors.textSecondary,
        height: 1.4,
      ),
    );
  }

  /// Gets the background color based on announcement type
  Color _getTypeBackgroundColor() {
    switch (announcement.announcementType.toLowerCase()) {
      case 'urgent':
        return AppColors.errorLight;
      case 'event':
        return AppColors.infoLight;
      case 'update':
        return AppColors.successLight;
      case 'news':
        return AppColors.warningLight;
      default:
        return AppColors.grey100;
    }
  }

  /// Gets the text color based on announcement type
  Color _getTypeColor() {
    switch (announcement.announcementType.toLowerCase()) {
      case 'urgent':
        return AppColors.error;
      case 'event':
        return AppColors.info;
      case 'update':
        return AppColors.success;
      case 'news':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Gets the icon based on announcement type
  IconData _getTypeIcon() {
    switch (announcement.announcementType.toLowerCase()) {
      case 'urgent':
        return Icons.warning_amber_rounded;
      case 'event':
        return Icons.event_rounded;
      case 'update':
        return Icons.update_rounded;
      case 'news':
        return Icons.newspaper_rounded;
      default:
        return Icons.campaign_outlined;
    }
  }
}

/// Shimmer loading placeholder for announcement item
class AnnouncementItemShimmer extends StatelessWidget {
  const AnnouncementItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          SizedBox(width: 12.w),
          // Content placeholders
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _shimmerBox(width: 60.w, height: 18.h),
                    _shimmerBox(width: 50.w, height: 14.h),
                  ],
                ),
                SizedBox(height: 8.h),
                // Title
                _shimmerBox(width: double.infinity, height: 16.h),
                SizedBox(height: 4.h),
                // Content
                _shimmerBox(width: 200.w, height: 14.h),
                SizedBox(height: 2.h),
                _shimmerBox(width: 150.w, height: 14.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox({required double width, required double height}) {
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
