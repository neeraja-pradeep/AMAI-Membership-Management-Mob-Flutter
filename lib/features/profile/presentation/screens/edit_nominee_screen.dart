import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/aswas_plus/application/providers/registration_providers.dart';
import 'package:myapp/features/aswas_plus/domain/entities/nominee.dart';

/// Edit Nominee Details Screen (Practitioner only)
/// Allows practitioners to edit their ASWAS Plus nominee information
class EditNomineeScreen extends ConsumerStatefulWidget {
  const EditNomineeScreen({
    required this.nominee,
    super.key,
  });

  /// The nominee data to edit
  final Nominee nominee;

  @override
  ConsumerState<EditNomineeScreen> createState() => _EditNomineeScreenState();
}

class _EditNomineeScreenState extends ConsumerState<EditNomineeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _contactController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _allocationController;
  String? _selectedRelation;
  DateTime? _selectedDateOfBirth;
  bool _isPrimary = false;
  bool _isSubmitting = false;

  // Relation options (static for now - will be from API later)
  final List<String> _relationOptions = [
    'Spouse',
    'Father',
    'Mother',
    'Son',
    'Daughter',
    'Brother',
    'Sister',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing nominee data
    _nameController = TextEditingController(text: widget.nominee.nomineeName);
    _contactController =
        TextEditingController(text: widget.nominee.contactNumber);
    _emailController = TextEditingController(text: widget.nominee.email ?? '');
    _addressController =
        TextEditingController(text: widget.nominee.address ?? '');
    _allocationController =
        TextEditingController(text: widget.nominee.allocationPercentage ?? '');

    // Pre-fill relationship dropdown
    _selectedRelation = _getRelationshipDisplayValue(widget.nominee.relationship);

    // Pre-fill date of birth
    if (widget.nominee.dateOfBirth != null &&
        widget.nominee.dateOfBirth!.isNotEmpty) {
      _selectedDateOfBirth = DateTime.tryParse(widget.nominee.dateOfBirth!);
    }

    // Pre-fill is primary
    _isPrimary = widget.nominee.isPrimary;
  }

  /// Converts API relationship value to display value
  String? _getRelationshipDisplayValue(String relationship) {
    final lowerRelation = relationship.toLowerCase();
    for (final option in _relationOptions) {
      if (option.toLowerCase() == lowerRelation) {
        return option;
      }
    }
    // Handle 'parent' case which maps to Father/Mother
    if (lowerRelation == 'parent') {
      return 'Father';
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _allocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Nominee Details',
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
              // Info banner about ASWAS Plus nominee
              _buildInfoBanner(),
              SizedBox(height: 24.h),

              // Section Header
              Text(
                'ASWAS Plus Nominee',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Please provide the details of your nominee for ASWAS Plus insurance benefits.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 24.h),

              // Nominee Details Card
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Field
                    _buildTextField(
                      label: 'Nominee Name',
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nominee name is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Relation Dropdown
                    _buildDropdownField(
                      label: 'Relationship',
                      value: _selectedRelation,
                      items: _relationOptions,
                      onChanged: (value) {
                        setState(() {
                          _selectedRelation = value;
                        });
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Date of Birth Field
                    _buildDatePickerField(
                      label: 'Date of Birth',
                      selectedDate: _selectedDateOfBirth,
                      onDateSelected: (date) {
                        setState(() {
                          _selectedDateOfBirth = date;
                        });
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Contact Field
                    _buildTextField(
                      label: 'Contact Number',
                      controller: _contactController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Contact number is required';
                        }
                        if (value.length < 10) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Email Field
                    _buildTextField(
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );
                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Address Field
                    _buildTextField(
                      label: 'Address',
                      controller: _addressController,
                      maxLines: 3,
                    ),
                    SizedBox(height: 16.h),

                    // Allocation Percentage Field
                    _buildTextField(
                      label: 'Allocation Percentage',
                      controller: _allocationController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final percentage = double.tryParse(value);
                          if (percentage == null ||
                              percentage < 0 ||
                              percentage > 100) {
                            return 'Please enter a valid percentage (0-100)';
                          }
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Is Primary Switch
                    _buildSwitchField(
                      label: 'Primary Nominee',
                      value: _isPrimary,
                      onChanged: (value) {
                        setState(() {
                          _isPrimary = value;
                        });
                      },
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.info, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Important Information',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.info,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'The nominee you specify here will be the beneficiary of your ASWAS Plus insurance. Changes require admin approval.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.info,
                  ),
                ),
              ],
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
    int maxLines = 1,
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
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.grey50,
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
            color: AppColors.grey50,
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

  Widget _buildDatePickerField({
    required String label,
    required DateTime? selectedDate,
    required void Function(DateTime) onDateSelected,
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
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppColors.primary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              onDateSelected(picked);
            }
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.grey300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}'
                      : 'Select $label',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: selectedDate != null
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

  Widget _buildSwitchField({
    required String label,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRelation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select the relation with nominee'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Build the payload
    final payload = <String, dynamic>{
      'nominee_name': _nameController.text.trim(),
      'relationship': _selectedRelation!.toLowerCase(),
      'contact_number': _contactController.text.trim(),
      'is_primary': _isPrimary,
    };

    // Add optional fields only if they have values
    if (_selectedDateOfBirth != null) {
      payload['date_of_birth'] =
          '${_selectedDateOfBirth!.year}-${_selectedDateOfBirth!.month.toString().padLeft(2, '0')}-${_selectedDateOfBirth!.day.toString().padLeft(2, '0')}';
    }
    if (_emailController.text.trim().isNotEmpty) {
      payload['email'] = _emailController.text.trim();
    }
    if (_addressController.text.trim().isNotEmpty) {
      payload['address'] = _addressController.text.trim();
    }
    if (_allocationController.text.trim().isNotEmpty) {
      payload['allocation_percentage'] = _allocationController.text.trim();
    }

    // Call the PATCH API using the nominee's ID
    final result = await ref.read(
      nomineeUpdateProvider(
        NomineeUpdateParams(
          nomineeId: widget.nominee.id,
          payload: payload,
        ),
      ).future,
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
      (success) {
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
          'Your nominee details update request has been submitted successfully. Changes will be reflected after admin approval.',
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
