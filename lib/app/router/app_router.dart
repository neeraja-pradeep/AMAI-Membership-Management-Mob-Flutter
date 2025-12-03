import 'package:flutter/material.dart';
import 'package:myapp/features/auth/presentation/screen/login_screen.dart';

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

  /// NEW: 3-step registration flow
  /// Step 1: Membership Details
  static const String registrationMembership = '/registration/membership';

  /// Step 2: Address Details
  static const String registrationAddress = '/registration/address';

  /// Step 3: Document Uploads
  static const String registrationDocuments = '/registration/documents';

  /// DEPRECATED: Old 5-step registration routes (kept for backward compatibility)
  /// Screen 1: Personal Details
  static const String registrationPersonal = '/registration/personal';

  /// Screen 2: Professional Details
  static const String registrationProfessional = '/registration/professional';

  /// Screen 4: Payment (separate from 3-step registration)
  static const String registrationPayment = '/registration/payment';

  /// Registration Success Screen
  static const String registrationSuccess = '/registration/success';

  /// Dashboard/Home routes
  static const String dashboard = '/dashboard';
  static const String home = '/home';

  // ============================================================================
  // ROUTE HELPERS
  // ============================================================================

  /// Get all registration routes (NEW 3-step flow)
  static List<String> get registrationRoutes => [
    registrationMembership,
    registrationAddress,
    registrationDocuments,
    registrationSuccess,
  ];

  /// Get route by registration step number (1-3)
  static String getRouteByStep(int stepNumber) {
    switch (stepNumber) {
      case 1:
        return registrationMembership;
      case 2:
        return registrationAddress;
      case 3:
        return registrationDocuments;
      default:
        throw ArgumentError('Invalid step number: $stepNumber');
    }
  }

  /// Get step number from route (NEW 3-step flow)
  static int getStepFromRoute(String route) {
    switch (route) {
      case registrationMembership:
        return 1;
      case registrationAddress:
        return 2;
      case registrationDocuments:
        return 3;
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
        return _buildRoute(const LoginScreen());

      case registrationAddress:
        final args = settings.arguments as Map;
        final userId = args['userId'];
        final applicationId = args['applicationId'];

        return _buildRoute(
          AddressDetailsScreen(userId: userId, applicationId: applicationId),
        );

      case AppRouter.registrationDocuments:
        final args = settings.arguments as Map<String, dynamic>;

        return _buildRoute(
          DocumentUploadScreen(
            applicationId: args['applicationId'],
            role: args['role'],
          ),
        );

      case registrationProfessional:
        return _buildRoute(const ProfessionalDetailsScreen());

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
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
        );
    }
  }

  /// Build MaterialPageRoute
  static MaterialPageRoute _buildRoute(Widget screen) {
    return MaterialPageRoute(builder: (_) => screen);
  }
}
