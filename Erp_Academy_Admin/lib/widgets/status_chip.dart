import 'package:flutter/material.dart';

import '../core/utils/text_format.dart';

/// Colored pill for statuses like Active, Inactive, Completed, Paid, Partially Paid…
class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key, this.small = false});

  final String status;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final s = status.trim().toLowerCase();
    late Color fg, bg;

    if (s.contains('partial')) {
      fg = const Color(0xFFB45309);
      bg = const Color(0xFFFFF7E6);
    } else if (s == 'active' || s == 'paid') {
      fg = const Color(0xFF16A34A);
      bg = const Color(0xFFEAF8EF);
    } else if (s.contains('complete')) {
      fg = const Color(0xFF2563EB);
      bg = const Color(0xFFEAF1FF);
    } else if (s == 'pending' || s == 'unpaid' || s.contains('overdue')) {
      fg = const Color(0xFFDC2626);
      bg = const Color(0xFFFFEEEE);
    } else {
      fg = const Color(0xFF6B7280);
      bg = const Color(0xFFF1F2F4);
    }

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 8 : 10, vertical: small ? 3 : 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(.35)),
      ),
      child: Text(TextFormat.pretty(status),
          style: TextStyle(
              fontSize: small ? 10 : 11,
              fontWeight: FontWeight.w800,
              color: fg)),
    );
  }
}