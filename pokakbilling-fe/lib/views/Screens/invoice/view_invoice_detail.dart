// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/models/data-models/invoice/invoice_model.dart';

// class ViewInvoiceDetail extends StatefulWidget {
//   final InvoiceModel invoice;
//   const ViewInvoiceDetail({super.key, required this.invoice});

//   @override
//   State<ViewInvoiceDetail> createState() => _ViewInvoiceDetailState();
// }

// class _ViewInvoiceDetailState extends State<ViewInvoiceDetail>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _animCtrl;
//   late final Animation<double> _fadeAnim;
//   late final Animation<Offset> _slideAnim;

//   @override
//   void initState() {
//     super.initState();
//     _animCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );
//     _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
//     _slideAnim = Tween<Offset>(
//       begin: const Offset(0, 0.06),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
//     _animCtrl.forward();
//   }

//   @override
//   void dispose() {
//     _animCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final invoice = widget.invoice;
//     final sw = MediaQuery.of(context).size.width;
//     final topPad = MediaQuery.of(context).padding.top;

//     final isClient = invoice.invoiceType == 'client';
//     final name = isClient
//         ? (invoice.clientName?.isNotEmpty == true ? invoice.clientName! : "—")
//         : (invoice.internName?.isNotEmpty == true ? invoice.internName! : "—");

//     final initials = name.trim().isNotEmpty && name != "—"
//         ? name.trim().split(" ").map((e) => e[0]).take(2).join().toUpperCase()
//         : "?";

//     return Scaffold(
//       backgroundColor: AppColors.white,
//       body: SizedBox(
//         width: double.infinity,
//         height: double.infinity,
//         child: Column(
//           children: [
//             _buildHeader(
//                 context, sw, topPad, invoice.invoiceNumber, name, initials),
//             Expanded(
//               child: FadeTransition(
//                 opacity: _fadeAnim,
//                 child: SlideTransition(
//                   position: _slideAnim,
//                   child: SingleChildScrollView(
//                     padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
//                     child: Column(
//                       children: [
//                         const SizedBox(height: 12),

//                         // ==================== Invoice Info =====================
//                         _buildInfoCard(
//                           icon: Icons.description_outlined,
//                           title: "Invoice Info",
//                           rows: [
//                             _InfoRow(
//                                 Icons.tag, "Invoice No", invoice.invoiceNumber),
//                             _InfoRow(Icons.calendar_today, "Invoice Date",
//                                 invoice.invoiceDate ?? ""),
//                             _InfoRow(
//                               isClient ? Icons.person : Icons.school_outlined,
//                               isClient ? "Client Name" : "Student Name",
//                               name == "—" ? "" : name,
//                             ),
//                             if (!isClient)
//                               _InfoRow(Icons.menu_book_outlined, "Course",
//                                   invoice.courseName ?? ""),
//                             _InfoRow(
//                               Icons.category_outlined,
//                               "Invoice Type",
//                               isClient ? "Client" : "Student",
//                             ),
//                             _InfoRow(
//                                 Icons.verified, "Status", invoice.status ?? ""),
//                           ],
//                         ),

//                         const SizedBox(height: 12),

//                         _buildPricingSummary(invoice),

//                         const SizedBox(height: 12),

//                         _buildExitButton(context),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(BuildContext context, double sw, double topPad,
//       String invoiceNumber, String name, String initials) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.only(
//         top: topPad + 12,
//         bottom: 40,
//         left: sw * 0.045,
//         right: sw * 0.045,
//       ),
//       decoration: const BoxDecoration(
//         color: AppColors.white,
//         border: Border(
//           bottom: BorderSide(color: AppColors.cborder, width: 1.5),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Back + title row
//           Row(
//             children: [
//               GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: Container(
//                   width: 36,
//                   height: 36,
//                   decoration: BoxDecoration(
//                     color: AppColors.cxl,
//                     shape: BoxShape.circle,
//                     border: Border.all(color: AppColors.cborder),
//                   ),
//                   child: const Icon(
//                     Icons.arrow_back_ios_new_rounded,
//                     color: AppColors.c3,
//                     size: 15,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               const Text(
//                 'Invoice View',
//                 style: TextStyle(
//                   color: AppColors.cdark,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               const Spacer(),
//               // Invoice number badge
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                 decoration: BoxDecoration(
//                   color: AppColors.cxl,
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: AppColors.cborder),
//                 ),
//                 child: Text(
//                   invoiceNumber,
//                   style: const TextStyle(
//                     color: AppColors.c1,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 20),

