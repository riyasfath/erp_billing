import 'package:flutter/foundation.dart';

import 'package:ecommerce_app/core/api_exception.dart';
import 'package:ecommerce_app/core/view_status.dart';
import 'package:ecommerce_app/models/order_model.dart';
import 'package:ecommerce_app/service/order_service.dart';

class OrderDetailViewModel extends ChangeNotifier {
  final OrderService _orderService;

  OrderDetailViewModel({OrderService? orderService})
      : _orderService = orderService ?? OrderService();

  ViewStatus status = ViewStatus.idle;
  String? error;
  OrderModel? order;

  bool isCancelling = false;
  String? cancelError;

  bool isReturning = false;
  String? returnError;

  bool isCancellingReturn = false;
  String? cancelReturnError;

  bool get isLoading => status == ViewStatus.loading;

  /// Call with an order already in hand (e.g. from the list screen) so
  /// the detail page has something to show instantly, before an
  /// optional refresh.
  void seed(OrderModel initial) {
    order = initial;
    status = ViewStatus.success;
    notifyListeners();
  }

  Future<void> fetchOrder(String id) async {
    status = ViewStatus.loading;
    error = null;
    notifyListeners();

    try {
      order = await _orderService.getOrderDetail(id);
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

  Future<bool> cancelOrder({required String reason, required String details}) async {
    if (order == null) return false;
    isCancelling = true;
    cancelError = null;
    notifyListeners();

    try {
      await _orderService.cancelOrder(order!.apiId.toString(), reason: reason, details: details);
      // Backend doesn't return the updated order from /cancel/, so
      // refetch to get the real status/cancelled_at/etc.
      order = await _orderService.getOrderDetail(order!.apiId.toString());
      isCancelling = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      isCancelling = false;
      cancelError = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      isCancelling = false;
      cancelError = 'Could not cancel this order. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> returnOrder(List<ReturnItemRequest> items) async {
    if (order == null) return false;
    isReturning = true;
    returnError = null;
    notifyListeners();

    try {
      await _orderService.returnOrder(order!.apiId.toString(), items);
      order = await _orderService.getOrderDetail(order!.apiId.toString());
      isReturning = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      isReturning = false;
      returnError = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      isReturning = false;
      returnError = 'Could not submit the return. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelReturn(String returnId) async {
    if (order == null) return false;
    isCancellingReturn = true;
    cancelReturnError = null;
    notifyListeners();

    try {
      await _orderService.cancelReturn(returnId);
      order = await _orderService.getOrderDetail(order!.apiId.toString());
      isCancellingReturn = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      isCancellingReturn = false;
      cancelReturnError = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      isCancellingReturn = false;
      cancelReturnError = 'Could not cancel the return. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Called on logout so a new login on this device starts with no
  /// leftover order-detail state from the previous user.
  void reset() {
    order = null;
    status = ViewStatus.idle;
    error = null;
    isCancelling = false;
    cancelError = null;
    isReturning = false;
    returnError = null;
    isCancellingReturn = false;
    cancelReturnError = null;
    notifyListeners();
  }
}