import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../admin/admin_model/admin_order_model.dart';
import '../../admin/admin_service/admin_export_service.dart';
import '../../admin/admin_viewmodel/admin_order_viewmodel.dart';
import 'admin_order_detail_screen.dart';

const Color _accent = Color(0xFF6366F1);
const Color _textDark = Color(0xFF0F172A);
const Color _textGrey = Color(0xFF64748B);
const Color _bg = Color(0xFFF5F6FA);

const List<String> _orderStatusFilters = [
  'All', 'pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded'
];

Color statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return const Color(0xFFF59E0B);
    case 'confirmed':
      return const Color(0xFF3B82F6);
    case 'processing':
      return const Color(0xFF8B5CF6);
    case 'shipped':
      return const Color(0xFF06B6D4);
    case 'delivered':
    case 'completed':
    case 'approved':
      return const Color(0xFF16A34A);
    case 'cancelled':
    case 'failed':
    case 'rejected':
      return const Color(0xFFEF4444);
    case 'refunded':
      return const Color(0xFF8B5CF6);
    default:
      return _textGrey;
  }
}

IconData statusIcon(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return Icons.schedule_rounded;
    case 'confirmed':
      return Icons.check_circle_outline_rounded;
    case 'processing':
      return Icons.autorenew_rounded;
    case 'shipped':
      return Icons.local_shipping_rounded;
    case 'delivered':
    case 'completed':
    case 'approved':
      return Icons.task_alt_rounded;
    case 'cancelled':
    case 'failed':
    case 'rejected':
      return Icons.cancel_rounded;
    case 'refunded':
      return Icons.replay_circle_filled_rounded;
    default:
      return Icons.circle;
  }
}

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String _filter = 'All';
  bool _isExporting = false;
  final _exportService = AdminExportService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminOrderViewModel>().fetchOrders();
    });
  }

  Future<void> _export() async {
    setState(() => _isExporting = true);
    try {
      await _exportService.exportOrders();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: const Color(0xFFEF4444)),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminOrderViewModel>();
    final filtered = _filter == 'All' ? viewModel.orders : viewModel.orders.where((o) => o.status.toLowerCase() == _filter).toList();

    return Container(
      color: _bg,
      child: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildBody(viewModel, filtered)),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _orderStatusFilters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final f = _orderStatusFilters[i];
                  final selected = f == _filter;
                  final color = f == 'All' ? _accent : statusColor(f);
                  return GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: selected ? LinearGradient(colors: [color, color.withOpacity(0.75)]) : null,
                        color: selected ? null : _bg,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: selected ? [BoxShadow(color: color.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))] : null,
                      ),
                      child: Text(
                        f == 'All' ? 'All' : f[0].toUpperCase() + f.substring(1),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? Colors.white : _textGrey),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isExporting ? null : _export,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_accent, Color(0xFF8B5CF6)]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: _accent.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: _isExporting
                  ? const Padding(padding: EdgeInsets.all(9), child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.ios_share_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AdminOrderViewModel viewModel, List<AdminOrderModel> filtered) {
    if (viewModel.isLoading && viewModel.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: _accent));
    }
    if (viewModel.error != null && viewModel.orders.isEmpty) {
      return _errorState(viewModel.error!, () => viewModel.fetchOrders());
    }
    if (filtered.isEmpty) {
      return _emptyState();
    }

    return RefreshIndicator(
      color: _accent,
      onRefresh: () => viewModel.fetchOrders(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemCount: filtered.length + (viewModel.hasMore && _filter == 'All' ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= filtered.length) {
            return Center(
              child: viewModel.isLoadingMore
                  ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(color: _accent))
                  : TextButton(onPressed: () => viewModel.loadMore(), child: const Text('Load More', style: TextStyle(color: _accent, fontWeight: FontWeight.w700))),
            );
          }
          return _FadeSlideIn(index: index, child: _orderTile(context, filtered[index]));
        },
      ),
    );
  }

  Widget _errorState(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 44, color: _textGrey),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: _textGrey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: _accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(color: _accent.withOpacity(0.08), shape: BoxShape.circle),
            child: const Icon(Icons.receipt_long_rounded, size: 40, color: _accent),
          ),
          const SizedBox(height: 16),
          const Text('No orders found', style: TextStyle(color: _textGrey, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _orderTile(BuildContext context, AdminOrderModel order) {
    final color = statusColor(order.status);
    final initials = _initials(order.customerName);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminOrderDetailScreen(orderId: order.id))),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 5, color: color),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [_accent.withOpacity(0.85), const Color(0xFF8B5CF6).withOpacity(0.85)]),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(order.orderId, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _textDark)),
                              const SizedBox(height: 3),
                              Text(order.customerName ?? 'Unknown customer', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: _textGrey)),
                              const SizedBox(height: 4),
                              Text(order.createdAt != null ? _formatDate(order.createdAt!) : '', style: const TextStyle(fontSize: 10, color: _textGrey)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('\$${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _textDark)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(statusIcon(order.status), size: 11, color: color),
                                  const SizedBox(width: 4),
                                  Text(order.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

/// Staggered fade + slide-up entrance for each tile.
class _FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int index;
  const _FadeSlideIn({required this.child, required this.index});

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 40 * (widget.index % 12)), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _fade, child: SlideTransition(position: _slide, child: widget.child));
  }
}