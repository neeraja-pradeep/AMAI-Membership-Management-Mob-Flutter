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
    'India': [
      'Andhra Pradesh',
      'Arunachal Pradesh',
      'Assam',
      'Bihar',
      'Chhattisgarh',
      'Goa',
      'Gujarat',
      'Haryana',
      'Himachal Pradesh',
      'Jharkhand',
      'Karnataka',
      'Kerala',
      'Madhya Pradesh',
      'Maharashtra',
      'Manipur',
      'Meghalaya',
      'Mizoram',
      'Nagaland',
      'Odisha',
      'Punjab',
      'Rajasthan',
      'Sikkim',
      'Tamil Nadu',
      'Telangana',
      'Tripura',
      'Uttar Pradesh',
      'Uttarakhand',
      'West Bengal',
      'Andaman and Nicobar Islands',
      'Chandigarh',
      'Dadra and Nagar Haveli and Daman and Diu',
      'Delhi',
      'Jammu and Kashmir',
      'Ladakh',
      'Lakshadweep',
      'Puducherry',
    ],
  };

  final Map<String, List<String>> _districts = {
    'Andhra Pradesh': [
      'Anantapur',
      'Chittoor',
      'East Godavari',
      'Guntur',
      'Krishna',
      'Kurnool',
      'Nellore',
      'Prakasam',
      'Srikakulam',
      'Visakhapatnam',
    ],
    'Arunachal Pradesh': [
      'Anjaw',
      'Changlang',
      'East Kameng',
      'East Siang',
      'Itanagar',
      'Lohit',
      'Lower Subansiri',
      'Papum Pare',
      'Tawang',
      'West Kameng',
    ],
    'Assam': [
      'Barpeta',
      'Bongaigaon',
      'Cachar',
      'Darrang',
      'Dibrugarh',
      'Goalpara',
      'Guwahati',
      'Jorhat',
      'Kamrup',
      'Nagaon',
    ],
    'Bihar': [
      'Araria',
      'Bhagalpur',
      'Gaya',
      'Muzaffarpur',
      'Nalanda',
      'Patna',
      'Purnia',
      'Samastipur',
      'Saran',
      'Vaishali',
    ],
    'Chhattisgarh': [
      'Bastar',
      'Bilaspur',
      'Dantewada',
      'Dhamtari',
      'Durg',
      'Janjgir-Champa',
      'Korba',
      'Raigarh',
      'Raipur',
      'Rajnandgaon',
    ],
    'Goa': [
      'North Goa',
      'South Goa',
      'Panaji',
      'Margao',
      'Vasco da Gama',
      'Mapusa',
      'Ponda',
      'Bicholim',
      'Curchorem',
      'Canacona',
    ],
    'Gujarat': [
      'Ahmedabad',
      'Amreli',
      'Anand',
      'Banaskantha',
      'Bharuch',
      'Gandhinagar',
      'Jamnagar',
      'Rajkot',
      'Surat',
      'Vadodara',
    ],
    'Haryana': [
      'Ambala',
      'Bhiwani',
      'Faridabad',
      'Gurugram',
      'Hisar',
      'Jhajjar',
      'Karnal',
      'Panipat',
      'Rohtak',
      'Sonipat',
    ],
    'Himachal Pradesh': [
      'Bilaspur',
      'Chamba',
      'Hamirpur',
      'Kangra',
      'Kinnaur',
      'Kullu',
      'Mandi',
      'Shimla',
      'Sirmaur',
      'Solan',
    ],
    'Jharkhand': [
      'Bokaro',
      'Dhanbad',
      'Dumka',
      'East Singhbhum',
      'Garhwa',
      'Giridih',
      'Hazaribagh',
      'Jamshedpur',
      'Ranchi',
      'West Singhbhum',
    ],
    'Karnataka': [
      'Bagalkot',
      'Bangalore Rural',
      'Bangalore Urban',
      'Belgaum',
      'Bellary',
      'Dakshina Kannada',
      'Dharwad',
      'Gulbarga',
      'Mysore',
      'Udupi',
    ],
    'Kerala': [
      'Alappuzha',
      'Ernakulam',
      'Idukki',
      'Kannur',
      'Kasaragod',
      'Kollam',
      'Kottayam',
      'Kozhikode',
      'Malappuram',
      'Palakkad',
      'Pathanamthitta',
      'Thiruvananthapuram',
      'Thrissur',
      'Wayanad',
    ],
    'Madhya Pradesh': [
      'Bhopal',
      'Gwalior',
      'Indore',
      'Jabalpur',
      'Katni',
      'Rewa',
      'Sagar',
      'Satna',
      'Ujjain',
      'Vidisha',
    ],
    'Maharashtra': [
      'Ahmednagar',
      'Aurangabad',
      'Kolhapur',
      'Mumbai City',
      'Mumbai Suburban',
      'Nagpur',
      'Nashik',
      'Pune',
      'Ratnagiri',
      'Thane',
    ],
    'Manipur': [
      'Bishnupur',
      'Chandel',
      'Churachandpur',
      'Imphal East',
      'Imphal West',
      'Senapati',
      'Tamenglong',
      'Thoubal',
      'Ukhrul',
      'Jiribam',
    ],
    'Meghalaya': [
      'East Garo Hills',
      'East Jaintia Hills',
      'East Khasi Hills',
      'North Garo Hills',
      'Ri Bhoi',
      'South Garo Hills',
      'South West Garo Hills',
      'South West Khasi Hills',
      'West Garo Hills',
      'West Khasi Hills',
    ],
    'Mizoram': [
      'Aizawl',
      'Champhai',
      'Kolasib',
      'Lawngtlai',
      'Lunglei',
      'Mamit',
      'Saiha',
      'Serchhip',
      'Hnahthial',
      'Khawzawl',
    ],
    'Nagaland': [
      'Dimapur',
      'Kiphire',
      'Kohima',
      'Longleng',
      'Mokokchung',
      'Mon',
      'Peren',
      'Phek',
      'Tuensang',
      'Wokha',
    ],
    'Odisha': [
      'Angul',
      'Balasore',
      'Bhubaneswar',
      'Cuttack',
      'Ganjam',
      'Jagatsinghpur',
      'Khordha',
      'Mayurbhanj',
      'Puri',
      'Sambalpur',
    ],
    'Punjab': [
      'Amritsar',
      'Barnala',
      'Bathinda',
      'Faridkot',
      'Gurdaspur',
      'Jalandhar',
      'Ludhiana',
      'Moga',
      'Patiala',
      'Sangrur',
    ],
    'Rajasthan': [
      'Ajmer',
      'Alwar',
      'Bikaner',
      'Jaipur',
      'Jodhpur',
      'Kota',
      'Nagaur',
      'Sikar',
      'Udaipur',
      'Bharatpur',
    ],
    'Sikkim': [
      'East Sikkim',
      'North Sikkim',
      'South Sikkim',
      'West Sikkim',
      'Gangtok',
      'Mangan',
      'Namchi',
      'Gyalshing',
      'Pakyong',
      'Soreng',
    ],
    'Tamil Nadu': [
      'Chennai',
      'Coimbatore',
      'Cuddalore',
      'Erode',
      'Kanchipuram',
      'Madurai',
      'Nagapattinam',
      'Salem',
      'Thanjavur',
      'Tiruchirappalli',
    ],
    'Telangana': [
      'Adilabad',
      'Hyderabad',
      'Karimnagar',
      'Khammam',
      'Mahbubnagar',
      'Medak',
      'Nalgonda',
      'Nizamabad',
      'Rangareddy',
      'Warangal',
    ],
    'Tripura': [
      'Dhalai',
      'Gomati',
      'Khowai',
      'North Tripura',
      'Sepahijala',
      'South Tripura',
      'Unakoti',
      'West Tripura',
      'Agartala',
      'Dharmanagar',
    ],
    'Uttar Pradesh': [
      'Agra',
      'Allahabad',
      'Ghaziabad',
      'Gorakhpur',
      'Kanpur',
      'Lucknow',
      'Meerut',
      'Noida',
      'Prayagraj',
      'Varanasi',
    ],
    'Uttarakhand': [
      'Almora',
      'Chamoli',
      'Dehradun',
      'Haridwar',
      'Nainital',
      'Pauri Garhwal',
      'Pithoragarh',
      'Rudraprayag',
      'Tehri Garhwal',
      'Udham Singh Nagar',
    ],
    'West Bengal': [
      'Bankura',
      'Bardhaman',
      'Darjeeling',
      'Hooghly',
      'Howrah',
      'Kolkata',
      'Malda',
      'Murshidabad',
      'Nadia',
      'North 24 Parganas',
    ],
    'Andaman and Nicobar Islands': [
      'Nicobar',
      'North and Middle Andaman',
      'South Andaman',
      'Port Blair',
      'Car Nicobar',
      'Mayabunder',
      'Diglipur',
      'Rangat',
      'Hut Bay',
      'Campbell Bay',
    ],
    'Chandigarh': [
      'Chandigarh',
      'Manimajra',
      'Mohali',
      'Panchkula',
      'Zirakpur',
      'Kharar',
      'Dera Bassi',
      'Mullanpur',
      'New Chandigarh',
      'Sector 17',
    ],
    'Dadra and Nagar Haveli and Daman and Diu': [
      'Dadra',
      'Nagar Haveli',
      'Daman',
      'Diu',
      'Silvassa',
      'Amli',
      'Khanvel',
      'Naroli',
      'Samarvarni',
      'Vapi',
    ],
    'Delhi': [
      'Central Delhi',
      'East Delhi',
      'New Delhi',
      'North Delhi',
      'North East Delhi',
      'North West Delhi',
      'Shahdara',
      'South Delhi',
      'South East Delhi',
      'South West Delhi',
      'West Delhi',
    ],
    'Jammu and Kashmir': [
      'Anantnag',
      'Baramulla',
      'Doda',
      'Jammu',
      'Kathua',
      'Pulwama',
      'Rajouri',
      'Srinagar',
      'Udhampur',
      'Kupwara',
    ],
    'Ladakh': [
      'Kargil',
      'Leh',
      'Nubra',
      'Zanskar',
      'Drass',
      'Turtuk',
      'Diskit',
      'Padum',
      'Sankoo',
      'Khaltse',
    ],
    'Lakshadweep': [
      'Agatti',
      'Amini',
      'Andrott',
      'Bangaram',
      'Bitra',
      'Chetlat',
      'Kadmat',
      'Kalpeni',
      'Kavaratti',
      'Minicoy',
    ],
    'Puducherry': [
      'Karaikal',
      'Mahe',
      'Puducherry',
      'Yanam',
      'Oulgaret',
      'Villianur',
      'Bahour',
      'Nettapakkam',
      'Mannadipet',
      'Ariyankuppam',
    ],
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
        'type': 'communications',
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
        _buildLabel("House No / Building Name"),
        SizedBox(height: 8.h),
        TextInputField(
          controller: address1,
          hintText: "Enter house no / building name",
        ),

        SizedBox(height: 16.h),
        _buildLabel("Street / Locality / Area"),
        SizedBox(height: 8.h),
        TextInputField(controller: address2, hintText: "Enter street, landmark"),

        SizedBox(height: 16.h),
        _buildLabel("Post Office"),
        SizedBox(height: 8.h),
        TextInputField(
          controller: city,
          hintText: "Enter post office",
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
          ],
        ),

        SizedBox(height: 16.h),
        _buildLabel("Post Code"),
        SizedBox(height: 8.h),
        TextInputField(
          controller: postal,
          hintText: "Enter post code",
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
        ),

        SizedBox(height: 16.h),
        _buildLabel("Country"),
        SizedBox(height: 8.h),
        _buildDropdown(["India"], country, onCountryChange, "Select Country"),

        SizedBox(height: 16.h),
        _buildLabel("State"),
        SizedBox(height: 8.h),
        _buildDropdown(_states[country] ?? [], state, onStateChange, "Select State"),

        SizedBox(height: 16.h),
        _buildLabel("District"),
        SizedBox(height: 8.h),
        _buildDropdown(_districts[state] ?? [], district, onDistrictChange, "Select District"),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required List<Widget> children,
    Widget? headerWidget,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (headerWidget != null) ...[
            SizedBox(height: 12.h),
            headerWidget,
          ],
          ...children,
        ],
      ),
    );
  }

  Widget _buildDropdown(
    List<String> items,
    String? value,
    Function(String?) onChanged,
    String hintText,
  ) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(
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
          borderSide: const BorderSide(color: AppColors.brown, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
      hint: Text(
        hintText,
        overflow: TextOverflow.ellipsis,
      ),
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(
                  e,
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? "Required" : null,
    );
  }

  /// ---------------- CHECKBOX UI SECTION ----------------

  Widget _buildCheckbox({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: value ? AppColors.brown : Colors.transparent,
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(
                color: value ? AppColors.brown : Colors.grey[400]!,
                width: 1.5,
              ),
            ),
            child: value
                ? Icon(
                    Icons.check,
                    size: 14.sp,
                    color: Colors.white,
                  )
                : null,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Register Here",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const RegistrationStepIndicator(currentStep: 3),
                  SizedBox(height: 24.h),

                  // Section 1: Communication Address
                  _buildSectionContainer(
                    title: "Communication Address",
                    children: [
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
                    ],
                  ),

                  /// Section 2: APTA MAILING → ONLY for practitioner
                  if (_isPractitioner) ...[
                    SizedBox(height: 16.h),
                    _buildSectionContainer(
                      title: "APTA Mailing Address",
                      headerWidget: _buildCheckbox(
                        label: "Same as Communication Address",
                        value: _useSameApta,
                        onChanged: (v) {
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
                        },
                      ),
                      children: [
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
                    ),
                  ],

                  // Section 3: Permanent Address (for all roles)
                  SizedBox(height: 16.h),
                  _buildSectionContainer(
                    title: "Permanent Address",
                    headerWidget: _buildCheckbox(
                      label: "Same as Communication Address",
                      value: _useSamePermanent,
                      onChanged: (v) {
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
                      },
                    ),
                    children: [
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
                    ],
                  ),

                  SizedBox(height: 32.h),

                  // Back and Next buttons
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50.h,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.brown),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100.r),
                              ),
                            ),
                            child: Text(
                              "Back",
                              style: TextStyle(
                                color: AppColors.brown,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: SizedBox(
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: _handleNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brown,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100.r),
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
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
