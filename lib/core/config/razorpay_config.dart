import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Razorpay configuration
///
/// Reads credentials from .env file
/// Create a .env file in the project root with:
/// RAZORPAY_KEY_ID=your_key_id_here
/// RAZORPAY_KEY_SECRET=your_key_secret_here
class RazorpayConfig {
  RazorpayConfig._();

  /// Razorpay API Key (Test/Live)
  /// Reads from RAZORPAY_KEY_ID in .env file
  static String get apiKey => dotenv.env['RAZORPAY_KEY_ID'] ?? '';

  /// Razorpay API Secret (Test/Live)
  /// Reads from RAZORPAY_KEY_SECRET in .env file
  /// Note: Secret key should NOT be used in client-side code in production
  static String get apiSecret => dotenv.env['RAZORPAY_KEY_SECRET'] ?? '';

  /// Company/App name shown in Razorpay checkout
  static const String companyName = 'AMAI';

  /// App description shown in Razorpay checkout
  static const String description = 'ASWAS Plus Insurance Renewal';

  /// Timeout for payment in seconds (default: 5 minutes)
  static const int timeout = 300;

  /// Theme color for Razorpay checkout (hex without #)
  static const int themeColor = 0xFF1E88E5;
}
