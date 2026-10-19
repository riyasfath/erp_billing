import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/invoice/invoice_model.dart';
import 'package:pokakbilling/views/Screens/invoice/add_invoice.dart';
import 'package:pokakbilling/views/Screens/invoice/view_invoice_detail.dart';

//==================== Status helpers ========================

Color _getStatusColor(String? status) {
  switch (status?.toLowerCase()) {
    case "paid":
      return AppColors.green;

    case "unpaid":
      return Colors.orange;

    case "cancelled":
      return AppColors.red;

    default:
      return Colors.orange;
  }
}

String _getStatusText(String? status) {
  switch (status?.toLowerCase()) {
    case "paid":
      return "Paid";

    case "unpaid":
      return "Unpaid";

    case "cancelled":
      return "Cancelled";

    default:
      return "Pending";
  }
}

class SingleInvoiceCard extends StatelessWidget {
  final InvoiceModel invoice;
  const SingleInvoiceCard({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final isClient = invoice.invoiceType == 'client';
    final name =
        isClient ? (invoice.clientName ?? '') : (invoice.internName ?? '');
    final typeLabel = isClient ? 'Client' : 'Student';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.cxl,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.cborder,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    _initials(name),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.c1,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            (name.isEmpty ? '—' : name).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cdark,
                              height: 1.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          invoice.invoiceNumber,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.cdark,
                              height: 1.0),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    /// TYPE BADGE
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isClient
                            ? AppColors.c1.withValues(alpha: 0.10)
                            : Colors.orange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        typeLabel,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color:
                              isClient ? AppColors.c1 : Colors.orange.shade700,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        /// INVOICE DATE
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Invoice Date",
                                style: TextStyle(
                                  fontSize: 8,
                                  color: AppColors.ctext,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                invoice.invoiceDate ?? '—',
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: AppColors.ctext,
                                  fontWeight: FontWeight.w600,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// DIVIDER
                        _verticalDivider(),

                        /// AMOUNT
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Amount",
                                style: TextStyle(
                                  fontSize: 8,
                                  color: AppColors.tagGreen,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 2),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "₹ ${invoice.grandTotal ?? "0"}",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.green,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// DIVIDER
                        _verticalDivider(),

                        /// STATUS
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Status",
                              style: TextStyle(
                                fontSize: 8,
                                color: AppColors.ctext,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getStatusColor(invoice.status)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getStatusColor(invoice.status)
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                _getStatusText(invoice.status),
                                style: TextStyle(
                                  fontSize: 8,
                                  height: 1.0,
                                  fontWeight: FontWeight.w700,
                                  color: _getStatusColor(invoice.status),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: AppColors.cborder,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 10, 24, 12),
          child: Row(
            children: [
              _ActionBtn(
                label: "View",
                icon: Icons.visibility_outlined,
                color: AppColors.c1,
                filled: true,
                onTap: () {
                  pushNavigation(
                    context,
                    ViewInvoiceDetail(invoice: invoice),
                  );
                },
              ),
              const SizedBox(width: 8),
              _ActionBtn(
                  label: "Edit",
                  icon: Icons.edit_outlined,
                  color: AppColors.c3,
                  filled: false,
                  onTap: () {
                    pushNavigation(
                      context,
                      AddInvoiceScreen(
                        isEdit: true,
                        invoice: invoice,
                      ),
                    );
                  }),
            ],
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    if (name.trim().isEmpty) return "?";
    final parts = name.trim().split(" ");
    return parts.length > 1
        ? "${parts[0][0]}${parts[1][0]}".toUpperCase()
        : parts[0][0].toUpperCase();
  }
}

Widget _verticalDivider() {
  return Container(
    height: 24,
    width: 1,
    margin: const EdgeInsets.symmetric(horizontal: 6),
    color: AppColors.cborder.withValues(alpha: 0.5),
  );
}

// ─── Same Action Button ─────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: filled ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: filled ? null : Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: filled ? AppColors.white : color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: filled ? AppColors.white : color,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
