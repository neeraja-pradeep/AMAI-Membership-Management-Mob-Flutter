import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/home/application/providers/home_providers.dart';
import 'package:myapp/features/navigation/presentation/screens/main_navigation_screen.dart';
import 'package:myapp/features/home/presentation/screens/contact_details_screen.dart';
import 'package:myapp/features/auth/application/providers/auth_provider.dart';

/// Registration Status screen shown when membership application is pending, approved, or rejected
/// Displays appropriate message based on status
class RegistrationStatusScreen extends ConsumerStatefulWidget {
  const RegistrationStatusScreen({
    super.key,
    this.isRejected = false,
    this.isApproved = false,
  });

  /// Whether the application was rejected
  final bool isRejected;

  /// Whether the application was approved
  final bool isApproved;

  @override
  ConsumerState<RegistrationStatusScreen> createState() =>
      _RegistrationStatusScreenState();
}

class _RegistrationStatusScreenState
    extends ConsumerState<RegistrationStatusScreen> {
  Future<void> _onRefresh() async {
    await ref.read(membershipStateProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Registration Status",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.lightBackgroundGradient,
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Card
                  if (widget.isApproved)
                    _buildApprovedCard()
                  else if (widget.isRejected)
                    _buildRejectedCard()
                  else
                    _buildReviewCard(),

                  // Timeline Card (only show for pending and approved)
                  if (!widget.isRejected) ...[
                    SizedBox(height: 16.h),
                    _buildTimelineCard(),
                  ],

                  SizedBox(height: 32.h),

                  // Bottom Button
                  _buildBottomButton(),

                  // Logout button for pending status
                  if (!widget.isApproved && !widget.isRejected) ...[
                    SizedBox(height: 16.h),
                    _buildLogoutButton(),
                  ],

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the Registration Under Review card (for pending status)
  Widget _buildReviewCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Clock Icon
          SvgPicture.asset(
            'assets/svg/clock.svg',
            width: 40.w,
            height: 40.w,
          ),
          SizedBox(height: 16.h),

          // Title
          Text(
            'Registration Under Review',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFB71C1C), // Dark red color
            ),
          ),
          SizedBox(height: 12.h),

          // Description
          Text(
            'Thank you for registering! Your request has been successfully submitted and is now pending administrative review.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 20.h),

          // Pending Approval Button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100.r),
              border: Border.all(
                color: const Color(0xFFB71C1C),
              ),
            ),
            child: Text(
              'Pending Approval',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFB71C1C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the Registration Approved card
  Widget _buildApprovedCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Checkmark Icon
          SvgPicture.asset(
            'assets/svg/tick.svg',
            width: 40.w,
            height: 40.w,
          ),
          SizedBox(height: 16.h),

          // Title
          Text(
            'Registration Approved',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2E7D32), // Dark green
            ),
          ),
          SizedBox(height: 12.h),

          // Description
          Text(
            'Congratulations! Your registration has been approved. We look forward to seeing you at the event.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 20.h),

          // Approved Button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100.r),
              border: Border.all(
                color: const Color(0xFF2E7D32),
              ),
            ),
            child: Text(
              'Approved',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the Registration Rejected card
  Widget _buildRejectedCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Reject Icon
          SvgPicture.asset(
            'assets/svg/reject.svg',
            width: 42.w,
            height: 42.w,
          ),
          SizedBox(height: 16.h),

          // Title
          Text(
            'Registration Rejected',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFB51212),
            ),
          ),
          SizedBox(height: 12.h),

          // Description
          Text(
            'Unfortunately, your registration could not be approved. You may try again or contact support for more details.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 20.h),

          // Rejected Button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(100.r),
            ),
            child: Text(
              'Rejected',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFB51212),
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // Contact Info Section
          Text(
            'Need help? Contact Admin or try again.',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),

          // Email row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mail_outline,
                size: 20.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 8.w),
              Text(
                'distadmin@amai.org.in',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Phone row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone_outlined,
                size: 20.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 8.w),
              Text(
                '+91 91234 56789',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the Registration Timeline card
  Widget _buildTimelineCard() {
    final membershipState = ref.watch(membershipStateProvider);

    // Get application date from state
    String? applicationDate;
    membershipState.maybeWhen(
      pending: (appDate) => applicationDate = appDate,
      orElse: () {},
    );

    // Format application date for display
    String submittedDate = 'January 15, 2025 | 2:30 PM';
    String expectedDate = 'Expected: January 20, 2025';

    if (applicationDate != null) {
      try {
        final dateTime = DateTime.parse(applicationDate!);
        // Format as "Month Day, Year | HH:MM AM/PM"
        final formattedDate = '${_getMonthName(dateTime.month)} ${dateTime.day}, ${dateTime.year} | ${_formatTime(dateTime)}';
        submittedDate = formattedDate;

        // Calculate expected date (application_date + 5 days)
        final expectedDateTime = dateTime.add(const Duration(days: 5));
        expectedDate = 'Expected: ${_getMonthName(expectedDateTime.month)} ${expectedDateTime.day}, ${expectedDateTime.year}';
      } catch (e) {
        // Keep default dates if parsing fails
      }
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Registration Timeline',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 20.h),

          // Timeline items
          _buildTimelineItem(
            title: 'Registration Submitted',
            subtitle: submittedDate,
            isCompleted: true,
            isFirst: true,
          ),
          _buildTimelineItem(
            title: 'Under Administrative Review',
            subtitle: widget.isApproved
                ? 'Completed: January 18, 2025'
                : expectedDate,
            isCompleted: widget.isApproved,
            isCurrent: !widget.isApproved && !widget.isRejected,
          ),
          _buildTimelineItem(
            title: 'Registration Approval',
            subtitle: widget.isApproved ? 'Approved: January 19, 2025' : 'Pending',
            isCompleted: widget.isApproved,
            isLast: true,
            isPending: !widget.isApproved,
          ),
        ],
      ),
    );
  }

  /// Builds a single timeline item
  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required bool isCompleted,
    bool isCurrent = false,
    bool isFirst = false,
    bool isLast = false,
    bool isPending = false,
  }) {
    final Color circleColor = isCompleted
        ? AppColors.brown
        : isCurrent
            ? AppColors.brown
            : Colors.grey[300]!;

    final Color lineColor = isCompleted ? AppColors.brown : Colors.grey[300]!;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator column
          Column(
            children: [
              // Circle indicator
              Container(
                width: 16.w,
                height: 16.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted || isCurrent ? circleColor : Colors.transparent,
                  border: Border.all(
                    color: circleColor,
                    width: 2,
                  ),
                ),
              ),
              // Connecting line
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.w,
                    color: lineColor,
                  ),
                ),
            ],
          ),
          SizedBox(width: 16.w),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the bottom button based on status
  Widget _buildBottomButton() {
    String buttonText;
    if (widget.isApproved) {
      buttonText = 'Back to Home';
    } else if (widget.isRejected) {
      buttonText = 'Back to Login';
    } else {
      buttonText = 'Contact Support';
    }

    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: () async {
          if (widget.isApproved) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const MainNavigationScreen(),
              ),
              (route) => false,
            );
          } else if (widget.isRejected) {
            // Logout the user before going back to login
            await ref.read(authProvider.notifier).logout();
            // Navigate to login screen
            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            }
          } else {
            // Contact support action - navigate to contact details screen
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const ContactDetailsScreen(),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brown,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.r),
          ),
        ),
        child: Text(
          buttonText,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Builds the logout button for pending status
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: OutlinedButton(
        onPressed: () async {
          // Logout the user
          await ref.read(authProvider.notifier).logout();
          // Navigate to login screen
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          }
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.brown, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.r),
          ),
        ),
        child: Text(
          'Logout',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.brown,
          ),
        ),
      ),
    );
  }

  /// Helper method to get month name from month number
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  /// Helper method to format time in 12-hour format with AM/PM
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}
