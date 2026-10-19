import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
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
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddMeetingScreen()),
    );
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Meeting scheduled successfully!'),
          backgroundColor: AppColors.c1,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  DateTime? _parseDateTime(String s) {
    if (s.isEmpty) return null;
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDisplay(DateTime? dt) {
    if (dt == null) return '—';
    return DateFormat('dd MMM yyyy • HH:mm').format(dt);
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
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

  // ── BUILD ──────────────────────────────────────────────────────────────────
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
        final total = meetingProv.stats['all'] ?? meetings.length;

        int todayCount = 0,
            upcomingCount = 0,
            completedCount = 0,
            overdueCount = 0;
        for (final m in meetings) {
          final d = _parseDateTime(m.dueDate);
          if (d != null) {
            final dd = DateTime(d.year, d.month, d.day);
            if (_isSameDate(dd, todayOnly))
              todayCount++;
            else if (dd.isAfter(todayOnly))
              upcomingCount++;
            else if (dd.isBefore(todayOnly)) overdueCount++;
          }
          if (m.status.toLowerCase() == 'completed') completedCount++;
        }

        final filtered = meetings.where((m) {
          final q = search.trim().toLowerCase();
          if (q.isNotEmpty &&
              !(m.leadName ?? '').toLowerCase().contains(q) &&
              !(m.title ?? '').toLowerCase().contains(q)) return false;
          final d = _parseDateTime(m.dueDate);
          final isCompleted = m.status.toLowerCase() == 'completed';
          if (selectedTab == 0) return d != null && _isSameDate(d, todayOnly);
          if (selectedTab == 1) return d != null && d.isAfter(todayOnly);
          if (selectedTab == 2) {
            if (!isCompleted) return false;
            if (filterDate != null) {
              final d2 = _parseDateTime(m.dueDate);
              return d2 != null && _isSameDate(d2, filterDate!);
            }
            return true;
          }
          return d != null && d.isBefore(todayOnly);
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.white,
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                // ── Fixed Header ─────────────────────────────────────
                FadeTransition(
                  opacity: _headerFade,
                  child: SlideTransition(
                    position: _headerSlide,
                    child: _buildHeader(
                      context,
                      top,
                      sw,
                      total,
                      todayCount,
                      upcomingCount,
                      overdueCount,
                      completedCount,
                    ),
                  ),
                ),

                // ── Scrollable body ──────────────────────────────────
                Expanded(
                  child: FadeTransition(
                    opacity: _bodyFade,
                    child: SlideTransition(
                      position: _bodySlide,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.cxl,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                          ),
                          child: Column(
                            children: [
                              // Drag handle
                              Container(
                                width: 40,
                                height: 4,
                                margin:
                                    const EdgeInsets.only(top: 12, bottom: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.c1.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),

                              // Filter / search bar
                              _buildFilterBar(
                                context,
                                todayCount,
                                upcomingCount,
                                completedCount,
                                overdueCount,
                                todayOnly,
                              ),

                              // List
                              Expanded(
                                child: meetingProv.getMeetingLoader
                                    ? Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.c1,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : filtered.isEmpty
                                        ? _buildEmptyState()
                                        : ListView.builder(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            padding: const EdgeInsets.fromLTRB(
                                                16, 8, 16, 32),
                                            itemCount: filtered.length,
                                            itemBuilder: (_, i) =>
                                                _AnimatedMeetingCard(
                                              meeting: filtered[i],
                                              leadProv: leadProv,
                                              delay: Duration(
                                                  milliseconds: 40 + i * 60),
                                              onLaunchURL: _launchURL,
                                              onLaunchPhone: _launchPhone,
                                              onLaunchEmail: _launchEmail,
                                              formatDisplay: _formatDisplay,
                                              outerContext: context,
                                            ),
                                          ),
                              ),
                            ],
                          ),
                        ),
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

  // ── Header ─────────────────────────────────────────────────────────────────
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
      padding: EdgeInsets.only(
        top: topPad + 14,
        bottom: 24,
        left: sw * 0.05,
        right: sw * 0.05,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.cborder, width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.cxl,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.cborder),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.c3,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title + count
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Meetings',
                      style: TextStyle(
                        color: AppColors.cdark,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$total total meetings',
                      style: const TextStyle(
                        color: AppColors.ctext,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Add button
              GestureDetector(
                onTap: _navigateToAddMeeting,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.c1,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.c1.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, color: AppColors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Add New',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Stat row — matches FollowUp header stats exactly
          Row(
            children: [
              _headerStat('Today', todayCount, AppColors.c1),
              const SizedBox(width: 8),
              _headerStat('Upcoming', upcomingCount, AppColors.ctext),
              const SizedBox(width: 8),
              _headerStat('Overdue', overdueCount, AppColors.red),
              const SizedBox(width: 8),
              _headerStat('Done', completedCount, AppColors.c1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.20)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: AppColors.ctext.withOpacity(0.70),
                fontSize: 9,
                fontWeight: FontWeight.w500,
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
    int todayCount,
    int upcomingCount,
    int completedCount,
    int overdueCount,
    DateTime todayOnly,
  ) {
    final tabs = [
      _TabData('Today', todayCount),
      _TabData('Upcoming', upcomingCount),
      _TabData('Done', completedCount),
      _TabData('Overdue', overdueCount),
    ];

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          // Tab switcher — solid c1 fill on active (matches FollowUp exactly)
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.cxl,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.cborder),
            ),
            padding: const EdgeInsets.all(3),
            child: Row(
              children: tabs.asMap().entries.map((e) {
                final i = e.key;
                final tab = e.value;
                final isSelected = selectedTab == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      selectedTab = i;
                      filterDate = null;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      decoration: isSelected
                          ? BoxDecoration(
                              color: AppColors.c1,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.c1.withOpacity(0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
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
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.ctext,
                              ),
                            ),
                            Text(
                              '${tab.count}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.ctext.withOpacity(0.60),
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

          // Search + optional date filter
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.cxl,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cborder),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded,
                          size: 16, color: AppColors.ctext),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (v) => setState(() => search = v),
                          cursorColor: AppColors.c1,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.cdark),
                          decoration: InputDecoration(
                            hintText: 'Search meetings…',
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: AppColors.ctext.withOpacity(0.60),
                            ),
                            border: InputBorder.none,
                            isCollapsed: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 0),
                          ),
                        ),
                      ),
                      if (search.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchCtrl.clear();
                            setState(() => search = '');
                          },
                          child: Icon(Icons.close_rounded,
                              size: 14, color: AppColors.c1),
                        ),
                    ],
                  ),
                ),
              ),

              // Date filter — only on Done tab
              if (selectedTab == 2) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: filterDate ?? todayOnly,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (ctx, child) => Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: ColorScheme.light(
                            primary: AppColors.c1,
                            onPrimary: AppColors.white,
                            surface: AppColors.white,
                            onSurface: AppColors.cdark,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) setState(() => filterDate = picked);
                  },
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: filterDate != null
                          ? AppColors.c1.withOpacity(0.10)
                          : AppColors.cxl,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: filterDate != null
                            ? AppColors.c1.withOpacity(0.40)
                            : AppColors.cborder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.date_range_rounded,
                          size: 14,
                          color: filterDate != null
                              ? AppColors.c1
                              : AppColors.ctext,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          filterDate == null
                              ? 'Date'
                              : '${filterDate!.day}/${filterDate!.month}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: filterDate != null
                                ? AppColors.c1
                                : AppColors.ctext,
                          ),
                        ),
                        if (filterDate != null) ...[
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => setState(() => filterDate = null),
                            child: Icon(Icons.close_rounded,
                                size: 12, color: AppColors.c1),
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

  // ── Empty state ────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    const labels = ['Today', 'Upcoming', 'Completed', 'Overdue'];
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.c1.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cborder),
            ),
            child: Icon(
              Icons.event_busy_rounded,
              color: AppColors.c1.withOpacity(0.55),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No ${labels[selectedTab]} Meetings',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.cdark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Nothing scheduled for this filter',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.ctext.withOpacity(0.60),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab data ──────────────────────────────────────────────────────────────────
class _TabData {
  final String label;
  final int count;
  const _TabData(this.label, this.count);
}

// ─── Animated meeting card ─────────────────────────────────────────────────────
class _AnimatedMeetingCard extends StatefulWidget {
  final MeetingModel meeting;
  final LeadViewmodel leadProv;
  final Duration delay;
  final Future<void> Function(String) onLaunchURL;
  final Future<void> Function(String) onLaunchPhone;
  final Future<void> Function(String) onLaunchEmail;
  final String Function(DateTime?) formatDisplay;
  final BuildContext outerContext;

  const _AnimatedMeetingCard({
    required this.meeting,
    required this.leadProv,
    required this.delay,
    required this.onLaunchURL,
    required this.onLaunchPhone,
    required this.onLaunchEmail,
    required this.formatDisplay,
    required this.outerContext,
  });

  @override
  State<_AnimatedMeetingCard> createState() => _AnimatedMeetingCardState();
}

class _AnimatedMeetingCardState extends State<_AnimatedMeetingCard>
    with TickerProviderStateMixin {
  late final AnimationController _entrCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _entrCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 480));
    _fade = CurvedAnimation(parent: _entrCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entrCtrl, curve: Curves.easeOut));
    _scale = Tween<double>(begin: 0.95, end: 1.0)
        .animate(CurvedAnimation(parent: _entrCtrl, curve: Curves.easeOutBack));

    _pressCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        lowerBound: 0,
        upperBound: 1);
    _pressScale = Tween<double>(begin: 1.0, end: 0.97).animate(_pressCtrl);

    Future.delayed(widget.delay, () {
      if (mounted) _entrCtrl.forward();
    });
  }

  @override
  void dispose() {
    _entrCtrl.dispose();
    _pressCtrl.dispose();
    super.dispose();
  }

  DateTime? _parseDateTime(String s) {
    if (s.isEmpty) return null;
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.meeting;
    final lProv = widget.leadProv;

    // Find linked lead
    LeadModel? linkedLead;
    for (final l in lProv.leadList) {
      if (l.id == m.lead || l.leadId == m.lead.toString()) {
        linkedLead = l;
        break;
      }
    }
    if (linkedLead == null && (m.leadName ?? '').isNotEmpty) {
      for (final l in lProv.leadList) {
        if (l.name.toLowerCase() == m.leadName!.toLowerCase()) {
          linkedLead = l;
          break;
        }
      }
    }

    final title = m.title.isNotEmpty ? m.title : 'Product Demo';
    final organiser = m.leadName ?? linkedLead?.name ?? 'Lead';
    final assignedTo = m.assignedToName ?? '';
    final location = m.location ?? '';
    final description = m.description ?? '';
    final isCompleted = m.status.toLowerCase() == 'completed';
    final phone = m.phone.isNotEmpty ? m.phone : linkedLead?.phone ?? '';
    final email = linkedLead?.email ?? '';
    final dateTime = _parseDateTime(m.dueDate);
    final dateTimeStr = widget.formatDisplay(dateTime);
    final initials = organiser.isNotEmpty ? organiser[0].toUpperCase() : 'M';

    String meetingLink = '';
    final locTrim = location.trim();
    if (locTrim.startsWith('http') || locTrim.startsWith('www.')) {
      meetingLink = locTrim;
    }

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(
          scale: _scale,
          child: GestureDetector(
            onTapDown: (_) => _pressCtrl.forward(),
            onTapUp: (_) => _pressCtrl.reverse(),
            onTapCancel: () => _pressCtrl.reverse(),
            child: ScaleTransition(
              scale: _pressScale,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCompleted
                        ? AppColors.c1.withOpacity(0.40)
                        : AppColors.c1.withOpacity(0.15),
                    width: isCompleted ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isCompleted
                          ? AppColors.c1.withOpacity(0.12)
                          : AppColors.c1.withOpacity(0.07),
                      blurRadius: isCompleted ? 16 : 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top accent bar — c1 solid (matches FollowUp card)
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.c1,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar + title + status badge
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar circle
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppColors.c1.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    initials,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.c1,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Title + organiser + assigned
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.cdark,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      organiser,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            AppColors.ctext.withOpacity(0.70),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (assignedTo.isNotEmpty) ...[
                                      Text(
                                        'Assigned: $assignedTo',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color:
                                              AppColors.ctext.withOpacity(0.50),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Status badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? AppColors.c1.withOpacity(0.10)
                                      : AppColors.red.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isCompleted
                                        ? AppColors.c1.withOpacity(0.30)
                                        : AppColors.red.withOpacity(0.30),
                                  ),
                                ),
                                child: Text(
                                  m.statusDisplay,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: isCompleted
                                        ? AppColors.c1
                                        : AppColors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.c1.withOpacity(0.10),
                          ),
                          const SizedBox(height: 10),

                          // Date + join button
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: AppColors.c1,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  dateTimeStr,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.cdark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (meetingLink.isNotEmpty)
                                GestureDetector(
                                  onTap: () => widget.onLaunchURL(meetingLink),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppColors.c1,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.c1.withOpacity(0.25),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.videocam_rounded,
                                            size: 12, color: AppColors.white),
                                        SizedBox(width: 4),
                                        Text(
                                          'JOIN',
                                          style: TextStyle(
                                            color: AppColors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          // Physical location
                          if (location.isNotEmpty && meetingLink.isEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    size: 12, color: AppColors.c1),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    location,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.ctext.withOpacity(0.70),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // Description
                          if (description.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.ctext.withOpacity(0.55),
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],

                          const SizedBox(height: 12),

                          // Action row
                          Row(
                            children: [
                              if (phone.isNotEmpty) ...[
                                _ActionBtn(
                                  icon: Icons.call_rounded,
                                  label: 'Call',
                                  color: AppColors.c1,
                                  onTap: () => widget.onLaunchPhone(phone),
                                ),
                                const SizedBox(width: 6),
                              ],
                              if (email.isNotEmpty) ...[
                                _ActionBtn(
                                  icon: Icons.email_rounded,
                                  label: 'Email',
                                  color: AppColors.cdark,
                                  onTap: () => widget.onLaunchEmail(email),
                                ),
                                const SizedBox(width: 6),
                              ],
                              const Spacer(),
                              // View Lead
                              GestureDetector(
                                onTap: () {
                                  if (linkedLead == null) {
                                    ScaffoldMessenger.of(widget.outerContext)
                                        .showSnackBar(
                                      SnackBar(
                                        content: const Text('Lead not found'),
                                        backgroundColor: AppColors.c1,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    );
                                    return;
                                  }
                                  Navigator.push(
                                    widget.outerContext,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          LeadsViewScreen(lead: linkedLead!),
                                    ),
                                  );
                                },
                                child: Text(
                                  'View Lead →',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.c1,
                                    fontWeight: FontWeight.w700,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Small action button (matches FollowUp _ActionBtn exactly) ─────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.20)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
