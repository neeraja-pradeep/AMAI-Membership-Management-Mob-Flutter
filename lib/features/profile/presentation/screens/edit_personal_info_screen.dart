import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/home/application/providers/home_providers.dart';
import 'package:myapp/features/profile/application/providers/profile_providers.dart';
import 'package:myapp/features/profile/domain/entities/user_profile.dart';

/// Edit Personal Information Screen
/// Allows users to edit their personal details
class EditPersonalInfoScreen extends ConsumerStatefulWidget {
  const EditPersonalInfoScreen({super.key, required this.userProfile});

  final UserProfile userProfile;

  @override
  ConsumerState<EditPersonalInfoScreen> createState() =>
      _EditPersonalInfoScreenState();
}

class _EditPersonalInfoScreenState
    extends ConsumerState<EditPersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _whatsappController;
  DateTime? _selectedDateOfBirth;
  String? _selectedGender;
  String? _selectedBloodGroup;
  bool _whatsappSameAsPhone = false;
  bool _isSubmitting = false;
  bool _hasPendingRequest = false;

  // Dropdown options (static for now - will be from API later)
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _bloodGroupOptions = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  void _initializeFormData() {
    final profile = widget.userProfile;
    _nameController = TextEditingController(text: profile.fullName);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phone);
    _whatsappController = TextEditingController(text: profile.phone);
    _selectedDateOfBirth = profile.dateOfBirth;

    // Validate gender against dropdown options (set to null if not a valid option)
    final formattedGender = profile.formattedGender;
    _selectedGender = _genderOptions.contains(formattedGender)
        ? formattedGender
        : null;

    // Validate blood group against dropdown options (set to null if not a valid option)
    final bloodGroup = profile.bloodGroup;
    _selectedBloodGroup = _bloodGroupOptions.contains(bloodGroup)
        ? bloodGroup
        : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Personal Information',
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
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info banner about pending approval
              _buildInfoBanner(),
              SizedBox(height: 24.h),

              // Name Field
              _buildTextField(
                label: 'Full Name',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Email Field
              _buildTextField(
                label: 'Email Address',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Phone Number Field
              _buildTextField(
                label: 'Phone Number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone number is required';
                  }
                  if (value.length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (_whatsappSameAsPhone) {
                    _whatsappController.text = value;
                  }
                },
              ),
              SizedBox(height: 16.h),

              // WhatsApp Number Field
              _buildTextField(
                label: 'WhatsApp Number',
                controller: _whatsappController,
                keyboardType: TextInputType.phone,
                enabled: !_whatsappSameAsPhone,
              ),
              SizedBox(height: 8.h),

              // Same as Phone Checkbox
              Row(
                children: [
                  SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: Checkbox(
                      value: _whatsappSameAsPhone,
                      onChanged: (value) {
                        setState(() {
                          _whatsappSameAsPhone = value ?? false;
                          if (_whatsappSameAsPhone) {
                            _whatsappController.text = _phoneController.text;
                          }
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Same as phone number',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Date of Birth Field
              _buildDatePickerField(
                label: 'Date of Birth',
                value: _selectedDateOfBirth,
                onTap: _selectDateOfBirth,
              ),
              SizedBox(height: 16.h),

              // Gender Dropdown
              _buildDropdownField(
                label: 'Gender',
                value: _selectedGender,
                items: _genderOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              SizedBox(height: 16.h),

              // Blood Group Dropdown
              _buildDropdownField(
                label: 'Blood Group',
                value: _selectedBloodGroup,
                items: _bloodGroupOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedBloodGroup = value;
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
              'Changes to your profile require admin approval and may take some time to reflect.',
              style: TextStyle(fontSize: 12.sp, color: AppColors.info),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool enabled = true,
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
          onChanged: onChanged,
          enabled: enabled,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? AppColors.white : AppColors.grey100,
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
          style: TextStyle(
            fontSize: 14.sp,
            color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
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
        InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.grey300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value != null
                      ? DateFormat('dd MMM yyyy').format(value)
                      : 'Select date',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: value != null
                        ? AppColors.textPrimary
                        : AppColors.textHint,
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.grey400,
                  size: 20.sp,
                ),
              ],
            ),
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

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Build the data map for API
    final data = <String, dynamic>{
      'first_name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'wa_phone': _whatsappController.text.trim(),
    };

    // Add date of birth if selected (format: YYYY-MM-DD)
    if (_selectedDateOfBirth != null) {
      data['date_of_birth'] = DateFormat(
        'yyyy-MM-dd',
      ).format(_selectedDateOfBirth!);
    }

    // Add gender if selected (lowercase for API)
    if (_selectedGender != null) {
      data['gender'] = _selectedGender!.toLowerCase();
    }

    // Add blood group if selected
    if (_selectedBloodGroup != null) {
      data['blood_group'] = _selectedBloodGroup;
    }

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
            backgroundColor: Color(0xFF60212E),
          ),
        );
      },
      (success) {
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
          'Your profile update request has been submitted successfully. Changes will be reflected after admin approval.',
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
