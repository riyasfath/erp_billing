import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';
import 'package:pokakbilling/views/Screens/quotation/view/quotation_pdf_service.dart';
import 'package:printing/printing.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/viewmodels/quotation/quotation_viewmodel.dart';
import 'package:pokakbilling/views/Screens/quotation/view/view_quotation.dart';
import 'package:pokakbilling/views/commonWidgets/popups/delete_popup.dart';
import 'package:provider/provider.dart';

class SingleQuotationCard extends StatefulWidget {
  final int index;

  const SingleQuotationCard({
    super.key,
    required this.index,
  });

  @override
  State<SingleQuotationCard> createState() => _SingleQuotationCardState();
}

class _SingleQuotationCardState extends State<SingleQuotationCard> {
  bool _sharing = false;
  bool _opening = false;

  String _initials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    return parts.length > 1 && parts[1].isNotEmpty
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : parts[0][0].toUpperCase();
  }

  Future<void> _handleShare(BuildContext context, QuotationViewmodel provider,
      int quotationId) async {
    if (_sharing) return;
    setState(() => _sharing = true);

    try {
      await provider.getQuotationById(quotationId);
      if (!context.mounted) return;

      if (provider.singleQuotationList.isEmpty) {
        _showSnack(context, 'Could not load quotation details.', isError: true);
        return;
      }

      final quotation = provider.singleQuotationList[0];

      final pdfBytes = await QuotationPdfService.generate(quotation);
      final fileName = QuotationPdfService.fileName(quotation);

      // Save to a temp file so we can share it with a proper filename.
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      if (!context.mounted) return;

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: fileName,
      );
    } catch (e) {
      if (context.mounted) {
        _showSnack(context, 'Failed to share quotation: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  void _showSnack(BuildContext context, String message,
      {bool isError = false}) {
    erpToast(
      context,
      message,
      color: isError ? ErpColors.red : ErpColors.cyanDeep,
      icon: isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final quotationProvider = Provider.of<QuotationViewmodel>(context);
    final quotation = quotationProvider.quotationList[widget.index];

    final String rawName = quotation.customerName.trim();
    final bool nameIsGeneric =
        rawName.isEmpty || rawName.toLowerCase() == 'client';
    final String displayName =
        nameIsGeneric ? quotation.quotationNumber : rawName;
    final avatarColor = ErpColors
        .rotation[displayName.hashCode.abs() % ErpColors.rotation.length];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Top Section ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [ErpColors.tint(avatarColor, 0.22), avatarColor],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: avatarColor.withValues(alpha: 0.32),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _initials(displayName),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
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
                      displayName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: ErpColors.ink,
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
                      ErpMetaChip(
                        icon: Icons.calendar_today_rounded,
                        text: quotation.quotationDate,
                        color: ErpColors.violet,
                      ),
                    ]),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Amount badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Total',
                      style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: ErpColors.slate)),
                  const SizedBox(height: 2),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          ErpColors.tint(ErpColors.green, 0.2),
                          ErpColors.green
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: ErpColors.green.withValues(alpha: 0.30),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      "₹ ${quotation.grandTotal}",
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Divider ──────────────────────────────────────────────────────
        const Divider(height: 1, thickness: 1, color: ErpColors.line),

        // ── Actions ──────────────────────────────────────────────────────
        Consumer<QuotationViewmodel>(
          builder: (context, provider, _) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 10, 24, 12),
              child: Row(
                children: [
                  // VIEW
                  _ActionBtn(
                    label: _opening ? 'Opening...' : 'View',
                    icon: Icons.visibility_rounded,
                    color: ErpColors.cyan,
                    filled: true,
                    loading: _opening,
                    onTap: () async {
                      setState(() => _opening = true);
                      try {
                        await provider
                            .getQuotationById(quotation.quotationId);
                        if (!context.mounted) return;
                        pushNavigation(context, const ViewQuotation());
                      } finally {
                        if (mounted) setState(() => _opening = false);
                      }
                    },
                  ),

                  const SizedBox(width: 8),

                  // SHARE
                  _ActionBtn(
                    label: _sharing ? 'Preparing...' : 'Share PDF',
                    icon: Icons.share_rounded,
                    color: ErpColors.violet,
                    filled: false,
                    loading: _sharing,
                    onTap: () =>
                        _handleShare(context, provider, quotation.quotationId),
                  ),

                  const SizedBox(width: 8),

                  // DELETE
                  _ActionBtn(
                    label: 'Delete',
                    icon: Icons.delete_rounded,
                    color: ErpColors.red,
                    filled: false,
                    onTap: () => showDeleteDialog(
                      context,
                      "Quotation",
                      () => provider.deleteQuotation(
                          quotation.quotationId, context),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─── Action Button ────────────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final bool loading;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.filled,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : ErpColors.shade(color, 0.12);
    return ErpPressable(
      onTap: loading ? null : onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: loading ? 0.75 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            gradient: filled
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [ErpColors.tint(color, 0.2), color],
                  )
                : null,
            color: filled ? null : color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
            border: filled
                ? null
                : Border.all(color: color.withValues(alpha: 0.28)),
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.32),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : const [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              loading
                  ? SizedBox(
                      width: 13,
                      height: 13,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.8,
                        color: filled ? Colors.white : color,
                      ),
                    )
                  : Icon(icon, size: 14, color: filled ? Colors.white : color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}