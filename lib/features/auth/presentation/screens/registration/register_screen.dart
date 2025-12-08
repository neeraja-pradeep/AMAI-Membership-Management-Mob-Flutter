import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/auth/application/providers/auth_provider.dart';
import 'package:myapp/features/auth/application/notifiers/registration_state_notifier.dart';
import 'package:myapp/features/auth/application/states/registration_state.dart';
import 'package:myapp/features/auth/presentation/components/email_field.dart';
import 'package:myapp/features/auth/presentation/components/offline_banner.dart';
import 'package:myapp/features/auth/presentation/components/password_field.dart';
import 'package:myapp/features/auth/presentation/components/role_selection_popup.dart';
import 'package:myapp/features/auth/presentation/components/stale_data_banner.dart';
import 'package:myapp/features/auth/presentation/screens/registration/personal_details_screen.dart';
import 'package:myapp/features/auth/presentation/widgets/resume_registration_dialog.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _hasCheckedForExistingRegistration = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForExistingRegistration();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Check for existing incomplete registration and show resume dialog
  void _checkForExistingRegistration() {
    if (_hasCheckedForExistingRegistration) return;
    _hasCheckedForExistingRegistration = true;

    final state = ref.read(registrationProvider);

    if (state is RegistrationStateResumePrompt) {
      showResumeRegistrationDialog(context, state.existingRegistration);
    }
  }

  void _continueRegistration() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final selectedRole = await showDialog(
        context: context,
        builder: (context) => const RoleSelectionPopup(),
      );

      if (selectedRole != null) {
        // Clear any existing registration data before starting fresh
        // This ensures new email/password are used, not old cached data
        await ref.read(registrationProvider.notifier).startFreshRegistration();

        if (!mounted) return;

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PersonalDetailsScreen(
              role: selectedRole,
              password: _passwordController.text.trim(),
              email: _emailController.text.trim(),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // gradient overlay
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.loginBackground,
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 100.h),

                  // Title
                  Text(
                    "Set Login Credentials",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 40.h),

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Enter Email Id",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 12.h),

                        EmailField(controller: _emailController),

                        SizedBox(height: 24.h),
                        Text(
                          "Set Password",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 12.h),

                        PasswordField(controller: _passwordController),

                        SizedBox(height: 24.h),
                        Text(
                          "Confirm Password",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 12.h),

                        PasswordField(controller: _confirmPasswordController),

                        SizedBox(height: 64.h),

                        SizedBox(
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: _continueRegistration,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brown,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Continue Registration',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
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
        ],
      ),
    );
  }
}
