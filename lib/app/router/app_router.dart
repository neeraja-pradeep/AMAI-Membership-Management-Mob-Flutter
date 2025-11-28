import 'package:flutter/material.dart';

import '../../features/auth/presentation/screens/registration/personal_details_screen.dart';
import '../../features/auth/presentation/screens/registration/professional_details_screen.dart';
import '../../features/auth/presentation/screens/registration/address_details_screen.dart';
import '../../features/auth/presentation/screens/registration/document_upload_screen.dart';
import '../../features/auth/presentation/screens/registration/payment_screen.dart';
import '../../features/auth/presentation/screens/registration/registration_success_screen.dart';

/// Application router with all route definitions
///
/// Handles navigation for all features including auth and registration
class AppRouter {
  AppRouter._();

  // ============================================================================
  // ROUTE NAMES
  // ============================================================================

  /// Authentication routes
  static const String login = '/login';
  static const String register = '/register';

  /// Registration flow routes (part of auth)
  /// Screen 1: Personal Details
  static const String registrationPersonal = '/registration/personal';

  /// Screen 2: Professional Details
  static const String registrationProfessional = '/registration/professional';

  /// Screen 3: Address Details
  static const String registrationAddress = '/registration/address';

  /// Screen 4: Document Uploads
  static const String registrationDocuments = '/registration/documents';

  /// Screen 5: Payment
  static const String registrationPayment = '/registration/payment';

  /// Registration Success Screen
  static const String registrationSuccess = '/registration/success';

  /// Dashboard/Home routes
  static const String dashboard = '/dashboard';
  static const String home = '/home';

  // ============================================================================
  // ROUTE HELPERS
  // ============================================================================

  /// Get all registration routes
  static List<String> get registrationRoutes => [
        registrationPersonal,
        registrationProfessional,
        registrationAddress,
        registrationDocuments,
        registrationPayment,
        registrationSuccess,
      ];

  /// Get route by registration step number (1-5)
  static String getRouteByStep(int stepNumber) {
    switch (stepNumber) {
      case 1:
        return registrationPersonal;
      case 2:
        return registrationProfessional;
      case 3:
        return registrationAddress;
      case 4:
        return registrationDocuments;
      case 5:
        return registrationPayment;
      default:
        throw ArgumentError('Invalid step number: $stepNumber');
    }
  }

  /// Get step number from route
  static int getStepFromRoute(String route) {
    switch (route) {
      case registrationPersonal:
        return 1;
      case registrationProfessional:
        return 2;
      case registrationAddress:
        return 3;
      case registrationDocuments:
        return 4;
      case registrationPayment:
        return 5;
      default:
        throw ArgumentError('Invalid route: $route');
    }
  }

  /// Check if route is a registration route
  static bool isRegistrationRoute(String route) {
    return registrationRoutes.contains(route);
  }

  // ============================================================================
  // ROUTE GENERATION
  // ============================================================================

  /// Generate routes for MaterialApp
  ///
  /// Usage:
  /// ```dart
  /// MaterialApp(
  ///   onGenerateRoute: AppRouter.generateRoute,
  /// )
  /// ```
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth routes
      case login:
        // TODO: Import and return LoginScreen
        return _buildRoute(
          const Scaffold(body: Center(child: Text('Login Screen'))),
        );

      // Registration routes
      case registrationPersonal:
        return _buildRoute(const PersonalDetailsScreen());

      case registrationProfessional:
        return _buildRoute(const ProfessionalDetailsScreen());

      case registrationAddress:
        return _buildRoute(const AddressDetailsScreen());

      case registrationDocuments:
        return _buildRoute(const DocumentUploadScreen());

      case registrationPayment:
        return _buildRoute(const PaymentScreen());

      case registrationSuccess:
        final registrationId = settings.arguments as String?;
        return _buildRoute(
          RegistrationSuccessScreen(registrationId: registrationId),
        );

      // Dashboard route
      case dashboard:
      case home:
        // TODO: Import and return DashboardScreen
        return _buildRoute(
          const Scaffold(body: Center(child: Text('Dashboard'))),
        );

      // Unknown route
      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
    }
  }

  /// Build MaterialPageRoute
  static MaterialPageRoute _buildRoute(Widget screen) {
    return MaterialPageRoute(builder: (_) => screen);
  }
}
