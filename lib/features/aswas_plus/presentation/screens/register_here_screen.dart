import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/aswas_plus/application/providers/registration_providers.dart';
import 'package:myapp/features/aswas_plus/infrastructure/models/registration_response_model.dart';
import 'package:myapp/features/aswas_plus/presentation/screens/registration_payment_screen.dart';
import 'package:myapp/features/home/application/providers/home_providers.dart';
import 'package:myapp/features/profile/application/providers/profile_providers.dart';

/// Register Here Screen for ASWAS Plus registration
/// Allows non-enrolled users to register for insurance policy
class RegisterHereScreen extends ConsumerStatefulWidget {
  const RegisterHereScreen({super.key});

  @override
  ConsumerState<RegisterHereScreen> createState() => _RegisterHereScreenState();
}

class _RegisterHereScreenState extends ConsumerState<RegisterHereScreen> {
  final _formKey = GlobalKey<FormState>();

  // Personal Details Controllers
  late TextEditingController _nameController;
  late TextEditingController _parentNameController;
  String? _selectedMaritalStatus;
  DateTime? _selectedDateOfBirth;

  // Document upload
  String? _ageProofDocumentPath;
  String? _ageProofDocumentName;

  // Nominees list
  List<NomineeFormData> _nominees = [];

  // Dropdown options
  final List<String> _maritalStatusOptions = [
    'Single',
    'Married',
    'Divorced',
    'Widowed',
  ];

