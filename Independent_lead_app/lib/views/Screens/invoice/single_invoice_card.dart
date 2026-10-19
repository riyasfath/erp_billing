import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/invoice_viewmodel.dart';
import 'package:pokakbilling/views/Screens/invoice/add_invoice/add_invoice.dart';
import 'package:pokakbilling/views/Screens/invoice/view_invoice.dart';
import 'package:pokakbilling/views/commonWidgets/popups/delete_popup.dart';
import 'package:provider/provider.dart';

//====================API INTEGRATED ========================

Color _getStatusColor(String? status) {
  switch (status?.toLowerCase()) {
    case "final":
      return AppColors.green;

    case "draft":
      return Colors.orange;

    case "cancelled":
      return AppColors.red;

    default:
      return Colors.orange;
  }
}

String _getStatusText(String? status) {
  switch (status?.toLowerCase()) {
    case "final":
      return "Active";

    case "draft":
      return "Draft";

    case "cancelled":
      return "Cancel";

    default:
      return "Pending";
  }
}

class SingleInvoiceCard extends StatelessWidget {
  final int index;
  const SingleInvoiceCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InvoiceViewModel>(context);
    final invoice = provider.invoiceList[index];

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
                    _initials(invoice.clientNameDisplay ?? ""),
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
                            (invoice.clientNameDisplay).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cdark,
                              height: 1.0,
                            ),
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
                              Text(
                                "Invoice Date",
                                style: TextStyle(
                                  fontSize: 8,
                                  color: AppColors.ctext,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                invoice.date,
                                style: TextStyle(
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

                        /// DUE DATE
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Due Date",
                                style: TextStyle(
                                  fontSize: 8,
                                  color: AppColors.red.withOpacity(0.6),
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                invoice.dueDate,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: AppColors.red,
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
                              Text(
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
                                  "₹ ${invoice.grandTotal}",
                                  style: TextStyle(
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
                            Text(
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
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getStatusColor(invoice.status)
                                      .withOpacity(0.4),
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
                    ViewInvoice(invoiceid: invoice.id),
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
                      AddInvoices(
                        invoiceId: invoice.id,
                        invoiceNumber: invoice.invoiceNumber,
                        isEdit: true,
                      ),
                    );

                    Future.microtask(() {
                      provider.getInvoiceById(invoice.id);
                    });
                  }),
              const SizedBox(width: 8),
              Consumer<InvoiceViewModel>(
                builder: (context, provider, _) => _ActionBtn(
                  label: 'Delete',
                  icon: Icons.delete_outline_rounded,
                  color: AppColors.tagRed,
                  filled: false,
                  onTap: () => showDeleteDialog(
                    context,
                    "Invoice",
                    () => provider.deleteInvoice(
                      invoice.id,
                      context,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    if (name.isEmpty) return "";
    final parts = name.split(" ");
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
    color: AppColors.cborder.withOpacity(0.5),
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
          color: filled ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: filled ? null : Border.all(color: color.withOpacity(0.35)),
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
