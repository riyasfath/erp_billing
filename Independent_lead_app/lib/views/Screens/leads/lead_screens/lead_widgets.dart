// lib/views/Screens/leads/common/lead_widgets.dart  (NEW)
// Shared building blocks for Dashboard / Leads / AI generator screens.

import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

class LeadUi {
  LeadUi._();

  static const Color hot = Color(0xFFEF4444);
  static const Color warm = Color(0xFFF59E0B);
  static const Color cool = Color(0xFF3B82F6);

  static const Color followUp = Color(0xFFF59E0B);
  static const Color meeting = Color(0xFF8B5CF6);
  static const Color call = Color(0xFF2A9BB8);
  static const Color email = Color(0xFF38BDF8);
  static const Color whatsapp = Color(0xFF22C55E);

  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFDC2626);

  static Color priorityColor(String? p) {
    switch ((p ?? '').toUpperCase()) {
      case 'HOT':
        return hot;
      case 'WARM':
        return warm;
      case 'COOL':
        return cool;
      default:
        return AppColors.ctext;
    }
  }

  static String priorityName(String? p) {
    switch ((p ?? '').toUpperCase()) {
      case 'HOT':
        return 'Hot';
      case 'WARM':
        return 'Warm';
      case 'COOL':
        return 'Cool';
      default:
        return '';
    }
  }

  /// Web naming used on the summary cards.
  static String priorityLevel(String? p) {
    switch ((p ?? '').toUpperCase()) {
      case 'HOT':
        return 'High';
      case 'WARM':
        return 'Medium';
      case 'COOL':
        return 'Low';
      default:
        return '';
    }
  }

  static Color statusColor(String? s) {
    switch ((s ?? '').toUpperCase()) {
      case 'NEW':
        return AppColors.c3;
      case 'CONTACTED':
        return meeting;
      case 'QUALIFIED':
      case 'PENDING':
        return warm;
      case 'CONVERTED':
      case 'COMPLETED':
      case 'SENT':
        return success;
      case 'LOST':
      case 'OVERDUE':
      case 'FAILED':
        return danger;
      case 'GENERATED':
        return meeting;
      case 'REPLIED':
        return AppColors.c3;
      default:
        return AppColors.ctext;
    }
  }

  static List<BoxShadow> shadow([double o = .07]) => [
        BoxShadow(
          color: AppColors.c1.withOpacity(o),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ];

  static IconData typeIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('meeting')) return Icons.videocam_rounded;
    if (t.contains('call')) return Icons.call_rounded;
    if (t.contains('whatsapp')) return Icons.chat_rounded;
    if (t.contains('email') || t.contains('mail')) return Icons.mail_rounded;
    return Icons.repeat_rounded;
  }

  static Color typeColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('meeting')) return meeting;
    if (t.contains('call')) return call;
    if (t.contains('whatsapp')) return whatsapp;
    if (t.contains('email') || t.contains('mail')) return email;
    return followUp;
  }
}

// ─── Fade + slide in ──────────────────────────────────────────────────────────
class Reveal extends StatelessWidget {
  final Widget child;
  final int delayMs;
  const Reveal({super.key, required this.child, this.delayMs = 0});

  @override
  Widget build(BuildContext context) {
    final total = 420 + delayMs;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(delayMs / total, 1, curve: Curves.easeOutCubic),
      builder: (_, v, c) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.translate(offset: Offset(0, (1 - v) * 16), child: c),
      ),
      child: child,
    );
  }
}

// ─── Card ────────────────────────────────────────────────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Color? accent;
  final Color? background;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.accent,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(18);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: background ?? AppColors.white,
        borderRadius: r,
        border: Border.all(color: AppColors.c1.withOpacity(0.15)),
        boxShadow: LeadUi.shadow(),
      ),
      child: ClipRRect(
        borderRadius: r,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (accent != null) Container(height: 3, color: accent),
                Padding(padding: padding, child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Section title ───────────────────────────────────────────────────────────
class SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  const SectionTitle(
      {super.key, required this.icon, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.c1.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: AppColors.c3),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.cdark)),
          ),
          if (trailing != null) trailing!,
        ],
      );
}

// ─── Empty hint ──────────────────────────────────────────────────────────────
class EmptyHint extends StatelessWidget {
  final IconData icon;
  final String text;
  const EmptyHint(
      {super.key, this.icon = Icons.auto_awesome_rounded, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.cxl,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cborder),
              ),
              child: Icon(icon,
                  color: AppColors.ctext.withOpacity(0.45), size: 24),
            ),
            const SizedBox(height: 10),
            Text(text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.ctext.withOpacity(0.75))),
          ]),
        ),
      );
}

