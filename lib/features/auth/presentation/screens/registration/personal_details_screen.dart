import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/auth/application/states/registration_state.dart';
import 'package:myapp/features/auth/domain/entities/user_role.dart';

import '../../../../../app/router/app_router.dart';
import '../../../application/notifiers/registration_state_notifier.dart';
import '../../../domain/entities/registration/personal_details.dart';
import '../../components/date_picker_field.dart';
import '../../components/registration_step_indicator.dart';
import '../../components/text_input_field.dart';
import '../../widgets/exit_confirmation_dialog.dart';

class PersonalDetailsScreen extends ConsumerStatefulWidget {
  final UserRole role;
  final String password;
  final String email;

  const PersonalDetailsScreen({
    super.key,
    required this.password,
    required this.role,
    this.email = '', // Optional: empty for resume flow, filled for fresh flow
  });

  @override
  ConsumerState<PersonalDetailsScreen> createState() =>
      _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends ConsumerState<PersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _waPhoneController;
  late final TextEditingController _dobController;

  late final TextEditingController _institutionController;
  late final TextEditingController _bamsStartYearController;

  String? _selectedGender;
  String? _selectedBloodGroup;
  String? _selectedMagazineType;
  DateTime? _dateOfBirth;
  bool _sameAsPhone = false;

  late String role;

  @override
  void initState() {
    super.initState();

    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController(
      text: widget.email,
    ); // Pre-fill with passed email
    _phoneController = TextEditingController();
    _waPhoneController = TextEditingController();
    _dobController = TextEditingController();

    _institutionController = TextEditingController();
    _bamsStartYearController = TextEditingController();

    /// Convert enum → string
    role = _mapRole(widget.role); // "practitioner", "house_surgeon", "student"
    debugPrint('Role mapped to: $role');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _waPhoneController.dispose();
    _dobController.dispose();
    _institutionController.dispose();
    _bamsStartYearController.dispose();
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

    if (state is! RegistrationStateInProgress) {
      ref.read(registrationProvider.notifier).startNewRegistration();
      return;
    }

    final personalDetails = state.registration.personalDetails;
    if (personalDetails != null) {
      _firstNameController.text = personalDetails.firstName;
      _lastNameController.text = personalDetails.lastName;

      // Only load email from state if widget.email is empty (resume case)
      // Otherwise keep the email passed from RegisterScreen (fresh case)
      if (widget.email.isEmpty && personalDetails.email.isNotEmpty) {
        _emailController.text = personalDetails.email;
      }

      _phoneController.text = personalDetails.phone;
      _waPhoneController.text = personalDetails.waPhone;

      _institutionController.text = personalDetails.institutionName ?? '';
      _bamsStartYearController.text = personalDetails.bamsStartYear ?? '';
      _selectedMagazineType = personalDetails.magazinePreference;

      if (personalDetails.dateOfBirth != null) {
        _dateOfBirth = personalDetails.dateOfBirth;
        _dobController.text = DateFormat('yyyy-MM-dd').format(_dateOfBirth!);
      }

      setState(() {
        _selectedGender = personalDetails.gender;
        _selectedBloodGroup = personalDetails.bloodGroup;
      });
    }
  }

  String _mapRole(UserRole role) {
    switch (role) {
      case UserRole.houseSurgeon:
        return "house_surgeon";
      case UserRole.student:
        return "student";
      case UserRole.practitioner:
        return "practitioner";
    }
  }

  void _autoSave() => _savePersonalDetails();

