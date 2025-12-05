import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/home/application/providers/home_providers.dart';
import 'package:myapp/features/membership/application/providers/membership_providers.dart';
import 'package:myapp/features/membership/presentation/screens/membership_payment_screen.dart';

/// Membership Renew Screen
/// Shows membership renewal option with user details
class MembershipRenewScreen extends ConsumerStatefulWidget {
  const MembershipRenewScreen({super.key});

  @override
  ConsumerState<MembershipRenewScreen> createState() =>
      _MembershipRenewScreenState();
}

class _MembershipRenewScreenState extends ConsumerState<MembershipRenewScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final membershipState = ref.watch(membershipScreenStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Renew Membership',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Renewal Option',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Membership Renewal Card (pre-selected)
                  _buildMembershipCard(membershipState),

                  SizedBox(height: 24.h),

                  // User Details Section
                  Text(
                    'Your Details',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  _buildUserDetailsCard(membershipState),
                ],
              ),
            ),
          ),

          // Bottom Buttons
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildMembershipCard(dynamic membershipState) {
    final membershipData = membershipState.currentData;
    final membershipType = membershipData?.displayMembershipType ?? 'Membership';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.primary,
          width: 2.w,
        ),
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
          // Radio button (always selected)
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary,
                width: 2.w,
              ),
            ),
            child: Center(
              child: Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),

          // Membership details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$membershipType Membership',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Annual renewal required',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
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

  Widget _buildUserDetailsCard(dynamic membershipState) {
    final membershipData = membershipState.currentData;

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
          _buildDetailRow(
            'Full Name',
            membershipData?.memberName ?? 'N/A',
          ),
          SizedBox(height: 12.h),
          _buildDetailRow(
            'Membership ID',
            membershipData?.membershipNumber ?? 'N/A',
          ),
          SizedBox(height: 12.h),
          _buildDetailRow(
            'Membership Type',
            membershipData?.displayMembershipType ?? 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Proceed to Payment Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onProceedToPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.w,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.white),
                        ),
                      )
                    : Text(
                        'Proceed to Payment',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 12.h),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _onCancel,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  side: BorderSide(color: AppColors.grey400, width: 1.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onProceedToPayment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = ref.read(userIdProvider);
      final repository = ref.read(membershipRepositoryProvider);
      final result = await repository.initiateMembershipPayment(userId: userId);

      if (!mounted) return;

      result.fold(
        (failure) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: AppColors.error,
            ),
          );
        },
        (paymentResponse) {
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => MembershipPaymentScreen(
                paymentResponse: paymentResponse,
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _onCancel() {
    Navigator.of(context).pop();
  }
}
