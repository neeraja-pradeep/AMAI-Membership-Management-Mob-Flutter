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

/// Professional Details Screen (Step 2 of 5)
///
/// Collects practitioner's professional credentials:
/// - Medical Council State
/// - Medical Council Number
/// - Central Council Number
/// - UG College
/// - Professional Details 1 (Qualifications - checkboxes)
/// - Professional Details 2 (Professional Category - checkboxes)
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

  // State
  String? _selectedMedicalCouncilState;
  bool _isSubmitting = false;

  // Professional Details 1 - Qualifications (checkboxes)
  final Set<String> _selectedQualifications = {};
  static const List<String> _qualificationOptions = [
    'UG',
    'PG',
    'PhD',
    'CCRAS',
    'PG Diploma',
    'Other',
  ];

  // Professional Details 2 - Professional Category (checkboxes)
  final Set<String> _selectedCategories = {};
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

    // Initialize controllers
    _medicalCouncilNoController = TextEditingController();
    _centralCouncilNoController = TextEditingController();
    _ugCollegeController = TextEditingController();

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

        // Parse professionalDetails1 (comma-separated string) into checkbox selections
        if (professionalDetails.professionalDetails1.isNotEmpty) {
          _selectedQualifications.clear();
          _selectedQualifications.addAll(
            professionalDetails.professionalDetails1.split(',').map((e) => e.trim()),
          );
        }

        // Parse professionalDetails2 (comma-separated string) into checkbox selections
        if (professionalDetails.professionalDetails2.isNotEmpty) {
          _selectedCategories.clear();
          _selectedCategories.addAll(
            professionalDetails.professionalDetails2.split(',').map((e) => e.trim()),
          );
        }
      });
      _medicalCouncilNoController.text = professionalDetails.medicalCouncilNo;
      _centralCouncilNoController.text = professionalDetails.centralCouncilNo;
      _ugCollegeController.text = professionalDetails.ugCollege;
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
      zoneId: '', // Removed - no longer collected
      professionalDetails1: _selectedQualifications.join(', '), // Convert checkboxes to comma-separated string
      professionalDetails2: _selectedCategories.join(', '), // Convert checkboxes to comma-separated string
    );

    ref
        .read(registrationProvider.notifier)
        .updateProfessionalDetails(professionalDetails);
  }

  /// Handle next button press - calls backend API with combined data
  Future<void> _handleNext() async {
    // Validate form fields
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Validate qualifications checkbox selection
    if (_selectedQualifications.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one qualification'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Validate professional category checkbox selection
    if (_selectedCategories.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one professional category'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

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

                        SizedBox(height: 24.h),

                        // Qualifications (Professional Details 1) - Checkboxes
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.school_outlined, size: 20.sp, color: const Color(0xFF1976D2)),
                                SizedBox(width: 8.w),
                                Text(
                                  'Qualifications',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  ' *',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: _qualificationOptions.map((qualification) {
                                return FilterChip(
                                  label: Text(qualification),
                                  selected: _selectedQualifications.contains(qualification),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedQualifications.add(qualification);
                                      } else {
                                        _selectedQualifications.remove(qualification);
                                      }
                                    });
                                    _autoSave();
                                  },
                                  backgroundColor: Colors.grey[100],
                                  selectedColor: const Color(0xFF1976D2).withOpacity(0.2),
                                  checkmarkColor: const Color(0xFF1976D2),
                                  labelStyle: TextStyle(
                                    fontSize: 14.sp,
                                    color: _selectedQualifications.contains(qualification)
                                        ? const Color(0xFF1976D2)
                                        : Colors.black87,
                                  ),
                                );
                              }).toList(),
                            ),
                            if (_selectedQualifications.isEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 8.h, left: 12.w),
                                child: Text(
                                  'Please select at least one qualification',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                          ],
                        ),

                        SizedBox(height: 24.h),

                        // Professional Category (Professional Details 2) - Checkboxes
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.work_outline, size: 20.sp, color: const Color(0xFF1976D2)),
                                SizedBox(width: 8.w),
                                Text(
                                  'Professional Category',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  ' *',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: _categoryOptions.map((category) {
                                return FilterChip(
                                  label: Text(category),
                                  selected: _selectedCategories.contains(category),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedCategories.add(category);
                                      } else {
                                        _selectedCategories.remove(category);
                                      }
                                    });
                                    _autoSave();
                                  },
                                  backgroundColor: Colors.grey[100],
                                  selectedColor: const Color(0xFF1976D2).withOpacity(0.2),
                                  checkmarkColor: const Color(0xFF1976D2),
                                  labelStyle: TextStyle(
                                    fontSize: 14.sp,
                                    color: _selectedCategories.contains(category)
                                        ? const Color(0xFF1976D2)
                                        : Colors.black87,
                                  ),
                                );
                              }).toList(),
                            ),
                            if (_selectedCategories.isEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 8.h, left: 12.w),
                                child: Text(
                                  'Please select at least one professional category',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                          ],
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