  PersonalDetails _buildPersonalDetailsFromForm() {
    return PersonalDetails(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: widget.password,
      phone: _phoneController.text.trim(),
      waPhone: _waPhoneController.text.trim(),
      dateOfBirth: _dateOfBirth ?? DateTime.now(),
      gender: _selectedGender ?? '',
      bloodGroup: _selectedBloodGroup ?? '',
      membershipType: role, // "practitioner" / "house_surgeon" / "student"
      // 🔧 FIXED: correct role string for house_surgeon
      institutionName: (role == "house_surgeon" || role == "student")
          ? _institutionController.text.trim()
          : null,
      bamsStartYear: role == "student"
          ? _bamsStartYearController.text.trim()
          : null,
      magazinePreference: (role == "house_surgeon" || role == "practitioner")
          ? _selectedMagazineType
          : null,
    );
  }

  void _savePersonalDetails() {
    final personalDetails = _buildPersonalDetailsFromForm();

    ref
        .read(registrationProvider.notifier)
        .updatePersonalDetails(personalDetails);
  }

  Future<void> _handleNext() async {
    // 1️⃣ Form validation gate
    if (!(_formKey.currentState?.validate() ?? false)) {
      debugPrint('❌ PersonalDetails form not valid');
      return;
    }

    // 2️⃣ Build from controllers + save into provider
    final personalDetails = _buildPersonalDetailsFromForm();

    ref
        .read(registrationProvider.notifier)
        .updatePersonalDetails(personalDetails);

    await ref.read(registrationProvider.notifier).autoSaveProgress();

    // 3️⃣ Role-based navigation

    // 🧑‍🎓 Student → Skip professional screen and hit membership endpoint
    if (role == "student") {
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
        'bams_start_year ': personalDetails.bamsStartYear,
        'institution_name': personalDetails.institutionName,
      };

      try {
        final responseData = await ref
            .read(registrationProvider.notifier)
            .submitMembershipRegistration(membershipData);

        final userId = responseData['application']?['user_detail']?['id'];
        final applicationId = responseData['application']?['id'];

        if (userId == null || applicationId == null) {
          debugPrint(responseData.toString());
          _showError(responseData['detail'] ?? 'Something went wrong');
          return;
        }

        final notifier = ref.read(registrationProvider.notifier);
        notifier.updateBackendIds(applicationId: applicationId, userId: userId);

        if (!mounted) return;
        Navigator.pushNamed(context, AppRouter.registrationAddress);
      } catch (e) {
        _showError("Failed: $e");
      }

      return;
    }

