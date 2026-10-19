import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/models/academy_models/academy_hr_model.dart';
import 'package:pokakbilling/viewmodels/academy/academy_hr_viewmodel.dart';
import 'package:pokakbilling/views/academy/academy_extras.dart';
import 'package:pokakbilling/views/academy/academy_hr_widgets.dart';
import 'package:pokakbilling/views/academy/academy_theme.dart';
import 'package:pokakbilling/views/academy/academy_widgets.dart';
import 'package:pokakbilling/views/academy/hr_submission_detail_screen.dart';

const Map<String, String> _kStatus = {
  'Pending HR': 'submitted',
  'Approved': 'approved',
  'Rejected': 'rejected',
};

// ═════════════════════════════════════════════════════════════════════════════
// Colour scheme (same as Payments / Academy home)
//   • Header / search / filters → Cyan
//   • Top 4 cards               → Blue / Orange / Green / Red
//   • Submission card accent    → by status (hrStatusColor)
// ═════════════════════════════════════════════════════════════════════════════
const Color _kPageBg = Color(0xFFF0FAFD);
const Color _kInk = Color(0xFF0F172A);
const Color _kSlate = Color(0xFF64748B);
const Color _kLine = Color(0xFFD9ECF2);

const Color _kCyan = Color(0xFF06B6D4);
const Color _kCyanLight = Color(0xFF67E8F9);
const Color _kCyanDeep = Color(0xFF0E7490);
const Color _kBlue = Color(0xFF3B82F6);
const Color _kViolet = Color(0xFF8B5CF6);
const Color _kGreen = Color(0xFF16A34A);
const Color _kOrange = Color(0xFFF97316);
const Color _kRed = Color(0xFFEF4444);

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

/// HR view: all counsellor submissions, tap to approve / reject.
class HrSubmissionsScreen extends StatefulWidget {
  const HrSubmissionsScreen({super.key});

  @override
  State<HrSubmissionsScreen> createState() => _HrSubmissionsScreenState();
}

