// import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/views/screens/order/cancel_order_sheet.dart';
import 'package:ecommerce_app/views/screens/order/return_product_screen.dart';
import 'package:ecommerce_app/app_colors.dart';
import 'package:ecommerce_app/models/order_model.dart';
import 'package:ecommerce_app/viewmodel/order_detail_viewmodel.dart';

/// "Order Tracking" screen — order details, an expandable logistics
/// timeline (derived from the order's timestamps), payment breakdown
/// and deliver-to card. Shows "Cancel Order" while pending, "Return
/// Product" / "Cancel Return" once delivered, wired to the real
/// cancel/return/cancel-return endpoints.
class OrderTrackingScreen extends StatefulWidget {
  final OrderModel order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  bool _showAllSteps = false;

  @override
  void initState() {
    super.initState();
    // Seed with the order we already have (from the list) so the page
    // isn't blank, then refresh in the background for the latest state.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<OrderDetailViewModel>();
      viewModel.seed(widget.order);
      viewModel.fetchOrder(widget.order.apiId.toString());
    });
  }

  void _showSnack(String message, {bool isError = false, IconData icon = Icons.check_circle}) {
    if (!mounted) return;
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
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelOrder(OrderDetailViewModel viewModel) async {
    final result = await showCancelOrderSheet(context);
    if (result == null || !mounted) return;

    final success = await viewModel.cancelOrder(reason: result.reason, details: result.details);
    if (!mounted) return;

    if (success) {
      _showSnack('Your order has been cancelled', icon: Icons.check_circle);
    } else {
      _showSnack(viewModel.cancelError ?? 'Could not cancel this order', isError: true, icon: Icons.error_outline);
    }
  }

  Future<void> _returnProduct(OrderDetailViewModel viewModel) async {
    final order = viewModel.order;
    if (order == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ReturnProductScreen(order: order)),
    );
    if (result == true && mounted) {
      _showSnack('Your return request has been submitted', icon: Icons.check_circle);
    }
  }

  Future<void> _cancelReturn(OrderDetailViewModel viewModel) async {
    final order = viewModel.order;
    if (order == null || order.returns.isEmpty) return;

    final success = await viewModel.cancelReturn(order.returns.first.id.toString());
    if (!mounted) return;

    if (success) {
      _showSnack('Your return request has been cancelled', icon: Icons.check_circle);
    } else {
      _showSnack(viewModel.cancelReturnError ?? 'Could not cancel the return', isError: true, icon: Icons.error_outline);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OrderDetailViewModel>();
    final order = viewModel.order ?? widget.order;
    final steps = _showAllSteps ? order.trackingSteps : order.trackingSteps.take(3).toList();

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
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Order Details',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
                          ),
                        ),
                        Text(order.orderId, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: order.imagePath.isEmpty
                          ? Container(
                              height: 180,
                              color: AppColors.bgLight,
                              child: const Icon(Icons.image_outlined, color: AppColors.hintGrey, size: 40),
                            )
                          : order.imagePath.startsWith('http')
                              ? Image.network(
                                  order.imagePath,
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stack) => Container(
                                    height: 180,
                                    color: AppColors.bgLight,
                                    child: const Icon(Icons.image_outlined, color: AppColors.hintGrey, size: 40),
                                  ),
                                )
                              : Image.asset(
                                  order.imagePath,
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stack) => Container(
                                    height: 180,
                                    color: AppColors.bgLight,
                                    child: const Icon(Icons.image_outlined, color: AppColors.hintGrey, size: 40),
                                  ),
                                ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      order.productName,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Size: ${order.size}, Order ID: ${order.orderId}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: order.isCancelled
                                ? AppColors.badgeRed.withOpacity(0.1)
                                : (order.isDelivered ? AppColors.success.withOpacity(0.1) : AppColors.primaryBlue.withOpacity(0.1)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            order.statusLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: order.isCancelled
                                  ? AppColors.badgeRed
                                  : (order.isDelivered ? AppColors.success : AppColors.primaryBlue),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (order.isDelivered) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                              ),
                              child: const Text('Buy Again', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.borderGrey),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                              ),
                              child: const Text('Write Review', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600, fontSize: 13)),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      order.hasActiveReturn ? 'Return Tracking' : 'Logistics Tracking',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 12),
                    ...steps.reversed.map((step) => _trackingStepTile(step)),
                    if (order.trackingSteps.length > 3)
                      GestureDetector(
                        onTap: () => setState(() => _showAllSteps = !_showAllSteps),
                        child: Text(
                          _showAllSteps ? 'See less' : 'See full details',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
                        ),
                      ),
                    const SizedBox(height: 20),
                    const Text(
                      'Payment Detail',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.bgLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          _paymentRow('Subtotal', '\$${order.totalBills.toStringAsFixed(2)}'),
                          const SizedBox(height: 8),
                          _paymentRow('Shipment Fee', order.shipmentFee == 0 ? 'Free' : '\$${order.shipmentFee.toStringAsFixed(2)}',
                              valueColor: order.shipmentFee == 0 ? AppColors.success : AppColors.textDark),
                          const SizedBox(height: 8),
                          _paymentRow('Tax', '\$${order.tax.toStringAsFixed(2)}'),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(height: 1, color: AppColors.borderGrey),
                          ),
                          _paymentRow('Total Payment', '\$${order.totalPayment.toStringAsFixed(2)}', bold: true),
                          const SizedBox(height: 8),
                          _paymentRow('Payment method', order.paymentMethod.toUpperCase()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 18, color: AppColors.primaryBlue),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Deliver to', style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
                                Text(
                                  order.deliverToAddress,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!order.isDelivered && !order.isCancelled)
                      _actionTile(
                        'Cancel Order',
                        onTap: viewModel.isCancelling ? null : () => _cancelOrder(viewModel),
                        color: AppColors.badgeRed,
                        loading: viewModel.isCancelling,
                      ),
                    if (order.isDelivered && !order.hasActiveReturn)
                      _actionTile('Return Product', onTap: () => _returnProduct(viewModel)),
                    if (order.hasActiveReturn)
                      _actionTile(
                        'Cancel Return',
                        onTap: viewModel.isCancellingReturn ? null : () => _cancelReturn(viewModel),
                        color: AppColors.badgeRed,
                        loading: viewModel.isCancellingReturn,
                      ),
                  ],
                ),
              ),
            ),
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
              decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Order Tracking',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }

  Widget _trackingStepTile(TrackingStep step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            step.completed ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: step.completed ? AppColors.success : AppColors.borderGrey,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: step.completed ? AppColors.textDark : AppColors.textGrey,
                  ),
                ),
                Text(step.subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentRow(String label, String value, {bool bold = false, Color? valueColor}) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textGrey))),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 15 : 12,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _actionTile(String label, {required VoidCallback? onTap, Color color = AppColors.textDark, bool loading = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.borderGrey)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
              ),
              loading
                  ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: color))
                  : Icon(Icons.chevron_right, size: 18, color: color),
            ],
          ),
        ),
      ),
    );
  }
}