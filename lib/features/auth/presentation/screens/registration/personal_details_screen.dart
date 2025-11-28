import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:myapp/features/auth/application/states/registration_state.dart';

import '../../../../../app/router/app_router.dart';
import '../../../application/notifiers/registration_state_notifier.dart';
import '../../../domain/entities/registration/personal_details.dart';
import '../../../domain/entities/registration/registration_step.dart';
import '../../components/date_picker_field.dart';
import '../../components/dropdown_field.dart';
import '../../components/step_progress_indicator.dart';
import '../../components/text_input_field.dart';
import '../../widgets/exit_confirmation_dialog.dart';

/// Personal Details Screen (Step 1)
///
/// Collects practitioner's basic personal information:
/// - First Name, Last Name
/// - Email, Phone
/// - Date of Birth
/// - Gender
/// - Optional Profile Image
class PersonalDetailsScreen extends ConsumerStatefulWidget {
  const PersonalDetailsScreen({super.key});

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
  late final TextEditingController _dobController;

  // State
  String? _selectedGender;
  DateTime? _dateOfBirth;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
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
    _dobController.dispose();
    super.dispose();
  }

  /// Load existing personal details from registration state
  void _loadExistingData() {
    final state = ref.read(registrationProvider);

    // Only proceed if registration exists
    if (state is! RegistrationStateInProgress) return;

    final personalDetails = state.registration.personalDetails;

    if (personalDetails != null) {
      _firstNameController.text = personalDetails.firstName;
      _lastNameController.text = personalDetails.lastName;
      _emailController.text = personalDetails.email;
      _phoneController.text = personalDetails.phone;
      _dateOfBirth = personalDetails.dateOfBirth;
      _dobController.text = DateFormat('yyyy-MM-dd').format(_dateOfBirth!);
      _selectedGender = personalDetails.gender;
    }
  }

  /// Auto-save progress on field changes
  void _autoSave() {
    // Only auto-save if form is valid
    if (_formKey.currentState?.validate() ?? false) {
      _savePersonalDetails();
    }
  }

  /// Save personal details to registration state
  void _savePersonalDetails() {
    final personalDetails = PersonalDetails(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      dateOfBirth: _dateOfBirth ?? DateTime.now(),
      gender: _selectedGender ?? '',
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
    return WillPopScope(
      onWillPop: _handleBack,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              const StepProgressIndicator(
                currentStep: 1,
                totalSteps: 5,
                stepTitle: 'Personal Details',
              ),

              // Form content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 24.h),

                        // Title
                        Text(
                          'Tell us about yourself',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Please provide your personal information',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),

                        SizedBox(height: 32.h),

                        // First Name
                        TextInputField(
                          controller: _firstNameController,
                          labelText: 'First Name',
                          prefixIcon: Icons.person_outline,
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

                        // Last Name
                        TextInputField(
                          controller: _lastNameController,
                          labelText: 'Last Name',
                          prefixIcon: Icons.person_outline,
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

                        // Email
                        TextInputField(
                          controller: _emailController,
                          labelText: 'Email',
                          hintText: 'your.email@example.com',
                          prefixIcon: Icons.email_outlined,
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

                        // Phone
                        TextInputField(
                          controller: _phoneController,
                          labelText: 'Phone Number',
                          hintText: '1234567890',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (_) => _autoSave(),
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

                        DatePickerField(
                          controller: _dobController,
                          // Prevent keyboard entry, force date picker
                          labelText: 'Date of Birth',
                          prefixIcon: Icons.cake_outlined,
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
                        DropdownField<String>(
                          labelText: 'Gender',
                          prefixIcon: Icons.wc_outlined,
                          value: _selectedGender,
                          items: const [
                            DropdownMenuItem(
                              value: 'male',
                              child: Text('Male'),
                            ),
                            DropdownMenuItem(
                              value: 'female',
                              child: Text('Female'),
                            ),
                            DropdownMenuItem(
                              value: 'other',
                              child: Text('Other'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                            _autoSave();
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Gender is required';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 32.h),

                        // Next button
                        SizedBox(
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: _handleNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1976D2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Next',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 20.sp,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
