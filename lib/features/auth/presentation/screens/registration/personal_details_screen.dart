import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/auth/application/states/registration_state.dart';
import 'package:myapp/features/auth/domain/entities/registration/registration_error.dart';
import 'package:myapp/features/auth/domain/entities/user_role.dart';

import '../../../../../app/router/app_router.dart';
import '../../../application/notifiers/registration_state_notifier.dart';
import '../../../domain/entities/registration/personal_details.dart';
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
      } on RegistrationError catch (e) {
        _showError(e.message);
      } catch (e) {
        _showError("Something went wrong. Please try again.");
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
  ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Color(0xFF60212E)));

  Future<bool> _handleBack() async {
    final shouldExit = await showExitConfirmationDialog(context);
    if (shouldExit == true && mounted) Navigator.pop(context);
    return false;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.brown,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
      _autoSave();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBack,
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
            onPressed: () => _handleBack(),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const RegistrationStepIndicator(currentStep: 1),
                    Text(
                      "Name",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    TextInputField(
                      controller: _firstNameController,
                      hintText: "Enter your name",
                      onChanged: (_) => _autoSave(),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),

                    SizedBox(height: 16.h),

                    Text(
                      "Email",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    TextInputField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      hintText: "Enter your Email",
                      onChanged: (_) => _autoSave(),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),

                    SizedBox(height: 16.h),
                    Text(
                      "Mobile Number",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    TextFormField(
                      controller: _phoneController,
                      maxLength: 10,
                      keyboardType: TextInputType.phone,
                      onChanged: (_) => _autoSave(),
                      validator: (v) => v!.length != 10 ? "Invalid" : null,
                      decoration: InputDecoration(
                        hintText: "Enter your mobile number",
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/auth/indiaFlag.png',
                                height: 18.h,
                                width: 18.h,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "+91",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        counterText: '',
                      ),
                    ),

                    SizedBox(height: 16.h),
                    // Same as Mobile checkbox above WhatsApp Number
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
                          "Same as Mobile no.",
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "Whatsapp Number",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                      ),
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
                        hintText: "Enter your WhatsApp number",
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/auth/indiaFlag.png',
                                height: 18.h,
                                width: 18.h,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "+91",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                        filled: _sameAsPhone,
                        fillColor: _sameAsPhone ? Colors.grey[200] : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        counterText: '',
                      ),
                    ),

                    SizedBox(height: 16.h),
                    Text(
                      "Date of Birth",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    TextFormField(
                      controller: _dobController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                      decoration: InputDecoration(
                        hintText: "Select date of birth",
                        suffixIcon: Padding(
                          padding: EdgeInsets.all(12.w),
                          child: SvgPicture.asset(
                            'assets/svg/calander.svg',
                            height: 20.h,
                            width: 20.h,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),
                    Text(
                      "Gender",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
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

                    if (role == 'house_surgeon' || role == 'student') ...[
                      Text(
                        "Institution Name",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      TextInputField(
                        controller: _institutionController,
                        hintText: "Enter institution name",
                        onChanged: (_) => _autoSave(),
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                      SizedBox(height: 16.h),
                    ],

                    if (role == 'house_surgeon' || role == 'practitioner') ...[
                      Text(
                        "APTA Magazine Type",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      DropdownButtonFormField<String>(
                        value: _selectedMagazineType,
                        hint: const Text("Select Type"),
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
                      SizedBox(height: 16.h),
                    ],

                    Text(
                      "Blood Group",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    DropdownButtonFormField<String>(
                      value: _selectedBloodGroup,
                      hint: const Text("Select Blood Group"),
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
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() => _selectedBloodGroup = v);
                        _autoSave();
                      },
                      validator: (v) => v == null ? "Required" : null,
                    ),

                    SizedBox(height: 16.h),

                    if (role == 'student') ...[
                      Text(
                        "BAMS Start Year",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
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

                    SizedBox(height: 10.h),
                    ElevatedButton(
                      onPressed: _handleNext,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(50.h),

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
      ),
    );
  }
}
