import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/home/application/providers/home_providers.dart';
import 'package:myapp/features/profile/application/providers/profile_providers.dart';

/// Edit Professional Details Screen (Practitioner, House Surgeon)
/// Allows users to edit their professional details and medical council registration
class EditProfessionalDetailsScreen extends ConsumerStatefulWidget {
  const EditProfessionalDetailsScreen({super.key});

  @override
  ConsumerState<EditProfessionalDetailsScreen> createState() =>
      _EditProfessionalDetailsScreenState();
}

class _EditProfessionalDetailsScreenState
    extends ConsumerState<EditProfessionalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Professional Types checkboxes
  bool _researcherSelected = false;
  bool _pgScholarSelected = false;
  bool _pgDiplomaScholarSelected = false;
  bool _deptOfIsmSelected = false;
  bool _deptOfNamSelected = false;
  bool _deptOfNhmSelected = false;
  bool _aidedCollegeSelected = false;
  bool _govtCollegeSelected = false;
  bool _pvtCollegeSelected = false;
  bool _pvtSectorCollegeSelected = false;
  bool _retdSelected = false;
  bool _pvtPracticeSelected = false;
  bool _manufacturerSelected = false;
  bool _militaryServiceSelected = false;
  bool _centralGovtSelected = false;
  bool _esiSelected = false;
  bool _otherSelected = false;

  // Medical Council Fields
  late TextEditingController _medicalCouncilNoController;
  late TextEditingController _centralCouncilNoController;
  late TextEditingController _ugCollegeController;
  String? _selectedMedicalCouncilState;
  bool _isSubmitting = false;
  bool _hasPendingRequest = false;

  // State options for Medical Council
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
    _medicalCouncilNoController = TextEditingController();
    _centralCouncilNoController = TextEditingController();
    _ugCollegeController = TextEditingController();
    // Pre-fill checkboxes from membership data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillProfessionalDetails();
    });
  }

  /// Pre-fills checkboxes and input fields based on membership API data
  void _prefillProfessionalDetails() {
    final membershipState = ref.read(membershipStateProvider);
    final membershipData = membershipState.currentData;
    final professionalDetails = membershipData?.professionalDetails;

    if (professionalDetails != null && professionalDetails.isNotEmpty) {
      // Convert to uppercase for case-insensitive comparison
      final upperCaseDetails = professionalDetails
          .map((e) => e.toUpperCase())
          .toList();
      setState(() {
        _researcherSelected = upperCaseDetails.contains('RESEARCHER');
        _pgScholarSelected = upperCaseDetails.contains('PG SCHOLAR');
        _pgDiplomaScholarSelected = upperCaseDetails.contains(
          'PG DIPLOMA SCHOLAR',
        );
        _deptOfIsmSelected = upperCaseDetails.contains('DEPT OF ISM');
        _deptOfNamSelected = upperCaseDetails.contains('DEPT OF NAM');
        _deptOfNhmSelected = upperCaseDetails.contains('DEPT OF NHM');
        _aidedCollegeSelected = upperCaseDetails.contains('AIDED COLLEGE');
        _govtCollegeSelected = upperCaseDetails.contains('GOVT COLLEGE');
        _pvtCollegeSelected = upperCaseDetails.contains('PVT COLLEGE');
        _pvtSectorCollegeSelected = upperCaseDetails.contains(
          'PVT SECTOR COLLEGE',
        );
        _retdSelected = upperCaseDetails.contains('RETIRED (RETD)');
        _pvtPracticeSelected = upperCaseDetails.contains('PRIVATE PRACTICE');
        _manufacturerSelected = upperCaseDetails.contains('MANUFACTURER');
        _militaryServiceSelected = upperCaseDetails.contains(
          'MILITARY SERVICE',
        );
        _centralGovtSelected = upperCaseDetails.contains('CENTRAL GOVT');
        _esiSelected = upperCaseDetails.contains('ESI');
        _otherSelected = upperCaseDetails.contains('OTHER');
      });
    }

    // Pre-fill medical council input fields
    if (membershipData != null) {
      setState(() {
        if (membershipData.medicalCouncilState != null &&
            _stateOptions.contains(membershipData.medicalCouncilState)) {
          _selectedMedicalCouncilState = membershipData.medicalCouncilState;
        }
      });
      if (membershipData.medicalCouncilNo != null) {
        _medicalCouncilNoController.text = membershipData.medicalCouncilNo!;
      }
      if (membershipData.centralCouncilNo != null) {
        _centralCouncilNoController.text = membershipData.centralCouncilNo!;
      }
      if (membershipData.ugCollege != null) {
        _ugCollegeController.text = membershipData.ugCollege!;
      }
    }
  }

  @override
  void dispose() {
    _medicalCouncilNoController.dispose();
    _centralCouncilNoController.dispose();
    _ugCollegeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Professional Details',
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

              // Section 1: Professional Types
              _buildSectionHeader('Professional Category'),
              SizedBox(height: 8.h),
              Text(
                'Select all that apply',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 16.h),

              // Professional Types Card
              _buildProfessionalTypesCard(),

              SizedBox(height: 24.h),

              // Section 2: Medical Council Registration Details
              _buildSectionHeader('Medical Council Registration'),
              SizedBox(height: 16.h),

              // Medical Council Card
              _buildMedicalCouncilCard(),

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
              'Changes to your professional details require admin approval and may take some time to reflect.',
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

  Widget _buildProfessionalTypesCard() {
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
        children: [
          _buildCompactCheckboxItem('Researcher', _researcherSelected, (v) {
            setState(() => _researcherSelected = v ?? false);
          }),
          _buildCompactCheckboxItem('PG Scholar', _pgScholarSelected, (v) {
            setState(() => _pgScholarSelected = v ?? false);
          }),
          _buildCompactCheckboxItem(
            'PG Diploma Scholar',
            _pgDiplomaScholarSelected,
            (v) {
              setState(() => _pgDiplomaScholarSelected = v ?? false);
            },
          ),
          _buildCompactCheckboxItem('Dept of ISM', _deptOfIsmSelected, (v) {
            setState(() => _deptOfIsmSelected = v ?? false);
          }),
          _buildCompactCheckboxItem('Dept of NAM', _deptOfNamSelected, (v) {
            setState(() => _deptOfNamSelected = v ?? false);
          }),
          _buildCompactCheckboxItem('Dept of NHM', _deptOfNhmSelected, (v) {
            setState(() => _deptOfNhmSelected = v ?? false);
          }),
          _buildCompactCheckboxItem('Aided College', _aidedCollegeSelected, (
            v,
          ) {
            setState(() => _aidedCollegeSelected = v ?? false);
          }),
          _buildCompactCheckboxItem('Govt College', _govtCollegeSelected, (v) {
            setState(() => _govtCollegeSelected = v ?? false);
          }),
          _buildCompactCheckboxItem('PVT College', _pvtCollegeSelected, (v) {
            setState(() => _pvtCollegeSelected = v ?? false);
          }),
          _buildCompactCheckboxItem(
            'PVT Sector College',
            _pvtSectorCollegeSelected,
            (v) {
              setState(() => _pvtSectorCollegeSelected = v ?? false);
            },
          ),
          _buildCompactCheckboxItem('Retired (RETD)', _retdSelected, (v) {
            setState(() => _retdSelected = v ?? false);
          }),
          _buildCompactCheckboxItem('Private Practice', _pvtPracticeSelected, (
            v,
          ) {
            setState(() => _pvtPracticeSelected = v ?? false);
          }),
          _buildCompactCheckboxItem('Manufacturer', _manufacturerSelected, (v) {
            setState(() => _manufacturerSelected = v ?? false);
          }),
          _buildCompactCheckboxItem(
            'Military Service',
            _militaryServiceSelected,
            (v) {
              setState(() => _militaryServiceSelected = v ?? false);
            },
          ),
          _buildCompactCheckboxItem('Central Govt', _centralGovtSelected, (v) {
            setState(() => _centralGovtSelected = v ?? false);
          }),
          _buildCompactCheckboxItem('ESI', _esiSelected, (v) {
            setState(() => _esiSelected = v ?? false);
          }),
          _buildCompactCheckboxItem('Other', _otherSelected, (v) {
            setState(() => _otherSelected = v ?? false);
          }, isLast: true),
        ],
      ),
    );
  }

  Widget _buildCompactCheckboxItem(
    String label,
    bool value,
    void Function(bool?) onChanged, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () => onChanged(!value),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
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
          ),
        ),
        if (!isLast) const Divider(color: AppColors.dividerLight, height: 1),
      ],
    );
  }

  Widget _buildMedicalCouncilCard() {
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
          // Medical Council State Dropdown
          _buildDropdownField(
            label: 'Medical Council State',
            value: _selectedMedicalCouncilState,
            items: _stateOptions,
            onChanged: (value) {
              setState(() {
                _selectedMedicalCouncilState = value;
              });
            },
          ),
          SizedBox(height: 16.h),

          // Medical Council Number
          _buildTextField(
            label: 'Medical Council Number',
            controller: _medicalCouncilNoController,
          ),
          SizedBox(height: 16.h),

          // Central Council Number
          _buildTextField(
            label: 'Central Council Number',
            controller: _centralCouncilNoController,
          ),
          SizedBox(height: 16.h),

          // UG College
          _buildTextField(
            label: 'UG College',
            controller: _ugCollegeController,
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
            fillColor: AppColors.grey50,
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

  Future<void> _onSubmit() async {
    setState(() {
      _isSubmitting = true;
    });

    // Build the list of selected professional categories
    final selectedProfessionalDetails = <String>[];
    if (_researcherSelected) selectedProfessionalDetails.add('Researcher');
    if (_pgScholarSelected) selectedProfessionalDetails.add('PG Scholar');
    if (_pgDiplomaScholarSelected)
      selectedProfessionalDetails.add('PG Diploma Scholar');
    if (_deptOfIsmSelected) selectedProfessionalDetails.add('Dept of ISM');
    if (_deptOfNamSelected) selectedProfessionalDetails.add('Dept of NAM');
    if (_deptOfNhmSelected) selectedProfessionalDetails.add('Dept of NHM');
    if (_aidedCollegeSelected) selectedProfessionalDetails.add('Aided College');
    if (_govtCollegeSelected) selectedProfessionalDetails.add('Govt College');
    if (_pvtCollegeSelected) selectedProfessionalDetails.add('PVT College');
    if (_pvtSectorCollegeSelected)
      selectedProfessionalDetails.add('PVT Sector College');
    if (_retdSelected) selectedProfessionalDetails.add('Retired (RETD)');
    if (_pvtPracticeSelected)
      selectedProfessionalDetails.add('Private Practice');
    if (_manufacturerSelected) selectedProfessionalDetails.add('Manufacturer');
    if (_militaryServiceSelected)
      selectedProfessionalDetails.add('Military Service');
    if (_centralGovtSelected) selectedProfessionalDetails.add('Central Govt');
    if (_esiSelected) selectedProfessionalDetails.add('ESI');
    if (_otherSelected) selectedProfessionalDetails.add('Other');

    // Build the data map for API
    final data = <String, dynamic>{
      'professional_details': selectedProfessionalDetails,
    };

    // Add medical council fields if provided
    if (_selectedMedicalCouncilState != null) {
      data['medical_council_state'] = _selectedMedicalCouncilState;
    }
    if (_medicalCouncilNoController.text.trim().isNotEmpty) {
      data['medical_council_no'] = _medicalCouncilNoController.text.trim();
    }
    if (_centralCouncilNoController.text.trim().isNotEmpty) {
      data['central_council_no'] = _centralCouncilNoController.text.trim();
    }
    if (_ugCollegeController.text.trim().isNotEmpty) {
      data['ug_college'] = _ugCollegeController.text.trim();
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
          'Your professional details update request has been submitted successfully. Changes will be reflected after admin approval.',
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
