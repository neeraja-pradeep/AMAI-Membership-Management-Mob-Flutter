import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/auth/application/states/registration_state.dart';
import 'package:myapp/features/auth/domain/entities/registration/registration_error.dart';
import '../../../../../app/router/app_router.dart';
import '../../../application/notifiers/registration_state_notifier.dart';
import '../../../domain/entities/registration/address_details.dart';
import '../../components/registration_step_indicator.dart';
import '../../components/text_input_field.dart';

class AddressDetailsScreen extends ConsumerStatefulWidget {
  const AddressDetailsScreen({super.key});

  @override
  ConsumerState<AddressDetailsScreen> createState() =>
      _AddressDetailsScreenState();
}

class _AddressDetailsScreenState extends ConsumerState<AddressDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  /// Communication Address controllers
  late final TextEditingController _addressLine1Controller;
  late final TextEditingController _addressLine2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _postalCodeController;

  String? _selectedCountry;
  String? _selectedState;
  String? _selectedDistrict;

  /// APTA Mailing Address
  bool _useSameApta = true;
  late final TextEditingController _aptaAddress1;
  late final TextEditingController _aptaAddress2;
  late final TextEditingController _aptaCity;
  late final TextEditingController _aptaPostal;
  String? _aptaCountry;
  String? _aptaState;
  String? _aptaDistrict;

  /// Permanent Address
  bool _useSamePermanent = true;
  late final TextEditingController _permAddress1;
  late final TextEditingController _permAddress2;
  late final TextEditingController _permCity;
  late final TextEditingController _permPostal;
  String? _permCountry;
  String? _permState;
  String? _permDistrict;

  /// Role (practitioner / house_surgeon / student)
  String _role = 'practitioner';

  bool get _isPractitioner => _role == 'practitioner';

  final Map<String, List<String>> _states = {
    'India': ['Karnataka', 'Kerala', 'Tamil Nadu', 'Delhi'],
    'USA': ['California', 'Texas'],
  };

  final Map<String, List<String>> _districts = {
    'Kerala': ['Kochi', 'Trivandrum', 'Kottayam'],
    'Karnataka': ['Bangalore', 'Mysore'],
    'Tamil Nadu': ['Chennai', 'Coimbatore'],
    'Delhi': ['New Delhi', 'South Delhi'],
    'California': ['Los Angeles', 'San Diego'],
    'Texas': ['Dallas', 'Austin'],
  };

  @override
  void initState() {
    super.initState();

    /// Communication
    _addressLine1Controller = TextEditingController();
    _addressLine2Controller = TextEditingController();
    _cityController = TextEditingController();
    _postalCodeController = TextEditingController();

    /// APTA
    _aptaAddress1 = TextEditingController();
    _aptaAddress2 = TextEditingController();
    _aptaCity = TextEditingController();
    _aptaPostal = TextEditingController();

    /// Permanent
    _permAddress1 = TextEditingController();
    _permAddress2 = TextEditingController();
    _permCity = TextEditingController();
    _permPostal = TextEditingController();

    /// Read role from registration state (personalDetails.membershipType)
    final regState = ref.read(registrationProvider);
    if (regState is RegistrationStateInProgress &&
        regState.registration.personalDetails != null) {
      _role = regState.registration.personalDetails!.membershipType;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExistingData());
  }

  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();

    _aptaAddress1.dispose();
    _aptaAddress2.dispose();
    _aptaCity.dispose();
    _aptaPostal.dispose();

    _permAddress1.dispose();
    _permAddress2.dispose();
    _permCity.dispose();
    _permPostal.dispose();

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

    // refresh role from persisted registration, just in case
    if (state.registration.personalDetails != null) {
      _role = state.registration.personalDetails!.membershipType;
    }

    final data = state.registration.addressDetails;
    if (data == null) return;

    setState(() {
      _addressLine1Controller.text = data.addressLine1;
      _addressLine2Controller.text = data.addressLine2;
      _selectedCountry = data.countryId;
      _selectedState = data.stateId;
      _selectedDistrict = data.districtId;
      _cityController.text = data.city;
      _postalCodeController.text = data.postalCode;
    });
  }

  /// Auto copy logic
  void _copyCommunicationTo(
    TextEditingController a1,
    a2,
    city,
    postal,
    Function setCountry,
    setStateField,
    setDistrict,
  ) {
    a1.text = _addressLine1Controller.text;
    a2.text = _addressLine2Controller.text;
    city.text = _cityController.text;
    postal.text = _postalCodeController.text;

    setCountry(_selectedCountry);
    setStateField(_selectedState);
    setDistrict(_selectedDistrict);
  }

  void _save() {
    final notifier = ref.read(registrationProvider.notifier);

    final communication = AddressDetails(
      type: AddressType.communication,
      addressLine1: _addressLine1Controller.text.trim(),
      addressLine2: _addressLine2Controller.text.trim(),
      countryId: _selectedCountry ?? "",
      stateId: _selectedState ?? "",
      districtId: _selectedDistrict ?? "",
      city: _cityController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      isPrimary: true,
    );

    notifier.updateAddressDetails(communication);

    /// APTA details → ONLY for practitioner
    if (_isPractitioner) {
      notifier.updateAptaAddress(
        AddressDetails(
          type: AddressType.apta,
          addressLine1: _aptaAddress1.text,
          addressLine2: _aptaAddress2.text,
          city: _aptaCity.text,
          postalCode: _aptaPostal.text,
          countryId: _aptaCountry ?? "",
          stateId: _aptaState ?? "",
          districtId: _aptaDistrict ?? "",
        ),
      );
    }

    /// Permanent (for all roles)
    notifier.updatePermanentAddress(
      AddressDetails(
        type: AddressType.permanent,
        addressLine1: _permAddress1.text,
        addressLine2: _permAddress2.text,
        city: _permCity.text,
        postalCode: _permPostal.text,
        countryId: _permCountry ?? "",
        stateId: _permState ?? "",
        districtId: _permDistrict ?? "",
      ),
    );
  }

  Future<void> _handleNext() async {
    if (!_formKey.currentState!.validate()) return;

    _save(); // keep your local state sync

    try {
      await ref.read(registrationProvider.notifier).autoSaveProgress();

      final notifier = ref.read(registrationProvider.notifier);

      // Get userId from registration state
      final regStateForUserId = ref.read(registrationProvider);
      int? userId;
      if (regStateForUserId is RegistrationStateInProgress) {
        userId = regStateForUserId.registration.userId;
      }

      if (userId == null) {
        _showError("User information missing. Please try again.");
        return;
      }

      // 1️⃣ Communication address (always from main fields)
      final communicationData = {
        'address_line1': _addressLine1Controller.text.trim(),
        'address_line2': _addressLine2Controller.text.trim(),
        'city': _cityController.text.trim(),
        'postal_code': _postalCodeController.text.trim(),
        'country': _selectedCountry ?? '',
        'state': _selectedState ?? '',
        'district': _selectedDistrict ?? '',
        'type': 'communication',
        'user': userId,
      };

      // 🔁 Always submit communication
      await notifier.submitAddress(data: communicationData);

      // 2️⃣ APTA address → ONLY for practitioner
      if (_isPractitioner) {
        final aptaData = _useSameApta
            ? {
                // copy from communication but change type
                ...communicationData,
                'type': 'apta',
              }
            : {
                'address_line1': _aptaAddress1.text.trim(),
                'address_line2': _aptaAddress2.text.trim(),
                'city': _aptaCity.text.trim(),
                'postal_code': _aptaPostal.text.trim(),
                'country': _aptaCountry ?? '',
                'state': _aptaState ?? '',
                'district': _aptaDistrict ?? '',
                'type': 'apta',
                'user': userId,
              };

        await notifier.submitAddress(data: aptaData);
      }

      // 3️⃣ Permanent address (for all roles)
      final permanentData = _useSamePermanent
          ? {
              // copy from communication but change type
              ...communicationData,
              'type': 'permanent',
            }
          : {
              'address_line1': _permAddress1.text.trim(),
              'address_line2': _permAddress2.text.trim(),
              'city': _permCity.text.trim(),
              'postal_code': _permPostal.text.trim(),
              'country': _permCountry ?? '',
              'state': _permState ?? '',
              'district': _permDistrict ?? '',
              'type': 'permanent',
              'user': userId,
            };

      await notifier.submitAddress(data: permanentData);

      // 4️⃣ Read applicationId + role from registrationProvider instead of args
      final regState = ref.read(registrationProvider);
      if (regState is! RegistrationStateInProgress ||
          regState.registration.applicationId == null ||
          regState.registration.personalDetails == null) {
        _showError("Application information missing. Please try again.");
        return;
      }

      final applicationId = regState.registration.applicationId!;
      final role = regState.registration.personalDetails!.membershipType;

      if (!mounted) return;
      Navigator.pushNamed(
        context,
        AppRouter.registrationDocuments,
        arguments: {"applicationId": applicationId, "role": role},
      );
    } on RegistrationError catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError("Something went wrong. Please try again.");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  /// -------- UI --------

  Widget _buildAddressFields({
    required TextEditingController address1,
    required TextEditingController address2,
    required TextEditingController city,
    required TextEditingController postal,
    required String? country,
    required String? state,
    required String? district,
    required Function(String?) onCountryChange,
    required Function(String?) onStateChange,
    required Function(String?) onDistrictChange,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        const Text("House/No Building"),
        SizedBox(height: 10.h),
        TextInputField(controller: address1, hintText: "House No / Building Name"),

        SizedBox(height: 16.h),
        const Text("Street / Locality / Area"),
        SizedBox(height: 10.h),
        TextInputField(controller: address2, hintText: "Street, Landmark"),

        SizedBox(height: 16.h),
        const Text("Country"),
        SizedBox(height: 10.h),
        _buildDropdown(["India", "USA"], country, onCountryChange),

        SizedBox(height: 16.h),
        const Text("State"),
        SizedBox(height: 10.h),
        _buildDropdown(_states[country] ?? [], state, onStateChange),

        SizedBox(height: 16.h),
        const Text("District"),
        SizedBox(height: 10.h),
        _buildDropdown(_districts[state] ?? [], district, onDistrictChange),

        SizedBox(height: 16.h),
        const Text("City / Post Office"),
        SizedBox(height: 10.h),
        TextInputField(controller: city, hintText: "City Name"),

        SizedBox(height: 16.h),
        const Text("Postal Code"),
        SizedBox(height: 10.h),
        TextInputField(
          controller: postal,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildDropdown(
    List<String> items,
    String? value,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : null,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
      ),
      hint: const Text("Select"),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? "Required" : null,
    );
  }

  /// ---------------- CHECKBOX UI SECTION ----------------

  Widget _toggleSection(String title, bool isSame, Function(bool) toggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30.h),

        // Title
        Text(
          title,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 6.h),

        // Checkbox
        Row(
          children: [
            SizedBox(
              height: 24.h,
              width: 24.w,
              child: Checkbox(
                value: isSame,
                activeColor: AppColors.brown,
                onChanged: (v) => toggle(v ?? false),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                "Same as Communication Address",
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register Here"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RegistrationStepIndicator(
                currentStep: 3,
                stepTitle: "Address Details",
              ),

              Text(
                "Communication Address",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),

              _buildAddressFields(
                address1: _addressLine1Controller,
                address2: _addressLine2Controller,
                city: _cityController,
                postal: _postalCodeController,
                country: _selectedCountry,
                state: _selectedState,
                district: _selectedDistrict,
                onCountryChange: (v) => setState(() => _selectedCountry = v),
                onStateChange: (v) => setState(() => _selectedState = v),
                onDistrictChange: (v) => setState(() => _selectedDistrict = v),
              ),

              /// APTA MAILING → ONLY for practitioner
              if (_isPractitioner) ...[
                _toggleSection("APTA Mailing Address", _useSameApta, (v) {
                  setState(() {
                    _useSameApta = v;
                    if (v) {
                      _copyCommunicationTo(
                        _aptaAddress1,
                        _aptaAddress2,
                        _aptaCity,
                        _aptaPostal,
                        (c) => _aptaCountry = c,
                        (s) => _aptaState = s,
                        (d) => _aptaDistrict = d,
                      );
                    }
                  });
                }),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: !_useSameApta
                      ? _buildAddressFields(
                          address1: _aptaAddress1,
                          address2: _aptaAddress2,
                          city: _aptaCity,
                          postal: _aptaPostal,
                          country: _aptaCountry,
                          state: _aptaState,
                          district: _aptaDistrict,
                          onCountryChange: (v) =>
                              setState(() => _aptaCountry = v),
                          onStateChange: (v) => setState(() => _aptaState = v),
                          onDistrictChange: (v) =>
                              setState(() => _aptaDistrict = v),
                        )
                      : const SizedBox.shrink(),
                ),
              ],

              /// PERMANENT (for all roles)
              _toggleSection("Permanent Address", _useSamePermanent, (v) {
                setState(() {
                  _useSamePermanent = v;
                  if (v) {
                    _copyCommunicationTo(
                      _permAddress1,
                      _permAddress2,
                      _permCity,
                      _permPostal,
                      (c) => _permCountry = c,
                      (s) => _permState = s,
                      (d) => _permDistrict = d,
                    );
                  }
                });
              }),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: !_useSamePermanent
                    ? _buildAddressFields(
                        address1: _permAddress1,
                        address2: _permAddress2,
                        city: _permCity,
                        postal: _permPostal,
                        country: _permCountry,
                        state: _permState,
                        district: _permDistrict,
                        onCountryChange: (v) =>
                            setState(() => _permCountry = v),
                        onStateChange: (v) => setState(() => _permState = v),
                        onDistrictChange: (v) =>
                            setState(() => _permDistrict = v),
                      )
                    : const SizedBox.shrink(),
              ),

              SizedBox(height: 40.h),
              SizedBox(
                height: 50.h,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    "Next",
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
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
