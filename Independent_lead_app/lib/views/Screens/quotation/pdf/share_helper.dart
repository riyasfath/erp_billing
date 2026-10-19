// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:pokakbilling/models/data-models/quotations-models/quotation_model.dart';
// import 'package:pokakbilling/views/Screens/quotation/pdf/pdf_generator.dart';

// enum ShareTarget { whatsapp, email }

// class QuotationShareHelper {
//   static Future<void> shareAsPdf({
//     required BuildContext context,
//     required QuotationModel quotation,
//     required ShareTarget target,
//   }) async {
//     // Show loading
//     _showLoadingDialog(context);

//     try {
//       // 1. Generate the PDF file
//       final File file = await QuotationPdfGenerator.generate(quotation);

//       if (!context.mounted) return;
//       Navigator.of(context).pop(); // close loading dialog

//       final clientName = (quotation.clientNameDisplay?.isNotEmpty == true
//               ? quotation.clientNameDisplay!
//               : quotation.clientName ?? 'Client')
//           .trim();

//       final subject = 'Quotation ${quotation.quotationNumber} - $clientName';
//       final body = _buildBody(quotation, clientName);

//       // 2. Share the PDF using share_plus
//       final xFile = XFile(file.path, mimeType: 'application/pdf');

//       if (target == ShareTarget.whatsapp) {
//         // Share directly to WhatsApp
//         await Share.shareXFiles(
//           [xFile],
//           text: body,
//           sharePositionOrigin: Rect.zero,
//         );
//       } else {
//         // Share to email
//         await Share.shareXFiles(
//           [xFile],
//           subject: subject,
//           text: body,
//           sharePositionOrigin: Rect.zero,
//         );
//       }
//     } catch (e) {
//       if (context.mounted) {
//         // Close loading dialog if still open
//         Navigator.of(context).pop();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed: $e'),
//             backgroundColor: const Color(0xFFDC2626),
//             behavior: SnackBarBehavior.floating,
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           ),
//         );
//       }
//     }
//   }

//   static String _buildBody(QuotationModel q, String clientName) {
//     final buf = StringBuffer();
//     buf.writeln('Dear $clientName,');
//     buf.writeln();
//     buf.writeln('Please find attached Quotation *${q.quotationNumber}*.');
//     if ((q.projectName ?? '').isNotEmpty) {
//       buf.writeln('Project     : ${q.projectName}');
//     }
//     buf.writeln('Date        : ${q.date}');
//     if ((q.validUntil ?? '').isNotEmpty) {
//       buf.writeln('Valid Until : ${q.validUntil}');
//     }
//     buf.writeln('Grand Total : \u20b9${q.grandTotal}');
//     buf.writeln();
//     buf.writeln('Thank you for your business!');
//     return buf.toString();
//   }

//   static void _showLoadingDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => PopScope(
//         canPop: false,
//         child: Dialog(
//           backgroundColor: Colors.white,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const SizedBox(
//                   width: 46,
//                   height: 46,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 3,
//                     color: Color(0xFF3BBCD9),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 const Text(
//                   'Generating PDF…',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF155F72),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Please wait a moment',
//                   style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pokakbilling/models/data-models/quotations-models/quotation_model.dart';
import 'package:pokakbilling/views/Screens/quotation/pdf/pdf_generator.dart';

enum ShareTarget { whatsapp, email }

