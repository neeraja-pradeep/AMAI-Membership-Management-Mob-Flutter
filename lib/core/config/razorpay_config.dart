/// Razorpay configuration
///
/// IMPORTANT: Replace the placeholder values with your actual Razorpay credentials
/// For production, consider using environment variables or a secure vault
class RazorpayConfig {
  RazorpayConfig._();

  /// Razorpay API Key (Test/Live)
  /// Replace with your Razorpay Key ID from the Razorpay Dashboard
  /// Format: rzp_test_XXXXXXXXXXXX (for test mode)
  /// Format: rzp_live_XXXXXXXXXXXX (for live mode)
  static const String apiKey = 'YOUR_RAZORPAY_KEY_ID_HERE';

  /// Razorpay API Secret (Test/Live)
  /// Replace with your Razorpay Key Secret from the Razorpay Dashboard
  /// Note: Secret key should NOT be used in client-side code in production
  /// It's only used here for testing purposes
  static const String apiSecret = 'YOUR_RAZORPAY_KEY_SECRET_HERE';

  /// Company/App name shown in Razorpay checkout
  static const String companyName = 'AMAI';

  /// App description shown in Razorpay checkout
  static const String description = 'ASWAS Plus Insurance Renewal';

  /// Timeout for payment in seconds (default: 5 minutes)
  static const int timeout = 300;

  /// Theme color for Razorpay checkout (hex without #)
  static const int themeColor = 0xFF1E88E5;
}
