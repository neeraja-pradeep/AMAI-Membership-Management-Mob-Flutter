import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/app/theme/typography.dart';
import 'package:myapp/features/home/application/providers/home_providers.dart';
import 'package:myapp/features/home/application/states/announcements_state.dart';
import 'package:myapp/features/home/application/states/aswas_state.dart';
import 'package:myapp/features/home/application/states/events_state.dart';
import 'package:myapp/features/home/application/states/membership_state.dart';
import 'package:myapp/features/home/presentation/components/announcements_section.dart';
import 'package:myapp/features/home/presentation/components/aswas_card_widget.dart';
import 'package:myapp/features/home/presentation/components/membership_card_widget.dart';
import 'package:myapp/features/home/presentation/components/quick_actions_section.dart';
import 'package:myapp/features/home/presentation/components/upcoming_events_section.dart';

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
      ref.read(aswasStateProvider.notifier).initialize();
      ref.read(eventsStateProvider.notifier).initialize();
      ref.read(announcementsStateProvider.notifier).initialize();
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
                // Quick Actions section
                QuickActionsSection(
                  onViewAll: () {
                    // TODO: Navigate to all quick actions
                  },
                  onMembershipTap: () {
                    // TODO: Navigate to membership
                  },
                  onAswasePlusTap: () {
                    // TODO: Navigate to Aswas Plus
                  },
                  onAcademyTap: () {
                    // TODO: Navigate to Academy
                  },
                  onContactsTap: () {
                    // TODO: Navigate to Contacts
                  },
                ),
                SizedBox(height: 24.h),
                // Aswas Plus card (only shows if active policy exists)
                _buildAswasCard(),
                // Upcoming Events section
                _buildUpcomingEvents(),
                SizedBox(height: 24.h),
                // Announcements section
                _buildAnnouncements(),
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
    await Future.wait([
      ref.read(membershipStateProvider.notifier).refresh(),
      ref.read(aswasStateProvider.notifier).refresh(),
      ref.read(eventsStateProvider.notifier).refresh(),
      ref.read(announcementsStateProvider.notifier).refresh(),
    ]);
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

  /// Builds the Aswas Plus card section
  /// Only shows if user has an active insurance policy
  Widget _buildAswasCard() {
    final state = ref.watch(aswasStateProvider);

    return state.when(
      initial: () => const SizedBox.shrink(), // Don't show shimmer initially
      loading: (previousData) {
        // Show previous data while loading, or nothing if no data
        if (previousData != null) {
          return Column(
            children: [
              Stack(
                children: [
                  AswasCardWidget(aswasPlus: previousData),
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.aswasCardGradientStart,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
            ],
          );
        }
        return const SizedBox.shrink(); // No shimmer if no previous data
      },
      loaded: (aswasPlus) {
        return Column(
          children: [
            AswasCardWidget(
              aswasPlus: aswasPlus,
              onTap: () {
                // TODO: Navigate to Aswas Plus details
              },
            ),
            SizedBox(height: 24.h),
          ],
        );
      },
      error: (failure, cachedData) {
        // Show cached data if available, otherwise nothing
        // Don't show error banner for Aswas - it's not critical
        if (cachedData != null) {
          return Column(
            children: [
              AswasCardWidget(aswasPlus: cachedData),
              SizedBox(height: 24.h),
            ],
          );
        }
        return const SizedBox.shrink();
      },
      empty: () => const SizedBox.shrink(), // No policy - don't show anything
    );
  }

  /// Builds the Upcoming Events section
  Widget _buildUpcomingEvents() {
    final state = ref.watch(eventsStateProvider);

    return state.when(
      initial: () => const UpcomingEventsSectionShimmer(),
      loading: (previousData) {
        // Show previous data while loading, or shimmer if no data
        if (previousData != null && previousData.isNotEmpty) {
          return UpcomingEventsSection(
            events: previousData,
            onViewAllTap: () {
              // TODO: Navigate to all events
            },
            onEventTap: (event) {
              // TODO: Navigate to event details
            },
            onRegisterTap: (event) {
              // TODO: Handle event registration
            },
          );
        }
        return const UpcomingEventsSectionShimmer();
      },
      loaded: (events) {
        return UpcomingEventsSection(
          events: events,
          onViewAllTap: () {
            // TODO: Navigate to all events
          },
          onEventTap: (event) {
            // TODO: Navigate to event details
          },
          onRegisterTap: (event) {
            // TODO: Handle event registration
          },
        );
      },
      error: (failure, cachedData) {
        // Show cached data if available, otherwise empty state
        if (cachedData != null && cachedData.isNotEmpty) {
          return UpcomingEventsSection(
            events: cachedData,
            onViewAllTap: () {
              // TODO: Navigate to all events
            },
            onEventTap: (event) {
              // TODO: Navigate to event details
            },
            onRegisterTap: (event) {
              // TODO: Handle event registration
            },
          );
        }
        return const UpcomingEventsEmptyState();
      },
      empty: () => const UpcomingEventsEmptyState(),
    );
  }

  /// Builds the Announcements section
  Widget _buildAnnouncements() {
    final state = ref.watch(announcementsStateProvider);

    return state.when(
      initial: () => const AnnouncementsSectionShimmer(),
      loading: (previousData) {
        // Show previous data while loading, or shimmer if no data
        if (previousData != null && previousData.isNotEmpty) {
          return AnnouncementsSection(
            announcements: previousData,
            onViewAllTap: () {
              // TODO: Navigate to all announcements
            },
            onAnnouncementTap: (announcement) {
              // TODO: Navigate to announcement details
            },
          );
        }
        return const AnnouncementsSectionShimmer();
      },
      loaded: (announcements) {
        return AnnouncementsSection(
          announcements: announcements,
          onViewAllTap: () {
            // TODO: Navigate to all announcements
          },
          onAnnouncementTap: (announcement) {
            // TODO: Navigate to announcement details
          },
        );
      },
      error: (failure, cachedData) {
        // Show cached data if available, otherwise empty state
        if (cachedData != null && cachedData.isNotEmpty) {
          return AnnouncementsSection(
            announcements: cachedData,
            onViewAllTap: () {
              // TODO: Navigate to all announcements
            },
            onAnnouncementTap: (announcement) {
              // TODO: Navigate to announcement details
            },
          );
        }
        return const AnnouncementsEmptyState();
      },
      empty: () => const AnnouncementsEmptyState(),
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
