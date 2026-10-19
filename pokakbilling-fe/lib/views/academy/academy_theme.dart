import 'package:flutter/material.dart';
import 'package:pokakbilling/views/academy/academy_palette.dart';

// ═════════════════════════════════════════════════════════════════════════════
// Shared UI building blocks for the Academy module (light violet + cyan theme)
// ═════════════════════════════════════════════════════════════════════════════

// ── Formatting helpers ───────────────────────────────────────────────────────
const _kMonths = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

String acadDate(DateTime? d) => d == null
    ? '—'
    : '${d.day.toString().padLeft(2, '0')} ${_kMonths[d.month - 1]} ${d.year}';

/// Indian-style currency: ₹1,23,456
String acadInr(num value) {
  final neg = value < 0;
  final whole = value.abs().round().toString();
  String out;
  if (whole.length <= 3) {
    out = whole;
  } else {
    final last3 = whole.substring(whole.length - 3);
    var rest = whole.substring(0, whole.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    out = '${parts.join(',')},$last3';
  }
  return '${neg ? '-' : ''}₹$out';
}

/// Short form for tight tiles: ₹1.2L, ₹45K
String acadInrShort(num value) {
  final v = value.abs();
  if (v >= 10000000) return '₹${(value / 10000000).toStringAsFixed(1)}Cr';
  if (v >= 100000) return '₹${(value / 100000).toStringAsFixed(1)}L';
  if (v >= 1000) return '₹${(value / 1000).toStringAsFixed(1)}K';
  return acadInr(value);
}

// ── Header (violet → cyan gradient) ──────────────────────────────────────────
class AcadHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> actions;
  const AcadHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AcadPal.heroGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
        boxShadow: [
          BoxShadow(
            color: AcadPal.primary.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(children: [
        Positioned(
          right: -30,
          top: -40,
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: AcadPal.white.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: 60,
          bottom: -34,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AcadPal.aqua.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              top: mq.padding.top + 10,
              bottom: 18,
              left: sw * .045,
              right: sw * .045),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AcadPal.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AcadPal.white.withValues(alpha: 0.45)),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AcadPal.white, size: 19),
              ),
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
                            color: AcadPal.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: AcadPal.white.withValues(alpha: 0.88),
                            fontSize: 14)),
                  ]),
            ),
            for (final a in actions) ...[const SizedBox(width: 8), a],
          ]),
        ),
      ]),
    );
  }
}

/// Glass-style icon button (sits on the gradient header).
class AcadIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool loading;
  const AcadIconButton(
      {super.key,
      required this.icon,
      required this.onTap,
      this.loading = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AcadPal.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AcadPal.white.withValues(alpha: 0.45)),
        ),
        child: loading
            ? const Padding(
                padding: EdgeInsets.all(11),
                child: CircularProgressIndicator(
                    color: AcadPal.white, strokeWidth: 2))
            : Icon(icon, color: AcadPal.white, size: 22),
      ),
    );
  }
}

// ── Section label ────────────────────────────────────────────────────────────
class AcadLabel extends StatelessWidget {
  final String text;
  const AcadLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          width: 4,
          height: 12,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AcadPal.primary, AcadPal.cyan],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 7),
        Text(text,
            style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: AcadPal.text,
                letterSpacing: 1.1)),
      ]);
}

// ── Stats row (soft gradient tiles, everything centered) ─────────────────────
class AcadStat {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const AcadStat(this.label, this.value, this.color, this.icon);
}

