import 'package:ecommerce_app/core/api_client.dart';
import 'package:ecommerce_app/core/providers.dart';
import 'package:ecommerce_app/models/payment_model.dart';

class PaymentService {
  final ApiClient _apiClient;

  PaymentService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Creates a Razorpay order for an already-placed order (the order
  /// must already exist server-side, via /api/orders/add/ or
  /// /api/orders/direct-buy/, before this is called).
  Future<RazorpayOrderModel> createRazorpayOrder(
    int orderId, {
    int fallbackAmountPaise = 0,
  }) async {
    final data = await _apiClient.post(
      ApiEndpoints.razorpayCreate(orderId.toString()),
      {
        'order_ids': [orderId],
      },
    );
    return RazorpayOrderModel.fromJson(data, fallbackAmountPaise: fallbackAmountPaise);
  }

  /// Verifies the Razorpay payment signature after the checkout sheet
  /// completes successfully.
  Future<String> verifyRazorpayPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required int orderId,
  }) async {
    final data = await _apiClient.post(ApiEndpoints.razorpayVerify, {
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_signature': razorpaySignature,
      'order_ids': [orderId],
    });
    return data['message']?.toString() ?? 'Payment verified successfully';
  }
}