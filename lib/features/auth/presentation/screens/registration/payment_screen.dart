import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';

import '../../../../../app/router/app_router.dart';
import '../../../application/notifiers/registration_state_notifier.dart';
import '../../../application/states/registration_state.dart';
import '../../../domain/entities/registration/practitioner_registration.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _isProcessing = false;
  String? _selectedPaymentMethod;

  /// Pricing Breakdown
  final double subtotal = 1000.00;
  final double gstRate = 0.18; // 18%
  late final double gstAmount = subtotal * gstRate;
  late final double totalPayable = subtotal + gstAmount;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureRegistrationInitialized();
    });
  }

  void _ensureRegistrationInitialized() {
    final state = ref.read(registrationProvider);

    if (state is RegistrationStateResumePrompt) {
      ref
          .read(registrationProvider.notifier)
          .resumeRegistration(state.existingRegistration);
      return;
    }

    if (state is! RegistrationStateInProgress) {
      ref.read(registrationProvider.notifier).startNewRegistration();
    }
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == null) {
      _showError("Please select a payment method.");
      return;
    }

    setState(() => _isProcessing = true);

    await Future.delayed(const Duration(seconds: 2)); // Mock delay

    final sessionId = "SESSION_${DateTime.now().millisecondsSinceEpoch}";

    final paymentDetails = PaymentDetails(
      sessionId: sessionId,
      amount: totalPayable,
      currency: "INR",
      status: PaymentStatus.completed,
      transactionId: "TXN_${DateTime.now().millisecondsSinceEpoch}",
      paymentMethod: _selectedPaymentMethod!,
      completedAt: DateTime.now(),
    );

    ref
        .read(registrationProvider.notifier)
        .updatePaymentDetails(paymentDetails);
    await ref.read(registrationProvider.notifier).submitRegistration();

    final finalState = ref.read(registrationProvider);

    if (mounted) {
      if (finalState is RegistrationStateSuccess) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.registrationSuccess,
          (route) => false,
        );
      } else if (finalState is RegistrationStateError) {
        _showError(finalState.message);
      }
    }

    if (mounted) setState(() => _isProcessing = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registrationProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _isProcessing ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          "Register Here",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            SizedBox(height: 30.h),

            /// Section Title
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Payment Breakdown",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20.h),

            /// Subtotal Row
            _priceRow("Subtotal", "₹${subtotal.toStringAsFixed(2)}"),

            /// GST Row
            _priceRow("GST (18%)", "₹${gstAmount.toStringAsFixed(2)}"),

            Divider(height: 32.h, thickness: 1),

            /// Total Payable
            _priceRow(
              "Total Payable",
              "₹${totalPayable.toStringAsFixed(2)}",
              bold: true,
              color: AppColors.brown,
            ),

            SizedBox(height: 30.h),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Select Payment Method",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 18.h),

            _paymentOption("UPI", "upi", Icons.account_balance_wallet),
            SizedBox(height: 12.h),
            _paymentOption(" Net Banking", "netbanking", Icons.account_balance),
            SizedBox(height: 12.h),
            _paymentOption(" Credit/Debit Card", "card", Icons.credit_card),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : Text(
                        "Pay Now",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Reusable Widgets
  Widget _priceRow(
    String label,
    String value, {
    bool bold = false,
    Color? color,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentOption(String title, String value, IconData icon) {
    final selected = _selectedPaymentMethod == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? AppColors.brown : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          color: selected ? AppColors.brown.withOpacity(0.1) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.brown : Colors.grey[600]),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? AppColors.brown : Colors.black,
                ),
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.brown : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
