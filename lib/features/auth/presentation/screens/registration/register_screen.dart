import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/auth/application/providers/auth_provider.dart';
import 'package:myapp/features/auth/presentation/components/email_field.dart';
import 'package:myapp/features/auth/presentation/components/offline_banner.dart';
import 'package:myapp/features/auth/presentation/components/password_field.dart';
import 'package:myapp/features/auth/presentation/components/role_selection_popup.dart';
import 'package:myapp/features/auth/presentation/components/stale_data_banner.dart';
import 'package:myapp/features/auth/presentation/screens/registration/personal_details_screen.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PersonalDetailsScreen(
              password: _passwordController.text.trim(),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // Background Image
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),

        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 60.h),

                    // Title
                    Text(
                      "Register",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: 60.h),

                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "Email / Username",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 16.h),

                          EmailField(controller: _emailController),

                          SizedBox(height: 20.h),
                          const Text(
                            "Password",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 16.h),

                          PasswordField(controller: _passwordController),

                          SizedBox(height: 20.h),
                          const Text(
                            "Confirm Password",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 16.h),

                          PasswordField(controller: _confirmPasswordController),

                          SizedBox(height: 40.h),

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
      ),
    );
  }
}
