import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/profile/application/providers/profile_providers.dart';
import 'package:myapp/features/profile/domain/entities/membership_type.dart';
import 'package:myapp/features/profile/domain/entities/profile_data.dart';
import 'package:myapp/features/profile/presentation/components/profile_header_section.dart';
import 'package:myapp/features/profile/presentation/components/personal_information_card.dart';
import 'package:myapp/features/profile/presentation/components/edit_profile_options_card.dart';
import 'package:myapp/features/profile/presentation/components/support_preferences_section.dart';
import 'package:myapp/features/profile/presentation/components/profile_loading_shimmer.dart';
import 'package:myapp/features/profile/presentation/screens/edit_personal_info_screen.dart';
import 'package:myapp/features/profile/presentation/screens/edit_address_screen.dart';
import 'package:myapp/features/profile/presentation/screens/edit_academic_details_screen.dart';
import 'package:myapp/features/profile/presentation/screens/edit_professional_details_screen.dart';
import 'package:myapp/features/profile/presentation/screens/edit_nominee_screen.dart';
import 'package:myapp/features/home/application/providers/home_providers.dart';
import 'package:myapp/features/auth/application/providers/auth_provider.dart';
import 'package:myapp/features/auth/presentation/screen/login_screen.dart';

/// Profile Screen - displays user profile with conditional UI based on membership type
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploadingPicture = false;

  @override
  void initState() {
    super.initState();
    // Initialize profile data fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileStateProvider.notifier).initialize();
      ref.read(nomineesStateProvider.notifier).initialize();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(profileStateProvider.notifier).refresh();
  }

  Future<void> _onEditPicture() async {
    // Show bottom sheet to choose camera or gallery
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Image Source',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() {
        _isUploadingPicture = true;
      });

      final userId = ref.read(userIdProvider);
      final result = await ref.read(
        profilePictureUploadProvider(
          ProfilePictureUploadParams(
            userId: userId,
            imagePath: pickedFile.path,
          ),
        ).future,
      );

      if (!mounted) return;

      setState(() {
        _isUploadingPicture = false;
      });

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: AppColors.error,
            ),
          );
        },
        (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          // Refresh profile to show updated picture
          ref.read(profileStateProvider.notifier).refresh();
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingPicture = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
              onEditPicture: _isUploadingPicture ? null : _onEditPicture,
            ),
            if (_isUploadingPicture)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Uploading...',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
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
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => EditPersonalInfoScreen(
                      userProfile: data.userProfile,
                    ),
                  ),
                );
              },
              onAddressesTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const EditAddressScreen(),
                  ),
                );
              },
              onAcademicDetailsTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const EditAcademicDetailsScreen(),
                  ),
                );
              },
              onProfessionalDetailsTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const EditProfessionalDetailsScreen(),
                  ),
                );
              },
              onNomineeDetailsTap: () {
                final nomineesState = ref.read(nomineesStateProvider);
                final nominees = nomineesState.currentData;

                if (nominees == null || nominees.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No nominee data available')),
                  );
                  return;
                }

                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => EditNomineeScreen(nominees: nominees),
                  ),
                );
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
    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await ref.read(authProvider.notifier).logout();
              navigator.pushAndRemoveUntil(
                MaterialPageRoute<void>(
                  builder: (context) => const LoginScreen(),
                ),
                (route) => false,
              );
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