//           // Avatar + name row
//           Row(
//             children: [
//               Container(
//                 width: 62,
//                 height: 62,
//                 decoration: BoxDecoration(
//                   color: AppColors.cxl,
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: AppColors.cborder),
//                 ),
//                 child: Center(
//                   child: Text(
//                     initials,
//                     style: const TextStyle(
//                       color: AppColors.c1,
//                       fontSize: 22,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       name.toUpperCase(),
//                       style: const TextStyle(
//                         color: AppColors.cdark,
//                         fontSize: 17,
//                         fontWeight: FontWeight.w800,
//                         letterSpacing: 0.5,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPricingSummary(InvoiceModel invoice) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppColors.cborder),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.c1.withOpacity(0.05),
//             blurRadius: 12,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           _row(
//             "Grand Total",
//             "${invoice.grandTotal ?? "0"}",
//             isBold: true,
//             color: AppColors.green,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _row(String title, String value, {bool isBold = false, Color? color}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               color: AppColors.cdark,
//               fontSize: 13,
//               fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
//             ),
//           ),
//           Text(
//             "₹ $value",
//             style: TextStyle(
//               color: color ?? AppColors.cdark,
//               fontSize: isBold ? 16 : 13,
//               fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── INFO CARD (REUSED) ─────────────────────────────────────────
//   Widget _buildInfoCard({
//     required IconData icon,
//     required String title,
//     required List<_InfoRow> rows,
//   }) {
//     final visibleRows = rows.where((r) => r.value.isNotEmpty).toList();
//     if (visibleRows.isEmpty) return const SizedBox.shrink();

//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppColors.cborder),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.c1.withOpacity(0.06),
//             blurRadius: 14,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Card header
//           Padding(
//             padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
//             child: Row(
//               children: [
//                 Container(
//                   width: 32,
//                   height: 32,
//                   decoration: BoxDecoration(
//                     color: AppColors.cxl,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: AppColors.cborder),
//                   ),
//                   child: Icon(icon, color: AppColors.c1, size: 16),
//                 ),
//                 const SizedBox(width: 10),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w700,
//                     color: AppColors.ctext,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const Divider(height: 1, thickness: 1, color: AppColors.cborder),

//           // Field rows
//           ...visibleRows.asMap().entries.map((entry) {
//             final i = entry.key;
//             final row = entry.value;
//             return Column(
//               children: [
//                 Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         width: 30,
//                         height: 30,
//                         decoration: BoxDecoration(
//                           color: AppColors.cxl,
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: AppColors.cborder),
//                         ),
//                         child: Icon(row.icon, size: 14, color: AppColors.c1),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               row.label,
//                               style: const TextStyle(
//                                 fontSize: 11,
//                                 color: AppColors.ctext,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             const SizedBox(height: 2),
//                             Text(
//                               row.value,
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 color: AppColors.cdark,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (i < visibleRows.length - 1)
//                   const Divider(
//                     height: 1,
//                     thickness: 1,
//                     color: AppColors.cborder,
//                     indent: 56,
//                   ),
//               ],
//             );
//           }),
//         ],
//       ),
//     );
//   }

//   // ── Exit / Go Back button ─────────────────────────────────────────────────
//   Widget _buildExitButton(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: DecoratedBox(
//         decoration: BoxDecoration(
//           color: AppColors.c1,
//           borderRadius: BorderRadius.circular(25),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.c1.withOpacity(0.30),
//               blurRadius: 14,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         child: ElevatedButton(
//           onPressed: () => Navigator.pop(context),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.transparent,
//             shadowColor: Colors.transparent,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(25),
//             ),
//           ),
//           child: const Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.arrow_back_ios_new_rounded,
//                   color: AppColors.white, size: 14),
//               SizedBox(width: 8),
//               Text(
//                 'Go Back',
//                 style: TextStyle(
//                   color: AppColors.white,
//                   fontSize: 15,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 0.8,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ── ROW MODEL ─────────────────────────────────────────────
// class _InfoRow {
//   final IconData icon;
//   final String label;
//   final String value;
//   const _InfoRow(this.icon, this.label, this.value);
// }
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/invoice/invoice_model.dart';

class ViewInvoiceDetail extends StatefulWidget {
  final InvoiceModel invoice;
  const ViewInvoiceDetail({super.key, required this.invoice});

  @override
  State<ViewInvoiceDetail> createState() => _ViewInvoiceDetailState();
}

