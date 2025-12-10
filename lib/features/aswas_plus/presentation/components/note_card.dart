import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';

/// Static Note Card for ASWAS Plus screen
/// Shows important information about claims and policy updates
class NoteCard extends StatelessWidget {
  const NoteCard({super.key});

  // Orange/Amber color for note card
  static const Color _noteColor = Color(0xFFE67E22);
  static const Color _noteBackgroundColor = Color(0xFFFDF2E9);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _noteBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _noteColor.withOpacity(0.2),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading with warning icon
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: _noteColor,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Note',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: _noteColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Content
          Text(
            'All claims and policy updates will be verified by the AMAI State Committee. For assistance, contact your district coordinator.',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
