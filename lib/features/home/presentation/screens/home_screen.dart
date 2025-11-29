import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/app/theme/typography.dart';
import 'package:myapp/features/home/application/providers/home_providers.dart';
import 'package:myapp/features/home/application/states/membership_state.dart';
import 'package:myapp/features/home/presentation/components/membership_card_widget.dart';

/// Home screen - primary landing screen after authentication
/// Displays membership card, quick actions, events, and announcements
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize data fetch when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(membershipStateProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                _buildHeader(),
                SizedBox(height: 24.h),
                _buildMembershipCard(),
                SizedBox(height: 24.h),
                // Placeholder for other sections
                _buildSectionPlaceholder('Quick Actions'),
                SizedBox(height: 24.h),
                _buildSectionPlaceholder('Upcoming Events'),
                SizedBox(height: 24.h),
                _buildSectionPlaceholder('Announcements'),
                SizedBox(height: 100.h), // Bottom padding for navigation
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Pull-to-refresh handler
  Future<void> _onRefresh() async {
    await ref.read(membershipStateProvider.notifier).refresh();
  }

  /// Builds the home header with greeting
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 4.h),
              Consumer(
                builder: (context, ref, child) {
                  final state = ref.watch(membershipStateProvider);
                  final name = state.currentData?.holderName ?? 'Member';
                  return Text(
                    'Hi, $name',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  );
                },
              ),
            ],
          ),
          Row(
            children: [
              _buildIconButton(
                icon: Icons.notifications_outlined,
                onPressed: () {
                  // TODO: Navigate to notifications
                },
              ),
              SizedBox(width: 8.w),
              _buildIconButton(
                icon: Icons.person_outline,
                onPressed: () {
                  // TODO: Navigate to profile
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds an icon button for the header
  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 44.w,
      height: 44.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: AppColors.grey700,
          size: 22.sp,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  /// Builds the membership card section
  Widget _buildMembershipCard() {
    final state = ref.watch(membershipStateProvider);

    return state.when(
      initial: () => const MembershipCardShimmer(),
      loading: (previousData) {
        // Show previous data while loading, or shimmer if no data
        if (previousData != null) {
          return Stack(
            children: [
              MembershipCardWidget(membershipCard: previousData),
              Positioned.fill(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 24.w,
                      height: 24.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return const MembershipCardShimmer();
      },
      loaded: (membershipCard) {
        return MembershipCardWidget(
          membershipCard: membershipCard,
          onTap: () {
            // TODO: Navigate to membership details
          },
        );
      },
      error: (failure, cachedData) {
        return Column(
          children: [
            // Error banner
            _buildErrorBanner(failure.toUserMessage()),
            SizedBox(height: 16.h),
            // Show cached data if available
            if (cachedData != null)
              MembershipCardWidget(membershipCard: cachedData)
            else
              MembershipCardEmpty(
                onApply: () {
                  // TODO: Navigate to membership application
                },
              ),
          ],
        );
      },
      empty: () => MembershipCardEmpty(
        onApply: () {
          // TODO: Navigate to membership application
        },
      ),
    );
  }

  /// Builds an error banner
  Widget _buildErrorBanner(String message) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
          TextButton(
            onPressed: _onRefresh,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Retry',
              style: AppTypography.buttonSmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Placeholder for sections to be implemented
  Widget _buildSectionPlaceholder(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.titleMedium,
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            height: 100.h,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Center(
              child: Text(
                'Coming Soon',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textHint,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
