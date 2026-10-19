import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../admin/admin_model/admin_return_model.dart';
import '../../admin/admin_viewmodel/admin_return_viewmodel.dart';
import 'admin_orders_screen.dart' show statusColor, statusIcon;

const Color _accent = Color(0xFF6366F1);
const Color _textDark = Color(0xFF0F172A);
const Color _textGrey = Color(0xFF64748B);
const Color _bg = Color(0xFFF5F6FA);
const Color _danger = Color(0xFFEF4444);

const List<Map<String, dynamic>> _actions = [
  {'value': 'approve', 'label': 'Approve', 'icon': Icons.check_circle_rounded, 'color': Color(0xFF16A34A)},
  {'value': 'schedule_pickup', 'label': 'Schedule Pickup', 'icon': Icons.event_rounded, 'color': Color(0xFF3B82F6)},
  {'value': 'mark_picked_up', 'label': 'Mark Picked Up', 'icon': Icons.local_shipping_rounded, 'color': Color(0xFF06B6D4)},
  {'value': 'quality_check_pass', 'label': 'QC: Pass', 'icon': Icons.verified_rounded, 'color': Color(0xFF8B5CF6)},
  {'value': 'initiate_refund', 'label': 'Initiate Refund', 'icon': Icons.hourglass_top_rounded, 'color': Color(0xFFF59E0B)},
  {'value': 'complete_refund', 'label': 'Complete Refund', 'icon': Icons.task_alt_rounded, 'color': Color(0xFF16A34A)},
  {'value': 'quality_check_fail', 'label': 'QC: Fail', 'icon': Icons.cancel_rounded, 'color': _danger},
];

const List<String> _rejectionCategories = ['item_mismatch', 'missing_parts', 'damage', 'fake_product', 'verification_failed'];

class AdminReturnDetailScreen extends StatefulWidget {
  final int returnId;
  const AdminReturnDetailScreen({super.key, required this.returnId});

  @override
  State<AdminReturnDetailScreen> createState() => _AdminReturnDetailScreenState();
}

