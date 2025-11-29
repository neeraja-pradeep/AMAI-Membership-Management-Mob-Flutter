import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/app_router.dart';
import '../../domain/entities/registration/practitioner_registration.dart';
import '../../domain/entities/registration/registration_step.dart';
import '../../application/notifiers/registration_state_notifier.dart';

/// Resume registration dialog
///
/// SCENARIO 2: User re-enters registration
/// - Shows when reg_incomplete_flag = true and <24h
/// - Displays progress percentage, current step, last updated date
/// - Options: "Continue" or "Start Fresh"
class ResumeRegistrationDialog extends ConsumerWidget {
  final PractitionerRegistration existingRegistration;

  const ResumeRegistrationDialog({
    super.key,
    required this.existingRegistration,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completionPercentage = existingRegistration.completionPercentage;
    final currentStep = existingRegistration.currentStep;
    final lastUpdated = existingRegistration.lastUpdatedAt;

    return AlertDialog(
      title: const Text('Continue Registration?'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have an incomplete registration from ${DateFormat.yMd().add_jm().format(lastUpdated)}',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
            ),
            SizedBox(height: 20.h),

            // Progress indicator
            LinearProgressIndicator(
              value: completionPercentage,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
              minHeight: 8.h,
            ),
            SizedBox(height: 8.h),

            // Progress text
            Text(
              '${(completionPercentage * 100).toStringAsFixed(0)}% complete',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 8.h),

            // Current step
            Text(
              'Step ${currentStep.stepNumber} of ${RegistrationStep.totalSteps}: ${currentStep.displayName}',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 16.h),

            // Warning for stale data
            if (_isStale(existingRegistration.createdAt))
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange[700],
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'This registration is about to expire. Please complete it soon.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.orange[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        // OPTION 1: Start Fresh
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await ref
                .read(registrationProvider.notifier)
                .startFreshRegistration();
          },
          child: Text(
            'Start Fresh',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ),

        // OPTION 2: Continue
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            ref
                .read(registrationProvider.notifier)
                .resumeRegistration(existingRegistration);

            // Navigate to the appropriate step screen
            _navigateToStep(context, currentStep);
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          ),
          child: Text('Continue', style: TextStyle(fontSize: 14.sp)),
        ),
      ],
    );
  }

  /// Check if data is stale (>20 hours old)
  bool _isStale(DateTime createdAt) {
    final ageInHours = DateTime.now().difference(createdAt).inHours;
    return ageInHours >= 20 && ageInHours < 24;
  }

  /// Navigate to appropriate step screen
  void _navigateToStep(BuildContext context, RegistrationStep currentStep) {
    final route = switch (currentStep) {
      RegistrationStep.personalDetails => AppRouter.registrationPersonal,
      RegistrationStep.professionalDetails =>
        AppRouter.registrationProfessional,
      RegistrationStep.addressDetails => AppRouter.registrationAddress,
      RegistrationStep.documentUploads => AppRouter.registrationDocuments,
      RegistrationStep.payment => AppRouter.registrationPayment,
      RegistrationStep.membershipDetails => AppRouter.registrationMembership,
    };

    Navigator.pushNamed(context, route);
  }
}

/// Helper function to show resume dialog
Future<void> showResumeRegistrationDialog(
  BuildContext context,
  PractitionerRegistration existingRegistration,
) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must choose an option
    builder: (context) =>
        ResumeRegistrationDialog(existingRegistration: existingRegistration),
  );
}
