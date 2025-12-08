import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/core/network/api_client_provider.dart';

import '../screen/login_screen.dart';
import 'package:myapp/features/navigation/presentation/screens/main_navigation_screen.dart';

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
        // Session is valid, go to main navigation (with bottom nav bar)
        debugPrint('[SplashScreen] Navigating to MainNavigationScreen');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
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
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashBackground),
        child: Center(child: Image.asset('assets/logo.png')),
      ),
    );
  }
}
