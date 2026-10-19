// ═════════════════════════════════════════════════════════════════════════════
// LEAD DATE FILTER SHEET — quick presets + custom range. NO future dates.
// Place at: lib/widgets/lead_date_filter_sheet.dart
//
// Usage:
//   final res = await showLeadDateFilterSheet(context, current: range);
//   if (res == null) return;          // sheet dismissed → no change
//   setRange(res.range);              // res.range == null → "All Dates"
// ═════════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const Color _kInk = Color(0xFF0F172A);
const Color _kSlate = Color(0xFF64748B);
const Color _kLine = Color(0xFFD9ECF2);
const Color _kPageBg = Color(0xFFF0FAFD);
const Color _kCyan = Color(0xFF06B6D4);

Color _shade(Color c, double a) => Color.lerp(c, Colors.black, a)!;
Color _tint(Color c, double a) => Color.lerp(c, Colors.white, a)!;

/// What the sheet returns.
///   * sheet returns `null`  → user dismissed it, keep current filter
///   * `range == null`       → "All Dates" (clear the date filter)
class LeadDateFilterResult {
  final DateTimeRange? range;
  const LeadDateFilterResult(this.range);
}

enum LeadDatePreset {
  all,
  today,
  yesterday,
  last7Days,
  last30Days,
  thisMonth,
  lastMonth,
  thisYear,
  custom,
}

// ── Date helpers ─────────────────────────────────────────────────────────────
DateTime leadDateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime leadToday() => leadDateOnly(DateTime.now());

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

extension LeadDatePresetX on LeadDatePreset {
  String get label => switch (this) {
        LeadDatePreset.all => 'All Dates',
        LeadDatePreset.today => 'Today',
        LeadDatePreset.yesterday => 'Yesterday',
        LeadDatePreset.last7Days => 'Last 7 Days',
        LeadDatePreset.last30Days => 'Last 30 Days',
        LeadDatePreset.thisMonth => 'This Month',
        LeadDatePreset.lastMonth => 'Last Month',
        LeadDatePreset.thisYear => 'This Year',
        LeadDatePreset.custom => 'Custom Range',
      };

  IconData get icon => switch (this) {
        LeadDatePreset.all => Icons.all_inclusive_rounded,
        LeadDatePreset.today => Icons.today_rounded,
        LeadDatePreset.yesterday => Icons.history_rounded,
        LeadDatePreset.last7Days => Icons.date_range_rounded,
        LeadDatePreset.last30Days => Icons.calendar_view_month_rounded,
        LeadDatePreset.thisMonth => Icons.calendar_month_rounded,
        LeadDatePreset.lastMonth => Icons.event_note_rounded,
        LeadDatePreset.thisYear => Icons.event_available_rounded,
        LeadDatePreset.custom => Icons.edit_calendar_rounded,
      };

  /// Every preset ends on TODAY at the latest — never in the future.
  DateTimeRange? get range {
    final t = leadToday();
    switch (this) {
      case LeadDatePreset.all:
      case LeadDatePreset.custom:
        return null;
      case LeadDatePreset.today:
        return DateTimeRange(start: t, end: t);
      case LeadDatePreset.yesterday:
        final y = DateTime(t.year, t.month, t.day - 1);
        return DateTimeRange(start: y, end: y);
      case LeadDatePreset.last7Days:
        return DateTimeRange(
            start: DateTime(t.year, t.month, t.day - 6), end: t);
      case LeadDatePreset.last30Days:
        return DateTimeRange(
            start: DateTime(t.year, t.month, t.day - 29), end: t);
      case LeadDatePreset.thisMonth:
        // 1st of this month → today (NOT end of month)
        return DateTimeRange(start: DateTime(t.year, t.month, 1), end: t);
      case LeadDatePreset.lastMonth:
        return DateTimeRange(
          start: DateTime(t.year, t.month - 1, 1),
          end: DateTime(t.year, t.month, 0), // last day of previous month
        );
      case LeadDatePreset.thisYear:
        return DateTimeRange(start: DateTime(t.year, 1, 1), end: t);
    }
  }
}

/// Which preset matches [r] (custom if none).
LeadDatePreset leadPresetFor(DateTimeRange? r) {
  if (r == null) return LeadDatePreset.all;
  for (final p in LeadDatePreset.values) {
    final pr = p.range;
    if (pr != null && _sameDay(pr.start, r.start) && _sameDay(pr.end, r.end)) {
      return p;
    }
  }
  return LeadDatePreset.custom;
}

/// Pulls a range back so it never goes past today (and not before [firstDate]).
DateTimeRange? clampLeadDateRange(DateTimeRange? r, {DateTime? firstDate}) {
  if (r == null) return null;
  final today = leadToday();
  var start = leadDateOnly(r.start);
  var end = leadDateOnly(r.end);
  if (end.isAfter(today)) end = today;
  if (start.isAfter(today)) start = today;
  if (firstDate != null) {
    final f = leadDateOnly(firstDate);
    if (start.isBefore(f)) start = f;
    if (end.isBefore(f)) end = f;
  }
  if (start.isAfter(end)) start = end;
  return DateTimeRange(start: start, end: end);
}

