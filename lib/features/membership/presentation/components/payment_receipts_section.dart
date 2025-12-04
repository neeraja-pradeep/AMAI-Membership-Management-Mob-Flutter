import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
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
            fontSize: 16.sp,
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
            blurRadius: 8,
            offset: const Offset(0, 2),
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
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
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
            blurRadius: 8,
            offset: const Offset(0, 2),
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
          Icon(
            Icons.error_outline,
            size: 20.sp,
            color: AppColors.error,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Failed to load payment receipts',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the receipts list
  Widget _buildReceiptsList(List<PaymentReceiptModel> receipts) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: receipts.length,
        separatorBuilder: (context, index) => Divider(
          color: AppColors.dividerLight,
          height: 1,
        ),
        itemBuilder: (context, index) {
          return PaymentReceiptItem(receipt: receipts[index]);
        },
      ),
    );
  }
}

/// Individual payment receipt item widget
class PaymentReceiptItem extends StatelessWidget {
  const PaymentReceiptItem({
    super.key,
    required this.receipt,
  });

  final PaymentReceiptModel receipt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Receipt icon
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.receipt_outlined,
              size: 20.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 12.w),

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

                // Amount
                Text(
                  _formatAmount(receipt.amount, receipt.currency),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
                SizedBox(height: 4.h),

                // Payment date and method
                Row(
                  children: [
                    Text(
                      _formatDate(receipt.paymentDate),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        receipt.paymentMethod.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action icons (static for now)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // View icon
              IconButton(
                icon: Icon(
                  Icons.visibility_outlined,
                  size: 20.sp,
                  color: AppColors.primary,
                ),
                onPressed: () {
                  // Static for now
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('View receipt coming soon'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                tooltip: 'View Receipt',
                constraints: BoxConstraints(
                  minWidth: 36.w,
                  minHeight: 36.h,
                ),
                padding: EdgeInsets.zero,
              ),

              // Download icon
              IconButton(
                icon: Icon(
                  Icons.download_outlined,
                  size: 20.sp,
                  color: AppColors.primary,
                ),
                onPressed: () {
                  // Static for now
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Download receipt coming soon'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                tooltip: 'Download Receipt',
                constraints: BoxConstraints(
                  minWidth: 36.w,
                  minHeight: 36.h,
                ),
                padding: EdgeInsets.zero,
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
      symbol: currency == 'INR' ? '\u20B9' : currency,
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  /// Formats the payment date
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (e) {
      return dateString;
    }
  }
}
