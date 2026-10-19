import 'package:flutter/material.dart';
import 'package:pokakbilling/views/academy/academy_palette.dart';

/// Kept for compatibility with older screens.
class AcademyColors {
  static const purple = AcadPal.primary;
  static const primary = AcadPal.primary;
  static const green = AcadPal.deep;
  static const amber = AcadPal.lilac;
  static const blue = AcadPal.cyanDeep;
}

/// Avatar: soft tinted circle, shade picked from the name.
class AcademyAvatar extends StatelessWidget {
  final String name;
  final double size;
  final int seed;
  const AcademyAvatar(
      {super.key, required this.name, this.size = 46, this.seed = 0});

  @override
  Widget build(BuildContext context) {
    final c = AcadPal.forName(name);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.withValues(alpha: 0.30), AcadPal.cyan.withValues(alpha: 0.12)],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: c.withValues(alpha: 0.40), width: 1.5),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
              color: Color.lerp(c, AcadPal.dark, 0.35),
              fontWeight: FontWeight.w800,
              fontSize: size * 0.42),
        ),
      ),
    );
  }
}

class AdmissionBadge extends StatelessWidget {
  final bool taken;
  const AdmissionBadge({super.key, required this.taken});

  @override
  Widget build(BuildContext context) {
    final c = taken ? AcadPal.cyanDeep : AcadPal.text;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: taken ? AcadPal.cyan.withValues(alpha: 0.14) : AcadPal.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: taken
                ? AcadPal.cyan.withValues(alpha: 0.50)
                : AcadPal.border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(taken ? Icons.check_circle_rounded : Icons.schedule_rounded,
            size: 14, color: c),
        const SizedBox(width: 5),
        Text(taken ? 'Admission Taken' : 'Admission Pending',
            style:
                TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c)),
      ]),
    );
  }
}

class AcademyChip extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color color;
  const AcademyChip(
      {super.key, required this.text, this.icon, this.color = AcadPal.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AcadPal.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AcadPal.border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
        ],
        Flexible(
          child: Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AcadPal.text)),
        ),
      ]),
    );
  }
}

class AcademySectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const AcademySectionCard(
      {super.key,
      required this.icon,
      required this.title,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AcadPal.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AcadPal.primary.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
              color: AcadPal.primary.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 5)),
          BoxShadow(
              color: AcadPal.cyan.withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(4, 8)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 4,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [AcadPal.lilac, AcadPal.primary, AcadPal.cyan]),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18), topRight: Radius.circular(18)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AcadPal.primary.withValues(alpha: 0.16),
                      AcadPal.cyan.withValues(alpha: 0.18),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 20, color: AcadPal.deep),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AcadPal.dark)),
              ),
            ]),
            Divider(height: 24, color: AcadPal.primary.withValues(alpha: 0.12)),
            child,
          ]),
        ),
      ]),
    );
  }
}

class AcademyInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const AcademyInfoRow(
      {super.key,
      required this.icon,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AcadPal.lilac.withValues(alpha: 0.26),
              AcadPal.cyan.withValues(alpha: 0.22),
            ],
          ),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, size: 19, color: AcadPal.deep),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(),
              style: TextStyle(
                  fontSize: 11.5,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w700,
                  color: AcadPal.text.withValues(alpha: 0.85))),
          const SizedBox(height: 3),
          Text(value.isEmpty ? 'N/A' : value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AcadPal.dark)),
        ]),
      ),
    ]);
  }
}

/// Bottom-sheet single-select picker used by the filter chips.
void showAcademyPicker({
  required BuildContext context,
  required String title,
  required List<String> options,
  required String selected,
  required void Function(String) onSelect,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => Container(
      decoration: const BoxDecoration(
        color: AcadPal.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 42,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
                gradient: AcadPal.brandGradient,
                borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
            child: Row(children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AcadPal.dark)),
              const Spacer(),
              IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded, color: AcadPal.text)),
            ]),
          ),
          Divider(height: 1, color: AcadPal.primary.withValues(alpha: 0.10)),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: options.length,
              separatorBuilder: (_, __) => Divider(
                  height: 1, color: AcadPal.primary.withValues(alpha: 0.07)),
              itemBuilder: (_, i) {
                final o = options[i];
                final sel = o == selected;
                return ListTile(
                  tileColor:
                      sel ? AcadPal.cyan.withValues(alpha: 0.10) : null,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                  title: Text(o,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                          color: sel ? AcadPal.primary : AcadPal.dark)),
                  trailing: sel
                      ? const Icon(Icons.check_circle_rounded,
                          color: AcadPal.cyanDeep, size: 22)
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

String academyFormatDate(String raw) {
  final d = DateTime.tryParse(raw);
  if (d == null) return raw.isEmpty ? '—' : raw;
  return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}