/// "12 Oct – 19 Oct", "19 Oct 2026", "28 Dec 25 – 05 Jan 26"
String leadRangeText(DateTimeRange r) {
  final s = r.start, e = r.end;
  if (_sameDay(s, e)) return DateFormat('dd MMM yyyy').format(s);
  if (s.year == e.year) {
    if (s.year == DateTime.now().year) {
      return '${DateFormat('dd MMM').format(s)} – ${DateFormat('dd MMM').format(e)}';
    }
    return '${DateFormat('dd MMM').format(s)} – ${DateFormat('dd MMM yyyy').format(e)}';
  }
  return '${DateFormat('dd MMM yy').format(s)} – ${DateFormat('dd MMM yy').format(e)}';
}

/// Short label for filter chips: preset name if it matches, else the dates.
String leadDateFilterLabel(DateTimeRange? r, {String empty = 'All Dates'}) {
  if (r == null) return empty;
  final p = leadPresetFor(r);
  return p == LeadDatePreset.custom ? leadRangeText(r) : p.label;
}

// ═════════════════════════════════════════════════════════════════════════════
// Open the sheet
// ═════════════════════════════════════════════════════════════════════════════
Future<LeadDateFilterResult?> showLeadDateFilterSheet(
  BuildContext context, {
  DateTimeRange? current,
  DateTime? firstDate,
  bool showAllOption = true,
  Color accent = _kCyan,
}) {
  return showModalBottomSheet<LeadDateFilterResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _LeadDateFilterSheet(
      current: current,
      firstDate: leadDateOnly(firstDate ?? DateTime(2020)),
      showAllOption: showAllOption,
      accent: accent,
    ),
  );
}

class _LeadDateFilterSheet extends StatelessWidget {
  final DateTimeRange? current;
  final DateTime firstDate;
  final bool showAllOption;
  final Color accent;

  const _LeadDateFilterSheet({
    required this.current,
    required this.firstDate,
    required this.showAllOption,
    required this.accent,
  });

  Future<void> _pickCustom(BuildContext context) async {
    final today = leadToday();
    final init = clampLeadDateRange(
      current ??
          DateTimeRange(start: DateTime(today.year, today.month, 1), end: today),
      firstDate: firstDate,
    )!;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: today, // ← no future dates can be picked
      currentDate: today,
      initialDateRange: init,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: 'Select date range',
      saveText: 'Apply',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: accent,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: _kInk,
            secondaryContainer: _tint(accent, 0.8),
          ),
        ),
        child: child!,
      ),
    );

    if (picked == null || !context.mounted) return;
    Navigator.pop(
      context,
      LeadDateFilterResult(DateTimeRange(
        start: leadDateOnly(picked.start),
        end: leadDateOnly(picked.end),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = leadPresetFor(current);
    final presets = LeadDatePreset.values
        .where((p) =>
            p != LeadDatePreset.custom &&
            (showAllOption || p != LeadDatePreset.all))
        .toList();
    final mq = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(maxHeight: mq.size.height * 0.85),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _kLine,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 12, 12),
              child: Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_tint(accent, 0.22), accent],
                    ),
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.32),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.date_range_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Filter by Date',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: _kInk)),
                      const SizedBox(height: 2),
                      Text(
                          'Up to today · ${DateFormat('dd MMM yyyy').format(leadToday())}',
                          style: const TextStyle(
                              fontSize: 12.5, color: _kSlate)),
                    ],
                  ),
                ),
                Material(
                  color: _kPageBg,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.pop(context),
                    child: const SizedBox(
                      width: 34,
                      height: 34,
                      child:
                          Icon(Icons.close_rounded, color: _kSlate, size: 18),
                    ),
                  ),
                ),
              ]),
            ),
            const Divider(height: 1, color: _kLine),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel('QUICK RANGES'),
                    const SizedBox(height: 10),
                    LayoutBuilder(builder: (ctx, c) {
                      final w = (c.maxWidth - 10) / 2;
                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final p in presets)
                            SizedBox(
                              width: w,
                              child: _OptionTile(
                                icon: p.icon,
                                label: p.label,
                                sub: p == LeadDatePreset.all
                                    ? 'No date filter'
                                    : leadRangeText(p.range!),
                                selected: selected == p,
                                accent: accent,
                                onTap: () => Navigator.pop(
                                    context, LeadDateFilterResult(p.range)),
                              ),
                            ),
                        ],
                      );
                    }),
                    const SizedBox(height: 18),
                    const _SectionLabel('CUSTOM RANGE'),
                    const SizedBox(height: 10),
                    _OptionTile(
                      icon: LeadDatePreset.custom.icon,
                      label: LeadDatePreset.custom.label,
                      sub: selected == LeadDatePreset.custom && current != null
                          ? leadRangeText(current!)
                          : 'Pick start & end date (till today)',
                      selected: selected == LeadDatePreset.custom,
                      accent: accent,
                      trailing: Icons.chevron_right_rounded,
                      onTap: () => _pickCustom(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: _kSlate,
          letterSpacing: 1.1));
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final bool selected;
  final Color accent;
  final IconData? trailing;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.sub,
    required this.selected,
    required this.accent,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
            color: selected ? accent.withValues(alpha: 0.10) : _kPageBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? accent.withValues(alpha: 0.6) : _kLine,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: selected
                    ? LinearGradient(colors: [_tint(accent, 0.2), accent])
                    : null,
                color: selected ? null : accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  size: 17,
                  color: selected ? Colors.white : _shade(accent, 0.1)),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: selected ? _shade(accent, 0.15) : _kInk)),
                  const SizedBox(height: 1),
                  Text(sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11, color: _kSlate, height: 1.2)),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: accent, size: 18)
            else if (trailing != null)
              Icon(trailing, color: _kSlate, size: 20),
          ]),
        ),
      ),
    );
  }
}