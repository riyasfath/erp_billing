// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:pokakbilling/models/data-models/quotations-models/quotation_model.dart';

// // ── Color Palette ─────────────────────────────────────────────────────────────
// const PdfColor _kCyan = PdfColor.fromInt(0xFF3BBCD9);
// const PdfColor _kCyanDark = PdfColor.fromInt(0xFF2A9BB8);
// const PdfColor _kCyanDeep = PdfColor.fromInt(0xFF155F72);
// const PdfColor _kCyanULight = PdfColor.fromInt(0xFFEAF9FD);
// const PdfColor _kCyanLight = PdfColor.fromInt(0xFFD0F2FA);
// const PdfColor _kCyanBorder = PdfColor.fromInt(0xFFB8E8F5);
// const PdfColor _kDark = PdfColor.fromInt(0xFF155F72);
// const PdfColor _kText = PdfColor.fromInt(0xFF1A6E84);
// const PdfColor _kWhite = PdfColors.white;
// const PdfColor _kTagGreen = PdfColor.fromInt(0xFF16A34A);
// const PdfColor _kTagGreenBg = PdfColor.fromInt(0xFFF0FDF4);
// const PdfColor _kGrey = PdfColor.fromInt(0xFFB0C4D0);
// const PdfColor _kRowAlt = PdfColor.fromInt(0xFFF0FBFD);

// class QuotationPdfGenerator {
//   static Future<File> generate(QuotationModel q) async {
//     final pdf = pw.Document(compress: true);

//     // Built-in fonts — no assets needed
//     final bold = pw.Font.helveticaBold();
//     final regular = pw.Font.helvetica();
//     final oblique = pw.Font.helveticaOblique();

//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: pw.EdgeInsets.zero,
//         build: (ctx) => [
//           _buildHeader(q, bold, regular, oblique),
//           _buildInfoCards(q, bold, regular),
//           _buildItemsTable(q, bold, regular, oblique),
//           _buildTotals(q, bold, regular),
//           if ((q.termsAndConditions ?? '').isNotEmpty)
//             _buildTextBlock(
//                 'Terms & Conditions', q.termsAndConditions!, bold, regular),
//           if ((q.notes ?? '').isNotEmpty)
//             _buildTextBlock('Notes', q.notes!, bold, regular),
//           _buildFooter(q, bold, regular),
//         ],
//       ),
//     );

//     final dir = await getTemporaryDirectory();
//     final safe = q.quotationNumber.replaceAll(RegExp(r'[^\w\-]'), '_');
//     final file = File('${dir.path}/Quotation_$safe.pdf');
//     await file.writeAsBytes(await pdf.save());
//     return file;
//   }

//   // ── 1. HEADER ───────────────────────────────────────────────────────────────
//   static pw.Widget _buildHeader(
//     QuotationModel q,
//     pw.Font bold,
//     pw.Font regular,
//     pw.Font oblique,
//   ) {
//     final clientName = (q.clientNameDisplay?.isNotEmpty == true
//             ? q.clientNameDisplay!
//             : q.clientName ?? 'Client')
//         .toUpperCase();

//     final initials = clientName
//         .trim()
//         .split(' ')
//         .where((e) => e.isNotEmpty)
//         .map((e) => e[0])
//         .take(2)
//         .join();

//     return pw.Container(
//       width: double.infinity,
//       decoration: const pw.BoxDecoration(
//         gradient: pw.LinearGradient(
//           colors: [_kCyanDeep, _kCyanDark, _kCyan],
//           begin: pw.Alignment.topLeft,
//           end: pw.Alignment.bottomRight,
//         ),
//       ),
//       child: pw.Stack(
//         children: [
//           // Decorative circles
//           pw.Positioned(
//             top: -28,
//             right: -28,
//             child: pw.Container(
//               width: 110,
//               height: 110,
//               decoration: const pw.BoxDecoration(
//                 shape: pw.BoxShape.circle,
//                 color: PdfColor(1, 1, 1, 0.06),
//               ),
//             ),
//           ),
//           pw.Positioned(
//             bottom: -16,
//             left: 16,
//             child: pw.Container(
//               width: 70,
//               height: 70,
//               decoration: const pw.BoxDecoration(
//                 shape: pw.BoxShape.circle,
//                 color: PdfColor(1, 1, 1, 0.04),
//               ),
//             ),
//           ),

//           pw.Padding(
//             padding: const pw.EdgeInsets.fromLTRB(32, 34, 32, 30),
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 // Top row
//                 pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   children: [
//                     pw.Text(
//                       'QUOTATION',
//                       style: pw.TextStyle(
//                           font: regular,
//                           fontSize: 10,
//                           color: _kCyanLight,
//                           letterSpacing: 4),
//                     ),
//                     _statusBadge(q.status, bold),
//                   ],
//                 ),

//                 pw.SizedBox(height: 8),

//                 pw.Text(
//                   q.quotationNumber,
//                   style: pw.TextStyle(
//                       font: bold,
//                       fontSize: 26,
//                       color: _kWhite,
//                       letterSpacing: 0.4),
//                 ),

//                 pw.SizedBox(height: 18),

