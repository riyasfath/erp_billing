
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

// ── Avatar gradient palette (shared with CustomerMain) ────────────────────────
const List<List<Color>> _kAvatarGradients = [
  [Color(0xFF6366F1), Color(0xFF818CF8)],
  [Color(0xFF06B6D4), Color(0xFF38BDF8)],
  [Color(0xFF10B981), Color(0xFF34D399)],
  [Color(0xFFF59E0B), Color(0xFFFBBF24)],
  [Color(0xFFEF4444), Color(0xFFFCA5A5)],
  [Color(0xFFA855F7), Color(0xFFD8B4FE)],
];

class DailyActivityScreen extends StatefulWidget {
  const DailyActivityScreen({super.key});

  @override
  State<DailyActivityScreen> createState() => _DailyActivityScreenState();
}

class _DailyActivityScreenState extends State<DailyActivityScreen>
    with TickerProviderStateMixin {
  late TabController _tab;

  late AnimationController _entryCtrl;
  late Animation<double> _fadeA;
  late Animation<Offset> _slideA;

  final List<_Act> _acts = [
    const _Act('Called Rajan Enterprises', '10:00 AM', Icons.phone_in_talk_rounded,
        'Follow Up', Color(0xFF6366F1), true),
    const _Act('Meeting – Product Demo Q2', '1:30 PM', Icons.videocam_rounded,
        'Meeting', Color(0xFF10B981), true),
    const _Act('Quotation #QT-2048 sent', '3:00 PM', Icons.description_rounded,
        'Quotation', Color(0xFFF59E0B), false),
    const _Act('New Lead – XYZ Corp', '4:15 PM', Icons.person_add_rounded, 'Lead',
        Color(0xFFA855F7), false),
    const _Act('Reminder: Team Sync', '5:00 PM', Icons.alarm_rounded, 'Reminder',
        Color(0xFF06B6D4), false),
  ];

  // ── Theme-aware getters — same pattern as CustomerMain ────────────────────
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bg => Theme.of(context).scaffoldBackgroundColor;
  Color get _appBarBg => _bg;
  Color get _fg => _isDark ? Colors.white : const Color(0xFF1E1B4B);
  Color get _fgMuted => _isDark
      ? Colors.white.withValues(alpha: 0.55)
      : const Color(0xFF1E1B4B).withValues(alpha: 0.5);
  Color get _cardBg =>
      _isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white.withValues(alpha: 0.85);
  Color get _cardBorder => _isDark
      ? Colors.white.withValues(alpha: 0.12)
      : const Color(0xFF6366F1).withValues(alpha: 0.15);
  Color get _iconBg => _isDark
      ? Colors.white.withValues(alpha: 0.12)
      : const Color(0xFF6366F1).withValues(alpha: 0.10);
  Color get _iconColor => _isDark ? Colors.white : const Color(0xFF4338CA);
  Color get _inputFill => _isDark
      ? Colors.white.withValues(alpha: 0.08)
      : const Color(0xFF6366F1).withValues(alpha: 0.06);
  Color get _inputBorder => _isDark
      ? Colors.white.withValues(alpha: 0.15)
      : const Color(0xFF6366F1).withValues(alpha: 0.2);
  // ──────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeA = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideA = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _tab.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final done = _acts.where((a) => a.done).length;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _fadeA,
          child: SlideTransition(
            position: _slideA,
            child: Column(
              children: [
                _buildAppBar(),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tab,
                    children: [
                      _todayTab(done),
                      _emptyState('No activities this week yet.'),
                      _emptyState('No historical records found.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── APP BAR ───────────────────────────────────────────────────────────────
  Widget _buildAppBar() => Container(
        color: _appBarBg,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.event_note_rounded, color: _iconColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Daily Organizer',
                    style: TextStyle(
                        color: _fg, fontSize: 16, fontWeight: FontWeight.w800)),
                Text("Track your day's tasks & events",
                    style: TextStyle(color: _fgMuted, fontSize: 10.5)),
              ],
            ),
          ),
          // Add Activity — gradient button (same pattern as CustomerMain)
          // GestureDetector(
          //   onTap: () {},
          //   child: Container(
          //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          //     decoration: BoxDecoration(
          //       gradient: const LinearGradient(
          //         colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
          //         begin: Alignment.topLeft,
          //         end: Alignment.bottomRight,
          //       ),
          //       borderRadius: BorderRadius.circular(10),
          //       boxShadow: [
          //         BoxShadow(
          //           color: const Color(0xFF6366F1).withOpacity(0.35),
          //           blurRadius: 8,
          //           offset: const Offset(0, 3),
          //         ),
          //       ],
          //     ),
          //     child: const Row(mainAxisSize: MainAxisSize.min, children: [
          //       Icon(Icons.add_rounded, color: Colors.white, size: 15),
          //       SizedBox(width: 5),
          //       Text('Add Activity',
          //           style: TextStyle(
          //               color: Colors.white,
          //               fontSize: 11.5,
          //               fontWeight: FontWeight.w700)),
          //     ]),
          //   ),
          // ),
        ]),
      );

  // ── TAB BAR ───────────────────────────────────────────────────────────────
  Widget _buildTabBar() => Container(
        color: _appBarBg,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: _inputFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _inputBorder, width: 1),
          ),
          child: TabBar(
            controller: _tab,
            labelColor: Colors.white,
            unselectedLabelColor: _fgMuted,
            indicator: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.all(3),
            dividerColor: Colors.transparent,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            tabs: const [
              Tab(text: 'Today'),
              Tab(text: 'This Week'),
              Tab(text: 'History'),
            ],
          ),
        ),
      );

  // ── TODAY TAB ─────────────────────────────────────────────────────────────
  Widget _todayTab(int done) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 40),
      children: [
        // Summary cards
        Row(children: [
          _sumCard('Done', '$done', const Color(0xFF10B981)),
          const SizedBox(width: 10),
          _sumCard(
              'Pending', '${_acts.length - done}', const Color(0xFFF59E0B)),
          const SizedBox(width: 10),
          _sumCard('Total', '${_acts.length}', const Color(0xFF6366F1)),
        ]),
        const SizedBox(height: 12),

        // Progress card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _cardBorder, width: 1),
            boxShadow: _isDark
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            children: [
              // Top accent strip
              Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Daily Progress',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 12, color: _fg)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${((done / _acts.length) * 100).round()}% Complete',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        color: Colors.white),
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: done / _acts.length,
                  backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.15),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                  minHeight: 7,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Section label
        Text('Activity Log',
            style: TextStyle(
                fontWeight: FontWeight.w800, fontSize: 13, color: _fg)),
        const SizedBox(height: 8),

        // Activity cards
        ...List.generate(_acts.length, (i) {
          final a = _acts[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: a.color.withValues(alpha: 0.2), width: 1),
              boxShadow: _isDark
                  ? null
                  : [
                      BoxShadow(
                        color: a.color.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Column(
              children: [
                // Top accent strip (same as CustomerMain card)
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: a.color.withValues(alpha: a.done ? 0.3 : 1.0),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Row(children: [
                    // Icon container (same style as CustomerMain avatar)
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: a.done
                              ? [
                                  a.color.withValues(alpha: 0.4),
                                  a.color.withValues(alpha: 0.25)
                                ]
                              : [
                                  a.color,
                                  a.color.withValues(alpha: 0.75),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(a.icon, color: Colors.white, size: 19),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                              color: a.done ? _fgMuted : _fg,
                              decoration:
                                  a.done ? TextDecoration.lineThrough : null,
                              decorationColor: _fgMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(children: [
                            Icon(Icons.access_time_filled_rounded,
                                size: 10, color: _fgMuted),
                            const SizedBox(width: 3),
                            Text(a.time,
                                style:
                                    TextStyle(fontSize: 10, color: _fgMuted)),
                            const SizedBox(width: 8),
                            // Type badge (same pattern as CustomerMain)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: a.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: a.color.withValues(alpha: 0.3), width: 1),
                              ),
                              child: Text(a.type,
                                  style: TextStyle(
                                      fontSize: 9.5,
                                      color: a.color,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status icon
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: a.done
                            ? const Color(0xFF10B981).withValues(alpha: 0.12)
                            : _iconBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: a.done
                              ? const Color(0xFF10B981).withValues(alpha: 0.3)
                              : _cardBorder,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        a.done
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: a.done ? const Color(0xFF10B981) : _fgMuted,
                        size: 18,
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ── SUMMARY CARD ──────────────────────────────────────────────────────────
  Widget _sumCard(String label, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
          boxShadow: _isDark
              ? null
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(children: [
          // Small color accent line on top
          Container(
            height: 3,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Text(val,
              style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 22, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: _fgMuted, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  // ── EMPTY STATE (same pattern as CustomerMain) ────────────────────────────
  Widget _emptyState(String msg) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _iconBg,
              shape: BoxShape.circle,
              border: Border.all(color: _cardBorder, width: 1),
            ),
            child: Icon(Icons.event_note_rounded, color: _fgMuted, size: 28),
          ),
          const SizedBox(height: 14),
          Text('Nothing here yet.',
              style: TextStyle(
                  color: _fgMuted, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(msg,
              style: TextStyle(color: _fgMuted.withValues(alpha: 0.6), fontSize: 11)),
        ]),
      );
}

// ── Activity data model ───────────────────────────────────────────────────────
class _Act {
  final String title, time, type;
  final IconData icon;
  final Color color;
  final bool done;
  const _Act(
      this.title, this.time, this.icon, this.type, this.color, this.done);
}
