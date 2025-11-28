import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/features/auth/presentation/screens/registration/personal_details_screen.dart';
import '../../application/providers/auth_provider.dart';
import '../../application/states/auth_state.dart';
import '../components/email_field.dart';
import '../components/offline_banner.dart';
import '../components/password_field.dart';
import '../components/role_selection_popup.dart';
import '../components/stale_data_banner.dart';

/// Login screen
///
/// SCENARIO 1: First Launch (No Cache)
/// - Show login screen immediately (no loading spinner)
/// - User submits credentials
/// - Navigate on success
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(authProvider.notifier)
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            rememberMe: _rememberMe,
          );
    }
  }

  void _showRoleSelectionPopup() {
    showDialog(
      context: context,
      builder: (context) => const RoleSelectionPopup(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isOffline = ref.watch(isOfflineProvider);
    final isStale = ref.watch(isStaleProvider);

    // Listen to auth state changes
    ref.listen<AuthState>(authProvider, (previous, next) {
      switch (next) {
        case AuthStateAuthenticated():
          // Navigate to home screen on successful login
          // Navigator.pushReplacementNamed(context, '/home');
          break;
        case AuthStateError(:final message):
          // Show error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
          break;
        default:
          break;
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 60.h),

                    // Logo or Title
                    Text(
                      'AMAI',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1976D2),
                      ),
                    ),

                    SizedBox(height: 8.h),

                    Text(
                      'Membership Management',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                      ),
                    ),

                    SizedBox(height: 60.h),

                    // Login Form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email field
                          EmailField(controller: _emailController),

                          SizedBox(height: 16.h),

                          // Password field
                          PasswordField(controller: _passwordController),

                          SizedBox(height: 12.h),

                          // Remember me checkbox
                          Row(
                            children: [
                              SizedBox(
                                width: 24.w,
                                height: 24.h,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  activeColor: const Color(0xFF1976D2),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Remember me',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 32.h),

                          // Login button
                          SizedBox(
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: authState is AuthStateLoading
                                  ? null
                                  : _handleLogin,

                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1976D2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                elevation: 0,
                              ),
                              child: authState is AuthStateLoading
                                  ? SizedBox(
                                      width: 24.w,
                                      height: 24.h,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),

                          SizedBox(height: 24.h),

                          // Register button
                          TextButton(
                            onPressed: () async {
                              final selectedRole = await showDialog(
                                context: context,
                                builder: (context) =>
                                    const RoleSelectionPopup(),
                              );

                              if (selectedRole != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PersonalDetailsScreen(),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              'Don\'t have an account? Register',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF1976D2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Offline banner (SCENARIO 3)
            if (isOffline)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: OfflineBanner(),
              ),

            // Stale data banner (SCENARIO 5)
            if (isStale)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: StaleDataBanner(),
              ),
          ],
        ),
      ),
    );
  }
}
