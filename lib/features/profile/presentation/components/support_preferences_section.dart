import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';

/// Support and preferences section with static options
class SupportPreferencesSection extends StatelessWidget {
  const SupportPreferencesSection({
    super.key,
    this.onPrivacySecurityTap,
    this.onHelpSupportTap,
    this.onTermsPoliciesTap,
  });

  final VoidCallback? onPrivacySecurityTap;
  final VoidCallback? onHelpSupportTap;
  final VoidCallback? onTermsPoliciesTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          const BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Support & Preferences',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          _buildOptionItem(
            icon: Icons.lock_outline,
            title: 'Privacy & Security',
            onTap: onPrivacySecurityTap,
          ),
          _buildOptionItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: onHelpSupportTap,
          ),
          _buildOptionItem(
            icon: Icons.description_outlined,
            title: 'Terms & Policies',
            onTap: onTermsPoliciesTap,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Row(
              children: [
                Icon(icon, color: AppColors.grey600, size: 22.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.grey400,
                  size: 24.sp,
                ),
              ],
            ),
          ),
        ),
        if (!isLast) const Divider(color: AppColors.dividerLight, height: 1),
      ],
    );
  }
}
