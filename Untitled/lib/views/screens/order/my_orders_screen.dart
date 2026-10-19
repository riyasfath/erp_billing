import 'package:ecommerce_app/views/screens/order/order_tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/app_colors.dart';
import 'package:ecommerce_app/models/order_model.dart';
import 'package:ecommerce_app/viewmodel/order_list_viewmodel.dart';

/// "My Orders" screen — a flat list of past purchases from the real
/// GET /api/orders/. Tapping a card opens Order Tracking for that order.
class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderListViewModel>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OrderListViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildBody(viewModel)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(OrderListViewModel viewModel) {
    if (viewModel.isLoading && viewModel.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.error != null && viewModel.orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(viewModel.error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textGrey)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => viewModel.fetchOrders(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }
    if (viewModel.orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.textGrey),
              const SizedBox(height: 14),
              const Text(
                "You haven't placed any orders yet",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
              const SizedBox(height: 6),
              const Text(
                "Once you place an order, you'll see it here",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.fetchOrders(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        itemCount: viewModel.orders.length + (viewModel.hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          if (index >= viewModel.orders.length) {
            if (!viewModel.isLoadingMore) {
              WidgetsBinding.instance.addPostFrameCallback((_) => viewModel.loadMore());
            }
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _orderCard(context, viewModel.orders[index]);
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            'My Orders',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }

  Widget _orderCard(BuildContext context, OrderModel order) {
    final bool isNetworkImage = order.imagePath.startsWith('http');

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OrderTrackingScreen(order: order)),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ${order.orderId}',
              style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: AppColors.bgLight, borderRadius: BorderRadius.circular(10)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: order.imagePath.isEmpty
                        ? const Icon(Icons.image_outlined, color: AppColors.hintGrey, size: 22)
                        : isNetworkImage
                            ? Image.network(order.imagePath, fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Icon(Icons.image_outlined, color: AppColors.hintGrey, size: 22))
                            : Image.asset(order.imagePath, fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Icon(Icons.image_outlined, color: AppColors.hintGrey, size: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Size : ${order.size}  Qty : ${order.quantity}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  order.isCancelled
                      ? Icons.cancel_outlined
                      : (order.isDelivered ? Icons.check_circle : Icons.local_shipping_outlined),
                  size: 15,
                  color: order.isCancelled
                      ? AppColors.badgeRed
                      : (order.isDelivered ? AppColors.success : AppColors.primaryBlue),
                ),
                const SizedBox(width: 6),
                Text(
                  order.statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: order.isCancelled
                        ? AppColors.badgeRed
                        : (order.isDelivered ? AppColors.success : AppColors.primaryBlue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}