class _ViewInvoiceDetailState extends State<ViewInvoiceDetail>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

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
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  /// For "intern" type invoices there's no `items` list — build a single
  /// synthetic product row from the fee/course fields so the layout
  /// still shows a product breakdown like the client type does.
  List<InvoiceItemModel> _displayItems(InvoiceModel invoice) {
    if (invoice.items.isNotEmpty) return invoice.items;

    if (invoice.invoiceType != 'client') {
      return [
        InvoiceItemModel(
          id: 0,
          product: null,
          productName: invoice.courseName.isNotEmpty
              ? invoice.courseName
              : (invoice.description.isNotEmpty
                  ? invoice.description
                  : "Course Fee"),
          quantity: "1",
          unitPrice: invoice.feeAmount,
          sgstPercentage: invoice.sgstPercentage,
          cgstPercentage: invoice.cgstPercentage,
          subTotal: invoice.feeAmount,
        ),
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final invoice = widget.invoice;
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;

    final isClient = invoice.invoiceType == 'client';
    final name = isClient
        ? (invoice.clientName.isNotEmpty ? invoice.clientName : "—")
        : (invoice.internName.isNotEmpty ? invoice.internName : "—");

    final initials = name.trim().isNotEmpty && name != "—"
        ? name.trim().split(" ").map((e) => e[0]).take(2).join().toUpperCase()
        : "?";

    final items = _displayItems(invoice);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            _buildHeader(
                context, sw, topPad, invoice.invoiceNumber, name, initials),
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

                        // ==================== Invoice Info =====================
                        _buildInfoCard(
                          icon: Icons.description_outlined,
                          title: "Invoice Info",
                          rows: [
                            _InfoRow(
                                Icons.tag, "Invoice No", invoice.invoiceNumber),
                            _InfoRow(Icons.calendar_today, "Invoice Date",
                                invoice.invoiceDate),
                            _InfoRow(
                              isClient ? Icons.person : Icons.school_outlined,
                              isClient ? "Client Name" : "Student Name",
                              name == "—" ? "" : name,
                            ),
                            if (!isClient)
                              _InfoRow(Icons.menu_book_outlined, "Course",
                                  invoice.courseName),
                            _InfoRow(
                              Icons.category_outlined,
                              "Invoice Type",
                              isClient ? "Client" : "Student",
                            ),
                            _InfoRow(Icons.verified, "Status", invoice.status),
                            if (invoice.remark.isNotEmpty)
                              _InfoRow(Icons.notes_outlined, "Remark",
                                  invoice.remark),
                            if (!isClient && invoice.description.isNotEmpty)
                              _InfoRow(Icons.info_outline, "Description",
                                  invoice.description),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ==================== Product List =====================
                        _buildProductHeader(),
                        const SizedBox(height: 12),
                        if (items.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              "No products added",
                              style: TextStyle(
                                color: AppColors.ctext,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else
                          Column(
                            children: List.generate(
                              items.length,
                              (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _InvoiceItemCard(item: items[index]),
                              ),
                            ),
                          ),

                        const SizedBox(height: 12),

                        _buildPricingSummary(invoice),

                        const SizedBox(height: 12),

                        _buildPaymentDetails(invoice),

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

  Widget _buildHeader(BuildContext context, double sw, double topPad,
      String invoiceNumber, String name, String initials) {
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
              // Invoice number badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.cxl,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cborder),
                ),
                child: Text(
                  invoiceNumber,
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

  // ── PRODUCT SECTION HEADER ──────────────────────────────────────
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
            color: AppColors.c1.withValues(alpha: 0.05),
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

  // ── PRICING SUMMARY ─────────────────────────────────────────────
  Widget _buildPricingSummary(InvoiceModel invoice) {
    final subtotal = invoice.totalAmountWithoutTax;
    final tax = invoice.taxAmount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cborder),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (subtotal != null)
            _row("Subtotal (Before Tax)", subtotal.toStringAsFixed(2)),
          if (tax != null) _row("Total Tax", tax.toStringAsFixed(2)),
          const Divider(
            height: 20,
            thickness: 1,
            color: AppColors.cborder,
          ),
          _row(
            "Grand Total",
            invoice.grandTotal,
            isBold: true,
            color: AppColors.green,
          ),
        ],
      ),
    );
  }

  // ── PAYMENT DETAILS ─────────────────────────────────────────────
  Widget _buildPaymentDetails(InvoiceModel invoice) {
    final total = double.tryParse(invoice.grandTotal) ?? 0;
    final pending = invoice.pendingAmount ?? 0;
    final paid = (total - pending).clamp(0, total);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cborder),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _miniRow("Paid Amount", "₹ ${paid.toStringAsFixed(2)}"),
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
                  "₹ ${pending.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: pending == 0 ? Colors.green : Colors.red,
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
              color: color ?? AppColors.cdark,
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
            color: AppColors.c1.withValues(alpha: 0.06),
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
                  title,
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
              color: AppColors.c1.withValues(alpha: 0.30),
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

// ── PRODUCT ITEM CARD ───────────────────────────────────────────
class _InvoiceItemCard extends StatelessWidget {
  final InvoiceItemModel item;
  const _InvoiceItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final qty = double.tryParse(item.quantity) ?? 0;
    final unitPrice = double.tryParse(item.unitPrice) ?? 0;
    final sgst = double.tryParse(item.sgstPercentage) ?? 0;
    final cgst = double.tryParse(item.cgstPercentage) ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cborder),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.cxl,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cborder),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.c1,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.productName.isNotEmpty ? item.productName : "—",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cdark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "₹ ${item.subTotal}",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, thickness: 1, color: AppColors.cborder),
          const SizedBox(height: 10),
          Row(
            children: [
              _itemMini("Qty", qty % 1 == 0 ? qty.toInt().toString() : "$qty"),
              _itemMini("Unit Price", "₹ ${unitPrice.toStringAsFixed(2)}"),
              _itemMini("SGST", "$sgst%"),
              _itemMini("CGST", "$cgst%"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _itemMini(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              color: AppColors.ctext,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColors.cdark,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
