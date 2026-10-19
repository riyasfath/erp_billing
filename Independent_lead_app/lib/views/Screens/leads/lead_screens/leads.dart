// lib/views/Screens/leads/lead_screens/leads.dart
// REPLACED: Lead Dashboard (same as web) powered by GET /staff/dashboard/

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pokakbilling/viewmodels/staff_dashboard/staff_dashboard_viewmodel.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/ai_generator_screen.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/lead_widgets.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/staff_dashboard_model.dart';
import 'package:pokakbilling/views/Screens/leads/follow_up/follow_up.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/create_lead.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leads_bottomBar.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leadsNewScreen.dart';
import 'package:pokakbilling/views/Screens/leads/meeting/meeting.dart';
import 'package:pokakbilling/views/Screens/leads/my_activity/my_activity_screen.dart';
import 'package:pokakbilling/views/Screens/leads/reminder/lead_reminder.dart';

class LeadScreen extends StatefulWidget {
  const LeadScreen({super.key});

  @override
  State<LeadScreen> createState() => _LeadScreenState();
}

class _LeadScreenState extends State<LeadScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  late DateTime _month;
  String _recentFilter = 'All';
  bool _showLost = false;

  static final NumberFormat _money =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _month = DateTime(n.year, n.month);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<StaffDashboardViewModel>();
      _searchCtrl.text = vm.search;
      vm.load();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      bottomNavigationBar: const LeadsBottomBar(index: 1),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            pushNavigation(context, const CreateLead(isEdit: false)),
        backgroundColor: AppColors.c1,
        elevation: 6,
        child: const Icon(Icons.add_rounded, color: AppColors.white, size: 26),
      ),
      body: Consumer<StaffDashboardViewModel>(
        builder: (context, vm, _) {
          final d = vm.data;
          return Column(children: [
            _header(context, vm),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.c1,
                onRefresh: () => vm.load(silent: true),
                child: d == null
                    ? _firstLoad(vm)
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
                        children: [
                          if (vm.loading)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: LinearProgressIndicator(
                                  minHeight: 3, color: AppColors.c1),
                            ),
                          if (vm.error != null) _errorBanner(vm),
                          Reveal(child: _stats(d.stats)),
                          const SizedBox(height: 14),
                          Reveal(delayMs: 60, child: _outcomes(d.outcomes)),
                          const SizedBox(height: 14),
                          Reveal(delayMs: 100, child: _weekly(d.weekly)),
                          const SizedBox(height: 14),
                          Reveal(delayMs: 140, child: _calendar(vm, d)),
                          const SizedBox(height: 14),
                          Reveal(
                            delayMs: 180,
                            child: _timelineCard(
                              icon: Icons.schedule_rounded,
                              title: 'Meetings & Calls',
                              items: d.meetingsAndCalls,
                              empty: 'No meetings or calls in this period',
                            ),
                          ),
                          const SizedBox(height: 14),
                          Reveal(
                            delayMs: 220,
                            child: _timelineCard(
                              icon: Icons.repeat_rounded,
                              title: 'Follow-ups',
                              items: d.followUps,
                              empty: 'No follow-ups in this period',
                            ),
                          ),
                          const SizedBox(height: 14),
                          Reveal(delayMs: 260, child: _recent(d.recent)),
                          const SizedBox(height: 14),
                          Reveal(delayMs: 300, child: _quickActions(context)),
                        ],
                      ),
              ),
            ),
          ]);
        },
      ),
    );
  }

  Widget _firstLoad(StaffDashboardViewModel vm) {
    if (vm.error != null && !vm.loading) {
      return ListView(children: [
        const SizedBox(height: 80),
        _errorBanner(vm),
      ]);
    }
    return const Center(
        child: CircularProgressIndicator(color: AppColors.c1, strokeWidth: 2.5));
  }

  Widget _errorBanner(StaffDashboardViewModel vm) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: LeadUi.danger.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: LeadUi.danger.withOpacity(0.25)),
        ),
        child: Row(children: [
          const Icon(Icons.error_outline_rounded, color: LeadUi.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(vm.error ?? '',
                style: const TextStyle(fontSize: 12.5, color: LeadUi.danger)),
          ),
          TextButton(onPressed: vm.load, child: const Text('Retry')),
        ]),
      );

  // ─── HEADER ───────────────────────────────────────────────────────────────
  Widget _header(BuildContext context, StaffDashboardViewModel vm) {
    final top = MediaQuery.of(context).padding.top;
    final h = DateTime.now().hour;
    final greet =
        h < 12 ? 'Good morning' : (h < 17 ? 'Good afternoon' : 'Good evening');
    final tasks = vm.data?.tasksLinedUp ?? 0;

    return Container(
      padding: EdgeInsets.fromLTRB(16, top + 12, 16, 14),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.cborder, width: 1.5)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
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
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$greet 👋',
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.ctext)),
              const Text('Lead Dashboard',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.cdark,
                      letterSpacing: .2)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.c1.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(children: [
              Text('$tasks',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.c3)),
              const Text('tasks',
                  style: TextStyle(fontSize: 9.5, color: AppColors.ctext)),
            ]),
          ),
        ]),
        const SizedBox(height: 6),
        Text.rich(TextSpan(
          style: const TextStyle(fontSize: 12.5, color: AppColors.ctext),
          children: [
            const TextSpan(text: 'You have '),
            TextSpan(
                text: '$tasks task${tasks == 1 ? '' : 's'}',
                style: const TextStyle(
                    color: AppColors.c3, fontWeight: FontWeight.w800)),
            const TextSpan(text: ' lined up for today'),
          ],
        )),
        const SizedBox(height: 12),
        SearchField(
          controller: _searchCtrl,
          hint: 'Search lead or company...',
          onChanged: vm.setSearch,
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _segmented(vm)),
          const SizedBox(width: 8),
          _dateChip(vm),
        ]),
      ]),
    );
  }

  Widget _segmented(StaffDashboardViewModel vm) {
    const items = {'day': 'Day', 'week': 'Week', 'month': 'Month'};
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.cxl,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cborder),
      ),
      child: Row(
        children: items.entries.map((e) {
          final sel = vm.filterType == e.key && !vm.hasCustomRange;
          return Expanded(
            child: GestureDetector(
              onTap: () => vm.setFilterType(e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sel ? AppColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: sel ? LeadUi.shadow(.12) : null,
                ),
                child: Text(e.value,
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                        color: sel ? AppColors.cdark : AppColors.ctext)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _dateChip(StaffDashboardViewModel vm) {
    String label;
    if (vm.hasCustomRange) {
      final f = DateFormat('dd MMM');
      label = vm.isSingleDay
          ? f.format(vm.startDate!)
          : '${f.format(vm.startDate!)} – ${f.format(vm.endDate ?? vm.startDate!)}';
    } else {
      label = DateFormat('EEE, dd MMM').format(DateTime.now());
    }
    final active = vm.hasCustomRange;
    return GestureDetector(
      onTap: () => _pickRange(vm),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.c1.withOpacity(0.10) : AppColors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
              color: active ? AppColors.c1.withOpacity(0.5) : AppColors.cborder),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.calendar_today_rounded,
              size: 14, color: active ? AppColors.c1 : AppColors.ctext),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: active ? AppColors.c1 : AppColors.cdark)),
          if (active) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: vm.clearRange,
              child:
                  const Icon(Icons.close_rounded, size: 15, color: AppColors.c1),
            ),
          ],
        ]),
      ),
    );
  }

  Future<void> _pickRange(StaffDashboardViewModel vm) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 2, 12, 31),
      initialDateRange: vm.startDate != null
          ? DateTimeRange(start: vm.startDate!, end: vm.endDate ?? vm.startDate!)
          : DateTimeRange(start: now, end: now),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.c1,
            onPrimary: AppColors.white,
            surface: AppColors.white,
            onSurface: AppColors.cdark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _month = DateTime(picked.start.year, picked.start.month));
      vm.setRange(picked.start, picked.end);
    }
  }

  // ─── TOP STAT CARDS ───────────────────────────────────────────────────────
  Widget _stats(ActivityStats s) {
    final items = <_StatItem>[
      _StatItem(Icons.repeat_rounded, 'Follow-ups', s.followUps, LeadUi.followUp),
      _StatItem(Icons.videocam_rounded, 'Meetings', s.meetings, LeadUi.meeting),
      _StatItem(Icons.call_rounded, 'Calls', s.calls, LeadUi.call),
      _StatItem(Icons.mail_rounded, 'Emails', s.emails, LeadUi.email),
      _StatItem(Icons.chat_rounded, 'WhatsApp', s.whatsapp, LeadUi.whatsapp),
    ];
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final it = items[i];
          return Container(
            width: 124,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.c1.withOpacity(0.15)),
              boxShadow: LeadUi.shadow(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: it.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(it.icon, size: 18, color: it.color),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: it.value.toDouble()),
                    duration: const Duration(milliseconds: 700),
                    builder: (_, v, __) => Text('${v.round()}',
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.cdark,
                            height: 1)),
                  ),
                  const SizedBox(height: 2),
                  Text(it.label,
                      style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ctext)),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── LEAD OUTCOMES ────────────────────────────────────────────────────────
  Widget _outcomes(LeadOutcomes o) {
    final rate = (o.conversionRate.clamp(0, 100)) / 100.0;
    final list = _showLost ? o.lostLeads : o.convertedLeads;

    return AppCard(
      accent: LeadUi.success,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionTitle(icon: Icons.emoji_events_outlined, title: 'Lead Outcomes'),
        const SizedBox(height: 16),
        Row(children: [
          SizedBox(
            width: 92,
            height: 92,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: rate.toDouble()),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => CustomPaint(
                painter: _RingPainter(
                    value: v,
                    color: LeadUi.success,
                    track: LeadUi.danger.withOpacity(0.12)),
                child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('${(v * 100).round()}%',
                        style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: AppColors.cdark)),
                    const Text('WIN RATE',
                        style: TextStyle(
                            fontSize: 7.5,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ctext)),
                  ]),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: _outcomeTile(Icons.check_circle_outline_rounded,
                  '${o.converted}', 'Converted', LeadUi.success)),
          const SizedBox(width: 10),
          Expanded(
              child: _outcomeTile(Icons.cancel_outlined, '${o.lost}', 'Lost',
                  LeadUi.danger)),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: LeadUi.success.withOpacity(0.08),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(children: [
            const Text('Revenue closed',
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ctext)),
            const Spacer(),
            Text(_money.format(o.revenueClosed),
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.c3)),
          ]),
        ),
        const SizedBox(height: 14),
        _toggle(),
        const SizedBox(height: 8),
        if (list.isEmpty)
          EmptyHint(
              text: _showLost
                  ? 'No lost leads in this period'
                  : 'No converted leads in this period')
        else
          ...list.map((l) => _outcomeRow(l)),
      ]),
    );
  }

  Widget _outcomeTile(IconData icon, String v, String label, Color c) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: c.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 16, color: c),
          const SizedBox(height: 4),
          Text(v,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w900, color: c, height: 1)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 10.5, fontWeight: FontWeight.w700, color: c)),
        ]),
      );

  Widget _toggle() => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.cxl,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(children: [
          for (final lost in [false, true])
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _showLost = lost),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _showLost == lost ? AppColors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: _showLost == lost ? LeadUi.shadow(.1) : null,
                  ),
                  child: Text(lost ? 'Lost' : 'Converted',
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: _showLost == lost
                              ? AppColors.cdark
                              : AppColors.ctext)),
                ),
              ),
            ),
        ]),
      );

  Widget _outcomeRow(OutcomeLead l) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundColor:
                (_showLost ? LeadUi.danger : LeadUi.success).withOpacity(0.12),
            child: Text(l.name.isNotEmpty ? l.name[0].toUpperCase() : '?',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: _showLost ? LeadUi.danger : LeadUi.success)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cdark)),
              if (l.company.isNotEmpty)
                Text(l.company,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.ctext)),
            ]),
          ),
          if (_showLost)
            Flexible(
              child: StatusPill(
                  label: l.reason.isEmpty ? 'LOST' : l.reason,
                  color: LeadUi.danger),
            )
          else
            Text(_money.format(l.revenue),
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.c3)),
        ]),
      );

  // ─── WEEKLY ACTIVITY ──────────────────────────────────────────────────────
  Widget _weekly(List<WeeklyPoint> w) {
    final maxV = w.fold<int>(1, (m, e) => math.max(m, math.max(e.calls, e.meetings)));
    final totalCalls = w.fold<int>(0, (s, e) => s + e.calls);
    final totalMeet = w.fold<int>(0, (s, e) => s + e.meetings);
    final range = w.isEmpty ? '' : '${w.first.date} – ${w.last.date}';

    return AppCard(
      accent: LeadUi.call,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionTitle(
          icon: Icons.show_chart_rounded,
          title: 'Weekly Activity',
          trailing: Text(range,
              style: const TextStyle(fontSize: 10.5, color: AppColors.ctext)),
        ),
        const SizedBox(height: 16),
        if (w.isEmpty)
          const EmptyHint(text: 'No activity this week')
        else
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: w.map((p) {
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _bar(p.calls, maxV, LeadUi.call),
                          const SizedBox(width: 3),
                          _bar(p.meetings, maxV, LeadUi.meeting),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(p.day,
                          style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cdark)),
                      Text(p.date.split(' ').first,
                          style: const TextStyle(
                              fontSize: 9, color: AppColors.ctext)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _legend(LeadUi.call, 'Calls', totalCalls),
          const SizedBox(width: 22),
          _legend(LeadUi.meeting, 'Meetings', totalMeet),
        ]),
      ]),
    );
  }

  Widget _bar(int v, int maxV, Color c) {
    final h = v == 0 ? 3.0 : math.max(6.0, v / maxV * 96);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      if (v > 0)
        Text('$v',
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: c)),
      const SizedBox(height: 2),
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: h),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (_, hh, __) => Container(
          width: 10,
          height: hh,
          decoration: BoxDecoration(
            color: v == 0 ? c.withOpacity(0.18) : c,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    ]);
  }

  Widget _legend(Color c, String label, int total) => Row(children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$label · $total',
            style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.ctext)),
      ]);

  // ─── CALENDAR ─────────────────────────────────────────────────────────────
  Widget _calendar(StaffDashboardViewModel vm, StaffDashboard d) {
    final byDate = {for (final e in d.calendar) e.date: e};
    final first = DateTime(_month.year, _month.month, 1);
    final days = DateTime(_month.year, _month.month + 1, 0).day;
    final lead = first.weekday - 1; // Monday first
    final today = DateTime.now();
    final fmt = DateFormat('yyyy-MM-dd');

    final cells = <Widget>[
      for (var i = 0; i < lead; i++) const SizedBox.shrink(),
      for (var day = 1; day <= days; day++)
        Builder(builder: (_) {
          final date = DateTime(_month.year, _month.month, day);
          final ev = byDate[fmt.format(date)];
          final isToday = DateUtils.isSameDay(date, today);
          final selected = vm.isSingleDay && DateUtils.isSameDay(vm.startDate, date);
          final dots = <Color>[
            if ((ev?.followUps ?? 0) > 0) LeadUi.followUp,
            if ((ev?.meetings ?? 0) > 0) LeadUi.meeting,
            if ((ev?.calls ?? 0) > 0) LeadUi.call,
            if ((ev?.emails ?? 0) > 0) LeadUi.email,
            if ((ev?.whatsapp ?? 0) > 0) LeadUi.whatsapp,
          ];
          return GestureDetector(
            onTap: () => vm.setDay(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: selected ? AppColors.cdark : Colors.transparent,
                borderRadius: BorderRadius.circular(11),
                border: isToday && !selected
                    ? Border.all(color: AppColors.c1, width: 1.4)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$day',
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight:
                              isToday || selected ? FontWeight.w800 : FontWeight.w500,
                          color: selected ? AppColors.white : AppColors.cdark)),
                  const SizedBox(height: 3),
                  SizedBox(
                    height: 5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: dots
                          .take(5)
                          .map((c) => Container(
                                width: 4,
                                height: 4,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration:
                                    BoxDecoration(color: c, shape: BoxShape.circle),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
    ];

    return AppCard(
      accent: LeadUi.meeting,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionTitle(
          icon: Icons.calendar_month_rounded,
          title: 'Calendar',
          trailing: StatusPill(
              label: vm.isSingleDay ? 'DAY VIEW' : 'PERIOD VIEW',
              color: AppColors.c3),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Text(DateFormat('MMMM yyyy').format(_month),
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.cdark)),
          const Spacer(),
          _navBtn(Icons.chevron_left_rounded,
              () => setState(() => _month = DateTime(_month.year, _month.month - 1))),
          const SizedBox(width: 6),
          _navBtn(Icons.chevron_right_rounded,
              () => setState(() => _month = DateTime(_month.year, _month.month + 1))),
        ]),
        const SizedBox(height: 8),
        Row(
          children: ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU']
              .map((e) => Expanded(
                    child: Center(
                      child: Text(e,
                          style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ctext)),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 4),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: .88,
          children: cells,
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 12, runSpacing: 6, children: [
          _dotLegend(LeadUi.followUp, 'Follow-ups'),
          _dotLegend(LeadUi.meeting, 'Meetings'),
          _dotLegend(LeadUi.call, 'Calls'),
          _dotLegend(LeadUi.email, 'Emails'),
          _dotLegend(LeadUi.whatsapp, 'WhatsApp'),
        ]),
      ]),
    );
  }

  Widget _navBtn(IconData i, VoidCallback t) => GestureDetector(
        onTap: t,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.cxl,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: AppColors.cborder),
          ),
          child: Icon(i, size: 18, color: AppColors.c3),
        ),
      );

  Widget _dotLegend(Color c, String l) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(l, style: const TextStyle(fontSize: 10, color: AppColors.ctext)),
      ]);

  // ─── TIMELINES ────────────────────────────────────────────────────────────
  Widget _timelineCard({
    required IconData icon,
    required String title,
    required List<TimelineItem> items,
    required String empty,
    bool showStatus = true,
  }) {
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionTitle(
          icon: icon,
          title: title,
          trailing: Text('${items.length} item${items.length == 1 ? '' : 's'}',
              style: const TextStyle(fontSize: 11, color: AppColors.ctext)),
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          EmptyHint(text: empty)
        else
          ...items.map(_timelineRow),
      ]),
    );
  }

  Widget _timelineRow(TimelineItem t) {
    final type = t.type.isEmpty ? 'Follow Up' : t.type;
    final c = LeadUi.typeColor(type);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: c.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(LeadUi.typeIcon(type), size: 18, color: c),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.cdark)),
            const SizedBox(height: 2),
            Text(t.lead,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, color: AppColors.ctext)),
          ]),
        ),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(t.time,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cdark)),
          const SizedBox(height: 4),
          if (t.status.isNotEmpty)
            StatusPill(label: t.status.toUpperCase(), color: LeadUi.statusColor(t.status)),
        ]),
      ]),
    );
  }

  Widget _recent(List<TimelineItem> all) {
    bool match(TimelineItem t, String f) {
      final x = t.type.toLowerCase();
      switch (f) {
        case 'Follow-ups':
          return x.contains('follow');
        case 'Meetings':
          return x.contains('meeting');
        case 'Calls':
          return x.contains('call');
        case 'Emails':
          return x.contains('mail');
        case 'WhatsApp':
          return x.contains('whatsapp');
        default:
          return true;
      }
    }

    final filters = ['All', 'Follow-ups', 'Meetings', 'Calls', 'Emails', 'WhatsApp'];
    final shown = all.where((t) => match(t, _recentFilter)).toList();

    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionTitle(icon: Icons.timeline_rounded, title: 'Recent Activities'),
        const SizedBox(height: 12),
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final f = filters[i];
              final sel = f == _recentFilter;
              final n = all.where((t) => match(t, f)).length;
              return GestureDetector(
                onTap: () => setState(() => _recentFilter = f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: sel ? AppColors.cdark : AppColors.cxl,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: sel ? AppColors.cdark : AppColors.cborder),
                  ),
                  child: Text('$f  $n',
                      style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: sel ? AppColors.white : AppColors.ctext)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        if (shown.isEmpty)
          const EmptyHint(text: 'No activity in this period')
        else
          ...shown.map(_timelineRow),
      ]),
    );
  }

  // ─── QUICK ACTIONS ────────────────────────────────────────────────────────
  Widget _quickActions(BuildContext context) {
    final actions = <_QA>[
      _QA(Icons.person_add_alt_1_rounded, 'Create Lead',
          () => pushNavigation(context, const CreateLead(isEdit: false))),
      _QA(Icons.people_alt_rounded, 'All Leads',
          () => pushNavigation(context, const LeadsNewScreen())),
      _QA(Icons.event_repeat_rounded, 'Follow-ups',
          () => pushNavigation(context, const FollowUp())),
      _QA(Icons.local_activity_rounded, 'Organizer',
          () => pushNavigation(context, const ActivityScreen())),
      _QA(Icons.event_note_rounded, 'Meetings',
          () => pushNavigation(context, const MeetingScreen())),
      _QA(Icons.notifications_active_rounded, 'Reminders',
          () => pushNavigation(context, const LeadReminder())),
      _QA(Icons.mail_rounded, 'AI Email',
          () => pushNavigation(context, const AiGeneratorScreen(initialChannel: 'email'))),
      _QA(Icons.chat_rounded, 'AI WhatsApp',
          () => pushNavigation(context, const AiGeneratorScreen(initialChannel: 'whatsapp'))),
    ];
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionTitle(icon: Icons.bolt_rounded, title: 'Quick Actions'),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 8,
          childAspectRatio: .86,
          children: actions
              .map((a) => GestureDetector(
                    onTap: a.onTap,
                    child: Column(children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.c1.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(a.icon, color: AppColors.c3, size: 22),
                      ),
                      const SizedBox(height: 6),
                      Text(a.label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cdark)),
                    ]),
                  ))
              .toList(),
        ),
      ]),
    );
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final int value;
  final Color color;
  const _StatItem(this.icon, this.label, this.value, this.color);
}

class _QA {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QA(this.icon, this.label, this.onTap);
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color color;
  final Color track;
  _RingPainter({required this.value, required this.color, required this.track});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 9.0;
    final c = size.center(Offset.zero);
    final r = (size.shortestSide - stroke) / 2;
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, r, p..color = track);
    if (value > 0) {
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), -math.pi / 2,
          2 * math.pi * value, false, p..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.value != value || old.color != color || old.track != track;
}