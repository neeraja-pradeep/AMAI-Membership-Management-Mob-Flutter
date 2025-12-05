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
  bool _isLoadingDetails = true;
  bool _paymentComplete = false;

  double? subtotal;
  double? gstAmount;
  double? totalPayable;

  String? orderId;
  int? _razorpayAmountPaise;

  String? _prefillEmail;
  String? _prefillPhone;

  int? _userId;

  String? _selectedPaymentMethod = "razorpay";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFromProvider();
    });

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  void _initFromProvider() async {
    final state = ref.read(registrationProvider);

    if (state is RegistrationStateResumePrompt) {
      ref
          .read(registrationProvider.notifier)
          .resumeRegistration(state.existingRegistration);
      Future.microtask(_initFromProvider);
      return;
    }

    if (state is! RegistrationStateInProgress) {
      _showError("Registration not in progress.");
      setState(() => _isLoadingDetails = false);
      return;
    }

    _userId = state.registration.userId;

    if (_userId == null) {
      _showError("User ID missing — restart registration.");
      setState(() => _isLoadingDetails = false);
      return;
    }

    await _fetchPaymentDetails();
  }

  Future<void> _fetchPaymentDetails() async {
    try {
      final notifier = ref.read(registrationProvider.notifier);
      final response = await notifier.initiatePayment(userId: _userId!);

      debugPrint("Payment init response: $response");

      orderId = response["order_id"] as String?;
      final rawAmount = response["amount"];

      if (orderId == null || rawAmount == null) {
        throw Exception("Invalid data from server (order/amount null)");
      }

      if (rawAmount is double) {
        _razorpayAmountPaise = (rawAmount * 100).toInt();
      } else if (rawAmount is int) {
        _razorpayAmountPaise = rawAmount * 100;
      }

      _prefillEmail = response["email"] as String?;
      _prefillPhone = response["phone"] as String?;

      setState(() {
        totalPayable = (rawAmount is num) ? rawAmount.toDouble() : null;
        subtotal = totalPayable;
        gstAmount = 0.0;
        _isLoadingDetails = false;
      });
    } catch (e, st) {
      log("Error fetching payment details: $e\n$st");
      _showError("Failed to load payment details.");
      setState(() => _isLoadingDetails = false);
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod != "razorpay") {
      _showError("Please select Razorpay to continue.");
      return;
    }

    if (orderId == null || _razorpayAmountPaise == null) {
      _showError("Payment details not loaded yet.");
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final options = {
        "key": "rzp_test_RZlZ38QcLdQOEK",
        "order_id": orderId,
        "amount": _razorpayAmountPaise,
        "currency": "INR",
        "name": "AMAI Membership",
        "description": "Membership Fee",
        "prefill": {
          "email": _prefillEmail ?? "",
          "contact": _prefillPhone ?? "",
        },
      };

      log("Opening Razorpay with options: $options");
      _razorpay.open(options);
    } catch (e) {
      log("Error opening Razorpay: $e");
      _showError("Couldn't start payment. Please try again.");
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final notifier = ref.read(registrationProvider.notifier);

      final result = await notifier.verifyPayment(
        orderId: response.orderId!,
        paymentId: response.paymentId!,
        signature: response.signature!,
      );

      debugPrint('hi');
      debugPrint(result.toString());
      if (!mounted) return;

      setState(() => _paymentComplete = true);
    } catch (e, st) {
      _showError("Payment verification failed.");
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    _showError("Payment Failed. Please try again.");
  }

  void _onExternalWallet(ExternalWalletResponse response) {}

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(24.w),
            child: _isLoadingDetails
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      _priceRow(
                        "Amount",
                        totalPayable != null
                            ? "₹${totalPayable!.toStringAsFixed(2)}"
                            : "—",
                      ),
                      _priceRow("GST", "₹0.00"),
                      const Divider(),
                      _priceRow(
                        "Total Payable",
                        totalPayable != null
                            ? "₹${totalPayable!.toStringAsFixed(2)}"
                            : "—",
                        bold: true,
                      ),
                      const SizedBox(height: 24),
                      _paymentOption(
                        "Razorpay",
                        "razorpay",
                        Icons.account_balance_wallet,
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _isProcessing ? null : _processPayment,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: AppColors.brown,
                        ),
                        child: _isProcessing
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                totalPayable != null
                                    ? "Pay ₹${totalPayable!.toStringAsFixed(2)}"
                                    : "Pay",
                              ),
                      ),
                    ],
                  ),
          ),

          /// SUCCESS CARD OVERLAY
          if (_paymentComplete)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.4),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(22.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  width: 300.w,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 60.sp,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        "Successfully Registered 🎉",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        "Thank you for registering!\nYour application has been successfully submitted and is now pending administrative review.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14.sp, height: 1.4),
                      ),
                      SizedBox(height: 20.h),
                      TextButton(
                        onPressed: () => Navigator.popUntil(
                          context,
                          (route) => route.isFirst,
                        ),
                        child: Text(
                          "Back to Home",
                          style: TextStyle(fontSize: 16.sp, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _paymentOption(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.brown),
      title: Text(title),
      trailing: Radio(
        value: value,
        groupValue: _selectedPaymentMethod,
        onChanged: (val) =>
            setState(() => _selectedPaymentMethod = val as String),
      ),
    );
  }
}
