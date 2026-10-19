import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pokakbilling/models/data-models/delivery-models/delivery_pdf_model.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<Uint8List> readImageData(String name) async {
  final ByteData data = await rootBundle.load('assets/$name');
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

Future<void> saveAndLaunchFile(List<int> bytes, String fileName) async {
  final path = (await getApplicationDocumentsDirectory()).path;
  final file = File('$path/$fileName');
  await file.writeAsBytes(bytes, flush: true);
  OpenFile.open('$path/$fileName');
}

Future<void> createDeliveryPDF(DeliveryPdfModel delivery) async {
  PdfDocument document = PdfDocument();
  PdfPage page = document.pages.add();
// === HEADER ===
  PdfPageTemplateElement mainHeader = PdfPageTemplateElement(
    Rect.fromLTWH(0, 0, document.pageSettings.size.width, 180),
  );

  final ByteData imageData =
      await rootBundle.load('assets/pokak_tech_logo.jpeg');
  final Uint8List imageBytes = imageData.buffer.asUint8List();
  final PdfBitmap logo = PdfBitmap(imageBytes);
  const double logoWidth = 100;
  const double gapBetweenLogoAndDetails = 250;
  const double detailsLeft = 10 + logoWidth + gapBetweenLogoAndDetails;
  final double pageWidth = document.pageSettings.size.width;
  const double rightMargin = 20;
  final double detailsWidth = pageWidth - detailsLeft - rightMargin;
  mainHeader.graphics.drawImage(
    logo,
    const Rect.fromLTWH(10, 8, logoWidth, 50),
  );
  mainHeader.graphics.drawString(
    'Pokak Technologies Pvt Ltd',
    PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold),
    bounds: Rect.fromLTWH(detailsLeft, 5, detailsWidth, 20),
  );
  mainHeader.graphics.drawString(
    'Suit No. 414, Valamkottil Tower,',
    PdfStandardFont(PdfFontFamily.helvetica, 10),
    bounds: Rect.fromLTWH(detailsLeft, 22, detailsWidth, 15),
  );
  mainHeader.graphics.drawString(
    'Kakkanad, Kochi - 682021',
    PdfStandardFont(PdfFontFamily.helvetica, 10),
    bounds: Rect.fromLTWH(detailsLeft, 36, detailsWidth, 15),
  );
  mainHeader.graphics.drawString(
    '+91 9656 033 444 | pokaktech@gmail.com',
    PdfStandardFont(PdfFontFamily.helvetica, 10),
    bounds: Rect.fromLTWH(detailsLeft, 50, detailsWidth, 15),
  );
  mainHeader.graphics.drawString(
    'www.pokaktech.com',
    PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.italic),
    bounds: Rect.fromLTWH(detailsLeft, 64, detailsWidth, 15),
  );
  mainHeader.graphics.drawLine(
    PdfPen(PdfColor(128, 128, 128), width: 1),
    const Offset(0, 83),
    Offset(pageWidth, 83),
  );

  document.template.top = mainHeader;

