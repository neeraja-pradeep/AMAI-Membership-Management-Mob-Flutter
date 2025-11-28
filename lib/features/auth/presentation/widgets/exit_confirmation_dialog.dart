import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../application/notifiers/registration_state_notifier.dart';

/// Exit confirmation dialog
///
/// NAVIGATION SPEC:
/// - Dialog: "Your progress will be saved. Exit registration?"
/// - Actions: "Stay" and "Exit"
/// - On exit: Save to Hive, navigate to previous screen
///
/// SHOWN WHEN:
/// - User presses back button on Screen 1 (Personal Details)
/// - User tries to exit registration flow
class ExitConfirmationDialog extends ConsumerWidget {
  final VoidCallback? onExit;

  const ExitConfirmationDialog({
    super.key,
    this.onExit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange[700],
            size: 24.sp,
          ),
          SizedBox(width: 8.w),
          const Text('Exit Registration?'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your progress will be saved.',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'You can continue from where you left off within the next 24 hours.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      actions: [
        // OPTION 1: Stay (continue registration)
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false); // Return false = stay
          },
          child: Text(
            'Stay',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // OPTION 2: Exit (save and leave)
        ElevatedButton(
          onPressed: () async {
            // Auto-save progress to Hive
            await ref.read(registrationProvider.notifier).autoSaveProgress();

            // Close dialog
            if (context.mounted) {
              Navigator.of(context).pop(true); // Return true = exit
            }

            // Execute custom exit callback
            onExit?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[600],
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 12.h,
            ),
          ),
          child: Text(
            'Exit',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

/// Helper function to show exit confirmation dialog
///
/// Returns:
/// - `true` if user chose to exit
/// - `false` if user chose to stay
/// - `null` if dialog was dismissed
Future<bool?> showExitConfirmationDialog(
  BuildContext context, {
  VoidCallback? onExit,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true, // Allow dismiss by tapping outside
    builder: (context) => ExitConfirmationDialog(onExit: onExit),
  );
}
