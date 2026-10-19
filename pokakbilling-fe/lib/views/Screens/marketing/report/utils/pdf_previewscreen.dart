// lib/views/Screens/marketing/report/pdf_preview_screen.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:path_provider/path_provider.dart';

/// PDF preview screen showing only the preview, share and download actions.
class PdfPreviewScreen extends StatefulWidget {
  final Future<Uint8List> Function(PdfPageFormat format) pdfBytesBuilder;
  final String title;

  const PdfPreviewScreen({
    super.key,
    required this.pdfBytesBuilder,
    this.title = 'PDF Preview',
  });

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  bool _isDownloading = false;
  bool _isSharing = false;

  Future<void> _sharePdf() async {
    setState(() => _isSharing = true);
    try {
      final bytes = await widget.pdfBytesBuilder(PdfPageFormat.a4);
      await Printing.sharePdf(bytes: bytes, filename: '${widget.title}.pdf');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _downloadPdf() async {
    setState(() => _isDownloading = true);
    try {
      final bytes = await widget.pdfBytesBuilder(PdfPageFormat.a4);

      Directory? baseDir;
      try {
        baseDir = await getExternalStorageDirectory();
      } catch (_) {
        baseDir = null;
      }

      baseDir ??= await getApplicationDocumentsDirectory();

      final safeTitle = widget.title.isNotEmpty
          ? widget.title.replaceAll(RegExp(r'[^\w\-_\. ]'), '_')
          : 'document';
      final fileName = '$safeTitle.pdf';
      final filePath = '${baseDir.path}/$fileName';
      final file = File(filePath);

      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloaded to: $filePath')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData localTheme = Theme.of(context).copyWith(
      colorScheme:
          Theme.of(context).colorScheme.copyWith(primary: AppColors.violetblue),
      primaryColor: AppColors.violetblue,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.violetblue,
        foregroundColor: AppColors.white,
      ),
    );

    return Theme(
      data: localTheme,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.violetblue,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            widget.title,
            style: const TextStyle(color: AppColors.white),
          ),
        ),
        body: Column(
          children: [
            // The pure PDF preview with no toolbar/toggle
            Expanded(
              child: PdfPreview(
                allowPrinting: false,
                allowSharing: false,
                canChangeOrientation: false,
                canChangePageFormat: false,
                useActions: false, // <-- disables top toggle toolbar
                pageFormats: const {'A4': PdfPageFormat.a4},
                build: (format) async =>
                    await widget.pdfBytesBuilder(PdfPageFormat.a4),
                loadingWidget: const Center(child: CircularProgressIndicator()),
              ),
            ),

            // Bottom action bar
            Container(
              color: AppColors.violetblue,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSharing ? null : _sharePdf,
                        icon: _isSharing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppColors.white),
                              )
                            : const Icon(Icons.share, color: AppColors.white),
                        label: _isSharing
                            ? const Text('Sharing...',
                                style: TextStyle(color: AppColors.white))
                            : const Text('Share',
                                style: TextStyle(color: AppColors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.violetblue,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: const BorderSide(color: AppColors.softBorder),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isDownloading ? null : _downloadPdf,
                        icon: _isDownloading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppColors.white),
                              )
                            : const Icon(Icons.download,
                                color: AppColors.white),
                        label: _isDownloading
                            ? const Text('Downloading...',
                                style: TextStyle(color: AppColors.white))
                            : const Text('Download',
                                style: TextStyle(color: AppColors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.violetblue,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: const BorderSide(color: AppColors.softBorder),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
