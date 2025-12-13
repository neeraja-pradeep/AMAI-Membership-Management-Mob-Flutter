import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/core/config/razorpay_config.dart';
import 'package:myapp/features/membership/application/providers/membership_providers.dart';
import 'package:myapp/features/membership/domain/entities/membership_payment_response.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

/// Membership Payment Screen
/// Shows payment options and total amount for membership renewal
class MembershipPaymentScreen extends ConsumerStatefulWidget {
  const MembershipPaymentScreen({super.key, required this.paymentResponse});

  final MembershipPaymentResponse paymentResponse;

  @override
  ConsumerState<MembershipPaymentScreen> createState() =>
      _MembershipPaymentScreenState();
}

class _MembershipPaymentScreenState
    extends ConsumerState<MembershipPaymentScreen> {
  late Razorpay _razorpay;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Verify payment with backend
    _verifyPayment(
      orderId: response.orderId ?? '',
      paymentId: response.paymentId ?? '',
      signature: response.signature ?? '',
    );
  }

  Future<void> _verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    final repository = ref.read(membershipRepositoryProvider);
    final result = await repository.verifyMembershipPayment(
      razorpayOrderId: orderId,
      razorpayPaymentId: paymentId,
      razorpaySignature: signature,
    );

    setState(() {
      _isProcessing = false;
    });

    result.fold(
      (failure) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment verification failed: ${failure.message}'),
            backgroundColor: Color(0xFF60212E),
          ),
        );
      },
      (success) {
        if (success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment Successful! ID: $paymentId'),
              backgroundColor: Colors.white,
              contentTextStyle: TextStyle(color: Colors.black),
            ),
          );
          // Navigate back to home
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          // Show verification failed message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment verification failed'),
              backgroundColor: Color(0xFF60212E),
            ),
          );
        }
      },
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _isProcessing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message ?? 'Unknown error'}'),
        backgroundColor: Color(0xFF60212E),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      _isProcessing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External Wallet: ${response.walletName}'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _openRazorpayCheckout() {
    setState(() {
      _isProcessing = true;
    });

    var options = {
      'key': RazorpayConfig.apiKey,
      'amount': widget.paymentResponse.amount * 100, // Amount in paise
      'currency': widget.paymentResponse.currency,
      'name': RazorpayConfig.companyName,
      'description': 'Membership Renewal',
      'order_id': widget.paymentResponse.orderId,
      'timeout': RazorpayConfig.timeout,
      'prefill': {'contact': '', 'email': ''},
      'theme': {
        'color': '#${RazorpayConfig.themeColor.toRadixString(16).substring(2)}',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Color(0xFF60212E),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Select Payment Method',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.lightBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Amount Card
                  _buildTotalAmountCard(),

                  SizedBox(height: 24.h),

                  // Payment Breakdown Section
                  if (widget.paymentResponse.hasFine) ...[
                    Text(
                      'Payment Breakdown',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildPaymentBreakdownCard(),
                    SizedBox(height: 24.h),
                  ],

                  // Payment Methods Section
                  Text(
                    'Choose Payment Method',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Payment method options
                  _buildPaymentMethodCard(
                    icon: Icons.account_balance,
                    title: 'Net Banking',
                    subtitle: 'Pay using your bank account',
                  ),
                  SizedBox(height: 12.h),
                  _buildPaymentMethodCard(
                    icon: Icons.credit_card,
                    title: 'Credit/Debit Card',
                    subtitle: 'Visa, Mastercard, RuPay',
                  ),
                  SizedBox(height: 12.h),
                  _buildPaymentMethodCard(
                    icon: Icons.phone_android,
                    title: 'UPI',
                    subtitle: 'Google Pay, PhonePe, Paytm',
                  ),
                ],
              ),
            ),
          ),

          // Pay Now Button
          _buildPayNowButton(),
        ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalAmountCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Amount',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            widget.paymentResponse.displayAmount,
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'Order ID: ${widget.paymentResponse.orderId}',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBreakdownCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildBreakdownRow(
            'Membership Fee',
            widget.paymentResponse.displayMembershipFee,
          ),
          if (widget.paymentResponse.hasFine) ...[
            SizedBox(height: 8.h),
            _buildBreakdownRow(
              'Late Fee (${widget.paymentResponse.delayedMonths} months)',
              widget.paymentResponse.displayFine,
              isWarning: true,
            ),
          ],
          SizedBox(height: 8.h),
          const Divider(color: AppColors.grey200),
          SizedBox(height: 8.h),
          _buildBreakdownRow(
            'Total',
            widget.paymentResponse.displayAmount,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(
    String label,
    String value, {
    bool isBold = false,
    bool isWarning = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: isWarning ? AppColors.warning : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            color: isWarning ? AppColors.warning : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey200, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 24.sp, color: AppColors.primary),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 24.sp, color: AppColors.grey400),
        ],
      ),
    );
  }

  Widget _buildPayNowButton() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8.r,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _openRazorpayCheckout,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: _isProcessing
                ? SizedBox(
                    height: 20.h,
                    width: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.w,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.white,
                      ),
                    ),
                  )
                : Text(
                    'Pay Now',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