class _HrSubmissionsScreenState extends State<HrSubmissionsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _search = '';
  String? _status; // raw
  String? _counsellor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AcademyHrViewmodel>().fetchSubmissions();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool get _hasFilter =>
      _search.isNotEmpty || _status != null || _counsellor != null;

  void _reset() {
    _searchCtrl.clear();
    setState(() {
      _search = '';
      _status = null;
      _counsellor = null;
    });
  }

  List<AcadSubmission> _apply(List<AcadSubmission> all) {
    final q = _search.trim().toLowerCase();
    return all.where((s) {
      if (_status != null && s.status != _status) return false;
      if (_counsellor != null && s.counsellorName != _counsellor) {
        return false;
      }
      if (q.isEmpty) return true;
      return s.counsellorName.toLowerCase().contains(q) ||
          s.periodLabel.toLowerCase().contains(q) ||
          s.submittedByName.toLowerCase().contains(q);
    }).toList();
  }

  void _open(AcadSubmission s) => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => HrSubmissionDetailScreen(submissionId: s.id)),
      );

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;

    return Consumer<AcademyHrViewmodel>(
      builder: (context, vm, _) {
        final all = vm.submissions;
        final list = _apply(all);
        final counsellors = {...all.map((s) => s.counsellorName)}
            .where((e) => e.isNotEmpty)
            .toList()
          ..sort();
        final statusLabel = _status == null
            ? null
            : _kStatus.entries.firstWhere((e) => e.value == _status).key;

        final stats = <AcadStat>[
          AcadStat('Total', '${all.length}', _kBlue, Icons.assignment_rounded),
          AcadStat('Pending', '${vm.pendingCount}', _kOrange,
              Icons.hourglass_top_rounded),
          AcadStat('Approved', '${vm.approvedCount}', _kGreen,
              Icons.verified_rounded),
          AcadStat('Rejected', '${vm.rejectedCount}', _kRed,
              Icons.cancel_rounded),
        ];

        return Scaffold(
          backgroundColor: _kPageBg,
          body: Column(children: [
            _Header(
              loading: vm.submissionsLoading,
              onRefresh: vm.fetchSubmissions,
            ),
            Expanded(
              child: RefreshIndicator(
                color: _kCyan,
                onRefresh: vm.fetchSubmissions,
                child: vm.submissionsLoading && !vm.submissionsLoaded
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: _kCyan, strokeWidth: 2.5))
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        padding: EdgeInsets.fromLTRB(
                            sw * .04, 18, sw * .04, mq.padding.bottom + 24),
                        children: [
                          if (vm.submissionsError != null)
                            AcadErrorBanner(
                                message: vm.submissionsError!,
                                onRetry: vm.fetchSubmissions),
                          const _SectionLabel(
                              text: 'SUBMISSIONS OVERVIEW', color: _kCyan),
                          const SizedBox(height: 10),
                          _StatsGrid(items: stats),
                          const SizedBox(height: 18),
                          _SearchBar(
                            controller: _searchCtrl,
                            hint: 'Search counsellor, period…',
                            onChanged: (v) => setState(() => _search = v),
                          ),
                          const SizedBox(height: 12),
                          _FilterRow(
                            showReset: _hasFilter,
                            onReset: _reset,
                            filters: [
                              acadPicker(
                                context: context,
                                icon: Icons.flag_rounded,
                                hint: 'Status',
                                title: 'Submission Status',
                                options: _kStatus.keys.toList(),
                                value: statusLabel,
                                onChanged: (v) => setState(() =>
                                    _status = v == null ? null : _kStatus[v]),
                              ),
                              acadPicker(
                                context: context,
                                icon: Icons.support_agent_rounded,
                                hint: 'Counsellor',
                                title: 'Select Counsellor',
                                options: counsellors,
                                value: _counsellor,
                                onChanged: (v) =>
                                    setState(() => _counsellor = v),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          AcadListHeader(
                              title: 'Submissions',
                              count: list.length,
                              color: _kCyan),
                          const SizedBox(height: 10),
                          if (list.isEmpty)
                            _Empty(
                              title: all.isEmpty
                                  ? 'No Submissions Yet'
                                  : 'Nothing Found',
                              subtitle: all.isEmpty
                                  ? 'Submitted conversions will appear here'
                                  : 'Try adjusting your filters',
                            )
                          else
                            ...List.generate(
                              list.length,
                              (i) => AcadFadeIn(
                                key: ValueKey('sub_${list[i].id}'),
                                index: i,
                                child: _SubmissionCard(
                                    s: list[i], onTap: () => _open(list[i])),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ]),
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Header
// ═════════════════════════════════════════════════════════════════════════════
class _Header extends StatelessWidget {
  final bool loading;
  final VoidCallback onRefresh;
  const _Header({required this.loading, required this.onRefresh});

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
          right: 56,
          top: mq.padding.top + 2,
          child: Transform.rotate(
            angle: -0.25,
            child: Icon(Icons.verified_user_rounded,
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
                    const Text('HR Submissions',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('Counsellor conversions for approval',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 14)),
                  ]),
            ),
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
// Top 4 overview cards
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
// Search bar
// ═════════════════════════════════════════════════════════════════════════════
class _SearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  const _SearchBar({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: focused ? _kCyan : _kLine,
          width: focused ? 1.6 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (focused ? _kCyan : _kInk)
                .withValues(alpha: focused ? 0.22 : 0.05),
            blurRadius: focused ? 16 : 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_tint(_kCyan, 0.2), _kCyan],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
              child: Icon(Icons.search_rounded, color: Colors.white, size: 21)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: widget.controller,
            focusNode: _focus,
            onChanged: widget.onChanged,
            cursorColor: _kCyan,
            style: const TextStyle(
                fontSize: 15.5, fontWeight: FontWeight.w500, color: _kInk),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(color: _kSlate, fontSize: 15),
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
                color: _kCyan.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, size: 16, color: _kCyan),
            ),
          ),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Filter row + pills
// ═════════════════════════════════════════════════════════════════════════════
class _FilterRow extends StatelessWidget {
  final List<AcadFilterSpec> filters;
  final bool showReset;
  final VoidCallback onReset;
  const _FilterRow({
    required this.filters,
    required this.showReset,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      for (var i = 0; i < filters.length; i++) ...[
        if (i > 0) const SizedBox(width: 8),
        Expanded(child: _Pill(spec: filters[i])),
      ],
      if (showReset) ...[
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onReset,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _kRed.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(color: _kRed.withValues(alpha: 0.25)),
            ),
            child:
                const Icon(Icons.restart_alt_rounded, size: 20, color: _kRed),
          ),
        ),
      ],
    ]);
  }
}

class _Pill extends StatelessWidget {
  final AcadFilterSpec spec;
  const _Pill({required this.spec});

  @override
  Widget build(BuildContext context) {
    final active = spec.active;
    return GestureDetector(
      onTap: spec.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          gradient: active ? _kMainGradient : null,
          color: active ? null : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: active ? Colors.transparent : _kLine),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: _kCyan.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(children: [
          Icon(spec.icon, size: 15, color: active ? Colors.white : _kCyan),
          const SizedBox(width: 5),
          Expanded(
            child: Text(spec.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : _kInk)),
          ),
          active
              ? GestureDetector(
                  onTap: spec.onClear,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.28),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 12, color: Colors.white),
                  ))
              : const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 18, color: _kSlate),
        ]),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Empty state
