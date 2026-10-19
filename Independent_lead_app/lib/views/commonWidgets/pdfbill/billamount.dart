import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

class CommonInvoiceSection extends StatelessWidget {
  final String title;
  final List<DataRow> dataRows;
  final double subtotal;
  final double total;

  const CommonInvoiceSection({
    super.key,
    required this.title,
    required this.dataRows,
    required this.subtotal,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(color: AppColors.grey, width: 1),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Company Name",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Q001011"),
                    Text("Date: 01/08/2023"),
                  ],
                ),
              ],
            ),
            const Divider(),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Received by",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Company Name"),
                      Text("Company address"),
                      Text("City, Country - 00000"),
                      Text("+0 (000) 123-4567"),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Prepared by",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Panda, Inc"),
                      Text("Business address"),
                      Text("City, State, IN - 000 000"),
                      Text("TAX ID: 000XXX1234XX"),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),
            DataTable(
              columnSpacing: 6,
              columns: const [
                DataColumn(
                    label: SizedBox(width: 80, child: Text("Item Name"))),
                DataColumn(
                    label: SizedBox(width: 80, child: Text("Description"))),
                DataColumn(label: Text("QTY")),
                DataColumn(label: Text("Rate")),
                DataColumn(label: Text("Tax")),
                DataColumn(label: Text("Amount")),
              ],
              rows: dataRows,
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Subtotal",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.grey,
                  ),
                ),
                Text(
                  " \$${subtotal.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total (USD):",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                Text(" \$${total.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink)),
              ],
            ),
            const Divider(),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Text("Payment details: "),
                    Text("Cash on Delivery"),
                  ],
                ),
                Column(
                  children: [
                    Text("Bank Name:"),
                    Text("IFSC Code:"),
                    Text("Swift Code:"),
                    Text("Account #:"),
                  ],
                ),
                Column(
                  children: [
                    Text("ABCD BANK"),
                    Text("ABCD000XXX"),
                    Text("ABCDUSXXX"),
                    Text("3747489 230001"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 50),
            const Center(child: Text("THANK YOU FOR YOUR BUSINESS!")),
          ],
        ),
      ),
    );
  }
}
