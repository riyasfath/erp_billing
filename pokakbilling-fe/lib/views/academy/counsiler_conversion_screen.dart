import 'package:flutter/material.dart';
import 'package:pokakbilling/views/academy/hr_submission_screen.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/models/academy_models/academy_hr_model.dart';
import 'package:pokakbilling/models/academy_models/academy_model.dart';
import 'package:pokakbilling/viewmodels/academy/academy_hr_viewmodel.dart';
import 'package:pokakbilling/views/academy/academy_extras.dart';
import 'package:pokakbilling/views/academy/academy_hr_widgets.dart';
import 'package:pokakbilling/views/academy/academy_theme.dart';
import 'package:pokakbilling/views/academy/academy_widgets.dart';

// ═════════════════════════════════════════════════════════════════════════════
// Colour scheme (same as Payments / Academy home / Admissions)
//   • Header / loaders / refresh → Cyan
//   • Module accent (this screen) → Pink  (Proceed button, records header)
//   • Stat cards use their own colours from hrSummaryStats
// ═════════════════════════════════════════════════════════════════════════════
const Color _kPageBg = Color(0xFFF0FAFD);
const Color _kInk = Color(0xFF0F172A);
const Color _kSlate = Color(0xFF64748B);
const Color _kLine = Color(0xFFD9ECF2);

const Color _kCyan = Color(0xFF06B6D4);
const Color _kCyanLight = Color(0xFF67E8F9);
const Color _kCyanDeep = Color(0xFF0E7490);
const Color _kPink = Color(0xFFEC4899);
const Color _kViolet = Color(0xFF8B5CF6);

const LinearGradient _kHeaderGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [_kCyanDeep, _kCyan, _kCyanLight],
);

const LinearGradient _kMainGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [_kCyan, _kCyanLight],
);

Color _shade(Color c, double amt) => Color.lerp(c, Colors.black, amt)!;
Color _tint(Color c, double amt) => Color.lerp(c, Colors.white, amt)!;

/// Pick a counsellor + period, review conversions, then send them to HR.
class CounsellorConversionScreen extends StatefulWidget {
  const CounsellorConversionScreen({super.key});

  @override
  State<CounsellorConversionScreen> createState() =>
      _CounsellorConversionScreenState();
}

