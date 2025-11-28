import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/router/app_router.dart';
import '../../../application/notifiers/registration_state_notifier.dart';
import '../../../application/states/registration_state.dart';
import '../../../domain/entities/registration/practitioner_registration.dart';
import '../../components/step_progress_indicator.dart';

/// Payment Screen (Step 5 - Final)
///
/// Handles membership payment:
/// - Displays payment amount and details
/// - Payment gateway integration
/// - One-way payment (no retry after success)
/// - Navigates to success screen after payment
///
/// CRITICAL REQUIREMENTS:
/// - Payment is one-way (cannot retry after success)
/// - Must validate all previous steps before payment
/// - Payment status tracked in PaymentDetails entity
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _isProcessing = false;
  String? _selectedPaymentMethod;

  // Mock payment amount (TODO: Fetch from backend)
  final double _paymentAmount = 1000.00;
  final String _currency = 'INR';

  /// Validate all steps with detailed error messages
  String? _validateAllSteps() {
    final state = ref.read(registrationProvider);

    // Only RegistrationStateInProgress contains registration data
    if (state is! RegistrationStateInProgress) {
      // Provide more helpful error message based on actual state
      if (state is RegistrationStateInitial) {
        return 'Registration not started. Please go back to Step 1 (Personal Details).';
      } else if (state is RegistrationStateResumePrompt) {
        return 'Please choose to resume or start fresh registration from Step 1.';
      } else if (state is RegistrationStateValidationError) {
        return 'Validation error: ${state.message}';
      } else if (state is RegistrationStateError) {
        return 'Registration error: ${state.message}';
      } else {
        return 'Invalid state (${state.runtimeType}). Please restart from Step 1.';
      }
    }

    final registration = state.registration;

    // Check each step individually and return specific error
    if (registration.personalDetails == null ||
        !registration.personalDetails!.isComplete) {
      return 'Step 1: Personal Details is incomplete. Please go back and complete it.';
    }

    if (registration.professionalDetails == null ||
        !registration.professionalDetails!.isComplete) {
      return 'Step 2: Professional Details is incomplete. Please go back and complete it.';
    }

    if (registration.addressDetails == null ||
        !registration.addressDetails!.isComplete) {
      return 'Step 3: Address Details is incomplete. Please go back and complete it.';
    }

    if (registration.documentUploads == null ||
        !registration.documentUploads!.isComplete) {
      return 'Step 4: Document Uploads is incomplete. Please go back and upload required documents.';
    }

    return null; // All steps complete
  }

  /// Handle payment processing
  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate all steps with detailed error message
    final validationError = _validateAllSteps();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4), // Longer duration for detailed message
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // TODO: Implement actual payment gateway integration
      // For now, simulate payment processing with mock session ID
      await Future.delayed(const Duration(seconds: 2));

      // Mock payment session ID (in real implementation, this comes from payment gateway)
      final sessionId = 'SESSION_${DateTime.now().millisecondsSinceEpoch}';

      // Create payment details with completed status
      final paymentDetails = PaymentDetails(
        sessionId: sessionId,
        amount: _paymentAmount,
        currency: _currency,
        status: PaymentStatus.completed,
        transactionId: 'TXN_${DateTime.now().millisecondsSinceEpoch}',
        paymentMethod: _selectedPaymentMethod,
        completedAt: DateTime.now(),
      );

      // Update payment details in registration state
      ref.read(registrationProvider.notifier).updatePaymentDetails(paymentDetails);

      // Submit registration to backend
      await ref.read(registrationProvider.notifier).submitRegistration();

      // Listen to registration state for success/error
      final finalState = ref.read(registrationProvider);

      if (mounted) {
        if (finalState is RegistrationStateSuccess) {
          // Navigate to success screen with registration ID
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRouter.registrationSuccess,
            (route) => false, // Remove all previous routes
            arguments: finalState.registrationId,
          );
        } else if (finalState is RegistrationStateError) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(finalState.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// Handle back button press
  void _handleBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isProcessing) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please wait, payment is processing...'),
              backgroundColor: Colors.orange,
            ),
          );
          return false;
        }
        _handleBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
            onPressed: _isProcessing ? null : _handleBack,
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              const StepProgressIndicator(
                currentStep: 5,
                totalSteps: 5,
                stepTitle: 'Payment',
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 24.h),

                      // Title
                      Text(
                        'Complete Payment',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Final step to complete your registration',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // Payment amount card
                      Container(
                        padding: EdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1976D2).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Membership Fee',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              '$_currency $_paymentAmount',
                              style: TextStyle(
                                fontSize: 36.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // Payment method selection
                      Text(
                        'Select Payment Method',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Payment method options
                      _PaymentMethodOption(
                        title: 'Credit/Debit Card',
                        icon: Icons.credit_card,
                        value: 'card',
                        selectedValue: _selectedPaymentMethod,
                        onChanged: _isProcessing
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedPaymentMethod = value;
                                });
                              },
                      ),

                      SizedBox(height: 12.h),

                      _PaymentMethodOption(
                        title: 'UPI',
                        icon: Icons.account_balance_wallet,
                        value: 'upi',
                        selectedValue: _selectedPaymentMethod,
                        onChanged: _isProcessing
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedPaymentMethod = value;
                                });
                              },
                      ),

                      SizedBox(height: 12.h),

                      _PaymentMethodOption(
                        title: 'Net Banking',
                        icon: Icons.account_balance,
                        value: 'netbanking',
                        selectedValue: _selectedPaymentMethod,
                        onChanged: _isProcessing
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedPaymentMethod = value;
                                });
                              },
                      ),

                      SizedBox(height: 32.h),

                      // Security note
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lock_outline,
                              color: Colors.green[700],
                              size: 20.sp,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                'Your payment is secure and encrypted',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.green[900],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // Pay button
                      SizedBox(
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _processPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            disabledBackgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: _isProcessing
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
                                  'Pay $_currency $_paymentAmount',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Payment method option widget
class _PaymentMethodOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final String? selectedValue;
  final void Function(String?)? onChanged;

  const _PaymentMethodOption({
    required this.title,
    required this.icon,
    required this.value,
    required this.selectedValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedValue == value;
    final isEnabled = onChanged != null;

    return GestureDetector(
      onTap: isEnabled ? () => onChanged?.call(value) : null,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1976D2).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF1976D2) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1976D2) : Colors.grey[100],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24.sp,
              ),
            ),

            SizedBox(width: 16.w),

            // Title
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? const Color(0xFF1976D2)
                      : Colors.grey[800],
                ),
              ),
            ),

            // Radio indicator
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF1976D2)
                      : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? const Color(0xFF1976D2) : Colors.white,
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 16.sp, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
