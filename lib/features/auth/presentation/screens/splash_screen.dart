import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/core/network/api_client_provider.dart';

import '../screen/login_screen.dart';
import 'home_screen.dart';

/// Splash screen that checks session and redirects accordingly
///
/// On app startup:
/// - If valid session exists -> Navigate to HomeScreen
/// - If no session -> Navigate to LoginScreen
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    // Small delay for splash screen visibility
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    final apiClient = ref.read(apiClientProvider);

    // Check if session cookie exists
    final hasSession = await apiClient.hasValidSession();
    debugPrint('[SplashScreen] hasSession: $hasSession');

    if (!mounted) return;

    if (hasSession) {
      // Validate session with server
      final isValid = await apiClient.validateSessionWithServer();
      debugPrint('[SplashScreen] isValid: $isValid');

      if (!mounted) return;

      if (isValid) {
        // Session is valid, go to home
        debugPrint('[SplashScreen] Navigating to HomeScreen');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else {
        // Session expired on server, clear cookies and go to login
        debugPrint('[SplashScreen] Session invalid, clearing cookies');
        await apiClient.clearCookies();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } else {
      // No session, go to login
      debugPrint('[SplashScreen] No session, navigating to LoginScreen');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo or Icon
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: AppColors.brown,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Center(
                child: Text(
                  "AMAI",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              "AMAI Membership",
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.brown,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Ayurveda Medical Association of India",
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 48.h),
            SizedBox(
              width: 32.w,
              height: 32.h,
              child: const CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.brown),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
