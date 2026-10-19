import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../admin/admin_model/admin_customer_model.dart';
import '../../admin/admin_viewmodel/admin_customer_viewmodel.dart';
import 'admin_customer_form.dart';

const Color _accent = Color(0xFF6366F1);
const Color _textDark = Color(0xFF0F172A);
const Color _textGrey = Color(0xFF64748B);
const Color _bg = Color(0xFFF5F6FA);

class AdminCustomersScreen extends StatefulWidget {
  const AdminCustomersScreen({super.key});

  @override
  State<AdminCustomersScreen> createState() => _AdminCustomersScreenState();
}

class _AdminCustomersScreenState extends State<AdminCustomersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminCustomerViewModel>().fetchCustomers();
    });
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
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

  Future<void> _confirmDelete(AdminCustomerViewModel viewModel, AdminCustomerModel customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete customer?'),
        content: Text('"${customer.displayName}" and their account will be permanently removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444)))),
        ],
      ),
    );
    if (confirmed != true) return;
    final success = await viewModel.deleteCustomer(customer);
    _showSnack(success ? 'Customer deleted' : (viewModel.error ?? 'Could not delete'), isError: !success);
  }

  Future<void> _openForm(AdminCustomerModel customer) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AdminCustomerFormScreen(customer: customer)),
    );
    if (result == true && mounted) {
      context.read<AdminCustomerViewModel>().fetchCustomers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminCustomerViewModel>();

    return Container(
      color: _bg,
      child: _buildBody(viewModel),
    );
  }

  Widget _buildBody(AdminCustomerViewModel viewModel) {
    if (viewModel.isLoading && viewModel.customers.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: _accent));
    }
    if (viewModel.error != null && viewModel.customers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 44, color: _textGrey),
            const SizedBox(height: 14),
            Text(viewModel.error!, style: const TextStyle(color: _textGrey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.fetchCustomers(),
              style: ElevatedButton.styleFrom(backgroundColor: _accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
    if (viewModel.customers.isEmpty) {
      return const Center(child: Text('No customers found', style: TextStyle(color: _textGrey)));
    }

    return RefreshIndicator(
      color: _accent,
      onRefresh: () => viewModel.fetchCustomers(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemCount: viewModel.customers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _customerTile(viewModel, viewModel.customers[index]),
      ),
    );
  }

  Widget _customerTile(AdminCustomerViewModel viewModel, AdminCustomerModel customer) {
    final bool busy = viewModel.isBusy(customer.id);
    final bool isTopSpender = customer.totalSpent > 50000;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: busy ? null : () => _openForm(customer),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: isTopSpender ? [const Color(0xFFF59E0B), const Color(0xFFF97316)] : [const Color(0xFF06B6D4), const Color(0xFF3B82F6)]),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(_initials(customer.displayName), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(customer.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark))),
                        if (isTopSpender)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(Icons.workspace_premium_rounded, size: 16, color: Color(0xFFF59E0B)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(customer.email, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: _textGrey)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.shopping_bag_outlined, size: 12, color: _textGrey),
                        const SizedBox(width: 4),
                        Text('${customer.ordersCount} orders', style: const TextStyle(fontSize: 11, color: _textGrey)),
                        const SizedBox(width: 10),
                        const Icon(Icons.payments_outlined, size: 12, color: Color(0xFF16A34A)),
                        const SizedBox(width: 4),
                        Text('\$${customer.totalSpent.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
                      ],
                    ),
                  ],
                ),
              ),
              busy
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _openForm(customer),
                          icon: const Icon(Icons.edit_outlined, size: 19, color: _accent),
                        ),
                        IconButton(
                          onPressed: () => _confirmDelete(viewModel, customer),
                          icon: const Icon(Icons.delete_outline_rounded, size: 19, color: Color(0xFFEF4444)),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}