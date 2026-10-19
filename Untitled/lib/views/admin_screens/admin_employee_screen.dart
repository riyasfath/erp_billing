import 'package:ecommerce_app/views/admin_screens/admin_emp_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../admin/admin_model/admin_employee_model.dart';
import '../../admin/admin_viewmodel/admin_employee_viewmodel.dart';

const Color _accent = Color(0xFF6366F1);
const Color _textDark = Color(0xFF0F172A);
const Color _textGrey = Color(0xFF64748B);
const Color _bg = Color(0xFFF5F6FA);

class AdminEmployeesScreen extends StatefulWidget {
  const AdminEmployeesScreen({super.key});

  @override
  State<AdminEmployeesScreen> createState() => _AdminEmployeesScreenState();
}

class _AdminEmployeesScreenState extends State<AdminEmployeesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminEmployeeViewModel>().fetchEmployees();
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

  Future<void> _confirmDelete(AdminEmployeeViewModel viewModel, AdminEmployeeModel emp) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove employee?'),
        content: Text('"${emp.displayName}" will lose admin access.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove', style: TextStyle(color: Color(0xFFEF4444)))),
        ],
      ),
    );
    if (confirmed != true) return;
    final success = await viewModel.deleteEmployee(emp);
    _showSnack(success ? 'Employee removed' : (viewModel.error ?? 'Could not remove'), isError: !success);
  }

  Future<void> _openForm({AdminEmployeeModel? employee}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AdminEmployeeFormScreen(employee: employee)),
    );
    if (result == true && mounted) {
      context.read<AdminEmployeeViewModel>().fetchEmployees();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminEmployeeViewModel>();

    return Container(
      color: _bg,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'admin_employees_fab',
          backgroundColor: _accent,
          onPressed: () => _openForm(),
          icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
          label: const Text('New Employee', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
        body: _buildBody(viewModel),
      ),
    );
  }

  Widget _buildBody(AdminEmployeeViewModel viewModel) {
    if (viewModel.isLoading && viewModel.employees.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: _accent));
    }
    if (viewModel.error != null && viewModel.employees.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 44, color: _textGrey),
            const SizedBox(height: 14),
            Text(viewModel.error!, style: const TextStyle(color: _textGrey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.fetchEmployees(),
              style: ElevatedButton.styleFrom(backgroundColor: _accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
    if (viewModel.employees.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(color: _accent.withOpacity(0.08), shape: BoxShape.circle),
              child: const Icon(Icons.badge_rounded, size: 40, color: _accent),
            ),
            const SizedBox(height: 16),
            const Text('No employees yet', style: TextStyle(color: _textGrey, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _accent,
      onRefresh: () => viewModel.fetchEmployees(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: viewModel.employees.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _employeeTile(viewModel, viewModel.employees[index]),
      ),
    );
  }

  Widget _employeeTile(AdminEmployeeViewModel viewModel, AdminEmployeeModel emp) {
    final bool busy = viewModel.isBusy(emp.id);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: busy ? null : () => _openForm(employee: emp),
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
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [_accent, Color(0xFF8B5CF6)]),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(_initials(emp.displayName), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(emp.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark)),
                    const SizedBox(height: 3),
                    Text(emp.jobTitle, style: const TextStyle(fontSize: 12, color: _textGrey)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: _accent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(emp.employeeId, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _accent)),
                        ),
                        const SizedBox(width: 6),
                        Flexible(child: Text(emp.userDetails.email, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: _textGrey))),
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
                          onPressed: () => _openForm(employee: emp),
                          icon: const Icon(Icons.edit_outlined, size: 19, color: _accent),
                        ),
                        IconButton(
                          onPressed: () => _confirmDelete(viewModel, emp),
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