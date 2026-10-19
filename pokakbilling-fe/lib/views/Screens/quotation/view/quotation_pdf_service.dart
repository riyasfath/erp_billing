import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pokakbilling/models/data-models/quotations-models/quotationItems_model.dart';

/// Shared PDF generation for quotations.
/// Extracted from ViewQuotation's original (working) PDF logic so both
/// the View screen (Print) and the Quotation list card (Share) use the
/// exact same PDF output.
class QuotationPdfService {
  QuotationPdfService._();

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

  static String _s(String raw) {
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

  static pw.TextStyle get _tsNormal => const pw.TextStyle(fontSize: 8.5);
  static pw.TextStyle get _tsBold =>
      pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold);
  static pw.TextStyle get _tsSmall =>
      const pw.TextStyle(fontSize: 8, color: PdfColors.grey700);
  static pw.TextStyle get _tsSmallGrey =>
      const pw.TextStyle(fontSize: 7.5, color: _pdfGrey600);
  static pw.TextStyle get _tsTableCell => const pw.TextStyle(fontSize: 8);
  static pw.TextStyle get _tsTableBold =>
      pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold);
  static pw.TextStyle get _tsTableHdr => pw.TextStyle(
        fontSize: 8,
        fontWeight: pw.FontWeight.bold,
        color: _pdfTableHdrTxt,
      );

  static pw.Widget _buildPdfPageHeader(
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

  static pw.Widget _buildPdfPageFooter(pw.Context ctx) {
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

  static pw.Widget _buildFirstPageIntro(QuotationitemsModel quotation) {
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

  static pw.Widget _pdfInfoRow(String label, String value) {
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

  static pw.Widget _buildItemsTable(List<QuotationItem> items) {
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

  static pw.Widget _buildTotalsBlock(
      List<QuotationItem> items, double grandTotal) {
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

  static pw.Widget _buildAmountInWords(double amount) {
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

  static String _numberToWords(int n) {
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

  static pw.Widget _buildPaymentTermsSection(QuotationitemsModel quotation) {
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

  static pw.Widget _buildContractSection(QuotationitemsModel quotation) {
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

  static pw.Widget _buildPreparedBy(QuotationitemsModel quotation) {
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

  /// Public entry point — generates the full quotation PDF as bytes.
  static Future<Uint8List> generate(QuotationitemsModel quotation) async {
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

  /// Suggested filename for saving/sharing.
  static String fileName(QuotationitemsModel quotation) {
    return 'Quotation_${quotation.quotationNumber.replaceAll('|', '_').replaceAll('/', '_')}.pdf';
  }
}