class AcadStatsRow extends StatelessWidget {
  final List<AcadStat> items;
  const AcadStatsRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(items.length, (i) {
        final it = items[i];
        return Expanded(
          child: AcadFadeIn(
            index: i,
            child: Container(
              height: 112,
              margin: EdgeInsets.only(right: i < items.length - 1 ? 8 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [it.color.withValues(alpha: 0.16), AcadPal.white],
                ),
                border: Border.all(color: it.color.withValues(alpha: 0.28)),
                boxShadow: [
                  BoxShadow(
                    color: it.color.withValues(alpha: 0.16),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(children: [
                  Positioned(
                    right: -16,
                    top: -16,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: it.color.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Everything below is centered both ways, same on every tile.
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AcadGradientIcon(
                              icon: it.icon,
                              color: it.color,
                              size: 32,
                              radius: 11),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: Text(it.value,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: AcadPal.dark,
                                      height: 1.1)),
                            ),
                          ),
                          const SizedBox(height: 3),
                          SizedBox(
                            width: double.infinity,
                            child: Text(it.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AcadPal.text)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Search bar with focus glow ───────────────────────────────────────────────
class AcadSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  const AcadSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hint = 'Search name, email, phone…',
  });

  @override
  State<AcadSearchBar> createState() => _AcadSearchBarState();
}

class _AcadSearchBarState extends State<AcadSearchBar> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
    widget.controller.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      height: 54,
      padding: const EdgeInsets.only(left: 7, right: 8),
      decoration: BoxDecoration(
        color: AcadPal.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: focused
              ? AcadPal.cyan
              : AcadPal.primary.withValues(alpha: 0.20),
          width: focused ? 1.6 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (focused ? AcadPal.cyan : AcadPal.primary)
                .withValues(alpha: focused ? 0.28 : 0.08),
            blurRadius: focused ? 18 : 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(children: [
        const AcadGradientIcon(
            icon: Icons.search_rounded, color: AcadPal.primary, size: 40),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: widget.controller,
            focusNode: _focus,
            onChanged: widget.onChanged,
            style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w500,
                color: AcadPal.dark),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(color: AcadPal.text, fontSize: 15),
              border: InputBorder.none,
              isCollapsed: true,
            ),
          ),
        ),
        if (widget.controller.text.isNotEmpty)
          GestureDetector(
            onTap: () {
              widget.controller.clear();
              widget.onChanged('');
            },
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AcadPal.cyan.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  size: 16, color: AcadPal.cyanDeep),
            ),
          ),
      ]),
    );
  }
}

// ── Filter pill ──────────────────────────────────────────────────────────────
class AcadFilterPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback onClear;
  const AcadFilterPill({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          gradient: active ? AcadPal.brandGradient : null,
          color: active ? null : AcadPal.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
              color: active ? Colors.transparent : AcadPal.border),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AcadPal.primary.withValues(alpha: 0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(children: [
          Icon(icon,
              size: 15, color: active ? AcadPal.white : AcadPal.cyanDeep),
          const SizedBox(width: 5),
          Expanded(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: active ? AcadPal.white : AcadPal.dark)),
          ),
          active
              ? GestureDetector(
                  onTap: onClear,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AcadPal.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 12, color: AcadPal.white),
                  ))
              : const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 18, color: AcadPal.text),
        ]),
      ),
    );
  }
}

// ── List header: accent bar + title + count badge ────────────────────────────
class AcadListHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  const AcadListHeader(
      {super.key,
      required this.title,
      required this.count,
      this.color = AcadPal.primary});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 4,
        height: 18,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(4)),
      ),
      const SizedBox(width: 8),
      Text(title,
          style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AcadPal.dark)),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text('$count',
            style: TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.w800, color: color)),
      ),
    ]);
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────
class AcadEmpty extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const AcadEmpty({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle = 'Try adjusting your filters',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Center(
        child: Column(children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AcadPal.lilac.withValues(alpha: 0.25),
                  AcadPal.cyan.withValues(alpha: 0.22),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: AcadPal.border),
            ),
            child: Icon(icon,
                size: 38, color: AcadPal.primary.withValues(alpha: 0.75)),
          ),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AcadPal.dark)),
          const SizedBox(height: 6),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15, color: AcadPal.text.withValues(alpha: 0.8))),
        ]),
      ),
    );
  }
}

// ── Small pieces ─────────────────────────────────────────────────────────────
class AcadGradientIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double radius;
  const AcadGradientIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(color, AcadPal.white, 0.22)!, color],
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.32),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, color: AcadPal.white, size: size * 0.52),
      ),
    );
  }
}

class AcadStatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const AcadStatusPill({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 5)
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w800, color: color)),
      ]),
    );
  }
}

class AcadMiniTag extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  const AcadMiniTag({
    super.key,
    required this.text,
    required this.icon,
    this.color = AcadPal.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ),
      ]),
    );
  }
}

class AcadArrowButton extends StatelessWidget {
  final Color color;
  final double size;
  const AcadArrowButton(
      {super.key, this.color = AcadPal.primary, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(color, AcadPal.white, 0.22)!, color],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.30),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(Icons.arrow_forward_rounded,
          size: size * 0.54, color: AcadPal.white),
    );
  }
}

// ── Motion helpers ───────────────────────────────────────────────────────────
class AcadFadeIn extends StatelessWidget {
  final Widget child;
  final int index;
  const AcadFadeIn({super.key, required this.child, this.index = 0});

  @override
  Widget build(BuildContext context) {
    final delay = index.clamp(0, 8) * 60;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, t, c) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * 18), child: c),
      ),
      child: child,
    );
  }
}

class AcadPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const AcadPressable({super.key, required this.child, required this.onTap});

  @override
  State<AcadPressable> createState() => _AcadPressableState();
}

class _AcadPressableState extends State<AcadPressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.975 : 1,
        duration: const Duration(milliseconds: 120),
        child: widget.child,
      ),
    );
  }
}