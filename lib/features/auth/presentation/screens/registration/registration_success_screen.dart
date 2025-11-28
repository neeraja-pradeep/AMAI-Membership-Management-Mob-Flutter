import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Registration Success Screen
///
/// Displayed after successful payment and registration
/// - Shows success message and registration ID
/// - Confetti animation
/// - Navigation to dashboard
class RegistrationSuccessScreen extends ConsumerStatefulWidget {
  final String? registrationId;

  const RegistrationSuccessScreen({super.key, this.registrationId});

  @override
  ConsumerState<RegistrationSuccessScreen> createState() =>
      _RegistrationSuccessScreenState();
}

class _RegistrationSuccessScreenState
    extends ConsumerState<RegistrationSuccessScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();

    // Initialize confetti controller
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Start confetti animation
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  /// Navigate to dashboard
  void _goToDashboard() {
    // TODO: Navigate to dashboard
    // Navigator.pushNamedAndRemoveUntil(
    //   context,
    //   AppRouter.dashboard,
    //   (route) => false,
    // );

    // For now, just pop until root
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final registrationId = widget.registrationId ?? 'UNKNOWN';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success icon
                    Container(
                      width: 120.w,
                      height: 120.h,
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        size: 80.sp,
                        color: Colors.green[600],
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Success title
                    Text(
                      'Registration Complete!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Success message
                    Text(
                      'Congratulations! Your registration has been submitted successfully.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Registration ID card
                    Container(
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Registration ID',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          SelectableText(
                            registrationId,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1976D2),
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Save this ID for future reference',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Next steps
                    Container(
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'What\'s Next?',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 16.h),
                          const _NextStepItem(
                            icon: Icons.email_outlined,
                            text:
                                'You will receive a confirmation email shortly',
                          ),
                          SizedBox(height: 12.h),
                          const _NextStepItem(
                            icon: Icons.verified_user_outlined,
                            text:
                                'Your application will be reviewed within 2-3 business days',
                          ),
                          SizedBox(height: 12.h),
                          const _NextStepItem(
                            icon: Icons.notifications_outlined,
                            text:
                                'We will notify you once your membership is approved',
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 48.h),

                    // Dashboard button
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: _goToDashboard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Go to Dashboard',
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
            ),

            // Confetti animation
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                particleDrag: 0.05,
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                gravity: 0.2,
                shouldLoop: false,
                colors: const [
                  Color(0xFF1976D2),
                  Colors.green,
                  Colors.orange,
                  Colors.purple,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Next step item widget
class _NextStepItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _NextStepItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20.sp, color: const Color(0xFF1976D2)),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
