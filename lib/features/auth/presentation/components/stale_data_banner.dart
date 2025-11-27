import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../application/providers/auth_provider.dart';

/// Stale data warning banner
///
/// SCENARIO 5: Expired Cache >24h with Internet
/// - Show visible "data may be outdated" warning banner
/// - Tap to refresh
class StaleDataBanner extends ConsumerWidget {
  const StaleDataBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        // Trigger immediate refresh
        ref.read(authProvider.notifier).checkAuthentication();
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          color: Colors.amber[100],
          border: Border(
            bottom: BorderSide(
              color: Colors.amber[300]!,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 20.sp,
              color: Colors.amber[900],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Data may be outdated • Tap to refresh',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.amber[900],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.refresh,
              size: 20.sp,
              color: Colors.amber[900],
            ),
          ],
        ),
      ),
    );
  }
}
