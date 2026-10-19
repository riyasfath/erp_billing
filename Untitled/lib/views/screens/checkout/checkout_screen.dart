// import 'package:ecommerce_app/core/env_config.dart';
import 'package:ecommerce_app/core/env_config.dart';
import 'package:ecommerce_app/models/adress_model.dart';
import 'package:ecommerce_app/models/cart_model.dart';
import 'package:ecommerce_app/models/order_model.dart';
import 'package:ecommerce_app/views/screens/checkout/my_addresss_screen.dart';
import 'package:ecommerce_app/views/screens/checkout/order_confirmation_screen.dart';
import 'package:ecommerce_app/views/screens/checkout/payment_method_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:ecommerce_app/app_colors.dart';
import 'package:ecommerce_app/viewmodel/place_order_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/cart_viewmodel.dart';

class _DeliveryOption {
  final String code; // sent to the API exactly as-is
  final String title;
  final String subtitle;
  final double cost;
  const _DeliveryOption(this.code, this.title, this.subtitle, this.cost);
}

// Matches the order API's `_delivery_options: "standard, express"` exactly.
const List<_DeliveryOption> _deliveryOptions = [
  _DeliveryOption('standard', 'Standard Delivery', '3-4 Day estimation', 0),
  _DeliveryOption('express', 'Express Delivery', '1-2 Day estimation', 8),
];

// Only cod and online are offered now.
const Map<String, String> _paymentMethodLabels = {
  'cod': 'Cash on Delivery',
  'online': 'Online Payment',
};

/// "Checkout Product" screen — order summary, delivery method, delivery
/// address, payment, discount voucher and a bottom Total Charge bar
/// with "Finish Payment". Places a real order via POST /api/orders/add/,
/// then — if "Online Payment" was chosen — opens the Razorpay checkout
/// sheet and verifies the signature before showing confirmation.
class CheckoutScreen extends StatefulWidget {
  final List<CartItemModel> items;

  const CheckoutScreen({super.key, required this.items});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedDeliveryIndex = 0;
  AddressModel? _selectedAddress;
  String? _selectedPaymentMethod; // 'cod' | 'online'
  final TextEditingController _voucherController = TextEditingController();
  bool _voucherApplied = false;

  late final Razorpay _razorpay;
  // Kept around between "order placed" and "Razorpay result" so the
  // payment-result callbacks (which can't take extra params) know
  // which order to verify/confirm.
  OrderModel? _pendingOrder;
  bool _isProcessingOnlinePayment = false;

  double get _subtotal => widget.items.fold(0, (sum, i) => sum + i.subtotal);
  double get _deliveryFee => _deliveryOptions[_selectedDeliveryIndex].cost;
  // Server-confirmed rate from real order responses (e.g. 99.00 subtotal
  // → 17.82 tax, consistently 18% across every sample order).
  double get _tax => _subtotal * 0.18;
  double get _discount => _voucherApplied ? _subtotal * 0.10 : 0;
  double get _total => _subtotal + _deliveryFee + _tax - _discount;

