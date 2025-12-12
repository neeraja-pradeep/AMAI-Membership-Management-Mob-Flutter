import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/home/application/providers/home_providers.dart';
import 'package:myapp/features/home/infrastructure/models/area_admin_model.dart';

/// Contact Details Screen
/// Shows contact information and about AMAI section
class ContactDetailsScreen extends ConsumerStatefulWidget {
  const ContactDetailsScreen({super.key});

  @override
  ConsumerState<ContactDetailsScreen> createState() => _ContactDetailsScreenState();
}

class _ContactDetailsScreenState extends ConsumerState<ContactDetailsScreen> {
  bool _isLoading = true;
  AreaAdminsResponse? _areaAdmins;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAreaAdmins();
  }

  /// Fetch area admins from API
  Future<void> _fetchAreaAdmins() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final homeApi = ref.read(homeApiProvider);
      final response = await homeApi.fetchAreaAdmins();

      if (response.isSuccess && response.data != null) {
        setState(() {
          _areaAdmins = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load area admins';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Contact Details',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.lightBackgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle text
            Text(
              'Get in touch with your regional and state representatives.',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),

            // About AMAI Card
            _buildAboutAmaiCard(),

            SizedBox(height: 24.h),

            // Area Admin Cards
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(
                  color: AppColors.brown,
                ),
              )
            else if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.red,
                ),
              )
            else if (_areaAdmins != null)
              ..._buildAreaAdminCards(),
          ],
        ),
          ),
        ),
      ),
    );
  }

  /// Builds the About AMAI card
  Widget _buildAboutAmaiCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card heading
          Text(
            'About AMAI',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),

          // Card content
          Text(
            'Ayurveda Medical Association of India (AMAI), founded in 1978, is the national organization representing qualified Ayurveda doctors across India. AMAI stands as the unified platform for all sectors of Ayurveda — private practitioners, academicians, government doctors, researchers, pharmaceutical professionals, postgraduate scholars, and students — working together for the advancement and protection of this ancient system of medicine.',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds area admin cards grouped by group name
  List<Widget> _buildAreaAdminCards() {
    final cards = <Widget>[];

    if (_areaAdmins == null) return cards;

    // Get all admins (both user and parent admins)
    final allAdmins = _areaAdmins!.allAdmins;

    // Create a card for each group for each admin
    for (final admin in allAdmins) {
      final userDetail = admin.userDetail;

      // If admin has groups, create a card for each group
      if (userDetail.groupsName.isNotEmpty) {
        for (final groupName in userDetail.groupsName) {
          cards.add(_buildAdminCard(
            groupName: groupName,
            firstName: userDetail.firstName,
            email: userDetail.email,
            phone: userDetail.phone,
          ));
          cards.add(SizedBox(height: 16.h));
        }
      } else {
        // If no groups, create a card without group name
        cards.add(_buildAdminCard(
          groupName: 'Admin',
          firstName: userDetail.firstName,
          email: userDetail.email,
          phone: userDetail.phone,
        ));
        cards.add(SizedBox(height: 16.h));
      }
    }

    return cards;
  }

  /// Builds a single admin card
  Widget _buildAdminCard({
    required String groupName,
    required String firstName,
    required String email,
    required String phone,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group name as heading
          Text(
            groupName,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),

          // First name
          Text(
            firstName,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),

          // Email
          Text(
            email,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),

          // Phone
          Text(
            phone,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
