import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/quotation/quotation_viewmodel.dart';
import 'package:provider/provider.dart';

// ─── COLOR SYSTEM ─────────────────────────────────────────────
class _C {
  _C._();
  static const Color navy = AppColors.navy;
  static const Color cyan = AppColors.cyan;
  static const Color ice = AppColors.ice;
  static const Color white = AppColors.white;
  static const Color red = AppColors.red;
  static const Color cyan1 = Color(0xFF5DD6EE);
  static const Color cyan2 = Color(0xFF2A9BB8);
  static const Color cyan3 = Color(0xFF1E7A94);
  static const Color navy2 = Color(0xFF38496A);
}
// ─────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────
// 🔷 MAIN SECTION (PRODUCT HEADER + ITEMS LIST)
// ─────────────────────────────────────────────────────────────
class QuotationItemsSection extends StatelessWidget {
  const QuotationItemsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final quotationProvider = Provider.of<QuotationViewmodel>(context);
    final items = quotationProvider.singleQuotation?.items ?? [];

    if (items.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── PRODUCT HEADER (ONLY ONCE) ─────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _C.cyan.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: _C.cyan,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Products",
                  style: TextStyle(
                    color: AppColors.cdark,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── ITEMS LIST ─────────────────
        ...List.generate(
          items.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: QuotationItems(index: index),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 🔷 ITEM CARD
// ─────────────────────────────────────────────────────────────
class QuotationItems extends StatelessWidget {
  final int index;
  const QuotationItems({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final quotationProvider = Provider.of<QuotationViewmodel>(context);
    final item = quotationProvider.singleQuotation!.items[index];

    return Container(
      decoration: BoxDecoration(
        color: _C.cyan.withOpacity(0.06), // light cyan background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.c1.withOpacity(0.15), // silver border
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── ITEM NUMBER ─────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.c1.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Item ${index + 1}",
                style: const TextStyle(
                  color: AppColors.c1,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          // ── PRODUCT NAME ─────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.c1.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.c1.withOpacity(0.20),
                ),
              ),
              child: Center(
                child: Text(
                  item.productName ?? "—",
                  style: const TextStyle(
                    color: AppColors.cdark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // ── VALUES GRID ─────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildField("Quantity", item.quantity.toString()),
                    _buildField("Unit Price", item.unitPrice.toString()),
                    _buildField("Total", item.total.toString()),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildField("SGST", item.sgst.toString()),
                    _buildField("CGST", item.cgst.toString()),
                    _buildField("Sub Total", item.total.toString()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── FIELD BOX ─────────────────
  Widget _buildField(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.c1.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.c1.withOpacity(0.20)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.cdark.withOpacity(0.55),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.cdark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
