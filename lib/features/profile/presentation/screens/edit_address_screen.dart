import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/home/application/providers/home_providers.dart';
import 'package:myapp/features/profile/application/providers/profile_providers.dart';

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
  bool _hasPendingRequest = false;

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
    // Pre-fill addresses after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillAddressData();
    });
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

  /// Pre-fills address fields from API data
  Future<void> _prefillAddressData() async {
    try {
      final addresses = await ref.read(addressesProvider.future);
      if (addresses.isEmpty) return;

      // Find communications address first, then fall back to first address
      Map<String, dynamic>? addressToUse;
      for (final addr in addresses) {
        if (addr['type'] == 'communications') {
          addressToUse = addr;
          break;
        }
      }
      addressToUse ??= addresses.first;

      if (!mounted) return;

      setState(() {
        // Pre-fill text fields
        _houseNoController.text = addressToUse?['address_line1'] ?? '';
        _streetController.text = addressToUse?['address_line2'] ?? '';
        _cityController.text = addressToUse?['city'] ?? '';
        _postalCodeController.text = addressToUse?['postal_code'] ?? '';
        _districtController.text = addressToUse?['district'] ?? '';

        // Pre-fill country dropdown
        final country = addressToUse?['country'];
        if (country != null && _countryOptions.contains(country)) {
          _selectedCountry = country;
        }

        // Pre-fill state dropdown
        final state = addressToUse?['state'];
        if (state != null && _stateOptions.contains(state)) {
          _selectedState = state;
        }

        // Set address type checkboxes based on available addresses
        for (final addr in addresses) {
          if (addr['type'] == 'apta') {
            _isAptaMailingAddress = true;
          }
          if (addr['type'] == 'permanent') {
            _isPermanentAddress = true;
          }
        }
      });
    } catch (e) {
      // Handle error silently - fields will remain empty
    }
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
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
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

              // Pending Request Banner
              if (_hasPendingRequest) ...[
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.hourglass_empty,
                        color: AppColors.warning,
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'You have a pending request awaiting admin approval. You can submit another request after the current one is approved.',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
              ],

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isSubmitting || _hasPendingRequest)
                      ? null
                      : _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasPendingRequest
                        ? AppColors.grey400
                        : AppColors.primary,
                    disabledBackgroundColor: AppColors.grey300,
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
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.white,
                            ),
                          ),
                        )
                      : Text(
                          _hasPendingRequest
                              ? 'Request Pending Approval'
                              : 'Submit Request',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: _hasPendingRequest
                                ? AppColors.grey600
                                : AppColors.white,
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
              style: TextStyle(fontSize: 12.sp, color: AppColors.info),
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
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
          ),
          style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
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
                style: TextStyle(fontSize: 14.sp, color: AppColors.textHint),
              ),
              icon: const Icon(
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
              style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
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
        const SnackBar(
          content: Text('Please select a state'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Determine address type based on checkboxes
    String addressType;
    if (_isAptaMailingAddress) {
      addressType = 'apta';
    } else if (_isPermanentAddress) {
      addressType = 'permanent';
    } else {
      addressType = 'communications';
    }

    // Build the data map for API
    final data = <String, dynamic>{
      'address_line1': _houseNoController.text.trim(),
      'address_line2': _streetController.text.trim(),
      'city': _postOfficeController.text.trim(),
      'postal_code': _postalCodeController.text.trim(),
      'country': _selectedCountry,
      'state': _selectedState,
      'district': _districtController.text.trim(),
      'type': addressType,
    };

    // Call the API
    final repository = ref.read(profileRepositoryProvider);
    final userId = ref.read(userIdProvider);
    final result = await repository.updatePersonalInfo(
      userId: userId,
      data: data,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    result.fold(
      (failure) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (updatedProfile) {
        // Set pending request state to true
        setState(() {
          _hasPendingRequest = true;
        });

        // Refresh the profile data
        ref.read(profileStateProvider.notifier).refresh();

        // Show success dialog
        _showSuccessDialog();
      },
    );
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
          'Your address update request has been submitted successfully. Changes will be reflected after admin approval.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
