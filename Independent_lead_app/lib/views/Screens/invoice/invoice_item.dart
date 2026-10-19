import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

class InvoiceItemCard extends StatelessWidget {
  final int index;
  final dynamic item; // replace with InvoiceItemModel if you have it

  const InvoiceItemCard({
    super.key,
    required this.index,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cborder),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── ITEM NUMBER ─────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.c1.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Item ${index + 1}",
                style: const TextStyle(
                  color: AppColors.ctext,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          // ── PRODUCT NAME ─────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.cxl,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.cborder,
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
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
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
          color: AppColors.cxl,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.cborder,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.ctext,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.ctext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
