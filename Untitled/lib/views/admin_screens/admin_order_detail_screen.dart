import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../admin/admin_model/admin_order_model.dart';
import '../../admin/admin_viewmodel/admin_order_viewmodel.dart';
import 'admin_orders_screen.dart' show statusColor, statusIcon;

const Color _accent = Color(0xFF6366F1);
const Color _textDark = Color(0xFF0F172A);
const Color _textGrey = Color(0xFF64748B);
const Color _bg = Color(0xFFF5F6FA);

const List<String> _statusOptions = ['confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded'];
const List<String> _paymentStatusOptions = ['pending', 'completed', 'failed', 'refunded'];

class AdminOrderDetailScreen extends StatefulWidget {
  final int orderId;
  const AdminOrderDetailScreen({super.key, required this.orderId});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  String? _selectedStatus;
  String? _selectedPaymentStatus;
  final _transactionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminOrderViewModel>().fetchDetail(widget.orderId);
    });
  }

  @override
  void dispose() {
    _transactionController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF16A34A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  Future<void> _saveUpdate(AdminOrderViewModel viewModel) async {
    if (_selectedStatus == null && _selectedPaymentStatus == null && _transactionController.text.trim().isEmpty) {
      _showSnack('Change something before saving', isError: true);
      return;
    }
    final success = await viewModel.updateOrder(
      widget.orderId,
      status: _selectedStatus,
      paymentStatus: _selectedPaymentStatus,
      transactionId: _transactionController.text.trim().isEmpty ? null : _transactionController.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      _showSnack('Order updated');
      setState(() {
        _selectedStatus = null;
        _selectedPaymentStatus = null;
        _transactionController.clear();
      });
    } else {
      _showSnack(viewModel.detailError ?? 'Could not update order', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminOrderViewModel>();
    final order = viewModel.selectedOrder;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _textDark,
        title: Text(order?.orderId ?? 'Order', style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: viewModel.isLoadingDetail
          ? const Center(child: CircularProgressIndicator(color: _accent))
          : viewModel.detailError != null && order == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(viewModel.detailError!, style: const TextStyle(color: _textGrey)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => viewModel.fetchDetail(widget.orderId),
                        style: ElevatedButton.styleFrom(backgroundColor: _accent),
                        child: const Text('Retry', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : order == null
                  ? const SizedBox.shrink()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      children: [
                        _statusHeader(order),
                        const SizedBox(height: 16),
                        _card(title: 'Items', icon: Icons.shopping_bag_rounded, iconColor: _accent, child: _itemsList(order)),
                        const SizedBox(height: 16),
                        _card(title: 'Customer', icon: Icons.person_rounded, iconColor: const Color(0xFF06B6D4), child: _customerInfo(order)),
                        if (order.address != null) ...[
                          const SizedBox(height: 16),
                          _card(title: 'Delivery Address', icon: Icons.location_on_rounded, iconColor: const Color(0xFFF59E0B), child: _addressInfo(order.address!)),
                        ],
                        const SizedBox(height: 16),
                        _card(title: 'Payment Summary', icon: Icons.receipt_long_rounded, iconColor: const Color(0xFF16A34A), child: _paymentSummary(order)),
                        if (order.cancelledReason != null) ...[
                          const SizedBox(height: 16),
                          _card(title: 'Cancellation', icon: Icons.cancel_rounded, iconColor: const Color(0xFFEF4444), child: _cancellationInfo(order)),
                        ],
                        const SizedBox(height: 16),
                        _card(title: 'Update Order', icon: Icons.edit_rounded, iconColor: const Color(0xFF8B5CF6), child: _updateForm(viewModel)),
                      ],
                    ),
    );
  }

  Widget _statusHeader(AdminOrderModel order) {
    final color = statusColor(order.status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color, color.withOpacity(0.7)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: color.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(statusIcon(order.status), color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.status.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: 0.5)),
                    const SizedBox(height: 2),
                    Text('Payment: ${order.paymentStatus}', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withOpacity(0.25)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
              Text('\$${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _card({required String title, required IconData icon, required Color iconColor, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _textDark)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _itemsList(AdminOrderModel order) {
    return Column(
      children: order.items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 54,
                  height: 54,
                  child: item.imageUrl != null
                      ? Image.network(item.imageUrl!, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: _bg))
                      : Container(color: _bg, child: const Icon(Icons.image_outlined, color: _textGrey, size: 20)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productName ?? 'Unknown product', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _textDark)),
                    const SizedBox(height: 2),
                    Text('${item.brandName} · Size ${item.size} · ${item.color} · x${item.quantity}', style: const TextStyle(fontSize: 11, color: _textGrey)),
                  ],
                ),
              ),
              Text('\$${item.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _textDark)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _customerInfo(AdminOrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow(Icons.badge_outlined, 'Name', order.customerName ?? '—'),
        _infoRow(Icons.mail_outline_rounded, 'Email', order.customerEmail ?? '—'),
        _infoRow(Icons.call_outlined, 'Phone', order.customerPhone ?? '—'),
      ],
    );
  }

  Widget _addressInfo(AdminOrderAddress address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(address.fullName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _textDark)),
        const SizedBox(height: 4),
        Text(
          '${address.addressLine1}${address.addressLine2.isNotEmpty ? ', ${address.addressLine2}' : ''}\n${address.city}, ${address.state} ${address.pincode}\nPhone: ${address.phone}',
          style: const TextStyle(fontSize: 12, color: _textGrey, height: 1.6),
        ),
      ],
    );
  }

  Widget _paymentSummary(AdminOrderModel order) {
    return Column(
      children: [
        _infoRow(Icons.receipt_outlined, 'Subtotal', '\$${order.subtotal.toStringAsFixed(2)}'),
        _infoRow(Icons.local_shipping_outlined, 'Shipping', '\$${order.shippingCost.toStringAsFixed(2)}'),
        _infoRow(Icons.percent_rounded, 'Tax', '\$${order.tax.toStringAsFixed(2)}'),
        if (order.refundAmount > 0) _infoRow(Icons.replay_rounded, 'Refunded', '\$${order.refundAmount.toStringAsFixed(2)}'),
        Container(margin: const EdgeInsets.symmetric(vertical: 12), height: 1, color: const Color(0xFFF1F5F9)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total', style: TextStyle(fontSize: 13, color: _textGrey, fontWeight: FontWeight.w600)),
            Text('\$${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _accent)),
          ],
        ),
        const SizedBox(height: 10),
        _infoRow(Icons.payment_rounded, 'Method', order.paymentMethod),
        _infoRow(Icons.local_shipping_rounded, 'Delivery', order.deliveryMethod),
        if (order.transactionId != null) _infoRow(Icons.tag_rounded, 'Transaction ID', order.transactionId!),
      ],
    );
  }

  Widget _cancellationInfo(AdminOrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow(Icons.info_outline_rounded, 'Reason', order.cancelledReason ?? '—'),
        if (order.cancelledComment != null) ...[
          const SizedBox(height: 6),
          Text(order.cancelledComment!, style: const TextStyle(fontSize: 12, color: _textGrey)),
        ],
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 14, color: _textGrey),
          const SizedBox(width: 8),
          SizedBox(width: 84, child: Text(label, style: const TextStyle(fontSize: 12, color: _textGrey))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textDark))),
        ],
      ),
    );
  }

  Widget _updateForm(AdminOrderViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _textGrey, letterSpacing: 0.8)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _statusOptions.map((s) {
            final selected = s == _selectedStatus;
            final color = statusColor(s);
            return GestureDetector(
              onTap: () => setState(() => _selectedStatus = selected ? null : s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                decoration: BoxDecoration(
                  gradient: selected ? LinearGradient(colors: [color, color.withOpacity(0.75)]) : null,
                  color: selected ? null : _bg,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: selected ? [BoxShadow(color: color.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 3))] : null,
                ),
                child: Text(s, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: selected ? Colors.white : _textGrey)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        const Text('PAYMENT STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _textGrey, letterSpacing: 0.8)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _paymentStatusOptions.map((s) {
            final selected = s == _selectedPaymentStatus;
            final color = statusColor(s);
            return GestureDetector(
              onTap: () => setState(() => _selectedPaymentStatus = selected ? null : s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                decoration: BoxDecoration(
                  gradient: selected ? LinearGradient(colors: [color, color.withOpacity(0.75)]) : null,
                  color: selected ? null : _bg,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: selected ? [BoxShadow(color: color.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 3))] : null,
                ),
                child: Text(s, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: selected ? Colors.white : _textGrey)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        const Text('TRANSACTION ID (optional)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _textGrey, letterSpacing: 0.8)),
        const SizedBox(height: 10),
        TextField(
          controller: _transactionController,
          decoration: InputDecoration(
            isDense: true,
            hintText: 'e.g. TXN-MANUAL-001',
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            filled: true,
            fillColor: _bg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: viewModel.isUpdating ? null : () => _saveUpdate(viewModel),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: viewModel.isUpdating
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ),
      ],
    );
  }
}