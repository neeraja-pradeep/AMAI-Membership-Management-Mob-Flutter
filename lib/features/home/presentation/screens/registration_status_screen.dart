import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/app/theme/typography.dart';

/// Registration Status screen shown when membership application is pending or rejected
/// Displays appropriate message based on status
class RegistrationStatusScreen extends StatelessWidget {
  const RegistrationStatusScreen({
    super.key,
    this.isRejected = false,
  });

  /// Whether the application was rejected (if false, it's pending)
  final bool isRejected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.lightBackgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.h),
                // Heading
                Text(
                  'Registration Status',
                  style: AppTypography.headlineMedium.copyWith(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 24.h),
                // Status Card
                isRejected ? _buildRejectedCard() : _buildReviewCard(),
                SizedBox(height: 16.h),
                // Timeline Card (only for pending) or Help Card (for rejected)
                isRejected ? _buildHelpCard(context) : _buildTimelineCard(),
                const Spacer(),
                // Bottom Button
                isRejected
                    ? _buildBackToLoginButton(context)
                    : _buildContactSupportButton(),
                SizedBox(height: 24.h),
              ],
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
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and Header
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.hourglass_top_rounded,
                  color: AppColors.warning,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Registration Under Review',
                  style: AppTypography.titleMedium.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Description text
          Text(
            'Thank you for registering! Your request has been successfully submitted and is now pending administrative review.',
            style: AppTypography.bodyMedium.copyWith(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 20.h),
          // Pending Approval Button (static)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: AppColors.warning.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pending_outlined,
                  color: AppColors.warning,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Pending Approval',
                  style: AppTypography.buttonMedium.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and Header
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.cancel_outlined,
                  color: AppColors.error,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Registration Rejected',
                  style: AppTypography.titleMedium.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Description text
          Text(
            'Unfortunately, your registration could not be approved. You may try again or contact support for more details.',
            style: AppTypography.bodyMedium.copyWith(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 20.h),
          // Rejected Button (static)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: AppColors.error.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.close,
                  color: AppColors.error,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Rejected',
                  style: AppTypography.buttonMedium.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the Help card for rejected status
  Widget _buildHelpCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Need help? Contact Admin or try again',
            style: AppTypography.titleMedium.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          // Email
          Row(
            children: [
              Icon(
                Icons.email_outlined,
                color: AppColors.primary,
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'support@amai.org',
                style: AppTypography.bodyMedium.copyWith(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Phone
          Row(
            children: [
              Icon(
                Icons.phone_outlined,
                color: AppColors.primary,
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                '+91 9876543210',
                style: AppTypography.bodyMedium.copyWith(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the Registration Timeline card (for pending status)
  Widget _buildTimelineCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Registration Timeline',
            style: AppTypography.titleMedium.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 20.h),
          // Timeline items
          _buildTimelineItem(
            title: 'Application Submitted',
            isCompleted: true,
            isFirst: true,
          ),
          _buildTimelineItem(
            title: 'Under Review',
            isCompleted: false,
            isCurrent: true,
          ),
          _buildTimelineItem(
            title: 'Approval',
            isCompleted: false,
            isLast: true,
          ),
        ],
      ),
    );
  }

  /// Builds a single timeline item
  Widget _buildTimelineItem({
    required String title,
    required bool isCompleted,
    bool isCurrent = false,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.success
                    : isCurrent
                        ? AppColors.warning
                        : AppColors.grey200,
                border: Border.all(
                  color: isCompleted
                      ? AppColors.success
                      : isCurrent
                          ? AppColors.warning
                          : AppColors.grey300,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? Icon(
                      Icons.check,
                      color: AppColors.white,
                      size: 14.sp,
                    )
                  : isCurrent
                      ? Center(
                          child: Container(
                            width: 8.w,
                            height: 8.h,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.warning,
                            ),
                          ),
                        )
                      : null,
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: 32.h,
                color: isCompleted ? AppColors.success : AppColors.grey200,
              ),
          ],
        ),
        SizedBox(width: 12.w),
        // Title
        Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              fontSize: 14.sp,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
              color: isCompleted || isCurrent
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the Contact Support button (for pending status)
  Widget _buildContactSupportButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          // Static button - no action
        },
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          'Contact Support',
          style: AppTypography.buttonMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Builds the Back to Login button (for rejected status)
  Widget _buildBackToLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Static button - no action
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          'Back to Login',
          style: AppTypography.buttonMedium.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
