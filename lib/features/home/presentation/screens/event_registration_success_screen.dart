import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/home/domain/entities/upcoming_event.dart';
import 'package:myapp/features/navigation/application/providers/navigation_providers.dart';
import 'package:myapp/features/navigation/presentation/screens/main_navigation_screen.dart';

/// Event registration success screen shown after successful payment
class EventRegistrationSuccessScreen extends ConsumerWidget {
  const EventRegistrationSuccessScreen({
    required this.event,
    super.key,
  });

  final UpcomingEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Success Icon
              Container(
                width: 120.w,
                height: 120.h,
                decoration: BoxDecoration(
                  color: AppColors.brown.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 80.sp,
                  color: AppColors.brown,
                ),
              ),
              SizedBox(height: 32.h),
              // Success Title
              Text(
                'Registration Successful!',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              // Success Message
              Text(
                'You have successfully registered for',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                event.title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.grey300),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16.sp,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          event.displayDate,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16.sp,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: Text(
                            event.venue,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // // View Status Button
              // SizedBox(
              //   width: double.infinity,
              //   height: 50.h,
              //   child: ElevatedButton(
              //     onPressed: () {
              //       // Navigate to Main Navigation Screen with Events tab selected
              //       ref.read(currentTabIndexProvider.notifier).state = 1; // Events tab
              //       Navigator.of(context).pushAndRemoveUntil(
              //         MaterialPageRoute(
              //           builder: (context) => const MainNavigationScreen(),
              //         ),
              //         (route) => false, // Remove all previous routes
              //       );
              //     },
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: AppColors.brown,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(25.r),
              //       ),
              //       elevation: 0,
              //     ),
              //     child: Text(
              //       'View Status',
              //       style: TextStyle(
              //         fontSize: 16.sp,
              //         fontWeight: FontWeight.w600,
              //         color: AppColors.white,
              //       ),
              //     ),
              //   ),
              // ),
              // SizedBox(height: 16.h),
              // Back to Home Button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: OutlinedButton(
                  onPressed: () {
                    // Navigate to Main Navigation Screen with Home tab selected
                    ref.read(currentTabIndexProvider.notifier).state = 0; // Home tab
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const MainNavigationScreen(),
                      ),
                      (route) => false, // Remove all previous routes
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.brown),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                  ),
                  child: Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brown,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
