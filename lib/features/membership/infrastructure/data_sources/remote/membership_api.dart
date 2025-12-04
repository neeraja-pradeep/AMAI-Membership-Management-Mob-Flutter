import 'package:myapp/core/network/api_client.dart';
import 'package:myapp/core/network/endpoints.dart';
import 'package:myapp/features/membership/infrastructure/models/membership_payment_response_model.dart';
import 'package:myapp/features/membership/infrastructure/models/membership_status_model.dart';
import 'package:myapp/features/membership/infrastructure/models/payment_receipt_model.dart';

/// Abstract class defining the membership API contract
abstract class MembershipApi {
  /// Fetches membership status for a user
  ///
  /// [userId] - The user ID to fetch membership for
  /// [ifModifiedSince] - Optional timestamp for conditional request
  ///
  /// Returns ApiResponse with MembershipStatusModel on success,
  /// null on 304 Not Modified
  Future<ApiResponse<MembershipStatusModel?>> fetchMembershipStatus({
    String? ifModifiedSince,
  });

  /// Initiates membership payment
  ///
  /// [userId] - The user ID to initiate payment for
  ///
  /// Returns ApiResponse with MembershipPaymentResponseModel on success
  Future<ApiResponse<MembershipPaymentResponseModel?>> initiateMembershipPayment({
    required int userId,
  });

  /// Verifies membership payment after Razorpay success
  ///
  /// [razorpayOrderId] - The Razorpay order ID
  /// [razorpayPaymentId] - The Razorpay payment ID
  /// [razorpaySignature] - The Razorpay signature
  ///
  /// Returns ApiResponse with bool (true on success)
  Future<ApiResponse<bool>> verifyMembershipPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  });

  /// Fetches payment receipts/history for the authenticated user
  ///
  /// Returns ApiResponse with List<PaymentReceiptModel> on success
  Future<ApiResponse<List<PaymentReceiptModel>>> fetchPaymentReceipts();
}

/// Implementation of MembershipApi using ApiClient
class MembershipApiImpl implements MembershipApi {
  const MembershipApiImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<ApiResponse<MembershipStatusModel?>> fetchMembershipStatus({
    String? ifModifiedSince,
  }) async {
    final response = await apiClient.get<MembershipStatusModel?>(
      Endpoints.membershipMe,
      ifModifiedSince: ifModifiedSince,
      fromJson: (json) {
        if (json == null) return null;
        final data = json as Map<String, dynamic>;
        // Extract nested 'membership' object from response
        final membershipData = data['membership'] as Map<String, dynamic>?;
        if (membershipData == null) return null;
        return MembershipStatusModel.fromJson(membershipData);
      },
    );

    return response;
  }

  @override
  Future<ApiResponse<MembershipPaymentResponseModel?>> initiateMembershipPayment({
    required int userId,
  }) async {
    final response = await apiClient.post<MembershipPaymentResponseModel?>(
      Endpoints.membershipPayment,
      data: {'user': userId},
      fromJson: (json) {
        if (json == null) return null;
        final data = json as Map<String, dynamic>;
        return MembershipPaymentResponseModel.fromJson(data);
      },
    );

    return response;
  }

  @override
  Future<ApiResponse<bool>> verifyMembershipPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final response = await apiClient.post<bool>(
      Endpoints.membershipPaymentVerify,
      data: {
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
      },
      fromJson: (json) => true,
    );

    return response;
  }

  @override
  Future<ApiResponse<List<PaymentReceiptModel>>> fetchPaymentReceipts() async {
    final response = await apiClient.get<List<PaymentReceiptModel>>(
      Endpoints.paymentHistory,
      fromJson: (json) {
        if (json == null) return <PaymentReceiptModel>[];
        final list = json as List<dynamic>;
        return list
            .map((item) =>
                PaymentReceiptModel.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );

    return response;
  }
}
