import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/app/theme/typography.dart';
import 'package:myapp/features/home/domain/entities/upcoming_event.dart';

/// Widget displaying an event card in the upcoming events section
/// Shows event image, title, date/time, location, and register button
class EventCard extends StatelessWidget {
  const EventCard({
    required this.event,
    super.key,
    this.onTap,
    this.onRegisterTap,
  });

  /// Event data to display
  final UpcomingEvent event;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Callback when register button is tapped
  final VoidCallback? onRegisterTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280.w,
        margin: EdgeInsets.only(right: 16.w),
        decoration: BoxDecoration(
          color: AppColors.eventCardBackground,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(),
                  SizedBox(height: 8.h),
                  _buildDateTime(),
                  SizedBox(height: 4.h),
                  _buildLocation(),
                  SizedBox(height: 12.h),
                  _buildFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the event image with date badge overlay
  Widget _buildImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          child: event.fullBannerImageUrl != null
              ? Image.network(
                  event.fullBannerImageUrl!,
                  height: 140.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildImagePlaceholder(),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildImagePlaceholder(showLoading: true);
                  },
                )
              : _buildImagePlaceholder(),
        ),
        // Date badge overlay
        Positioned(
          top: 12.h,
          left: 12.w,
          child: _buildDateBadge(),
        ),
        // Price badge overlay
        Positioned(
          top: 12.h,
          right: 12.w,
          child: _buildPriceBadge(),
        ),
      ],
    );
  }

  /// Builds placeholder for event image
  Widget _buildImagePlaceholder({bool showLoading = false}) {
    return Container(
      height: 140.h,
      width: double.infinity,
      color: AppColors.grey200,
      child: Center(
        child: showLoading
            ? SizedBox(
                width: 24.w,
                height: 24.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : Icon(
                Icons.event_outlined,
                size: 48.sp,
                color: AppColors.grey400,
              ),
      ),
    );
  }

  /// Builds the date badge
  Widget _buildDateBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.eventDateBadge,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Text(
            event.eventDate.day.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.eventDateBadgeText,
              height: 1.1,
            ),
          ),
          Text(
            _getMonthShort(event.eventDate.month),
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.eventDateBadgeText.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the price badge
  Widget _buildPriceBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.eventPriceBadge,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        event.displayTicketPrice,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.eventPriceBadgeText,
        ),
      ),
    );
  }

  /// Builds the event title
  Widget _buildTitle() {
    return Text(
      event.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.titleMedium.copyWith(
        color: AppColors.textPrimary,
        height: 1.2,
      ),
    );
  }

  /// Builds the date/time row
  Widget _buildDateTime() {
    return Row(
      children: [
        Icon(
          Icons.access_time_rounded,
          size: 14.sp,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            event.displayTimeRange,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Builds the location row
  Widget _buildLocation() {
    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 14.sp,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            event.venue,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Builds the footer with available slots and register button
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Available slots
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${event.availableSlots} slots left',
              style: AppTypography.labelSmall.copyWith(
                color: event.availableSlots <= 10
                    ? AppColors.warning
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        // Register button
        SizedBox(
          height: 32.h,
          child: ElevatedButton(
            onPressed: event.isRegistrationOpen ? onRegisterTap : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.eventRegisterButton,
              disabledBackgroundColor: AppColors.grey300,
              foregroundColor: AppColors.eventRegisterButtonText,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              elevation: 0,
            ),
            child: Text(
              event.isRegistrationOpen ? 'Register' : 'Closed',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Gets short month name
  String _getMonthShort(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC'
    ];
    return months[month - 1];
  }
}

/// Shimmer loading placeholder for event card
class EventCardShimmer extends StatelessWidget {
  const EventCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280.w,
      margin: EdgeInsets.only(right: 16.w),
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 140.h,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(width: 200.w, height: 20.h),
                SizedBox(height: 8.h),
                _shimmerBox(width: 150.w, height: 14.h),
                SizedBox(height: 4.h),
                _shimmerBox(width: 180.w, height: 14.h),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _shimmerBox(width: 80.w, height: 14.h),
                    _shimmerBox(width: 80.w, height: 32.h),
                  ],
                ),
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
        color: AppColors.grey300,
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}
