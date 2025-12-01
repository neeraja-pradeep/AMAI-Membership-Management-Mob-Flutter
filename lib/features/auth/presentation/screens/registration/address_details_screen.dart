import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/auth/application/states/registration_state.dart';
import '../../../../../app/router/app_router.dart';
import '../../../application/notifiers/registration_state_notifier.dart';
import '../../../domain/entities/registration/address_details.dart';
import '../../components/text_input_field.dart';

class AddressDetailsScreen extends ConsumerStatefulWidget {
  final int userId;
  const AddressDetailsScreen({super.key, required this.userId});

  @override
  ConsumerState<AddressDetailsScreen> createState() =>
      _AddressDetailsScreenState();
}

class _AddressDetailsScreenState extends ConsumerState<AddressDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _addressLine1Controller;
  late final TextEditingController _addressLine2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _postalCodeController;

  String? _selectedCountry;
  String? _selectedState;
  String? _selectedDistrict;

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
    _addressLine1Controller = TextEditingController();
    _addressLine2Controller = TextEditingController();
    _cityController = TextEditingController();
    _postalCodeController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExistingData());
  }

  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  void _loadExistingData() {
    final state = ref.read(registrationProvider);

    if (state is RegistrationStateResumePrompt) {
      ref
          .read(registrationProvider.notifier)
          .resumeRegistration(state.existingRegistration);
      Future.microtask(() => _loadExistingData());
      return;
    }

    if (state is! RegistrationStateInProgress) return;

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

  void _save() {
    final data = AddressDetails(
      addressLine1: _addressLine1Controller.text.trim(),
      addressLine2: _addressLine2Controller.text.trim(),
      countryId: _selectedCountry ?? "",
      stateId: _selectedState ?? "",
      districtId: _selectedDistrict ?? "",
      city: _cityController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      isPrimary: true,
    );
    ref.read(registrationProvider.notifier).updateAddressDetails(data);
  }

  Future<void> _handleNext() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref.read(registrationProvider.notifier).autoSaveProgress();

    try {
      _save();
      final state = ref.read(registrationProvider);

      final addressData = {
        'user': widget.userId, // <-- from previous screen
        'address_line1': _addressLine1Controller.text.trim(),
        'address_line2': _addressLine2Controller.text.trim(),
        'country': _selectedCountry,
        'state': _selectedState,
        'district': _selectedDistrict,
        'city': _cityController.text.trim(),
        'postal_code': _postalCodeController.text.trim(),
        'is_primary': true,
      };

      final responseData = await ref
          .read(registrationProvider.notifier)
          .submitAddress(data: addressData);
      debugPrint(responseData.toString());
      await ref.read(registrationProvider.notifier).autoSaveProgress();

      final addressId = responseData['id'];

      if (addressId == null) {
        _showError('Backend Registration Failed');
        return;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration saved. Continue with Document details."),
          backgroundColor: Colors.green,
        ),
      );

      if (mounted)
        Navigator.pushNamed(context, AppRouter.registrationDocuments);
    } catch (e) {
      if (mounted) _showError("Registration failed: ${e.toString()}");
    } finally {
      // if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Register Here",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
              SizedBox(height: 10.h),
              Center(
                child: Text(
                  "Step 3 of 4",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: 20.h),
              Text(
                "Address Details",
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 25.h),

              // Address Line 1
              _buildLabel("Address Line 1"),
              SizedBox(height: 6.h),
              TextInputField(
                controller: _addressLine1Controller,
                hintText: "Building, House No",
                validator: (v) => v!.trim().isEmpty ? "Required" : null,
              ),

              SizedBox(height: 18.h),
              _buildLabel("Address Line 2"),
              SizedBox(height: 6.h),
              TextInputField(
                controller: _addressLine2Controller,
                hintText: "Street, Locality",
                validator: (v) => v!.trim().isEmpty ? "Required" : null,
              ),

              SizedBox(height: 18.h),
              _buildLabel("Country"),
              SizedBox(height: 6.h),
              _buildDropdown(["India", "USA"], _selectedCountry, (val) {
                setState(() {
                  _selectedCountry = val;
                  _selectedState = null;
                  _selectedDistrict = null;
                });
                _save();
              }),

              SizedBox(height: 18.h),
              _buildLabel("State"),
              SizedBox(height: 6.h),
              _buildDropdown(_states[_selectedCountry] ?? [], _selectedState, (
                val,
              ) {
                setState(() {
                  _selectedState = val;
                  _selectedDistrict = null;
                });
                _save();
              }),

              SizedBox(height: 18.h),
              _buildLabel("District"),
              SizedBox(height: 6.h),
              _buildDropdown(
                _districts[_selectedState] ?? [],
                _selectedDistrict,
                (val) {
                  setState(() => _selectedDistrict = val);
                  _save();
                },
              ),

              SizedBox(height: 18.h),
              _buildLabel("City / Post Office"),
              SizedBox(height: 6.h),
              TextInputField(
                controller: _cityController,
                hintText: "City, PO Name",
                validator: (v) => v!.trim().isEmpty ? "Required" : null,
              ),

              SizedBox(height: 18.h),
              _buildLabel("Postal Code"),
              SizedBox(height: 6.h),
              TextInputField(
                controller: _postalCodeController,
                hintText: "6-digit postal code",
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.isEmpty) return "Required";
                  if (v.trim().length != 6)
                    return "Postal code must be 6 digits";
                  return null;
                },
              ),

              SizedBox(height: 40.h),
              _buildNextButton(),
            ],
          ),
        ),
      ),
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
    if (value != null && !items.contains(value)) value = null;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: DropdownButtonFormField(
        value: value,
        decoration: const InputDecoration(border: InputBorder.none),
        hint: const Text("Select"),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        validator: (v) => v == null ? "Required" : null,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
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
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
