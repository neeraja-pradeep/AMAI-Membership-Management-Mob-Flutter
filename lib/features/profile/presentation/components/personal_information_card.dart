import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/profile/domain/entities/profile_data.dart';

/// Personal information card showing membership details
class PersonalInformationCard extends StatelessWidget {
  const PersonalInformationCard({super.key, required this.profileData});

  final ProfileData profileData;

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
            'Personal Information',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          _buildInfoRow('Member ID', profileData.membershipNumber ?? 'N/A'),
          _buildDivider(),
          _buildInfoRow(
            'Specialization',
            profileData.membershipType.displayName,
          ),
          _buildDivider(),
          _buildInfoRow(
            'Gender',
            profileData.userProfile.formattedGender ?? 'N/A',
          ),
          _buildDivider(),
          _buildInfoRow('Valid Until', _formatValidUntil()),
          _buildDivider(),
          _buildInfoRow(
            'Date of Birth',
            profileData.userProfile.formattedDateOfBirth ?? 'N/A',
          ),
        ],
      ),
    );
  }

  String _formatValidUntil() {
    if (profileData.validUntil == null) return 'N/A';
    return DateFormat('dd MMM yyyy').format(profileData.validUntil!);
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(color: AppColors.dividerLight, height: 1);
  }
}
