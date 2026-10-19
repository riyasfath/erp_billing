import 'package:flutter/material.dart';
import 'package:pokakbilling/models/academy_models/academy_model.dart';
import 'package:pokakbilling/views/academy/academy_theme.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/viewmodels/academy/academy_viewmodel.dart';
import 'package:pokakbilling/views/academy/academy_detail_screen.dart';
import 'package:pokakbilling/views/academy/academy_extras.dart';
import 'package:pokakbilling/views/academy/academy_widgets.dart';

// ═════════════════════════════════════════════════════════════════════════════
// Colour scheme (same as Payments / Academy home)
//   • Header / search / filters → Cyan
//   • Top 4 cards               → Violet / Green / Orange / Pink
//   • Student card accent       → Paid = Violet, No payment = Orange
// ═════════════════════════════════════════════════════════════════════════════
const Color _kPageBg = Color(0xFFF0FAFD);
const Color _kInk = Color(0xFF0F172A);
const Color _kSlate = Color(0xFF64748B);
const Color _kLine = Color(0xFFD9ECF2);

const Color _kCyan = Color(0xFF06B6D4);
const Color _kCyanLight = Color(0xFF67E8F9);
const Color _kCyanDeep = Color(0xFF0E7490);
const Color _kViolet = Color(0xFF8B5CF6);
const Color _kGreen = Color(0xFF16A34A);
const Color _kOrange = Color(0xFFF97316);
const Color _kPink = Color(0xFFEC4899);
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

/// Students who have taken admission.
class AdmissionScreen extends StatefulWidget {
  const AdmissionScreen({super.key});

  @override
  State<AdmissionScreen> createState() => _AdmissionScreenState();
}