class QuotationShareHelper {
  static Future<void> shareAsPdf({
    required BuildContext context,
    required QuotationModel quotation,
    required ShareTarget target,
  }) async {
    _showLoadingDialog(context);

    try {
      final File file = await QuotationPdfGenerator.generate(quotation);

      if (!context.mounted) return;
      Navigator.of(context).pop(); // close loading dialog

      final clientName = (quotation.clientNameDisplay?.isNotEmpty == true
              ? quotation.clientNameDisplay!
              : quotation.clientName ?? 'Client')
          .trim();

      final subject = 'Quotation ${quotation.quotationNumber} - $clientName';
      final body = _buildBody(quotation, clientName);
      final xFile = XFile(file.path, mimeType: 'application/pdf');

      if (target == ShareTarget.whatsapp) {
        await _shareToWhatsApp(context, xFile, body);
      } else {
        await _shareToEmail(context, xFile, subject, body);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  // ── WhatsApp direct ────────────────────────────────────────────────────────
  static Future<void> _shareToWhatsApp(
    BuildContext context,
    XFile file,
    String body,
  ) async {
    // Try to open WhatsApp directly via deep link with the PDF
    // share_plus with shareXFiles targeting WhatsApp package
    try {
      final result = await Share.shareXFiles(
        [file],
        text: body,
        sharePositionOrigin: Rect.zero,
      );

      // If user cancelled or share sheet appeared, try direct WhatsApp URI
      if (result.status == ShareResultStatus.dismissed ||
          result.status == ShareResultStatus.unavailable) {
        await _openWhatsAppFallback(body);
      }
    } catch (_) {
      await _openWhatsAppFallback(body);
    }
  }

  static Future<void> _openWhatsAppFallback(String body) async {
    final encoded = Uri.encodeComponent(body);
    final waUri = Uri.parse('whatsapp://send?text=$encoded');
    if (await canLaunchUrl(waUri)) {
      await launchUrl(waUri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Gmail / Email direct ───────────────────────────────────────────────────
  static Future<void> _shareToEmail(
    BuildContext context,
    XFile file,
    String subject,
    String body,
  ) async {
    // First try Gmail via intent (Android) / mailto (iOS)
    final encodedSubject = Uri.encodeComponent(subject);
    final encodedBody = Uri.encodeComponent(body);

    // Try Gmail package directly on Android
    final gmailUri = Uri.parse(
      'googlegmail://co?subject=$encodedSubject&body=$encodedBody',
    );

    if (await canLaunchUrl(gmailUri)) {
      // Gmail can open but can't attach file via URI — share PDF via share_plus
      // targeting Gmail specifically
      await Share.shareXFiles(
        [file],
        subject: subject,
        text: body,
        sharePositionOrigin: Rect.zero,
      );
    } else {
      // Fallback: mailto URI — opens default mail app directly
      final mailtoUri = Uri.parse(
        'mailto:?subject=$encodedSubject&body=$encodedBody',
      );
      if (await canLaunchUrl(mailtoUri)) {
        await launchUrl(mailtoUri, mode: LaunchMode.externalApplication);
        // After mail app opens, also share file so attachment is available
        await Future.delayed(const Duration(milliseconds: 800));
        if (context.mounted) {
          await Share.shareXFiles(
            [file],
            subject: subject,
            text: body,
            sharePositionOrigin: Rect.zero,
          );
        }
      } else {
        // Last resort: system share sheet
        await Share.shareXFiles(
          [file],
          subject: subject,
          text: body,
          sharePositionOrigin: Rect.zero,
        );
      }
    }
  }

  // ── Message body ───────────────────────────────────────────────────────────
  static String _buildBody(QuotationModel q, String clientName) {
    final buf = StringBuffer();
    buf.writeln('Dear $clientName,');
    buf.writeln();
    buf.writeln('Please find attached Quotation *${q.quotationNumber}*.');
    if ((q.projectName ?? '').isNotEmpty) {
      buf.writeln('Project     : ${q.projectName}');
    }
    buf.writeln('Date        : ${q.date}');
    if ((q.validUntil ?? '').isNotEmpty) {
      buf.writeln('Valid Until : ${q.validUntil}');
    }
    buf.writeln('Grand Total : \u20b9${q.grandTotal}');
    buf.writeln();
    buf.writeln('Thank you for your business!');
    return buf.toString();
  }

  // ── Loading dialog ─────────────────────────────────────────────────────────
  static void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 46,
                  height: 46,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Color(0xFF3BBCD9),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Generating PDF…',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF155F72),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Please wait a moment',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
