import 'package:hive/hive.dart';
import '../../../../../core/storage/hive/boxes.dart';
import '../../../../../core/storage/hive/secure_storage.dart';

/// Registration local data source (Hive layer)
///
/// FORM DATA CACHING SCENARIOS:
/// 1. User exits mid-registration → Save data + set reg_incomplete_flag = true
/// 2. User re-enters → Check flag → Show "Continue?" dialog
/// 3. Successful registration → Clear all reg_* keys + set flag = false
/// 4. Failed submission → Keep data for retry
/// 5. Cache expiry → 24 hours (prompt to start fresh)
///
/// HIVE KEYS PATTERN:
/// - reg_incomplete_flag: bool
/// - reg_current_step: int (1-5)
/// - reg_created_at: ISO 8601 timestamp
/// - reg_last_updated_at: ISO 8601 timestamp
/// - reg_personal_details: JSON
/// - reg_professional_details: JSON
/// - reg_address_details: JSON
/// - reg_document_uploads: JSON
/// - reg_payment_details: JSON
/// - reg_registration_id: String (UUID)
class RegistrationLocalDs {
  // Hive key constants
  static const String _keyIncompleteFlag = 'reg_incomplete_flag';
  static const String _keyCurrentStep = 'reg_current_step';
  static const String _keyCreatedAt = 'reg_created_at';
  static const String _keyLastUpdatedAt = 'reg_last_updated_at';
  static const String _keyPersonalDetails = 'reg_personal_details';
  static const String _keyProfessionalDetails = 'reg_professional_details';
  static const String _keyAddressDetails = 'reg_address_details';
  static const String _keyDocumentUploads = 'reg_document_uploads';
  static const String _keyPaymentDetails = 'reg_payment_details';
  static const String _keyRegistrationId = 'reg_registration_id';

  /// Check if incomplete registration exists (24-hour expiry enforced)
  Future<bool> hasIncompleteRegistration() async {
    final box = await SecureHiveStorage.openEncryptedBox(HiveBoxes.registrationBox);

    final incompleteFlag = box.get(_keyIncompleteFlag) as bool?;
    if (incompleteFlag != true) return false;

    // Check 24-hour expiry
    final createdAtStr = box.get(_keyCreatedAt) as String?;
    if (createdAtStr == null) return false;

    final createdAt = DateTime.parse(createdAtStr);
    final now = DateTime.now();
    final ageInHours = now.difference(createdAt).inHours;

    if (ageInHours > 24) {
      // Expired - clear all data
      await clearAllRegistrationData();
      return false;
    }

    return true;
  }

  /// Get current step number (1-5)
  Future<int?> getCurrentStep() async {
    final box = await SecureHiveStorage.openEncryptedBox(HiveBoxes.registrationBox);
    return box.get(_keyCurrentStep) as int?;
  }

  /// Get registration ID
  Future<String?> getRegistrationId() async {
    final box = await SecureHiveStorage.openEncryptedBox(HiveBoxes.registrationBox);
    return box.get(_keyRegistrationId) as String?;
  }

  /// Get registration timestamps
  Future<Map<String, DateTime>?> getRegistrationTimestamps() async {
    final box = await SecureHiveStorage.openEncryptedBox(HiveBoxes.registrationBox);

    final createdAtStr = box.get(_keyCreatedAt) as String?;
    final lastUpdatedAtStr = box.get(_keyLastUpdatedAt) as String?;

    if (createdAtStr == null || lastUpdatedAtStr == null) return null;

    return {
      'createdAt': DateTime.parse(createdAtStr),
      'lastUpdatedAt': DateTime.parse(lastUpdatedAtStr),
    };
  }

