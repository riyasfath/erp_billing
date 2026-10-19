import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

/// Shared small helpers reused across the Call Activity tabs
/// (Dashboard / Today's Tasks / Follow-ups / Call History).
/// Extracted unchanged from the original CallActivityScreen file.

String initialsFromName(String name) {
  final parts =
      name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    return parts.first
        .substring(0, parts.first.length >= 2 ? 2 : 1)
        .toUpperCase();
  }
  return (parts[0][0] + parts[1][0]).toUpperCase();
}

// ── Shared: section header with live count badge ─────────────────────────
Widget sectionLabelWithBadge(
    String text, int count, Color color, IconData icon) {
  return Row(
    children: [
      Icon(icon, size: 13, color: color.withOpacity(0.75)),
      const SizedBox(width: 6),
      Text(
        text,
        style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: AppColors.cdark,
            letterSpacing: 1.1),
      ),
      const SizedBox(width: 7),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text('$count',
            style: TextStyle(
                fontSize: 9.5, fontWeight: FontWeight.w800, color: color)),
      ),
    ],
  );
}

// ── Shared: loading state ─────────────────────────────────────────────────
Widget callActivityLoadingState() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 90),
    child: Center(
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.c1.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(13),
            child: const CircularProgressIndicator(
              strokeWidth: 2.6,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.c1),
            ),
          ),
          const SizedBox(height: 14),
          const Text('Loading…',
              style: TextStyle(
                  color: AppColors.ctext,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    ),
  );
}

// ── Shared: empty state ───────────────────────────────────────────────────
Widget callActivityEmptyState({
  required IconData icon,
  required String title,
  required String subtitle,
  bool compact = false,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: compact ? 26 : 64),
    child: Center(
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.c1.withOpacity(0.10),
                  AppColors.c1.withOpacity(0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cborder),
            ),
            child: Icon(icon, color: AppColors.c1.withOpacity(0.55), size: 26),
          ),
          const SizedBox(height: 14),
          Text(title,
              style: const TextStyle(
                  color: AppColors.cdark,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.ctext.withOpacity(0.60),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget callActivityPillLabel(String text, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
    ),
  );
}

Widget callActivityDetailRow(String label, String value, {Color? pillColor}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 13),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 104,
          child: Text(
            label,
            style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.ctext.withOpacity(0.6)),
          ),
        ),
        Expanded(
          child: pillColor != null
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: callActivityPillLabel(value, pillColor),
                )
              : Text(
                  value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cdark),
                ),
        ),
      ],
    ),
  );
}
