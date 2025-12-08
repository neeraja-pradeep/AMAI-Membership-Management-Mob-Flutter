import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/app/theme/typography.dart';
import 'package:myapp/features/aswas_plus/domain/entities/nominee.dart';
import 'package:myapp/features/home/application/providers/home_providers.dart';
import 'package:myapp/features/home/application/states/aswas_state.dart';
import 'package:myapp/features/home/application/states/nominees_state.dart';
import 'package:myapp/features/home/domain/entities/aswas_plus.dart';
import 'package:myapp/features/aswas_plus/presentation/components/policy_details_card.dart';
import 'package:myapp/features/aswas_plus/presentation/components/scheme_details_section.dart';
import 'package:myapp/features/aswas_plus/presentation/components/nominee_info_card.dart';
import 'package:myapp/features/aswas_plus/presentation/components/download_documents_section.dart';
import 'package:myapp/features/aswas_plus/presentation/components/note_card.dart';
import 'package:myapp/features/aswas_plus/presentation/components/not_enrolled_card.dart';
import 'package:myapp/features/aswas_plus/presentation/screens/register_here_screen.dart';
import 'package:myapp/features/aswas_plus/presentation/screens/renew_membership_screen.dart';
import 'package:myapp/features/profile/presentation/screens/edit_nominee_screen.dart';

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
      ref.read(nomineesStateProvider.notifier).refresh();
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
    );
  }

  /// Pull-to-refresh handler
  Future<void> _onRefresh() async {
    await Future.wait([
      ref.read(aswasStateProvider.notifier).refresh(),
      ref.read(nomineesStateProvider.notifier).refresh(),
    ]);
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
    final nomineesState = ref.watch(nomineesStateProvider);
    final nomineesCount = nomineesState.currentData?.length ?? 0;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Policy Details Card
          PolicyDetailsCard(
            aswasPlus: aswasPlus,
            nomineesCount: nomineesCount,
          ),

          SizedBox(height: 12.h),

          // Download PDF Button
          _buildDownloadPdfButton(aswasPlus.policyPdfUrl),

          SizedBox(height: 24.h),

          // Expired message (shown only when policy is expired)
          if (aswasPlus.isExpired) ...[
            _buildExpiredMessage(),
            SizedBox(height: 24.h),
          ],

          // Scheme Details Section
          SchemeDetailsSection(
            productDescription: aswasPlus.productDescription,
            showRenewButton: aswasPlus.isExpired,
            onRenewPressed: _onRenewPressed,
          ),

          SizedBox(height: 24.h),

          // Nominee Information Card
          _buildNomineeSection(nomineesState),

          SizedBox(height: 24.h),

          // Download Documents Section
          const DownloadDocumentsSection(),

          SizedBox(height: 24.h),

          // Note Card
          const NoteCard(),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  /// Builds the nominee section based on state
  Widget _buildNomineeSection(NomineesState nomineesState) {
    return nomineesState.when(
      initial: () => const NomineeInfoCardShimmer(),
      loading: (previousData) {
        if (previousData != null && previousData.isNotEmpty) {
          return NomineeInfoCard(
            nominees: previousData,
            onRequestChange: _onRequestNomineeChange,
          );
        }
        return const NomineeInfoCardShimmer();
      },
      loaded: (nominees) => NomineeInfoCard(
        nominees: nominees,
        onRequestChange: _onRequestNomineeChange,
      ),
      error: (failure, cachedData) {
        if (cachedData != null && cachedData.isNotEmpty) {
          return NomineeInfoCard(
            nominees: cachedData,
            onRequestChange: _onRequestNomineeChange,
          );
        }
        return const SizedBox.shrink();
      },
      empty: () => const SizedBox.shrink(),
    );
  }

  /// Handles request change button press
  void _onRequestNomineeChange() {
    // Get the first nominee from the state
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
  }

  /// Handles renew button press
  void _onRenewPressed() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const RenewMembershipScreen(),
      ),
    );
  }

  /// Builds the Download PDF button
  Widget _buildDownloadPdfButton(String? pdfUrl) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _downloadPolicyPdf(pdfUrl),
        icon: Icon(
          Icons.download_rounded,
          size: 20.sp,
          color: AppColors.primary,
        ),
        label: Text(
          'Download PDF',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          side: BorderSide(color: AppColors.primary, width: 1.5.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }

  /// Downloads the policy PDF
  Future<void> _downloadPolicyPdf(String? pdfUrl) async {
    if (pdfUrl == null || pdfUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String fullUrl = pdfUrl;
    if (!pdfUrl.startsWith('http://') && !pdfUrl.startsWith('https://')) {
      fullUrl = 'https://$pdfUrl';
    }

    try {
      final uri = Uri.parse(fullUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open PDF'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Builds the expired message widget
  Widget _buildExpiredMessage() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
          width: 1.w,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Your Aswas plus membership has expired. Renew to continue the benefits.',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.error,
                height: 1.4,
              ),
            ),
          ),
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
          const NomineeInfoCardShimmer(),
          SizedBox(height: 24.h),
          const DownloadDocumentsSectionShimmer(),
        ],
      ),
    );
  }

  /// Builds error state with cached data
  Widget _buildErrorWithCachedData(AswasPlus cachedData) {
    final nomineesState = ref.watch(nomineesStateProvider);
    final nomineesCount = nomineesState.currentData?.length ?? 0;

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
                  nomineesCount: nomineesCount,
                ),
                SizedBox(height: 12.h),
                _buildDownloadPdfButton(cachedData.policyPdfUrl),
                SizedBox(height: 24.h),
                if (cachedData.isExpired) ...[
                  _buildExpiredMessage(),
                  SizedBox(height: 24.h),
                ],
                SchemeDetailsSection(
                  productDescription: cachedData.productDescription,
                  showRenewButton: cachedData.isExpired,
                  onRenewPressed: _onRenewPressed,
                ),
                SizedBox(height: 24.h),
                _buildNomineeSection(nomineesState),
                SizedBox(height: 24.h),
                const DownloadDocumentsSection(),
                SizedBox(height: 24.h),
                const NoteCard(),
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

  /// Builds empty state (no policy) - shows non-enrolled view
  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Not Enrolled Card
          NotEnrolledCard(
            onRegisterPressed: _onRegisterPressed,
          ),

          SizedBox(height: 24.h),

          // Scheme Details Section (without renew button)
          const SchemeDetailsSection(
            showRenewButton: false,
          ),

          SizedBox(height: 24.h),

          // Download Documents Section
          const DownloadDocumentsSection(),

          SizedBox(height: 24.h),

          // Note Card
          const NoteCard(),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  /// Handles register button press - navigates to registration screen
  void _onRegisterPressed() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const RegisterHereScreen(),
      ),
    );
  }
}
