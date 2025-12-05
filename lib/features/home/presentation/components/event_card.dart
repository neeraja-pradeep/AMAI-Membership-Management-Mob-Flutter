import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/app/theme/typography.dart';
import 'package:myapp/features/home/domain/entities/upcoming_event.dart';

/// Widget displaying an event card in the upcoming events section
/// Shows event image, title, date/location, and register button
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
        width: 293.w,
        margin: EdgeInsets.only(right: 16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImage(),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(),
                  SizedBox(height: 14.h),
                  _buildDateLocation(),
                  SizedBox(height: 16.h),
                  EventCardButton(
                    label: 'Register Now',
                    onTap: event.isRegistrationOpen ? onRegisterTap : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the event image
  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
      child: event.fullBannerImageUrl != null
          ? Image.network(
              event.fullBannerImageUrl!,
              height: 120.h,
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
    );
  }

  /// Builds placeholder for event image
  Widget _buildImagePlaceholder({bool showLoading = false}) {
    return Container(
      height: 120.h,
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
            : Icon(Icons.event_outlined, size: 40.sp, color: AppColors.grey400),
      ),
    );
  }

  /// Builds the event title
  Widget _buildTitle() {
    return Text(
      event.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.titleMedium.copyWith(
        color: AppColors.textPrimary,
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Builds the date and location row
  Widget _buildDateLocation() {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/svg/calander.svg',
          width: 16.w,
          height: 16.h,
          colorFilter: const ColorFilter.mode(
            AppColors.textSecondary,
            BlendMode.srcIn,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Text(
            _formatDateLocation(),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Formats date range and location for display
  String _formatDateLocation() {
    final startDay = event.eventDate.day;
    final endDay = event.eventEndDate.day;
    final month = _getMonthShort(event.eventDate.month);
    final year = event.eventDate.year;

    String dateStr;
    if (startDay == endDay) {
      dateStr = '$startDay $month $year';
    } else {
      dateStr = '$startDay-$endDay $month $year';
    }

    return '$dateStr | ${event.venue}';
  }

  /// Gets short month name
  String _getMonthShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

/// Reusable button widget for Event Card
class EventCardButton extends StatelessWidget {
  const EventCardButton({required this.label, super.key, this.onTap});

  /// Button label text
  final String label;

  /// Callback when button is tapped
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 40.h,
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.primary : AppColors.grey300,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isEnabled ? AppColors.white : AppColors.grey500,
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer loading placeholder for event card
class EventCardShimmer extends StatelessWidget {
  const EventCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240.w,
      margin: EdgeInsets.only(right: 16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image placeholder
          Container(
            height: 120.h,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(width: 180.w, height: 18.h),
                SizedBox(height: 8.h),
                _shimmerBox(width: 150.w, height: 14.h),
                SizedBox(height: 12.h),
                _shimmerBox(width: double.infinity, height: 40.h),
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
