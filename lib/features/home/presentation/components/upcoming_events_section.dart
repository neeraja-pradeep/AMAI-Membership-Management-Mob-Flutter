import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/app/theme/typography.dart';
import 'package:myapp/features/home/domain/entities/upcoming_event.dart';
import 'package:myapp/features/home/presentation/components/event_card.dart';

/// Section displaying upcoming events in a horizontally scrollable list
class UpcomingEventsSection extends StatelessWidget {
  const UpcomingEventsSection({
    required this.events,
    super.key,
    this.onViewAllTap,
    this.onEventTap,
    this.onRegisterTap,
  });

  /// List of events to display
  final List<UpcomingEvent> events;

  /// Callback when "View All" is tapped
  final VoidCallback? onViewAllTap;

  /// Callback when an event card is tapped
  final void Function(UpcomingEvent event)? onEventTap;

  /// Callback when register button is tapped
  final void Function(UpcomingEvent event)? onRegisterTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        SizedBox(height: 12.h),
        _buildEventsList(),
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
            'Upcoming Events',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (events.length > 3)
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

  /// Builds the horizontal scrollable events list
  Widget _buildEventsList() {
    return SizedBox(
      height: 290.h, // Fixed height for horizontal list
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return EventCard(
            event: event,
            onTap: () => onEventTap?.call(event),
            onRegisterTap: () => onRegisterTap?.call(event),
          );
        },
      ),
    );
  }
}

/// Loading state for upcoming events section
class UpcomingEventsSectionShimmer extends StatelessWidget {
  const UpcomingEventsSectionShimmer({super.key});

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
                width: 140.w,
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
        SizedBox(
          height: 290.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: 3,
            itemBuilder: (context, index) {
              return const EventCardShimmer();
            },
          ),
        ),
      ],
    );
  }
}

/// Empty state for when no events are available
class UpcomingEventsEmptyState extends StatelessWidget {
  const UpcomingEventsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Events',
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
                  Icons.event_busy_outlined,
                  size: 48.sp,
                  color: AppColors.grey400,
                ),
                SizedBox(height: 12.h),
                Text(
                  'No upcoming events',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Check back later for new events',
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