// === FOOTER ===
  const double footerHeight = 45;

  PdfPageTemplateElement footer = PdfPageTemplateElement(
    Rect.fromLTWH(0, document.pageSettings.size.height - footerHeight,
        pageWidth, footerHeight),
  );
  footer.graphics.drawLine(
    PdfPen(PdfColor(128, 128, 128), width: 1),
    const Offset(0, 0),
    Offset(pageWidth, 0),
  );
  final PdfFont regularFont = PdfStandardFont(PdfFontFamily.helvetica, 9);
  final PdfFont italicFont =
      PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.italic);
  const String line1 =
      'If you have any queries about this price quote, Please contact';
  const String line2 = '+91 9656 033 444 | pokaktech@gmail.com';
  const String line3 = 'Thank You For Your Business!';
  const double topPaddingAfterLine = 6;
  footer.graphics.drawString(
    line1,
    regularFont,
    bounds: Rect.fromLTWH(0, topPaddingAfterLine, pageWidth, 12),
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  );
  footer.graphics.drawString(
    line2,
    regularFont,
    bounds: Rect.fromLTWH(0, topPaddingAfterLine + 14, pageWidth, 12),
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  );
  footer.graphics.drawString(
    line3,
    italicFont,
    bounds: Rect.fromLTWH(0, topPaddingAfterLine + 28, pageWidth, 12),
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  );
  PdfPageNumberField pageNumber =
      PdfPageNumberField(font: regularFont, brush: PdfBrushes.black);
  PdfCompositeField compositeField = PdfCompositeField(
    font: regularFont,
    brush: PdfBrushes.black,
    text: 'Page {0} of {1}',
    fields: <PdfAutomaticField>[pageNumber, PdfPageCountField()],
  );

  const double pageNumberWidth = 100;
  compositeField.bounds = Rect.fromLTWH(
    pageWidth - pageNumberWidth - 10,
    footerHeight - 15,
    pageNumberWidth,
    12,
  );
  compositeField.draw(
    footer.graphics,
    Offset(pageWidth - pageNumberWidth - 10, footerHeight - 15),
  );
  document.template.bottom = footer;
  double currentY = 20;
  double pageHeight = page.getClientSize().height;
  const double marginTop = 20;
  const double marginBottom = 20;
  PdfPage ensurePageSpace(
      PdfDocument doc, PdfPage currentPage, double yPos, double neededHeight) {
    double availableHeight = pageHeight - yPos - marginBottom;
    if (neededHeight > availableHeight) {
      currentPage = doc.pages.add();
      yPos = marginTop;
    }
    return currentPage;
  }

  final PdfFont boldFont =
      PdfStandardFont(PdfFontFamily.helvetica, 11, style: PdfFontStyle.bold);
  final PdfFont normalFont = PdfStandardFont(PdfFontFamily.helvetica, 11);
  page.graphics.drawString(
    "DELIVERY ORDER",
    PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold),
    bounds: Rect.fromLTWH(0, currentY, page.getClientSize().width, 30),
    format: PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    ),
  );
  currentY += 30;
  // ==== CLIENT DETAILS ====
  double clientY = 100;
  mainHeader.graphics.drawString(
    'Client Details',
    boldFont,
    bounds: Rect.fromLTWH(0, clientY, 300, 20),
  );
  clientY += 15;

  mainHeader.graphics.drawString(
    '${delivery.customer.firstName} ${delivery.customer.lastName}',
    boldFont,
    bounds: Rect.fromLTWH(0, clientY, 300, 15),
  );
  clientY += 12;

  List<String> addressLines = [
    delivery.customer.address,
    '${delivery.customer.state}, ${delivery.customer.country}',
    '${delivery.customer.mobile} | ${delivery.customer.email}',
  ];

  for (var line in addressLines) {
    mainHeader.graphics.drawString(
      line,
      normalFont,
      bounds: Rect.fromLTWH(0, clientY, 300, 20),
    );
    clientY += 15;
  }

