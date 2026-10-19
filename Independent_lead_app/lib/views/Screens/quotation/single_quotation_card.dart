import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/quotation/quotation_viewmodel.dart';
import 'package:pokakbilling/views/Screens/quotation/add/add_quotation.dart';
import 'package:pokakbilling/views/Screens/quotation/pdf/share_helper.dart';
import 'package:pokakbilling/views/Screens/quotation/view/view_quotation.dart';
import 'package:pokakbilling/views/commonWidgets/popups/delete_popup.dart';
import 'package:provider/provider.dart';

class SingleQuotationCard extends StatelessWidget {
  final int index;
  const SingleQuotationCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final quotationProvider = Provider.of<QuotationViewmodel>(context);
    final quotation = quotationProvider.filteredQuotationList[index];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Section ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.cxl,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.cborder, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      _initials(quotation.clientNameDisplay ??
                          quotation.clientName ??
                          "No client"),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.c1,
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
                        (quotation.clientNameDisplay ??
                                quotation.clientName ??
                                "No Client")
                            .toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cdark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        quotation.quotationNumber,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cdark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 11, color: AppColors.cdark),
                          const SizedBox(width: 4),
                          Text(
                            quotation.date,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.cdark),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Amount badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.tagGreen.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: AppColors.tagGreen.withOpacity(0.35)),
                  ),
                  child: Text(
                    "₹ ${quotation.grandTotal}",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.tagGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ──────────────────────────────────────────────
          const Divider(height: 1, thickness: 1, color: AppColors.cborder),

          // ── Actions ──────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 10, 24, 12),
            child: Row(
              children: [
                // VIEW
                _ActionBtn(
                  label: 'View',
                  icon: Icons.visibility_outlined,
                  color: AppColors.c1,
                  filled: true,
                  onTap: () async {
                    await quotationProvider
                        .getQuotationById(quotation.quotationId);
                    if (!context.mounted) return;
                    pushNavigation(context, const ViewQuotation());
                  },
                ),

                const SizedBox(width: 8),

                // EDIT
                _ActionBtn(
                  label: 'Edit',
                  icon: Icons.edit_outlined,
                  color: AppColors.c3,
                  filled: false,
                  onTap: () async {
                    await quotationProvider
                        .getQuotationById(quotation.quotationId);
                    if (!context.mounted) return;
                    pushNavigation(
                      context,
                      AddQuotation(
                        quotationId: quotation.quotationId,
                        quotationNumber: quotation.quotationNumber,
                        isEdit: true,
                      ),
                    );
                  },
                ),

                const SizedBox(width: 8),

                // DELETE
                Consumer<QuotationViewmodel>(
                  builder: (context, provider, _) => _ActionBtn(
                    label: 'Delete',
                    icon: Icons.delete_outline_rounded,
                    color: AppColors.tagRed,
                    filled: false,
                    onTap: () => showDeleteDialog(
                      context,
                      "Quotation",
                      () => provider.deleteQuotation(
                          quotation.quotationId, context),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // SHARE
                _ActionBtn(
                  label: 'Share',
                  icon: Icons.share_outlined,
                  color: AppColors.c3,
                  filled: false,
                  onTap: () async {
                    await quotationProvider
                        .getQuotationById(quotation.quotationId);
                    if (!context.mounted) return;
                    final full = quotationProvider.singleQuotation;
                    if (full == null) return;
                    _showShareSheet(context, full);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    if (name.isEmpty) return '';
    final parts = name.split(' ');
    return parts.length > 1
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : parts[0][0].toUpperCase();
  }
}

// ─── Action Button ────────────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: filled ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: filled ? null : Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: filled ? Colors.white : color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: filled ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Share Bottom Sheet ───────────────────────────────────────────────────────
void _showShareSheet(BuildContext context, dynamic quotation) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) {
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.cxl,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border(
            top: BorderSide(color: AppColors.cborder, width: 1.5),
            left: BorderSide(color: AppColors.cborder, width: 1.5),
            right: BorderSide(color: AppColors.cborder, width: 1.5),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cborder,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 18),

            // Title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.picture_as_pdf_outlined, color: AppColors.cdark),
                    SizedBox(width: 8),
                    Text(
                      'Share Quotation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cdark,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(sheetCtx),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.c3,
                    ),
                    child: const Icon(Icons.close,
                        size: 18, color: AppColors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            const Text(
              'A professionally formatted PDF will be generated & shared.',
              style: TextStyle(fontSize: 12, color: AppColors.ctext),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 22),

            // Options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _shareItem(
                  label: 'WhatsApp',
                  image: AppAssets.whatsappIcon,
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    QuotationShareHelper.shareAsPdf(
                      context: context,
                      quotation: quotation,
                      target: ShareTarget.whatsapp,
                    );
                  },
                ),
                _shareItem(
                  label: 'Email',
                  image: AppAssets.gmailIcon,
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    QuotationShareHelper.shareAsPdf(
                      context: context,
                      quotation: quotation,
                      target: ShareTarget.email,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

Widget _shareItem({
  required String label,
  required String image,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.cborder, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.c1.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Image.asset(image, width: 30, height: 30, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.cdark,
          ),
        ),
      ],
    ),
  );
}
