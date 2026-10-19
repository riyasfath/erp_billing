import 'package:flutter/material.dart';
import 'package:pokakbilling/views/academy/academy_palette.dart';
import 'package:pokakbilling/views/academy/academy_theme.dart';
import 'package:pokakbilling/views/academy/academy_widgets.dart';

const Color kAcadGreen = AcadPal.green;

IconData acadMethodIcon(String? m) {
  switch ((m ?? '').toLowerCase()) {
    case 'upi':
      return Icons.qr_code_2_rounded;
    case 'card':
      return Icons.credit_card_rounded;
    case 'bank_transfer':
    case 'bank':
    case 'neft':
      return Icons.account_balance_rounded;
    case 'cash':
      return Icons.payments_rounded;
    default:
      return Icons.payments_outlined;
  }
}

/// Each payment method gets its own violet / cyan shade.
Color acadMethodColor(String? m) {
  switch ((m ?? '').toLowerCase()) {
    case 'upi':
      return AcadPal.indigo;
    case 'card':
      return AcadPal.plum;
    case 'bank_transfer':
    case 'bank':
    case 'neft':
      return AcadPal.periwinkle;
    case 'cash':
      return AcadPal.cyanDeep;
    default:
      return AcadPal.lilac;
  }
}

IconData acadCategoryIcon(String c) {
  switch (c) {
    case 'advance':
      return Icons.bolt_rounded;
    case 'installment':
      return Icons.event_repeat_rounded;
    case 'slot_amount':
      return Icons.event_seat_rounded;
    case 'admission_first_payment':
      return Icons.flag_rounded;
    default:
      return Icons.receipt_long_rounded;
  }
}

Color acadCategoryColor(String c) {
  switch (c) {
    case 'advance':
      return AcadPal.cyanDeep;
    case 'installment':
      return AcadPal.primary;
    case 'slot_amount':
      return AcadPal.periwinkle;
    case 'admission_first_payment':
      return AcadPal.plum;
    default:
      return AcadPal.lilac;
  }
}

// ── Error banner ─────────────────────────────────────────────────────────────
class AcadErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const AcadErrorBanner(
      {super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: AcadPal.red.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AcadPal.red.withValues(alpha: 0.25)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded, color: AcadPal.red, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AcadPal.dark)),
        ),
        TextButton(
          onPressed: onRetry,
          child: const Text('Retry',
              style: TextStyle(
                  color: AcadPal.red, fontWeight: FontWeight.w800)),
        ),
      ]),
    );
  }
}

// ── Filter row ───────────────────────────────────────────────────────────────
class AcadFilterSpec {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback onClear;
  const AcadFilterSpec(
      this.icon, this.label, this.active, this.onTap, this.onClear);
}

AcadFilterSpec acadPicker({
  required BuildContext context,
  required IconData icon,
  required String hint,
  required String title,
  required List<String> options,
  required String? value,
  required ValueChanged<String?> onChanged,
}) =>
    AcadFilterSpec(
      icon,
      value ?? hint,
      value != null,
      () => showAcademyPicker(
        context: context,
        title: title,
        options: ['All', ...options],
        selected: value ?? 'All',
        onSelect: (v) => onChanged(v == 'All' ? null : v),
      ),
      () => onChanged(null),
    );

class AcadFilterRow extends StatelessWidget {
  final List<AcadFilterSpec> filters;
  final bool showReset;
  final VoidCallback onReset;
  const AcadFilterRow({
    super.key,
    required this.filters,
    required this.showReset,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      for (var i = 0; i < filters.length; i++) ...[
        if (i > 0) const SizedBox(width: 8),
        Expanded(
          child: AcadFilterPill(
            icon: filters[i].icon,
            label: filters[i].label,
            active: filters[i].active,
            onTap: filters[i].onTap,
            onClear: filters[i].onClear,
          ),
        ),
      ],
      if (showReset) ...[
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onReset,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AcadPal.red.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(color: AcadPal.red.withValues(alpha: 0.25)),
            ),
            child: const Icon(Icons.restart_alt_rounded,
                size: 20, color: AcadPal.red),
          ),
        ),
      ],
    ]);
  }
}

// ── Person card (registration / admission lists) ─────────────────────────────
class AcadPersonCard extends StatelessWidget {
  final String name, phone, pill, date;
  final Color accent;
  final IconData badge;
  final List<Widget> tags;
  final VoidCallback onTap;

  const AcadPersonCard({
    super.key,
    required this.name,
    required this.phone,
    required this.pill,
    required this.date,
    required this.accent,
    required this.badge,
    required this.tags,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AcadPressable(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [accent.withValues(alpha: 0.10), AcadPal.white],
          ),
          border: Border.all(color: accent.withValues(alpha: 0.24)),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.14),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(children: [
            Positioned(
              right: -12,
              top: -12,
              child:
                  Icon(badge, size: 70, color: accent.withValues(alpha: 0.07)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Column(children: [
                Row(children: [
                  Stack(clipBehavior: Clip.none, children: [
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [accent, AcadPal.cyan],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                            color: AcadPal.white, shape: BoxShape.circle),
                        child: AcademyAvatar(name: name, size: 44),
                      ),
                    ),
                    Positioned(
                      right: -3,
                      bottom: -3,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: AcadPal.white, width: 2),
                        ),
                        child: Icon(badge, size: 10, color: AcadPal.white),
                      ),
                    ),
                  ]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w800,
                                  color: AcadPal.dark)),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AcadPal.cyanSoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.phone_rounded,
                                      size: 12.5, color: AcadPal.cyanDeep),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(phone,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: AcadPal.text)),
                                  ),
                                ]),
                          ),
                        ]),
                  ),
                  const SizedBox(width: 8),
                  AcadStatusPill(label: pill, color: accent),
                ]),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
                  decoration: BoxDecoration(
                    color: AcadPal.bgSoft,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AcadPal.border),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Wrap(spacing: 6, runSpacing: 6, children: tags),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.event_rounded,
                        size: 14, color: AcadPal.text),
                    const SizedBox(width: 3),
                    Text(date,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AcadPal.text)),
                    const SizedBox(width: 6),
                    AcadArrowButton(color: accent),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}