import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/membership/application/providers/membership_providers.dart';
import 'package:myapp/features/membership/application/states/membership_screen_state.dart';
import 'package:myapp/features/membership/presentation/components/current_status_card.dart';

/// Main Membership Screen
/// Displays current membership status, digital card, and payment receipts
class MembershipScreen extends ConsumerStatefulWidget {
  const MembershipScreen({super.key});

  @override
  ConsumerState<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends ConsumerState<MembershipScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch membership data on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(membershipScreenStateProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(membershipScreenStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(membershipScreenStateProvider.notifier).refresh();
        },
        child: _buildBody(state),
      ),
    );
  }

  /// Builds the custom app bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: AppColors.textPrimary,
          size: 20.sp,
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Membership',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: AppColors.textPrimary,
            size: 24.sp,
          ),
          onPressed: () {
            // Static notification icon - no functionality for now
          },
        ),
      ],
    );
  }

  /// Builds the main body content based on state
  Widget _buildBody(MembershipScreenState state) {
    return state.when(
      initial: () => _buildLoadingState(),
      loading: (previousData) => _buildLoadingState(previousData: previousData),
      loaded: (membershipStatus) => _buildLoadedState(membershipStatus),
      empty: () => _buildEmptyState(),
      error: (failure, cachedData) => _buildErrorState(failure, cachedData),
    );
  }

  /// Builds the loading state with shimmer
  Widget _buildLoadingState({
    dynamic previousData,
  }) {
    // If we have previous data, show it with a loading indicator
    if (previousData != null) {
      return Stack(
        children: [
          _buildContent(previousData),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              backgroundColor: AppColors.grey200,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      );
    }

    // Show shimmer loading
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.w),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CurrentStatusCardShimmer(),
          // TODO: Add more shimmers for other sections
        ],
      ),
    );
  }

  /// Builds the loaded state with membership data
  Widget _buildLoadedState(dynamic membershipStatus) {
    return _buildContent(membershipStatus);
  }

  /// Builds the content with membership data
  Widget _buildContent(dynamic membershipStatus) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Status Card
          CurrentStatusCard(
            membershipStatus: membershipStatus,
            onRenewalPressed: () {
              // TODO: Navigate to renewal screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Renewal flow coming soon'),
                ),
              );
            },
          ),

          SizedBox(height: 16.h),

          // TODO: Add Digital Membership Card section
          // TODO: Add Payment Receipts section
        ],
      ),
    );
  }

  /// Builds the empty state when no membership exists
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.card_membership_outlined,
                size: 64.sp,
                color: AppColors.grey400,
              ),
              SizedBox(height: 16.h),
              Text(
                'No Membership Found',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'You do not have an active membership.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the error state with optional cached data
  Widget _buildErrorState(dynamic failure, dynamic cachedData) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // Error banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            color: AppColors.errorLight,
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    failure.toUserMessage(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.error,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref
                        .read(membershipScreenStateProvider.notifier)
                        .initialize();
                  },
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Show cached data if available
          if (cachedData != null)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: CurrentStatusCard(
                membershipStatus: cachedData,
                onRenewalPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Renewal flow coming soon'),
                    ),
                  );
                },
              ),
            )
          else
            Padding(
              padding: EdgeInsets.all(32.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_off_outlined,
                    size: 64.sp,
                    color: AppColors.grey400,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Unable to load membership',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Please check your connection and try again.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
