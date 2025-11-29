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

  String? _selectedMedicalCouncilState;
  bool _isSubmitting = false;

  final Set<String> _selectedQualifications = {};
  final Set<String> _selectedCategories = {};

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
    _medicalCouncilNoController = TextEditingController();
    _centralCouncilNoController = TextEditingController();
    _ugCollegeController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExistingData());
  }

  @override
  void dispose() {
    _medicalCouncilNoController.dispose();
    _centralCouncilNoController.dispose();
    _ugCollegeController.dispose();
    super.dispose();
  }

  void _loadExistingData() {
    final state = ref.read(registrationProvider);

    if (state is RegistrationStateResumePrompt) {
      ref
          .read(registrationProvider.notifier)
          .resumeRegistration(state.existingRegistration);
      Future.microtask(() => _loadExistingData());
      return;
    }

    if (state is! RegistrationStateInProgress) return;

    final data = state.registration.professionalDetails;
    if (data == null) return;

    setState(() {
      _selectedMedicalCouncilState = data.medicalCouncilState;
      _selectedQualifications.addAll(data.professionalDetails1.split(','));
      _selectedCategories.addAll(data.professionalDetails2.split(','));
    });

    _medicalCouncilNoController.text = data.medicalCouncilNo;
    _centralCouncilNoController.text = data.centralCouncilNo;
    _ugCollegeController.text = data.ugCollege;
  }

  void _saveProfessionalDetails() {
    final data = ProfessionalDetails(
      medicalCouncilState: _selectedMedicalCouncilState ?? "",
      medicalCouncilNo: _medicalCouncilNoController.text.trim(),
      centralCouncilNo: _centralCouncilNoController.text.trim(),
      ugCollege: _ugCollegeController.text.trim(),
      professionalDetails1: _selectedQualifications.join(','),
      professionalDetails2: _selectedCategories.join(','),
    );

    ref.read(registrationProvider.notifier).updateProfessionalDetails(data);
  }

  /// ------------------------ HANDLE NEXT (API FLOW) ------------------------
  Future<void> _handleNext() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedQualifications.isEmpty) {
      _showError("Please select at least one qualification");
      return;
    }

    if (_selectedCategories.isEmpty) {
      _showError("Please select at least one professional category");
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      _saveProfessionalDetails();

      final state = ref.read(registrationProvider);
      if (state is! RegistrationStateInProgress) {
        throw Exception("Registration not in progress");
      }

      final personalDetails = state.registration.personalDetails;
      final professionalDetails = state.registration.professionalDetails;

      if (personalDetails == null) {
        throw Exception("Personal details missing");
      }
      if (professionalDetails == null) {
        throw Exception("Professional details not saved");
      }

      final membershipData = {
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
        'medical_council_no': professionalDetails.medicalCouncilNo,
        'central_council_no': professionalDetails.centralCouncilNo,
        'ug_college': professionalDetails.ugCollege,

        'professional_details1': professionalDetails.professionalDetails1,
        'professional_details2': professionalDetails.professionalDetails2,
      };

      await ref
          .read(registrationProvider.notifier)
          .submitMembershipRegistration(membershipData);

      await ref.read(registrationProvider.notifier).autoSaveProgress();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration saved. Continue with address details."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushNamed(context, AppRouter.registrationAddress);
    } catch (e) {
      if (mounted) _showError("Registration failed: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// ------------------------ UI SECTION ------------------------

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Register Here",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 10.h),
              Center(
                child: Text(
                  "Step 2 of 4",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: 20.h),
              Text(
                "Professional Details",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 25.h),
              _label("Medical Council State"),
              _dropdown(),

              SizedBox(height: 18.h),
              _label("Medical Council Number"),
              TextInputField(
                controller: _medicalCouncilNoController,
                hintText: "Enter Council No.",
              ),

              SizedBox(height: 18.h),
              _label("Central Council Number"),
              TextInputField(
                controller: _centralCouncilNoController,
                hintText: "Enter Central Council No.",
              ),

              SizedBox(height: 18.h),
              _label("UG College"),
              TextInputField(
                controller: _ugCollegeController,
                hintText: "Enter UG College",
              ),

              SizedBox(height: 24.h),
              _buildQualificationGrid(),

              SizedBox(height: 24.h),
              _checkboxGroup(
                "Professional Category",
                _categoryOptions,
                _selectedCategories,
              ),

              SizedBox(height: 40.h),
              _nextButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
  );

  Widget _dropdown() {
    final list = [
      "Kerala",
      "Karnataka",
      "Tamil Nadu",
      "Delhi",
      "Maharashtra",
      "Other",
    ];

    if (_selectedMedicalCouncilState != null &&
        !list.contains(_selectedMedicalCouncilState)) {
      _selectedMedicalCouncilState = null;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField(
        value: _selectedMedicalCouncilState,
        decoration: const InputDecoration(border: InputBorder.none),
        items: list
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (val) => setState(() => _selectedMedicalCouncilState = val),
        validator: (v) => v == null ? "Required" : null,
      ),
    );
  }

  Widget _buildQualificationGrid() {
    final twoColumnItems = ["UG", "PG", "PhD", "CCRAS"];
    final fullWidthItems = ["PG Diploma", "Other"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Qualifications",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12.h),

        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 4,
                padding: EdgeInsets.zero,
                children: twoColumnItems.map((item) {
                  return _checkboxTile(item, _selectedQualifications);
                }).toList(),
              ),

              SizedBox(height: 6.h),
              ...fullWidthItems.map(
                (e) => Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: _checkboxTile(e, _selectedQualifications),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _checkboxTile(String text, Set<String> collection) {
    final selected = collection.contains(text);

    return InkWell(
      onTap: () => setState(
        () => selected ? collection.remove(text) : collection.add(text),
      ),
      child: Row(
        children: [
          Checkbox(
            visualDensity: VisualDensity.compact,
            value: selected,
            activeColor: AppColors.brown,
            onChanged: (_) => setState(
              () => selected ? collection.remove(text) : collection.add(text),
            ),
          ),
          Flexible(
            child: Text(text, style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }

  Widget _checkboxGroup(String title, List<String> list, Set<String> store) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12.h),

        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: list.map((e) => _checkboxTile(e, store)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _nextButton() {
    return SizedBox(
      height: 50.h,
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
            : Text(
                "Next",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