//                 // Client row
//                 pw.Row(
//                   crossAxisAlignment: pw.CrossAxisAlignment.center,
//                   children: [
//                     pw.Container(
//                       width: 48,
//                       height: 48,
//                       decoration: pw.BoxDecoration(
//                         shape: pw.BoxShape.circle,
//                         color: const PdfColor(1, 1, 1, 0.16),
//                         border: pw.BoxDecoration(
//                           border: pw.Border.all(
//                               color: const PdfColor(1, 1, 1, 0.4), width: 1.5),
//                         ).border,
//                       ),
//                       child: pw.Center(
//                         child: pw.Text(initials,
//                             style: pw.TextStyle(
//                                 font: bold, fontSize: 17, color: _kWhite)),
//                       ),
//                     ),
//                     pw.SizedBox(width: 14),
//                     pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.Text(clientName,
//                             style: pw.TextStyle(
//                                 font: bold, fontSize: 15, color: _kWhite)),
//                         if ((q.projectName ?? '').isNotEmpty)
//                           pw.Text(q.projectName!,
//                               style: pw.TextStyle(
//                                   font: regular,
//                                   fontSize: 10,
//                                   color: _kCyanLight)),
//                       ],
//                     ),
//                   ],
//                 ),

//                 pw.SizedBox(height: 22),

//                 // Meta row
//                 pw.Row(
//                   crossAxisAlignment: pw.CrossAxisAlignment.end,
//                   children: [
//                     _metaChip('Date', q.date, bold, regular),
//                     pw.SizedBox(width: 10),
//                     if ((q.validUntil ?? '').isNotEmpty)
//                       _metaChip('Valid Until', q.validUntil!, bold, regular),
//                     pw.Spacer(),
//                     // Grand total box
//                     pw.Container(
//                       padding: const pw.EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 10),
//                       decoration: const pw.BoxDecoration(
//                         color: _kWhite,
//                         borderRadius:
//                             pw.BorderRadius.all(pw.Radius.circular(10)),
//                       ),
//                       child: pw.Column(
//                         crossAxisAlignment: pw.CrossAxisAlignment.end,
//                         children: [
//                           pw.Text('GRAND TOTAL',
//                               style: pw.TextStyle(
//                                   font: regular,
//                                   fontSize: 7,
//                                   color: _kText,
//                                   letterSpacing: 1.5)),
//                           pw.SizedBox(height: 3),
//                           pw.Text('\u20b9 ${q.grandTotal}',
//                               style: pw.TextStyle(
//                                   font: bold, fontSize: 19, color: _kCyanDeep)),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   static pw.Widget _statusBadge(String status, pw.Font bold) {
//     final lower = status.toLowerCase();
//     final isApproved = lower == 'approved';
//     final isDraft = lower == 'draft';
//     final bg = isApproved
//         ? _kTagGreenBg
//         : isDraft
//             ? const PdfColor(1.0, 0.97, 0.80)
//             : _kCyanLight;
//     final fg = isApproved
//         ? _kTagGreen
//         : isDraft
//             ? const PdfColor(0.55, 0.45, 0.0)
//             : _kCyanDeep;
//     return pw.Container(
//       padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//       decoration: pw.BoxDecoration(
//         color: bg,
//         borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
//       ),
//       child: pw.Text(status.toUpperCase(),
//           style: pw.TextStyle(
//               font: bold, fontSize: 8, color: fg, letterSpacing: 1)),
//     );
//   }

//   static pw.Widget _metaChip(
//       String label, String value, pw.Font bold, pw.Font regular) {
//     return pw.Container(
//       padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//       decoration: pw.BoxDecoration(
//         color: const PdfColor(1, 1, 1, 0.14),
//         borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
//         border: pw.BoxDecoration(
//           border:
//               pw.Border.all(color: const PdfColor(1, 1, 1, 0.30), width: 0.8),
//         ).border,
//       ),
//       child: pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.Text(label.toUpperCase(),
//               style: pw.TextStyle(
//                   font: regular,
//                   fontSize: 7,
//                   color: _kCyanLight,
//                   letterSpacing: 1)),
//           pw.SizedBox(height: 2),
//           pw.Text(value,
//               style: pw.TextStyle(font: bold, fontSize: 11, color: _kWhite)),
//         ],
//       ),
//     );
//   }

//   // ── 2. INFO CARDS ───────────────────────────────────────────────────────────
//   static pw.Widget _buildInfoCards(
//       QuotationModel q, pw.Font bold, pw.Font regular) {
//     final hasAddress = (q.companyAddress ?? '').isNotEmpty ||
//         (q.companyLocation ?? '').isNotEmpty;