class _CounsellorConversionScreenState
    extends State<CounsellorConversionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<AcademyHrViewmodel>();
      vm.loadCounsellors();
      if (vm.selected != null) vm.loadConversion();
    });
  }

  Future<void> _pickDate(AcademyHrViewmodel vm, bool isStart) async {
    final d = await showDatePicker(
      context: context,
      initialDate: isStart ? vm.start : vm.end,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _kCyan,
            onPrimary: Colors.white,
            onSurface: _kInk,
          ),
        ),
        child: child!,
      ),
    );
    if (d == null) return;
    isStart ? vm.setStart(d) : vm.setEnd(d);
  }

  Future<void> _proceed(AcademyHrViewmodel vm) async {
    final c = vm.selected;
    if (c == null) return;
    final res = await showModalBottomSheet<(String, String)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HrRemarksSheet(
        title: 'Proceed to HR',
        subtitle: '${c.name} · ${acadDate(vm.start)} to ${acadDate(vm.end)}',
        confirmLabel: 'Submit to HR',
        color: _kPink,
        icon: Icons.send_rounded,
        periodLabel: acadMonthYear(vm.start),
      ),
    );
    if (res == null || !mounted) return;
    await vm.proceedToHr(
        context: context, periodLabel: res.$1, remarks: res.$2);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;

    return Consumer<AcademyHrViewmodel>(
      builder: (context, vm, _) {
        final conv = vm.conversion;
        final names = vm.counsellors.map((c) => c.name).toList();

        return Scaffold(
          backgroundColor: _kPageBg,
          body: Column(children: [
            _Header(
              loading: vm.conversionLoading,
              onRefresh: vm.loadConversion,
              onHistory: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const HrSubmissionsScreen())),
            ),
            Expanded(
              child: RefreshIndicator(
                color: _kCyan,
                onRefresh: vm.loadConversion,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  padding: EdgeInsets.fromLTRB(
                      sw * .04, 18, sw * .04, mq.padding.bottom + 24),
                  children: [
                    if (vm.conversionError != null)
                      AcadErrorBanner(
                          message: vm.conversionError!,
                          onRetry: vm.selected == null
                              ? () => vm.loadCounsellors(force: true)
                              : vm.loadConversion),
                    const _SectionLabel(text: 'FILTER', color: _kCyan),
                    const SizedBox(height: 10),
                    _Pill(
                      icon: Icons.support_agent_rounded,
                      caption: 'Counsellor',
                      label: vm.selected?.name ??
                          (vm.counsellorsLoading
                              ? 'Loading counsellors…'
                              : 'Select counsellor'),
                      active: vm.selected != null,
                      trailing: Icons.keyboard_arrow_down_rounded,
                      onTap: () {
                        if (names.isEmpty) return;
                        showAcademyPicker(
                          context: context,
                          title: 'Select Counsellor',
                          options: names,
                          selected: vm.selected?.name ?? '',
                          onSelect: (v) => vm.selectCounsellor(
                              vm.counsellors.firstWhere((c) => c.name == v)),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                        child: _Pill(
                          icon: Icons.play_arrow_rounded,
                          caption: 'From',
                          label: acadDate(vm.start),
                          active: false,
                          trailing: Icons.calendar_month_rounded,
                          onTap: () => _pickDate(vm, true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _Pill(
                          icon: Icons.stop_rounded,
                          caption: 'To',
                          label: acadDate(vm.end),
                          active: false,
                          trailing: Icons.calendar_month_rounded,
                          onTap: () => _pickDate(vm, false),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 18),
                    if (vm.selected == null)
                      const _Empty(
                        icon: Icons.support_agent_rounded,
                        title: 'Select a Counsellor',
                        subtitle: 'Choose a counsellor and a date range\n'
                            'to see their conversions',
                      )
                    else if (vm.conversionLoading && conv == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Center(
                          child: CircularProgressIndicator(
                              color: _kCyan, strokeWidth: 2.5),
                        ),
                      )
                    else if (conv != null)
                      ..._buildReport(vm, conv),
                  ],
                ),
              ),
            ),
          ]),
        );
      },
    );
  }

  List<Widget> _buildReport(AcademyHrViewmodel vm, AcadConversion conv) {
    final c = vm.selected!;
    final status = conv.submissionStatus;
    return [
      AcadFadeIn(
        child: HrHeroCard(
          title: c.name,
          line1: '${acadDate(vm.start)}  →  ${acadDate(vm.end)}',
          line2: conv.counsellor.designation,
          status: status,
        ),
      ),
      const SizedBox(height: 20),
      const _SectionLabel(text: 'CONVERSION OVERVIEW', color: _kViolet),
      const SizedBox(height: 10),
      _StatsGrid(items: hrSummaryStats(conv.summary)),
      const SizedBox(height: 16),
      HrGradientButton(
        label: status == null ? 'Proceed to HR' : 'Submit Again to HR',
        icon: Icons.send_rounded,
        color: _kPink,
        loading: vm.submitting,
        onTap: () => _proceed(vm),
      ),
      const SizedBox(height: 20),
      AcadListHeader(
          title: 'Records', count: conv.records.length, color: _kPink),
      const SizedBox(height: 10),
      if (conv.records.isEmpty)
        const _Empty(
          icon: Icons.inbox_outlined,
          title: 'No Records',
          subtitle: 'No admissions or registrations in this period',
        )
      else
        ...List.generate(
          conv.records.length,
          (i) => AcadFadeIn(
            key: ValueKey(
                'rec_${conv.records[i].recordType}_${conv.records[i].id}'),
            index: i,
            child: HrRecordTile(r: conv.records[i]),
          ),
        ),
    ];
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Header
// ═════════════════════════════════════════════════════════════════════════════
class _Header extends StatelessWidget {
  final bool loading;
  final VoidCallback onRefresh;
  final VoidCallback onHistory;
  const _Header({
    required this.loading,
    required this.onRefresh,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: _kHeaderGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: _kCyan.withValues(alpha: 0.35),
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
          right: 96,
          top: mq.padding.top + 2,
          child: Transform.rotate(
            angle: -0.25,
            child: Icon(Icons.fact_check_rounded,
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
              bottom: 22,
              left: sw * .045,
              right: sw * .045),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.4)),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 19),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Counsellor Conversion',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('Verify conversions & send to HR',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 14)),
                  ]),
            ),
            const SizedBox(width: 8),
            AcadIconButton(icon: Icons.history_rounded, onTap: onHistory),
            const SizedBox(width: 8),
            AcadIconButton(
                icon: Icons.refresh_rounded, loading: loading, onTap: onRefresh),
          ]),
        ),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Section label
