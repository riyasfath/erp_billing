import 'package:flutter/material.dart';
import 'package:pokakbilling/models/academy_models/academy_model.dart';
import 'package:pokakbilling/views/academy/academy_theme.dart';
import 'package:pokakbilling/views/academy/counsiler_conversion_screen.dart';
import 'package:pokakbilling/views/academy/hr_submission_screen.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/viewmodels/academy/academy_viewmodel.dart';
import 'package:pokakbilling/viewmodels/academy/academy_hr_viewmodel.dart';
import 'package:pokakbilling/views/academy/academy_extras.dart';
import 'package:pokakbilling/views/academy/academy_widgets.dart';
import 'package:pokakbilling/views/academy/admission_screen.dart';
import 'package:pokakbilling/views/academy/payment_screen.dart';
import 'package:pokakbilling/views/academy/registration_formscreen.dart';

// ═════════════════════════════════════════════════════════════════════════════
// Colour scheme (same as Payments screen)
//   • Header         → Cyan gradient
//   • Top 4 cards    → Pink / Violet / Green / Amber
//   • Modules        → Cyan / Violet / Blue / Pink / Green
//   • Slot bookings  → Orange
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
const Color _kOrangeLight = Color(0xFFFBBF24);
const Color _kViolet = Color(0xFF8B5CF6);
const Color _kGreen = Color(0xFF16A34A);
const Color _kPink = Color(0xFFEC4899);
const Color _kAmber = Color(0xFFF59E0B);

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
class AcademyDashboardScreen extends StatefulWidget {
  const AcademyDashboardScreen({super.key});

  @override
  State<AcademyDashboardScreen> createState() => _AcademyDashboardScreenState();
}

