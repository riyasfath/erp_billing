import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/exit_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/print_colorfilled_button.dart';
import 'package:pokakbilling/views/commonWidgets/pdfbill/billamount.dart';

class SalesReturnsPDF extends StatelessWidget {
  const SalesReturnsPDF({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final List<DataRow> dataRows = [
      const DataRow(cells: [
        DataCell(SizedBox(width: 80, child: Text("Item Name"))),
        DataCell(SizedBox(width: 50, child: Text(""))),
        DataCell(Text("1")),
        DataCell(Text("\$100")),
        DataCell(Text("0%")),
        DataCell(Text("\$100")),
      ]),
      const DataRow(cells: [
        DataCell(SizedBox(width: 80, child: Text("Item Name"))),
        DataCell(SizedBox(width: 50, child: Text(""))),
        DataCell(Text("1")),
        DataCell(Text("\$100")),
        DataCell(Text("0%")),
        DataCell(Text("\$100")),
      ]),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sales Returns",
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w500,
            fontSize: screenWidth * 0.05,
          ),
        ),
        backgroundColor: AppColors.violetblue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CommonInvoiceSection(
                title: "Sales Returns",
                dataRows: dataRows,
                subtotal: 100,
                total: 100,
              ),
              const SizedBox(height: 10),
              const PrintFilledCustomButton(text: 'Print'),
              const SizedBox(height: 10),
              const ExitCustomButton(text: 'Exit'),
            ],
          ),
        ),
      ),
    );
  }
}
