import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/home/application/providers/home_providers.dart';
import 'package:myapp/features/home/presentation/screens/home_screen.dart';
import 'package:myapp/features/home/presentation/screens/registration_status_screen.dart';
import 'package:myapp/features/navigation/application/providers/navigation_providers.dart';
import 'package:myapp/features/profile/application/providers/profile_providers.dart';
import 'package:myapp/features/profile/presentation/screens/profile_screen.dart';

/// Main navigation screen with bottom navigation bar
/// Contains 4 tabs: Home, Events, Library, Profile
/// Shows RegistrationStatusScreen when membership application is pending
class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const _EventsPlaceholderScreen(),
    const _LibraryPlaceholderScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final membershipState = ref.watch(membershipStateProvider);
    final tabIndex = ref.watch(currentTabIndexProvider);

    // Sync provider state with local state
    if (tabIndex != _currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _currentIndex = tabIndex;
        });
        _refreshProvidersForTab(tabIndex);
      });
    }

    // Show Registration Status screen when membership application is pending
    if (membershipState.isPending) {
      return const RegistrationStatusScreen();
    }

    // Show Registration Status screen with rejected UI when membership application is rejected
    if (membershipState.isRejected) {
      return const RegistrationStatusScreen(isRejected: true);
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  svgPath: 'assets/svg/home.svg',
                  label: 'Home',
                ),
                _buildNavItem(
                  index: 1,
                  svgPath: 'assets/svg/events.svg',
                  label: 'Events',
                ),
                _buildNavItem(
                  index: 2,
                  svgPath: 'assets/svg/calander.svg',
                  label: 'Library',
                ),
                _buildNavItem(
                  index: 3,
                  svgPath: 'assets/svg/profile.svg',
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String svgPath,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        // Update provider so other parts of the app can trigger tab changes
        ref.read(currentTabIndexProvider.notifier).state = index;
        // Refresh relevant providers when switching tabs (uses if-modified-since)
        _refreshProvidersForTab(index);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              svgPath,
              width: 24.sp,
              height: 24.sp,
              colorFilter: ColorFilter.mode(
                isSelected ? AppColors.brown : AppColors.grey400,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.brown : AppColors.grey400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Refreshes relevant providers when switching to a tab
  /// Uses if-modified-since strategy for efficient data fetching
  void _refreshProvidersForTab(int tabIndex) {
    switch (tabIndex) {
      case 0: // Home tab
        ref.read(membershipStateProvider.notifier).refresh();
        ref.read(aswasStateProvider.notifier).refresh();
        break;
      case 3: // Profile tab
        ref.read(profileStateProvider.notifier).refresh();
        ref.read(nomineesStateProvider.notifier).refresh();
        break;
    }
  }
}

/// Placeholder screen for Events tab
class _EventsPlaceholderScreen extends StatelessWidget {
  const _EventsPlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Events',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event,
              size: 64.sp,
              color: AppColors.grey300,
            ),
            SizedBox(height: 16.h),
            Text(
              'Events',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder screen for Library tab
class _LibraryPlaceholderScreen extends StatelessWidget {
  const _LibraryPlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Library',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books,
              size: 64.sp,
              color: AppColors.grey300,
            ),
            SizedBox(height: 16.h),
            Text(
              'Library',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

