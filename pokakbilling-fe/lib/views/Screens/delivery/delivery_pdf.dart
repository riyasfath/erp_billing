import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_media_downloader/flutter_media_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/exit_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/pdf_custom_button.dart';
import 'package:pdf/widgets.dart' as pw;

class DeliveryPDF extends StatelessWidget {
  const DeliveryPDF({super.key});

  Future<String?> generateAndSavePDF() async {
    final pdf = pw.Document();

    // Create PDF content
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text("Delivery Invoice",
                style: const pw.TextStyle(fontSize: 30)),
          );
        },
      ),
    );

    // Get directory path
    final directory = await getApplicationDocumentsDirectory();
    final filePath = "${directory.path}/delivery_invoice.pdf";

    // Save PDF file
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  Future<void> downloadPDF(BuildContext context) async {
    if (await Permission.storage.request().isGranted) {
      final pdfPath = await generateAndSavePDF();
      if (pdfPath != null) {
        final flutterMediaDownloaderPlugin = MediaDownload();
        flutterMediaDownloaderPlugin.downloadMedia(context, pdfPath);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to create PDF")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission denied")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Delivery",
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
              PdfCustomButton(
                text: "Download",
                onTap: () => downloadPDF(context),
              ),
              const SizedBox(height: 10),
              const ExitCustomButton(text: 'Exit'),
            ],
          ),
        ),
      ),
    );
  }
}
