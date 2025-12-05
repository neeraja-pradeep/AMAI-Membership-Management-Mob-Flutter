import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/home/domain/entities/upcoming_event.dart';

/// Mini card widget for upcoming events displayed in horizontal scroll
/// Shows event within a week from current date
class UpcomingEventMiniCard extends StatelessWidget {
  const UpcomingEventMiniCard({
    required this.event,
    super.key,
    this.onRegisterTap,
  });

  /// Event data to display
  final UpcomingEvent event;

  /// Callback when register button is tapped
  final VoidCallback? onRegisterTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 32.w,
      height: 180.h,
      margin: EdgeInsets.only(right: 16.w),
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
              'Upcoming Events',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: 16.h),
            // Event name and date row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    event.displayDate,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Register button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRegisterTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Check if the event is within a week from now
  static bool isWithinWeek(UpcomingEvent event) {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));
    return event.eventDate.isAfter(now) &&
        event.eventDate.isBefore(weekFromNow);
  }
}