class _AdminReturnDetailScreenState extends State<AdminReturnDetailScreen> {
  String? _selectedCategory;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminReturnViewModel>().fetchDetail(widget.returnId);
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? _danger : const Color(0xFF16A34A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  Future<void> _runAction(AdminReturnViewModel viewModel, String action) async {
    if (action == 'quality_check_fail' && _selectedCategory == null) {
      _showSnack('Pick a rejection category first', isError: true);
      return;
    }
    final success = await viewModel.processReturn(
      widget.returnId,
      action,
      category: action == 'quality_check_fail' ? _selectedCategory : null,
      note: action == 'quality_check_fail' && _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
    );
    if (!mounted) return;
    if (success) {
      _showSnack('Return updated');
      setState(() {
        _selectedCategory = null;
        _noteController.clear();
      });
    } else {
      _showSnack(viewModel.detailError ?? 'Could not process return', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminReturnViewModel>();
    final ret = viewModel.selectedReturn;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _textDark,
        title: Text(ret?.returnId ?? 'Return', style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: viewModel.isLoadingDetail
          ? const Center(child: CircularProgressIndicator(color: _accent))
          : viewModel.detailError != null && ret == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(viewModel.detailError!, style: const TextStyle(color: _textGrey)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => viewModel.fetchDetail(widget.returnId),
                        style: ElevatedButton.styleFrom(backgroundColor: _accent),
                        child: const Text('Retry', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : ret == null
                  ? const SizedBox.shrink()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      children: [
                        _statusHeader(ret),
                        const SizedBox(height: 16),
                        _card(title: 'Product', icon: Icons.inventory_2_rounded, iconColor: _accent, child: _productInfo(ret)),
                        const SizedBox(height: 16),
                        _card(title: 'Customer', icon: Icons.person_rounded, iconColor: const Color(0xFF06B6D4), child: _customerInfo(ret)),
                        const SizedBox(height: 16),
                        _card(title: 'Return Reason', icon: Icons.info_rounded, iconColor: const Color(0xFFF59E0B), child: _reasonInfo(ret)),
                        if (ret.rejectionReason != null || ret.rejectionCategory != null) ...[
                          const SizedBox(height: 16),
                          _card(title: 'Rejection Details', icon: Icons.block_rounded, iconColor: _danger, child: _rejectionInfo(ret)),
                        ],
                        const SizedBox(height: 16),
                        _card(title: 'Process Return', icon: Icons.settings_suggest_rounded, iconColor: const Color(0xFF8B5CF6), child: _actionForm(viewModel)),
                      ],
                    ),
    );
  }

  Widget _statusHeader(AdminReturnModel ret) {
    final color = statusColor(ret.status);
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
                child: Icon(statusIcon(ret.status), color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ret.status.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: 0.5)),
                    const SizedBox(height: 2),
                    Text('Order #${ret.orderId}', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
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
              Text('REFUND AMOUNT', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
              Text('\$${ret.refundAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24)),
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

  Widget _productInfo(AdminReturnModel ret) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 64,
            height: 64,
            child: ret.imageUrl != null
                ? Image.network(ret.imageUrl!, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: _bg))
                : Container(color: _bg, child: const Icon(Icons.image_outlined, color: _textGrey)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ret.productName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark)),
              const SizedBox(height: 4),
              Text('Size ${ret.productSize} · ${ret.productColor}', style: const TextStyle(fontSize: 12, color: _textGrey)),
              const SizedBox(height: 4),
              Text('\$${ret.productPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _accent)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _customerInfo(AdminReturnModel ret) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow(Icons.badge_outlined, 'Name', ret.customerName),
        _infoRow(Icons.mail_outline_rounded, 'Email', ret.customerEmail),
      ],
    );
  }

  Widget _reasonInfo(AdminReturnModel ret) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow(Icons.report_problem_outlined, 'Reason', ret.reason.replaceAll('_', ' ')),
        if (ret.comment.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(ret.comment, style: const TextStyle(fontSize: 12, color: _textGrey)),
        ],
      ],
    );
  }

  Widget _rejectionInfo(AdminReturnModel ret) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ret.rejectionCategory != null) _infoRow(Icons.category_outlined, 'Category', ret.rejectionCategory!.replaceAll('_', ' ')),
        if (ret.rejectionReason != null) ...[
          const SizedBox(height: 6),
          Text(ret.rejectionReason!, style: const TextStyle(fontSize: 12, color: _textGrey)),
        ],
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: _textGrey),
          const SizedBox(width: 8),
          SizedBox(width: 70, child: Text(label, style: const TextStyle(fontSize: 12, color: _textGrey))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textDark))),
        ],
      ),
    );
  }

  Widget _actionForm(AdminReturnViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _actions.map((a) {
            final Color color = a['color'] as Color;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: viewModel.isProcessing ? null : () => _runAction(viewModel, a['value'] as String),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(a['icon'] as IconData, size: 14, color: color),
                      const SizedBox(width: 6),
                      Text(a['label'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        const Text('IF REJECTING — CATEGORY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _textGrey, letterSpacing: 0.8)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _rejectionCategories.map((c) {
            final selected = c == _selectedCategory;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = selected ? null : c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                decoration: BoxDecoration(
                  gradient: selected ? const LinearGradient(colors: [_danger, Color(0xFFEF7676)]) : null,
                  color: selected ? null : _bg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(c.replaceAll('_', ' '), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: selected ? Colors.white : _textGrey)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _noteController,
          maxLines: 2,
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Rejection note (optional)',
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            filled: true,
            fillColor: _bg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
        ),
        if (viewModel.isProcessing) ...[
          const SizedBox(height: 14),
          const Center(child: CircularProgressIndicator(color: _accent)),
        ],
      ],
    );
  }
}