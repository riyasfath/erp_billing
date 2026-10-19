import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:pokakbilling/models/data-models/marketing_model/marketing_report.dart';

/// ---------------------------------------------------------------------------
/// MARKETING REPORT PDF BUILDER
/// ---------------------------------------------------------------------------
/// Generates a simple A4-sized Marketing Report as a PDF file.
/// Returns a [Uint8List] of bytes that can be saved, shared, or printed.
/// ---------------------------------------------------------------------------
Future<Uint8List> buildMarketingPdfSimple({
  required List<MarketingReport> reports,
}) async {
  final pdf = pw.Document();

  // Define headers for the table
  final headers = [
    'SL/NO',
    'DATE',
    'SALES PERSON',
    'SOURCE',
    'LOCATION',
    'CATEGORY',
    'CALLS',
    'LEADS',
  ];

  // Convert each report into a row of strings
  final data = reports.asMap().entries.map((entry) {
    final index = entry.key + 1;
    final r = entry.value;
    return [
      '$index',
      r.date,
      r.salesperson,
      r.source,
      r.location,
      r.category,
      '${r.calls}',
      '${r.leads}',
    ];
  }).toList();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      build: (context) => [
        // Header Section
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Pokak Technologies Pvt Ltd',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text('Kakkanad, Kochi - 682021',
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('+91 9656 033 444 | pokaktech@gmail.com',
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('www.pokaktech.com',
                      style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ),
          ],
        ),

        pw.SizedBox(height: 12),

        // Title
        pw.Center(
          child: pw.Text(
            'MARKETING REPORT',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
        ),

        pw.SizedBox(height: 12),

        // Table Section
        pw.Table.fromTextArray(
          headers: headers,
          data: data,
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 9,
            color: PdfColors.black,
          ),
          cellStyle: const pw.TextStyle(fontSize: 9),
          headerDecoration: const pw.BoxDecoration(
            color: PdfColors.grey300,
          ),
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          cellAlignment: pw.Alignment.centerLeft,
          columnWidths: {
            0: const pw.FlexColumnWidth(4),
            1: const pw.FlexColumnWidth(8),
            2: const pw.FlexColumnWidth(20),
            3: const pw.FlexColumnWidth(14),
            4: const pw.FlexColumnWidth(14),
            5: const pw.FlexColumnWidth(20),
            6: const pw.FlexColumnWidth(6),
            7: const pw.FlexColumnWidth(6),
          },
          cellPadding: const pw.EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 6,
          ),
        ),
      ],

      // Footer Section
      footer: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 8),
        child: pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 9),
        ),
      ),
    ),
  );

  return pdf.save();
}
