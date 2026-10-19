import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/viewmodels/activity_leads/activity_viewmodel.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/followup_viewmodel.dart';
import 'package:pokakbilling/views/Screens/leads/follow_up/follow_up.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/create_lead.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leads_bottomBar.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leadsnewscreen.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/myactivityscreen.dart';
import 'package:pokakbilling/views/Screens/leads/meeting/meeting.dart';
import 'package:pokakbilling/views/Screens/leads/reminder/lead_reminder.dart';
import 'package:provider/provider.dart';

// ═════════════════════════════════════════════════════════════════════════════
// Colour scheme (same as Academy dashboard / ERP home)
// ═════════════════════════════════════════════════════════════════════════════
const Color _kPageBg = Color(0xFFF0FAFD);
const Color _kInk = Color(0xFF0F172A);
const Color _kSlate = Color(0xFF64748B);
const Color _kLine = Color(0xFFD9ECF2);

const Color _kCyan = Color(0xFF06B6D4);
const Color _kCyanLight = Color(0xFF67E8F9);
const Color _kCyanDeep = Color(0xFF0E7490);
const Color _kBlue = Color(0xFF3B82F6);
const Color _kOrange = Color(0xFFF97316);
const Color _kViolet = Color(0xFF8B5CF6);
const Color _kGreen = Color(0xFF16A34A);
const Color _kPink = Color(0xFFEC4899);
const Color _kAmber = Color(0xFFF59E0B);
const Color _kRed = Color(0xFFEF4444);

const LinearGradient _kHeaderGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [_kCyanDeep, _kCyan, _kCyanLight],
);

Color _shade(Color c, double amt) => Color.lerp(c, Colors.black, amt)!;
Color _tint(Color c, double amt) => Color.lerp(c, Colors.white, amt)!;

// ═════════════════════════════════════════════════════════════════════════════
// Screen
// ═════════════════════════════════════════════════════════════════════════════
class LeadScreen extends StatefulWidget {
  const LeadScreen({super.key});

  @override
  State<LeadScreen> createState() => _LeadScreenState();
}

