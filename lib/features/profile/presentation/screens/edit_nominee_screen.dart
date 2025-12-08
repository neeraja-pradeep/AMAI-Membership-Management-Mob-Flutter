import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/aswas_plus/application/providers/registration_providers.dart';
import 'package:myapp/features/aswas_plus/domain/entities/nominee.dart';

/// Edit Nominee Details Screen (Practitioner only)
/// Allows practitioners to edit their ASWAS Plus nominee information
class EditNomineeScreen extends ConsumerStatefulWidget {
  const EditNomineeScreen({required this.nominees, super.key});

  /// The list of nominees to display and edit
  final List<Nominee> nominees;

  @override
  ConsumerState<EditNomineeScreen> createState() => _EditNomineeScreenState();
}

class _EditNomineeScreenState extends ConsumerState<EditNomineeScreen> {
  final _formKey = GlobalKey<FormState>();
  late List<_NomineeFormData> _nomineeForms;
  int? _editingNomineeIndex;
  bool _isSubmitting = false;

  // Relation options - same as register_here_screen
  final List<String> _relationOptions = [
    'Spouse',
    'Child',
    'Parent',
    'Sibling',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize form data for each nominee
    _nomineeForms = widget.nominees.map((nominee) {
      return _NomineeFormData(
        nominee: nominee,
        nameController: TextEditingController(text: nominee.nomineeName),
        contactController: TextEditingController(text: nominee.contactNumber),
        emailController: TextEditingController(text: nominee.email ?? ''),
        addressController: TextEditingController(text: nominee.address ?? ''),
        allocationController: TextEditingController(
          text: nominee.allocationPercentage ?? '',
        ),
        selectedRelation: _getRelationshipDisplayValue(nominee.relationship),
        selectedDateOfBirth:
            nominee.dateOfBirth != null && nominee.dateOfBirth!.isNotEmpty
            ? DateTime.tryParse(nominee.dateOfBirth!)
            : null,
        isPrimary: nominee.isPrimary,
      );
    }).toList();
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
    for (final form in _nomineeForms) {
      form.dispose();
    }
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
              // Info banner about ASWAS Plus nominee
              _buildInfoBanner(),
              SizedBox(height: 24.h),

              // Section Header
              Text(
                'ASWAS Plus Nominees',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Your registered nominees for ASWAS Plus insurance benefits.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 24.h),

              // Display all nominees
              ...List.generate(_nomineeForms.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: _buildNomineeCard(index),
                );
              }),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a card for each nominee
  Widget _buildNomineeCard(int index) {
    final form = _nomineeForms[index];
    final isEditing = _editingNomineeIndex == index;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          const BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nominee header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Nominee ${index + 1}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  if (form.isPrimary) ...[
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        'Primary',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _editingNomineeIndex = isEditing ? null : index;
                  });
                },
                child: Text(
                  isEditing ? 'Close' : 'Edit',
                  style: TextStyle(fontSize: 14.sp, color: AppColors.primary),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          if (!isEditing) ...[
            // Display mode - show summary
            _buildInfoRow('Name', form.nameController.text),
            _buildInfoRow('Relationship', form.selectedRelation ?? '-'),
            _buildInfoRow('Contact', form.contactController.text),
            if (form.emailController.text.isNotEmpty)
              _buildInfoRow('Email', form.emailController.text),
          ] else ...[
            // Edit mode - show form fields
            _buildTextField(
              label: 'Nominee Name',
              controller: form.nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nominee name is required';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            _buildDropdownField(
              label: 'Relationship',
              value: form.selectedRelation,
              items: _relationOptions,
              onChanged: (value) {
                setState(() {
                  form.selectedRelation = value;
                });
              },
            ),
            SizedBox(height: 16.h),

            _buildDatePickerField(
              label: 'Date of Birth',
              selectedDate: form.selectedDateOfBirth,
              onDateSelected: (date) {
                setState(() {
                  form.selectedDateOfBirth = date;
                });
              },
            ),
            SizedBox(height: 16.h),

            _buildTextField(
              label: 'Contact Number',
              controller: form.contactController,
              keyboardType: TextInputType.phone,
              prefixText: '+91 ',
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

            _buildTextField(
              label: 'Email',
              controller: form.emailController,
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

            _buildTextField(
              label: 'Address',
              controller: form.addressController,
              maxLines: 3,
            ),
            SizedBox(height: 16.h),

            _buildTextField(
              label: 'Allocation Percentage',
              controller: form.allocationController,
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

            _buildSwitchField(
              label: 'Primary Nominee',
              value: form.isPrimary,
              onChanged: (value) {
                setState(() {
                  form.isPrimary = value;
                });
              },
            ),
            SizedBox(height: 16.h),

            // Submit Button for this nominee
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : () => _onSubmitNominee(index),
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
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.white,
                          ),
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
          ],
        ],
      ),
    );
  }

  /// Builds an info row for display mode
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
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
                  style: TextStyle(fontSize: 12.sp, color: AppColors.info),
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
    String? prefixText,
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
            prefixText: prefixText,
            prefixStyle: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textPrimary,
            ),
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
                    colorScheme: const ColorScheme.light(
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

  Future<void> _onSubmitNominee(int index) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final form = _nomineeForms[index];

    if (form.selectedRelation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select the relation with nominee'),
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
      'nominee_name': form.nameController.text.trim(),
      'relationship': form.selectedRelation!.toLowerCase(),
      'contact_number': form.contactController.text.trim(),
      'is_primary': form.isPrimary,
    };

    // Add optional fields only if they have values
    if (form.selectedDateOfBirth != null) {
      payload['date_of_birth'] =
          '${form.selectedDateOfBirth!.year}-${form.selectedDateOfBirth!.month.toString().padLeft(2, '0')}-${form.selectedDateOfBirth!.day.toString().padLeft(2, '0')}';
    }
    if (form.emailController.text.trim().isNotEmpty) {
      payload['email'] = form.emailController.text.trim();
    }
    if (form.addressController.text.trim().isNotEmpty) {
      payload['address'] = form.addressController.text.trim();
    }
    if (form.allocationController.text.trim().isNotEmpty) {
      payload['allocation_percentage'] = form.allocationController.text.trim();
    }

    // Call the PATCH API using the nominee's ID
    final result = await ref.read(
      nomineeUpdateProvider(
        NomineeUpdateParams(nomineeId: form.nominee.id, payload: payload),
      ).future,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _editingNomineeIndex = null;
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
            child: const Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

/// Helper class to manage form data for each nominee
class _NomineeFormData {
  _NomineeFormData({
    required this.nominee,
    required this.nameController,
    required this.contactController,
    required this.emailController,
    required this.addressController,
    required this.allocationController,
    this.selectedRelation,
    this.selectedDateOfBirth,
    this.isPrimary = false,
  });

  final Nominee nominee;
  final TextEditingController nameController;
  final TextEditingController contactController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final TextEditingController allocationController;
  String? selectedRelation;
  DateTime? selectedDateOfBirth;
  bool isPrimary;

  void dispose() {
    nameController.dispose();
    contactController.dispose();
    emailController.dispose();
    addressController.dispose();
    allocationController.dispose();
  }
}
