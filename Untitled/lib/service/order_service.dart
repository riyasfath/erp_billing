import 'package:ecommerce_app/core/api_client.dart';
import 'package:ecommerce_app/core/providers.dart';
import 'package:ecommerce_app/models/order_model.dart';

class OrderService {
  final ApiClient _apiClient;

  OrderService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Places an order from whatever's currently in the cart.
  Future<OrderModel> placeOrderFromCart({
    required String deliveryMethod,
    required String paymentMethod,
  }) async {
    final data = await _apiClient.post(ApiEndpoints.orderAdd, {
      'delivery_method': deliveryMethod,
      'payment_method': paymentMethod,
    });
    return OrderModel.fromJson(data);
  }

  /// Buys a single product immediately, bypassing the cart.
  Future<OrderModel> directBuy(DirectBuyModel model) async {
    final data = await _apiClient.post(ApiEndpoints.orderDirectBuy, model.toJson());
    return OrderModel.fromJson(data);
  }

  Future<OrderListResult> getOrders({String? url}) async {
    final data = await _apiClient.get(url ?? ApiEndpoints.orders);
    final List<dynamic> resultsJson = (data['results'] as List?) ?? [];
    final int count = data['count'] is int
        ? data['count'] as int
        : int.tryParse(data['count']?.toString() ?? '') ?? resultsJson.length;

    return OrderListResult(
      orders: resultsJson.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList(),
      nextUrl: data['next']?.toString(),
      count: count,
    );
  }

  Future<OrderModel> getOrderDetail(String id) async {
    final data = await _apiClient.get(ApiEndpoints.orderDetail(id));
    return OrderModel.fromJson(data);
  }

  Future<String> cancelOrder(String id, {required String reason, required String details}) async {
    final data = await _apiClient.post(ApiEndpoints.orderCancel(id), {
      'reason': reason,
      'details': details,
    });
    return data['message']?.toString() ?? 'Order cancelled successfully';
  }

  Future<String> returnOrder(String id, List<ReturnItemRequest> items) async {
    final data = await _apiClient.post(ApiEndpoints.orderReturn(id), {
      'items': items.map((e) => e.toJson()).toList(),
    });
    return data['message']?.toString() ?? 'Return request submitted successfully';
  }

  Future<String> cancelReturn(String returnId) async {
    final data = await _apiClient.post(ApiEndpoints.cancelReturn(returnId), {});
    return data['message']?.toString() ?? 'Return cancelled successfully';
  }
}