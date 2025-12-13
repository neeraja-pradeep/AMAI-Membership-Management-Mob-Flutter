import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/auth/application/states/registration_state.dart';
import 'package:myapp/features/auth/domain/entities/registration/registration_error.dart';
import 'package:myapp/features/auth/domain/entities/registration/membership_zone.dart';
import 'package:myapp/core/network/api_client.dart';
import 'package:myapp/features/auth/infrastructure/data_sources/remote/registration_api.dart';

import '../../../../../app/router/app_router.dart';
import '../../../application/notifiers/registration_state_notifier.dart';
import '../../../domain/entities/registration/professional_details.dart';
import '../../components/registration_step_indicator.dart';

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
  String? _selectedMembershipDistrict;
  String? _selectedMembershipArea;

  bool _isSubmitting = false;
  bool _isLoadingStates = false;

  final Set<String> _selectedQualifications = {};
  final Set<String> _selectedCategories = {};
  String role = "";

  // Dynamic states list loaded from API
  List<String> _medicalCouncilStates = [];
  List<String> _membershipStates = [];

  static const List<String> dropdownStates = [
    "Andhra Pradesh",
    "Arunachal Pradesh",
    "Assam",
    "Bihar",
    "Chhattisgarh",
    "Goa",
    "Gujarat",
    "Haryana",
    "Himachal Pradesh",
    "Jharkhand",
    "Karnataka",
    "Kerala",
    "Madhya Pradesh",
    "Maharashtra",
    "Manipur",
    "Meghalaya",
    "Mizoram",
    "Nagaland",
    "Odisha",
    "Punjab",
    "Rajasthan",
    "Sikkim",
    "Tamil Nadu",
    "Telangana",
    "Tripura",
    "Uttar Pradesh",
    "Uttarakhand",
    "West Bengal",
    "Andaman and Nicobar Islands",
    "Chandigarh",
    "Dadra and Nagar Haveli and Daman and Diu",
    "Delhi",
    "Jammu and Kashmir",
    "Ladakh",
    "Lakshadweep",
    "Puducherry",
    "Other",
  ];

  static const List<String> dropdownCountry = ["India"];

  // Sample districts - UI placeholder
  static const List<String> dropdownDistricts = ["Select District"];

  // Sample areas - UI placeholder
  static const List<String> dropdownAreas = ["Select Area"];

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
    'PG DIPLOMA SCHOLAR',
    'DEPT OF ISM',
    'DEPT OF NAM',
    'DEPT OF NHM',
    'AIDED COLLEGE',
    'GOVT COLLEGE',
    'PVT COLLEGE',
    'PVT SECTOR SERVICE',
    'RETD',
    'PVT PRACTICE',
    'MANUFACTURER',
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
      _loadMembershipZones();
    });
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

  /// Load membership zones (states) from API with pagination
  Future<void> _loadMembershipZones() async {
    if (_isLoadingStates) return;

    setState(() {
      _isLoadingStates = true;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final registrationApi = RegistrationApi(apiClient: apiClient);

      final List<MembershipZone> allZones = [];
      int? currentPage = 1;
      String? nextUrl;

      // Fetch all pages
      do {
        final response = await registrationApi.fetchMembershipZones(
          parent: 2, // India
          page: currentPage,
        );

        final zonesResponse = MembershipZonesResponse.fromJson(response);
        allZones.addAll(zonesResponse.results);

        nextUrl = zonesResponse.next;
        if (nextUrl != null) {
          currentPage = (currentPage ?? 1) + 1;
        }
      } while (nextUrl != null);

      if (mounted) {
        setState(() {
          _medicalCouncilStates = allZones.map((z) => z.zoneName).toList();
          _membershipStates = allZones.map((z) => z.zoneName).toList();
          _isLoadingStates = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading membership zones: $e');
      if (mounted) {
        setState(() {
          _isLoadingStates = false;
          // Fallback to static list
          _medicalCouncilStates = dropdownStates;
          _membershipStates = dropdownStates;
        });
      }
    }
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
          // API expects JSON arrays, not comma-separated strings
          'academic_details': _selectedQualifications.toList(),
          'professional_details': _selectedCategories.toList(),
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

      debugPrint(responseData.toString());

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
    } on RegistrationError catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError("Something went wrong. Please try again.");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _handleBack() {
    Navigator.pop(context);
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

    return WillPopScope(
      onWillPop: () async {
        _handleBack();
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Register Here",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
              size: 20.sp,
            ),
            onPressed: _handleBack,
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
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const RegistrationStepIndicator(currentStep: 2),
                    SizedBox(height: 16.h),

                    // Section 1: Medical Council Registration Details
                    _buildMedicalCouncilSection(),

                    SizedBox(height: 16.h),

                    // Section 2: Desired Membership Area
                    _buildDesiredMembershipAreaSection(),

                    SizedBox(height: 16.h),

                    // Section 3: Academic Details (only for practitioner)
                    if (role == "practitioner") ...[
                      _buildAcademicDetailsSection(),
                      SizedBox(height: 16.h),
                    ],

                    // Section 4: Professional Details (only for practitioner)
                    if (role == "practitioner") ...[
                      _buildProfessionalDetailsSection(),
                      SizedBox(height: 16.h),
                    ],

                    SizedBox(height: 16.h),

                    // Back and Next buttons
                    _buildBottomButtons(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Section container with border
  Widget _buildSectionContainer({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  /// Section 1: Medical Council Registration Details
  Widget _buildMedicalCouncilSection() {
    return _buildSectionContainer(
      title: "Medical Council Registration Details",
      children: [
        _buildLabel("Medical Council State"),
        SizedBox(height: 10.h),
        _buildDropdown(
          value: _selectedMedicalCouncilState,
          hint: "Select Medical Council State",
          items: _medicalCouncilStates.isNotEmpty
              ? _medicalCouncilStates
              : dropdownStates,
          onChanged: (v) => setState(() => _selectedMedicalCouncilState = v),
          isLoading: _isLoadingStates && _medicalCouncilStates.isEmpty,
        ),
        SizedBox(height: 16.h),
        _buildLabel("Medical Council Number"),
        SizedBox(height: 10.h),
        _buildTextField(
          controller: _medicalCouncilNoController,
          hintText: "Enter Medical Council Number",
        ),
        SizedBox(height: 16.h),
        _buildLabel("Central Council Number"),
        SizedBox(height: 10.h),
        _buildTextField(
          controller: _centralCouncilNoController,
          hintText: "Enter Central Council Number",
        ),
        SizedBox(height: 16.h),
        _buildLabel("UG College"),
        SizedBox(height: 10.h),
        _buildTextField(
          controller: _ugCollegeController,
          hintText: "Enter UG College",
        ),
      ],
    );
  }

  /// Section 2: Desired Membership Area
  Widget _buildDesiredMembershipAreaSection() {
    return _buildSectionContainer(
      title: "Desired Membership Area",
      children: [
        _buildLabel("Country"),
        SizedBox(height: 10.h),
        _buildDropdown(
          value: _selectedCountry,
          hint: "Select Area",
          items: dropdownCountry,
          onChanged: (v) => setState(() => _selectedCountry = v),
        ),
        SizedBox(height: 16.h),
        _buildLabel("State"),
        SizedBox(height: 10.h),
        _buildDropdown(
          value: _selectedState,
          hint: "Select State",
          items: _membershipStates.isNotEmpty
              ? _membershipStates
              : dropdownStates,
          onChanged: (v) => setState(() => _selectedState = v),
          isLoading: _isLoadingStates && _membershipStates.isEmpty,
        ),
        SizedBox(height: 16.h),
        _buildLabel("Membership District"),
        SizedBox(height: 10.h),
        _buildDropdown(
          value: _selectedMembershipDistrict,
          hint: "Select District",
          items: dropdownDistricts,
          onChanged: (v) => setState(() => _selectedMembershipDistrict = v),
          isRequired: false,
        ),
        SizedBox(height: 16.h),
        _buildLabel("Membership Area"),
        SizedBox(height: 10.h),
        _buildDropdown(
          value: _selectedMembershipArea,
          hint: "Select Area",
          items: dropdownAreas,
          onChanged: (v) => setState(() => _selectedMembershipArea = v),
          isRequired: false,
        ),
      ],
    );
  }

  /// Section 3: Academic Details
  Widget _buildAcademicDetailsSection() {
    return _buildSectionContainer(
      title: "Academic Details",
      children: [
        Text(
          "Select all that apply",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 12.h),
        _buildCheckboxGrid(_qualificationOptions, _selectedQualifications),
      ],
    );
  }

  /// Section 4: Professional Details
  Widget _buildProfessionalDetailsSection() {
    return _buildSectionContainer(
      title: "Professional Details",
      children: [
        Text(
          "Select all that apply",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 12.h),
        _buildCheckboxList(_categoryOptions, _selectedCategories),
      ],
    );
  }

  /// Checkbox grid for Academic Details (2 columns)
  Widget _buildCheckboxGrid(List<String> options, Set<String> selected) {
    return Column(
      children: [
        for (int i = 0; i < options.length; i += 2)
          Row(
            children: [
              Expanded(
                child: _buildCheckboxItem(
                  label: options[i],
                  isSelected: selected.contains(options[i]),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selected.add(options[i]);
                      } else {
                        selected.remove(options[i]);
                      }
                    });
                  },
                ),
              ),
              if (i + 1 < options.length)
                Expanded(
                  child: _buildCheckboxItem(
                    label: options[i + 1],
                    isSelected: selected.contains(options[i + 1]),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selected.add(options[i + 1]);
                        } else {
                          selected.remove(options[i + 1]);
                        }
                      });
                    },
                  ),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
      ],
    );
  }

  /// Checkbox list for Professional Details (single column)
  Widget _buildCheckboxList(List<String> options, Set<String> selected) {
    return Column(
      children: options.map((option) {
        return _buildCheckboxItem(
          label: option,
          isSelected: selected.contains(option),
          onChanged: (value) {
            setState(() {
              if (value == true) {
                selected.add(option);
              } else {
                selected.remove(option);
              }
            });
          },
        );
      }).toList(),
    );
  }

  /// Single checkbox item
  Widget _buildCheckboxItem({
    required String label,
    required bool isSelected,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!isSelected),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          children: [
            Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(
                  color: isSelected ? AppColors.brown : Colors.grey[400]!,
                  width: 1.5,
                ),
                color: isSelected ? AppColors.brown : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Label widget
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// TextField widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.textHint),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.brown, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
      validator: isRequired ? (v) => v!.isEmpty ? "Required" : null : null,
    );
  }

  /// Dropdown widget
  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isRequired = true,
    bool isLoading = false,
  }) {
    if (isLoading) {
      return Container(
        height: 50.h,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.brown,
          ),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(
        hint,
        style: TextStyle(fontSize: 14.sp, color: AppColors.textHint),
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.brown, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
      isExpanded: true,
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(
                e,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: isRequired ? (v) => v == null ? "Required" : null : null,
    );
  }

  /// Bottom buttons: Back and Next
  Widget _buildBottomButtons() {
    return Row(
      children: [
        // Back button
        Expanded(
          child: OutlinedButton(
            onPressed: _handleBack,
            style: OutlinedButton.styleFrom(
              minimumSize: Size.fromHeight(50.h),
              side: const BorderSide(color: AppColors.brown),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100.r),
              ),
            ),
            child: Text(
              "Back",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.brown,
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        // Next button
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _handleNext,
            style: ElevatedButton.styleFrom(
              minimumSize: Size.fromHeight(50.h),
              backgroundColor: AppColors.brown,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100.r),
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
        ),
      ],
    );
  }
}
