import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/app/theme/typography.dart';
import 'package:myapp/features/home/domain/entities/announcement.dart';
import 'package:myapp/features/home/presentation/components/announcement_item.dart';

/// Section displaying announcements in a vertical list
/// Each announcement is shown one below the other, scrollable
class AnnouncementsSection extends StatelessWidget {
  const AnnouncementsSection({
    required this.announcements,
    super.key,
    this.onViewAllTap,
    this.onAnnouncementTap,
  });

  /// List of announcements to display
  final List<Announcement> announcements;

  /// Callback when "View All" is tapped
  final VoidCallback? onViewAllTap;

  /// Callback when an announcement item is tapped
  final void Function(Announcement announcement)? onAnnouncementTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        SizedBox(height: 12.h),
        _buildAnnouncementsList(),
      ],
    );
  }

  /// Builds the section header with title and "View All" button
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Announcements',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (announcements.length > 3)
            TextButton(
              onPressed: onViewAllTap,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All',
                    style: AppTypography.buttonSmall.copyWith(
                      color: AppColors.newPrimaryLight,
                      fontWeight: FontWeight.w400,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12.sp,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the vertical announcements list
  Widget _buildAnnouncementsList() {
    // Show max 5 announcements on home screen
    final displayAnnouncements = announcements.take(5).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey300),
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: displayAnnouncements.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            thickness: 1,
            color: AppColors.grey200,
            indent: 16.w,
            endIndent: 16.w,
          ),
          itemBuilder: (context, index) {
            final announcement = displayAnnouncements[index];
            return AnnouncementItem(
              announcement: announcement,
              onTap: () => onAnnouncementTap?.call(announcement),
            );
          },
        ),
      ),
    );
  }
}

/// Loading state for announcements section
class AnnouncementsSectionShimmer extends StatelessWidget {
  const AnnouncementsSectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 120.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              Container(
                width: 60.w,
                height: 16.h,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: 3,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 1,
                color: AppColors.grey200,
                indent: 16.w,
                endIndent: 16.w,
              ),
              itemBuilder: (context, index) => const AnnouncementItemShimmer(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Empty state for when no announcements are available
class AnnouncementsEmptyState extends StatelessWidget {
  const AnnouncementsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Announcements',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.campaign_outlined,
                  size: 48.sp,
                  color: AppColors.grey400,
                ),
                SizedBox(height: 12.h),
                Text(
                  'No announcements',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Check back later for updates',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
