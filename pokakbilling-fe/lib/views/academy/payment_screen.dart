import 'package:flutter/material.dart';
import 'package:pokakbilling/models/academy_models/academy_model.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/viewmodels/academy/academy_viewmodel.dart';
import 'package:pokakbilling/views/academy/academy_extras.dart';
import 'package:pokakbilling/views/academy/academy_palette.dart';
import 'package:pokakbilling/views/academy/academy_theme.dart';
import 'package:pokakbilling/views/academy/academy_widgets.dart';

const Map<String, String> _kReceiptTypes = {
  'Advance': 'advance',
  'Installment': 'installment',
  'First Payment': 'admission_first_payment',
};

// ═════════════════════════════════════════════════════════════════════════════
// Colour scheme  (standard modern dashboard look)
//   • Receipts mode  → Cyan (primary)
//   • Slot mode      → Orange (header stays cyan)
//   • Top 4 cards    → Pink / Violet / Green / Amber
//   • Receipt types  → Cyan / Violet / Blue   • Slot → Orange
// ═════════════════════════════════════════════════════════════════════════════
const Color _kPageBg = Color(0xFFF0FAFD);
const Color _kInk = Color(0xFF0F172A);
const Color _kSlate = Color(0xFF64748B);
const Color _kLine = Color(0xFFD9ECF2);

const Color _kCyan = Color(0xFF06B6D4);
const Color _kCyanLight = Color(0xFF67E8F9);
const Color _kBlue = Color(0xFF3B82F6);
const Color _kOrange = Color(0xFFF97316);
const Color _kOrangeLight = Color(0xFFFBBF24);
const Color _kViolet = Color(0xFF8B5CF6);
const Color _kGreen = Color(0xFF16A34A);
const Color _kPink = Color(0xFFEC4899);

/// Main colour of the current mode.
Color _mode(bool slot) => slot ? _kOrange : _kCyan;

LinearGradient _modeGradient(bool slot) => LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: slot ? [_kOrange, _kOrangeLight] : [_kCyan, _kCyanLight],
    );

/// Header gradient is the same cyan for both Receipts and Slot tabs.
const LinearGradient _kHeaderGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF0E7490), _kCyan, _kCyanLight],
);

/// Accent of one payment.
Color _accent(AcadPayment p) {
  if (p.isSlot) return _kOrange;
  switch (p.category) {
    case 'installment':
      return _kViolet;
    case 'admission_first_payment':
      return _kBlue;
    case 'advance':
    default:
      return _kCyan;
  }
}

Color _shade(Color c, double amt) => Color.lerp(c, Colors.black, amt)!;
Color _tint(Color c, double amt) => Color.lerp(c, Colors.white, amt)!;

