import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Professional Details',
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
        children: [
          Icon(Icons.info_outline, color: AppColors.info, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Changes to your professional details require admin approval and may take some time to reflect.',
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

  Widget _buildProfessionalTypesCard() {
    return Container(
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
          _buildCompactCheckboxItem('Researcher', _researcherSelected, (v) {
            setState(() => _researcherSelected = v ?? false);
          }),
          _buildCompactCheckboxItem('PG Scholar', _pgScholarSelected, (v) {
            setState(() => _pgScholarSelected = v ?? false);
          }),
          _buildCompactCheckboxItem('PG Diploma Scholar', _pgDiplomaScholarSelected, (v) {
            setState(() => _pgDiplomaScholarSelected = v ?? false);
          }),
          _buildCompactCheckboxItem('Dept of ISM', _deptOfIsmSelected, (v) {
            setState(() => _deptOfIsmSelected = v ?? false);
          }),
          _buildCompactCheckboxItem('Dept of NAM', _deptOfNamSelected, (v) {
            setState(() => _deptOfNamSelected = v ?? false);
          }),
          _buildCompactCheckboxItem('Dept of NHM', _deptOfNhmSelected, (v) {
            setState(() => _deptOfNhmSelected = v ?? false);
          }),
          _buildCompactCheckboxItem('Aided College', _aidedCollegeSelected, (v) {
            setState(() => _aidedCollegeSelected = v ?? false);
          }),
          _buildCompactCheckboxItem('Govt College', _govtCollegeSelected, (v) {
            setState(() => _govtCollegeSelected = v ?? false);
          }),
          _buildCompactCheckboxItem('PVT College', _pvtCollegeSelected, (v) {
            setState(() => _pvtCollegeSelected = v ?? false);
          }),
          _buildCompactCheckboxItem('PVT Sector College', _pvtSectorCollegeSelected, (v) {
            setState(() => _pvtSectorCollegeSelected = v ?? false);
          }),
          _buildCompactCheckboxItem('Retired (RETD)', _retdSelected, (v) {
            setState(() => _retdSelected = v ?? false);
          }),
          _buildCompactCheckboxItem('Private Practice', _pvtPracticeSelected, (v) {
            setState(() => _pvtPracticeSelected = v ?? false);
          }),
          _buildCompactCheckboxItem('Manufacturer', _manufacturerSelected, (v) {
            setState(() => _manufacturerSelected = v ?? false);
          }),
          _buildCompactCheckboxItem('Military Service', _militaryServiceSelected, (v) {
            setState(() => _militaryServiceSelected = v ?? false);
          }),
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
        if (!isLast)
          Divider(
            color: AppColors.dividerLight,
            height: 1,
          ),
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

  Future<void> _onSubmit() async {
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
          'Your professional details update request has been submitted successfully. Changes will be reflected after admin approval.',
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
