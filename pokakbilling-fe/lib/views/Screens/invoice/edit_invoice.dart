////////////
///// lib/views/Screens/invoice/edit_invoice_screen.dart
library;

//add invoice file

import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/invoice/invoice_model.dart';
import 'package:pokakbilling/viewmodels/invoice_viewmodel.dart';
import 'package:provider/provider.dart';

class EditInvoiceScreen extends StatefulWidget {
  final InvoiceModel invoice;

  const EditInvoiceScreen({super.key, required this.invoice});

  @override
  State<EditInvoiceScreen> createState() => _EditInvoiceScreenState();
}

class _EditInvoiceScreenState extends State<EditInvoiceScreen> {
  // ── theme helpers ──────────────────────────────────────────────────────────
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bg => _isDark ? const Color(0xFF0F0E2E) : const Color(0xFFEEEEF5);
  Color get _cardBg =>
      _isDark ? const Color(0xFF1E1A3E).withValues(alpha: 0.85) : Colors.white;
  Color get _fg => _isDark ? Colors.white : const Color(0xFF0F0E2E);
  Color get _fgMuted => _isDark
      ? Colors.white.withValues(alpha: 0.50)
      : const Color(0xFF0F0E2E).withValues(alpha: 0.45);
  Color get _cardBorder => _isDark
      ? Colors.white.withValues(alpha: 0.09)
      : const Color(0xFF4F46E5).withValues(alpha: 0.12);
  Color get _primary =>
      _isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5);
  Color get _inputFill => _isDark
      ? Colors.white.withValues(alpha: 0.05)
      : const Color(0xFF4F46E5).withValues(alpha: 0.04);

  // ── shared remark controller ───────────────────────────────────────────────
  late TextEditingController _remarkCtrl;

  // ── intern-only controllers ────────────────────────────────────────────────
  late TextEditingController _feeCtrl;
  late TextEditingController _sgstCtrl;
  late TextEditingController _cgstCtrl;

  // ── client items ──────────────────────────────────────────────────────────
  // Each row: { product, quantity, unit_price, sgst_percentage, cgst_percentage }
  // We mirror the invoice.items and keep TextEditingControllers per row per field.
  late List<_ItemRow> _itemRows;

  @override
  void initState() {
    super.initState();

    final inv = widget.invoice;
    _remarkCtrl = TextEditingController(text: inv.remark);

    if (inv.invoiceType == 'intern') {
      _feeCtrl = TextEditingController(text: inv.feeAmount);
      _sgstCtrl = TextEditingController(text: inv.sgstPercentage);
      _cgstCtrl = TextEditingController(text: inv.cgstPercentage);
      _itemRows = [];
    } else {
      _feeCtrl = TextEditingController();
      _sgstCtrl = TextEditingController();
      _cgstCtrl = TextEditingController();
      _itemRows = inv.items.map((item) => _ItemRow.fromModel(item)).toList();
    }
  }

  @override
  void dispose() {
    _remarkCtrl.dispose();
    _feeCtrl.dispose();
    _sgstCtrl.dispose();
    _cgstCtrl.dispose();
    for (final row in _itemRows) {
      row.dispose();
    }
    super.dispose();
  }

  // ── submit ─────────────────────────────────────────────────────────────────
  void _submit() {
    final vm = Provider.of<InvoiceViewmodel>(context, listen: false);
    final inv = widget.invoice;

    if (inv.invoiceType == 'intern') {
      vm.editInternInvoice(
        inv.id,
        feeAmount: _feeCtrl.text.trim(),
        sgstPercentage: _sgstCtrl.text.trim(),
        cgstPercentage: _cgstCtrl.text.trim(),
        remark: _remarkCtrl.text.trim(),
        context: context,
        onSuccess: () => Navigator.pop(context),
      );
    } else {
      final items = _itemRows.map((row) {
        return {
          'product': row.productId,
          'quantity': row.quantityCtrl.text.trim(),
          'unit_price': row.unitPriceCtrl.text.trim(),
          'sgst_percentage': row.sgstCtrl.text.trim(),
          'cgst_percentage': row.cgstCtrl.text.trim(),
        };
      }).toList();

      vm.editClientInvoice(
        inv.id,
        items: items,
        remark: _remarkCtrl.text.trim(),
        context: context,
        onSuccess: () => Navigator.pop(context),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final inv = widget.invoice;
    final isIntern = inv.invoiceType == 'intern';

    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(inv),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── invoice info banner ──
            _infoBanner(inv),
            const SizedBox(height: 14),

            if (isIntern) ...[
              _sectionLabel('Intern Details'),
              const SizedBox(height: 8),
              _buildInternForm(),
            ] else ...[
              _sectionLabel('Invoice Items'),
              const SizedBox(height: 8),
              ..._itemRows.asMap().entries.map(
                    (e) => _buildItemCard(e.key, e.value),
                  ),
            ],

            const SizedBox(height: 14),
            _sectionLabel('Remark'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _remarkCtrl,
              hint: 'Enter remark',
              maxLines: 3,
            ),
            const SizedBox(height: 28),
            _buildSaveButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── app bar ────────────────────────────────────────────────────────────────
  AppBar _buildAppBar(InvoiceModel inv) {
    return AppBar(
      backgroundColor: _isDark ? const Color(0xFF0F0E2E) : Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_rounded, size: 18, color: _fg),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Edit Invoice',
            style: TextStyle(
              color: _fg,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          Text(
            inv.invoiceNumber,
            style: TextStyle(color: _fgMuted, fontSize: 10),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Divider(
          height: 0,
          thickness: 0.5,
          color: const Color(0xFF4F46E5).withValues(alpha: 0.10),
        ),
      ),
    );
  }

  // ── info banner ────────────────────────────────────────────────────────────
  Widget _infoBanner(InvoiceModel inv) {
    final isIntern = inv.invoiceType == 'intern';
    final color = isIntern ? const Color(0xFF8B5CF6) : const Color(0xFF10B981);
    final name = isIntern
        ? (inv.internName.isNotEmpty ? inv.internName : '—')
        : (inv.clientName.isNotEmpty ? inv.clientName : '—');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: _isDark
                ? Colors.black.withValues(alpha: 0.10)
                : const Color(0xFF4F46E5).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.receipt_rounded, size: 20, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(inv.invoiceNumber,
                    style: TextStyle(
                        color: _fg, fontSize: 13, fontWeight: FontWeight.w700)),
                Text(name, style: TextStyle(color: _fgMuted, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isIntern ? 'Intern' : 'Client',
                  style: TextStyle(
                      color: color, fontSize: 9, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹ ${inv.grandTotal}',
                style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── section label ──────────────────────────────────────────────────────────
  Widget _sectionLabel(String title) {
    return Text(
      title,
      style: TextStyle(
        color: _primary,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
    );
  }

  // ── intern form ────────────────────────────────────────────────────────────
  Widget _buildInternForm() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _feeCtrl,
            hint: 'Fee Amount',
            label: 'Fee Amount',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.currency_rupee_rounded,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _sgstCtrl,
                  hint: 'SGST %',
                  label: 'SGST %',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  controller: _cgstCtrl,
                  hint: 'CGST %',
                  label: 'CGST %',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── client item card ───────────────────────────────────────────────────────
  Widget _buildItemCard(int index, _ItemRow row) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: _primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  row.productName,
                  style: TextStyle(
                    color: _fg,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: row.quantityCtrl,
                  hint: 'Qty',
                  label: 'Quantity',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  controller: row.unitPriceCtrl,
                  hint: 'Unit Price',
                  label: 'Unit Price',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: row.sgstCtrl,
                  hint: 'SGST %',
                  label: 'SGST %',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  controller: row.cgstCtrl,
                  hint: 'CGST %',
                  label: 'CGST %',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── generic text field ─────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: _fg, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _fgMuted, fontSize: 12),
        hintText: hint,
        hintStyle: TextStyle(color: _fgMuted.withValues(alpha: 0.6), fontSize: 12),
        filled: true,
        fillColor: _inputFill,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 16, color: _primary)
            : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _primary, width: 1.5),
        ),
      ),
    );
  }

  // ── save button ────────────────────────────────────────────────────────────
  Widget _buildSaveButton() {
    return Consumer<InvoiceViewmodel>(
      builder: (context, vm, _) {
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: vm.editInvoiceLoader ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              disabledBackgroundColor: _primary.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: vm.editInvoiceLoader
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Save Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper: holds controllers for a single client-invoice item row
// ─────────────────────────────────────────────────────────────────────────────

class _ItemRow {
  final int productId;
  final String productName;
  final TextEditingController quantityCtrl;
  final TextEditingController unitPriceCtrl;
  final TextEditingController sgstCtrl;
  final TextEditingController cgstCtrl;

  _ItemRow({
    required this.productId,
    required this.productName,
    required this.quantityCtrl,
    required this.unitPriceCtrl,
    required this.sgstCtrl,
    required this.cgstCtrl,
  });

  factory _ItemRow.fromModel(InvoiceItemModel item) {
    return _ItemRow(
      productId: item.product ?? 0,
      productName: item.productName,
      quantityCtrl: TextEditingController(text: item.quantity),
      unitPriceCtrl: TextEditingController(text: item.unitPrice),
      sgstCtrl: TextEditingController(text: item.sgstPercentage),
      cgstCtrl: TextEditingController(text: item.cgstPercentage),
    );
  }

  void dispose() {
    quantityCtrl.dispose();
    unitPriceCtrl.dispose();
    sgstCtrl.dispose();
    cgstCtrl.dispose();
  }
}
