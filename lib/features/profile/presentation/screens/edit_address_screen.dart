import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';

/// Edit Saved Addresses Screen
/// Allows users to edit their address information
class EditAddressScreen extends ConsumerStatefulWidget {
  const EditAddressScreen({super.key});

  @override
  ConsumerState<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends ConsumerState<EditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _houseNoController;
  late TextEditingController _streetController;
  late TextEditingController _postOfficeController;
  late TextEditingController _postalCodeController;
  late TextEditingController _districtController;
  late TextEditingController _cityController;
  String? _selectedCountry;
  String? _selectedState;
  bool _isAptaMailingAddress = false;
  bool _isPermanentAddress = true;
  bool _isSubmitting = false;

  // Dropdown options (static for now - will be from API later)
  final List<String> _countryOptions = ['India'];
  final List<String> _stateOptions = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  void _initializeFormData() {
    _houseNoController = TextEditingController();
    _streetController = TextEditingController();
    _postOfficeController = TextEditingController();
    _postalCodeController = TextEditingController();
    _districtController = TextEditingController();
    _cityController = TextEditingController();
    _selectedCountry = 'India';
  }

  @override
  void dispose() {
    _houseNoController.dispose();
    _streetController.dispose();
    _postOfficeController.dispose();
    _postalCodeController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Saved Addresses',
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info banner about pending approval
              _buildInfoBanner(),
              SizedBox(height: 24.h),

              // House No. / Building Name Field
              _buildTextField(
                label: 'House No. / Building Name',
                controller: _houseNoController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Street / Locality / Area Field
              _buildTextField(
                label: 'Street / Locality / Area',
                controller: _streetController,
              ),
              SizedBox(height: 16.h),

              // City Field
              _buildTextField(
                label: 'City',
                controller: _cityController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'City is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Post Office Field
              _buildTextField(
                label: 'Post Office',
                controller: _postOfficeController,
              ),
              SizedBox(height: 16.h),

              // Postal Code Field
              _buildTextField(
                label: 'Postal Code',
                controller: _postalCodeController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Postal code is required';
                  }
                  if (value.length != 6) {
                    return 'Please enter a valid 6-digit postal code';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Country Dropdown
              _buildDropdownField(
                label: 'Country',
                value: _selectedCountry,
                items: _countryOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedCountry = value;
                  });
                },
              ),
              SizedBox(height: 16.h),

              // State Dropdown
              _buildDropdownField(
                label: 'State',
                value: _selectedState,
                items: _stateOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedState = value;
                  });
                },
              ),
              SizedBox(height: 16.h),

              // District Field
              _buildTextField(
                label: 'District',
                controller: _districtController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'District is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Address Type Checkboxes
              _buildSectionHeader('Address Type'),
              SizedBox(height: 8.h),

              // Apta Mailing Address Checkbox
              _buildCheckboxItem(
                label: 'Set as Apta Mailing Address',
                value: _isAptaMailingAddress,
                onChanged: (value) {
                  setState(() {
                    _isAptaMailingAddress = value ?? false;
                  });
                },
              ),

              // Permanent Address Checkbox
              _buildCheckboxItem(
                label: 'Set as Permanent Address',
                value: _isPermanentAddress,
                onChanged: (value) {
                  setState(() {
                    _isPermanentAddress = value ?? false;
                  });
                },
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
                          'Save Address',
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
              'Changes to your address require admin approval and may take some time to reflect.',
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
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
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.error),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
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
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.grey300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                'Select $label',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textHint,
                ),
              ),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.grey400,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxItem({
    required String label,
    required bool value,
    required void Function(bool?) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
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
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedState == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a state'),
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
            const Text('Address Saved'),
          ],
        ),
        content: const Text(
          'Your address has been saved successfully. Changes will be reflected after admin approval.',
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
