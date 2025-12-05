import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/home/domain/entities/announcement.dart';

/// Mini card widget for announcements displayed in horizontal scroll
/// Shows announcements created within the last week
class AnnouncementMiniCard extends StatelessWidget {
  const AnnouncementMiniCard({
    required this.announcement,
    super.key,
    this.onTap,
  });

  /// Announcement data to display
  final Announcement announcement;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 180.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
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
              // Header
              Text(
                'Announcement',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: 16.h),
              // Announcement title
              Text(
                announcement.title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              // Posted date
              Text(
                announcement.relativeTime,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Check if the announcement is within a week from creation
  static bool isWithinWeek(Announcement announcement) {
    return announcement.isNew;
  }
}
