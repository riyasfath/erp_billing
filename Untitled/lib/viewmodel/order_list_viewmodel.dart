import 'package:flutter/foundation.dart';

import 'package:ecommerce_app/core/api_exception.dart';
import 'package:ecommerce_app/core/view_status.dart';
import 'package:ecommerce_app/models/order_model.dart';
import 'package:ecommerce_app/service/order_service.dart';

class OrderListViewModel extends ChangeNotifier {
  final OrderService _orderService;

  OrderListViewModel({OrderService? orderService})
      : _orderService = orderService ?? OrderService();

  ViewStatus status = ViewStatus.idle;
  String? error;
  List<OrderModel> orders = [];

  String? _nextUrl;
  bool _isLoadingMore = false;

  bool get isLoading => status == ViewStatus.loading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _nextUrl != null;

  Future<void> fetchOrders() async {
    status = ViewStatus.loading;
    error = null;
    notifyListeners();

    try {
      final result = await _orderService.getOrders();
      orders = result.orders;
      _nextUrl = result.nextUrl;
      status = ViewStatus.success;
    } on ApiException catch (e) {
      status = ViewStatus.error;
      error = e.message;
    } catch (_) {
      status = ViewStatus.error;
      error = 'Something went wrong. Please try again.';
    }

    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_nextUrl == null || _isLoadingMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _orderService.getOrders(url: _nextUrl);
      orders = [...orders, ...result.orders];
      _nextUrl = result.nextUrl;
    } on ApiException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'Something went wrong loading more orders.';
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  /// Replaces one order in the list with fresher data — used after
  /// cancelling/returning so the list reflects the new status without
  /// a full refetch.
  void updateOrder(OrderModel updated) {
    orders = orders.map((o) => o.apiId == updated.apiId ? updated : o).toList();
    notifyListeners();
  }

  /// Called on logout so a new login on this device starts with no
  /// leftover orders from the previous user.
  void reset() {
    orders = [];
    status = ViewStatus.idle;
    error = null;
    _nextUrl = null;
    _isLoadingMore = false;
    notifyListeners();
  }
}