import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/app/theme/typography.dart';
import 'package:myapp/features/home/application/providers/home_providers.dart';
import 'package:myapp/features/home/application/states/aswas_state.dart';
import 'package:myapp/features/home/domain/entities/aswas_plus.dart';
import 'package:myapp/features/aswas_plus/presentation/components/policy_details_card.dart';
import 'package:myapp/features/aswas_plus/presentation/components/scheme_details_section.dart';
import 'package:myapp/features/aswas_plus/presentation/components/download_documents_section.dart';

/// ASWAS Plus Screen - displays insurance policy details
/// Shows policy information for enrolled users
class AswasePlusScreen extends ConsumerStatefulWidget {
  const AswasePlusScreen({super.key});

  @override
  ConsumerState<AswasePlusScreen> createState() => _AswasePlusScreenState();
}

class _AswasePlusScreenState extends ConsumerState<AswasePlusScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aswasStateProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        child: _buildBody(),
      ),
    );
  }

  /// Builds the app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: AppColors.textPrimary,
          size: 20.sp,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'ASWAS PLUS',
        style: AppTypography.titleMedium.copyWith(
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
            // Static for now
          },
        ),
      ],
    );
  }

  /// Pull-to-refresh handler
  Future<void> _onRefresh() async {
    await ref.read(aswasStateProvider.notifier).refresh();
  }

  /// Builds the main body based on state
  Widget _buildBody() {
    final state = ref.watch(aswasStateProvider);

    return state.when(
      initial: () => _buildLoadingShimmer(),
      loading: (previousData) {
        if (previousData != null) {
          return _buildContent(previousData, isLoading: true);
        }
        return _buildLoadingShimmer();
      },
      loaded: (aswasPlus) => _buildContent(aswasPlus),
      error: (failure, cachedData) {
        if (cachedData != null) {
          return _buildErrorWithCachedData(cachedData);
        }
        return _buildErrorState();
      },
      empty: () => _buildEmptyState(),
    );
  }

  /// Builds the main content with policy details
  Widget _buildContent(AswasPlus aswasPlus, {bool isLoading = false}) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Policy Details Card
          PolicyDetailsCard(
            aswasPlus: aswasPlus,
            onRenewPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Renewal flow coming soon'),
                ),
              );
            },
          ),

          SizedBox(height: 24.h),

          // Scheme Details Section
          SchemeDetailsSection(
            productDescription: aswasPlus.productDescription,
          ),

          SizedBox(height: 24.h),

          // Download Documents Section
          const DownloadDocumentsSection(),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  /// Builds loading shimmer
  Widget _buildLoadingShimmer() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PolicyDetailsCardShimmer(),
          SizedBox(height: 24.h),
          const SchemeDetailsSectionShimmer(),
          SizedBox(height: 24.h),
          const DownloadDocumentsSectionShimmer(),
        ],
      ),
    );
  }

  /// Builds error state with cached data
  Widget _buildErrorWithCachedData(AswasPlus cachedData) {
    return Column(
      children: [
        // Error banner
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          color: AppColors.errorLight,
          child: Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Unable to refresh. Showing cached data.',
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
        ),
        // Cached content
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PolicyDetailsCard(
                  aswasPlus: cachedData,
                  onRenewPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Renewal flow coming soon'),
                      ),
                    );
                  },
                ),
                SizedBox(height: 24.h),
                SchemeDetailsSection(
                  productDescription: cachedData.productDescription,
                ),
                SizedBox(height: 24.h),
                const DownloadDocumentsSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds error state without cached data
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'Unable to load policy details',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Please check your connection and try again.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds empty state (no policy)
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield_outlined,
              size: 64.sp,
              color: AppColors.textHint,
            ),
            SizedBox(height: 16.h),
            Text(
              'No Active Policy',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'You don\'t have an active ASWAS Plus policy.\nRegister now to get coverage.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Registration flow coming soon'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Register for Policy',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
