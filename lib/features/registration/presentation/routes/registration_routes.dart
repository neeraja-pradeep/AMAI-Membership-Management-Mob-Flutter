/// Registration module route names
///
/// All registration screens use these route constants for navigation
class RegistrationRoutes {
  RegistrationRoutes._();

  /// Registration Screen 1: Personal Details
  static const String personal = '/registration/personal';

  /// Registration Screen 2: Professional Details
  static const String professional = '/registration/professional';

  /// Registration Screen 3: Address Details
  static const String address = '/registration/address';

  /// Registration Screen 4: Document Uploads
  static const String documents = '/registration/documents';

  /// Registration Screen 5: Payment
  static const String payment = '/registration/payment';

  /// Registration Success Screen
  static const String success = '/registration/success';

  /// Get all registration routes
  static List<String> get allRoutes => [
        personal,
        professional,
        address,
        documents,
        payment,
        success,
      ];

  /// Get route by step number (1-5)
  static String getRouteByStep(int stepNumber) {
    switch (stepNumber) {
      case 1:
        return personal;
      case 2:
        return professional;
      case 3:
        return address;
      case 4:
        return documents;
      case 5:
        return payment;
      default:
        throw ArgumentError('Invalid step number: $stepNumber');
    }
  }

  /// Get step number from route
  static int getStepFromRoute(String route) {
    switch (route) {
      case personal:
        return 1;
      case professional:
        return 2;
      case address:
        return 3;
      case documents:
        return 4;
      case payment:
        return 5;
      default:
        throw ArgumentError('Invalid route: $route');
    }
  }

  /// Check if route is a registration route
  static bool isRegistrationRoute(String route) {
    return allRoutes.contains(route);
  }
}
