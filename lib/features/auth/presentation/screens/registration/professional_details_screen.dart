import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/auth/application/states/registration_state.dart';

import '../../../../../app/router/app_router.dart';
import '../../../application/notifiers/registration_state_notifier.dart';
import '../../../domain/entities/registration/professional_details.dart';
import '../../components/text_input_field.dart';

class ProfessionalDetailsScreen extends ConsumerStatefulWidget {
  const ProfessionalDetailsScreen({super.key});

  @override
  ConsumerState<ProfessionalDetailsScreen> createState() =>
      _ProfessionalDetailsScreenState();
}

class _ProfessionalDetailsScreenState
    extends ConsumerState<ProfessionalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _medicalCouncilNoController;
  late final TextEditingController _centralCouncilNoController;
  late final TextEditingController _ugCollegeController;

  /// HOUSE SURGEON fields
  late final TextEditingController _provisionalController;
  late final TextEditingController _districtCouncilController;
  late final TextEditingController _membershipDistrictController;
  late final TextEditingController _membershipAreaController;

  String? _selectedMedicalCouncilState;
  String? _selectedCountry;
  String? _selectedState;

  bool _isSubmitting = false;

  final Set<String> _selectedQualifications = {};
  final Set<String> _selectedCategories = {};
  String role = "";

  static const List<String> dropdownStates = [
    "Kerala",
    "Karnataka",
    "Tamil Nadu",
    "Delhi",
    "Maharashtra",
    "Other",
  ];

  static const List<String> dropdownCountry = [
    "India",
    "UAE",
    "USA",
    "UK",
    "Other",
  ];

  static const List<String> _qualificationOptions = [
    'UG',
    'PG',
    'PhD',
    'CCRAS',
    'PG Diploma',
    'Other',
  ];

  static const List<String> _categoryOptions = [
    'RESEARCHER',
    'PG SCHOLAR',
    'PVT PRACTICE',
    'MANUFACTURER',
    'PG DIPLOMA SCHOLAR',
    'DEPT OF ISM',
    'DEPT OF NAM',
    'DEPT OF NHM',
    'AIDED COLLEGE',
    'GOVT COLLEGE',
    'PVT COLLEGE',
    'PVT SECTOR SERVICE',
    'RETD',
    'MILITARY SERVICE',
    'CENTRAL GOVT',
    'ESI',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    /// Practitioner controllers
    _medicalCouncilNoController = TextEditingController();
    _centralCouncilNoController = TextEditingController();
    _ugCollegeController = TextEditingController();

    /// House surgeon controllers
    _provisionalController = TextEditingController();
    _districtCouncilController = TextEditingController();
    _membershipDistrictController = TextEditingController();
    _membershipAreaController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExistingData());
  }

  @override
  void dispose() {
    _medicalCouncilNoController.dispose();
    _centralCouncilNoController.dispose();
    _ugCollegeController.dispose();

    _provisionalController.dispose();
    _districtCouncilController.dispose();
    _membershipDistrictController.dispose();
    _membershipAreaController.dispose();

    super.dispose();
  }

  void _loadExistingData() {
    final state = ref.read(registrationProvider);

    // If RegistrationStateResumePrompt somehow still exists here,
    // it means the user bypassed the resume dialog. Start fresh instead.
    if (state is RegistrationStateResumePrompt) {
      ref.read(registrationProvider.notifier).startFreshRegistration();
      return;
    }

    if (state is! RegistrationStateInProgress) return;

    final professional = state.registration.professionalDetails;
    if (professional == null) return;

    setState(() {
      _selectedMedicalCouncilState = professional.medicalCouncilState;
      _medicalCouncilNoController.text = professional.medicalCouncilNo;
      _centralCouncilNoController.text = professional.centralCouncilNo;
      _ugCollegeController.text = professional.ugCollege;

      _provisionalController.text =
          professional.provisionalRegistrationNumber ?? '';
      _districtCouncilController.text =
          professional.councilDistrictNumber ?? '';
      _selectedCountry = professional.country;
      _selectedState = professional.state;
      _membershipDistrictController.text =
          professional.membershipDistrict ?? '';
      _membershipAreaController.text = professional.membershipArea ?? '';

      if ((professional.professionalDetails1).isNotEmpty) {
        _selectedQualifications
          ..clear()
          ..addAll(
            professional.professionalDetails1
                .split(',')
                .where((e) => e.trim().isNotEmpty),
          );
      }

      if ((professional.professionalDetails2).isNotEmpty) {
        _selectedCategories
          ..clear()
          ..addAll(
            professional.professionalDetails2
                .split(',')
                .where((e) => e.trim().isNotEmpty),
          );
      }
    });
  }

  void _saveProfessionalDetails() {
    final data = ProfessionalDetails(
      medicalCouncilState: _selectedMedicalCouncilState ?? "",
      medicalCouncilNo: _medicalCouncilNoController.text.trim(),
      centralCouncilNo: _centralCouncilNoController.text.trim(),
      ugCollege: _ugCollegeController.text.trim(),

      /// House surgeon only fields
      provisionalRegistrationNumber: _provisionalController.text.trim(),
      councilDistrictNumber: _districtCouncilController.text.trim(),
      country: _selectedCountry,
      state: _selectedState,
      membershipDistrict: _membershipDistrictController.text.trim(),
      membershipArea: _membershipAreaController.text.trim(),

      /// Practitioner only fields
      professionalDetails1: _selectedQualifications.join(','),
      professionalDetails2: _selectedCategories.join(','),
    );

    ref.read(registrationProvider.notifier).updateProfessionalDetails(data);
  }

  Future<void> _handleNext() async {
    /// Student should never see this screen, but just in case:
    if (role == "student") return;

    if (!_formKey.currentState!.validate()) return;

    /// Practitioner extra validation
    if (role == "practitioner") {
      if (_selectedQualifications.isEmpty) {
        return _showError("Select at least one qualification");
      }
      if (_selectedCategories.isEmpty) {
        return _showError("Select at least one category");
      }
    }

    setState(() => _isSubmitting = true);

    try {
      _saveProfessionalDetails();

      final state = ref.read(registrationProvider);
      if (state is! RegistrationStateInProgress ||
          state.registration.personalDetails == null ||
          state.registration.professionalDetails == null) {
        _showError("Incomplete registration data. Please go back and retry.");
        return;
      }

      final personalDetails = state.registration.personalDetails!;
      final professionalDetails = state.registration.professionalDetails!;

      Map<String, dynamic> membershipData = {
        'membership_type': personalDetails.membershipType,
        'first_name': personalDetails.firstName,
        'email': personalDetails.email,
        'password': personalDetails.password,
        'phone': personalDetails.phone,
        'wa_phone': personalDetails.waPhone,
        'date_of_birth':
            "${personalDetails.dateOfBirth.year}-${personalDetails.dateOfBirth.month.toString().padLeft(2, '0')}-${personalDetails.dateOfBirth.day.toString().padLeft(2, '0')}",
        'gender': personalDetails.gender,
        'blood_group': personalDetails.bloodGroup,
        'medical_council_state': professionalDetails.medicalCouncilState,
      };

      if (role == "practitioner") {
        membershipData.addAll({
          'medical_council_no': professionalDetails.medicalCouncilNo,
          'central_council_no': professionalDetails.centralCouncilNo,
          'ug_college': professionalDetails.ugCollege,
          'professional_details': professionalDetails.professionalDetails1,
          'academic_details': professionalDetails.professionalDetails2,
        });
      }

      if (role == "house_surgeon") {
        membershipData.addAll({
          'provisional_registration_no':
              professionalDetails.provisionalRegistrationNumber,
          'council_district_no': professionalDetails.councilDistrictNumber,
          'country': professionalDetails.country,
          'state': professionalDetails.state,
          'membership_district': professionalDetails.membershipDistrict,
          'membership_area': professionalDetails.membershipArea,
        });
      }

      final notifier = ref.read(registrationProvider.notifier);

      // Hit membership API
      final responseData = await notifier.submitMembershipRegistration(
        membershipData,
      );

      final userId = responseData['application']?['user_detail']?['id'];
      final applicationId = responseData['application']?['id'];

      if (userId == null || applicationId == null) {
        _showError(
          (responseData['error'] as String?) ??
              "Failed to create application. Please try again.",
        );
        return;
      }

      // 🔥 Save backend ids in Riverpod (single source of truth)
      notifier.updateBackendIds(applicationId: applicationId, userId: userId);

      if (!mounted) return;

      // Address screen will read userId/applicationId from provider
      Navigator.pushNamed(context, AppRouter.registrationAddress);
    } catch (e) {
      _showError("Registration failed: $e");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));

  @override
  Widget build(BuildContext context) {
    final regState = ref.watch(registrationProvider);

    if (regState is RegistrationStateInProgress) {
      role = regState.registration.personalDetails?.membershipType ?? "";
    }

    /// Skip screen for students
    if (role == "student") {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Register Here",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 10.h),
              Text(
                "Step 2 of 4",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
              ),
              SizedBox(height: 20.h),
              Text(
                "Professional Details",
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 25.h),

              if (role == "practitioner") _buildPractitionerUI(),
              if (role == "house_surgeon") _buildHouseSurgeonUI(),

              SizedBox(height: 30.h),
              _nextButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHouseSurgeonUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Medical Council State"),
        _dropdown(dropdownStates, (v) => _selectedMedicalCouncilState = v),

        SizedBox(height: 18.h),
        _label("Provisional Registration Number"),
        TextInputField(controller: _provisionalController),

        SizedBox(height: 18.h),
        _label("Council District Number"),
        TextInputField(controller: _districtCouncilController),

        SizedBox(height: 18.h),
        _label("Country"),
        _dropdown(dropdownCountry, (v) => _selectedCountry = v),

        SizedBox(height: 18.h),
        _label("State"),
        _dropdown(dropdownStates, (v) => _selectedState = v),

        SizedBox(height: 18.h),
        _label("Membership District"),
        TextInputField(controller: _membershipDistrictController),

        SizedBox(height: 18.h),
        _label("Membership Area"),
        TextInputField(controller: _membershipAreaController),
      ],
    );
  }

  Widget _buildPractitionerUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Medical Council State"),
        _dropdown(dropdownStates, (v) => _selectedMedicalCouncilState = v),

        SizedBox(height: 18.h),
        _label("Medical Council Number"),
        TextInputField(controller: _medicalCouncilNoController),

        SizedBox(height: 18.h),
        _label("Central Council Number"),
        TextInputField(controller: _centralCouncilNoController),

        SizedBox(height: 18.h),
        _label("UG College"),
        TextInputField(controller: _ugCollegeController),

        SizedBox(height: 22.h),
        Text(
          "Qualifications",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
        ),
        Wrap(
          spacing: 8,
          children: _qualificationOptions.map((e) {
            final selected = _selectedQualifications.contains(e);
            return FilterChip(
              selected: selected,
              label: Text(e),
              onSelected: (_) => setState(
                () => selected
                    ? _selectedQualifications.remove(e)
                    : _selectedQualifications.add(e),
              ),
            );
          }).toList(),
        ),

        SizedBox(height: 22.h),
        Text(
          "Professional Category",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categoryOptions.map((e) {
            final selected = _selectedCategories.contains(e);
            return FilterChip(
              selected: selected,
              label: Text(e),
              onSelected: (_) => setState(
                () => selected
                    ? _selectedCategories.remove(e)
                    : _selectedCategories.add(e),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _label(String text) => Text(
    text,
    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
  );

  Widget _dropdown(List<String> data, Function(String?) callback) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField(
        decoration: const InputDecoration(border: InputBorder.none),
        items: data
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        validator: (v) => v == null ? "Required" : null,
        onChanged: callback,
      ),
    );
  }

  Widget _nextButton() {
    return SizedBox(
      height: 50.h,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _handleNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brown,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Next", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
