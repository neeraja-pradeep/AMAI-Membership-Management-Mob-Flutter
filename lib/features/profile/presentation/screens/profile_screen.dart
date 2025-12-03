import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/profile/application/providers/profile_providers.dart';
import 'package:myapp/features/profile/domain/entities/membership_type.dart';
import 'package:myapp/features/profile/domain/entities/profile_data.dart';
import 'package:myapp/features/profile/presentation/components/profile_header_section.dart';
import 'package:myapp/features/profile/presentation/components/personal_information_card.dart';
import 'package:myapp/features/profile/presentation/components/edit_profile_options_card.dart';
import 'package:myapp/features/profile/presentation/components/support_preferences_section.dart';
import 'package:myapp/features/profile/presentation/components/profile_loading_shimmer.dart';

/// Profile Screen - displays user profile with conditional UI based on membership type
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize profile data fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileStateProvider.notifier).initialize();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(profileStateProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Navigate to notifications
            },
            icon: Icon(
              Icons.notifications_outlined,
              color: AppColors.textPrimary,
              size: 24.sp,
            ),
          ),
        ],
      ),
      body: state.when(
        initial: () => const ProfileLoadingShimmer(),
        loading: (previousData) {
          if (previousData != null) {
            return _buildProfileContent(previousData, isLoading: true);
          }
          return const ProfileLoadingShimmer();
        },
        loaded: (data) => _buildProfileContent(data),
        error: (failure, cachedData) {
          if (cachedData != null) {
            return _buildProfileContent(cachedData, errorMessage: failure.message);
          }
          return _buildErrorState(failure.message);
        },
      ),
    );
  }

  Widget _buildProfileContent(
    ProfileData data, {
    bool isLoading = false,
    String? errorMessage,
  }) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            if (errorMessage != null) _buildErrorBanner(errorMessage),
            if (isLoading) _buildLoadingIndicator(),
            SizedBox(height: 24.h),
            // Profile Header Section
            ProfileHeaderSection(
              userProfile: data.userProfile,
              onEditPicture: () {
                // TODO: Handle edit picture (static for now)
              },
            ),
            SizedBox(height: 24.h),
            // Personal Information Card
            PersonalInformationCard(
              profileData: data,
            ),
            SizedBox(height: 16.h),
            // Edit Profile Options Card (conditional based on membership type)
            EditProfileOptionsCard(
              membershipType: data.membershipType,
              onPersonalInfoTap: () {
                // TODO: Navigate to Edit Personal Information
              },
              onAddressesTap: () {
                // TODO: Navigate to Edit Addresses
              },
              onAcademicDetailsTap: () {
                // TODO: Navigate to Edit Academic Details (Practitioner only)
              },
              onProfessionalDetailsTap: () {
                // TODO: Navigate to Edit Professional Details
              },
              onNomineeDetailsTap: () {
                // TODO: Navigate to Edit Nominee Details (Practitioner only)
              },
            ),
            SizedBox(height: 16.h),
            // Support & Preferences Section
            SupportPreferencesSection(
              onPrivacySecurityTap: () {
                // TODO: Navigate to Privacy & Security
              },
              onHelpSupportTap: () {
                // TODO: Navigate to Help & Support
              },
              onTermsPoliciesTap: () {
                // TODO: Navigate to Terms & Policies
              },
            ),
            SizedBox(height: 24.h),
            // Logout Button
            _buildLogoutButton(),
            SizedBox(height: 100.h), // Bottom padding for navigation
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: const LinearProgressIndicator(
        backgroundColor: AppColors.grey200,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.error,
              ),
            ),
          ),
          TextButton(
            onPressed: _onRefresh,
            child: Text(
              'Retry',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: AppColors.grey400,
            ),
            SizedBox(height: 16.h),
            Text(
              'Unable to load profile',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
              child: Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () {
            // TODO: Handle logout (static for now)
            _showLogoutDialog();
          },
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            side: const BorderSide(color: AppColors.error),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Text(
            'Logout',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement actual logout
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
