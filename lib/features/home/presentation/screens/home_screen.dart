import 'dart:async';

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
import 'package:myapp/features/home/presentation/components/upcoming_event_mini_card.dart';
import 'package:myapp/features/home/presentation/components/announcement_mini_card.dart';
import 'package:myapp/features/membership/presentation/screens/membership_screen.dart';
import 'package:myapp/features/aswas_plus/presentation/screens/aswas_plus_screen.dart';
import 'package:myapp/features/profile/presentation/screens/profile_screen.dart';
import 'package:myapp/features/profile/application/providers/profile_providers.dart';
import 'package:myapp/features/academy/presentation/screens/academy_screen.dart';
import 'package:myapp/features/home/presentation/screens/contact_details_screen.dart';
import 'package:myapp/features/navigation/application/providers/navigation_providers.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Home screen - primary landing screen after authentication
/// Displays membership card, quick actions, events, and announcements
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _cardPageController = PageController();
  Timer? _autoScrollTimer;
  int _currentCardPage = 0;
  int _totalCardPages = 1;

  @override
  void initState() {
    super.initState();
    // Initialize data fetch when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(membershipStateProvider.notifier).initialize();
      ref.read(aswasStateProvider.notifier).initialize();
      ref.read(eventsStateProvider.notifier).initialize();
      ref.read(announcementsStateProvider.notifier).initialize();
      ref.read(profileStateProvider.notifier).initialize();
    });
    // Start auto-scroll timer
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _cardPageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_totalCardPages > 1 && _cardPageController.hasClients) {
        _currentCardPage = (_currentCardPage + 1) % _totalCardPages;
        _cardPageController.animateToPage(
          _currentCardPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.scaffoldBackground,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.lightBackgroundGradient,
        ),
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top section with background
                _buildTopSection(),
                SizedBox(height: 24.h),
                // Quick Actions section
                Consumer(
                  builder: (context, ref, child) {
                    final membershipState = ref.watch(membershipStateProvider);
                    final membershipType = membershipState.currentData?.membershipType;
                    return QuickActionsSection(
                      membershipType: membershipType,
                      onViewAll: () {
                        // TODO: Navigate to all quick actions
                      },
                      onMembershipTap: () {
                        // Navigate to membership screen
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => const MembershipScreen(),
                          ),
                        ).then((_) => _onRefresh());
                      },
                      onAswasePlusTap: () {
                        // Navigate to Aswas Plus screen
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => const AswasePlusScreen(),
                          ),
                        ).then((_) => _onRefresh());
                      },
                      onAcademyTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => const AcademyScreen(),
                          ),
                        );
                      },
                      onContactsTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => const ContactDetailsScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),
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

  /// Builds the top section with background image and header/membership card
  Widget _buildTopSection() {
    return Container(
      height: 330.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(52, 3, 13, 1),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
        image: const DecorationImage(
          image: AssetImage('assets/home/bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            _buildHeader(),
            SizedBox(height: 24.h),
            _buildMembershipCard(),
          ],
        ),
      ),
    );
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
              Consumer(
                builder: (context, ref, child) {
                  final state = ref.watch(membershipStateProvider);
                  final name = state.currentData?.holderName ?? 'Member';
                  return Text(
                    'Hi, $name',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ],
          ),
          Row(
            children: [
              _buildSvgButton(
                assetPath: 'assets/svg/bell.svg',
                onPressed: () {
                  // TODO: Navigate to notifications
                },
              ),
              SizedBox(width: 8.w),
              _buildProfileAvatar(),
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
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22.r)),
      child: IconButton(
        icon: Icon(icon, color: AppColors.white, size: 22.sp),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  //build an icon button for the header with svg
  Widget _buildSvgButton({
    required String assetPath,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 44.w,
      height: 44.h,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22.r)),
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        icon: SvgPicture.asset(
          assetPath,
          width: 22.w,
          height: 22.h,
          color: AppColors.white, // Remove this if your SVG already has colors
        ),
      ),
    );
  }

  /// Builds the profile avatar for the header
  Widget _buildProfileAvatar() {
    return Consumer(
      builder: (context, ref, child) {
        final profileState = ref.watch(profileStateProvider);
        final userProfile = profileState.userProfile;

        return GestureDetector(
          onTap: () {
            // Switch to Profile tab (index 3) instead of navigating to new screen
            ref.read(currentTabIndexProvider.notifier).state = 3;
          },
          child: Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white.withOpacity(0.3), width: 2),
            ),
            child: ClipOval(
              child: userProfile != null && userProfile.hasProfilePicture
                  ? Image.network(
                      userProfile.profilePictureUrl!,
                      fit: BoxFit.cover,
                      width: 44.w,
                      height: 44.h,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildInitialsAvatar(userProfile.initials);
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 16.w,
                            height: 16.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          ),
                        );
                      },
                    )
                  : _buildInitialsAvatar(userProfile?.initials ?? ''),
            ),
          ),
        );
      },
    );
  }

  /// Builds initials avatar for fallback
  Widget _buildInitialsAvatar(String initials) {
    return Container(
      width: 44.w,
      height: 44.h,
      color: AppColors.primary,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  /// Builds the membership card section with horizontal scroll and auto-scroll
  Widget _buildMembershipCard() {
    final membershipState = ref.watch(membershipStateProvider);
    final eventsState = ref.watch(eventsStateProvider);
    final announcementsState = ref.watch(announcementsStateProvider);

    // Get event within a week if available
    final upcomingEventWithinWeek = eventsState.maybeWhen(
      loaded: (events) {
        final eventsWithinWeek = events
            .where((event) => UpcomingEventMiniCard.isWithinWeek(event))
            .toList();
        return eventsWithinWeek.isNotEmpty ? eventsWithinWeek.first : null;
      },
      orElse: () => null,
    );

    // Get announcement within a week if available
    final announcementWithinWeek = announcementsState.maybeWhen(
      loaded: (announcements) {
        final announcementsWithinWeek = announcements
            .where((announcement) => AnnouncementMiniCard.isWithinWeek(announcement))
            .toList();
        return announcementsWithinWeek.isNotEmpty ? announcementsWithinWeek.first : null;
      },
      orElse: () => null,
    );

    // Build list of card pages
    final List<Widget> cardPages = [
      // Membership card (always first) - has internal margin
      membershipState.when(
        initial: () => const MembershipCardShimmer(),
        loading: (previousData) {
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
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
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
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const MembershipScreen(),
                ),
              ).then((_) => _onRefresh());
            },
          );
        },
        error: (failure, cachedData) {
          if (cachedData != null) {
            return MembershipCardWidget(membershipCard: cachedData);
          }
          return MembershipCardEmpty(
            onApply: _onRefresh,
          );
        },
        empty: () => MembershipCardEmpty(
          onApply: () {
            // TODO: Navigate to membership application
          },
        ),
        pending: (_) => const MembershipCardShimmer(),
        rejected: () => const MembershipCardShimmer(),
      ),
    ];

    // Add upcoming event card if available
    if (upcomingEventWithinWeek != null) {
      cardPages.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: UpcomingEventMiniCard(
            event: upcomingEventWithinWeek,
            onRegisterTap: () {
              // TODO: Navigate to event registration
            },
          ),
        ),
      );
    }

    // Add announcement card if available
    if (announcementWithinWeek != null) {
      cardPages.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: AnnouncementMiniCard(
            announcement: announcementWithinWeek,
            onTap: () {
              // TODO: Navigate to announcement details
            },
          ),
        ),
      );
    }

    // Update total pages for auto-scroll
    _totalCardPages = cardPages.length;

    return SizedBox(
      height: 180.h,
      child: PageView(
        controller: _cardPageController,
        onPageChanged: (index) {
          _currentCardPage = index;
        },
        children: cardPages,
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
                  AswasCardWidget(
                    aswasPlus: previousData,
                    onTap: () {
                      // Navigate to Aswas Plus details
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => const AswasePlusScreen(),
                        ),
                      ).then((_) => _onRefresh());
                    },
                  ),
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
                // Navigate to Aswas Plus details
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const AswasePlusScreen(),
                  ),
                ).then((_) => _onRefresh());
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
              AswasCardWidget(
                aswasPlus: cachedData,
                onTap: () {
                  // Navigate to Aswas Plus details
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const AswasePlusScreen(),
                    ),
                  ).then((_) => _onRefresh());
                },
              ),
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
          Icon(Icons.error_outline, color: AppColors.error, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(color: AppColors.error),
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
              style: AppTypography.buttonSmall.copyWith(color: AppColors.error),
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
          Text(title, style: AppTypography.titleMedium),
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
