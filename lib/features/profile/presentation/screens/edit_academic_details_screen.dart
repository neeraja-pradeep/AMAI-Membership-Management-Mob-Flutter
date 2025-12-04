import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';

/// Edit Academic Details Screen (Practitioner only)
/// Allows practitioners to edit their academic qualifications
class EditAcademicDetailsScreen extends ConsumerStatefulWidget {
  const EditAcademicDetailsScreen({super.key});

  @override
  ConsumerState<EditAcademicDetailsScreen> createState() =>
      _EditAcademicDetailsScreenState();
}

class _EditAcademicDetailsScreenState
    extends ConsumerState<EditAcademicDetailsScreen> {
  // Academic qualification checkboxes
  bool _ugSelected = false;
  bool _pgSelected = false;
  bool _phdSelected = false;
  bool _ccrasSelected = false;
  bool _pgDiplomaSelected = false;
  bool _otherSelected = false;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Academic Details',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner about pending approval
            _buildInfoBanner(),
            SizedBox(height: 24.h),

            // Section Header
            Text(
              'Select your academic qualifications',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Please select all that apply',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 16.h),

            // Academic Qualifications Card
            Container(
              padding: EdgeInsets.all(16.w),
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
              child: Column(
                children: [
                  _buildCheckboxItem(
                    label: 'UG (Under Graduate)',
                    subtitle: 'Bachelor\'s degree in Ayurveda (BAMS)',
                    value: _ugSelected,
                    onChanged: (value) {
                      setState(() {
                        _ugSelected = value ?? false;
                      });
                    },
                  ),
                  _buildDivider(),
                  _buildCheckboxItem(
                    label: 'PG (Post Graduate)',
                    subtitle: 'Master\'s degree in Ayurveda (MD/MS)',
                    value: _pgSelected,
                    onChanged: (value) {
                      setState(() {
                        _pgSelected = value ?? false;
                      });
                    },
                  ),
                  _buildDivider(),
                  _buildCheckboxItem(
                    label: 'PhD',
                    subtitle: 'Doctorate in Ayurveda',
                    value: _phdSelected,
                    onChanged: (value) {
                      setState(() {
                        _phdSelected = value ?? false;
                      });
                    },
                  ),
                  _buildDivider(),
                  _buildCheckboxItem(
                    label: 'CCRAS',
                    subtitle:
                        'Central Council for Research in Ayurvedic Sciences',
                    value: _ccrasSelected,
                    onChanged: (value) {
                      setState(() {
                        _ccrasSelected = value ?? false;
                      });
                    },
                  ),
                  _buildDivider(),
                  _buildCheckboxItem(
                    label: 'PG Diploma',
                    subtitle: 'Post Graduate Diploma in Ayurveda',
                    value: _pgDiplomaSelected,
                    onChanged: (value) {
                      setState(() {
                        _pgDiplomaSelected = value ?? false;
                      });
                    },
                  ),
                  _buildDivider(),
                  _buildCheckboxItem(
                    label: 'Other',
                    subtitle: 'Any other academic qualification',
                    value: _otherSelected,
                    onChanged: (value) {
                      setState(() {
                        _otherSelected = value ?? false;
                      });
                    },
                    isLast: true,
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: _isSubmitting
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
                        'Submit Request',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.info, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Changes to your academic details require admin approval and may take some time to reflect.',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.info,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxItem({
    required String label,
    required String subtitle,
    required bool value,
    required void Function(bool?) onChanged,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
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
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: AppColors.dividerLight,
      height: 1,
    );
  }

  bool get _hasSelection =>
      _ugSelected ||
      _pgSelected ||
      _phdSelected ||
      _ccrasSelected ||
      _pgDiplomaSelected ||
      _otherSelected;

  Future<void> _onSubmit() async {
    if (!_hasSelection) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Please select at least one academic qualification'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call (static for now)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    // Show success dialog
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 24.sp),
            SizedBox(width: 8.w),
            const Text('Request Submitted'),
          ],
        ),
        content: const Text(
          'Your academic details update request has been submitted successfully. Changes will be reflected after admin approval.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'OK',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
