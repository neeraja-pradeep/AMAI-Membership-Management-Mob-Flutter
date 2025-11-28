import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/features/auth/application/states/registration_state.dart';

import '../../../../../app/router/app_router.dart';
import '../../../application/notifiers/registration_state_notifier.dart';
import '../../../domain/entities/registration/membership_details.dart';
import '../../../domain/entities/registration/registration_step.dart';
import '../../components/dropdown_field.dart';
import '../../components/step_progress_indicator.dart';
import '../../components/text_input_field.dart';
import '../../widgets/exit_confirmation_dialog.dart';

/// Membership Form Screen (Step 1 of 3)
///
/// Collects membership registration information:
/// - Email & Password (for account creation)
/// - Phone & WhatsApp Phone
/// - First Name & Last Name
/// - Membership Type (student, practitioner, house_surgeon, honorary)
/// - Blood Group
/// - BAMS Start Year
/// - Institution Name
///
/// Matches backend POST /api/membership/register/ requirements
class MembershipFormScreen extends ConsumerStatefulWidget {
  const MembershipFormScreen({super.key});

  @override
  ConsumerState<MembershipFormScreen> createState() =>
      _MembershipFormScreenState();
}

class _MembershipFormScreenState extends ConsumerState<MembershipFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _phoneController;
  late final TextEditingController _waPhoneController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _institutionController;

  // State
  MembershipType? _selectedMembershipType;
  String? _selectedBloodGroup;
  int? _selectedBamsYear;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _phoneController = TextEditingController();
    _waPhoneController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _institutionController = TextEditingController();

    // Load existing data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _waPhoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  /// Load existing membership details from registration state
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

    // TODO: Load membershipDetails from state once state is updated
    // For now, we're building the UI first
  }

  /// Auto-save progress on field changes
  void _autoSave() {
    // Save without validation - validation only happens on "Next" button
    _saveMembershipDetails();
  }

  /// Save membership details to registration state
  void _saveMembershipDetails() {
    final membershipDetails = MembershipDetails(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      phone: _phoneController.text.trim(),
      waPhone: _waPhoneController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      membershipType: _selectedMembershipType ?? MembershipType.practitioner,
      bloodGroup: _selectedBloodGroup ?? '',
      bamsStartYear: _selectedBamsYear ?? DateTime.now().year,
      institutionName: _institutionController.text.trim(),
    );

    // TODO: Add updateMembershipDetails method to state notifier
    // ref.read(registrationProvider.notifier).updateMembershipDetails(membershipDetails);
  }

  /// Handle next button press
  Future<void> _handleNext() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Save current step
      _saveMembershipDetails();

      // Auto-save to Hive
      // TODO: Uncomment after state notifier is updated
      // await ref.read(registrationProvider.notifier).autoSaveProgress();

      // Navigate to next step (Address Form)
      if (mounted) {
        Navigator.pushNamed(context, AppRouter.registrationAddress);
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

  /// Generate list of years for BAMS start year dropdown
  List<DropdownMenuItem<int>> _generateYearList() {
    final currentYear = DateTime.now().year;
    final years = <DropdownMenuItem<int>>[];

    // Generate last 60 years (from 1965 to current year)
    for (int year = currentYear; year >= 1965; year--) {
      years.add(
        DropdownMenuItem(
          value: year,
          child: Text(year.toString()),
        ),
      );
    }

    return years;
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
                totalSteps: 3,
                stepTitle: 'Membership Details',
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
                          'Membership Registration',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Please provide your membership information',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),

                        SizedBox(height: 32.h),

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

                        // Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          onChanged: (_) => _autoSave(),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Minimum 8 characters',
                            prefixIcon: Icon(
                              Icons.lock_outlined,
                              size: 20.sp,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 20.sp,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(
                                color: Color(0xFF1976D2),
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(
                                color: Colors.red,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 16.h,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

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

                        // Phone Number
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

                        // WhatsApp Phone Number
                        TextInputField(
                          controller: _waPhoneController,
                          labelText: 'WhatsApp Number',
                          hintText: '1234567890',
                          prefixIcon: Icons.chat_outlined,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (_) => _autoSave(),
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

                        // Membership Type
                        DropdownField<MembershipType>(
                          labelText: 'Membership Type',
                          prefixIcon: Icons.badge_outlined,
                          value: _selectedMembershipType,
                          items: MembershipType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type.displayName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedMembershipType = value;
                            });
                            _autoSave();
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Membership type is required';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

                        // Blood Group
                        DropdownField<String>(
                          labelText: 'Blood Group',
                          prefixIcon: Icons.water_drop_outlined,
                          value: _selectedBloodGroup,
                          items: BloodGroup.options.map((bloodGroup) {
                            return DropdownMenuItem(
                              value: bloodGroup,
                              child: Text(bloodGroup),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedBloodGroup = value;
                            });
                            _autoSave();
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Blood group is required';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

                        // BAMS Start Year
                        DropdownField<int>(
                          labelText: 'BAMS Start Year',
                          prefixIcon: Icons.calendar_today_outlined,
                          value: _selectedBamsYear,
                          items: _generateYearList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedBamsYear = value;
                            });
                            _autoSave();
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'BAMS start year is required';
                            }
                            if (value < 1900 || value > DateTime.now().year) {
                              return 'Invalid year';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

                        // Institution Name
                        TextInputField(
                          controller: _institutionController,
                          labelText: 'Institution Name',
                          hintText: 'Your institution',
                          prefixIcon: Icons.school_outlined,
                          onChanged: (_) => _autoSave(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Institution name is required';
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
