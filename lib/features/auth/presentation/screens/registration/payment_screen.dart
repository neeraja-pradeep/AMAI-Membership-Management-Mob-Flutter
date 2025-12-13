import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myapp/features/navigation/presentation/screens/main_navigation_screen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:myapp/app/theme/colors.dart';
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

  // Payment method options
  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: "razorpay",
      name: "Razorpay",
      icon: "assets/svg/razorpay.svg",
    ),
    PaymentMethod(
      id: "googlepay",
      name: "Google Pay",
      icon: "assets/svg/googlepay.svg",
    ),
    PaymentMethod(id: "paytm", name: "Paytm", icon: "assets/svg/paytm.svg"),
    PaymentMethod(
      id: "card",
      name: ".... .... .... ....6521",
      icon: "assets/svg/mastercard.svg",
      isCard: true,
    ),
  ];

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
        // Calculate subtotal and GST (18%)
        if (totalPayable != null) {
          subtotal = (totalPayable! / 1.18);
          gstAmount = totalPayable! - subtotal!;
        }
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
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Color(0xFF60212E)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Select Payment Method",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.textPrimary),
            onPressed: () {
              // Add new payment method action
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.lightBackgroundGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _isLoadingDetails
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Order Summary Card
                          _buildOrderSummaryCard(),

                          SizedBox(height: 16.h),

                          // Payment Methods
                          ..._paymentMethods.map(
                            (method) => Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: _buildPaymentMethodOption(method),
                            ),
                          ),

                          SizedBox(height: 24.h),

                          // Back and Pay Now buttons
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 50.h,
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: AppColors.brown,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          100.r,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      "Back",
                                      style: TextStyle(
                                        color: AppColors.brown,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: SizedBox(
                                  height: 50.h,
                                  child: ElevatedButton(
                                    onPressed: _isProcessing
                                        ? null
                                        : _processPayment,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.brown,
                                      disabledBackgroundColor: Colors.grey[300],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          100.r,
                                        ),
                                      ),
                                    ),
                                    child: _isProcessing
                                        ? SizedBox(
                                            height: 20.h,
                                            width: 20.w,
                                            child:
                                                const CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                          )
                                        : Text(
                                            "Pay Now",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),

              // Success Overlay
              if (_paymentComplete) _buildSuccessOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          _buildPriceRow(
            "Subtotal",
            subtotal != null ? "₹${subtotal!.toStringAsFixed(0)}" : "—",
          ),
          SizedBox(height: 12.h),
          _buildPriceRow(
            "GST (18%)",
            gstAmount != null ? "₹${gstAmount!.toStringAsFixed(0)}" : "—",
          ),
          SizedBox(height: 12.h),
          _buildPriceRow(
            "Total Payable",
            totalPayable != null ? "₹${totalPayable!.toStringAsFixed(0)}" : "—",
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodOption(PaymentMethod method) {
    final isSelected = _selectedPaymentMethod == method.id;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = method.id),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: Center(
                child: SvgPicture.asset(method.icon, width: 24.w, height: 24.w),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                method.name,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            // Custom radio button
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.brown : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.brown,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 32.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Confetti image at the top
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
                child: Image.asset(
                  'assets/payment/sucess.png',
                  width: double.infinity,
                  height: 150.h,
                  fit: BoxFit.cover,
                ),
              ),

              // Content section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: Column(
                  children: [
                    Text(
                      "Successfully Registered!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "Thank you for registering! Your application has been successfully submitted and is now pending administrative review.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MainNavigationScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      child: Text(
                        "Go to home",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
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
    );
  }
}

class PaymentMethod {
  final String id;
  final String name;
  final String icon;
  final bool isCard;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    this.isCard = false,
  });
}
