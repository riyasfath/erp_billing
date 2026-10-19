import 'package:flutter/material.dart';
import 'package:ecommerce_app/app_colors.dart';
import 'package:ecommerce_app/models/order_model.dart';
import 'package:ecommerce_app/views/screens/order/my_orders_screen.dart';

/// "Order Confirmed" screen shown after a successful checkout/direct-buy.
/// Takes the real OrderModel returned by the API — no more separately
/// passed items/total/address/paymentMethod, it's all on the order now.
/// "Continue Shopping" pops every screen back to MainTabScreen (the
/// app's root).
class OrderConfirmedScreen extends StatelessWidget {
  final OrderModel order;

  const OrderConfirmedScreen({super.key, required this.order});

  String get _estimatedArrival {
    if (order.expectedDelivery != null && order.expectedDelivery!.isNotEmpty) {
      return order.expectedDelivery!;
    }
    final date = DateTime.now().add(const Duration(days: 5));
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle, color: AppColors.success, size: 48),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Order Confirmed!',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 24),
                      _infoRow(Icons.inventory_2_outlined, 'Order Number', order.orderId),
                      const SizedBox(height: 12),
                      _infoRow(Icons.local_shipping_outlined, 'Estimated Arrival', _estimatedArrival),
                      const SizedBox(height: 24),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'ORDER SUMMARY',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textGrey,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...order.items.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.bgLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: item.imageUrl.isEmpty
                                        ? const Icon(Icons.image_outlined, color: AppColors.hintGrey, size: 20)
                                        : Image.network(
                                            item.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stack) =>
                                                const Icon(Icons.image_outlined, color: AppColors.hintGrey, size: 20),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.productName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                                      ),
                                      Text(
                                        'Qty: ${item.quantity}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '\$${item.subtotal.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                                ),
                              ],
                            ),
                          )),
                      const Divider(height: 24, color: AppColors.borderGrey),
                      // --- Price breakdown (was missing before — only
                      // base price + TOTAL showed, no way to see why
                      // the total was higher than the item price) ---
                      _summaryRow('Subtotal', '\$${order.subtotal.toStringAsFixed(2)}'),
                      const SizedBox(height: 6),
                      _summaryRow('Shipping', order.shippingCost > 0 ? '\$${order.shippingCost.toStringAsFixed(2)}' : 'Free'),
                      const SizedBox(height: 6),
                      _summaryRow('Tax', '\$${order.tax.toStringAsFixed(2)}'),
                      const Divider(height: 24, color: AppColors.borderGrey),
                      _summaryRow('Payment Method', order.paymentMethod.toUpperCase()),
                      const SizedBox(height: 6),
                      _summaryRow('Delivery Address', order.address?.title ?? order.shippingAddress),
                      const SizedBox(height: 10),
                      _summaryRow('TOTAL', '\$${order.totalAmount.toStringAsFixed(2)}', bold: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Clears back to the app root first, then opens My
                    // Orders — so backing out of My Orders lands the
                    // user on the main tabs, not back inside checkout.
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Track My Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text(
                  'Continue Shopping',
                  style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(color: AppColors.bgLight, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 16, color: AppColors.primaryBlue),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
        ),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
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
            fontSize: bold ? 16 : 12,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}