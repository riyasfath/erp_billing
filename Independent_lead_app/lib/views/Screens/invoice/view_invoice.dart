import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/core/utils/text_utils.dart';
import 'package:pokakbilling/viewmodels/invoice_viewmodel.dart';
import 'package:pokakbilling/viewmodels/quotation/quotation_viewmodel.dart';
import 'package:pokakbilling/views/Screens/invoice/invoice_item.dart';
import 'package:pokakbilling/views/Screens/quotation/view/view_terms_and_conditions.dart';
import 'package:provider/provider.dart';

class ViewInvoice extends StatefulWidget {
  final int invoiceid;
  const ViewInvoice({super.key, required this.invoiceid});

  @override
  State<ViewInvoice> createState() => _ViewInvoiceState();
}

class _ViewInvoiceState extends State<ViewInvoice>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
//================ Qu.No ======================
  String _getQuotationNumber(int? quotationId) {
    if (quotationId == null) return "-";

    final quotationVM = Provider.of<QuotationViewmodel>(context, listen: false);

    try {
      final quotation = quotationVM.quotationList.firstWhere(
        (q) => q.quotationId == quotationId,
      );
      return quotation.quotationNumber ?? "-";
    } catch (e) {
      return "-";
    }
  }

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
    Future.microtask(() {
      Provider.of<InvoiceViewModel>(context, listen: false)
          .getInvoiceById(widget.invoiceid);
      Provider.of<QuotationViewmodel>(context, listen: false)
          .getAllQuotations();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceViewModel>(context);
    final invoice = invoiceProvider.singleInvoice;
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;

    if (invoice == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final name = (invoice.clientNameDisplay?.isNotEmpty == true)
        ? invoice.clientNameDisplay!
        : (invoice.clientName ?? "—");

    final initials = name.isNotEmpty
        ? name.trim().split(" ").map((e) => e[0]).take(2).join()
        : "";

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            _buildHeader(context, sw, topPad, invoice.id, name, initials),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),

                        // ==================== Invoive Info =====================
                        _buildInfoCard(
                          icon: Icons.description_outlined,
                          title: "Invoice Info",
                          rows: [
                            _InfoRow(
                                Icons.tag, "Invoice No", invoice.invoiceNumber),
                            _InfoRow(
                                Icons.calendar_today, "Date", invoice.date),
                            _InfoRow(Icons.calendar_today, "Due Date",
                                invoice.dueDate),
                            _InfoRow(
                              Icons.description,
                              "Quotation",
                              _getQuotationNumber(invoice.quotation),
                            ),
                            _InfoRow(Icons.person, "Client Name", name),
                            _InfoRow(Icons.work_outline, "Project",
                                invoice.projectName),
                            _InfoRow(Icons.receipt_long, "Invoice Type",
                                invoice.invoiceType),
                            _InfoRow(Icons.verified, "Status", invoice.status),
                            _InfoRow(Icons.location_on_outlined, "Location",
                                invoice.companyLocation),
                            _InfoRow(Icons.home_outlined, "Address",
                                invoice.companyAddress),
                          ],
                        ),

                        const SizedBox(height: 12),
                        _buildProductHeader(),
                        const SizedBox(height: 12),
                        if (invoice.items.isEmpty)
                          const Text(
                            "No products added",
                            style: TextStyle(
                              color: AppColors.ctext,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else
                          Column(
                            children: List.generate(
                              invoice.items.length,
                              (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: InvoiceItemCard(
                                  index: index,
                                  item: invoice.items[index],
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 12),

                        _buildPricingSummary(invoice),
                        const SizedBox(height: 12),
                        _buildPaymentDetails(invoice),
                        const SizedBox(height: 12),

                        const SizedBox(height: 12),

                        // ── TERMS ───────────────────────────────
                        const ViewTermsAndConditions(),
                        const SizedBox(height: 12),

                        _buildExitButton(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double sw, double topPad, id,
      String name, String initials) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topPad + 12,
        bottom: 40,
        left: sw * 0.045,
        right: sw * 0.045,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.cborder, width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back + title row
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.cxl,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.cborder),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.c3,
                    size: 15,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Invoice View',
                style: TextStyle(
                  color: AppColors.cdark,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              // ID badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.cxl,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cborder),
                ),
                child: Text(
                  "IN.YID #$id",
                  style: const TextStyle(
                    color: AppColors.c1,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Avatar + name row
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: AppColors.cxl,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cborder),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: AppColors.c1,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.cdark,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRowGroup(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: children.map((e) => Expanded(child: e)).toList(),
      ),
    );
  }

  Widget _mini(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.c1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.c1,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildPricingSummary(invoice) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cborder),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _row("Subtotal (Before Tax)", invoice.subtotal ?? "0"),
          _row("Taxable Amount", invoice.taxableAmount ?? "0"),
          _row("Total Tax", invoice.taxTotal ?? "0"),
          const Divider(
            height: 20,
            thickness: 1,
            color: AppColors.cborder,
          ),
          _row(
            "Grand Total",
            invoice.grandTotal ?? "0",
            isBold: true,
            color: AppColors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails(invoice) {
    final paid = double.tryParse(invoice.paidAmount ?? "0") ?? 0;
    final total = double.tryParse(invoice.grandTotal ?? "0") ?? 0;
    final balance = total - paid;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cborder),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _miniRow("Payment Status", invoice.paymentStatus ?? "-"),
          _miniRow("Payment Method", invoice.paymentMethod ?? "-"),
          _miniRow("Paid Amount", "₹ ${invoice.paidAmount ?? "0"}"),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.cxl,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cborder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Balance Due",
                  style: TextStyle(
                    color: AppColors.ctext,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "₹ ${balance.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: balance == 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String title, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.cdark,
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
            ),
          ),
          Text(
            "₹ $value",
            style: TextStyle(
              color: AppColors.cdark,
              fontSize: isBold ? 16 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.cdark,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.cdark,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cborder),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cborder),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.c1,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            "Product",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.ctext),
          ),
        ],
      ),
    );
  }

  // ── INFO CARD (REUSED) ─────────────────────────────────────────
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<_InfoRow> rows,
  }) {
    final visibleRows = rows.where((r) => r.value.isNotEmpty).toList();
    if (visibleRows.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cborder),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.cxl,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cborder),
                  ),
                  child: Icon(icon, color: AppColors.c1, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  capitalizeWords(title),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ctext,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.cborder),

          // Field rows
          ...visibleRows.asMap().entries.map((entry) {
            final i = entry.key;
            final row = entry.value;
            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.cxl,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.cborder),
                        ),
                        child: Icon(row.icon, size: 14, color: AppColors.c1),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.label,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.ctext,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              row.value,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.cdark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < visibleRows.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.cborder,
                    indent: 56,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ── Exit / Go Back button ─────────────────────────────────────────────────
  Widget _buildExitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.c1,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: AppColors.c1.withOpacity(0.30),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.white, size: 14),
              SizedBox(width: 8),
              Text(
                'Go Back',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── ROW MODEL ─────────────────────────────────────────────
class _InfoRow {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);
}
