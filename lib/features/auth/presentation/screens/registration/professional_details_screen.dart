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

/// Professional Details Screen (Step 2 of 2)
///
/// Collects practitioner's professional credentials:
/// - Medical Council State
/// - Medical Council Number
/// - Central Council Number
/// - UG College
/// - Zone ID
/// - Professional Details 1 & 2
///
/// CRITICAL: When "Next" is clicked, combines PersonalDetails + ProfessionalDetails
/// and calls POST /api/membership/register/ to create the account
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
  late final TextEditingController _medicalCouncilNoController;
  late final TextEditingController _centralCouncilNoController;
  late final TextEditingController _ugCollegeController;
  late final TextEditingController _zoneIdController;
  late final TextEditingController _professionalDetails1Controller;
  late final TextEditingController _professionalDetails2Controller;

  // State
  String? _selectedMedicalCouncilState;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _medicalCouncilNoController = TextEditingController();
    _centralCouncilNoController = TextEditingController();
    _ugCollegeController = TextEditingController();
    _zoneIdController = TextEditingController();
    _professionalDetails1Controller = TextEditingController();
    _professionalDetails2Controller = TextEditingController();

    // Load existing data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
  }

  @override
  void dispose() {
    _medicalCouncilNoController.dispose();
    _centralCouncilNoController.dispose();
    _ugCollegeController.dispose();
    _zoneIdController.dispose();
    _professionalDetails1Controller.dispose();
    _professionalDetails2Controller.dispose();
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
      setState(() {
        _selectedMedicalCouncilState = professionalDetails.medicalCouncilState;
      });
      _medicalCouncilNoController.text = professionalDetails.medicalCouncilNo;
      _centralCouncilNoController.text = professionalDetails.centralCouncilNo;
      _ugCollegeController.text = professionalDetails.ugCollege;
      _zoneIdController.text = professionalDetails.zoneId;
      _professionalDetails1Controller.text = professionalDetails.professionalDetails1;
      _professionalDetails2Controller.text = professionalDetails.professionalDetails2;
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
      medicalCouncilState: _selectedMedicalCouncilState ?? '',
      medicalCouncilNo: _medicalCouncilNoController.text.trim(),
      centralCouncilNo: _centralCouncilNoController.text.trim(),
      ugCollege: _ugCollegeController.text.trim(),
      zoneId: _zoneIdController.text.trim(),
      professionalDetails1: _professionalDetails1Controller.text.trim(),
      professionalDetails2: _professionalDetails2Controller.text.trim(),
    );

    ref
        .read(registrationProvider.notifier)
        .updateProfessionalDetails(professionalDetails);
  }

  /// Handle next button press - calls backend API with combined data
  Future<void> _handleNext() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Save current step
        _saveProfessionalDetails();

        // Get current state
        final state = ref.read(registrationProvider);
        if (state is! RegistrationStateInProgress) {
          throw Exception('Registration not in progress');
        }

        // Get personal details from state
        final personalDetails = state.registration.personalDetails;
        if (personalDetails == null) {
          throw Exception('Personal details not found. Please go back and fill personal information.');
        }

        // Get professional details from state
        final professionalDetails = state.registration.professionalDetails;
        if (professionalDetails == null) {
          throw Exception('Professional details not saved');
        }

        // Combine personal + professional data into MembershipDetails
        final membershipData = {
          'membership_type': personalDetails.membershipType,
          'first_name': personalDetails.firstName,
          'email': personalDetails.email,
          'password': personalDetails.password,
          'phone': personalDetails.phone,
          'wa_phone': personalDetails.waPhone,
          'date_of_birth': '${personalDetails.dateOfBirth.year}-${personalDetails.dateOfBirth.month.toString().padLeft(2, '0')}-${personalDetails.dateOfBirth.day.toString().padLeft(2, '0')}',
          'gender': personalDetails.gender,
          'blood_group': personalDetails.bloodGroup,
          'medical_council_state': professionalDetails.medicalCouncilState,
          'medical_council_no': professionalDetails.medicalCouncilNo,
          'central_council_no': professionalDetails.centralCouncilNo,
          'ug_college': professionalDetails.ugCollege,
          'zone_id': professionalDetails.zoneId,
          'professional_details1': professionalDetails.professionalDetails1,
          'professional_details2': professionalDetails.professionalDetails2,
        };

        // Call registration API
        final response = await ref
            .read(registrationProvider.notifier)
            .submitMembershipRegistration(membershipData);

        // Auto-save to Hive
        await ref.read(registrationProvider.notifier).autoSaveProgress();

        // Navigate to next step (Address) on success
        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful! Please continue with address details.'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushNamed(context, AppRouter.registrationAddress);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration failed: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
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
                totalSteps: 2,
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

                        // Medical Council State
                        DropdownField<String>(
                          labelText: 'Medical Council State',
                          prefixIcon: Icons.location_city_outlined,
                          value: _selectedMedicalCouncilState,
                          items: const [
                            DropdownMenuItem(value: 'Kerala', child: Text('Kerala')),
                            DropdownMenuItem(value: 'Karnataka', child: Text('Karnataka')),
                            DropdownMenuItem(value: 'Tamil Nadu', child: Text('Tamil Nadu')),
                            DropdownMenuItem(value: 'Maharashtra', child: Text('Maharashtra')),
                            DropdownMenuItem(value: 'Delhi', child: Text('Delhi')),
                            DropdownMenuItem(value: 'Other', child: Text('Other')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedMedicalCouncilState = value;
                            });
                            _autoSave();
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Medical council state is required';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

                        // Medical Council Number
                        TextInputField(
                          controller: _medicalCouncilNoController,
                          labelText: 'Medical Council Number',
                          prefixIcon: Icons.badge_outlined,
                          onChanged: (_) => _autoSave(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Medical council number is required';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

                        // Central Council Number
                        TextInputField(
                          controller: _centralCouncilNoController,
                          labelText: 'Central Council Number',
                          prefixIcon: Icons.confirmation_number_outlined,
                          onChanged: (_) => _autoSave(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Central council number is required';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

                        // UG College
                        TextInputField(
                          controller: _ugCollegeController,
                          labelText: 'UG College',
                          hintText: 'Your undergraduate college name',
                          prefixIcon: Icons.school_outlined,
                          onChanged: (_) => _autoSave(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'UG college is required';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

                        // Zone ID
                        TextInputField(
                          controller: _zoneIdController,
                          labelText: 'Zone ID',
                          prefixIcon: Icons.pin_outlined,
                          onChanged: (_) => _autoSave(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Zone ID is required';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

                        // Professional Details 1
                        TextInputField(
                          controller: _professionalDetails1Controller,
                          labelText: 'Professional Details 1',
                          hintText: 'Additional professional information',
                          prefixIcon: Icons.description_outlined,
                          maxLines: 3,
                          onChanged: (_) => _autoSave(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Professional details 1 is required';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

                        // Professional Details 2
                        TextInputField(
                          controller: _professionalDetails2Controller,
                          labelText: 'Professional Details 2',
                          hintText: 'Additional professional information',
                          prefixIcon: Icons.description_outlined,
                          maxLines: 3,
                          onChanged: (_) => _autoSave(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Professional details 2 is required';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 32.h),

                        // Next button (Submit to backend)
                        SizedBox(
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _handleNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1976D2),
                              disabledBackgroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 0,
                            ),
                            child: _isSubmitting
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20.w,
                                        height: 20.h,
                                        child: const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Text(
                                        'Submitting...',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Submit Registration',
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