  bool get _canFinish => _selectedAddress != null && _selectedPaymentMethod != null;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onRazorpaySuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onRazorpayError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onRazorpayExternalWallet);
  }

  @override
  void dispose() {
    _voucherController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _pickAddress() async {
    final result = await Navigator.push<AddressModel>(
      context,
      MaterialPageRoute(builder: (_) => const MyAddressScreen()),
    );
    if (result != null) {
      setState(() => _selectedAddress = result);
    }
  }

  Future<void> _pickPaymentMethod() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => PaymentMethodScreen(initialSelection: _selectedPaymentMethod)),
    );
    if (result != null) {
      setState(() => _selectedPaymentMethod = result);
    }
  }

  void _applyVoucher() {
    if (_voucherController.text.trim().isEmpty) return;
    setState(() => _voucherApplied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voucher applied — 10% off'),
        duration: Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  void _showSnack(String message, {bool isError = false, IconData icon = Icons.check_circle}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppColors.badgeRed : const Color(0xFF16A34A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(milliseconds: 1800),
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13))),
          ],
        ),
      ),
    );
  }

  /// Confirmation popup shown right before an order is actually placed —
  /// summarizes what's about to happen so a stray tap on "Finish
  /// Payment" doesn't place an order by accident.
  Future<bool> _confirmOrderDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 12))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.receipt_long_rounded, color: AppColors.primaryBlue, size: 30),
              ),
              const SizedBox(height: 16),
              const Text(
                'Confirm your order?',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedPaymentMethod == 'cod'
                    ? "You're about to place an order for \$${_total.toStringAsFixed(2)}, paid on delivery."
                    : "You're about to place an order for \$${_total.toStringAsFixed(2)}. You'll be taken to payment next.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textGrey, height: 1.4),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.borderGrey),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Cancel', style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.w700, fontSize: 14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Confirm', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return confirmed ?? false;
  }

  /// Only used for true payment success (COD placed, or Razorpay
  /// verified) — plays a brief celebratory animation before landing on
  /// the confirmation screen.
  Future<void> _goToConfirmedScreen(OrderModel order, {bool celebrate = false}) async {
    if (celebrate) {
      await showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.55),
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) => const _OrderSuccessAnimation(),
        transitionBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
      );
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => OrderConfirmedScreen(order: order)),
    );
  }

  Future<void> _finishPayment(PlaceOrderViewModel viewModel) async {
    if (!_canFinish) return;

    final cartViewModel = context.read<CartViewModel>();

    // The real /api/orders/add/ endpoint always builds the order from
    // the ENTIRE server-side cart — it has no way to say "just these
    // items". To honor what the user actually checked on this screen
    // without losing the rest of their cart, temporarily remove
    // whatever wasn't selected, place the order (now made only from
    // what's selected), then add those set-aside items back
    // afterward — whether the order succeeded or not.
    final selectedIds = widget.items.map((i) => i.cartItemId).toSet();
    final setAside = cartViewModel.items
        .where((i) => !selectedIds.contains(i.cartItemId))
        .toList();

    for (final item in setAside) {
      final removed = await cartViewModel.removeItem(item.cartItemId);
      if (!removed) {
        if (!mounted) return;
        _showSnack(
          cartViewModel.error ?? 'Could not prepare your cart for checkout. Please try again.',
          isError: true,
          icon: Icons.error_outline,
        );
        return;
      }
    }

    final success = await viewModel.placeOrderFromCart(
      deliveryMethod: _deliveryOptions[_selectedDeliveryIndex].code,
      paymentMethod: _selectedPaymentMethod!,
    );

    // Restore the set-aside items regardless of outcome — they were
    // never meant to be part of this particular order.
    for (final item in setAside) {
      await cartViewModel.addToCart(
        productId: item.productId,
        quantity: item.quantity,
        size: item.size,
        color: item.color,
      );
    }

    if (!mounted) return;

    if (!success || viewModel.lastOrder == null) {
      cartViewModel.fetchCart();
      _showSnack(viewModel.placeFromCartError ?? 'Could not place your order', isError: true, icon: Icons.error_outline);
      return;
    }

    final order = viewModel.lastOrder!;
    cartViewModel.fetchCart();

    if (_selectedPaymentMethod == 'cod') {
      await _goToConfirmedScreen(order, celebrate: true);
      return;
    }

    // Online payment: order already exists server-side (unpaid) —
    // now create the matching Razorpay order and open the checkout sheet.
    await _startRazorpayCheckout(viewModel, order);
  }

  Future<void> _startRazorpayCheckout(PlaceOrderViewModel viewModel, OrderModel order) async {
    setState(() => _isProcessingOnlinePayment = true);

    final razorpayOrder = await viewModel.createRazorpayOrder(
      order.apiId,
      fallbackAmountPaise: (_total * 100).round(),
    );

    if (!mounted) return;
    setState(() => _isProcessingOnlinePayment = false);

    if (razorpayOrder == null) {
      _showSnack(
        viewModel.razorpayCreateError ?? 'Could not start online payment. You can retry from My Orders.',
        isError: true,
        icon: Icons.error_outline,
      );
      // Order is already placed (just unpaid) — send them to
      // confirmation anyway so it isn't lost/hidden from them.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OrderConfirmedScreen(order: order)),
      );
      return;
    }

    final keyId = razorpayOrder.keyId?.isNotEmpty == true
        ? razorpayOrder.keyId!
        : EnvConfig.razorpayKeyId;

    if (keyId.isEmpty) {
      _showSnack('Online payment isn\'t set up yet (missing Razorpay key). Please choose Cash on Delivery for now.', isError: true, icon: Icons.error_outline);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OrderConfirmedScreen(order: order)),
      );
      return;
    }

    _pendingOrder = order;

    final options = {
      'key': keyId,
      'amount': razorpayOrder.amountInPaise,
      'order_id': razorpayOrder.razorpayOrderId,
      'name': 'Kicks',
      'description': 'Order ${order.orderId}',
      // Forces Razorpay's own checkout form (card/UPI entry, validation
      // messages like "invalid expiry date") to English regardless of
      // device locale — was defaulting to Hindi on some devices.
      'preferences': {'language': 'en'},
      'prefill': {
        'contact': order.customerPhone,
        'email': order.customerEmail,
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      _pendingOrder = null;
      if (!mounted) return;
      _showSnack('Could not open the payment sheet. Please try again.', isError: true, icon: Icons.error_outline);
    }
  }

  void _onRazorpaySuccess(PaymentSuccessResponse response) async {
    final order = _pendingOrder;
    if (order == null || !mounted) return;

    final viewModel = context.read<PlaceOrderViewModel>();

    final verified = await viewModel.verifyRazorpayPayment(
      razorpayOrderId: response.orderId ?? '',
      razorpayPaymentId: response.paymentId ?? '',
      razorpaySignature: response.signature ?? '',
      orderId: order.apiId,
    );

    _pendingOrder = null;
    if (!mounted) return;

    if (verified) {
      await _goToConfirmedScreen(order, celebrate: true);
    } else {
      _showSnack(
        viewModel.razorpayVerifyError ?? 'Payment succeeded but could not be verified. Please contact support.',
        isError: true,
        icon: Icons.error_outline,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OrderConfirmedScreen(order: order)),
      );
    }
  }

  void _onRazorpayError(PaymentFailureResponse response) {
    // Was auto-navigating to the "success" confirmation screen even
    // when the user cancelled or exited the payment sheet — that's
    // wrong, the order is still unpaid and nothing succeeded. Now it
    // just shows the error and leaves the user right here on checkout
    // so they can retry or change payment method.
    _pendingOrder = null;
    if (!mounted) return;

    final String reason = response.code == 2 ? 'Payment cancelled' : (response.message ?? 'Payment failed');
    _showSnack(reason, isError: true, icon: Icons.error_outline);
  }

  void _onRazorpayExternalWallet(ExternalWalletResponse response) {
    _showSnack('Selected wallet: ${response.walletName ?? ''}');
  }

  @override
  Widget build(BuildContext context) {
    final placeOrderViewModel = context.watch<PlaceOrderViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailTransaction(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Delivery Method'),
                    const SizedBox(height: 10),
                    _buildDeliveryMethods(),
                    const SizedBox(height: 24),
                    _buildDeliveryAddress(),
                    const SizedBox(height: 24),
                    _buildPaymentMethod(),
                    const SizedBox(height: 24),
                    _buildDiscountVoucher(),
                    const SizedBox(height: 24),
                    _buildPriceSummary(),
                  ],
                ),
              ),
            ),
            _buildBottomBar(placeOrderViewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Checkout Product',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
    );
  }

  Widget _buildDetailTransaction() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionTitle('Detail Transaction'),
            const SizedBox(width: 6),
            Text(
              '(${widget.items.length} Items)',
              style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...widget.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.bgLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: item.imagePath.startsWith('http')
                          ? Image.network(
                              item.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) =>
                                  const Icon(Icons.image_outlined, color: AppColors.hintGrey, size: 22),
                            )
                          : Image.asset(
                              item.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) =>
                                  const Icon(Icons.image_outlined, color: AppColors.hintGrey, size: 22),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Size : ${item.size}  Color : ${item.color}  x${item.quantity}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${item.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildDeliveryMethods() {
    return Column(
      children: List.generate(_deliveryOptions.length, (index) {
        final option = _deliveryOptions[index];
        final bool selected = index == _selectedDeliveryIndex;
        return GestureDetector(
          onTap: () => setState(() => _selectedDeliveryIndex = index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryBlue.withOpacity(0.06) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: selected ? AppColors.primaryBlue : AppColors.borderGrey),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.local_shipping_outlined, size: 18, color: AppColors.primaryBlue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.title,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        option.subtitle,
                        style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ),
                Text(
                  option.cost == 0 ? 'Free' : '+\$${option.cost.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDeliveryAddress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildSectionTitle('Delivery Address')),
            GestureDetector(
              onTap: _pickAddress,
              child: Text(
                _selectedAddress == null ? 'Select Address' : 'Change Address',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.badgeRed),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_selectedAddress == null)
          GestureDetector(
            onTap: _pickAddress,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bgLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                "Oops it looks like you haven't selected your address yet, you can also set it as default",
                style: TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderGrey),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: AppColors.primaryBlue),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedAddress!.title,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _selectedAddress!.fullAddress,
                        style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildSectionTitle('Payment Method')),
            GestureDetector(
              onTap: _pickPaymentMethod,
              child: Text(
                _selectedPaymentMethod == null ? 'Select Method' : 'Change Method',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.badgeRed),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _pickPaymentMethod,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _selectedPaymentMethod == null ? AppColors.bgLight : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: _selectedPaymentMethod == null
                  ? null
                  : Border.all(color: AppColors.borderGrey),
            ),
            child: _selectedPaymentMethod == null
                ? const Text(
                    "Oops it looks like you haven't selected your payment method yet, you can also set it as default.",
                    style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                  )
                : Row(
                    children: [
                      const Icon(Icons.payments_outlined, size: 18, color: AppColors.primaryBlue),
                      const SizedBox(width: 10),
                      Text(
                        _paymentMethodLabels[_selectedPaymentMethod!] ?? _selectedPaymentMethod!,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountVoucher() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Discount Voucher'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderGrey),
                ),
                child: TextField(
                  controller: _voucherController,
                  decoration: const InputDecoration(
                    hintText: 'Enter voucher code',
                    hintStyle: TextStyle(color: AppColors.hintGrey, fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: _applyVoucher,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: const Text('Apply', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Price Details'),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              _priceRow('Subtotal', '\$${_subtotal.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _priceRow('Delivery Fee', _deliveryFee == 0 ? 'Free' : '\$${_deliveryFee.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _priceRow('Tax', '\$${_tax.toStringAsFixed(2)}'),
              if (_voucherApplied) ...[
                const SizedBox(height: 8),
                _priceRow('Discount', '-\$${_discount.toStringAsFixed(2)}', valueColor: const Color(0xFF16A34A)),
              ],
              const Divider(height: 20, color: AppColors.borderGrey),
              _priceRow('Total', '\$${_total.toStringAsFixed(2)}', bold: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _priceRow(String label, String value, {bool bold = false, Color? valueColor}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: bold ? 14 : 12,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              color: bold ? AppColors.textDark : AppColors.textGrey,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 16 : 13,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
            color: valueColor ?? AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(PlaceOrderViewModel viewModel) {
    final bool busy = viewModel.isPlacingFromCart || _isProcessingOnlinePayment || viewModel.isCreatingRazorpayOrder;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Total Charge', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                  const SizedBox(height: 2),
                  Text(
                    '\$${_total.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: (_canFinish && !busy)
                    ? () async {
                        final confirmed = await _confirmOrderDialog();
                        if (confirmed && mounted) _finishPayment(viewModel);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  disabledBackgroundColor: AppColors.borderGrey,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                ),
                child: busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Finish Payment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward, color: Colors.white, size: 15),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen celebratory animation shown briefly right after a real
/// payment success (COD placed / Razorpay verified) before landing on
/// OrderConfirmedScreen — a ring pulse + elastic check-circle pop-in +
/// fading "Order Placed!" text. Pops itself after ~1.6s.
class _OrderSuccessAnimation extends StatefulWidget {
  const _OrderSuccessAnimation();

  @override
  State<_OrderSuccessAnimation> createState() => _OrderSuccessAnimationState();
}

class _OrderSuccessAnimationState extends State<_OrderSuccessAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _circleScale;
  late final Animation<double> _checkOpacity;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));

    _circleScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.15).chain(CurveTween(curve: Curves.easeOutBack)), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
    ]).animate(_controller);

    _checkOpacity = CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.55, curve: Curves.easeIn));

    _ringScale = Tween<double>(begin: 0.6, end: 2.4)
        .animate(CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.8, curve: Curves.easeOut)));
    _ringOpacity = Tween<double>(begin: 0.55, end: 0.0)
        .animate(CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.8, curve: Curves.easeOut)));

    _textOpacity = CurvedAnimation(parent: _controller, curve: const Interval(0.55, 0.85, curve: Curves.easeIn));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: const Interval(0.55, 0.85, curve: Curves.easeOut)));

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.scale(
                        scale: _ringScale.value,
                        child: Opacity(
                          opacity: _ringOpacity.value,
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                          ),
                        ),
                      ),
                      Transform.scale(
                        scale: _circleScale.value,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.primaryBlue, Color(0xFF16A34A)],
                            ),
                            boxShadow: [
                              BoxShadow(color: AppColors.primaryBlue.withOpacity(0.55), blurRadius: 36, spreadRadius: 4),
                            ],
                          ),
                          child: Opacity(
                            opacity: _checkOpacity.value,
                            child: const Icon(Icons.check_rounded, color: Colors.white, size: 58),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                FadeTransition(
                  opacity: _textOpacity,
                  child: SlideTransition(
                    position: _textSlide,
                    child: const Column(
                      children: [
                        Text(
                          'Order Placed!',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Thanks for shopping with us',
                          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}