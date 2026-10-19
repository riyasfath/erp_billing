import 'package:flutter/foundation.dart';

import '../admin_api_client.dart';
import '../admin_endpoints.dart';
import '../admin_model/admin_order_model.dart';
import '../admin_service/admin_order_service.dart';

class AdminOrderViewModel extends ChangeNotifier {
  final AdminOrderService _service;

  AdminOrderViewModel({AdminOrderService? service}) : _service = service ?? AdminOrderService();

  bool isLoading = false;
  bool isLoadingMore = false;
  String? error;
  List<AdminOrderModel> orders = [];
  String? _nextUrl;
  bool get hasMore => _nextUrl != null;

  bool isLoadingDetail = false;
  String? detailError;
  AdminOrderModel? selectedOrder;
  bool isUpdating = false;

  Future<void> fetchOrders() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final result = await _service.getOrders(AdminEndpoints.ordersAll);
      orders = result.orders;
      _nextUrl = result.nextUrl;
      isLoading = false;
    } on AdminApiException catch (e) {
      isLoading = false;
      error = e.message;
    } catch (_) {
      isLoading = false;
      error = 'Could not load orders.';
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_nextUrl == null || isLoadingMore) return;
    isLoadingMore = true;
    notifyListeners();
    try {
      final result = await _service.getOrders(_nextUrl!);
      orders = [...orders, ...result.orders];
      _nextUrl = result.nextUrl;
    } catch (_) {
      // silent — Load More stays tappable to retry
    }
    isLoadingMore = false;
    notifyListeners();
  }

  Future<void> fetchDetail(int id) async {
    isLoadingDetail = true;
    detailError = null;
    selectedOrder = null;
    notifyListeners();
    try {
      selectedOrder = await _service.getDetail(id);
      isLoadingDetail = false;
    } on AdminApiException catch (e) {
      isLoadingDetail = false;
      detailError = e.message;
    } catch (_) {
      isLoadingDetail = false;
      detailError = 'Could not load this order.';
    }
    notifyListeners();
  }

  Future<bool> updateOrder(int id, {String? status, String? paymentStatus, String? transactionId}) async {
    isUpdating = true;
    notifyListeners();
    bool success = false;
    try {
      await _service.updateOrder(id, status: status, paymentStatus: paymentStatus, transactionId: transactionId);
      await fetchDetail(id);
      success = true;
    } on AdminApiException catch (e) {
      detailError = e.message;
    } catch (_) {
      detailError = 'Could not update this order.';
    }
    isUpdating = false;
    notifyListeners();
    return success;
  }
}