// ─── Pills ───────────────────────────────────────────────────────────────────
class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const StatusPill({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.30)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: .4,
                color: color)),
      );
}

class PriorityBadge extends StatelessWidget {
  final String? priority;
  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final name = LeadUi.priorityName(priority);
    if (name.isEmpty) return const SizedBox.shrink();
    final c = LeadUi.priorityColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withOpacity(0.30)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.star_rounded, size: 11, color: c),
        const SizedBox(width: 3),
        Text(name,
            style:
                TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: c)),
      ]),
    );
  }
}

// ─── Page header ─────────────────────────────────────────────────────────────
class AppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;
  final Widget? bottom;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, top + 12, 16, 14),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.cborder, width: 1.5)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          if (onBack != null) ...[
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.cxl,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cborder),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.c3, size: 15),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      color: AppColors.cdark,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .2)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!,
                    style:
                        const TextStyle(color: AppColors.ctext, fontSize: 12)),
              ],
            ]),
          ),
          if (trailing != null) trailing!,
        ]),
        if (bottom != null) ...[const SizedBox(height: 12), bottom!],
      ]),
    );
  }
}

// ─── Filter chip ─────────────────────────────────────────────────────────────
class SoftChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const SoftChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.c1.withOpacity(0.10) : AppColors.white,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
                color: active
                    ? AppColors.c1.withOpacity(0.45)
                    : AppColors.cborder),
          ),
          child: Row(children: [
            Icon(icon,
                size: 13, color: active ? AppColors.c1 : AppColors.ctext),
            const SizedBox(width: 5),
            Expanded(
              child: Text(label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: active ? AppColors.c1 : AppColors.ctext)),
            ),
            if (active && onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Padding(
                  padding: EdgeInsets.only(left: 3),
                  child: Icon(Icons.close_rounded, size: 14, color: AppColors.c1),
                ),
              )
            else
              const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 15, color: AppColors.ctext),
          ]),
        ),
      );
}

// ─── Search field ────────────────────────────────────────────────────────────
class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const SearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) => Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.cborder),
        ),
        child: Row(children: [
          const Icon(Icons.search_rounded, size: 18, color: AppColors.ctext),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 13, color: AppColors.cdark),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle:
                    const TextStyle(fontSize: 13, color: AppColors.ctext),
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, v, __) => v.text.isEmpty
                ? const SizedBox.shrink()
                : GestureDetector(
                    onTap: () {
                      controller.clear();
                      onChanged?.call('');
                      onClear?.call();
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                          color: AppColors.c1.withOpacity(0.12),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.close_rounded,
                          size: 12, color: AppColors.c1),
                    ),
                  ),
          ),
        ]),
      );
}

// ─── Primary gradient button ─────────────────────────────────────────────────
class GradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool loading;
  final double height;

  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.loading = false,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null || loading;
    return Opacity(
      opacity: disabled ? .6 : 1,
      child: GestureDetector(
        onTap: disabled ? null : onTap,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            gradient: AppColors.buttonGradient,
            borderRadius: BorderRadius.circular(height / 2),
            boxShadow: [
              BoxShadow(
                  color: AppColors.c1.withOpacity(.30),
                  blurRadius: 14,
                  offset: const Offset(0, 5)),
            ],
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: AppColors.white, strokeWidth: 2))
                : Row(mainAxisSize: MainAxisSize.min, children: [
                    if (icon != null) ...[
                      Icon(icon, color: AppColors.white, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(label,
                        style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .4)),
                  ]),
          ),
        ),
      ),
    );
  }
}

// ─── Selection bottom sheet ──────────────────────────────────────────────────
Future<void> showPickerSheet(
  BuildContext context, {
  required String title,
  required List<String> options,
  required String selected,
  required ValueChanged<String> onSelect,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
                color: AppColors.c1.withOpacity(0.25),
                borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
            child: Row(children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.cdark)),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(ctx),
                icon: Icon(Icons.close_rounded,
                    color: AppColors.ctext.withOpacity(0.55)),
              ),
            ]),
          ),
          Divider(height: 1, color: AppColors.c1.withOpacity(0.10)),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: options.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: AppColors.c1.withOpacity(0.07)),
              itemBuilder: (_, i) {
                final o = options[i];
                final sel = o == selected;
                return ListTile(
                  title: Text(o,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: sel ? FontWeight.w800 : FontWeight.w400,
                          color: sel ? AppColors.c1 : AppColors.cdark)),
                  trailing: sel
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppColors.c1, size: 20)
                      : null,
                  onTap: () {
                    onSelect(o);
                    Navigator.pop(ctx);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ]),
      ),
    ),
  );
}

void showToast(BuildContext context, String msg, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: error ? LeadUi.danger : AppColors.c3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
}