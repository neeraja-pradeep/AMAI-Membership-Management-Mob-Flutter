import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Offline mode banner
///
/// SCENARIO 3: App Restart No Internet (12h old cache)
/// - Show non-blocking "offline mode" indicator
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        border: Border(
          bottom: BorderSide(
            color: Colors.orange[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off,
            size: 20.sp,
            color: Colors.orange[900],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Offline mode - Using cached data',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.orange[900],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