class _AdmissionScreenState extends State<AdmissionScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _search = '';
  String? _course;
  String? _counsellor;
  String? _payment; // 'Paid' | 'No Payment'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<AcademyViewmodel>();
      if (!vm.loaded) vm.fetchAll();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool get _hasFilter =>
      _search.isNotEmpty ||
      _course != null ||
      _counsellor != null ||
      _payment != null;

  void _reset() {
    _searchCtrl.clear();
    setState(() {
      _search = '';
      _course = null;
      _counsellor = null;
      _payment = null;
    });
  }

  List<AcadAdmission> _apply(List<AcadAdmission> all) {
    final q = _search.trim().toLowerCase();
    return all.where((a) {
      if (_course != null && a.course != _course) return false;
      if (_counsellor != null && a.counsellor != _counsellor) return false;
      if (_payment == 'Paid' && !a.hasPayment) return false;
      if (_payment == 'No Payment' && a.hasPayment) return false;
      if (q.isEmpty) return true;
      return a.name.toLowerCase().contains(q) ||
          a.phone.toLowerCase().contains(q) ||
          a.email.toLowerCase().contains(q) ||
          a.studentId.toLowerCase().contains(q);
    }).toList();
  }

  void _open(AcadAdmission a) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AcademyDetailScreen.admission(a)),
      );

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;

    return Consumer<AcademyViewmodel>(
      builder: (context, vm, _) {
        final all = vm.admissions;
        final list = _apply(all);
        final paid = all.where((a) => a.hasPayment).length;
        final courses = AcademyViewmodel.distinct(all.map((a) => a.course));
        final counsellors =
            AcademyViewmodel.distinct(all.map((a) => a.counsellor));

        final stats = <AcadStat>[
          AcadStat('Admitted', '${all.length}', _kViolet, Icons.school_rounded),
          AcadStat('Paid', '$paid', _kGreen, Icons.verified_rounded),
          AcadStat('No Payment', '${all.length - paid}', _kOrange,
              Icons.pending_actions_rounded),
          AcadStat('This Month', '${vm.admissionsThisMonth}', _kPink,
              Icons.calendar_month_rounded),
        ];

        return Scaffold(
          backgroundColor: _kPageBg,
          body: Column(children: [
            _Header(loading: vm.loading, onRefresh: vm.fetchAll),
            Expanded(
              child: RefreshIndicator(
                color: _kCyan,
                onRefresh: vm.fetchAll,
                child: vm.loading && !vm.loaded
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: _kCyan, strokeWidth: 2.5))
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        padding: EdgeInsets.fromLTRB(
                            sw * .04, 18, sw * .04, mq.padding.bottom + 24),
                        children: [
                          if (vm.error != null)
                            AcadErrorBanner(
                                message: vm.error!, onRetry: vm.fetchAll),
                          const _SectionLabel(
                              text: 'ADMISSIONS OVERVIEW', color: _kCyan),
                          const SizedBox(height: 10),
                          _StatsGrid(items: stats),
                          const SizedBox(height: 18),
                          _SearchBar(
                            controller: _searchCtrl,
                            hint: 'Search name, phone, student ID…',
                            onChanged: (v) => setState(() => _search = v),
                          ),
                          const SizedBox(height: 12),
                          _FilterRow(
                            showReset: _hasFilter,
                            onReset: _reset,
                            filters: [
                              acadPicker(
                                context: context,
                                icon: Icons.menu_book_rounded,
                                hint: 'Course',
                                title: 'Select Course',
                                options: courses,
                                value: _course,
                                onChanged: (v) => setState(() => _course = v),
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
                              acadPicker(
                                context: context,
                                icon: Icons.account_balance_wallet_rounded,
                                hint: 'Payment',
                                title: 'Payment Status',
                                options: const ['Paid', 'No Payment'],
                                value: _payment,
                                onChanged: (v) => setState(() => _payment = v),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          AcadListHeader(
                              title: 'Admitted Students',
                              count: list.length,
                              color: _kCyan),
                          const SizedBox(height: 10),
                          if (list.isEmpty)
                            _Empty(
                              title: all.isEmpty
                                  ? 'No Admissions Yet'
                                  : 'No Students Found',
                              subtitle: all.isEmpty
                                  ? 'Admitted students will appear here'
                                  : 'Try adjusting your filters',
                            )
                          else
                            ...List.generate(list.length, (i) {
                              final a = list[i];
                              return AcadFadeIn(
                                key: ValueKey('adm_${a.id}_$i'),
                                index: i,
                                child: _StudentCard(
                                    a: a, onTap: () => _open(a)),
                              );
                            }),
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
            child: Icon(Icons.workspace_premium_rounded,
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
                    const Text('Admissions',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('Students who took admission',
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
            child: Icon(Icons.school_outlined,
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
// Student card (white, accent bar, status chip, tag strip)
// ═════════════════════════════════════════════════════════════════════════════
class _StudentCard extends StatelessWidget {
  final AcadAdmission a;
  final VoidCallback onTap;
  const _StudentCard({required this.a, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = a.hasPayment ? _kViolet : _kOrange;
    final text = _shade(color, 0.12);

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
                          child: AcademyAvatar(name: a.name, size: 44),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: _kInk)),
                              const SizedBox(height: 3),
                              Row(children: [
                                const Icon(Icons.phone_rounded,
                                    size: 13, color: _kSlate),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(a.phone,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12.5, color: _kSlate)),
                                ),
                              ]),
                            ]),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: (a.hasPayment ? _kGreen : _kOrange)
                              .withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(
                              a.hasPayment
                                  ? Icons.check_circle_rounded
                                  : Icons.pending_rounded,
                              size: 12,
                              color: a.hasPayment ? _kGreen : _kOrange),
                          const SizedBox(width: 3),
                          Text(
                              a.hasPayment
                                  ? 'Paid ${acadInrShort(a.payment!.amount)}'
                                  : 'No Payment',
                              style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: a.hasPayment ? _kGreen : _kOrange)),
                        ]),
                      ),
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
                                text: a.studentId,
                                icon: Icons.badge_rounded,
                                color: color),
                            if (a.course.isNotEmpty)
                              AcadMiniTag(
                                  text: a.course,
                                  icon: Icons.menu_book_rounded,
                                  color: _kCyan),
                            if (a.counsellor.isNotEmpty)
                              AcadMiniTag(
                                  text: a.counsellor,
                                  icon: Icons.support_agent_rounded,
                                  color: text),
                          ]),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.event_rounded,
                            size: 14, color: _kSlate),
                        const SizedBox(width: 3),
                        Text(acadDate(a.date),
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _kSlate)),
                        const SizedBox(width: 6),
                        AcadArrowButton(color: color),
                      ]),
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