// ==== QUOTE DETAILS ====
  double quoteDetailsY = 100;
  double quoteDetailsX = pageWidth - 220;

  mainHeader.graphics.drawString(
    'Delivery Details',
    boldFont,
    bounds: Rect.fromLTWH(quoteDetailsX, quoteDetailsY, 200, 15),
    format: PdfStringFormat(alignment: PdfTextAlignment.right),
  );
  quoteDetailsY += 15;

  mainHeader.graphics.drawString(
    'Delivery No: ${delivery.deliveryNumber}',
    normalFont,
    bounds: Rect.fromLTWH(quoteDetailsX, quoteDetailsY, 200, 15),
    format: PdfStringFormat(alignment: PdfTextAlignment.right),
  );
  quoteDetailsY += 15;

  mainHeader.graphics.drawString(
    'Date: ${delivery.deliveryDate}',
    normalFont,
    bounds: Rect.fromLTWH(quoteDetailsX, quoteDetailsY, 200, 15),
    format: PdfStringFormat(alignment: PdfTextAlignment.right),
  );

  page.graphics.drawString(
    "Project Name: ",
    boldFont,
    bounds: Rect.fromLTWH(0, currentY, page.getClientSize().width, 30),
    format: PdfStringFormat(
      alignment: PdfTextAlignment.left,
      lineAlignment: PdfVerticalAlignment.top,
    ),
  );
  currentY += 30;

  // Table
  PdfGrid grid = PdfGrid();
  grid.columns.add(count: 6);
  grid.columns[0].width = 30;
  grid.columns[1].width = 80;
  grid.columns[2].width = 200;
  grid.columns[3].width = 50;
  grid.columns[4].width = 60;
  // grid.columns[5].width = 50;
  // grid.columns[6].width = 50;
  grid.columns[5].width = 75;
  grid.headers.add(1);

  PdfGridRow header = grid.headers[0];
  header.cells[0].value = 'SL/NO';
  header.cells[1].value = 'ITEM NAME';
  header.cells[2].value = 'DESCRIPTION';
  header.cells[3].value = 'QTY';
  header.cells[4].value = 'PRICE';
  // header.cells[5].value = 'SGST';
  // header.cells[6].value = 'CGST';
  header.cells[5].value = 'TOTAL';

  PdfPen violetBluePen = PdfPen(PdfColor(100, 60, 181));

  for (int i = 0; i < header.cells.count; i++) {
    header.cells[i].style = PdfGridCellStyle(
      font: PdfStandardFont(PdfFontFamily.helvetica, 11,
          style: PdfFontStyle.bold),
      cellPadding: PdfPaddings(left: 4, right: 4, top: 4, bottom: 4),
      textBrush: PdfSolidBrush(PdfColor(100, 60, 181)),
      backgroundBrush: PdfBrushes.white,
      borders: PdfBorders(
        left: violetBluePen,
        right: violetBluePen,
        top: violetBluePen,
        bottom: violetBluePen,
      ),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
    );
  }

  for (int i = 0; i < delivery.items.length; i++) {
    final formatCurrency =
        NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 2);
    final item = delivery.items[i];
    PdfGridRow row = grid.rows.add();
    row.cells[0].value = '${i + 1}';
    row.cells[1].value = item.productName;
    row.cells[2].value = item.productDescription;
    row.cells[3].value = item.deliveredQuantity.toString();
    row.cells[4].value =
        formatCurrency.format(double.parse(item.unitPrice.replaceAll(',', '')));
    row.cells[5].value =
        formatCurrency.format(double.parse(item.subTotal.replaceAll(',', '')));

    for (int j = 0; j < row.cells.count; j++) {
      PdfTextAlignment horizontalAlign;
      PdfVerticalAlignment verticalAlign = PdfVerticalAlignment.bottom;

      if (j == 3) {
        // QTY column
        horizontalAlign = PdfTextAlignment.center;
      } else if (j == 4 || j == 5) {
        // PRICE and TOTAL columns
        horizontalAlign = PdfTextAlignment.right;
      } else if (j == 2) {
        // DESCRIPTION column
        horizontalAlign = PdfTextAlignment.left;
      } else if (j == 0) {
        // SL/NO
        horizontalAlign = PdfTextAlignment.center;
      } else if (j == 1) {
        // ITEM NAME
        horizontalAlign = PdfTextAlignment.left;
      } else {
        horizontalAlign = PdfTextAlignment.left;
      }

      row.cells[j].style = PdfGridCellStyle(
        font: PdfStandardFont(PdfFontFamily.helvetica, 11),
        cellPadding: PdfPaddings(left: 4, right: 4, top: 4, bottom: 4),
        textBrush: PdfBrushes.black,
        backgroundBrush: PdfBrushes.white,
        borders: PdfBorders(
          left: violetBluePen,
          right: violetBluePen,
          top: violetBluePen,
          bottom: violetBluePen,
        ),
        format: PdfStringFormat(
          alignment: horizontalAlign,
          lineAlignment: verticalAlign,
        ),
      );
    }
  }
  final gridResult = grid.draw(
    page: page,
    bounds: Rect.fromLTWH(0, currentY, pageWidth, 0),
  )!;
  currentY = gridResult.bounds.bottom + 20;

  double totalRightX = pageWidth - 280 - rightMargin;
  double spacing = 20;

  String totalLabel = 'Total (INR)';
  String totalValue = delivery.grandTotal;

  double labelWidth = boldFont.measureString(totalLabel).width;
  double valueWidth = boldFont.measureString(totalValue).width;
  double totalWidth = labelWidth + spacing + valueWidth;

