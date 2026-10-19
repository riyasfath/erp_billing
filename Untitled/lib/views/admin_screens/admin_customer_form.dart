import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../admin/admin_model/admin_customer_model.dart';
import '../../admin/admin_viewmodel/admin_customer_viewmodel.dart';

const Color _accent = Color(0xFF6366F1);
const Color _textDark = Color(0xFF0F172A);
const Color _textGrey = Color(0xFF64748B);
const Color _bg = Color(0xFFF5F6FA);

class AdminCustomerFormScreen extends StatefulWidget {
  final AdminCustomerModel customer;
  const AdminCustomerFormScreen({super.key, required this.customer});

  @override
  State<AdminCustomerFormScreen> createState() => _AdminCustomerFormScreenState();
}

class _AdminCustomerFormScreenState extends State<AdminCustomerFormScreen> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.customer.fullName ?? '');
    _emailController = TextEditingController(text: widget.customer.email);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
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

  Future<void> _save(AdminCustomerViewModel viewModel) async {
    if (_fullNameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      _showSnack('Name and email are required', isError: true);
      return;
    }
    final success = await viewModel.updateCustomer(
      widget.customer.id,
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      _showSnack('Customer updated');
      Navigator.pop(context, true);
    } else {
      _showSnack(viewModel.saveError ?? 'Could not update customer', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminCustomerViewModel>();
    final c = widget.customer;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _textDark,
        title: const Text('Edit Customer', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_accent, Color(0xFF8B5CF6)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: _accent.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${c.ordersCount} orders', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('\$${c.totalSpent.toStringAsFixed(2)} total spent', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.person_rounded, color: Colors.white, size: 32),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 6))]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _textDark)),
                const SizedBox(height: 14),
                _field('Full Name', _fullNameController),
                const SizedBox(height: 12),
                _field('Email', _emailController, keyboardType: TextInputType.emailAddress),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: viewModel.isSaving ? null : () => _save(viewModel),
              style: ElevatedButton.styleFrom(backgroundColor: _accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
              child: viewModel.isSaving
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _textGrey)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: _bg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}