class _AcademyDashboardScreenState extends State<AcademyDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AcademyViewmodel>().fetchAll();
      context.read<AcademyHrViewmodel>().fetchSubmissions();
    });
  }

  void _go(Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  Future<void> _refresh() async {
    await Future.wait([
      context.read<AcademyViewmodel>().fetchAll(),
      context.read<AcademyHrViewmodel>().fetchSubmissions(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final hr = context.watch<AcademyHrViewmodel>();
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;

    return Consumer<AcademyViewmodel>(
      builder: (context, vm, _) {
        final firstLoad = vm.loading && !vm.loaded;

        final stats = <AcadStat>[
          AcadStat('Registered', '${vm.totalRegistrations}', _kPink,
              Icons.groups_rounded),
          AcadStat('Admitted', '${vm.totalAdmissions}', _kViolet,
              Icons.school_rounded),
          AcadStat('Receipts', '${vm.receiptCount}', _kGreen,
              Icons.receipt_long_rounded),
          AcadStat('Slots', '${vm.slotCount}', _kAmber,
              Icons.event_seat_rounded),
        ];

        return Scaffold(
          backgroundColor: _kPageBg,
          body: Column(children: [
            _Header(
              loading: vm.loading,
              onRefresh: _refresh,
              pending: hr.pendingCount,
            ),
            Expanded(
              child: RefreshIndicator(
                color: _kCyan,
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  padding: EdgeInsets.fromLTRB(
                      sw * .04, 18, sw * .04, mq.padding.bottom + 28),
                  children: [
                    if (vm.error != null)
                      AcadErrorBanner(message: vm.error!, onRetry: vm.fetchAll),

                    // ── Overview ────────────────────────────────────────
                    const _SectionLabel(text: 'ACADEMY OVERVIEW', color: _kCyan),
                    const SizedBox(height: 10),
                    _StatsGrid(items: stats),
                    const SizedBox(height: 14),
                    AcadFadeIn(
                      index: 4,
                      child: _ConversionCard(
                        rate: vm.conversionRate,
                        admitted: vm.totalAdmissions,
                        registered: vm.totalRegistrations,
                        pending: vm.pendingRegistrations,
                        today: vm.todayRegistrations,
                        loading: firstLoad,
                      ),
                    ),

                    // ── Modules ─────────────────────────────────────────
                    const SizedBox(height: 22),
                    const _SectionLabel(text: 'MANAGE ACADEMY', color: _kViolet),
                    const SizedBox(height: 12),
                    AcadFadeIn(
                      index: 0,
                      child: _ModuleCard(
                        title: 'Registration',
                        subtitle: 'Candidates yet to take admission',
                        icon: Icons.how_to_reg_rounded,
                        color: _kCyan,
                        loading: firstLoad,
                        metrics: [
                          ('Pending', '${vm.pendingRegistrations}',
                              Icons.hourglass_top_rounded),
                          ('Today', '${vm.todayRegistrations}',
                              Icons.today_rounded),
                        ],
                        onTap: () => _go(const RegistrationFormScreen()),
                      ),
                    ),
                    AcadFadeIn(
                      index: 1,
                      child: _ModuleCard(
                        title: 'Admission',
                        subtitle: 'Students who took admission',
                        icon: Icons.school_rounded,
                        color: _kViolet,
                        loading: firstLoad,
                        metrics: [
                          ('Admitted', '${vm.totalAdmissions}',
                              Icons.verified_rounded),
                          ('Conversion',
                              '${vm.conversionRate.toStringAsFixed(0)}%',
                              Icons.trending_up_rounded),
                        ],
                        onTap: () => _go(const AdmissionScreen()),
                      ),
                    ),
                    AcadFadeIn(
                      index: 2,
                      child: _ModuleCard(
                        title: 'Payments',
                        subtitle: 'Receipts & slot bookings',
                        icon: Icons.account_balance_wallet_rounded,
                        color: _kBlue,
                        loading: firstLoad,
                        metrics: [
                          ('Receipts', '${vm.receiptCount}',
                              Icons.receipt_rounded),
                          ('Slots', '${vm.slotCount}',
                              Icons.event_seat_rounded),
                        ],
                        onTap: () => _go(const PaymentsScreen()),
                      ),
                    ),
                    AcadFadeIn(
                      index: 3,
                      child: _ModuleCard(
                        title: 'Counsellor Conversion',
                        subtitle: 'Verify conversions & send to HR',
                        icon: Icons.assignment_turned_in_rounded,
                        color: _kPink,
                        loading: false,
                        metrics: [
                          ('Submissions', '${hr.submissions.length}',
                              Icons.send_rounded),
                        ],
                        onTap: () => _go(const CounsellorConversionScreen()),
                      ),
                    ),
                    AcadFadeIn(
                      index: 4,
                      child: _ModuleCard(
                        title: 'HR Approvals',
                        subtitle: 'Approve or reject submissions',
                        icon: Icons.verified_user_rounded,
                        color: _kGreen,
                        loading: false,
                        metrics: [
                          ('Pending', '${hr.pendingCount}',
                              Icons.hourglass_top_rounded),
                          ('Approved', '${hr.approvedCount}',
                              Icons.verified_rounded),
                        ],
                        alert: hr.pendingCount > 0
                            ? '${hr.pendingCount} new'
                            : null,
                        onTap: () => _go(const HrSubmissionsScreen()),
                      ),
                    ),

                    // ── Recent activity ─────────────────────────────────
                    const SizedBox(height: 10),
                    _SectionHeader(
                      label: 'LATEST RECEIPTS',
                      color: _kCyan,
                      onTap: () => _go(const PaymentsScreen()),
                    ),
                    const SizedBox(height: 10),
                    AcadFadeIn(
                      index: 5,
                      child: _RecentCard(
                        list: vm.receipts.take(5).toList(),
                        color: _kCyan,
                        icon: Icons.receipt_long_rounded,
                        emptyText: 'No receipts yet',
                        loading: firstLoad,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _SectionHeader(
                      label: 'SLOT BOOKINGS',
                      color: _kOrange,
                      onTap: () => _go(const PaymentsScreen()),
                    ),
                    const SizedBox(height: 10),
                    AcadFadeIn(
                      index: 6,
                      child: _RecentCard(
                        list: vm.slotPayments.take(5).toList(),
                        color: _kOrange,
                        icon: Icons.event_seat_rounded,
                        emptyText: 'No slot bookings yet',
                        loading: firstLoad,
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
// Header (same look as Payments header)
// ═════════════════════════════════════════════════════════════════════════════
class _Header extends StatelessWidget {
  final bool loading;
  final VoidCallback onRefresh;
  final int pending;
  const _Header({
    required this.loading,
    required this.onRefresh,
    required this.pending,
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
          right: 56,
          top: mq.padding.top + 2,
          child: Transform.rotate(
            angle: -0.25,
            child: Icon(Icons.school_rounded,
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
                    Text('Academy',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text('Registrations, admissions & payments',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 14)),
                  ]),
            ),
            const SizedBox(width: 8),
            if (pending > 0) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: _kOrange,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _kOrange.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.notifications_active_rounded,
                      size: 13, color: Colors.white),
                  const SizedBox(width: 4),
                  Text('$pending',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800)),
                ]),
              ),
              const SizedBox(width: 8),
            ],
            AcadIconButton(
                icon: Icons.refresh_rounded, loading: loading, onTap: onRefresh),
          ]),
        ),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Section label / header
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
// Top 4 overview cards (white, colour wash, bottom bar, count-up)
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
// Conversion card (animated progress bar)
// ═════════════════════════════════════════════════════════════════════════════
class _ConversionCard extends StatelessWidget {
  final double rate;
  final int admitted;
  final int registered;
  final int pending;
  final int today;
  final bool loading;
  const _ConversionCard({
    required this.rate,
    required this.admitted,
    required this.registered,
    required this.pending,
    required this.today,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (rate / 100).clamp(0.0, 1.0).toDouble();

    Widget mini(IconData ic, String value, String label, Color c) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
          decoration: BoxDecoration(
            color: _kPageBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kLine),
          ),
          child: Row(children: [
            Icon(ic, size: 16, color: c),
            const SizedBox(width: 6),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(
                        text: value,
                        style: TextStyle(
                            fontWeight: FontWeight.w900, color: c)),
                    TextSpan(
                        text: ' $label',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, color: _kSlate)),
                  ]),
                  style: const TextStyle(fontSize: 12.5),
                ),
              ),
            ),
          ]),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kLine),
        boxShadow: [
          BoxShadow(
            color: _kCyan.withValues(alpha: 0.12),
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
                colors: [_tint(_kCyan, 0.22), _kCyan],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _kCyan.withValues(alpha: 0.32),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.trending_up_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Conversion Rate',
                      style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: _kInk)),
                  SizedBox(height: 2),
                  Text('Registered → Admitted',
                      style: TextStyle(fontSize: 12.5, color: _kSlate)),
                ]),
          ),
          loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: _kCyan))
              : TweenAnimationBuilder<double>(
                  key: ValueKey(rate),
                  tween: Tween<double>(begin: 0, end: rate),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => Text('${v.toStringAsFixed(0)}%',
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: _kCyanDeep)),
                ),
        ]),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 10,
            color: _kCyan.withValues(alpha: 0.12),
            alignment: Alignment.centerLeft,
            child: TweenAnimationBuilder<double>(
              key: ValueKey('bar_$progress'),
              tween: Tween<double>(begin: 0, end: loading ? 0 : progress),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => FractionallySizedBox(
                widthFactor: v,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [_kCyan, _kCyanLight]),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(children: [
          mini(Icons.hourglass_top_rounded, '$pending', 'Pending', _kOrange),
          const SizedBox(width: 8),
          mini(Icons.today_rounded, '$today', 'Today', _kPink),
          const SizedBox(width: 8),
          mini(Icons.verified_rounded, '$admitted/$registered', 'Admitted',
              _kViolet),
        ]),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Module card (white, accent bar, gradient icon tile, metric chips)
// ═════════════════════════════════════════════════════════════════════════════
class _ModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<(String, String, IconData)> metrics;
  final String? alert;
  final bool loading;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.metrics,
    required this.onTap,
    this.alert,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
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
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                  child: Row(children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_tint(color, 0.22), color],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.34),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 27),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Flexible(
                                child: Text(title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w800,
                                        color: _kInk)),
                              ),
                              if (alert != null) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _kOrange.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(alert!,
                                      style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: _kOrange)),
                                ),
                              ],
                            ]),
                            const SizedBox(height: 2),
                            Text(subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12.5, color: _kSlate)),
                            const SizedBox(height: 9),
                            loading
                                ? SizedBox(
                                    height: 26,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2, color: color),
                                      ),
                                    ),
                                  )
                                : Row(children: [
                                    for (var i = 0;
                                        i < metrics.length;
                                        i++) ...[
                                      if (i > 0) const SizedBox(width: 6),
                                      Flexible(
                                          child:
                                              _metricChip(metrics[i], text)),
                                    ],
                                  ]),
                          ]),
                    ),
                    const SizedBox(width: 8),
                    AcadArrowButton(color: color),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _metricChip((String, String, IconData) m, Color text) {
    final (label, value, ic) = m;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: _kPageBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kLine),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(ic, size: 13, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text.rich(
            TextSpan(children: [
              TextSpan(
                  text: value,
                  style: TextStyle(fontWeight: FontWeight.w900, color: text)),
              const TextSpan(text: ' '),
              TextSpan(
                  text: label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: _kSlate)),
            ]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Recent list card
// ═════════════════════════════════════════════════════════════════════════════
class _RecentCard extends StatelessWidget {
  final List<AcadPayment> list;
  final Color color;
  final IconData icon;
  final String emptyText;
  final bool loading;
  const _RecentCard({
    required this.list,
    required this.color,
    required this.icon,
    required this.emptyText,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
      child: loading
          ? Padding(
              padding: const EdgeInsets.all(22),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child:
                      CircularProgressIndicator(strokeWidth: 2, color: color),
                ),
              ),
            )
          : list.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(22),
                  child: Center(
                    child: Text(emptyText,
                        style:
                            const TextStyle(fontSize: 14, color: _kSlate)),
                  ),
                )
              : Column(children: [
                  for (var i = 0; i < list.length; i++) ...[
                    _row(list[i]),
                    if (i < list.length - 1)
                      Divider(height: 1, color: _kLine),
                  ],
                ]),
    );
  }

  Widget _row(AcadPayment p) {
    final sub = [
      if (p.course.isNotEmpty) p.course,
      if (p.counsellor.isNotEmpty) p.counsellor,
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_tint(color, 0.22), color],
            ),
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.30),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: _kInk)),
            const SizedBox(height: 2),
            Text(sub.isEmpty ? acadCategoryLabel(p.category) : sub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: _kSlate)),
          ]),
        ),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(acadInr(p.amount),
              style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  color: _shade(color, 0.12))),
          const SizedBox(height: 2),
          Text(acadDate(p.date),
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: _kSlate)),
        ]),
      ]),
    );
  }
}