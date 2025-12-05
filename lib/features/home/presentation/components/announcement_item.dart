import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/app/theme/typography.dart';
import 'package:myapp/features/home/domain/entities/announcement.dart';

/// Widget displaying a single announcement item
/// Shows title, content preview, type badge, and relative time
class AnnouncementItem extends StatelessWidget {
  const AnnouncementItem({required this.announcement, super.key, this.onTap});

  /// Announcement data to display
  final Announcement announcement;

  /// Callback when item is tapped
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              announcement.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 6.h),
            // Posted time
            Text(
              'Posted ${announcement.relativeTime}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textHint,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading placeholder for announcement item
class AnnouncementItemShimmer extends StatelessWidget {
  const AnnouncementItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title placeholder
          Container(
            width: double.infinity,
            height: 16.h,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 6.h),
          // Posted time placeholder
          Container(
            width: 100.w,
            height: 14.h,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ],
      ),
    );
  }
}
