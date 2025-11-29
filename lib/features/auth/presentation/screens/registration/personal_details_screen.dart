import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/auth/application/states/registration_state.dart';

import '../../../../../app/router/app_router.dart';
import '../../../application/notifiers/registration_state_notifier.dart';
import '../../../domain/entities/registration/personal_details.dart';
import '../../components/date_picker_field.dart';

import '../../components/text_input_field.dart';
import '../../widgets/exit_confirmation_dialog.dart';

/// Personal Details Screen (Step 1 of 5)
///
/// Collects practitioner's basic personal information:
/// - First Name, Last Name
/// - Email, Password
/// - Phone (+91 prefix), WhatsApp Phone (+91 prefix)
/// - Date of Birth
/// - Gender
/// - Blood Group
///
/// NOTE: Membership type is passed when registration starts (when user selects "Practitioner")
/// and is stored in the registration state.
///
/// UPDATED: Now includes all fields needed for /api/membership/register/
class PersonalDetailsScreen extends ConsumerStatefulWidget {
  final String password;
  const PersonalDetailsScreen({super.key, required this.password});

  @override
  ConsumerState<PersonalDetailsScreen> createState() =>
      _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends ConsumerState<PersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;

  late final TextEditingController _phoneController;
  late final TextEditingController _waPhoneController;
  late final TextEditingController _dobController;

  // State
  String? _selectedGender;
  String? _selectedBloodGroup;
  DateTime? _dateOfBirth;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();

    _phoneController = TextEditingController();
    _waPhoneController = TextEditingController();
    _dobController = TextEditingController();

