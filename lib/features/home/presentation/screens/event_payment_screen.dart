import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/core/network/api_client_provider.dart';
import 'package:myapp/features/home/domain/entities/upcoming_event.dart';
import 'package:myapp/features/home/infrastructure/data_sources/remote/home_api.dart';
import 'package:myapp/features/home/presentation/screens/event_registration_success_screen.dart';

/// Event payment screen for selecting payment method and processing payment
class EventPaymentScreen extends ConsumerStatefulWidget {
  const EventPaymentScreen({
    required this.event,
    super.key,
  });

  final UpcomingEvent event;

  @override
  ConsumerState<EventPaymentScreen> createState() =>
      _EventPaymentScreenState();
}

class _EventPaymentScreenState extends ConsumerState<EventPaymentScreen> {
  bool _isProcessing = false;

  double get _subtotal {
    final price = double.tryParse(widget.event.ticketPrice) ?? 0;
    return price;
  }

  double get _gst {
    return _subtotal * 0.18; // 18% GST
  }

  double get _total {
    return _subtotal + _gst;
  }

  Future<void> _handlePayNow() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final homeApi = HomeApiImpl(apiClient: apiClient);

      // Register for event with online payment mode
      final response = await homeApi.registerForEvent(
        eventId: int.parse(widget.event.id),
        paymentMode: 'online',
      );

      if (response.data != null && mounted) {
        // TODO: Integrate with Razorpay payment gateway
        // For now, simulate successful payment
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          // Navigate to success screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => EventRegistrationSuccessScreen(
                event: widget.event,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          _showError('Registration failed. Please try again.');
        }
      }
    } catch (e) {
      debugPrint('Error processing payment: $e');
      if (mounted) {
        _showError('Payment failed. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF60212E),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Payment',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Details Card
                _buildEventCard(),
                SizedBox(height: 24.h),
                // Payment Summary
                _buildPaymentSummary(),
                SizedBox(height: 24.h),
                // Razorpay Logo/Info
                _buildRazorpayInfo(),
                SizedBox(height: 100.h), // Space for bottom buttons
              ],
            ),
          ),
          // Bottom Buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.event.title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14.sp, color: AppColors.textSecondary),
              SizedBox(width: 6.w),
              Text(
                widget.event.displayDate,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Summary',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          _buildPriceRow('Subtotal', _subtotal),
          SizedBox(height: 12.h),
          _buildPriceRow('GST (18%)', _gst),
          SizedBox(height: 12.h),
          Divider(color: AppColors.grey300),
          SizedBox(height: 12.h),
          _buildPriceRow('Total Payable', _total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 18.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? AppColors.brown : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildRazorpayInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Row(
        children: [
          Icon(Icons.security, size: 24.sp, color: AppColors.brown),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure Payment',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Powered by Razorpay',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isProcessing ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.brown),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              child: Text(
                'Back',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brown,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _handlePayNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                elevation: 0,
              ),
              child: _isProcessing
                  ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
        ],
      ),
    );
  }
}