// ═════════════════════════════════════════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionLabel({required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          width: 4,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 7),
        Text(text,
            style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: _kSlate,
                letterSpacing: 1.1)),
      ]);
}

// ═════════════════════════════════════════════════════════════════════════════
// Filter pill (counsellor + date range)
// ═════════════════════════════════════════════════════════════════════════════
class _Pill extends StatelessWidget {
  final IconData icon;
  final IconData trailing;
  final String caption;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Pill({
    required this.icon,
    required this.trailing,
    required this.caption,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          gradient: active ? _kMainGradient : null,
          color: active ? null : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: active ? Colors.transparent : _kLine),
          boxShadow: [
            BoxShadow(
              color: active
                  ? _kCyan.withValues(alpha: 0.35)
                  : _kInk.withValues(alpha: 0.05),
              blurRadius: active ? 12 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: active
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_tint(_kCyan, 0.2), _kCyan],
                    ),
              color: active ? Colors.white.withValues(alpha: 0.24) : null,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(caption,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: active
                              ? Colors.white.withValues(alpha: 0.85)
                              : _kSlate)),
                  const SizedBox(height: 1),
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: active ? Colors.white : _kInk)),
                ]),
          ),
          Icon(trailing,
              size: 19, color: active ? Colors.white : _kSlate),
        ]),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Overview cards (white, colour wash, bottom bar, count-up)
// ═════════════════════════════════════════════════════════════════════════════
class _StatsGrid extends StatelessWidget {
  final List<AcadStat> items;
  const _StatsGrid({required this.items});

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
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: it.color.withValues(alpha: 0.18)),
                boxShadow: [
                  BoxShadow(
                    color: it.color.withValues(alpha: 0.16),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [
                            it.color.withValues(alpha: 0.10),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [_tint(it.color, 0.25), it.color]),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6, 0, 6, 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [_tint(it.color, 0.22), it.color],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: it.color.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(it.icon, size: 19, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: TweenAnimationBuilder<double>(
                              key: ValueKey('${it.label}_${it.value}'),
                              tween: Tween<double>(
                                  begin: 0,
                                  end: (int.tryParse(it.value) ?? 0)
                                      .toDouble()),
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOutCubic,
                              builder: (_, v, __) => Text(
                                  int.tryParse(it.value) == null
                                      ? it.value
                                      : '${v.round()}',
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: _kInk,
                                      height: 1.1)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        SizedBox(
                          width: double.infinity,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(it.label,
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: _shade(it.color, 0.1))),
                          ),
                        ),
                      ],
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

// ═════════════════════════════════════════════════════════════════════════════
// Empty state
// ═════════════════════════════════════════════════════════════════════════════
class _Empty extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _Empty(
      {required this.icon, required this.title, required this.subtitle});

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
                  _kCyan.withValues(alpha: 0.22),
                  _kCyan.withValues(alpha: 0.06)
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: _kCyan.withValues(alpha: 0.25)),
            ),
            child: Icon(icon, size: 38, color: _kCyan.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                  fontSize: 19, fontWeight: FontWeight.w700, color: _kInk)),
          const SizedBox(height: 6),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: _kSlate)),
        ]),
      ),
    );
  }
}