    // 👨‍⚕️ Practitioner or 🩺 House Surgeon → go to Professional screen
    if (mounted) {
      Navigator.pushNamed(context, AppRouter.registrationProfessional);
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));

  Future<bool> _handleBack() async {
    final shouldExit = await showExitConfirmationDialog(context);
    if (shouldExit == true && mounted) Navigator.pop(context);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: _handleBack,
        child: Scaffold(
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const RegistrationStepIndicator(
                    currentStep: 1,
                    stepTitle: "Personal Details",
                  ),
                  const Text("First Name"),
                  SizedBox(height: 10.h),
                  TextInputField(
                    controller: _firstNameController,
                    hintText: "First Name",
                    onChanged: (_) => _autoSave(),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  SizedBox(height: 16.h),

                  const Text("Last Name"),
                  SizedBox(height: 10.h),
                  TextInputField(
                    controller: _lastNameController,
                    hintText: "Last Name",
                    onChanged: (_) => _autoSave(),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  SizedBox(height: 16.h),

                  const Text("Email"),
                  SizedBox(height: 10.h),
                  TextInputField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    hintText: "your.email@gmail.com",
                    onChanged: (_) => _autoSave(),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),

                  SizedBox(height: 16.h),
                  const Text("Mobile Number"),
                  SizedBox(height: 10.h),
                  TextFormField(
                    controller: _phoneController,
                    maxLength: 10,
                    keyboardType: TextInputType.phone,
                    onChanged: (_) => _autoSave(),
                    validator: (v) => v!.length != 10 ? "Invalid" : null,
                    decoration: InputDecoration(
                      prefixText: "+91 ",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Whatsapp Number"),
                      Row(
                        children: [
                          SizedBox(
                            height: 24.h,
                            width: 24.w,
                            child: Checkbox(
                              value: _sameAsPhone,
                              activeColor: AppColors.brown,
                              onChanged: (v) {
                                setState(() {
                                  _sameAsPhone = v ?? false;
                                  if (_sameAsPhone) {
                                    _waPhoneController.text =
                                        _phoneController.text;
                                  }
                                });
                                _autoSave();
                              },
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "Same as phone",
                            style: TextStyle(fontSize: 12.sp),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  TextFormField(
                    controller: _waPhoneController,
                    maxLength: 10,
                    enabled: !_sameAsPhone,
                    keyboardType: TextInputType.phone,
                    onChanged: (_) => _autoSave(),
                    validator: (v) => v!.length != 10 ? "Invalid" : null,
                    decoration: InputDecoration(
                      prefixText: "+91 ",
                      filled: _sameAsPhone,
                      fillColor: _sameAsPhone ? Colors.grey[200] : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),
                  const Text("Date of Birth"),
                  DatePickerField(
                    controller: _dobController,
                    onDateSelected: (date) {
                      setState(() => _dateOfBirth = date);
                      _autoSave();
                    },
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),

                  SizedBox(height: 16.h),
                  const Text("Gender"),
                  Row(
                    children: [
                      Radio<String>(
                        value: "male",
                        groupValue: _selectedGender,
                        activeColor: AppColors.brown,
                        onChanged: (v) {
                          setState(() => _selectedGender = v);
                          _autoSave();
                        },
                      ),
                      const Text("Male"),
                      Radio<String>(
                        value: "female",
                        groupValue: _selectedGender,
                        activeColor: AppColors.brown,
                        onChanged: (v) {
                          setState(() => _selectedGender = v);
                          _autoSave();
                        },
                      ),
                      const Text("Female"),
                      Radio<String>(
                        value: "other",
                        groupValue: _selectedGender,
                        activeColor: AppColors.brown,
                        onChanged: (v) {
                          setState(() => _selectedGender = v);
                          _autoSave();
                        },
                      ),
                      const Text("Other"),
                    ],
                  ),

                  SizedBox(height: 16.h),
                  const Text("Blood Group"),
                  SizedBox(height: 10.h),
                  DropdownButtonFormField<String>(
                    value: _selectedBloodGroup,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                    items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) {
                      setState(() => _selectedBloodGroup = v);
                      _autoSave();
                    },
                    validator: (v) => v == null ? "Required" : null,
                  ),

                  SizedBox(height: 20.h),

                  if (role == 'house_surgeon' || role == 'student') ...[
                    const Text("Institution Name"),
                    SizedBox(height: 10.h),
                    TextInputField(
                      controller: _institutionController,
                      hintText: "Enter institution name",
                      onChanged: (_) => _autoSave(),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    SizedBox(height: 20.h),
                  ],

                  if (role == 'house_surgeon' || role == 'practitioner') ...[
                    const Text("APTA Magazine Type"),
                    SizedBox(height: 10.h),
                    DropdownButtonFormField<String>(
                      value: _selectedMagazineType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                      items: ["Physical Copy", "Digital Copy", "Both"]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() => _selectedMagazineType = v);
                        _autoSave();
                      },
                      validator: (v) => v == null ? "Required" : null,
                    ),
                    SizedBox(height: 20.h),
                  ],

                  if (role == 'student') ...[
                    const Text("BAMS Start Year"),
                    SizedBox(height: 10.h),
                    TextFormField(
                      controller: _bamsStartYearController,
                      maxLength: 4,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _autoSave(),
                      validator: (v) => RegExp(r'^\d{4}$').hasMatch(v ?? "")
                          ? null
                          : "Enter valid year",
                    ),
                    SizedBox(height: 20.h),
                  ],

                  SizedBox(height: 30.h),
                  ElevatedButton(
                    onPressed: _handleNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brown,
                    ),
                    child: const Text(
                      "Next",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
