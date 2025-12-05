import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/features/auth/presentation/screens/home_screen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:myapp/app/theme/colors.dart';
import '../../../../../app/router/app_router.dart';
import '../../../application/notifiers/registration_state_notifier.dart';
import '../../../application/states/registration_state.dart';
import '../../components/registration_step_indicator.dart';

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

    // If RegistrationStateResumePrompt somehow still exists here,
    // it means the user bypassed the resume dialog. Start fresh instead.
    if (state is RegistrationStateResumePrompt) {
      ref.read(registrationProvider.notifier).startFreshRegistration();
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
          SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: _isLoadingDetails
                ? SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Step Indicator

                      // Order Summary Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  color: AppColors.brown,
                                  size: 24.sp,
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  "Order Summary",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h),
                            _priceRow(
                              "Membership Fee",
                              totalPayable != null
                                  ? "₹${totalPayable!.toStringAsFixed(2)}"
                                  : "—",
                            ),
                            SizedBox(height: 12.h),
                            _priceRow("GST (0%)", "₹0.00"),
                            SizedBox(height: 16.h),
                            Divider(color: Colors.grey[300], thickness: 1),
                            SizedBox(height: 16.h),
                            _priceRow(
                              "Total Amount",
                              totalPayable != null
                                  ? "₹${totalPayable!.toStringAsFixed(2)}"
                                  : "—",
                              bold: true,
                              highlight: true,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Payment Method Section
                      Text(
                        "Payment Method",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Razorpay Payment Option
                      _buildRazorpayOption(),

                      SizedBox(height: 32.h),

                      // Pay Button
                      SizedBox(
                        width: double.infinity,
                        height: 54.h,
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _processPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brown,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 2,
                          ),
                          child: _isProcessing
                              ? SizedBox(
                                  height: 24.h,
                                  width: 24.w,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.lock,
                                      size: 20.sp,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      totalPayable != null
                                          ? "Pay ₹${totalPayable!.toStringAsFixed(2)}"
                                          : "Pay Now",
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Security Note
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shield,
                            size: 16.sp,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            "Secure payment powered by Razorpay",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
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
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomeScreen(),
                            ),
                            (route) => false, // remove everything
                          );
                        },
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

  Widget _priceRow(
    String label,
    String value, {
    bool bold = false,
    bool highlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? 16.sp : 14.sp,
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            color: bold ? Colors.black : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 18.sp : 14.sp,
            fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
            color: highlight ? AppColors.brown : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildRazorpayOption() {
    final isSelected = _selectedPaymentMethod == "razorpay";
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = "razorpay"),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.brown : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.brown.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Razorpay Logo Container
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: const Color(0xFF072654),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Text(
                  "R",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Razorpay",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Cards, UPI, Netbanking & Wallets",
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: "razorpay",
              groupValue: _selectedPaymentMethod,
              onChanged: (val) =>
                  setState(() => _selectedPaymentMethod = val as String),
              activeColor: AppColors.brown,
            ),
          ],
        ),
      ),
    );
  }
}
