import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

/// Use [ErpIcons.whatsapp] anywhere the kit takes an IconData — it renders the
/// real WhatsApp logo (SVG) instead of a font glyph.
class ErpIcons {
  ErpIcons._();
  static const IconData whatsapp =
      IconData(0xF232, fontFamily: 'ErpBrandIcons');
}

const String kErpWhatsAppSvg = '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347z"/>
  <path d="M12 0C5.373 0 0 5.373 0 12c0 2.125.558 4.122 1.528 5.855L.057 23.885a.5.5 0 00.611.611l6.101-1.459A11.945 11.945 0 0012 24c6.627 0 12-5.373 12-12S18.627 0 12 0zm0 21.818a9.818 9.818 0 01-5.012-1.378l-.36-.214-3.724.89.908-3.64-.235-.374A9.818 9.818 0 0112 2.182c5.428 0 9.818 4.39 9.818 9.818 0 5.429-4.39 9.818-9.818 9.818z"/>
</svg>
''';

/// Drop-in replacement for [Icon] that also understands [ErpIcons.whatsapp].
Widget erpIcon(IconData icon, {double size = 20, Color? color}) {
  if (icon == ErpIcons.whatsapp) {
    // The SVG fills its whole box, so shrink it a touch to match glyph icons.
    final s = size * 0.9;
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: SvgPicture.string(
          kErpWhatsAppSvg,
          width: s,
          height: s,
          colorFilter:
              color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
        ),
      ),
    );
  }
  return Icon(icon, size: size, color: color);
}

// ─── Palette ─────────────────────────────────────────────────────────────────
class ErpColors {
  ErpColors._();

  static const Color pageBg = Color(0xFFF0FAFD);
  static const Color ink = Color(0xFF0F172A);
  static const Color slate = Color(0xFF64748B);
  static const Color line = Color(0xFFD9ECF2);

  static const Color cyan = Color(0xFF06B6D4);
  static const Color cyanLight = Color(0xFF67E8F9);
  static const Color cyanDeep = Color(0xFF0E7490);
  static const Color blue = Color(0xFF3B82F6);
  static const Color orange = Color(0xFFF97316);
  static const Color violet = Color(0xFF8B5CF6);
  static const Color green = Color(0xFF16A34A);
  static const Color pink = Color(0xFFEC4899);
  static const Color amber = Color(0xFFF59E0B);
  static const Color red = Color(0xFFEF4444);
  static const Color whatsapp = Color(0xFF25D366);

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cyanDeep, cyan, cyanLight],
  );

  static Color shade(Color c, double amt) => Color.lerp(c, Colors.black, amt)!;
  static Color tint(Color c, double amt) => Color.lerp(c, Colors.white, amt)!;

  static const List<Color> rotation = [
    cyan, violet, pink, green, amber, blue, orange
  ];
}

// ─── Semantic helpers ────────────────────────────────────────────────────────
Color erpStatusColor(String status) {
  final s = status.toLowerCase();
  if (s.contains('complet') || s.contains('done') || s.contains('convert')) {
    return ErpColors.green;
  }
  if (s.contains('cancel') ||
      s.contains('overdue') ||
      s.contains('missed') ||
      s.contains('lost')) {
    return ErpColors.red;
  }
  if (s.contains('resched')) return ErpColors.violet;
  if (s.contains('schedul') || s.contains('contact')) return ErpColors.blue;
  if (s.contains('pending') || s.contains('follow')) return ErpColors.orange;
  if (s.contains('new')) return ErpColors.cyan;
  return ErpColors.amber;
}

bool erpIsDone(String status) {
  final s = status.toLowerCase();
  return s.contains('complet') || s.contains('done');
}

/// Icon + colour for a meeting / follow-up / reminder type.
(IconData, Color) erpTypeStyle(String type) {
  final t = type.toLowerCase();
  if (t.contains('whatsapp')) return (ErpIcons.whatsapp, ErpColors.whatsapp);
  if (t.contains('video')) return (Icons.videocam_rounded, ErpColors.blue);
  if (t.contains('mail')) return (Icons.email_rounded, ErpColors.violet);
  if (t.contains('sms') || t.contains('message')) {
    return (Icons.sms_rounded, ErpColors.pink);
  }
  if (t.contains('person') || t.contains('meeting')) {
    return (Icons.handshake_rounded, ErpColors.amber);
  }
  if (t.contains('follow')) {
    return (Icons.event_repeat_rounded, ErpColors.orange);
  }
  if (t.contains('call') || t.contains('phone')) {
    return (Icons.call_rounded, ErpColors.cyan);
  }
  return (Icons.event_note_rounded, ErpColors.cyan);
}

String erpTitleCase(String s) => s
    .trim()
    .replaceAll('_', ' ')
    .split(' ')
    .where((w) => w.isNotEmpty)
    .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
    .join(' ');

DateTime? erpParseDateTime(String? date, String? time) {
  final d = (date ?? '').trim();
  final t = (time ?? '').trim();
  if (d.isEmpty) return null;
  return DateTime.tryParse(t.isNotEmpty ? '$d $t' : d) ?? DateTime.tryParse(d);
}

/// Returns ('12 Oct 2026', '03:30 PM') — either part may be empty.
(String, String) erpSplitDateTime(String? date, String? time) {
  final d = (date ?? '').trim();
  final t = (time ?? '').trim();
  final dt = DateTime.tryParse(d);
  final dateOut = dt != null ? DateFormat('dd MMM yyyy').format(dt) : d;
  var timeOut = '';
  if (t.isNotEmpty) {
    final tdt = DateTime.tryParse('2000-01-01 $t');
    timeOut = tdt != null ? DateFormat('hh:mm a').format(tdt) : t;
  }
  return (dateOut, timeOut);
}

/// Themed builder for showDatePicker / showTimePicker.
Widget erpPickerTheme(BuildContext context, Widget? child,
    {Color color = ErpColors.cyan}) {
  return Theme(
    data: Theme.of(context).copyWith(
      colorScheme: ColorScheme.light(
        primary: color,
        onPrimary: Colors.white,
        surface: Colors.white,
        onSurface: ErpColors.ink,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: Colors.white,
        headerBackgroundColor: color,
        headerForegroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    ),
    child: child!,
  );
}

void erpToast(BuildContext context, String msg,
    {Color color = ErpColors.cyanDeep, IconData? icon}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(children: [
      Icon(icon ?? Icons.check_circle_rounded, color: Colors.white, size: 18),
      const SizedBox(width: 8),
      Expanded(child: Text(msg)),
    ]),
    backgroundColor: color,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  ));
}

// ═════════════════════════════════════════════════════════════════════════════
// Basic building blocks
// ═════════════════════════════════════════════════════════════════════════════
class ErpPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  const ErpPressable(
      {super.key, required this.child, this.onTap, this.scale = 0.96});

  @override
  State<ErpPressable> createState() => _ErpPressableState();
}

class _ErpPressableState extends State<ErpPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 90));
    _scale = Tween<double>(begin: 1.0, end: widget.scale).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) return widget.child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap!();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

class ErpFadeIn extends StatefulWidget {
  final Widget child;
  final int index;
  const ErpFadeIn({super.key, required this.child, this.index = 0});

  @override
  State<ErpFadeIn> createState() => _ErpFadeInState();
}

class _ErpFadeInState extends State<ErpFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, .07), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 40 + widget.index * 55), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child));
}

class ErpGradientTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final bool circle;
  const ErpGradientTile({
    super.key,
    required this.icon,
    required this.color,
    this.size = 44,
    this.circle = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [ErpColors.tint(color, 0.22), color],
          ),
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circle ? null : BorderRadius.circular(size * 0.32),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.32),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
            child: erpIcon(icon, color: Colors.white, size: size * 0.5)),
      );
}

class ErpGlassCircle extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  const ErpGlassCircle({super.key, required this.icon, this.iconSize = 20});

  @override
  Widget build(BuildContext context) => Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        ),
        child: Icon(icon, color: Colors.white, size: iconSize),
      );
}

class ErpStatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const ErpStatusChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: ErpColors.shade(color, 0.1))),
        ]),
      );
}

class ErpMetaChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const ErpMetaChip(
      {super.key, required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: color.withValues(alpha: 0.20)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          erpIcon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.5),
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: ErpColors.shade(color, 0.15))),
          ),
        ]),
      );
}

// ═════════════════════════════════════════════════════════════════════════════
// Form pieces
// ═════════════════════════════════════════════════════════════════════════════
class ErpFieldLabel extends StatelessWidget {
  final String text;
  final bool isRequired;
  final bool isOptional;
  const ErpFieldLabel(this.text,
      {super.key, this.isRequired = false, this.isOptional = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 7),
        child: Row(children: [
          Text(text,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: ErpColors.ink)),
          if (isRequired) ...[
            const SizedBox(width: 4),
            const Icon(Icons.circle, size: 6, color: ErpColors.red),
          ],
          if (isOptional) ...[
            const SizedBox(width: 6),
            const Text('optional',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: ErpColors.slate)),
          ],
        ]),
      );
}

class ErpErrorText extends StatelessWidget {
  final String text;
  const ErpErrorText(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 6, left: 4),
        child: Row(children: [
          const Icon(Icons.error_outline_rounded,
              size: 14, color: ErpColors.red),
          const SizedBox(width: 4),
          Flexible(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ErpColors.red,
                    height: 1.4)),
          ),
        ]),
      );
}

OutlineInputBorder _erpBorder(Color c, {double width = 1}) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c, width: width),
    );

/// Text-field decoration. Validator messages are hidden (we render
/// [ErpErrorText] ourselves) but the red border still shows.
InputDecoration erpInputDecoration({
  required String hint,
  required IconData icon,
  bool hasError = false,
  Color color = ErpColors.cyan,
}) {
  final accent = hasError ? ErpColors.red : color;
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      fontSize: 13.5,
      color: hasError
          ? ErpColors.red.withValues(alpha: 0.7)
          : ErpColors.slate.withValues(alpha: 0.7),
    ),
    prefixIcon: Padding(
      padding: const EdgeInsets.only(left: 10, right: 8),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon,
            size: 16,
            color: hasError ? ErpColors.red : ErpColors.shade(color, 0.15)),
      ),
    ),
    prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 30),
    filled: true,
    fillColor:
        hasError ? ErpColors.red.withValues(alpha: 0.04) : ErpColors.pageBg,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    border: _erpBorder(ErpColors.line),
    enabledBorder: _erpBorder(
        hasError ? ErpColors.red.withValues(alpha: 0.6) : ErpColors.line),
    focusedBorder:
        _erpBorder(hasError ? ErpColors.red : color, width: 1.6),
    errorBorder: _erpBorder(ErpColors.red.withValues(alpha: 0.6)),
    focusedErrorBorder: _erpBorder(ErpColors.red, width: 1.6),
    errorStyle: const TextStyle(fontSize: 0, height: 0),
  );
}

/// Tappable tile used for date / time / lead pickers.
class ErpPickerTile extends StatelessWidget {
  final IconData icon;
  final String placeholder;
  final String? value;
  final bool hasError;
  final Color color;
  final VoidCallback onTap;
  final Widget? leading;
  final String? subValue;

  const ErpPickerTile({
    super.key,
    required this.icon,
    required this.placeholder,
    required this.value,
    required this.onTap,
    this.hasError = false,
    this.color = ErpColors.cyan,
    this.leading,
    this.subValue,
  });

  @override
  Widget build(BuildContext context) {
    final isSet = value != null && value!.isNotEmpty;
    final accent = hasError ? ErpColors.red : color;

    return ErpPressable(
      onTap: onTap,
      scale: 0.98,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: hasError
              ? ErpColors.red.withValues(alpha: 0.04)
              : (isSet ? color.withValues(alpha: 0.06) : ErpColors.pageBg),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasError
                ? ErpColors.red.withValues(alpha: 0.6)
                : (isSet ? color.withValues(alpha: 0.7) : ErpColors.line),
            width: hasError || isSet ? 1.4 : 1,
          ),
        ),
        child: Row(children: [
          leading ??
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: erpIcon(icon,
                      size: 16,
                      color: hasError
                          ? ErpColors.red
                          : ErpColors.shade(color, 0.15)),
                ),
              ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isSet ? value! : placeholder,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: isSet ? FontWeight.w700 : FontWeight.w500,
                    color: hasError
                        ? ErpColors.red
                        : (isSet
                            ? ErpColors.ink
                            : ErpColors.slate.withValues(alpha: 0.75)),
                  ),
                ),
                if (isSet && (subValue ?? '').isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(subValue!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: ErpColors.slate)),
                ],
              ],
            ),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: isSet
                  ? LinearGradient(colors: [ErpColors.tint(color, 0.2), color])
                  : null,
              color: isSet ? null : color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
                isSet ? Icons.check_rounded : Icons.chevron_right_rounded,
                size: isSet ? 15 : 19,
                color: isSet ? Colors.white : ErpColors.shade(color, 0.15)),
          ),
        ]),
      ),
    );
  }
}

class ErpChoice {
  final String label;
  final IconData icon;
  final Color color;
  const ErpChoice(this.label, this.icon, this.color);
}

/// Grid of selectable chips (replaces dropdowns for short option lists).
class ErpChoiceGrid extends StatelessWidget {
  final List<ErpChoice> options;
  final String selected;
  final ValueChanged<String> onSelect;
  final int columns;

  const ErpChoiceGrid({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
    this.columns = 3,
  });

  @override
  Widget build(BuildContext context) {
    const gap = 8.0;
    return LayoutBuilder(builder: (context, c) {
      final w = (c.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: options.map((o) {
          final isSel = o.label == selected;
          return SizedBox(
            width: w,
            child: ErpPressable(
              onTap: () => onSelect(o.label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  gradient: isSel
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [ErpColors.tint(o.color, 0.2), o.color],
                        )
                      : null,
                  color: isSel ? null : ErpColors.pageBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: isSel ? Colors.transparent : ErpColors.line),
                  boxShadow: isSel
                      ? [
                          BoxShadow(
                            color: o.color.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : const [],
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  erpIcon(o.icon,
                      size: 20, color: isSel ? Colors.white : o.color),
                  const SizedBox(height: 4),
                  Text(o.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isSel
                              ? Colors.white
                              : ErpColors.shade(o.color, 0.15))),
                ]),
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

class ErpPrimaryButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool loading;
  final VoidCallback? onTap;
  final Color? color;

  const ErpPrimaryButton({
    super.key,
    required this.text,
    this.icon,
    this.loading = false,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final glow = color ?? ErpColors.cyan;
    return ErpPressable(
      onTap: loading ? null : onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: loading ? 0.75 : 1,
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: color == null
                ? ErpColors.headerGradient
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [ErpColors.tint(color!, 0.18), color!],
                  ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: glow.withValues(alpha: 0.38),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.2))
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    if (icon != null) ...[
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(text,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3)),
                  ]),
          ),
        ),
      ),
    );
  }
}

class ErpSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  const ErpSecondaryButton({super.key, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) => ErpPressable(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: ErpColors.line, width: 1.5),
          ),
          child: Center(
            child: Text(text,
                style: const TextStyle(
                    color: ErpColors.slate,
                    fontSize: 15,
                    fontWeight: FontWeight.w800)),
          ),
        ),
      );
}

// ═════════════════════════════════════════════════════════════════════════════
// Bottom-sheet shell
// ═════════════════════════════════════════════════════════════════════════════
class ErpSheet extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  const ErpSheet({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: mq.size.height * 0.92),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: ErpColors.line,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withValues(alpha: 0.12),
                          color.withValues(alpha: 0.03),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: color.withValues(alpha: 0.18)),
                    ),
                    child: Row(children: [
                      ErpGradientTile(icon: icon, color: color, size: 46),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: ErpColors.ink)),
                            if ((subtitle ?? '').isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 13, color: ErpColors.slate)),
                            ],
                          ],
                        ),
                      ),
                      ErpPressable(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: ErpColors.line),
                          ),
                          child: const Icon(Icons.close_rounded,
                              size: 18, color: ErpColors.slate),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 18),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Empty / error state
// ═════════════════════════════════════════════════════════════════════════════
class ErpEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String? actionLabel;
  final IconData actionIcon;
  final VoidCallback? onAction;

  const ErpEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color = ErpColors.cyan,
    this.actionLabel,
    this.actionIcon = Icons.refresh_rounded,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.10),
                  color.withValues(alpha: 0.22),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Center(
                child: erpIcon(icon,
                    color: ErpColors.shade(color, 0.15), size: 38)),
          ),
          const SizedBox(height: 16),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: ErpColors.ink)),
          const SizedBox(height: 6),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13.5, color: ErpColors.slate, height: 1.4)),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 18),
            ErpPressable(
              onTap: onAction,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [ErpColors.shade(color, 0.15), color]),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(actionIcon, size: 17, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(actionLabel!,
                      style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ]),
              ),
            ),
          ],
        ]),
      );
}

// ═════════════════════════════════════════════════════════════════════════════
// Activity card (meetings / reminders / follow-ups)
// ═════════════════════════════════════════════════════════════════════════════
class ErpActivityCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String date;
  final String time;
  final String? notes;
  final String status;
  final String typeLabel;
  final bool done;
  final bool overdue;
  final VoidCallback? onTap;

  const ErpActivityCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.date,
    required this.time,
    required this.status,
    required this.typeLabel,
    this.notes,
    this.done = false,
    this.overdue = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sLabel = overdue && !done ? 'Overdue' : status;
    final sColor = overdue && !done ? ErpColors.red : erpStatusColor(status);

    return ErpPressable(
      onTap: onTap,
      scale: 0.98,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ErpColors.line),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: IntrinsicHeight(
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [ErpColors.tint(color, 0.25), color],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ErpGradientTile(
                                    icon: icon, color: color, size: 44),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: done
                                                  ? ErpColors.slate
                                                  : ErpColors.ink,
                                              decoration: done
                                                  ? TextDecoration.lineThrough
                                                  : null)),
                                      const SizedBox(height: 3),
                                      Text(typeLabel,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: ErpColors.shade(
                                                  color, 0.15))),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (sLabel.isNotEmpty)
                                  ErpStatusChip(label: sLabel, color: sColor),
                              ]),
                          const SizedBox(height: 12),
                          Wrap(spacing: 6, runSpacing: 6, children: [
                            if (date.isNotEmpty)
                              ErpMetaChip(
                                  icon: Icons.calendar_today_rounded,
                                  text: date,
                                  color: ErpColors.cyan),
                            if (time.isNotEmpty)
                              ErpMetaChip(
                                  icon: Icons.schedule_rounded,
                                  text: time,
                                  color: ErpColors.violet),
                          ]),
                          if ((notes ?? '').isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: ErpColors.pageBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: ErpColors.line),
                              ),
                              child: Text(notes!,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: ErpColors.ink,
                                      height: 1.45)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// List screen shell (gradient header + stats + refresh + states)
// ═════════════════════════════════════════════════════════════════════════════
class ErpStat {
  final String label;
  final int value;
  final IconData icon;
  const ErpStat(this.label, this.value, this.icon);
}

class ErpListShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData watermark;
  final Color color;
  final bool loading;
  final String? error;
  final Future<void> Function() onRefresh;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final List<ErpStat> stats;
  final Widget? floatingAction;

  const ErpListShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.watermark,
    required this.loading,
    required this.onRefresh,
    required this.itemCount,
    required this.itemBuilder,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    this.color = ErpColors.cyan,
    this.error,
    this.stats = const [],
    this.floatingAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ErpColors.pageBg,
      floatingActionButton: floatingAction,
      body: Column(children: [
        _header(context),
        Expanded(
          child: RefreshIndicator(
            color: color,
            onRefresh: onRefresh,
            child: _body(context),
          ),
        ),
      ]),
    );
  }

  Widget _body(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    const physics =
        AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics());

    if (loading) {
      return ListView(physics: physics, children: [
        const SizedBox(height: 140),
        Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(color: color, strokeWidth: 2.5),
          ),
        ),
      ]);
    }
    if (error != null) {
      return ListView(physics: physics, children: [
        const SizedBox(height: 60),
        ErpEmptyState(
          icon: Icons.cloud_off_rounded,
          title: 'Couldn\'t load data',
          subtitle: error!,
          color: ErpColors.red,
          actionLabel: 'Retry',
          onAction: onRefresh,
        ),
      ]);
    }
    if (itemCount == 0) {
      return ListView(physics: physics, children: [
        const SizedBox(height: 60),
        ErpEmptyState(
          icon: emptyIcon,
          title: emptyTitle,
          subtitle: emptySubtitle,
          color: color,
          actionLabel: 'Refresh',
          onAction: onRefresh,
        ),
      ]);
    }
    return ListView.builder(
      physics: physics,
      padding: EdgeInsets.fromLTRB(
          sw * .04, 18, sw * .04, MediaQuery.of(context).padding.bottom + 90),
      itemCount: itemCount,
      itemBuilder: (ctx, i) =>
          ErpFadeIn(index: i < 10 ? i : 10, child: itemBuilder(ctx, i)),
    );
  }

  Widget _header(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: ErpColors.headerGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: ErpColors.cyan.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(children: [
        Positioned(
          right: -34,
          top: -44,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: 64,
          top: mq.padding.top + 2,
          child: Transform.rotate(
            angle: -0.25,
            child: Icon(watermark,
                size: 90, color: Colors.white.withValues(alpha: 0.12)),
          ),
        ),
        Positioned(
          left: -26,
          bottom: -34,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              top: mq.padding.top + 10,
              bottom: 20,
              left: sw * .045,
              right: sw * .045),
          child: Column(children: [
            Row(children: [
              ErpPressable(
                onTap: () => Navigator.pop(context),
                child: const ErpGlassCircle(
                    icon: Icons.arrow_back_ios_new_rounded, iconSize: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14)),
                    ]),
              ),
              const SizedBox(width: 8),
              loading
                  ? const SizedBox(
                      width: 42,
                      height: 42,
                      child: Padding(
                        padding: EdgeInsets.all(11),
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      ),
                    )
                  : ErpPressable(
                      onTap: onRefresh,
                      child:
                          const ErpGlassCircle(icon: Icons.refresh_rounded),
                    ),
            ]),
            if (stats.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(children: [
                for (var i = 0; i < stats.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: _statTile(stats[i])),
                ],
              ]),
            ],
          ]),
        ),
      ]),
    );
  }

  Widget _statTile(ErpStat s) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
        ),
        child: Row(children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: Center(
                child: erpIcon(s.icon, color: Colors.white, size: 16)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<double>(
                  key: ValueKey('${s.label}_${s.value}'),
                  tween: Tween<double>(begin: 0, end: s.value.toDouble()),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => Text('${v.round()}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          height: 1.1)),
                ),
                Text(s.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ]),
      );
}