// import 'package:flutter/foundation.dart';

import 'package:ecommerce_app/core/api_exception.dart';
import 'package:ecommerce_app/core/view_status.dart';
import 'package:ecommerce_app/models/order_model.dart';
import 'package:ecommerce_app/models/payment_model.dart';
import 'package:ecommerce_app/service/order_service.dart';
import 'package:ecommerce_app/service/payment_service.dart';
import 'package:flutter/material.dart';

/// ViewModel for creating an order — either from the cart
/// (POST /api/orders/add/) or a single-product "Buy Now"
/// (POST /api/orders/direct-buy/) — plus the Razorpay online-payment
/// flow (create Razorpay order -> checkout sheet -> verify signature).
class PlaceOrderViewModel extends ChangeNotifier {
  final OrderService _orderService;
  final PaymentService _paymentService;

  PlaceOrderViewModel({OrderService? orderService, PaymentService? paymentService})
      : _orderService = orderService ?? OrderService(),
        _paymentService = paymentService ?? PaymentService();

  ViewStatus placeFromCartStatus = ViewStatus.idle;
  String? placeFromCartError;
  OrderModel? lastOrder;

  ViewStatus directBuyStatus = ViewStatus.idle;
  String? directBuyError;

  // --- Razorpay: create order (step after the base order is placed) ---
  ViewStatus razorpayCreateStatus = ViewStatus.idle;
  String? razorpayCreateError;
  RazorpayOrderModel? razorpayOrder;

  // --- Razorpay: verify payment signature (after checkout sheet closes) ---
  ViewStatus razorpayVerifyStatus = ViewStatus.idle;
  String? razorpayVerifyError;

  bool get isPlacingFromCart => placeFromCartStatus == ViewStatus.loading;
  bool get isDirectBuying => directBuyStatus == ViewStatus.loading;
  bool get isCreatingRazorpayOrder => razorpayCreateStatus == ViewStatus.loading;
  bool get isVerifyingRazorpayPayment => razorpayVerifyStatus == ViewStatus.loading;

  Future<bool> placeOrderFromCart({
    required String deliveryMethod,
    required String paymentMethod,
  }) async {
    placeFromCartStatus = ViewStatus.loading;
    placeFromCartError = null;
    notifyListeners();

    try {
      lastOrder = await _orderService.placeOrderFromCart(
        deliveryMethod: deliveryMethod,
        paymentMethod: paymentMethod,
      );
      placeFromCartStatus = ViewStatus.success;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      placeFromCartStatus = ViewStatus.error;
      placeFromCartError = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      placeFromCartStatus = ViewStatus.error;
      placeFromCartError = 'Could not place your order. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> directBuy(DirectBuyModel model) async {
    directBuyStatus = ViewStatus.loading;
    directBuyError = null;
    notifyListeners();

    try {
      lastOrder = await _orderService.directBuy(model);
      directBuyStatus = ViewStatus.success;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      directBuyStatus = ViewStatus.error;
      directBuyError = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      directBuyStatus = ViewStatus.error;
      directBuyError = 'Could not complete your purchase. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Step 1 of online payment: order must already exist server-side
  /// (call placeOrderFromCart/directBuy first). Creates the matching
  /// Razorpay order so the checkout sheet can be opened.
  Future<RazorpayOrderModel?> createRazorpayOrder(
    int orderId, {
    int fallbackAmountPaise = 0,
  }) async {
    razorpayCreateStatus = ViewStatus.loading;
    razorpayCreateError = null;
    notifyListeners();

    try {
      razorpayOrder = await _paymentService.createRazorpayOrder(
        orderId,
        fallbackAmountPaise: fallbackAmountPaise,
      );
      razorpayCreateStatus = ViewStatus.success;
      notifyListeners();
      return razorpayOrder;
    } on ApiException catch (e) {
      razorpayCreateStatus = ViewStatus.error;
      razorpayCreateError = e.message;
      notifyListeners();
      return null;
    } catch (_) {
      razorpayCreateStatus = ViewStatus.error;
      razorpayCreateError = 'Could not start online payment. Please try again.';
      notifyListeners();
      return null;
    }
  }

  /// Step 2 of online payment: called after Razorpay's checkout sheet
  /// returns a successful payment, to verify the signature server-side.
  Future<bool> verifyRazorpayPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required int orderId,
  }) async {
    razorpayVerifyStatus = ViewStatus.loading;
    razorpayVerifyError = null;
    notifyListeners();

    try {
      await _paymentService.verifyRazorpayPayment(
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
        orderId: orderId,
      );
      razorpayVerifyStatus = ViewStatus.success;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      razorpayVerifyStatus = ViewStatus.error;
      razorpayVerifyError = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      razorpayVerifyStatus = ViewStatus.error;
      razorpayVerifyError = 'Could not verify your payment. Please contact support if money was deducted.';
      notifyListeners();
      return false;
    }
  }

  void reset() {
    placeFromCartStatus = ViewStatus.idle;
    placeFromCartError = null;
    directBuyStatus = ViewStatus.idle;
    directBuyError = null;
    razorpayCreateStatus = ViewStatus.idle;
    razorpayCreateError = null;
    razorpayOrder = null;
    razorpayVerifyStatus = ViewStatus.idle;
    razorpayVerifyError = null;
    notifyListeners();
  }
}