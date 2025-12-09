import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/navigation/presentation/screens/main_navigation_screen.dart';
import 'package:myapp/features/auth/presentation/screens/registration/personal_details_screen.dart';
import 'package:myapp/features/auth/presentation/screens/registration/register_screen.dart';
import '../screens/forgot_password/forgot_password_screen.dart';
import '../../application/providers/auth_provider.dart';
import '../../application/states/auth_state.dart';
import '../../infrastructure/repositories/auth_repository_provider.dart';
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
  void initState() {
    super.initState();
    _loadRememberMeCredentials();
  }

  Future<void> _loadRememberMeCredentials() async {
    final credentials = await ref
        .read(authRepositoryProvider)
        .getRememberMeCredentials();
    if (credentials.email != null && credentials.password != null) {
      setState(() {
        _emailController.text = credentials.email!;
        _passwordController.text = credentials.password!;
        _rememberMe = true;
      });
    }
  }

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

    // Listen to auth state changes
    ref.listen<AuthState>(authProvider, (previous, next) {
      switch (next) {
        case AuthStateAuthenticated():
          // Navigate to home screen on successful login
          // Navigator.pushReplacementNamed(context, '/home');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MainNavigationScreen(),
            ),
          );
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Login',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.lightBackgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 40.h),

                  // Login Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Email / Usermame",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        // Email field
                        EmailField(controller: _emailController),

                        SizedBox(height: 24.h),

                        Text(
                          "Password",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // Password field
                        PasswordField(controller: _passwordController),

                        SizedBox(height: 16.h),

                        // Remember me checkbox
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                                    activeColor: AppColors.brown,
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

                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Forgot Password ?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.brown,
                                ),
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
                              backgroundColor: AppColors.brown,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                              elevation: 0,
                            ),
                            child: authState is AuthStateLoading
                                ? SizedBox(
                                    width: 24.w,
                                    height: 24.h,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
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

                        SizedBox(height: 180.h),

                        // Register button
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              text: "New Member?   ",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ),
                              children: [
                                TextSpan(
                                  text: "Register Here",
                                  style: TextStyle(
                                    fontSize: 14.sp,

                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }
}