// ═════════════════════════════════════════════════════════════════════════════
class _Empty extends StatelessWidget {
  final String title;
  final String subtitle;
  const _Empty({required this.title, required this.subtitle});

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
            child: Icon(Icons.assignment_outlined,
                size: 38, color: _kCyan.withValues(alpha: 0.85)),
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

// ═════════════════════════════════════════════════════════════════════════════
// Submission card (white, status accent bar, tag strip)
// ═════════════════════════════════════════════════════════════════════════════
class _SubmissionCard extends StatelessWidget {
  final AcadSubmission s;
  final VoidCallback onTap;
  const _SubmissionCard({required this.s, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = hrStatusColor(s.status);
    return AcadPressable(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _kLine),
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
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(
                width: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_tint(color, 0.25), color],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 14, 12),
                  child: Column(children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                              colors: [color, _tint(color, 0.35)]),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child:
                              AcademyAvatar(name: s.counsellorName, size: 42),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.counsellorName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: _kInk)),
                              const SizedBox(height: 3),
                              Row(children: [
                                const Icon(Icons.calendar_month_rounded,
                                    size: 13, color: _kCyan),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(s.periodLabel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12.5, color: _kSlate)),
                                ),
                              ]),
                            ]),
                      ),
                      const SizedBox(width: 8),
                      AcadStatusPill(
                          label: hrStatusLabel(s.status), color: color),
                    ]),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
                      decoration: BoxDecoration(
                        color: _kPageBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _kLine),
                      ),
                      child: Row(children: [
                        Expanded(
                          child: Wrap(spacing: 6, runSpacing: 6, children: [
                            AcadMiniTag(
                                text: '${s.summary.newAdmissions} admissions',
                                icon: Icons.school_rounded,
                                color: _kViolet),
                            AcadMiniTag(
                                text: '${s.summary.newRegistrations} reg.',
                                icon: Icons.how_to_reg_rounded,
                                color: _kCyan),
                            AcadMiniTag(
                                text: acadInrShort(s.summary.totalCollected),
                                icon: Icons.savings_rounded,
                                color: _kGreen),
                          ]),
                        ),
                        const SizedBox(width: 6),
                        AcadArrowButton(color: color),
                      ]),
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.person_outline_rounded,
                          size: 14, color: _kSlate),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text('By ${s.submittedByName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _kSlate)),
                      ),
                      Text(acadDate(s.submittedAt),
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _kSlate)),
                    ]),
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