class _LeadScreenState extends State<LeadScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.45, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final leadVm = context.read<LeadViewmodel>();
      if (leadVm.leadList.isEmpty) leadVm.getAllLeads();

      context.read<FollowupViewmodel>().fetchFollowups();

      final activityVm = context.read<ActivityScreenViewmodel>();
      activityVm.init();
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  DateTime? _parseDate(String? s) {
    if (s == null || s.trim().isEmpty) return null;
    try {
      return DateTime.parse(s.trim());
    } catch (_) {
      return null;
    }
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _openLeadsFiltered(BuildContext context, DateTime from, DateTime to) {
    pushNavigation(
      context,
      LeadsNewScreen(preFilterFrom: from, preFilterTo: to),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kPageBg,
      bottomNavigationBar: const LeadsBottomBar(index: 1),
      floatingActionButton: _GradientFab(
        onTap: () => pushNavigation(context, const CreateLead(isEdit: false)),
      ),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Consumer3<LeadViewmodel, FollowupViewmodel,
                ActivityScreenViewmodel>(
              builder: (_, leadVm, followupVm, activityVm, __) {
                if (leadVm.singleLeadLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: _kCyan),
                  );
                }
                return _buildBody(context, leadVm, followupVm, activityVm);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── HEADER (cyan gradient, Academy style) ─────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;

    return Consumer<LeadViewmodel>(
      builder: (_, vm, __) {
        final totalLeads = vm.leadList.length;
        final convertedLeads = vm.leadList
            .where((l) => (l.leadStatus ?? '').toUpperCase() == 'CONVERTED')
            .length;
        final ratio = totalLeads > 0
            ? (convertedLeads / totalLeads).clamp(0.0, 1.0).toDouble()
            : 0.0;

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
              right: 70,
              top: mq.padding.top + 2,
              child: Transform.rotate(
                angle: -0.25,
                child: Icon(Icons.trending_up_rounded,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    _Pressable(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4)),
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
                          Row(children: [
                            AnimatedBuilder(
                              animation: _pulseAnim,
                              builder: (_, __) => Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4ADE80)
                                      .withValues(alpha: _pulseAnim.value),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4ADE80).withValues(
                                          alpha: _pulseAnim.value * 0.6),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('LIVE',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5)),
                          ]),
                          const SizedBox(height: 2),
                          const Text('Leads',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900)),
                          const SizedBox(height: 1),
                          Text(
                            '$totalLeads lead${totalLeads == 1 ? '' : 's'} in pipeline',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.88),
                                fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Total badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4)),
                      ),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        TweenAnimationBuilder<double>(
                          key: ValueKey('total_$totalLeads'),
                          tween: Tween<double>(
                              begin: 0, end: totalLeads.toDouble()),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          builder: (_, v, __) => Text('${v.round()}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1)),
                        ),
                        Text('Total',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.88),
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // ── Conversion rate (glass card) ──────────────────────
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.30)),
                    ),
                    child: Column(children: [
                      Row(children: [
                        const Icon(Icons.trending_up_rounded,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Conversion Rate · $convertedLeads/$totalLeads converted',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        TweenAnimationBuilder<double>(
                          key: ValueKey('pct_$ratio'),
                          tween: Tween<double>(begin: 0, end: ratio * 100),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOutCubic,
                          builder: (_, v, __) => Text(
                              '${v.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900)),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 8,
                          color: Colors.white.withValues(alpha: 0.25),
                          alignment: Alignment.centerLeft,
                          child: TweenAnimationBuilder<double>(
                            key: ValueKey('bar_$ratio'),
                            tween: Tween<double>(begin: 0, end: ratio),
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.easeOutCubic,
                            builder: (_, v, __) => FractionallySizedBox(
                              widthFactor: v == 0 ? 0.02 : v,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ]),
        );
      },
    );
  }

  // ── BODY ──────────────────────────────────────────────────────────────────
  Widget _buildBody(
    BuildContext context,
    LeadViewmodel leadVm,
    FollowupViewmodel followupVm,
    ActivityScreenViewmodel activityVm,
  ) {
    final now = DateTime.now();
    final todayOnly = DateTime(now.year, now.month, now.day);

    final todayStart = todayOnly;
    final todayEnd = todayOnly;

    final weekDayOffset = now.weekday - 1;
    final weekStart = DateTime(now.year, now.month, now.day - weekDayOffset);
    final weekEnd = weekStart.add(const Duration(days: 6));

    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);

    int leadsToday = 0;
    int leadsThisWeek = 0;
    int leadsThisMonth = 0;

    for (final lead in leadVm.leadList) {
      final d = _parseDate((lead.date.isNotEmpty) ? lead.date : lead.enquiry);
      if (d == null) continue;
      final dOnly = DateTime(d.year, d.month, d.day);

      if (_isSameDate(dOnly, todayOnly)) leadsToday++;
      if (!dOnly.isBefore(weekStart) && !dOnly.isAfter(weekEnd)) {
        leadsThisWeek++;
      }
      if (!dOnly.isBefore(monthStart) && !dOnly.isAfter(monthEnd)) {
        leadsThisMonth++;
      }
    }

    final int totalActivities = activityVm.allItems.length;
    final int totalLeads = leadVm.leadList.length;

    int followupsToday = 0;
    int followupsUpcoming = 0;
    int followupsOverdue = 0;
    int followupsDone = 0;

    for (final f in followupVm.followups) {
      if (f.status.toLowerCase() == 'completed') {
        followupsDone++;
        continue;
      }
      final fd = _parseDate(f.date);
      if (fd == null) continue;
      final fOnly = DateTime(fd.year, fd.month, fd.day);
      if (_isSameDate(fOnly, todayOnly)) {
        followupsToday++;
      } else if (fOnly.isAfter(todayOnly)) {
        followupsUpcoming++;
      } else {
        followupsOverdue++;
      }
    }

    final sw = MediaQuery.of(context).size.width;

    return RefreshIndicator(
      color: _kCyan,
      onRefresh: () async {
        await Future.wait([
          Future.sync(() => leadVm.getAllLeads()),
          Future.sync(() => followupVm.fetchFollowups()),
          Future.sync(() => activityVm.init()),
        ]);
      },
      child: ListView(
        padding: EdgeInsets.fromLTRB(sw * .04, 18, sw * .04, 96),
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        children: [
          // ── Leads overview ─────────────────────────────────────────────
          const _SectionLabel(text: 'LEADS OVERVIEW', color: _kCyan),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: _FadeIn(
                index: 0,
                child: _StatCard(
                  value: leadsToday,
                  label: 'Today',
                  icon: Icons.today_rounded,
                  color: _kCyan,
                  onTap: () =>
                      _openLeadsFiltered(context, todayStart, todayEnd),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FadeIn(
                index: 1,
                child: _StatCard(
                  value: leadsThisWeek,
                  label: 'This Week',
                  icon: Icons.date_range_rounded,
                  color: _kViolet,
                  onTap: () => _openLeadsFiltered(context, weekStart, weekEnd),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FadeIn(
                index: 2,
                child: _StatCard(
                  value: leadsThisMonth,
                  label: 'This Month',
                  icon: Icons.calendar_month_rounded,
                  color: _kGreen,
                  onTap: () =>
                      _openLeadsFiltered(context, monthStart, monthEnd),
                ),
              ),
            ),
          ]),

          // ── Activity snapshot ──────────────────────────────────────────
          const SizedBox(height: 22),
          const _SectionLabel(text: 'ACTIVITY SNAPSHOT', color: _kPink),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: _FadeIn(
                index: 3,
                child: _StatCard(
                  value: totalLeads,
                  label: 'All Leads',
                  icon: Icons.people_alt_rounded,
                  color: _kPink,
                  onTap: () => pushNavigation(context, const LeadsNewScreen()),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FadeIn(
                index: 4,
                child: _StatCard(
                  value: followupsToday,
                  label: 'Follow-ups',
                  icon: Icons.event_repeat_rounded,
                  color: _kOrange,
                  onTap: () => pushNavigation(context, const FollowUp()),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FadeIn(
                index: 5,
                child: _StatCard(
                  value: totalActivities,
                  label: 'Organizer',
                  icon: Icons.event_note_rounded,
                  color: _kAmber,
                  onTap: () =>
                      pushNavigation(context, const MyOrganizerScreen()),
                ),
              ),
            ),
          ]),

          // ── Follow-up summary ──────────────────────────────────────────
          const SizedBox(height: 22),
          _SectionHeader(
            label: 'FOLLOW-UP SUMMARY',
            color: _kOrange,
            onTap: () => pushNavigation(context, const FollowUp()),
          ),
          const SizedBox(height: 10),
          _FadeIn(
            index: 6,
            child: _FollowupSummaryCard(
              today: followupsToday,
              upcoming: followupsUpcoming,
              overdue: followupsOverdue,
              done: followupsDone,
              onTap: () => pushNavigation(context, const FollowUp()),
            ),
          ),

          // ── Quick actions ──────────────────────────────────────────────
          const SizedBox(height: 22),
          const _SectionLabel(text: 'QUICK ACTIONS', color: _kViolet),
          const SizedBox(height: 12),
          ..._quickActions(context),
        ],
      ),
    );
  }

  List<Widget> _quickActions(BuildContext context) {
    final actions = [
      _ActionData(Icons.people_alt_rounded, 'All Leads',
          'View and manage all leads', _kCyan,
          () => pushNavigation(context, const LeadsNewScreen())),
      _ActionData(Icons.event_repeat_rounded, 'Follow-ups',
          'Track your follow-up schedule', _kOrange,
          () => pushNavigation(context, const FollowUp())),
      _ActionData(Icons.event_note_rounded, 'My Organizer',
          'View and manage all activities', _kViolet,
          () => pushNavigation(context, const MyOrganizerScreen())),
      _ActionData(Icons.person_add_alt_1_rounded, 'Create Lead',
          'Add a new sales lead', _kGreen,
          () => pushNavigation(context, const CreateLead(isEdit: false))),
      _ActionData(Icons.video_camera_front_rounded, 'Meeting Schedule',
          'Plan and track meetings', _kBlue,
          () => pushNavigation(context, const MeetingScreen())),
      _ActionData(Icons.alarm_rounded, 'Reminder', 'Set follow-up reminders',
          _kPink, () => pushNavigation(context, const LeadReminder())),
    ];

    return [
      for (var i = 0; i < actions.length; i++)
        _FadeIn(index: 7 + i, child: _ActionCard(data: actions[i])),
    ];
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Section label / header (coloured bar)
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

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SectionHeader(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _SectionLabel(text: label, color: color),
      const Spacer(),
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text('View all',
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: color)),
            const SizedBox(width: 2),
            Icon(Icons.chevron_right_rounded, size: 16, color: color),
          ]),
        ),
      ),
    ]);
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Stat card (white, colour wash, bottom bar, count-up)
// ═════════════════════════════════════════════════════════════════════════════
class _StatCard extends StatelessWidget {
  final int value;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color;
    return _Pressable(
      onTap: onTap,
      child: Container(
        height: 118,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: c.withValues(alpha: 0.16),
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
                      c.withValues(alpha: 0.10),
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
                  gradient: LinearGradient(colors: [_tint(c, 0.25), c]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_tint(c, 0.22), c],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: c.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(icon, size: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey('${label}_$value'),
                        tween: Tween<double>(begin: 0, end: value.toDouble()),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, __) => Text('${v.round()}',
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
                      child: Text(label,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _shade(c, 0.1))),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Follow-up summary card
// ═════════════════════════════════════════════════════════════════════════════
class _FollowupSummaryCard extends StatelessWidget {
  final int today;
  final int upcoming;
  final int overdue;
  final int done;
  final VoidCallback onTap;
  const _FollowupSummaryCard({
    required this.today,
    required this.upcoming,
    required this.overdue,
    required this.done,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final total = today + upcoming + overdue + done;
    final doneRatio = total == 0 ? 0.0 : done / total;

    Widget tile(String label, int count, Color c, IconData ic) {
      return Expanded(
        child: Column(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  c.withValues(alpha: 0.10),
                  c.withValues(alpha: 0.20),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: c.withValues(alpha: 0.30)),
            ),
            child: Center(
              child: TweenAnimationBuilder<double>(
                key: ValueKey('${label}_$count'),
                tween: Tween<double>(begin: 0, end: count.toDouble()),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => Text('${v.round()}',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: _shade(c, 0.08))),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(ic, size: 12, color: c),
            const SizedBox(width: 3),
            Text(label,
                style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: _kSlate)),
          ]),
        ]),
      );
    }

