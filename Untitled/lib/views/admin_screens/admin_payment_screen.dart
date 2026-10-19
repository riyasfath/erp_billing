import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../admin/admin_model/admin_payment_model.dart';
import '../../admin/admin_viewmodel/admin_payment_viewmodel.dart';
import 'admin_orders_screen.dart' show statusColor, statusIcon;

const Color _accent = Color(0xFF6366F1);
const Color _textDark = Color(0xFF0F172A);
const Color _textGrey = Color(0xFF64748B);
const Color _bg = Color(0xFFF5F6FA);

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminPaymentViewModel>().fetchPayments();
    });
  }

  Future<void> _export(AdminPaymentViewModel viewModel) async {
    final success = await viewModel.exportPayments();
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.exportError ?? 'Export failed'), backgroundColor: const Color(0xFFEF4444)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminPaymentViewModel>();

    return Container(
      color: _bg,
      child: Column(
        children: [
          _buildSummaryBar(viewModel),
          Expanded(child: _buildBody(viewModel)),
        ],
      ),
    );
  }

  Widget _buildSummaryBar(AdminPaymentViewModel viewModel) {
    final completed = viewModel.payments.where((p) => p.status.toLowerCase() == 'completed').fold<double>(0, (s, p) => s + p.amount);
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_accent, Color(0xFF8B5CF6)]),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: _accent.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TOTAL COMPLETED', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text('\$${completed.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('${viewModel.payments.length} transactions', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11)),
              ],
            ),
          ),
          GestureDetector(
            onTap: viewModel.isExporting ? null : () => _export(viewModel),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
              child: viewModel.isExporting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.ios_share_rounded, size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Text('Export', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AdminPaymentViewModel viewModel) {
    if (viewModel.isLoading && viewModel.payments.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: _accent));
    }
    if (viewModel.error != null && viewModel.payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 44, color: _textGrey),
            const SizedBox(height: 14),
            Text(viewModel.error!, style: const TextStyle(color: _textGrey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.fetchPayments(),
              style: ElevatedButton.styleFrom(backgroundColor: _accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
    if (viewModel.payments.isEmpty) {
      return const Center(child: Text('No payments found', style: TextStyle(color: _textGrey)));
    }

    return RefreshIndicator(
      color: _accent,
      onRefresh: () => viewModel.fetchPayments(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        itemCount: viewModel.payments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _paymentTile(viewModel.payments[index]),
      ),
    );
  }

  Widget _paymentTile(AdminPaymentModel payment) {
    final color = statusColor(payment.status);
    final bool isNegative = payment.amount < 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.withOpacity(0.85), color.withOpacity(0.55)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_methodIcon(payment.method), color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payment.formattedTransactionId, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _textDark)),
                const SizedBox(height: 3),
                Text(payment.customerName ?? 'Unknown', style: const TextStyle(fontSize: 11, color: _textGrey)),
                const SizedBox(height: 2),
                Text('${payment.orderId} · ${payment.date}', style: const TextStyle(fontSize: 10, color: _textGrey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isNegative ? '-' : ''}\$${payment.amount.abs().toStringAsFixed(2)}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: isNegative ? const Color(0xFFEF4444) : _textDark),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon(payment.status), size: 11, color: color),
                    const SizedBox(width: 4),
                    Text(payment.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _methodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cod':
      case 'cash_on_delivery':
        return Icons.local_shipping_outlined;
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
      case 'netbanking':
        return Icons.account_balance_outlined;
      case 'credit_card':
        return Icons.credit_card_outlined;
      case 'online':
        return Icons.language_outlined;
      default:
        return Icons.payments_outlined;
    }
  }
}