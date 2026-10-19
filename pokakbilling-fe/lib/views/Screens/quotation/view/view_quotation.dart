import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';
import 'package:pokakbilling/models/data-models/quotations-models/quotationItems_model.dart';
import 'package:pokakbilling/viewmodels/quotation/quotation_viewmodel.dart';
import 'package:pokakbilling/views/Screens/quotation/view/quotation_items.dart';
import 'package:pokakbilling/views/Screens/quotation/view/view_contract_details.dart';
import 'package:pokakbilling/views/Screens/quotation/view/view_terms_and_conditions.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ViewQuotation extends StatefulWidget {
  const ViewQuotation({super.key});

  @override
  State<ViewQuotation> createState() => _ViewQuotationState();
}

class _ViewQuotationState extends State<ViewQuotation>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late Animation<double> _fadeA;
  late Animation<Offset> _slideA;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeA = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideA = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'Q';
  }

  @override
  Widget build(BuildContext context) {
    final quotationProvider = Provider.of<QuotationViewmodel>(context);
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;

    // Load finished but nothing came back (API/parse error) → don't spin forever.
    if (!quotationProvider.singleQuotationLoading &&
        quotationProvider.singleQuotationList.isEmpty) {
      return Scaffold(
        backgroundColor: ErpColors.pageBg,
        body: SafeArea(
          child: Center(
            child: ErpEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Could not open quotation',
              subtitle:
                  'The quotation details failed to load. Please go back and try again.',
              color: ErpColors.red,
              actionLabel: 'Go Back',
              actionIcon: Icons.arrow_back_rounded,
              onAction: () => Navigator.pop(context),
            ),
          ),
        ),
      );
    }

    if (quotationProvider.singleQuotationLoading) {
      return const Scaffold(
        backgroundColor: ErpColors.pageBg,
        body: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              color: ErpColors.cyan,
              strokeWidth: 2.5,
            ),
          ),
        ),
      );
    }

    final QuotationitemsModel quotation =
        quotationProvider.singleQuotationList[0];
    final name = quotation.clientName.trim();
    final initials = _initials(name);

    return Scaffold(
      backgroundColor: ErpColors.pageBg,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            _buildHeader(context, sw, topPad, quotation, name, initials),
            Expanded(
              child: FadeTransition(
                opacity: _fadeA,
                child: SlideTransition(
                  position: _slideA,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(sw * 0.04, 18, sw * 0.04,
                        MediaQuery.of(context).padding.bottom + 28),
                    child: Column(
                      children: [
                        // Section 1 — Quotation Info
                        ErpFadeIn(
                          index: 0,
                          child: _buildSection(
                            icon: Icons.description_rounded,
                            color: ErpColors.cyan,
                            title: 'Quotation Info',
                            rows: [
                              _InfoRow(Icons.person_rounded, 'Client Name',
                                  name),
                              _InfoRow(Icons.tag_rounded, 'Quotation No',
                                  quotation.quotationNumber),
                              _InfoRow(Icons.calendar_today_rounded, 'Date',
                                  quotation.quotationDate),
                              _InfoRow(Icons.support_agent_rounded,
                                  'Salesperson', quotation.salespersonName),
                              _InfoRow(Icons.work_rounded, 'Project',
                                  quotation.projectName),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Section 2 — Products
                        ErpFadeIn(
                          index: 1,
                          child: _buildSectionShell(
                            icon: Icons.inventory_2_rounded,
                            color: ErpColors.blue,
                            title: 'Products',
                            trailing: quotation.items.isEmpty
                                ? null
                                : ErpStatusChip(
                                    label:
                                        '${quotation.items.length} item${quotation.items.length == 1 ? '' : 's'}',
                                    color: ErpColors.blue,
                                  ),
                            child: _buildProductsSection(quotation),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Section 3 — Amount
                        ErpFadeIn(
                          index: 2,
                          child: _buildTotalCard(quotation.grandTotal),
                        ),
                        const SizedBox(height: 14),

                        // Section 4 — Terms & Conditions
                        ErpFadeIn(
                          index: 3,
                          child: _buildSectionShell(
                            icon: Icons.article_rounded,
                            color: ErpColors.violet,
                            title: 'Terms & Conditions',
                            child: quotation.termsAndConditionsTitle.isNotEmpty
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            14, 0, 14, 8),
                                        child: Text(
                                          quotation.termsAndConditionsTitle,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            color: ErpColors.ink,
                                          ),
                                        ),
                                      ),
                                      const ViewTermsAndConditions(),
                                    ],
                                  )
                                : const ViewTermsAndConditions(),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Section 5 — Contract
                        ErpFadeIn(
                          index: 4,
                          child: _buildSectionShell(
                            icon: Icons.gavel_rounded,
                            color: ErpColors.orange,
                            title: quotation.contractTitle.isNotEmpty
                                ? quotation.contractTitle
                                : 'Contract Details',
                            child: const ViewContractDetails(),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Action buttons
                        // Row(
                        //   children: [
                        //     Expanded(
                        //       child: _actionBtn(
                        //         icon: Icons.picture_as_pdf_rounded,
                        //         label: 'PDF File',
                        //         onPressed: () =>
                        //             _viewAndDownloadPdf(context, quotation),
                        //       ),
                        //     ),
                        //     const SizedBox(width: 10),
                        //     Expanded(
                        //       child: _actionBtn(
                        //         icon: Icons.print_rounded,
                        //         label: 'Print',
                        //         onPressed: () =>
                        //             _printQuotation(context, quotation),
                        //         outlined: true,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // const SizedBox(height: 14),

                        // Go Back button
                        ErpFadeIn(index: 5, child: _buildExitButton(context)),
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

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(
    BuildContext context,
    double sw,
    double topPad,
    QuotationitemsModel quotation,
    String name,
    String initials,
  ) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: ErpColors.headerGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: ErpColors.cyan.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -34,
            top: -44,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -26,
            bottom: -34,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: topPad + 12,
              bottom: 22,
              left: sw * 0.045,
              right: sw * 0.045,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ErpPressable(
                      onTap: () => Navigator.pop(context),
                      child: const ErpGlassCircle(
                          icon: Icons.arrow_back_ios_new_rounded,
                          iconSize: 19),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Quotation View',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Client card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: ErpColors.cyanDeep.withValues(alpha: 0.22),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: ErpColors.headerGradient,
                          borderRadius: BorderRadius.circular(17),
                          boxShadow: [
                            BoxShadow(
                              color: ErpColors.cyan.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.isNotEmpty ? name : 'Unknown Client',
                              style: const TextStyle(
                                color: ErpColors.ink,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Wrap(spacing: 6, runSpacing: 6, children: [
                              ErpMetaChip(
                                icon: Icons.tag_rounded,
                                text: quotation.quotationNumber,
                                color: ErpColors.cyanDeep,
                              ),
                              if (quotation.quotationDate.isNotEmpty)
                                ErpMetaChip(
                                  icon: Icons.calendar_today_rounded,
                                  text: quotation.quotationDate,
                                  color: ErpColors.violet,
                                ),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section card with info rows ───────────────────────────────────────────
  Widget _buildSection({
    required IconData icon,
    required Color color,
    required String title,
    required List<_InfoRow> rows,
  }) {
    final visibleRows = rows.where((r) => r.value.isNotEmpty).toList();
    if (visibleRows.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ErpColors.line),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(children: [
              ErpGradientTile(icon: icon, color: color, size: 38),
              const SizedBox(width: 11),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: ErpColors.ink,
                ),
              ),
            ]),
          ),
          const Divider(height: 1, thickness: 1, color: ErpColors.line),
          ...visibleRows.asMap().entries.map((entry) {
            final i = entry.key;
            final row = entry.value;
            final isLast = i == visibleRows.length - 1;

            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(row.icon,
                            size: 16, color: ErpColors.shade(color, 0.15)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.label,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: ErpColors.slate,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              row.value,
                              style: const TextStyle(
                                fontSize: 14,
                                color: ErpColors.ink,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 58,
                    color: ErpColors.line,
                  ),
              ],
            );
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ── Grand total card ──────────────────────────────────────────────────────
  Widget _buildTotalCard(double grandTotal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ErpColors.tint(ErpColors.green, 0.15), ErpColors.green],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: ErpColors.green.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withValues(alpha: 0.40)),
          ),
          child: const Icon(Icons.currency_rupee_rounded,
              color: Colors.white, size: 26),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Grand Total',
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.9))),
              const SizedBox(height: 2),
              Text(
                '₹ ${grandTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('Incl. tax',
              style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: ErpColors.green)),
        ),
      ]),
    );
  }

  // ── Section shell ─────────────────────────────────────────────────────────
  Widget _buildSectionShell({
    required IconData icon,
    required Color color,
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ErpColors.line),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              ErpGradientTile(icon: icon, color: color, size: 38),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: ErpColors.ink,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ]),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, thickness: 1, color: ErpColors.line),
            ),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 40),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: 0.14)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  // ── Products section ──────────────────────────────────────────────────────
  Widget _buildProductsSection(QuotationitemsModel quotation) {
    final items = quotation.items;
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        child: Column(
          children: [
            Icon(Icons.inventory_2_rounded,
                color: ErpColors.blue.withValues(alpha: 0.45), size: 26),
            const SizedBox(height: 6),
            const Text(
              'No products added',
              style: TextStyle(
                color: ErpColors.slate,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      children: List.generate(
        items.length,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: index < items.length - 1 ? 10 : 0),
          child: QuotationItems(index: index),
        ),
      ),
    );
  }

  // ── Go Back button ────────────────────────────────────────────────────────
  Widget _buildExitButton(BuildContext context) {
    return ErpPrimaryButton(
      text: 'Go Back',
      icon: Icons.arrow_back_rounded,
      onTap: () => Navigator.pop(context),
    );
  }

  // ── Action buttons (used by the commented-out PDF / Print row) ────────────
  // ignore: unused_element
  Widget _actionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool outlined = false,
  }) {
    return ErpPressable(
      onTap: onPressed,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: outlined ? null : ErpColors.headerGradient,
          color: outlined ? Colors.white : null,
          borderRadius: BorderRadius.circular(16),
          border: outlined
              ? Border.all(color: ErpColors.cyan.withValues(alpha: 0.45))
              : null,
          boxShadow: outlined
              ? null
              : [
                  BoxShadow(
                    color: ErpColors.cyan.withValues(alpha: 0.32),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: outlined ? ErpColors.cyanDeep : Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: outlined ? ErpColors.cyanDeep : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PDF — all unchanged from original ERP
  // ════════════════════════════════════════════════════════════════════════════
  static const _pdfNavy = PdfColor.fromInt(0xFF1A1A5E);
  static const _pdfBlue = PdfColor.fromInt(0xFF2563EB);
  static const _pdfWhite = PdfColors.white;
  static const _pdfTableHdrBg = PdfColor.fromInt(0xFFE8EEFF);
  static const _pdfTableHdrTxt = PdfColor.fromInt(0xFF1A3A7A);
  static const _pdfRowAlt = PdfColor.fromInt(0xFFF8F9FF);
  static const _pdfBorder = PdfColor.fromInt(0xFFD1D5DB);
  static const _pdfGrey600 = PdfColor.fromInt(0xFF4B5563);
  static const _pdfBoxHeadBg = PdfColor.fromInt(0xFFEFF6FF);
  static const _pdfBoxBorder = PdfColor.fromInt(0xFFBFDBFE);

  String _s(String raw) {
    return raw
        .replaceAll('\u20B9', 'Rs.')
        .replaceAll('\u2022', '-')
        .replaceAll('\u2013', '-')
        .replaceAll('\u2014', '--')
        .replaceAll('\u2018', "'")
        .replaceAll('\u2019', "'")
        .replaceAll('\u201C', '"')
        .replaceAll('\u201D', '"')
        .replaceAll('\u00A0', ' ');
  }

  pw.TextStyle get _tsNormal => const pw.TextStyle(fontSize: 8.5);
  pw.TextStyle get _tsBold =>
      pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold);
  pw.TextStyle get _tsSmall =>
      const pw.TextStyle(fontSize: 8, color: PdfColors.grey700);
  pw.TextStyle get _tsSmallGrey =>
      const pw.TextStyle(fontSize: 7.5, color: _pdfGrey600);
  pw.TextStyle get _tsTableCell => const pw.TextStyle(fontSize: 8);
  pw.TextStyle get _tsTableBold =>
      pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold);
  pw.TextStyle get _tsTableHdr => pw.TextStyle(
        fontSize: 8,
        fontWeight: pw.FontWeight.bold,
        color: _pdfTableHdrTxt,
      );

  pw.Widget _buildPdfPageHeader(
      pw.Context ctx, QuotationitemsModel quotation, Uint8List logoBytes) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Container(
              width: 120,
              height: 56,
              child:
                  pw.Image(pw.MemoryImage(logoBytes), fit: pw.BoxFit.contain),
            ),
            pw.Spacer(),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Pokak Technologies Pvt Ltd',
                    style: pw.TextStyle(
                        color: _pdfNavy,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 3),
                pw.Text('Kakkanad, Kochi - 682021', style: _tsSmall),
                pw.Text('+91 9656033444  |  pokaktech@gmail.com',
                    style: _tsSmall),
                pw.Text('www.pokaktech.com', style: _tsSmall),
                pw.SizedBox(height: 2),
                pw.Text('GSTIN 32AAMCP4053B1ZT',
                    style: pw.TextStyle(
                        fontSize: 8.5,
                        fontWeight: pw.FontWeight.bold,
                        color: _pdfNavy)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Divider(color: _pdfBorder, thickness: 0.8),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('QUOTATION DETAILS',
                    style: pw.TextStyle(
                        fontSize: 7.5,
                        fontWeight: pw.FontWeight.bold,
                        color: _pdfBlue)),
                pw.Text('Quotation No: ${_s(quotation.quotationNumber)}',
                    style: _tsSmallGrey),
                pw.Text('Date: ${_s(quotation.quotationDate)}',
                    style: _tsSmallGrey),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 8),
      ],
    );
  }

  pw.Widget _buildPdfPageFooter(pw.Context ctx) {
    return pw.Column(children: [
      pw.Divider(color: _pdfBorder, thickness: 0.6),
      pw.SizedBox(height: 3),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Pokak Technologies Pvt Ltd   |   +91 9656 033 444   |   pokaktech@gmail.com',
            style: _tsSmallGrey,
          ),
          pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: _tsSmallGrey),
        ],
      ),
    ]);
  }

  pw.Widget _buildFirstPageIntro(QuotationitemsModel quotation) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Center(
          child: pw.Text('PROPOSAL',
              style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: _pdfNavy,
                  letterSpacing: 2)),
        ),
        pw.SizedBox(height: 14),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('CLIENT DETAILS',
                      style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: _pdfBlue)),
                  pw.SizedBox(height: 5),
                  _pdfInfoRow('Client Name', _s(quotation.clientName)),
                  if (quotation.address.isNotEmpty)
                    _pdfInfoRow('Address', _s(quotation.address)),
                  if (quotation.deliveryLocation.isNotEmpty)
                    _pdfInfoRow('Location', _s(quotation.deliveryLocation)),
                ],
              ),
            ),
            pw.SizedBox(width: 16),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('QUOTATION DETAILS',
                    style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: _pdfBlue)),
                pw.SizedBox(height: 5),
                pw.Text('Quotation No: ${_s(quotation.quotationNumber)}',
                    style: _tsNormal),
                pw.Text('Date: ${_s(quotation.quotationDate)}',
                    style: _tsNormal),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Project : ',
                style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: _pdfNavy)),
            pw.Expanded(
              child: pw.Text(_s(quotation.projectName),
                  style: const pw.TextStyle(fontSize: 11)),
            ),
          ],
        ),
        pw.SizedBox(height: 16),
      ],
    );
  }

  pw.Widget _pdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 72, child: pw.Text(label, style: _tsBold)),
          pw.Text(' : ', style: _tsNormal),
          pw.Expanded(child: pw.Text(value, style: _tsNormal)),
        ],
      ),
    );
  }

  pw.Widget _buildItemsTable(List<QuotationItem> items) {
    const headers = [
      'SL/NO',
      'ITEM\nNAME',
      'DESCRIPTION',
      'QTY',
      'UNIT\nPRICE',
      'TAX\n(%)',
      'AMOUNT',
    ];
    final colWidths = {
      0: const pw.FixedColumnWidth(30),
      1: const pw.FixedColumnWidth(55),
      2: const pw.FlexColumnWidth(1),
      3: const pw.FixedColumnWidth(26),
      4: const pw.FixedColumnWidth(62),
      5: const pw.FixedColumnWidth(36),
      6: const pw.FixedColumnWidth(66),
    };

    pw.Widget headerCell(String text) => pw.Container(
          color: _pdfTableHdrBg,
          padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 8),
          child: pw.Text(_s(text),
              style: _tsTableHdr, textAlign: pw.TextAlign.center),
        );

    pw.Widget dataCell(String text,
            {pw.TextStyle? style, pw.TextAlign align = pw.TextAlign.left}) =>
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 7),
          child:
              pw.Text(_s(text), style: style ?? _tsTableCell, textAlign: align),
        );

    final headerRow =
        pw.TableRow(children: headers.map((h) => headerCell(h)).toList());
    final dataRows = <pw.TableRow>[];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final double taxPct = item.sgstPercentage + item.cgstPercentage;
      final bg = i.isOdd ? _pdfRowAlt : _pdfWhite;
      dataRows.add(pw.TableRow(
        decoration: pw.BoxDecoration(color: bg),
        children: [
          dataCell((i + 1).toString().padLeft(2, '0'),
              align: pw.TextAlign.center),
          dataCell(item.name, align: pw.TextAlign.center),
          dataCell(''),
          dataCell(
              item.quantity % 1 == 0
                  ? item.quantity.toInt().toString()
                  : item.quantity.toStringAsFixed(2),
              align: pw.TextAlign.center),
          dataCell('Rs.${item.unitPrice.toStringAsFixed(2)}',
              align: pw.TextAlign.right),
          dataCell('${taxPct.toStringAsFixed(0)}%', align: pw.TextAlign.center),
          dataCell('Rs.${item.subTotal.toStringAsFixed(2)}',
              style: _tsTableBold, align: pw.TextAlign.right),
        ],
      ));
    }

    return pw.Table(
      columnWidths: colWidths,
      border: pw.TableBorder.all(color: _pdfBorder, width: 0.5),
      children: [headerRow, ...dataRows],
    );
  }

  pw.Widget _buildTotalsBlock(List<QuotationItem> items, double grandTotal) {
    double subtotal = 0, totalTax = 0;
    for (final item in items) {
      subtotal += item.quantity * item.unitPrice;
      totalTax += item.sgst + item.cgst;
    }

    pw.Widget tRow(String label, String value,
        {bool bold = false, bool topLine = false}) {
      final style = bold
          ? pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5)
          : const pw.TextStyle(fontSize: 9);
      return pw.Column(children: [
        if (topLine) pw.Divider(color: _pdfBorder, thickness: 0.7),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 4),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(label, style: style),
              pw.Text(_s(value), style: style),
            ],
          ),
        ),
      ]);
    }

    return pw.Container(
      decoration: pw.BoxDecoration(
        color: _pdfWhite,
        border: pw.Border.all(color: _pdfBorder, width: 0.6),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.SizedBox(height: 4),
          tRow('Total', 'Rs. ${subtotal.toStringAsFixed(2)}'),
          tRow('Tax Amount', 'Rs. ${totalTax.toStringAsFixed(2)}'),
          tRow('Grand Total (Inc. Tax)', 'Rs. ${grandTotal.toStringAsFixed(2)}',
              bold: true, topLine: true),
          pw.SizedBox(height: 4),
        ],
      ),
    );
  }

  pw.Widget _buildAmountInWords(double amount) {
    final String words = _numberToWords(amount.round());
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: pw.BoxDecoration(
          border: pw.Border.all(color: _pdfBorder, width: 0.5)),
      child: pw.RichText(
        text: pw.TextSpan(children: [
          pw.TextSpan(
              text: 'Amount in Words: ',
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
          pw.TextSpan(
              text: '$words Only', style: const pw.TextStyle(fontSize: 9)),
        ]),
      ),
    );
  }

  String _numberToWords(int n) {
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
      'Nineteen',
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
      'Ninety',
    ];
    String w = '';
    if (n >= 10000000) {
      w += '${_numberToWords(n ~/ 10000000)} Crore ';
      n %= 10000000;
    }
    if (n >= 100000) {
      w += '${_numberToWords(n ~/ 100000)} Lakh ';
      n %= 100000;
    }
    if (n >= 1000) {
      w += '${_numberToWords(n ~/ 1000)} Thousand ';
      n %= 1000;
    }
    if (n >= 100) {
      w += '${ones[n ~/ 100]} Hundred ';
      n %= 100;
    }
    if (n >= 20) {
      w += '${tens[n ~/ 10]} ';
      n %= 10;
    }
    if (n > 0) w += '${ones[n]} ';
    return w.trim();
  }

  pw.Widget _buildPaymentTermsSection(QuotationitemsModel quotation) {
    final termsList = quotation.termsAndConditions;
    if (termsList.isEmpty) return pw.SizedBox();
    final heading = quotation.termsAndConditionsTitle.isNotEmpty
        ? quotation.termsAndConditionsTitle.toUpperCase()
        : 'PAYMENT TERMS';
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        color: _pdfWhite,
        border: pw.Border.all(color: _pdfBoxBorder, width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            decoration: const pw.BoxDecoration(
              color: _pdfBoxHeadBg,
              borderRadius: pw.BorderRadius.only(
                  topLeft: pw.Radius.circular(3),
                  topRight: pw.Radius.circular(3)),
            ),
            padding: const pw.EdgeInsets.fromLTRB(10, 7, 10, 7),
            child: pw.Text(_s(heading),
                style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: _pdfBlue)),
          ),
          pw.Divider(color: _pdfBoxBorder, thickness: 0.5),
          pw.SizedBox(height: 2),
          ...termsList.asMap().entries.map((entry) {
            return pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(10, 2, 10, 2),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                      width: 20,
                      child: pw.Text('${entry.key + 1}.', style: _tsBold)),
                  pw.Expanded(
                      child: pw.Text(_s(entry.value.point), style: _tsNormal)),
                ],
              ),
            );
          }),
          pw.SizedBox(height: 6),
        ],
      ),
    );
  }

  pw.Widget _buildContractSection(QuotationitemsModel quotation) {
    final sections = quotation.contract.sections;
    if (quotation.contractTitle.isEmpty && sections.isEmpty) {
      return pw.SizedBox();
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 3),
          decoration: const pw.BoxDecoration(
            border:
                pw.Border(bottom: pw.BorderSide(color: _pdfNavy, width: 1.2)),
          ),
          child: pw.Text('CONTRACT DETAILS',
              style: pw.TextStyle(
                  color: _pdfNavy,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold)),
        ),
        pw.SizedBox(height: 6),
        if (quotation.contractTitle.isNotEmpty)
          pw.Text(_s(quotation.contractTitle),
              style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: _pdfBlue)),
        pw.SizedBox(height: 8),
        ...sections.asMap().entries.map((sEntry) {
          final sIdx = sEntry.key + 1;
          final section = sEntry.value;
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('$sIdx. ${_s(section.title)}',
                  style: pw.TextStyle(
                      fontSize: 9.5,
                      fontWeight: pw.FontWeight.bold,
                      color: _pdfNavy)),
              pw.SizedBox(height: 3),
              ...section.points.map((cp) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 2, left: 12),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('-  ', style: const pw.TextStyle(fontSize: 9)),
                        pw.Expanded(
                            child: pw.Text(_s(cp.points),
                                style: const pw.TextStyle(fontSize: 9))),
                      ],
                    ),
                  )),
              pw.SizedBox(height: 7),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildPreparedBy(QuotationitemsModel quotation) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Prepared by',
            style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(_s(quotation.salespersonName),
            style: const pw.TextStyle(fontSize: 9.5)),
        pw.Text('Pokak Technologies Pvt Ltd',
            style: const pw.TextStyle(fontSize: 9.5)),
      ],
    );
  }

  Future<Directory?> _resolveOutputDirectory() async {
    try {
      final dl = await getDownloadsDirectory();
      if (dl != null) return dl;
    } catch (_) {}
    try {
      final ext = await getExternalStorageDirectory();
      if (ext != null) {
        final parts = ext.path.split('/');
        final idx = parts.indexOf('Android');
        if (idx > 0) {
          final dlDir =
              Directory('${parts.sublist(0, idx).join('/')}/Download');
          if (!await dlDir.exists()) await dlDir.create(recursive: true);
          return dlDir;
        }
        return ext;
      }
    } catch (_) {}
    try {
      return await getApplicationDocumentsDirectory();
    } catch (_) {}
    return null;
  }

  Future<void> _viewAndDownloadPdf(
      BuildContext context, QuotationitemsModel quotation) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Generating PDF...'), duration: Duration(seconds: 1)));
      final pdfBytes = await _generateQuotationPdf(quotation);
      final fileName =
          'Quotation_${quotation.quotationNumber.replaceAll('|', '_')}.pdf';
      await Printing.layoutPdf(onLayout: (_) async => pdfBytes, name: fileName);
      final directory = await _resolveOutputDirectory();
      if (directory != null) {
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(pdfBytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Saved: ${file.path}'),
              duration: const Duration(seconds: 4)));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Could not find a writable directory.')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('PDF Error: $e')));
      }
    }
  }

  Future<void> _printQuotation(
      BuildContext context, QuotationitemsModel quotation) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Opening print dialog...'),
          duration: Duration(seconds: 1)));
      final pdfBytes = await _generateQuotationPdf(quotation);
      await Printing.layoutPdf(
          onLayout: (_) async => pdfBytes,
          name: 'Quotation_${quotation.quotationNumber.replaceAll('|', '_')}');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Print dialog opened')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Print Error: $e')));
      }
    }
  }

  Future<Uint8List> _generateQuotationPdf(QuotationitemsModel quotation) async {
    final ByteData logoData =
        await rootBundle.load('assets/images/pokaklogo.png');
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final pdf = pw.Document();
    final items = quotation.items;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 36, 36, 54),
        header: (pw.Context ctx) =>
            _buildPdfPageHeader(ctx, quotation, logoBytes),
        footer: (pw.Context ctx) => _buildPdfPageFooter(ctx),
        build: (pw.Context ctx) => [
          _buildFirstPageIntro(quotation),
          pw.Text('PRODUCT DETAILS',
              style: pw.TextStyle(
                  color: _pdfNavy,
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          _buildItemsTable(items),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.SizedBox(
                  width: 260,
                  child: _buildTotalsBlock(items, quotation.grandTotal)),
            ],
          ),
          pw.SizedBox(height: 8),
          _buildAmountInWords(quotation.grandTotal),
          pw.SizedBox(height: 16),
          _buildPaymentTermsSection(quotation),
          pw.SizedBox(height: 18),
          _buildContractSection(quotation),
          pw.SizedBox(height: 16),
          _buildPreparedBy(quotation),
          pw.SizedBox(height: 10),
        ],
      ),
    );

    return pdf.save();
  }
}

// ── Row model ──────────────────────────────────────────────────────────────
class _InfoRow {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);
}