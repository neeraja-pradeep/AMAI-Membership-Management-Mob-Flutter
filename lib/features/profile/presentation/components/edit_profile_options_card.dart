import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/profile/domain/entities/membership_type.dart';

/// Edit profile options card with conditional options based on membership type
/// - Practitioner: All options visible
/// - House Surgeon: Personal Info, Saved Addresses, Professional Details
/// - Student: Personal Info, Saved Addresses only
class EditProfileOptionsCard extends StatelessWidget {
  const EditProfileOptionsCard({
    super.key,
    required this.membershipType,
    this.onPersonalInfoTap,
    this.onAddressesTap,
    this.onAcademicDetailsTap,
    this.onProfessionalDetailsTap,
    this.onNomineeDetailsTap,
  });

  final MembershipType membershipType;
  final VoidCallback? onPersonalInfoTap;
  final VoidCallback? onAddressesTap;
  final VoidCallback? onAcademicDetailsTap;
  final VoidCallback? onProfessionalDetailsTap;
  final VoidCallback? onNomineeDetailsTap;

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
            'Edit Profile Information',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          // Personal Information - visible to all
          _buildOptionItem(
            title: 'Personal Information',
            onTap: onPersonalInfoTap,
          ),
          // Saved Addresses - visible to all
          _buildOptionItem(title: 'Saved Addresses', onTap: onAddressesTap),
          // Academic Details - Practitioner only
          if (membershipType == MembershipType.practitioner)
            _buildOptionItem(
              title: 'Academic Details',
              onTap: onAcademicDetailsTap,
            ),
          // Professional Details - Practitioner and House Surgeon
          if (membershipType == MembershipType.practitioner ||
              membershipType == MembershipType.houseSurgeon)
            _buildOptionItem(
              title: 'Professional Details',
              onTap: onProfessionalDetailsTap,
            ),
          // ASWAS Plus Nominee - Practitioner only
          if (membershipType == MembershipType.practitioner)
            _buildOptionItem(
              title: 'ASWAS Plus Nominee',
              onTap: onNomineeDetailsTap,
              isLast: true,
            ),
          // If student, last item is Saved Addresses
          if (membershipType == MembershipType.student) const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
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
