import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';

/// A step indicator widget for the registration flow.
/// Shows "Step X of 4" title and dot indicators.
class RegistrationStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const RegistrationStepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
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
            color: AppColors.brown,
          ),
        ),

        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalSteps, (index) {
            final isFilled = index < currentStep;

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 6.w),
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled ? AppColors.brown : Colors.grey.shade300,
              ),
            );
          }),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}