    // Load existing data if available
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
    super.dispose();
  }

  /// Load existing personal details from registration state
  void _loadExistingData() {
    final state = ref.read(registrationProvider);

    // Handle different state types
    if (state is RegistrationStateResumePrompt) {
      // User has existing registration, resume it
      ref
          .read(registrationProvider.notifier)
          .resumeRegistration(state.existingRegistration);
      // Reload after resuming
      Future.microtask(() => _loadExistingData());
      return;
    }

    // If registration hasn't been started yet, start it now
    if (state is! RegistrationStateInProgress) {
      ref.read(registrationProvider.notifier).startNewRegistration();
      return; // State is now initialized, but no data to load yet
    }

    final personalDetails = state.registration.personalDetails;

    if (personalDetails != null) {
      _firstNameController.text = personalDetails.firstName;
      _lastNameController.text = personalDetails.lastName;
      _emailController.text = personalDetails.email;

      _phoneController.text = personalDetails.phone;
      _waPhoneController.text = personalDetails.waPhone;
      _dateOfBirth = personalDetails.dateOfBirth;
      _dobController.text = DateFormat('yyyy-MM-dd').format(_dateOfBirth!);
      setState(() {
        _selectedGender = personalDetails.gender;
        _selectedBloodGroup = personalDetails.bloodGroup;
      });
    }
  }

  /// Auto-save progress on field changes
  void _autoSave() {
    // Save without validation - validation only happens on "Next" button

    _savePersonalDetails();
  }

  /// Save personal details to registration state
  void _savePersonalDetails() {
    // Get membership type from registration state (set when registration started)
    final state = ref.read(registrationProvider);
    String membershipType = 'practitioner'; // default

    if (state is RegistrationStateInProgress) {
      // Try to get from existing personal details or use default
      membershipType =
          state.registration.personalDetails?.membershipType ?? 'practitioner';
    }

    final personalDetails = PersonalDetails(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: widget.password,
      phone: _phoneController.text.trim(),
      waPhone: _waPhoneController.text.trim(),
      dateOfBirth: _dateOfBirth ?? DateTime.now(),
      gender: _selectedGender ?? '',
      bloodGroup: _selectedBloodGroup ?? '',
      membershipType: membershipType,
    );

    ref
        .read(registrationProvider.notifier)
        .updatePersonalDetails(personalDetails);
  }

  /// Handle next button press
  Future<void> _handleNext() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Save current step
      _savePersonalDetails();

      // Auto-save to Hive
      await ref.read(registrationProvider.notifier).autoSaveProgress();

      // Navigate to next step
      if (mounted) {
        Navigator.pushNamed(context, AppRouter.registrationProfessional);
      }
    }
  }

  /// Handle back button press
  Future<bool> _handleBack() async {
    final shouldExit = await showExitConfirmationDialog(context);
    if (shouldExit == true && mounted) {
      Navigator.pop(context);
    }
    return false; // Prevent default back behavior
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
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Column(
                    children: [
                      // Step text
                      Text(
                        "Step 1 of 4",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // Dot progress indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          final isActive =
                              index == 0; // current step = 1 → index 0 active
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.symmetric(horizontal: 6.w),
                            width: isActive ? 16.w : 10.w,
                            height: isActive ? 16.w : 10.w,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.brown
                                  : Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),

                      SizedBox(height: 10.h),

                      Text(
                        "Personal Details",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                // Form content
                Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title
                        const Text(
                          "First Name",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 10.h),

                        // First Name
                        TextInputField(
                          controller: _firstNameController,
                          hintText: "First Name",
                          onChanged: (_) => _autoSave(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'First name is required';
                            }
                            if (value.trim().length < 2) {
                              return 'First name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),
                        const Text(
                          "Last Name",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 10.h),
                        // Last Name
                        TextInputField(
                          controller: _lastNameController,
                          hintText: "Last Name",
                          onChanged: (_) => _autoSave(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Last name is required';
                            }
                            if (value.trim().length < 2) {
                              return 'Last name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),
                        const Text(
                          "Email",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 10.h),

                        // Email
                        TextInputField(
                          controller: _emailController,

                          hintText: 'your.email@example.com',

                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) => _autoSave(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            final emailRegex = RegExp(
                              r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
                            );
                            if (!emailRegex.hasMatch(value.trim())) {
                              return 'Invalid email format';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),
                        const Text(
                          "Mobile Number",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 10.h),

                        // Phone with +91 prefix
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (_) => _autoSave(),
                          decoration: InputDecoration(
                            hintText: '1234567890',
                            prefixIcon: Icon(Icons.phone_outlined, size: 20.sp),
                            prefixText: '+91 ',
                            prefixStyle: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
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
                              borderSide: const BorderSide(
                                color: AppColors.brown,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 16.h,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Phone number is required';
                            }
                            if (value.trim().length != 10) {
                              return 'Phone number must be 10 digits';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),
                        const Text(
                          "Whatsapp Numberr",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 10.h),

                        // WhatsApp Phone with +91 prefix
                        TextFormField(
                          controller: _waPhoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (_) => _autoSave(),
                          decoration: InputDecoration(
                            hintText: '1234567890',
                            prefixIcon: Icon(Icons.chat_outlined, size: 20.sp),
                            prefixText: '+91 ',
                            prefixStyle: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
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
                              borderSide: const BorderSide(
                                color: AppColors.brown,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 16.h,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'WhatsApp number is required';
                            }
                            if (value.trim().length != 10) {
                              return 'WhatsApp number must be 10 digits';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),
                        const Text(
                          "Date Of Birth",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 10.h),

                        DatePickerField(
                          controller: _dobController,
                          hintText: 'Enter Your Birthday',
                          // Prevent keyboard entry,   force date picker
                          initialDate: _dateOfBirth,
                          firstDate: DateTime(1940),
                          lastDate:
                              DateTime.now(), // <-- allow selecting any date, validation limits 18+
                          onDateSelected: (date) {
                            setState(() {
                              _dateOfBirth = date;
                              _dobController.text = DateFormat(
                                'yyyy-MM-dd',
                              ).format(date);
                            });
                            _autoSave();
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Date of birth is required';
                            }
                            if (_dateOfBirth == null) {
                              return 'Please select a valid date';
                            }

                            // Correct age check
                            final today = DateTime.now();
                            final birthdayThisYear = DateTime(
                              today.year,
                              _dateOfBirth!.month,
                              _dateOfBirth!.day,
                            );
                            final age = today.year - _dateOfBirth!.year;

                            if (age < 18 ||
                                (age == 18 &&
                                    today.isBefore(birthdayThisYear))) {
                              return 'You must be at least 18 years old';
                            }

                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

                        // Gender
                        const Text(
                          "Gender",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 10.h),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  value: "male",
                                  groupValue: _selectedGender,
                                  title: const Text("Male"),
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  activeColor: AppColors.brown,
                                  onChanged: (value) {
                                    setState(() => _selectedGender = value);
                                    _autoSave();
                                  },
                                ),
                              ),

                              Expanded(
                                child: RadioListTile<String>(
                                  value: "female",
                                  groupValue: _selectedGender,
                                  title: const Text("Female"),
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  activeColor: AppColors.brown,
                                  onChanged: (value) {
                                    setState(() => _selectedGender = value);
                                    _autoSave();
                                  },
                                ),
                              ),

                              Expanded(
                                child: RadioListTile<String>(
                                  value: "other",
                                  groupValue: _selectedGender,
                                  title: const Text("Other"),
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  activeColor: AppColors.brown,
                                  onChanged: (value) {
                                    setState(() => _selectedGender = value);
                                    _autoSave();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16.h),

                        const Text(
                          "Blood Group",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 10.h),

                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedBloodGroup,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            hint: const Text("Select your blood group"),
                            items: const [
                              DropdownMenuItem(value: 'A+', child: Text('A+')),
                              DropdownMenuItem(value: 'A-', child: Text('A-')),
                              DropdownMenuItem(value: 'B+', child: Text('B+')),
                              DropdownMenuItem(value: 'B-', child: Text('B-')),
                              DropdownMenuItem(
                                value: 'AB+',
                                child: Text('AB+'),
                              ),
                              DropdownMenuItem(
                                value: 'AB-',
                                child: Text('AB-'),
                              ),
                              DropdownMenuItem(value: 'O+', child: Text('O+')),
                              DropdownMenuItem(value: 'O-', child: Text('O-')),
                            ],
                            dropdownColor: Colors.white,
                            onChanged: (value) {
                              setState(() => _selectedBloodGroup = value);
                              _autoSave();
                            },
                            validator: (value) => value == null
                                ? "Blood group is required"
                                : null,
                          ),
                        ),

                        SizedBox(height: 32.h),

                        // Next button
                        SizedBox(
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: _handleNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brown,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Next',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