  final List<String> _relationshipOptions = [
    'Spouse',
    'Child',
    'Parent',
    'Sibling',
    'Other',
  ];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _parentNameController = TextEditingController();
    // Add one empty nominee by default
    _nominees.add(NomineeFormData());
    // Auto-fill from profile data
    _prefillFromProfile();
  }

  /// Pre-fill form fields from user profile data
  void _prefillFromProfile() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileState = ref.read(profileStateProvider);
      final userProfile = profileState.currentData?.userProfile;

      if (userProfile != null) {
        setState(() {
          // Pre-fill name
          _nameController.text = userProfile.firstName;

          // Pre-fill parent name if available
          if (userProfile.parentName != null) {
            _parentNameController.text = userProfile.parentName!;
          }

          // Pre-fill date of birth if available
          _selectedDateOfBirth = userProfile.dateOfBirth;

          // Pre-fill marital status if available
          if (userProfile.maritalStatus != null) {
            _selectedMaritalStatus = _mapMaritalStatus(
              userProfile.maritalStatus,
            );
          }
        });
      }
    });
  }

  /// Maps marital status from API format to dropdown format
  String? _mapMaritalStatus(String? status) {
    if (status == null || status.isEmpty) return null;
    // Capitalize first letter to match dropdown options
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _parentNameController.dispose();
    for (final nominee in _nominees) {
      nominee.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Register here',
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
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20.sp,
          ),
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
              // Personal Details Section
              _buildSectionHeading('Personal Details'),
              SizedBox(height: 16.h),
              _buildPersonalDetailsSection(),

              SizedBox(height: 24.h),

              // Nominee Details Section
              _buildSectionHeading('Nominee Details'),
              SizedBox(height: 16.h),
              _buildNomineesSection(),

              SizedBox(height: 24.h),

              // Age Proof Certificate Section
              _buildSectionHeading('Age Proof Certificate'),
              SizedBox(height: 16.h),
              _buildDocumentUploadSection(),

              SizedBox(height: 32.h),

              // Submit Button
              _buildSubmitButton(),

              SizedBox(height: 24.h),
            ],
          ),
        ),
          ),
        ),
      ),
    );
  }

  /// Builds section heading
  Widget _buildSectionHeading(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// Builds personal details section
  Widget _buildPersonalDetailsSection() {
    return Container(
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
          // Name Field
          _buildTextField(
            label: 'Name',
            controller: _nameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Name is required';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),

          // Parent Name Field
          _buildTextField(
            label: 'Parent Name',
            controller: _parentNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Parent name is required';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),

          // Date of Birth Field
          _buildDatePickerField(
            label: 'Date of Birth',
            value: _selectedDateOfBirth,
            onTap: _selectDateOfBirth,
          ),
          SizedBox(height: 16.h),

          // Marital Status Dropdown
          _buildDropdownField(
            label: 'Marital Status',
            value: _selectedMaritalStatus,
            items: _maritalStatusOptions,
            onChanged: (value) {
              setState(() {
                _selectedMaritalStatus = value;
              });
            },
          ),
        ],
      ),
    );
  }

  /// Builds nominees section with add/remove functionality
  Widget _buildNomineesSection() {
    return Column(
      children: [
        // List of nominee forms
        ...List.generate(_nominees.length, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: _buildNomineeCard(index),
          );
        }),

        // Add/Remove buttons row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add button
            InkWell(
              onTap: _addNominee,
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Add Nominee',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_nominees.length > 1) ...[
              SizedBox(width: 16.w),
              // Remove button
              InkWell(
                onTap: _removeLastNominee,
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.remove_circle_outline,
                        color: AppColors.error,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Remove',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// Builds a single nominee card
  Widget _buildNomineeCard(int index) {
    final nominee = _nominees[index];
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nominee header with number
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nominee ${index + 1}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              if (_nominees.length > 1)
                InkWell(
                  onTap: () => _removeNomineeAt(index),
                  child: Icon(Icons.close, color: AppColors.error, size: 20.sp),
                ),
            ],
          ),
          SizedBox(height: 16.h),

          // Nominee Name
          _buildTextField(
            label: 'Nominee Name',
            controller: nominee.nameController,
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
            label: 'Relation',
            value: nominee.selectedRelation,
            items: _relationshipOptions,
            onChanged: (value) {
              setState(() {
                nominee.selectedRelation = value;
              });
            },
          ),
          SizedBox(height: 16.h),

          // Nominee Address
          _buildTextField(
            label: 'Nominee Address',
            controller: nominee.addressController,
            maxLines: 2,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Address is required';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),

          // Nominee Mobile Number
          _buildTextField(
            label: 'Nominee Mobile Number',
            controller: nominee.mobileController,
            keyboardType: TextInputType.phone,
            prefixText: '+91 ',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Mobile number is required';
              }
              if (value.length < 10) {
                return 'Please enter a valid mobile number';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),

          // Nominee Email
          _buildTextField(
            label: 'Nominee Email',
            controller: nominee.emailController,
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

          // Nominee Date of Birth
          _buildNomineeDatePickerField(
            label: 'Nominee Date of Birth',
            value: nominee.dateOfBirth,
            onTap: () => _selectNomineeDateOfBirth(index),
          ),
        ],
      ),
    );
  }

  /// Builds document upload section
  Widget _buildDocumentUploadSection() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Document',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          InkWell(
            onTap: _pickDocument,
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 24.h),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.grey300,
                  width: 1.w,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(8.r),
                color: AppColors.grey100,
              ),
              child: Column(
                children: [
                  Icon(
                    _ageProofDocumentName != null
                        ? Icons.description
                        : Icons.cloud_upload_outlined,
                    color: AppColors.primary,
                    size: 32.sp,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _ageProofDocumentName ?? 'Tap to upload document',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: _ageProofDocumentName != null
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_ageProofDocumentName != null) ...[
                    SizedBox(height: 8.h),
                    Text(
                      'Tap to change',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Supported formats: PDF, JPG, PNG',
            style: TextStyle(fontSize: 12.sp, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  /// Builds submit button
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
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
                'Submit Registration',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
      ),
    );
  }

  /// Builds a text field
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
            fillColor: AppColors.white,
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

  /// Builds a date picker field
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

  /// Builds a dropdown field
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

  /// Adds a new nominee
  void _addNominee() {
    setState(() {
      _nominees.add(NomineeFormData());
    });
  }

  /// Removes the last nominee
  void _removeLastNominee() {
    if (_nominees.length > 1) {
      setState(() {
        final removed = _nominees.removeLast();
        removed.dispose();
      });
    }
  }

  /// Removes nominee at specific index
  void _removeNomineeAt(int index) {
    if (_nominees.length > 1) {
      setState(() {
        final removed = _nominees.removeAt(index);
        removed.dispose();
      });
    }
  }

  /// Selects date of birth
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

  /// Selects nominee date of birth
  Future<void> _selectNomineeDateOfBirth(int index) async {
    final nominee = _nominees[index];
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: nominee.dateOfBirth ?? DateTime(1990),
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
    if (picked != null && picked != nominee.dateOfBirth) {
      setState(() {
        nominee.dateOfBirth = picked;
      });
    }
  }

  /// Builds a date picker field for nominee
  Widget _buildNomineeDatePickerField({
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

  /// Picks document for upload
  void _pickDocument() {
    // Static for now - will integrate with file_picker package later
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document upload coming soon')),
    );
  }

  /// Handles form submission
  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate marital status
    if (_selectedMaritalStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select marital status'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validate date of birth
    if (_selectedDateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date of birth'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validate nominees have relation selected
    for (int i = 0; i < _nominees.length; i++) {
      if (_nominees[i].selectedRelation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select relation for Nominee ${i + 1}'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    // Validate nominees have date of birth selected
    for (int i = 0; i < _nominees.length; i++) {
      if (_nominees[i].dateOfBirth == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select date of birth for Nominee ${i + 1}'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    // Build the request payload
    final userId = ref.read(userIdProvider);
    final nomineesData = _nominees.map((nominee) {
      return {
        'nominee_name': nominee.nameController.text.trim(),
        'relationship': nominee.selectedRelation!.toLowerCase(),
        'date_of_birth': nominee.dateOfBirth != null
            ? DateFormat('yyyy-MM-dd').format(nominee.dateOfBirth!)
            : null,
        'contact_number': nominee.mobileController.text.trim(),
        'email': nominee.emailController.text.trim(),
        'address': nominee.addressController.text.trim(),
        'allocation_percentage': 100 ~/ _nominees.length,
        'is_primary': _nominees.indexOf(nominee) == 0,
      };
    }).toList();

    final payload = {
      'user': userId,
      'date_of_birth': DateFormat('yyyy-MM-dd').format(_selectedDateOfBirth!),
      'nominees': nomineesData,
    };

    // Call API
    final result = await ref.read(
      insuranceRegistrationProvider(payload).future,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (registrationResponse) {
        // Navigate to payment screen
        _navigateToPayment(registrationResponse);
      },
    );
  }

  /// Navigates to payment screen with registration response
  void _navigateToPayment(RegistrationResponseModel registrationResponse) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => RegistrationPaymentScreen(
          registrationResponse: registrationResponse,
        ),
      ),
    );
  }
}

/// Helper class to manage nominee form data
class NomineeFormData {
  NomineeFormData()
    : nameController = TextEditingController(),
      addressController = TextEditingController(),
      mobileController = TextEditingController(),
      emailController = TextEditingController();

  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController mobileController;
  final TextEditingController emailController;
  String? selectedRelation;
  DateTime? dateOfBirth;

  void dispose() {
    nameController.dispose();
    addressController.dispose();
    mobileController.dispose();
    emailController.dispose();
  }
}