// Align the total block starting from the right edge
  double startX = totalRightX +
      200 -
      totalWidth; // Assuming width of quoteDetails block is 200

  page.graphics.drawString(
    totalLabel,
    boldFont,
    bounds: Rect.fromLTWH(startX, currentY, labelWidth, 20),
    brush: PdfBrushes.black,
  );
  page.graphics.drawString(
    totalValue,
    boldFont,
    bounds:
        Rect.fromLTWH(startX + labelWidth + spacing, currentY, valueWidth, 20),
    brush: PdfBrushes.deepPink,
  );

  currentY += 40;
  double leftX = 0;
  double sectionTopY = currentY;
  page.graphics.drawString(
    'Prepared by',
    boldFont,
    bounds: Rect.fromLTWH(leftX, sectionTopY, 200, 20),
  );
  sectionTopY += 20;
  page.graphics.drawString(
    "Name",
    // '${delivery.salesperson.firstName} ${delivery.salesperson.lastName}',
    normalFont,
    bounds: Rect.fromLTWH(leftX, sectionTopY, 200, 20),
  );
  sectionTopY += 15;
  page.graphics.drawString(
    "email",
    // order.salesperson.email,
    normalFont,
    bounds: Rect.fromLTWH(leftX, sectionTopY, 200, 20),
  );

  sectionTopY += 15;

  page.graphics.drawString(
    "9945678900",
    // order.salesperson.mobile,
    normalFont,
    bounds: Rect.fromLTWH(leftX, sectionTopY, 200, 20),
  );

  sectionTopY += 20;
  page.graphics.drawLine(
    PdfPen(PdfColor(169, 169, 169)),
    Offset(leftX, sectionTopY),
    Offset(pageWidth, sectionTopY),
  );
  currentY += 80;
  PdfGrid termsGrid = PdfGrid();
  termsGrid.columns.add(count: 1);

// Header Row
  PdfGridRow termsHeader = termsGrid.headers.add(1)[0];
  termsHeader.cells[0].value = 'Terms & Conditions';
  termsHeader.style = PdfGridCellStyle(
    font: boldFont,
    textBrush: PdfBrushes.white,
    backgroundBrush: PdfSolidBrush(PdfColor(100, 60, 181)),
    cellPadding: PdfPaddings(left: 8, right: 8, top: 0, bottom: 0),
    borders: PdfBorders(
      left: PdfPen(PdfColor(192, 192, 192), width: 1),
      right: PdfPen(PdfColor(192, 192, 192), width: 1),
      top: PdfPen(PdfColor(192, 192, 192), width: 1),
      bottom: PdfPen(PdfColor(192, 192, 192), width: 1),
    ),
    format: PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    ),
  );
  for (int i = 0; i < delivery.termsandconditions.length; i++) {
    final term = delivery.termsandconditions[i];
    PdfGridRow row = termsGrid.rows.add();
    row.cells[0].value = '${i + 1}. ${term.point}';
    row.cells[0].style = PdfGridCellStyle(
      font: normalFont,
      textBrush: PdfBrushes.black,
      backgroundBrush: PdfBrushes.white,
      cellPadding: PdfPaddings(left: 8, right: 8, top: 0, bottom: 0),
      borders: PdfBorders(
        left: PdfPen(PdfColor(192, 192, 192), width: 1),
        right: PdfPen(PdfColor(192, 192, 192), width: 1),
        top: i == 0
            ? PdfPen(PdfColor(192, 192, 192), width: 1)
            : PdfPen(PdfColor.empty),
        bottom: i == delivery.termsandconditions.length - 1
            ? PdfPen(PdfColor(192, 192, 192), width: 1)
            : PdfPen(PdfColor.empty),
      ),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.left,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
    );
  }
  termsGrid.draw(
    page: page,
    bounds: Rect.fromLTWH(0, currentY, pageWidth, 0),
  );

  currentY += 150;

  List<int> bytes = await document.save();
  document.dispose();
  saveAndLaunchFile(bytes, 'Delivery_Order.pdf');
}
