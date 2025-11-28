import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:myapp/features/auth/application/states/registration_state.dart';

import '../../../../../app/router/app_router.dart';
import '../../../application/notifiers/registration_state_notifier.dart';
import '../../../domain/entities/registration/professional_details.dart';
import '../../components/date_picker_field.dart';
import '../../components/dropdown_field.dart';
import '../../components/step_progress_indicator.dart';
import '../../components/text_input_field.dart';

/// Professional Details Screen (Step 2)
///
/// Collects practitioner's professional credentials:
/// - Medical Council Registration Number
/// - Medical Council
/// - Registration Date
/// - Qualification
/// - Specialization (optional)
/// - Institute Name (optional)
/// - Years of Experience
/// - Current Workplace (optional)
/// - Designation (optional)
class ProfessionalDetailsScreen extends ConsumerStatefulWidget {
  const ProfessionalDetailsScreen({super.key});

  @override
  ConsumerState<ProfessionalDetailsScreen> createState() =>
      _ProfessionalDetailsScreenState();
}

class _ProfessionalDetailsScreenState
    extends ConsumerState<ProfessionalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _regNumberController;
  late final TextEditingController _regDateController;
  late final TextEditingController _specializationController;
  late final TextEditingController _instituteController;
  late final TextEditingController _experienceController;
  late final TextEditingController _workplaceController;
  late final TextEditingController _designationController;

  // State
  String? _selectedCouncil;
  String? _selectedQualification;
  DateTime? _registrationDate;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _regNumberController = TextEditingController();
    _regDateController = TextEditingController();
    _specializationController = TextEditingController();
    _instituteController = TextEditingController();
    _experienceController = TextEditingController(text: '0');
    _workplaceController = TextEditingController();
    _designationController = TextEditingController();

    // Load existing data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
  }

  @override
  void dispose() {
    _regNumberController.dispose();
    _regDateController.dispose();
    _specializationController.dispose();
    _instituteController.dispose();
    _experienceController.dispose();
    _workplaceController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  void _loadExistingData() {
    final state = ref.read(registrationProvider);

    // Handle different state types
    if (state is RegistrationStateResumePrompt) {
      // User has existing registration, resume it
      ref.read(registrationProvider.notifier).resumeRegistration(
        state.existingRegistration,
      );
      // Reload after resuming
      Future.microtask(() => _loadExistingData());
      return;
    }

    // If registration hasn't been started yet, start it now
    if (state is! RegistrationStateInProgress) {
      ref.read(registrationProvider.notifier).startNewRegistration();
      return; // State is now initialized, but no data to load yet
    }

    final professionalDetails = state.registration.professionalDetails;

    if (professionalDetails != null) {
      _regNumberController.text =
          professionalDetails.medicalCouncilRegistrationNumber;
      _selectedCouncil = professionalDetails.medicalCouncil;
      _registrationDate = professionalDetails.registrationDate;
      _regDateController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(_registrationDate!);
      _selectedQualification = professionalDetails.qualification;
      _specializationController.text = professionalDetails.specialization ?? '';
      _instituteController.text = professionalDetails.instituteName ?? '';
      _experienceController.text = professionalDetails.yearsOfExperience
          .toString();
      _workplaceController.text = professionalDetails.currentWorkplace ?? '';
      _designationController.text = professionalDetails.designation ?? '';
    }
  }

  /// Auto-save progress on field changes
  void _autoSave() {
    // Save without validation - validation only happens on "Next" button
    _saveProfessionalDetails();
  }

  /// Save professional details to registration state
  void _saveProfessionalDetails() {
    final professionalDetails = ProfessionalDetails(
      medicalCouncilRegistrationNumber: _regNumberController.text.trim(),
      medicalCouncil: _selectedCouncil ?? '',
      registrationDate: _registrationDate ?? DateTime.now(),
      qualification: _selectedQualification ?? '',
      specialization: _specializationController.text.trim().isNotEmpty
          ? _specializationController.text.trim()
          : null,
      instituteName: _instituteController.text.trim().isNotEmpty
          ? _instituteController.text.trim()
          : null,
      yearsOfExperience: int.tryParse(_experienceController.text) ?? 0,
      currentWorkplace: _workplaceController.text.trim().isNotEmpty
          ? _workplaceController.text.trim()
          : null,
      designation: _designationController.text.trim().isNotEmpty
          ? _designationController.text.trim()
          : null,
    );

    ref
        .read(registrationProvider.notifier)
        .updateProfessionalDetails(professionalDetails);
  }

  /// Handle next button press
  Future<void> _handleNext() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Save current step
      _saveProfessionalDetails();

      // Auto-save to Hive
      await ref.read(registrationProvider.notifier).autoSaveProgress();

      // Navigate to next step
      if (mounted) {
        Navigator.pushNamed(context, AppRouter.registrationAddress);
      }
    }
  }

  /// Handle back button press
  void _handleBack() {
    // Save progress before going back
    _saveProfessionalDetails();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
            onPressed: _handleBack,
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              const StepProgressIndicator(
                currentStep: 2,
                totalSteps: 5,
                stepTitle: 'Professional Details',
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
                          'Professional Credentials',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Please provide your medical credentials',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),

                        SizedBox(height: 32.h),

                        // Medical Council Registration Number
                        TextInputField(
                          controller: _regNumberController,
                          labelText: 'Medical Council Registration Number',
                          prefixIcon: Icons.badge_outlined,
                          onChanged: (_) => _autoSave(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Registration number is required';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

                        // Medical Council
                        DropdownField<String>(
                          labelText: 'Medical Council',
                          prefixIcon: Icons.account_balance_outlined,
                          value: _selectedCouncil,
                          items: const [
                            DropdownMenuItem(
                              value: 'MCI',
                              child: Text('Medical Council of India (MCI)'),
                            ),
                            DropdownMenuItem(
                              value: 'State Medical Council',
                              child: Text('State Medical Council'),
                            ),
                            DropdownMenuItem(
                              value: 'Other',
                              child: Text('Other'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCouncil = value;
                            });
                            _autoSave();
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Medical council is required';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

                        // Registration Date
                        DatePickerField(
                          controller: _regDateController,
                          labelText: 'Registration Date',
                          prefixIcon: Icons.event_outlined,
                          initialDate: _registrationDate,
                          firstDate: DateTime(1970),
                          lastDate: DateTime.now(),
                          onDateSelected: (date) {
                            setState(() {
                              _registrationDate = date;
                            });
                            _autoSave();
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Registration date is required';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

                        // Qualification
                        DropdownField<String>(
                          labelText: 'Qualification',
                          prefixIcon: Icons.school_outlined,
                          value: _selectedQualification,
                          items: const [
                            DropdownMenuItem(
                              value: 'MBBS',
                              child: Text('MBBS'),
                            ),
                            DropdownMenuItem(
                              value: 'MD',
                              child: Text('MD (Doctor of Medicine)'),
                            ),
                            DropdownMenuItem(
                              value: 'MS',
                              child: Text('MS (Master of Surgery)'),
                            ),
                            DropdownMenuItem(
                              value: 'BDS',
                              child: Text('BDS (Bachelor of Dental Surgery)'),
                            ),
                            DropdownMenuItem(
                              value: 'MDS',
                              child: Text('MDS (Master of Dental Surgery)'),
                            ),
                            DropdownMenuItem(
                              value: 'Other',
                              child: Text('Other'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedQualification = value;
                            });
                            _autoSave();
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Qualification is required';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

                        // Specialization (optional)
                        TextInputField(
                          controller: _specializationController,
                          labelText: 'Specialization (Optional)',
                          hintText: 'e.g., Cardiology, Pediatrics',
                          prefixIcon: Icons.medical_services_outlined,
                          onChanged: (_) => _autoSave(),
                        ),

                        SizedBox(height: 16.h),

                        // Institute Name (optional)
                        TextInputField(
                          controller: _instituteController,
                          labelText: 'Institute Name (Optional)',
                          hintText: 'Where you obtained your degree',
                          prefixIcon: Icons.business_outlined,
                          onChanged: (_) => _autoSave(),
                        ),

                        SizedBox(height: 16.h),

                        // Years of Experience
                        TextInputField(
                          controller: _experienceController,
                          labelText: 'Years of Experience',
                          prefixIcon: Icons.work_outline,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (_) => _autoSave(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Experience is required';
                            }
                            final years = int.tryParse(value);
                            if (years == null || years < 0) {
                              return 'Invalid number of years';
                            }
                            if (years > 70) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

                        // Current Workplace (optional)
                        TextInputField(
                          controller: _workplaceController,
                          labelText: 'Current Workplace (Optional)',
                          hintText: 'Hospital or clinic name',
                          prefixIcon: Icons.local_hospital_outlined,
                          onChanged: (_) => _autoSave(),
                        ),

                        SizedBox(height: 16.h),

                        // Designation (optional)
                        TextInputField(
                          controller: _designationController,
                          labelText: 'Designation (Optional)',
                          hintText: 'e.g., Consultant, Senior Surgeon',
                          prefixIcon: Icons.assignment_ind_outlined,
                          onChanged: (_) => _autoSave(),
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
