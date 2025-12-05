import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';

/// A step indicator widget for the registration flow.
/// Shows "Step X of 4" title and dot indicators.
class RegistrationStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String stepTitle;

  const RegistrationStepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
    required this.stepTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Step $currentStep of $totalSteps",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          stepTitle,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalSteps, (index) {
            final isActive = index < currentStep;
            final isCurrent = index == currentStep - 1;
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              width: isCurrent ? 24.w : 10.w,
              height: 10.h,
              decoration: BoxDecoration(
                color: isActive ? AppColors.brown : Colors.grey[300],
                borderRadius: BorderRadius.circular(5.r),
              ),
            );
          }),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}
