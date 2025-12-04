import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:myapp/app/theme/colors.dart';

import '../../../../../app/router/app_router.dart';
import '../../../application/notifiers/registration_state_notifier.dart';
import '../../../application/states/registration_state.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final Razorpay _razorpay = Razorpay();
  bool _isProcessing = false;
  String? _selectedPaymentMethod;

  /// Pricing Breakdown (driven by backend)
  final double gstRate = 0.18;
  double? subtotal;
  double? gstAmount;
  double? totalPayable;

  String? orderId;
  int? _razorpayAmountPaise; // amount to send to Razorpay (from API)

  int? _userId; // 🔥 pulled from registrationProvider

  @override
  void initState() {
    super.initState();

    // Read userId from Riverpod once the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFromProvider();
    });

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  void _initFromProvider() {
    final state = ref.read(registrationProvider);

    if (state is RegistrationStateResumePrompt) {
      // If it was a resume prompt, resume then re-init
      ref
          .read(registrationProvider.notifier)
          .resumeRegistration(state.existingRegistration);
      Future.microtask(_initFromProvider);
      return;
    }

    if (state is! RegistrationStateInProgress) {
      _showError("Registration not in progress.");
      return;
    }

    final reg = state.registration;

    // ✅ Assuming you added userId to PractitionerRegistration
    _userId = reg.userId;

    if (_userId == null) {
      _showError("Missing user ID from registration. Please restart the flow.");
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  /// STEP 1 — Initiate payment + Get pricing + order ID from backend
  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == null) {
      _showError("Please select a payment method.");
      return;
    }

    if (_userId == null) {
      _showError("User not found in registration state.");
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final notifier = ref.read(registrationProvider.notifier);

      // 🔹 Call backend: POST /membership/payment/ (or your mapped method)
      final response = await notifier.initiatePayment(userId: _userId!);

      // Expected:
      // response["amount"] → int, in paise (e.g. 118000 = ₹1180.00)
      // response["razorpay_order_id"]
      // response["phone"], response["email"] (for prefill)

      orderId = response["razorpay_order_id"] as String?;
      _razorpayAmountPaise = response["amount"] as int?;

      if (_razorpayAmountPaise == null || orderId == null) {
        _showError("Invalid payment details from server.");
        setState(() => _isProcessing = false);
        return;
      }

      // Convert paise → rupees
      final totalRupees = _razorpayAmountPaise! / 100.0;

      // Derive subtotal & GST from total using gstRate
      final base = totalRupees / (1 + gstRate);
      final gst = totalRupees - base;

      setState(() {
        totalPayable = totalRupees;
        subtotal = base;
        gstAmount = gst;
      });

      final options = {
        "key": "rzp_live_xxxxxxxxx", // 🔥 replace with your real Razorpay key
        "amount": _razorpayAmountPaise, // in paise
        "currency": "INR",
        "order_id": orderId,
        "name": "AMAI Membership",
        "description": "Membership Fees",
        "prefill": {"contact": response["phone"], "email": response["email"]},
      };

      _razorpay.open(options);
    } catch (e) {
      _showError("Payment initiation failed: $e");
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// STEP 2 — Successfully paid → verify on backend
  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    log("SUCCESS: ${response.paymentId}");

    // 🔧 Fix for: 'String?' can't be assigned to 'String'
    final orderId = response.orderId;
    final paymentId = response.paymentId;
    final signature = response.signature;

    if (orderId == null || paymentId == null || signature == null) {
      _showError("Invalid payment response from Razorpay.");
      return;
    }

    try {
      final notifier = ref.read(registrationProvider.notifier);

      await notifier.verifyPayment(
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
      );

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.registrationSuccess,
        (_) => false,
      );
    } catch (e) {
      _showError("Payment verification failed: $e");
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    _showError("Payment Failed. Try again.");
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Selected external wallet: ${response.walletName}"),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
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

            /// --- UI SAME AS BEFORE ---
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Payment Breakdown",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20.h),

            _priceRow(
              "Subtotal",
              subtotal != null ? "₹${subtotal!.toStringAsFixed(2)}" : "—",
            ),
            _priceRow(
              "GST (18%)",
              gstAmount != null ? "₹${gstAmount!.toStringAsFixed(2)}" : "—",
            ),

            Divider(height: 32.h, thickness: 1),

            _priceRow(
              "Total Payable",
              totalPayable != null
                  ? "₹${totalPayable!.toStringAsFixed(2)}"
                  : "—",
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
            _paymentOption("Net Banking", "netbanking", Icons.account_balance),
            SizedBox(height: 12.h),
            _paymentOption("Credit/Debit Card", "card", Icons.credit_card),

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