//     return pw.Padding(
//       padding: const pw.EdgeInsets.fromLTRB(32, 22, 32, 0),
//       child: pw.Row(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.Expanded(
//             child: _infoCard(
//               title: 'Quotation Details',
//               rows: [
//                 _IE('Quotation No', q.quotationNumber),
//                 _IE('Date', q.date),
//                 if ((q.validUntil ?? '').isNotEmpty)
//                   _IE('Valid Until', q.validUntil!),
//                 if ((q.projectName ?? '').isNotEmpty)
//                   _IE('Project', q.projectName!),
//                 _IE('Status', q.status),
//               ],
//               bold: bold,
//               regular: regular,
//             ),
//           ),
//           if (hasAddress) ...[
//             pw.SizedBox(width: 14),
//             pw.Expanded(
//               child: _infoCard(
//                 title: 'Company Info',
//                 rows: [
//                   if ((q.companyLocation ?? '').isNotEmpty)
//                     _IE('Location', q.companyLocation!),
//                   if ((q.companyAddress ?? '').isNotEmpty)
//                     _IE('Address', q.companyAddress!),
//                 ],
//                 bold: bold,
//                 regular: regular,
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   static pw.Widget _infoCard({
//     required String title,
//     required List<_IE> rows,
//     required pw.Font bold,
//     required pw.Font regular,
//   }) {
//     return pw.Container(
//       decoration: pw.BoxDecoration(
//         color: _kWhite,
//         borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
//         border: pw.BoxDecoration(
//           border: pw.Border.all(color: _kCyanBorder, width: 1),
//         ).border,
//         boxShadow: const [
//           pw.BoxShadow(
//             color: PdfColor(0.23, 0.74, 0.85, 0.07),
//             blurRadius: 6,
//             offset: PdfPoint(0, 2),
//           ),
//         ],
//       ),
//       child: pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.Container(
//             height: 3,
//             decoration: const pw.BoxDecoration(
//               color: _kCyan,
//               borderRadius: pw.BorderRadius.only(
//                 topLeft: pw.Radius.circular(10),
//                 topRight: pw.Radius.circular(10),
//               ),
//             ),
//           ),
//           pw.Padding(
//             padding: const pw.EdgeInsets.fromLTRB(14, 10, 14, 12),
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Text(title.toUpperCase(),
//                     style: pw.TextStyle(
//                         font: bold,
//                         fontSize: 7.5,
//                         color: _kCyan,
//                         letterSpacing: 1.5)),
//                 pw.SizedBox(height: 8),
//                 ...rows.map((r) => _infoRow(r.label, r.value, bold, regular)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   static pw.Widget _infoRow(
//       String label, String value, pw.Font bold, pw.Font regular) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.only(bottom: 7),
//       child: pw.Row(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.SizedBox(
//             width: 68,
//             child: pw.Text(label,
//                 style:
//                     pw.TextStyle(font: regular, fontSize: 8.5, color: _kText)),
//           ),
//           pw.Text(':  ',
//               style: pw.TextStyle(font: regular, fontSize: 8.5, color: _kGrey)),
//           pw.Expanded(
//             child: pw.Text(value,
//                 style: pw.TextStyle(font: bold, fontSize: 8.5, color: _kDark)),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── 3. ITEMS TABLE ──────────────────────────────────────────────────────────
//   static pw.Widget _buildItemsTable(
//     QuotationModel q,
//     pw.Font bold,
//     pw.Font regular,
//     pw.Font oblique,
//   ) {
//     if (q.items.isEmpty) return pw.SizedBox();

//     return pw.Padding(
//       padding: const pw.EdgeInsets.fromLTRB(32, 22, 32, 0),
//       child: pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           // Section heading
//           pw.Row(
//             children: [
//               pw.Container(
//                 width: 4,
//                 height: 16,
//                 decoration: const pw.BoxDecoration(
//                   color: _kCyan,
//                   borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
//                 ),
//               ),
//               pw.SizedBox(width: 8),
//               pw.Text('PRODUCTS & SERVICES',
//                   style: pw.TextStyle(
//                       font: bold,
//                       fontSize: 10,
//                       color: _kDark,
//                       letterSpacing: 1)),
//             ],
//           ),

//           pw.SizedBox(height: 10),

//           pw.Container(
//             decoration: pw.BoxDecoration(
//               borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
//               border: pw.BoxDecoration(
//                 border: pw.Border.all(color: _kCyanBorder, width: 1),
//               ).border,
//             ),
//             child: pw.ClipRRect(
//               horizontalRadius: 10,
//               verticalRadius: 10,
//               child: pw.Column(
//                 children: [
//                   // Header
//                   pw.Container(
//                     color: _kCyan,
//                     padding: const pw.EdgeInsets.symmetric(
//                         horizontal: 12, vertical: 9),
//                     child: pw.Row(
//                       children: [
//                         _th('#', bold, flex: 1),
//                         _th('Product', bold, flex: 5),
//                         _th('Qty', bold, flex: 2, align: pw.TextAlign.center),
//                         _th('Unit Price', bold,
//                             flex: 3, align: pw.TextAlign.right),
//                         _th('SGST', bold, flex: 2, align: pw.TextAlign.right),
//                         _th('CGST', bold, flex: 2, align: pw.TextAlign.right),
//                         _th('Total', bold, flex: 3, align: pw.TextAlign.right),
//                       ],
//                     ),
//                   ),

//                   // Rows
//                   ...q.items.asMap().entries.map((entry) {
//                     final i = entry.key;
//                     final item = entry.value;
//                     return pw.Container(
//                       color: i.isOdd ? _kRowAlt : _kWhite,
//                       padding: const pw.EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 9),
//                       child: pw.Row(
//                         crossAxisAlignment: pw.CrossAxisAlignment.start,
//                         children: [
//                           _td('${i + 1}', regular, flex: 1),
//                           pw.Expanded(
//                             flex: 5,
//                             child: pw.Column(
//                               crossAxisAlignment: pw.CrossAxisAlignment.start,
//                               children: [
//                                 pw.Text(item.productName ?? '—',
//                                     style: pw.TextStyle(
//                                         font: bold,
//                                         fontSize: 8.5,
//                                         color: _kDark)),
//                                 if ((item.description ?? '').isNotEmpty)
//                                   pw.Text(item.description!,
//                                       style: pw.TextStyle(
//                                           font: oblique,
//                                           fontSize: 7.5,
//                                           color: _kText)),
//                                 if ((item.unit ?? '').isNotEmpty)
//                                   pw.Text('Unit: ${item.unit}',
//                                       style: pw.TextStyle(
//                                           font: regular,
//                                           fontSize: 7,
//                                           color: _kGrey)),
//                               ],
//                             ),
//                           ),
//                           _td(item.quantity.toString(), regular,
//                               flex: 2, align: pw.TextAlign.center),
//                           _td('\u20b9${item.unitPrice}', regular,
//                               flex: 3, align: pw.TextAlign.right),
//                           _td('${item.sgst}%', regular,
//                               flex: 2, align: pw.TextAlign.right),
//                           _td('${item.cgst}%', regular,
//                               flex: 2, align: pw.TextAlign.right),
//                           _tdBold('\u20b9${item.total}', bold,
//                               flex: 3, align: pw.TextAlign.right),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   static pw.Widget _th(String t, pw.Font bold,
//       {int flex = 1, pw.TextAlign align = pw.TextAlign.left}) {
//     return pw.Expanded(
//       flex: flex,
//       child: pw.Text(t,
//           textAlign: align,
//           style: pw.TextStyle(
//               font: bold, fontSize: 8, color: _kWhite, letterSpacing: 0.3)),
//     );
//   }

//   static pw.Widget _td(String t, pw.Font regular,
//       {int flex = 1, pw.TextAlign align = pw.TextAlign.left}) {
//     return pw.Expanded(
//       flex: flex,
//       child: pw.Text(t,
//           textAlign: align,
//           style: pw.TextStyle(font: regular, fontSize: 8.5, color: _kDark)),
//     );
//   }

//   static pw.Widget _tdBold(String t, pw.Font bold,
//       {int flex = 1, pw.TextAlign align = pw.TextAlign.left}) {
//     return pw.Expanded(
//       flex: flex,
//       child: pw.Text(t,
//           textAlign: align,
//           style: pw.TextStyle(font: bold, fontSize: 8.5, color: _kCyanDeep)),
//     );
//   }

//   // ── 4. TOTALS ───────────────────────────────────────────────────────────────
//   static pw.Widget _buildTotals(
//       QuotationModel q, pw.Font bold, pw.Font regular) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.fromLTRB(32, 18, 32, 0),
//       child: pw.Row(
//         mainAxisAlignment: pw.MainAxisAlignment.end,
//         children: [
//           pw.Container(
//             width: 210,
//             decoration: pw.BoxDecoration(
//               color: _kWhite,
//               borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
//               border: pw.BoxDecoration(
//                 border: pw.Border.all(color: _kCyanBorder, width: 1),
//               ).border,
//             ),
//             child: pw.Column(
//               children: [
//                 pw.Container(
//                   height: 3,
//                   decoration: const pw.BoxDecoration(
//                     color: _kCyan,
//                     borderRadius: pw.BorderRadius.only(
//                       topLeft: pw.Radius.circular(10),
//                       topRight: pw.Radius.circular(10),
//                     ),
//                   ),
//                 ),
//                 pw.Padding(
//                   padding: const pw.EdgeInsets.all(14),
//                   child: pw.Column(
//                     children: [
//                       _totalRow(
//                           'Subtotal', '\u20b9${q.subtotal}', bold, regular),
//                       pw.Container(
//                           height: 0.5,
//                           color: _kCyanBorder,
//                           margin: const pw.EdgeInsets.symmetric(vertical: 5)),
//                       _totalRow(
//                           'Tax Total', '\u20b9${q.taxTotal}', bold, regular),
//                       pw.SizedBox(height: 8),
//                       // Grand total highlight
//                       pw.Container(
//                         padding: const pw.EdgeInsets.symmetric(
//                             horizontal: 10, vertical: 10),
//                         decoration: const pw.BoxDecoration(
//                           gradient: pw.LinearGradient(
//                             colors: [_kCyanDeep, _kCyanDark],
//                             begin: pw.Alignment.centerLeft,
//                             end: pw.Alignment.centerRight,
//                           ),
//                           borderRadius:
//                               pw.BorderRadius.all(pw.Radius.circular(8)),
//                         ),
//                         child: pw.Row(
//                           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                           children: [
//                             pw.Text('GRAND TOTAL',
//                                 style: pw.TextStyle(
//                                     font: bold,
//                                     fontSize: 8.5,
//                                     color: _kCyanLight,
//                                     letterSpacing: 0.8)),
//                             pw.Text('\u20b9${q.grandTotal}',
//                                 style: pw.TextStyle(
//                                     font: bold, fontSize: 13, color: _kWhite)),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   static pw.Widget _totalRow(
//       String label, String value, pw.Font bold, pw.Font regular) {
//     return pw.Row(
//       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//       children: [
//         pw.Text(label,
//             style: pw.TextStyle(font: regular, fontSize: 9, color: _kText)),
//         pw.Text(value,
//             style: pw.TextStyle(font: bold, fontSize: 9, color: _kDark)),
//       ],
//     );
//   }

//   // ── 5. TEXT BLOCK (Terms / Notes) ───────────────────────────────────────────
//   static pw.Widget _buildTextBlock(
//       String title, String body, pw.Font bold, pw.Font regular) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.fromLTRB(32, 18, 32, 0),
//       child: pw.Container(
//         decoration: pw.BoxDecoration(
//           color: _kCyanULight,
//           borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
//           border: pw.BoxDecoration(
//             border: pw.Border.all(color: _kCyanBorder, width: 1),
//           ).border,
//         ),
//         child: pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.Container(
//               height: 3,
//               decoration: const pw.BoxDecoration(
//                 color: _kCyanDark,
//                 borderRadius: pw.BorderRadius.only(
//                   topLeft: pw.Radius.circular(10),
//                   topRight: pw.Radius.circular(10),
//                 ),
//               ),
//             ),
//             pw.Padding(
//               padding: const pw.EdgeInsets.fromLTRB(14, 10, 14, 14),
//               child: pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   pw.Text(title.toUpperCase(),
//                       style: pw.TextStyle(
//                           font: bold,
//                           fontSize: 7.5,
//                           color: _kCyanDark,
//                           letterSpacing: 1.5)),
//                   pw.SizedBox(height: 7),
//                   pw.Text(body,
//                       style: pw.TextStyle(
//                           font: regular,
//                           fontSize: 8.5,
//                           color: _kText,
//                           lineSpacing: 3)),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── 6. FOOTER ───────────────────────────────────────────────────────────────
//   static pw.Widget _buildFooter(
//       QuotationModel q, pw.Font bold, pw.Font regular) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.fromLTRB(32, 26, 32, 34),
//       child: pw.Column(
//         children: [
//           pw.Container(height: 0.8, color: _kCyanBorder),
//           pw.SizedBox(height: 10),
//           pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//             children: [
//               pw.Text('Generated by Pokak Billing',
//                   style: pw.TextStyle(
//                       font: regular, fontSize: 7.5, color: _kGrey)),
//               pw.Text(q.quotationNumber,
//                   style:
//                       pw.TextStyle(font: bold, fontSize: 7.5, color: _kCyan)),
//               pw.Text('Valid: ${q.validUntil ?? q.date}',
//                   style: pw.TextStyle(
//                       font: regular, fontSize: 7.5, color: _kGrey)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Helpers ───────────────────────────────────────────────────────────────────
// class _IE {
//   final String label;
//   final String value;
//   const _IE(this.label, this.value);
// }
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pokakbilling/models/data-models/quotations-models/quotation_model.dart';

// ── Colors matching the uploaded PDF exactly ─────────────────────────────────
const PdfColor _blue = PdfColor.fromInt(0xFF1A3C6E); // dark navy blue
const PdfColor _blueLight = PdfColor.fromInt(0xFF2563EB); // header text blue
const PdfColor _tableHeaderBg = PdfColor.fromInt(0xFF1A3C6E);
const PdfColor _tableRowAlt = PdfColor.fromInt(0xFFF5F9FF);
const PdfColor _borderColor = PdfColor.fromInt(0xFFCCCCCC);
const PdfColor _textDark = PdfColor.fromInt(0xFF222222);
const PdfColor _textGrey = PdfColor.fromInt(0xFF555555);
const PdfColor _white = PdfColors.white;
const PdfColor _paymentBg = PdfColor.fromInt(0xFFF0F4FF);
const PdfColor _paymentBorder = PdfColor.fromInt(0xFF1A3C6E);

// ── Company constants ─────────────────────────────────────────────────────────
const String _companyName = 'Pokak Technologies Pvt Ltd';
const String _companyAddr = 'Kakkanad, Kochi - 682021';
const String _companyPhone = '+91 9656033444 | pokaktech@gmail.com';
const String _companyWeb = 'www.pokaktech.com';
const String _companyGst = 'GSTIN 32AAMCP4053B1ZT';
const String _companyFooterLine =
    'Pokak Technologies Pvt Ltd  |  +91 9656 033 444  |  pokaktech@gmail.com';

// ── Payment terms (fixed) ─────────────────────────────────────────────────────
const List<String> _paymentTerms = [
  '1. PAYMENT MODE : Bank Transfer(NEFT/RTGS), UPI, or Cheque',
  '2. ACCOUNT NAME : POKAK TECHNOLOGIES PVT LTD',
  '3. A/C NUMBER : 50200060689752',
  '4. IFSC CODE : HDFC0000057',
  '5. 100% advance payment required to start the work.',
  '6. Minimum contract: 6 months and 3 months (renewable)',
  '7. Ad campaign costs (if any) are extra',
];

class QuotationPdfGenerator {
  static Future<File> generate(QuotationModel q) async {
    final pdf = pw.Document(compress: true);
    final bold = pw.Font.helveticaBold();
    final regular = pw.Font.helvetica();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(40, 36, 40, 36),
        header: (ctx) => _buildLetterhead(bold, regular),
        footer: (ctx) => _buildPageFooter(ctx, bold, regular),
        build: (ctx) => [
          _gap(18),
          _buildProposalTitle(bold),
          _gap(16),
          _buildClientAndQuotationRow(q, bold, regular),
          _gap(20),
          if ((q.projectName ?? '').isNotEmpty) ...[
            _buildProjectLabel(q.projectName!, bold, regular),
            _gap(14),
          ],
          _buildItemsTable(q, bold, regular),
          _gap(10),
          _buildTotalsBlock(q, bold, regular),
          _gap(6),
          _buildAmountInWords(q, bold, regular),
          _gap(18),
          _buildPaymentTermsBox(bold, regular),
          if ((q.contractText ?? q.contractName ?? '').isNotEmpty ||
              (q.termsAndConditions ?? '').isNotEmpty) ...[
            _gap(18),
            _buildPage2Content(q, bold, regular),
          ],
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final safe = q.quotationNumber.replaceAll(RegExp(r'[^\w\-]'), '_');
    final file = File('${dir.path}/Quotation_$safe.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // ── Letterhead (header on every page) ──────────────────────────────────────
  static pw.Widget _buildLetterhead(pw.Font bold, pw.Font regular) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Logo placeholder — simple styled box matching the PDF logo area
            pw.Container(
              width: 56,
              height: 56,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _blue, width: 1.5),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Center(
                child: pw.Text(
                  'PT',
                  style: pw.TextStyle(font: bold, fontSize: 18, color: _blue),
                ),
              ),
            ),
            // Company info (right-aligned)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  _companyName,
                  style:
                      pw.TextStyle(font: bold, fontSize: 13, color: _blueLight),
                ),
                _gap(2),
                pw.Text(_companyAddr,
                    style: pw.TextStyle(
                        font: regular, fontSize: 8.5, color: _textGrey)),
                pw.Text(_companyPhone,
                    style: pw.TextStyle(
                        font: regular, fontSize: 8.5, color: _textGrey)),
                pw.Text(_companyWeb,
                    style: pw.TextStyle(
                        font: regular, fontSize: 8.5, color: _textGrey)),
                pw.Text(
                  _companyGst,
                  style:
                      pw.TextStyle(font: bold, fontSize: 8.5, color: _textDark),
                ),
              ],
            ),
          ],
        ),
        _gap(8),
        pw.Container(height: 1.5, color: _blue),
      ],
    );
  }

  // ── Page footer ──────────────────────────────────────────────────────────────
  static pw.Widget _buildPageFooter(
      pw.Context ctx, pw.Font bold, pw.Font regular) {
    return pw.Column(
      children: [
        pw.Container(height: 0.8, color: _borderColor),
        _gap(4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              _companyFooterLine,
              style:
                  pw.TextStyle(font: regular, fontSize: 7.5, color: _textGrey),
            ),
            pw.Text(
              'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style:
                  pw.TextStyle(font: regular, fontSize: 7.5, color: _textGrey),
            ),
          ],
        ),
      ],
    );
  }

  // ── PROPOSAL title ──────────────────────────────────────────────────────────
  static pw.Widget _buildProposalTitle(pw.Font bold) {
    return pw.Center(
      child: pw.Text(
        'PROPOSAL',
        style: pw.TextStyle(
            font: bold, fontSize: 18, color: _textDark, letterSpacing: 2),
      ),
    );
  }

  // ── Client + Quotation details side-by-side ──────────────────────────────────
  static pw.Widget _buildClientAndQuotationRow(
      QuotationModel q, pw.Font bold, pw.Font regular) {
    final clientName = (q.clientNameDisplay?.isNotEmpty == true
        ? q.clientNameDisplay!
        : q.clientName ?? '—');

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Left: CLIENT DETAILS
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'CLIENT DETAILS',
                style: pw.TextStyle(
                    font: bold,
                    fontSize: 9,
                    color: _blueLight,
                    letterSpacing: 0.5),
              ),
              _gap(6),
              _detailRow('Client Name', clientName, bold, regular),
              if ((q.companyAddress ?? '').isNotEmpty)
                _detailRow('Address', q.companyAddress!, bold, regular),
              if ((q.companyLocation ?? '').isNotEmpty)
                _detailRow('Location', q.companyLocation!, bold, regular),
            ],
          ),
        ),
        pw.SizedBox(width: 30),
        // Right: QUOTATION DETAILS
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'QUOTATION DETAILS',
                style: pw.TextStyle(
                    font: bold,
                    fontSize: 9,
                    color: _blueLight,
                    letterSpacing: 0.5),
              ),
              _gap(6),
              _detailRowRight(
                  'Quotation No:', q.quotationNumber, bold, regular),
              _detailRowRight('Date:', q.date, bold, regular),
              if ((q.validUntil ?? '').isNotEmpty)
                _detailRowRight('Valid Until:', q.validUntil!, bold, regular),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _detailRow(
      String label, String value, pw.Font bold, pw.Font regular) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 72,
            child: pw.Text(label,
                style:
                    pw.TextStyle(font: regular, fontSize: 9, color: _textDark)),
          ),
          pw.Text(': ',
              style:
                  pw.TextStyle(font: regular, fontSize: 9, color: _textDark)),
          pw.Expanded(
            child: pw.Text(value,
                style:
                    pw.TextStyle(font: regular, fontSize: 9, color: _textDark)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _detailRowRight(
      String label, String value, pw.Font bold, pw.Font regular) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text(label,
              style:
                  pw.TextStyle(font: regular, fontSize: 9, color: _textDark)),
          pw.SizedBox(width: 4),
          pw.Text(value,
              style:
                  pw.TextStyle(font: regular, fontSize: 9, color: _textDark)),
        ],
      ),
    );
  }

  // ── Project label ────────────────────────────────────────────────────────────
  static pw.Widget _buildProjectLabel(
      String project, pw.Font bold, pw.Font regular) {
    return pw.Row(
      children: [
        pw.Text('Project : ',
            style: pw.TextStyle(font: bold, fontSize: 10, color: _blueLight)),
        pw.Text(project,
            style: pw.TextStyle(font: regular, fontSize: 10, color: _textDark)),
      ],
    );
  }

  // ── Items table ──────────────────────────────────────────────────────────────
  static pw.Widget _buildItemsTable(
      QuotationModel q, pw.Font bold, pw.Font regular) {
    // Column flex widths: SL/NO, ITEM NAME, DESCRIPTION, QTY, UNIT PRICE, TAX(%), AMOUNT
    const colWidths = [30.0, 90.0, 130.0, 30.0, 70.0, 40.0, 70.0];
    final totalWidth = colWidths.fold<double>(0, (a, b) => a + b); // ~460

    pw.Widget headerCell(String text) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 6),
        child: pw.Text(
          text,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
              font: bold, fontSize: 8, color: _white, letterSpacing: 0.3),
        ),
      );
    }

    pw.Widget cell(String text,
        {pw.TextAlign align = pw.TextAlign.left,
        bool isBold = false,
        double fontSize = 8.5}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 6),
        child: pw.Text(
          text,
          textAlign: align,
          style: pw.TextStyle(
            font: isBold ? bold : regular,
            fontSize: fontSize,
            color: _textDark,
          ),
        ),
      );
    }

    List<pw.TableRow> rows = [];

    // Header row
    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: _tableHeaderBg),
        children: [
          headerCell('SL/NO'),
          headerCell('ITEM NAME'),
          headerCell('DESCRIPTION'),
          headerCell('QTY'),
          headerCell('UNIT PRICE'),
          headerCell('TAX\n(%)'),
          headerCell('AMOUNT'),
        ],
      ),
    );

    // Data rows
    for (int i = 0; i < q.items.length; i++) {
      final item = q.items[i];
      final isAlt = i.isOdd;

      // Calculate combined tax % (sgst + cgst)
      final sgst = double.tryParse(item.sgst) ?? 0;
      final cgst = double.tryParse(item.cgst) ?? 0;
      final taxPct = sgst + cgst;
      final taxPctStr = taxPct == taxPct.truncateToDouble()
          ? '${taxPct.toInt()}%'
          : '${taxPct.toStringAsFixed(1)}%';

      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: isAlt ? _tableRowAlt : _white,
          ),
          children: [
            cell('${i + 1}', align: pw.TextAlign.center),
            cell(item.productName ?? '—'),
            cell(item.description ?? ''),
            cell(item.quantity.toString(), align: pw.TextAlign.center),
            cell('Rs. ${_fmt(item.unitPrice)}', align: pw.TextAlign.right),
            cell(taxPctStr, align: pw.TextAlign.center),
            cell('Rs. ${_fmt(item.total)}',
                align: pw.TextAlign.right, isBold: true),
          ],
        ),
      );
    }

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _borderColor, width: 0.8),
      ),
      child: pw.Table(
        columnWidths: {
          0: pw.FixedColumnWidth(colWidths[0]),
          1: pw.FixedColumnWidth(colWidths[1]),
          2: pw.FixedColumnWidth(colWidths[2]),
          3: pw.FixedColumnWidth(colWidths[3]),
          4: pw.FixedColumnWidth(colWidths[4]),
          5: pw.FixedColumnWidth(colWidths[5]),
          6: pw.FixedColumnWidth(colWidths[6]),
        },
        border: pw.TableBorder.symmetric(
          inside: pw.BorderSide(color: _borderColor, width: 0.5),
        ),
        children: rows,
      ),
    );
  }

  // ── Totals block (right-aligned) ─────────────────────────────────────────────
  static pw.Widget _buildTotalsBlock(
      QuotationModel q, pw.Font bold, pw.Font regular) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          width: 200,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: _borderColor, width: 0.8),
          ),
          child: pw.Column(
            children: [
              _totalLine('Total', 'Rs. ${_fmt(q.subtotal)}', bold, regular,
                  isHeader: false),
              pw.Container(height: 0.5, color: _borderColor),
              _totalLine('Tax Amount', 'Rs. ${_fmt(q.taxTotal)}', bold, regular,
                  isHeader: false),
              pw.Container(height: 0.5, color: _borderColor),
              _totalLine('Grand Total (Inc. Tax)', 'Rs. ${_fmt(q.grandTotal)}',
                  bold, regular,
                  isHeader: true),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _totalLine(
      String label, String value, pw.Font bold, pw.Font regular,
      {required bool isHeader}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
                font: isHeader ? bold : regular,
                fontSize: isHeader ? 9 : 8.5,
                color: _textDark),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
                font: bold, fontSize: isHeader ? 9.5 : 8.5, color: _textDark),
          ),
        ],
      ),
    );
  }

  // ── Amount in words ──────────────────────────────────────────────────────────
  static pw.Widget _buildAmountInWords(
      QuotationModel q, pw.Font bold, pw.Font regular) {
    final words = _amountToWords(q.grandTotal);
    return pw.Row(
      children: [
        pw.Text('Amount in Words: ',
            style: pw.TextStyle(font: bold, fontSize: 9, color: _textDark)),
        pw.Text(words,
            style: pw.TextStyle(font: regular, fontSize: 9, color: _textDark)),
      ],
    );
  }

  // ── Payment terms box ────────────────────────────────────────────────────────
  static pw.Widget _buildPaymentTermsBox(pw.Font bold, pw.Font regular) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: _paymentBg,
        border: pw.Border.all(color: _paymentBorder, width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      padding: const pw.EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'PAYMENT TERMS',
            style: pw.TextStyle(
                font: bold, fontSize: 9, color: _blueLight, letterSpacing: 0.5),
          ),
          _gap(6),
          ..._paymentTerms.map(
            (t) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 3),
              child: pw.Text(t,
                  style: pw.TextStyle(
                      font: regular, fontSize: 8.5, color: _textDark)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Page 2 content: contract + terms ────────────────────────────────────────
  static pw.Widget _buildPage2Content(
      QuotationModel q, pw.Font bold, pw.Font regular) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Contract details section
        if ((q.contractText ?? q.contractName ?? '').isNotEmpty) ...[
          pw.Text(
            'CONTRACT DETAILS',
            style: pw.TextStyle(
                font: bold,
                fontSize: 10,
                color: _blueLight,
                letterSpacing: 0.5),
          ),
          _gap(6),
          if ((q.contractName ?? '').isNotEmpty)
            pw.Text(
              q.contractName!,
              style: pw.TextStyle(font: bold, fontSize: 9, color: _blueLight),
            ),
          if ((q.contractText ?? '').isNotEmpty) ...[
            _gap(4),
            pw.Text(
              q.contractText!,
              style: pw.TextStyle(
                  font: regular,
                  fontSize: 8.5,
                  color: _textDark,
                  lineSpacing: 2),
            ),
          ],
          _gap(14),
        ],

        // Terms & Conditions
        if ((q.termsAndConditions ?? '').isNotEmpty) ...[
          pw.Text(
            'Terms & Conditions',
            style: pw.TextStyle(
                font: bold,
                fontSize: 10,
                color: _blueLight,
                letterSpacing: 0.5),
          ),
          _gap(6),
          // Split by newline and render as bullet list matching the PDF
          ...((q.termsAndConditions ?? '').split('\n')).map(
            (line) {
              final trimmed = line.trim();
              if (trimmed.isEmpty) return pw.SizedBox(height: 2);
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 3),
                child: pw.Text(
                  '- $trimmed',
                  style: pw.TextStyle(
                      font: regular, fontSize: 8.5, color: _textDark),
                ),
              );
            },
          ),
          _gap(20),
        ],

        // Prepared by section
        pw.Text('Prepared by',
            style: pw.TextStyle(font: bold, fontSize: 9, color: _textDark)),
        _gap(3),
        // You can extend QuotationModel to include preparedBy fields if needed
        // For now we show static company info
        pw.Text('Pokak Technologies Pvt Ltd',
            style: pw.TextStyle(font: regular, fontSize: 9, color: _textDark)),
      ],
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  static pw.SizedBox _gap(double h) => pw.SizedBox(height: h);

  /// Format number string to 2 decimal places
  static String _fmt(String val) {
    final d = double.tryParse(val);
    if (d == null) return val;
    return d.toStringAsFixed(2);
  }

  /// Simple amount-to-words for INR
  static String _amountToWords(String amountStr) {
    final amount = double.tryParse(amountStr) ?? 0;
    final rupees = amount.truncate();
    final paise = ((amount - rupees) * 100).round();

    final words = _numToWords(rupees);
    if (paise > 0) {
      return '$words and ${_numToWords(paise)} Paise Only';
    }
    return '$words Only';
  }

  static String _numToWords(int n) {
    if (n == 0) return 'Zero';
    const ones = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen'
    ];
    const tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety'
    ];

    String words = '';
    if (n >= 10000000) {
      words += '${_numToWords(n ~/ 10000000)} Crore ';
      n %= 10000000;
    }
    if (n >= 100000) {
      words += '${_numToWords(n ~/ 100000)} Lakh ';
      n %= 100000;
    }
    if (n >= 1000) {
      words += '${_numToWords(n ~/ 1000)} Thousand ';
      n %= 1000;
    }
    if (n >= 100) {
      words += '${ones[n ~/ 100]} Hundred ';
      n %= 100;
    }
    if (n >= 20) {
      words += '${tens[n ~/ 10]} ';
      n %= 10;
    }
    if (n > 0) {
      words += '${ones[n]} ';
    }
    return words.trim();
  }
}
