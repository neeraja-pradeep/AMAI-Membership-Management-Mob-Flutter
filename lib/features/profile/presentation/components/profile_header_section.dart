import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/profile/domain/entities/user_profile.dart';

/// Profile header section showing avatar, name, and email
class ProfileHeaderSection extends StatelessWidget {
  const ProfileHeaderSection({
    super.key,
    required this.userProfile,
    this.onEditPicture,
  });

  final UserProfile userProfile;
  final VoidCallback? onEditPicture;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Profile Avatar with Edit Icon
        Stack(
          children: [
            _buildAvatar(),
            Positioned(
              right: 0,
              bottom: 0,
              child: _buildEditButton(),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        // User Name
        Text(
          userProfile.fullName,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        // User Email
        Text(
          userProfile.email,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 100.w,
      height: 100.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.grey200,
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 3,
        ),
      ),
      child: userProfile.hasProfilePicture
          ? ClipOval(
              child: Image.network(
                userProfile.profilePictureUrl!,
                fit: BoxFit.cover,
                width: 100.w,
                height: 100.w,
                errorBuilder: (context, error, stackTrace) {
                  return _buildInitialsAvatar();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            )
          : _buildInitialsAvatar(),
    );
  }

  Widget _buildInitialsAvatar() {
    return Center(
      child: Text(
        userProfile.initials,
        style: TextStyle(
          fontSize: 32.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildEditButton() {
    return GestureDetector(
      onTap: onEditPicture,
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
          border: Border.all(
            color: AppColors.white,
            width: 2,
          ),
        ),
        child: Icon(
          Icons.camera_alt,
          size: 16.sp,
          color: AppColors.white,
        ),
      ),
    );
  }
}