    return _Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _kLine),
          boxShadow: [
            BoxShadow(
              color: _kOrange.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(children: [
          Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_tint(_kOrange, 0.22), _kOrange],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _kOrange.withValues(alpha: 0.32),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.event_repeat_rounded,
                  color: Colors.white, size: 23),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Follow-ups',
                        style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: _kInk)),
                    const SizedBox(height: 2),
                    Text('$done of $total completed',
                        style:
                            const TextStyle(fontSize: 12.5, color: _kSlate)),
                  ]),
            ),
            if (overdue > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _kRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$overdue overdue',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _kRed)),
              ),
          ]),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 8,
              color: _kGreen.withValues(alpha: 0.12),
              alignment: Alignment.centerLeft,
              child: TweenAnimationBuilder<double>(
                key: ValueKey('fu_$doneRatio'),
                tween: Tween<double>(begin: 0, end: doneRatio),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => FractionallySizedBox(
                  widthFactor: v,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [_tint(_kGreen, 0.3), _kGreen]),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            tile('Today', today, _kCyan, Icons.today_rounded),
            tile('Upcoming', upcoming, _kViolet, Icons.upcoming_rounded),
            tile('Overdue', overdue, _kRed, Icons.warning_amber_rounded),
            tile('Done', done, _kGreen, Icons.check_circle_rounded),
          ]),
        ]),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Quick action card (Academy module-card style)
