import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/features/auth/application/states/registration_state.dart';

import '../../../../../app/router/app_router.dart';
import '../../../application/notifiers/registration_state_notifier.dart';
import '../../../domain/entities/registration/address_details.dart';
import '../../components/dropdown_field.dart';
import '../../components/step_progress_indicator.dart';
import '../../components/text_input_field.dart';

/// Address Details Screen (Step 3)
///
/// Collects practitioner's address information with dependent dropdowns:
/// - Address Line 1
/// - Address Line 2 (optional)
/// - Country → State → District (dependent hierarchy)
/// - City
/// - Pincode
///
/// CRITICAL REQUIREMENT: Dependent Dropdown Validation
/// - State selection requires valid Country
/// - District selection requires valid State
/// - When Country changes, clear State + District
/// - When State changes, clear District
class AddressDetailsScreen extends ConsumerStatefulWidget {
  const AddressDetailsScreen({super.key});

  @override
  ConsumerState<AddressDetailsScreen> createState() =>
      _AddressDetailsScreenState();
}

class _AddressDetailsScreenState extends ConsumerState<AddressDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _addressLine1Controller;
  late final TextEditingController _addressLine2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _pincodeController;

  // Dependent dropdown state
  String? _selectedCountry;
  String? _selectedState;
  String? _selectedDistrict;

  // Mock data for dropdowns (TODO: Replace with API data)
  final Map<String, List<String>> _states = {
    'India': ['Karnataka', 'Maharashtra', 'Tamil Nadu', 'Delhi'],
    'USA': ['California', 'New York', 'Texas'],
  };

  final Map<String, List<String>> _districts = {
    'Karnataka': ['Bangalore', 'Mysore', 'Mangalore'],
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur'],
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai'],
    'Delhi': ['Central Delhi', 'North Delhi', 'South Delhi'],
    'California': ['Los Angeles', 'San Francisco', 'San Diego'],
    'New York': ['New York City', 'Buffalo', 'Rochester'],
    'Texas': ['Houston', 'Dallas', 'Austin'],
  };

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _addressLine1Controller = TextEditingController();
    _addressLine2Controller = TextEditingController();
    _cityController = TextEditingController();
    _pincodeController = TextEditingController();

    // Load existing data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
  }

  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _loadExistingData() {
    final state = ref.read(registrationProvider);

    // Only RegistrationStateInProgress has registration data
    if (state is RegistrationStateInProgress) {
      final addressDetails = state.registration.addressDetails;

      if (addressDetails != null) {
        _addressLine1Controller.text = addressDetails.addressLine1;
        _addressLine2Controller.text = addressDetails.addressLine2 ?? '';
        _selectedCountry = addressDetails.countryId;
        _selectedState = addressDetails.stateId;
        _selectedDistrict = addressDetails.districtId;
        _cityController.text = addressDetails.city;
        _pincodeController.text = addressDetails.pincode;
      }
    }
  }

  /// Auto-save progress on field changes
  void _autoSave() {
    // Save without validation - validation only happens on "Next" button
    _saveAddressDetails();
  }

  /// Save address details to registration state
  void _saveAddressDetails() {
    final addressDetails = AddressDetails(
      addressLine1: _addressLine1Controller.text.trim(),
      addressLine2: _addressLine2Controller.text.trim().isNotEmpty
          ? _addressLine2Controller.text.trim()
          : null,
      countryId: _selectedCountry ?? '',
      stateId: _selectedState ?? '',
      districtId: _selectedDistrict ?? '',
      city: _cityController.text.trim(),
      pincode: _pincodeController.text.trim(),
    );

    ref
        .read(registrationProvider.notifier)
        .updateAddressDetails(addressDetails);
  }

  /// Handle country change - clear dependent dropdowns
  void _handleCountryChange(String? country) {
    setState(() {
      _selectedCountry = country;
      // CRITICAL: Clear dependent fields when parent changes
      _selectedState = null;
      _selectedDistrict = null;
    });
    _autoSave();
  }

  /// Handle state change - clear dependent dropdowns
  void _handleStateChange(String? state) {
    setState(() {
      _selectedState = state;
      // CRITICAL: Clear dependent fields when parent changes
      _selectedDistrict = null;
    });
    _autoSave();
  }

  /// Handle district change
  void _handleDistrictChange(String? district) {
    setState(() {
      _selectedDistrict = district;
    });
    _autoSave();
  }

  /// Get available states based on selected country
  List<DropdownMenuItem<String>> _getAvailableStates() {
    if (_selectedCountry == null) return [];

    final states = _states[_selectedCountry] ?? [];
    return states
        .map((state) => DropdownMenuItem(value: state, child: Text(state)))
        .toList();
  }

  /// Get available districts based on selected state
  List<DropdownMenuItem<String>> _getAvailableDistricts() {
    if (_selectedState == null) return [];

    final districts = _districts[_selectedState] ?? [];
    return districts
        .map(
          (district) =>
              DropdownMenuItem(value: district, child: Text(district)),
        )
        .toList();
  }

  /// Handle next button press
  Future<void> _handleNext() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Save current step
      _saveAddressDetails();

      // Auto-save to Hive
      await ref.read(registrationProvider.notifier).autoSaveProgress();

      // Navigate to next step
      if (mounted) {
        Navigator.pushNamed(context, AppRouter.registrationDocuments);
      }
    }
  }

  /// Handle back button press
  void _handleBack() {
    _saveAddressDetails();
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
                currentStep: 3,
                totalSteps: 5,
                stepTitle: 'Address Details',
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
                          'Your Address',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Please provide your residential address',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),

                        SizedBox(height: 32.h),

                        // Address Line 1
                        TextInputField(
                          controller: _addressLine1Controller,
                          labelText: 'Address Line 1',
                          hintText: 'Building name, street name',
                          prefixIcon: Icons.home_outlined,
                          maxLines: 2,
                          onChanged: (_) => _autoSave(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Address is required';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

                        // Address Line 2 (optional)
                        TextInputField(
                          controller: _addressLine2Controller,
                          labelText: 'Address Line 2 (Optional)',
                          hintText: 'Landmark, area',
                          prefixIcon: Icons.location_on_outlined,
                          maxLines: 2,
                          onChanged: (_) => _autoSave(),
                        ),

                        SizedBox(height: 16.h),

                        // Country (parent dropdown)
                        DropdownField<String>(
                          labelText: 'Country',
                          prefixIcon: Icons.public_outlined,
                          value: _selectedCountry,
                          items: const [
                            DropdownMenuItem(
                              value: 'India',
                              child: Text('India'),
                            ),
                            DropdownMenuItem(
                              value: 'USA',
                              child: Text('United States'),
                            ),
                          ],
                          onChanged: _handleCountryChange,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Country is required';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

                        // State (depends on country)
                        DropdownField<String>(
                          labelText: 'State',
                          prefixIcon: Icons.map_outlined,
                          value: _selectedState,
                          items: _getAvailableStates(),
                          enabled: _selectedCountry != null,
                          onChanged: _handleStateChange,
                          validator: (value) {
                            if (_selectedCountry == null) {
                              return 'Please select a country first';
                            }
                            if (value == null || value.isEmpty) {
                              return 'State is required';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

                        // District (depends on state)
                        DropdownField<String>(
                          labelText: 'District',
                          prefixIcon: Icons.location_city_outlined,
                          value: _selectedDistrict,
                          items: _getAvailableDistricts(),
                          enabled: _selectedState != null,
                          onChanged: _handleDistrictChange,
                          validator: (value) {
                            if (_selectedState == null) {
                              return 'Please select a state first';
                            }
                            if (value == null || value.isEmpty) {
                              return 'District is required';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

                        // City
                        TextInputField(
                          controller: _cityController,
                          labelText: 'City',
                          prefixIcon: Icons.location_city,
                          onChanged: (_) => _autoSave(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'City is required';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

                        // Pincode
                        TextInputField(
                          controller: _pincodeController,
                          labelText: 'Pincode',
                          hintText: '6-digit pincode',
                          prefixIcon: Icons.markunread_mailbox_outlined,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (_) => _autoSave(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Pincode is required';
                            }
                            if (value.trim().length != 6) {
                              return 'Pincode must be 6 digits';
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
