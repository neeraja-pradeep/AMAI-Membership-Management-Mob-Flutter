import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/membership/application/providers/membership_providers.dart';
import 'package:myapp/features/membership/infrastructure/models/payment_receipt_model.dart';

/// Payment Receipts Section widget
/// Displays a list of payment history with view and download icons
class PaymentReceiptsSection extends ConsumerWidget {
  const PaymentReceiptsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receiptsAsync = ref.watch(paymentReceiptsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Text(
          'Payment Receipts',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),

        // Receipts List
        receiptsAsync.when(
          data: (receipts) {
            if (receipts.isEmpty) {
              return _buildEmptyState();
            }
            return _buildReceiptsList(receipts);
          },
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(error.toString()),
        ),
      ],
    );
  }

  /// Builds the empty state when no receipts
  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(24.w),
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
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48.sp,
              color: AppColors.grey400,
            ),
            SizedBox(height: 12.h),
            Text(
              'No payment history',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the loading state
  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.all(24.w),
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
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.w,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  /// Builds the error state
  Widget _buildErrorState(String error) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 20.sp, color: AppColors.error),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Failed to load payment receipts',
              style: TextStyle(fontSize: 14.sp, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the receipts list
  Widget _buildReceiptsList(List<PaymentReceiptModel> receipts) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: receipts.length,
      separatorBuilder: (context, index) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        return PaymentReceiptItem(receipt: receipts[index]);
      },
    );
  }
}

/// Individual payment receipt item widget
class PaymentReceiptItem extends StatelessWidget {
  const PaymentReceiptItem({super.key, required this.receipt});

  final PaymentReceiptModel receipt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
      child: Row(
        children: [
          // Receipt details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name / description
                Text(
                  receipt.productName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),

                // Payment date and amount
                Text(
                  '${_formatDate(receipt.paymentDate)} • ${_formatAmount(receipt.amount, receipt.currency)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Action icons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // View icon
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('View receipt coming soon'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Icon(
                  Icons.visibility_outlined,
                  size: 20.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(width: 16.w),

              // Download icon
              GestureDetector(
                onTap: () => _downloadReceipt(context, receipt.receiptPdfUrl),
                child: Icon(
                  Icons.download_outlined,
                  size: 20.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Formats the amount with currency symbol
  String _formatAmount(String amount, String currency) {
    final value = double.tryParse(amount) ?? 0.0;
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: currency == 'INR' ? '₹' : currency,
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  /// Formats the payment date
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  /// Downloads the receipt PDF
  Future<void> _downloadReceipt(BuildContext context, String? pdfUrl) async {
    if (pdfUrl == null || pdfUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receipt PDF not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String fullUrl = pdfUrl;
    if (!pdfUrl.startsWith('http://') && !pdfUrl.startsWith('https://')) {
      fullUrl = 'https://$pdfUrl';
    }

    try {
      final uri = Uri.parse(fullUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open receipt PDF'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening receipt: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