// ═════════════════════════════════════════════════════════════════════════════
class _ActionData {
  final IconData icon;
  final String title;
  final String sub;
  final Color color;
  final VoidCallback onTap;
  const _ActionData(this.icon, this.title, this.sub, this.color, this.onTap);
}

class _ActionCard extends StatelessWidget {
  final _ActionData data;
  const _ActionCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final c = data.color;
    return _Pressable(
      onTap: data.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _kLine),
          boxShadow: [
            BoxShadow(
              color: c.withValues(alpha: 0.12),
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
                        colors: [_tint(c, 0.25), c],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                      child: Row(children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [_tint(c, 0.22), c],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: c.withValues(alpha: 0.34),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(data.icon, color: Colors.white, size: 25),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(data.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: _kInk)),
                              const SizedBox(height: 2),
                              Text(data.sub,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 12.5, color: _kSlate)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: c.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.arrow_forward_ios_rounded,
                              size: 14, color: _shade(c, 0.1)),
                        ),
                      ]),
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
// Gradient FAB
// ═════════════════════════════════════════════════════════════════════════════
class _GradientFab extends StatelessWidget {
  final VoidCallback onTap;
  const _GradientFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _Pressable(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          gradient: _kHeaderGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _kCyan.withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Shared helpers: press-scale + staggered fade-in
// ═════════════════════════════════════════════════════════════════════════════
class _Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _Pressable({required this.child, required this.onTap});

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 90));
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

class _FadeIn extends StatefulWidget {
  final Widget child;
  final int index;
  const _FadeIn({required this.child, required this.index});

  @override
  State<_FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<_FadeIn> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, .08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 60 + widget.index * 60), () {
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