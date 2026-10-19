import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../admin/admin_api_client.dart';
import '../../admin/admin_model/admin_employee_model.dart';
import '../../admin/admin_service/admin_employee_service.dart';

const Color _accent = Color(0xFF6366F1);
const Color _textDark = Color(0xFF0F172A);
const Color _textGrey = Color(0xFF64748B);
const Color _bg = Color(0xFFF5F6FA);

/// NOTE: the API gave no `_permission_options` hint (unlike other
/// endpoints) — this list is a best guess based on the admin sections
/// that actually exist. Confirm the real list if the server rejects
/// any of these values.
const List<String> _permissionOptions = [
  'Dashboard', 'Products', 'Orders', 'Returns', 'Payments', 'Employees', 'Customers', 'Support'
];

final RegExp _emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');

class AdminEmployeeFormScreen extends StatefulWidget {
  final AdminEmployeeModel? employee;
  const AdminEmployeeFormScreen({super.key, this.employee});

  @override
  State<AdminEmployeeFormScreen> createState() => _AdminEmployeeFormScreenState();
}

class _AdminEmployeeFormScreenState extends State<AdminEmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = AdminEmployeeService();

  late final TextEditingController _emailController;
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _pinController;
  late final TextEditingController _jobTitleController;
  final Set<String> _selectedPermissions = {};

  // Auto-generated, never typed by the admin — see _generateEmployeeId.
  String _employeeId = '';

  bool get _isEdit => widget.employee != null;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.employee;
    _emailController = TextEditingController(text: e?.userDetails.email ?? '');
    _fullNameController = TextEditingController(text: e?.displayName ?? '');
    _phoneController = TextEditingController(text: e?.phone ?? '');
    _pinController = TextEditingController();
    _jobTitleController = TextEditingController(text: e?.jobTitle ?? '');
    _employeeId = e?.employeeId ?? _generateEmployeeId();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    _jobTitleController.dispose();
    super.dispose();
  }

  /// Matches the confirmed working shape (e.g. "EMP0018") — a random
  /// 4-digit number, always zero-padded to 4 digits.
  String _generateEmployeeId() {
    final number = Random().nextInt(9999) + 1;
    return 'EMP${number.toString().padLeft(4, '0')}';
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

  Future<void> _save() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    setState(() => _isSaving = true);
    try {
      if (_isEdit) {
        await _service.updateEmployee(
          widget.employee!.id,
          fullName: _fullNameController.text.trim(),
          pin: _pinController.text.trim().isEmpty ? null : _pinController.text.trim(),
          jobTitle: _jobTitleController.text.trim().isEmpty ? null : _jobTitleController.text.trim(),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          permissions: _selectedPermissions.isEmpty ? null : _selectedPermissions.toList(),
        );
        _showSnack('Employee updated');
      } else {
        await _service.createEmployee(
          email: _emailController.text.trim(),
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          employeeId: _employeeId,
          pin: _pinController.text.trim(),
          jobTitle: _jobTitleController.text.trim(),
          permissions: _selectedPermissions.toList(),
        );
        _showSnack('Employee created');
      }
      if (mounted) Navigator.pop(context, true);
    } on AdminApiException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (_) {
      _showSnack('Could not save this employee. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _textDark,
        title: Text(_isEdit ? 'Edit Employee' : 'New Employee', style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            _card(
              title: 'Details',
              child: Column(
                children: [
                  if (!_isEdit) ...[
                    _employeeIdDisplay(),
                    const SizedBox(height: 12),
                  ],
                  _field('Full Name', _fullNameController, validator: (v) => (v == null || v.trim().isEmpty) ? 'Full name is required' : null),
                  const SizedBox(height: 12),
                  if (!_isEdit) ...[
                    _field(
                      'Email',
                      _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        if (value.isEmpty) return 'Email is required';
                        if (!_emailRegex.hasMatch(value)) return 'Enter a valid email address';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  _field(
                    'Phone',
                    _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      final value = v?.trim() ?? '';
                      if (value.isEmpty) return 'Phone is required';
                      if (value.length < 10) return 'Enter a valid 10-digit phone number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _field('Job Title', _jobTitleController, validator: (v) => (v == null || v.trim().isEmpty) ? 'Job title is required' : null),
                  const SizedBox(height: 12),
                  _field(
                    _isEdit ? 'New PIN (leave blank to keep current)' : 'PIN',
                    _pinController,
                    keyboardType: TextInputType.number,
                    obscure: true,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                    validator: (v) {
                      final value = v?.trim() ?? '';
                      if (_isEdit && value.isEmpty) return null; // optional on edit
                      if (value.isEmpty) return 'PIN is required';
                      if (value.length < 4) return 'PIN must be at least 4 digits';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _card(
              title: 'Permissions',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _permissionOptions.map((p) {
                  final selected = _selectedPermissions.contains(p);
                  return GestureDetector(
                    onTap: () => setState(() => selected ? _selectedPermissions.remove(p) : _selectedPermissions.add(p)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        gradient: selected ? const LinearGradient(colors: [_accent, Color(0xFF8B5CF6)]) : null,
                        color: selected ? null : _bg,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: selected ? [BoxShadow(color: _accent.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))] : null,
                      ),
                      child: Text(p, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? Colors.white : _textGrey)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(backgroundColor: _accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                child: _isSaving
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_isEdit ? 'Save Changes' : 'Create Employee', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Read-only display of the auto-generated employee ID — never a
  /// text field, with a regenerate button in case the admin wants a
  /// different random one before saving.
  Widget _employeeIdDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('EMPLOYEE ID (auto-generated)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _textGrey)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _accent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _accent.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.badge_rounded, size: 16, color: _accent),
              const SizedBox(width: 8),
              Expanded(child: Text(_employeeId, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _accent, letterSpacing: 0.5))),
              GestureDetector(
                onTap: () => setState(() => _employeeId = _generateEmployeeId()),
                child: const Icon(Icons.refresh_rounded, size: 18, color: _accent),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 6))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _textDark)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    bool obscure = false,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _textGrey)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          inputFormatters: inputFormatters,
          validator: validator,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: _bg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEF4444))),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5)),
            errorStyle: const TextStyle(fontSize: 11, color: Color(0xFFEF4444)),
          ),
        ),
      ],
    );
  }
}