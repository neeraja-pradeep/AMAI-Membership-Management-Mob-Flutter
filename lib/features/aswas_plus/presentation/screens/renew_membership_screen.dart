import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/aswas_plus/application/providers/renewal_providers.dart';
import 'package:myapp/features/aswas_plus/application/states/renewal_state.dart';
import 'package:myapp/features/aswas_plus/domain/entities/digital_product.dart';
import 'package:myapp/features/aswas_plus/presentation/screens/select_payment_method_screen.dart';
import 'package:myapp/features/home/application/providers/home_providers.dart';

/// Renew Membership Screen
/// Shows renewal options for membership and Aswas Plus
class RenewMembershipScreen extends ConsumerStatefulWidget {
  const RenewMembershipScreen({
    super.key,
    this.defaultSelectedProductId,
  });

  /// Default product ID to select on screen load
  /// If null, defaults to Aswas Plus (for backward compatibility)
  final int? defaultSelectedProductId;

  @override
  ConsumerState<RenewMembershipScreen> createState() =>
      _RenewMembershipScreenState();
}

class _RenewMembershipScreenState extends ConsumerState<RenewMembershipScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(renewalStateProvider.notifier).loadProducts();
      // Select the default product based on where navigation came from
      // If coming from membership screen, select membership; otherwise select Aswas Plus
      final defaultProductId = widget.defaultSelectedProductId ?? RenewalProductIds.aswasPlus;
      ref.read(renewalStateProvider.notifier).selectProduct(defaultProductId);
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final state = ref.watch(renewalStateProvider);

    return state.when(
      initial: () => const Center(child: CircularProgressIndicator()),
      loading: () => const Center(child: CircularProgressIndicator()),
      loaded: (membershipProduct, aswasProduct, selectedId) => _buildContent(
        membershipProduct: membershipProduct,
        aswasProduct: aswasProduct,
        selectedProductId: selectedId ?? RenewalProductIds.aswasPlus,
      ),
      error: (failure) => _buildErrorState(failure.message),
    );
  }

  Widget _buildContent({
    required DigitalProduct membershipProduct,
    required DigitalProduct aswasProduct,
    required int selectedProductId,
  }) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Renewal Option',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 16.h),

                // Membership Product Card
                _buildProductCard(
                  product: membershipProduct,
                  subtitle: 'Annual renewal required',
                  isSelected: selectedProductId == membershipProduct.id,
                  onTap: () => ref
                      .read(renewalStateProvider.notifier)
                      .selectProduct(membershipProduct.id),
                ),

                SizedBox(height: 16.h),

                // Aswas Plus Product Card
                _buildProductCard(
                  product: aswasProduct,
                  subtitle: 'Health insurance add-on',
                  isSelected: selectedProductId == aswasProduct.id,
                  onTap: () => ref
                      .read(renewalStateProvider.notifier)
                      .selectProduct(aswasProduct.id),
                ),

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

                _buildUserDetailsCard(),
              ],
            ),
          ),
        ),

        // Bottom Buttons
        _buildBottomButtons(),
      ],
    );
  }

  Widget _buildUserDetailsCard() {
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
          _buildDetailRow('Full Name', 'John Doe'),
          SizedBox(height: 12.h),
          _buildDetailRow('Membership ID', 'AMAI-2024-001234'),
          SizedBox(height: 12.h),
          _buildDetailRow('Email Address', 'john.doe@example.com'),
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
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
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
      final repository = ref.read(homeRepositoryProvider);
      final result = await repository.initiateInsuranceRenewal();

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
        (renewalResponse) {
          setState(() {
            _isLoading = false;
          });
          if (renewalResponse != null) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => SelectPaymentMethodScreen(
                  renewalResponse: renewalResponse,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Failed to initiate renewal'),
                backgroundColor: AppColors.error,
              ),
            );
          }
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

  Widget _buildProductCard({
    required DigitalProduct product,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey200,
            width: isSelected ? 2.w : 1.w,
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
            // Radio button
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.grey400,
                  width: 2.w,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 16.w),

            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.productName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        product.displayPrice,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
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
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'Failed to load products',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () =>
                  ref.read(renewalStateProvider.notifier).loadProducts(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