  /// Get personal details (Step 1)
  Future<Map<String, dynamic>?> getPersonalDetails() async {
    final box = await SecureHiveStorage.openEncryptedBox(HiveBoxes.registrationBox);
    final data = box.get(_keyPersonalDetails) as Map<dynamic, dynamic>?;

    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  /// Get professional details (Step 2)
  Future<Map<String, dynamic>?> getProfessionalDetails() async {
    final box = await SecureHiveStorage.openEncryptedBox(HiveBoxes.registrationBox);
    final data = box.get(_keyProfessionalDetails) as Map<dynamic, dynamic>?;

    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  /// Get address details (Step 3)
  Future<Map<String, dynamic>?> getAddressDetails() async {
    final box = await SecureHiveStorage.openEncryptedBox(HiveBoxes.registrationBox);
    final data = box.get(_keyAddressDetails) as Map<dynamic, dynamic>?;

    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  /// Get document uploads (Step 4)
  Future<Map<String, dynamic>?> getDocumentUploads() async {
    final box = await SecureHiveStorage.openEncryptedBox(HiveBoxes.registrationBox);
    final data = box.get(_keyDocumentUploads) as Map<dynamic, dynamic>?;

    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  /// Get payment details (Step 5)
  Future<Map<String, dynamic>?> getPaymentDetails() async {
    final box = await SecureHiveStorage.openEncryptedBox(HiveBoxes.registrationBox);
    final data = box.get(_keyPaymentDetails) as Map<dynamic, dynamic>?;

    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  /// Save registration state (on screen exit / "Next" button)
  ///
  /// SCENARIO: User exits mid-registration
  /// - Save current screen data to Hive
  /// - Set reg_incomplete_flag = true
  /// - Store reg_current_step = X
  Future<void> saveRegistrationState({
    required String registrationId,
    required int currentStep,
    required DateTime createdAt,
    Map<String, dynamic>? personalDetails,
    Map<String, dynamic>? professionalDetails,
    Map<String, dynamic>? addressDetails,
    Map<String, dynamic>? documentUploads,
    Map<String, dynamic>? paymentDetails,
  }) async {
    final box = await SecureHiveStorage.openEncryptedBox(HiveBoxes.registrationBox);

    // Set incomplete flag
    await box.put(_keyIncompleteFlag, true);

    // Store current step
    await box.put(_keyCurrentStep, currentStep);

    // Store timestamps
    await box.put(_keyCreatedAt, createdAt.toIso8601String());
    await box.put(_keyLastUpdatedAt, DateTime.now().toIso8601String());

    // Store registration ID
    await box.put(_keyRegistrationId, registrationId);

    // Store step data (only if provided)
    if (personalDetails != null) {
      await box.put(_keyPersonalDetails, personalDetails);
    }
    if (professionalDetails != null) {
      await box.put(_keyProfessionalDetails, professionalDetails);
    }
    if (addressDetails != null) {
      await box.put(_keyAddressDetails, addressDetails);
    }
    if (documentUploads != null) {
      await box.put(_keyDocumentUploads, documentUploads);
    }
    if (paymentDetails != null) {
      await box.put(_keyPaymentDetails, paymentDetails);
    }
  }

  /// Clear all registration data
  ///
  /// SCENARIO 1: Successful registration
  /// SCENARIO 2: User chooses "Start Fresh" on resume dialog
  /// SCENARIO 3: Cache expired (>24 hours)
  Future<void> clearAllRegistrationData() async {
    final box = await SecureHiveStorage.openEncryptedBox(HiveBoxes.registrationBox);

    await box.delete(_keyIncompleteFlag);
    await box.delete(_keyCurrentStep);
    await box.delete(_keyCreatedAt);
    await box.delete(_keyLastUpdatedAt);
    await box.delete(_keyPersonalDetails);
    await box.delete(_keyProfessionalDetails);
    await box.delete(_keyAddressDetails);
    await box.delete(_keyDocumentUploads);
    await box.delete(_keyPaymentDetails);
    await box.delete(_keyRegistrationId);
  }

  /// Set incomplete flag to false (keep data for retry)
  ///
  /// SCENARIO: Failed submission
  /// - Keep all form data in Hive
  /// - User can retry without re-entering data
  Future<void> markSubmissionFailed() async {
    final box = await SecureHiveStorage.openEncryptedBox(HiveBoxes.registrationBox);

    // Keep flag as true but update timestamp
    await box.put(_keyLastUpdatedAt, DateTime.now().toIso8601String());
  }

  /// Clear incomplete flag (successful registration)
  ///
  /// SCENARIO: Successful registration
  /// - Clear all reg_* keys from Hive
  /// - Set reg_incomplete_flag = false
  Future<void> markRegistrationComplete() async {
    await clearAllRegistrationData();

    final box = await SecureHiveStorage.openEncryptedBox(HiveBoxes.registrationBox);
    await box.put(_keyIncompleteFlag, false);
  }

  /// Get cache age in hours
  Future<int?> getCacheAgeInHours() async {
    final box = await SecureHiveStorage.openEncryptedBox(HiveBoxes.registrationBox);

    final createdAtStr = box.get(_keyCreatedAt) as String?;
    if (createdAtStr == null) return null;

    final createdAt = DateTime.parse(createdAtStr);
    final now = DateTime.now();
    return now.difference(createdAt).inHours;
  }

  /// Check if cache is stale (>24 hours)
  Future<bool> isCacheStale() async {
    final ageInHours = await getCacheAgeInHours();
    if (ageInHours == null) return false;

    return ageInHours > 24;
  }
}
