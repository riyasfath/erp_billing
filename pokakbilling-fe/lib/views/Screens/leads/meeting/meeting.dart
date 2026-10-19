import 'package:flutter/material.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pokakbilling/viewmodels/meeting_viewmodel.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/models/data-models/meeting_model.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';
import 'package:pokakbilling/views/Screens/leads/meeting/addmeetingscreen.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leadsviewscreen.dart';

class MeetingScreen extends StatefulWidget {
  const MeetingScreen({super.key});

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen>
    with TickerProviderStateMixin {
  int selectedTab = 0;
  String search = '';
  DateTime? filterDate;

  late final AnimationController _headerCtrl;
  late final AnimationController _bodyCtrl;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _bodyFade;
  late final Animation<Offset> _bodySlide;

  final TextEditingController _searchCtrl = TextEditingController();

  static const _tabColors = [
    ErpColors.cyan,
    ErpColors.blue,
    ErpColors.violet,
    ErpColors.green,
    ErpColors.red,
  ];

  @override
  void initState() {
    super.initState();

    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
            begin: const Offset(0, -0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));

    _bodyCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    _bodyFade = CurvedAnimation(parent: _bodyCtrl, curve: Curves.easeOut);
    _bodySlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _bodyCtrl, curve: Curves.easeOut));

    _headerCtrl.forward();
    Future.delayed(
        const Duration(milliseconds: 200), () => _bodyCtrl.forward());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MeetingViewmodel>(context, listen: false).getAllMeetings();
    });
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _bodyCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _navigateToAddMeeting() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const AddMeetingScreen()));
  }

  // ── Date helpers ──────────────────────────────────────────────────────────
  DateTime? _parseDate(String? s) {
    if (s == null || s.trim().isEmpty) return null;
    try {
      return DateTime.parse(s);
    } catch (_) {}
    try {
      final parts = s.split(RegExp(r'[-/\s]'));
      if (parts.length == 3) {
        if (parts[0].length == 4) {
          return DateTime(int.tryParse(parts[0]) ?? 1970,
              int.tryParse(parts[1]) ?? 1, int.tryParse(parts[2]) ?? 1);
        } else {
          return DateTime(int.tryParse(parts[2]) ?? 1970,
              int.tryParse(parts[1]) ?? 1, int.tryParse(parts[0]) ?? 1);
        }
      }
    } catch (_) {}
    return null;
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDisplay(String date, String time) {
    final d = _parseDate(date);
    if (d == null) return '—';
    final dateStr =
        '${d.day.toString().padLeft(2, '0')} ${_monthAbbr(d.month)} ${d.year}';
    return time.isNotEmpty ? '$dateStr • $time' : dateStr;
  }

  String _monthAbbr(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[m - 1];
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Consumer2<MeetingViewmodel, LeadViewmodel>(
      builder: (context, meetingProv, leadProv, _) {
        final mq = MediaQuery.of(context);
        final top = mq.padding.top;
        final sw = mq.size.width;
        final now = DateTime.now();
        final todayOnly = DateTime(now.year, now.month, now.day);
        final meetings = meetingProv.meetingList;

        int todayCount = 0,
            upcomingCount = 0,
            completedCount = 0,
            overdueCount = 0;
        for (final m in meetings) {
          final d = _parseDate(m.date);
          final isCompleted = m.status.toLowerCase() == 'completed';
          if (isCompleted) completedCount++;
          if (d != null) {
            final dd = DateTime(d.year, d.month, d.day);
            if (_isSameDate(dd, todayOnly)) {
              todayCount++;
            } else if (dd.isAfter(todayOnly) && !isCompleted) {
              upcomingCount++;
            } else if (dd.isBefore(todayOnly) && !isCompleted) {
              overdueCount++;
            }
          }
        }

        final filtered = meetings.where((m) {
          final q = search.trim().toLowerCase();
          if (q.isNotEmpty &&
              !m.leadName.toLowerCase().contains(q) &&
              !m.title.toLowerCase().contains(q)) {
            return false;
          }
          final d = _parseDate(m.date);
          final isCompleted = m.status.toLowerCase() == 'completed';
          if (selectedTab == 0) return true; // All
          if (selectedTab == 1) {
            return d != null && _isSameDate(d, todayOnly); // Today
          }
          if (selectedTab == 2) {
            return d != null &&
                d.isAfter(todayOnly) &&
                !isCompleted; // Upcoming
          }
          if (selectedTab == 3) {
            // Done
            if (!isCompleted) return false;
            if (filterDate != null) {
              return d != null && _isSameDate(d, filterDate!);
            }
            return true;
          }
          return d != null && d.isBefore(todayOnly) && !isCompleted; // Overdue
        }).toList();

        return Scaffold(
          backgroundColor: ErpColors.pageBg,
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                // ── Fixed Header ─────────────────────────────────────────
                FadeTransition(
                  opacity: _headerFade,
                  child: SlideTransition(
                    position: _headerSlide,
                    child: _buildHeader(
                      context,
                      top,
                      sw,
                      meetings.length,
                      todayCount,
                      upcomingCount,
                      overdueCount,
                      completedCount,
                    ),
                  ),
                ),

                // ── Scrollable body ───────────────────────────────────────
                Expanded(
                  child: FadeTransition(
                    opacity: _bodyFade,
                    child: SlideTransition(
                      position: _bodySlide,
                      child: Column(
                        children: [
                          _buildFilterBar(
                            context,
                            meetings.length,
                            todayCount,
                            upcomingCount,
                            completedCount,
                            overdueCount,
                            todayOnly,
                          ),
                          Expanded(
                            child: meetingProv.getMeetingLoader
                                ? const Center(
                                    child: SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                        color: ErpColors.cyan,
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                  )
                                : filtered.isEmpty
                                    ? _buildEmptyState()
                                    : ListView.builder(
                                        physics: const BouncingScrollPhysics(),
                                        padding: EdgeInsets.fromLTRB(
                                            sw * 0.04, 6, sw * 0.04, 32),
                                        itemCount: filtered.length,
                                        itemBuilder: (_, i) => ErpFadeIn(
                                          key: ValueKey(
                                              '${filtered[i].meetingId}_${filtered[i].status}'),
                                          index: i < 10 ? i : 10,
                                          child: _MeetingCard(
                                            meeting: filtered[i],
                                            leadProv: leadProv,
                                            onLaunchURL: _launchURL,
                                            onLaunchPhone: _launchPhone,
                                            onLaunchEmail: _launchEmail,
                                            formatDisplay: _formatDisplay,
                                            outerContext: context,
                                          ),
                                        ),
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(
    BuildContext context,
    double topPad,
    double sw,
    int total,
    int todayCount,
    int upcomingCount,
    int overdueCount,
    int completedCount,
  ) {
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
      child: Stack(
        children: [
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
            right: 110,
            top: topPad + 4,
            child: Transform.rotate(
              angle: -0.25,
              child: Icon(Icons.video_camera_front_rounded,
                  size: 86, color: Colors.white.withValues(alpha: 0.12)),
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
              top: topPad + 12,
              bottom: 20,
              left: sw * 0.045,
              right: sw * 0.045,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ErpPressable(
                      onTap: () => Navigator.of(context).pop(),
                      child: const ErpGlassCircle(
                          icon: Icons.arrow_back_ios_new_rounded,
                          iconSize: 19),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Meetings',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$total total meetings',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ErpPressable(
                      onTap: _navigateToAddMeeting,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: ErpColors.cyanDeep.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_rounded,
                                color: ErpColors.cyanDeep, size: 18),
                            SizedBox(width: 4),
                            Text(
                              'Add New',
                              style: TextStyle(
                                color: ErpColors.cyanDeep,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _headerStat('Today', todayCount, Icons.today_rounded),
                    const SizedBox(width: 8),
                    _headerStat(
                        'Upcoming', upcomingCount, Icons.upcoming_rounded),
                    const SizedBox(width: 8),
                    _headerStat('Overdue', overdueCount,
                        Icons.warning_amber_rounded),
                    const SizedBox(width: 8),
                    _headerStat(
                        'Done', completedCount, Icons.check_circle_rounded),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String label, int count, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.9)),
            const SizedBox(height: 3),
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.88),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Filter bar ─────────────────────────────────────────────────────────────
  Widget _buildFilterBar(
    BuildContext context,
    int totalCount,
    int todayCount,
    int upcomingCount,
    int completedCount,
    int overdueCount,
    DateTime todayOnly,
  ) {
    final tabs = [
      _TabData('All', totalCount),
      _TabData('Today', todayCount),
      _TabData('Upcoming', upcomingCount),
      _TabData('Done', completedCount),
      _TabData('Overdue', overdueCount),
    ];
    final sw = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.fromLTRB(sw * 0.04, 16, sw * 0.04, 10),
      child: Column(
        children: [
          // ── Segmented tabs ──────────────────────────────────────────────
          Container(
            height: 52,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: ErpColors.line),
              boxShadow: [
                BoxShadow(
                  color: ErpColors.cyan.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: tabs.asMap().entries.map((e) {
                final i = e.key;
                final tab = e.value;
                final isSelected = selectedTab == i;
                final c = _tabColors[i];
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() {
                      selectedTab = i;
                      filterDate = null;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      decoration: isSelected
                          ? BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [ErpColors.tint(c, 0.2), c],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: c.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            )
                          : null,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              tab.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? Colors.white
                                    : ErpColors.slate,
                              ),
                            ),
                            Text(
                              '${tab.count}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: isSelected
                                    ? Colors.white
                                    : ErpColors.shade(c, 0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),

          // ── Search + date ───────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ErpColors.line),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: ErpColors.cyan.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(Icons.search_rounded,
                            size: 17, color: ErpColors.cyanDeep),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (v) => setState(() => search = v),
                          cursorColor: ErpColors.cyan,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ErpColors.ink),
                          decoration: InputDecoration(
                            hintText: 'Search meetings…',
                            hintStyle: TextStyle(
                              fontSize: 13.5,
                              color: ErpColors.slate.withValues(alpha: 0.7),
                            ),
                            border: InputBorder.none,
                            isCollapsed: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 0),
                          ),
                        ),
                      ),
                      if (search.isNotEmpty)
                        ErpPressable(
                          onTap: () {
                            _searchCtrl.clear();
                            setState(() => search = '');
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: ErpColors.slate.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded,
                                size: 14, color: ErpColors.slate),
                          ),
                        ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              ),

              // Date filter — only on Done tab (index 3)
              if (selectedTab == 3) ...[
                const SizedBox(width: 8),
                ErpPressable(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: filterDate ?? todayOnly,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (ctx, child) =>
                          erpPickerTheme(ctx, child, color: ErpColors.green),
                    );
                    if (picked != null) setState(() => filterDate = picked);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      gradient: filterDate != null
                          ? LinearGradient(colors: [
                              ErpColors.tint(ErpColors.green, 0.2),
                              ErpColors.green
                            ])
                          : null,
                      color: filterDate != null ? null : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: filterDate != null
                            ? Colors.transparent
                            : ErpColors.line,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.date_range_rounded,
                            size: 17,
                            color: filterDate != null
                                ? Colors.white
                                : ErpColors.cyanDeep),
                        const SizedBox(width: 6),
                        Text(
                          filterDate == null
                              ? 'Date'
                              : '${filterDate!.day}/${filterDate!.month}',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: filterDate != null
                                ? Colors.white
                                : ErpColors.cyanDeep,
                          ),
                        ),
                        if (filterDate != null) ...[
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => setState(() => filterDate = null),
                            child: const Icon(Icons.close_rounded,
                                size: 14, color: Colors.white),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    const labels = ['', 'Today', 'Upcoming', 'Completed', 'Overdue'];
    final label =
        selectedTab == 0 ? 'Meetings' : '${labels[selectedTab]} Meetings';
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(top: 50, bottom: 30),
        child: ErpEmptyState(
          icon: Icons.event_busy_rounded,
          title: 'No $label',
          subtitle: 'Nothing scheduled for this filter',
          color: _tabColors[selectedTab],
          actionLabel: 'Schedule a meeting',
          actionIcon: Icons.add_rounded,
          onAction: _navigateToAddMeeting,
        ),
      ),
    );
  }
}

// ─── Tab data ─────────────────────────────────────────────────────────────────
class _TabData {
  final String label;
  final int count;
  const _TabData(this.label, this.count);
}

// ─── Meeting card ─────────────────────────────────────────────────────────────
class _MeetingCard extends StatelessWidget {
  final MeetingModel meeting;
  final LeadViewmodel leadProv;
  final Future<void> Function(String) onLaunchURL;
  final Future<void> Function(String) onLaunchPhone;
  final Future<void> Function(String) onLaunchEmail;
  final String Function(String date, String time) formatDisplay;
  final BuildContext outerContext;

  const _MeetingCard({
    required this.meeting,
    required this.leadProv,
    required this.onLaunchURL,
    required this.onLaunchPhone,
    required this.onLaunchEmail,
    required this.formatDisplay,
    required this.outerContext,
  });

  @override
  Widget build(BuildContext context) {
    final m = meeting;

    // Find linked lead using ERP's leadId (int)
    LeadModel? linkedLead;
    for (final l in leadProv.leadList) {
      if (l.leadId == m.leadId) {
        linkedLead = l;
        break;
      }
    }
    if (linkedLead == null && m.leadName.isNotEmpty) {
      for (final l in leadProv.leadList) {
        if (l.name.toLowerCase() == m.leadName.toLowerCase()) {
          linkedLead = l;
          break;
        }
      }
    }

    final title = m.title.isNotEmpty ? m.title : 'Meeting';
    final organiser = m.leadName.isNotEmpty ? m.leadName : 'Lead';
    final location = (m.meetingPlace ?? '').trim();
    final description = (m.description ?? '').trim();
    final isCompleted = m.status.toLowerCase() == 'completed';
    // ERP: phone from meeting.phone or linked lead
    final phone = m.phone.isNotEmpty ? m.phone : (linkedLead?.phone ?? '');
    // ERP: LeadModel uses emailId not email
    final email = linkedLead?.emailId ?? '';
    final dateTimeStr = formatDisplay(m.date, m.time);
    final initials = organiser.isNotEmpty ? organiser[0].toUpperCase() : 'M';

    final hasLink = location.startsWith('http') || location.startsWith('www.');
    final accent = isCompleted ? ErpColors.green : ErpColors.blue;
    final avatarColor =
        ErpColors.rotation[organiser.hashCode.abs() % ErpColors.rotation.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isCompleted
              ? ErpColors.green.withValues(alpha: 0.35)
              : ErpColors.line,
          width: isCompleted ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top accent bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [ErpColors.tint(accent, 0.3), accent]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Avatar + title + status ───────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ErpColors.tint(avatarColor, 0.22),
                            avatarColor
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: avatarColor.withValues(alpha: 0.32),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: ErpColors.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(children: [
                            const Icon(Icons.person_rounded,
                                size: 13, color: ErpColors.slate),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                organiser,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: ErpColors.slate,
                                ),
                              ),
                            ),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    ErpStatusChip(
                      label: isCompleted ? 'Completed' : 'Scheduled',
                      color: isCompleted ? ErpColors.green : ErpColors.blue,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Date / place / description box ────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ErpColors.blue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: ErpColors.blue.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const ErpGradientTile(
                              icon: Icons.schedule_rounded,
                              color: ErpColors.blue,
                              size: 32),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              dateTimeStr,
                              style: const TextStyle(
                                fontSize: 13,
                                color: ErpColors.ink,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (hasLink)
                            ErpPressable(
                              onTap: () => onLaunchURL(location),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      ErpColors.tint(ErpColors.blue, 0.2),
                                      ErpColors.blue
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          ErpColors.blue.withValues(alpha: 0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.videocam_rounded,
                                        size: 14, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text(
                                      'JOIN',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Physical location
                      if (location.isNotEmpty && !hasLink) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                size: 15, color: ErpColors.orange),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: ErpColors.slate,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Description
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: ErpColors.slate,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Action row ────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            if (phone.isNotEmpty) ...[
                              _ActionBtn(
                                icon: Icons.call_rounded,
                                label: 'Call',
                                color: ErpColors.cyan,
                                onTap: () => onLaunchPhone(phone),
                              ),
                              const SizedBox(width: 6),
                            ],
                            if (email.isNotEmpty) ...[
                              _ActionBtn(
                                icon: Icons.email_rounded,
                                label: 'Email',
                                color: ErpColors.violet,
                                onTap: () => onLaunchEmail(email),
                              ),
                              const SizedBox(width: 6),
                            ],
                            // Mark Complete
                            if (!isCompleted)
                              _ActionBtn(
                                icon: Icons.check_rounded,
                                label: 'Mark Done',
                                color: ErpColors.green,
                                filled: true,
                                onTap: () async {
                                  final vm = Provider.of<MeetingViewmodel>(
                                      outerContext,
                                      listen: false);
                                  await vm.updateMeeting(
                                      m.meetingId, {'status': 'completed'});
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // View Lead
                    ErpPressable(
                      onTap: () {
                        if (linkedLead == null) {
                          erpToast(outerContext, 'Lead not found',
                              color: ErpColors.cyanDeep,
                              icon: Icons.info_outline_rounded);
                          return;
                        }
                        Navigator.push(
                          outerContext,
                          MaterialPageRoute(
                            builder: (_) => LeadsViewScreen(lead: linkedLead!),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: ErpColors.cyan.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View Lead',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: ErpColors.cyanDeep,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.arrow_forward_rounded,
                                size: 13, color: ErpColors.cyanDeep),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Small action button ──────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return ErpPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          gradient: filled
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [ErpColors.tint(color, 0.2), color],
                )
              : null,
          color: filled ? null : color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
          border:
              filled ? null : Border.all(color: color.withValues(alpha: 0.25)),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.32),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : const [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            erpIcon(icon, size: 14, color: filled ? Colors.white : color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: filled ? Colors.white : ErpColors.shade(color, 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}