// ═════════════════════════════════════════════════════════════════════════════
// Screen
// ═════════════════════════════════════════════════════════════════════════════
class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _search = '';
  int _tab = 0; // 0 = receipts, 1 = slot bookings
  String? _category;
  String? _method;
  String? _course;
  String? _counsellor;

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
      _category != null ||
      _method != null ||
      _course != null ||
      _counsellor != null;

  void _reset() {
    _searchCtrl.clear();
    setState(() {
      _search = '';
      _category = null;
      _method = null;
      _course = null;
      _counsellor = null;
    });
  }

  void _switchTab(int i) {
    if (i == _tab) return;
    _searchCtrl.clear();
    setState(() {
      _tab = i;
      _search = '';
      _category = null;
      _method = null;
      _course = null;
      _counsellor = null;
    });
  }

  List<AcadPayment> _apply(List<AcadPayment> src) {
    final q = _search.trim().toLowerCase();
    return src.where((p) {
      if (_category != null && p.category != _category) return false;
      if (_method != null && p.method != _method) return false;
      if (_course != null && p.course != _course) return false;
      if (_counsellor != null && p.counsellor != _counsellor) return false;
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.phone.toLowerCase().contains(q) ||
          p.id.toLowerCase().contains(q) ||
          p.studentId.toLowerCase().contains(q) ||
          p.transactionId.toLowerCase().contains(q) ||
          p.course.toLowerCase().contains(q);
    }).toList();
  }

  // ── Period counts (today / week / month / year) ───────────────────────────
  int _countSince(List<AcadPayment> src, DateTime from) => src
      .where((p) => p.date != null && !p.date!.isBefore(from))
      .length;

  List<AcadStat> _periodStats(List<AcadPayment> src) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);
    final yearStart = DateTime(now.year, 1, 1);

    return [
      AcadStat('Today', '${_countSince(src, today)}', _kPink,
          Icons.today_rounded),
      AcadStat('This Week', '${_countSince(src, weekStart)}', _kViolet,
          Icons.date_range_rounded),
      AcadStat('This Month', '${_countSince(src, monthStart)}', _kGreen,
          Icons.calendar_month_rounded),
      AcadStat('This Year', '${_countSince(src, yearStart)}',
          const Color(0xFFF59E0B), Icons.emoji_events_rounded),
    ];
  }

  void _openDetail(AcadPayment p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentSheet(p: p),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;

    return Consumer<AcademyViewmodel>(
      builder: (context, vm, _) {
        final isReceipts = _tab == 0;
        final slot = !isReceipts;
        final source = isReceipts ? vm.receipts : vm.slotPayments;
        final list = _apply(source);

        final courses = AcademyViewmodel.distinct(source.map((p) => p.course));
        final counsellors =
            AcademyViewmodel.distinct(source.map((p) => p.counsellor));
        final methodMap = <String, String>{};
        for (final p in source) {
          if (p.method != null && p.method!.isNotEmpty) {
            methodMap[acadMethodLabel(p.method)] = p.method!;
          }
        }
        final methodLabel = _method == null ? null : acadMethodLabel(_method);
        final categoryLabel =
            _category == null ? null : acadCategoryLabel(_category!);

        final filters = <AcadFilterSpec>[
          if (isReceipts)
            acadPicker(
              context: context,
              icon: Icons.category_rounded,
              hint: 'Type',
              title: 'Receipt Type',
              options: _kReceiptTypes.keys.toList(),
              value: categoryLabel,
              onChanged: (v) => setState(
                  () => _category = v == null ? null : _kReceiptTypes[v]),
            ),
          acadPicker(
            context: context,
            icon: Icons.account_balance_wallet_rounded,
            hint: 'Method',
            title: 'Payment Method',
            options: methodMap.keys.toList(),
            value: methodLabel,
            onChanged: (v) =>
                setState(() => _method = v == null ? null : methodMap[v]),
          ),
          acadPicker(
            context: context,
            icon: Icons.support_agent_rounded,
            hint: 'Counsellor',
            title: 'Select Counsellor',
            options: counsellors,
            value: _counsellor,
            onChanged: (v) => setState(() => _counsellor = v),
          ),
          if (slot)
            acadPicker(
              context: context,
              icon: Icons.menu_book_rounded,
              hint: 'Course',
              title: 'Select Course',
              options: courses,
              value: _course,
              onChanged: (v) => setState(() => _course = v),
            ),
        ];

        return Scaffold(
          backgroundColor: _kPageBg,
          body: Column(children: [
            _PayHeader(
              title: 'Payments',
              subtitle: 'Receipts & slot bookings',
              loading: vm.loading,
              onRefresh: vm.fetchAll,
              slot: slot,
            ),
            Expanded(
              child: RefreshIndicator(
                color: _mode(slot),
                onRefresh: vm.fetchAll,
                child: vm.loading && !vm.loaded
                    ? Center(
                        child: CircularProgressIndicator(
                            color: _mode(slot), strokeWidth: 2.5))
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        padding: EdgeInsets.fromLTRB(
                            sw * .04, 18, sw * .04, mq.padding.bottom + 24),
                        children: [
                          if (vm.error != null)
                            AcadErrorBanner(
                                message: vm.error!, onRetry: vm.fetchAll),
                          _SectionLabel(
                              text: isReceipts
                                  ? 'RECEIPTS OVERVIEW'
                                  : 'SLOT BOOKINGS OVERVIEW',
                              color: _mode(slot)),
                          const SizedBox(height: 10),
                          _StatsGrid(items: _periodStats(source)),
                          const SizedBox(height: 18),
                          _buildTabs(vm),
                          const SizedBox(height: 12),
                          _PaySearch(
                            controller: _searchCtrl,
                            color: _mode(slot),
                            hint: isReceipts
                                ? 'Search student, receipt, txn ID…'
                                : 'Search name, phone, course…',
                            onChanged: (v) => setState(() => _search = v),
                          ),
                          const SizedBox(height: 12),
                          _FilterRow(
                            slot: slot,
                            showReset: _hasFilter,
                            onReset: _reset,
                            filters: filters,
                          ),
                          const SizedBox(height: 18),
                          AcadListHeader(
                            title: isReceipts
                                ? 'Receipts Issued'
                                : 'Slot Bookings',
                            count: list.length,
                            color: _mode(slot),
                          ),
                          const SizedBox(height: 10),
                          if (list.isEmpty)
                            _Empty(
                              slot: slot,
                              title: source.isEmpty
                                  ? (isReceipts
                                      ? 'No Receipts Yet'
                                      : 'No Slot Bookings Yet')
                                  : 'Nothing Found',
                              subtitle: source.isEmpty
                                  ? 'Entries will appear here'
                                  : 'Try adjusting your filters',
                            )
                          else
                            ...List.generate(
                              list.length,
                              (i) => AcadFadeIn(
                                key: ValueKey('pay_${list[i].id}_$i'),
                                index: i,
                                child: _PaymentCard(
                                    p: list[i],
                                    onTap: () => _openDetail(list[i])),
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

  // ── Segmented tabs: Receipts = blue, Slot Booking = orange ───────────────
  Widget _buildTabs(AcademyViewmodel vm) {
    Widget tab(int i, IconData icon, String label, int count) {
      final on = _tab == i;
      final isSlotTab = i == 1;
      final c = _mode(isSlotTab);
      return Expanded(
        child: GestureDetector(
          onTap: () => _switchTab(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOut,
            height: 46,
            decoration: BoxDecoration(
              gradient: on ? _modeGradient(isSlotTab) : null,
              borderRadius: BorderRadius.circular(14),
              boxShadow: on
                  ? [
                      BoxShadow(
                        color: c.withValues(alpha: 0.38),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 18, color: on ? Colors.white : _kSlate),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: on ? Colors.white : _kSlate)),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: BoxDecoration(
                  color: on
                      ? Colors.white.withValues(alpha: 0.28)
                      : c.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$count',
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: on ? Colors.white : c)),
              ),
            ]),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kLine),
        boxShadow: [
          BoxShadow(
            color: _kInk.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(children: [
        tab(0, Icons.receipt_long_rounded, 'Receipts', vm.receiptCount),
        const SizedBox(width: 4),
        tab(1, Icons.event_seat_rounded, 'Slot Booking', vm.slotCount),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Header (cyan on both tabs)
// ═════════════════════════════════════════════════════════════════════════════
class _PayHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool loading;
  final VoidCallback onRefresh;
  final bool slot;
  const _PayHeader({
    required this.title,
    required this.subtitle,
    required this.loading,
    required this.onRefresh,
    required this.slot,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
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
            child: Icon(
                slot ? Icons.event_seat_rounded : Icons.receipt_long_rounded,
                size: 90,
                color: Colors.white.withValues(alpha: 0.12)),
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
                  border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
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
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(subtitle,
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
// Top 4 overview cards → white cards, each with its own colour
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
                  // soft colour wash at the top
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
                  // coloured bottom bar
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
class _PaySearch extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final Color color;
  final ValueChanged<String> onChanged;
  const _PaySearch({
    required this.controller,
    required this.hint,
    required this.color,
    required this.onChanged,
  });

  @override
  State<_PaySearch> createState() => _PaySearchState();
}

class _PaySearchState extends State<_PaySearch> {
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
    final c = widget.color;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      height: 54,
      padding: const EdgeInsets.only(left: 7, right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: focused ? c : _kLine,
          width: focused ? 1.6 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (focused ? c : _kInk).withValues(alpha: focused ? 0.22 : 0.05),
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
              colors: [_tint(c, 0.2), c],
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
            cursorColor: c,
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
                color: c.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded, size: 16, color: c),
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
  final bool slot;
  final VoidCallback onReset;
  const _FilterRow({
    required this.filters,
    required this.showReset,
    required this.slot,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      for (var i = 0; i < filters.length; i++) ...[
        if (i > 0) const SizedBox(width: 8),
        Expanded(child: _PayPill(spec: filters[i], slot: slot)),
      ],
      if (showReset) ...[
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onReset,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AcadPal.red.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(color: AcadPal.red.withValues(alpha: 0.25)),
            ),
            child: const Icon(Icons.restart_alt_rounded,
                size: 20, color: AcadPal.red),
          ),
        ),
      ],
    ]);
  }
}

class _PayPill extends StatelessWidget {
  final AcadFilterSpec spec;
  final bool slot;
  const _PayPill({required this.spec, required this.slot});

  @override
  Widget build(BuildContext context) {
    final active = spec.active;
    final c = _mode(slot);
    return GestureDetector(
      onTap: spec.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          gradient: active ? _modeGradient(slot) : null,
          color: active ? null : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: active ? Colors.transparent : _kLine),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: c.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(children: [
          Icon(spec.icon, size: 15, color: active ? Colors.white : c),
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
  final bool slot;
  final String title;
  final String subtitle;
  const _Empty(
      {required this.slot, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final c = _mode(slot);
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
                colors: [c.withValues(alpha: 0.22), c.withValues(alpha: 0.06)],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: c.withValues(alpha: 0.25)),
            ),
            child: Icon(
                slot ? Icons.event_seat_outlined : Icons.receipt_long_outlined,
                size: 38,
                color: c.withValues(alpha: 0.85)),
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
// Transaction card (white, accent bar, green status chip)
// ═════════════════════════════════════════════════════════════════════════════
class _PaymentCard extends StatelessWidget {
  final AcadPayment p;
  final VoidCallback onTap;
  const _PaymentCard({required this.p, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _accent(p);
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
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_tint(color, 0.22), color],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.32),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(acadCategoryIcon(p.category),
                              color: Colors.white, size: 25),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: _kInk)),
                              const SizedBox(height: 3),
                              Text(
                                  p.course.isEmpty
                                      ? acadCategoryLabel(p.category)
                                      : '${acadCategoryLabel(p.category)} · ${p.course}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 12.5, color: _kSlate)),
                              if (p.counsellor.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Row(children: [
                                  Icon(Icons.support_agent_rounded,
                                      size: 13, color: text),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(p.counsellor,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: text)),
                                  ),
                                ]),
                              ],
                            ]),
                      ),
                      const SizedBox(width: 8),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(acadInr(p.amount),
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: text)),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _kGreen.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.check_circle_rounded,
                                        size: 12, color: _kGreen),
                                    const SizedBox(width: 3),
                                    Text(p.isSlot ? 'Slot Paid' : 'Received',
                                        style: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                            color: _kGreen)),
                                  ]),
                            ),
                          ]),
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
                                text: p.id,
                                icon: Icons.tag_rounded,
                                color: color),
                            if (p.method != null && p.method!.isNotEmpty)
                              AcadMiniTag(
                                  text: acadMethodLabel(p.method),
                                  icon: acadMethodIcon(p.method),
                                  color: color),
                          ]),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.event_rounded,
                            size: 14, color: _kSlate),
                        const SizedBox(width: 3),
                        Text(acadDate(p.date),
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

// ═════════════════════════════════════════════════════════════════════════════
// Detail sheet
// ═════════════════════════════════════════════════════════════════════════════
class _PaymentSheet extends StatelessWidget {
  final AcadPayment p;
  const _PaymentSheet({required this.p});

  @override
  Widget build(BuildContext context) {
    final color = _accent(p);
    final bottom = MediaQuery.of(context).padding.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scroll) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scroll,
            padding: EdgeInsets.fromLTRB(18, 10, 18, bottom + 24),
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    gradient: _modeGradient(p.isSlot),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient:
                        LinearGradient(colors: [color, _tint(color, 0.35)]),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: AcademyAvatar(name: p.name, size: 52),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: _kInk)),
                        const SizedBox(height: 3),
                        Text(p.course.isEmpty ? '—' : p.course,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13.5, color: _kSlate)),
                      ]),
                ),
                AcadStatusPill(
                    label: acadCategoryLabel(p.category), color: color),
              ]),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_shade(color, 0.3), color, _tint(color, 0.2)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.32),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(children: [
                  Icon(acadCategoryIcon(p.category),
                      color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.isSlot ? 'Slot amount paid' : 'Amount received',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.9))),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(acadInr(p.amount),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900)),
                          ),
                        ]),
                  ),
                  Text(acadDate(p.date),
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.94),
                          fontWeight: FontWeight.w700)),
                ]),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _kPageBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _kLine),
                ),
                child: Column(children: [
                  AcademyInfoRow(
                      icon: Icons.tag_rounded,
                      label: p.isSlot ? 'Slot ID' : 'Receipt No',
                      value: p.id),
                  const SizedBox(height: 14),
                  AcademyInfoRow(
                      icon: Icons.support_agent_rounded,
                      label: 'Received by (Counsellor)',
                      value: p.counsellor),
                  const SizedBox(height: 14),
                  AcademyInfoRow(
                      icon: acadMethodIcon(p.method),
                      label: 'Payment method',
                      value: acadMethodLabel(p.method)),
                  const SizedBox(height: 14),
                  AcademyInfoRow(
                      icon: Icons.receipt_rounded,
                      label: 'Transaction ID',
                      value: p.transactionId),
                  const SizedBox(height: 14),
                  if (!p.isSlot) ...[
                    AcademyInfoRow(
                        icon: Icons.badge_rounded,
                        label: 'Student ID',
                        value: p.studentId),
                    const SizedBox(height: 14),
                  ],
                  AcademyInfoRow(
                      icon: Icons.phone_rounded, label: 'Phone', value: p.phone),
                  const SizedBox(height: 14),
                  AcademyInfoRow(
                      icon: Icons.email_rounded, label: 'Email', value: p.email),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }
}