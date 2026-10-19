import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/models/academy_models/academy_hr_model.dart';
import 'package:pokakbilling/viewmodels/academy/academy_hr_viewmodel.dart';
import 'package:pokakbilling/views/academy/academy_extras.dart';
import 'package:pokakbilling/views/academy/academy_hr_widgets.dart';
import 'package:pokakbilling/views/academy/academy_theme.dart';
import 'package:pokakbilling/views/academy/academy_widgets.dart';

// ═════════════════════════════════════════════════════════════════════════════
// Colour scheme (same as Payments / Academy home)
//   • Header / loaders      → Cyan
//   • Info section          → Violet
//   • Records header        → Pink
//   • Approve / Reject      → Green / Red
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
const Color _kPink = Color(0xFFEC4899);
const Color _kRed = Color(0xFFEF4444);

const LinearGradient _kHeaderGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [_kCyanDeep, _kCyan, _kCyanLight],
);

Color _shade(Color c, double amt) => Color.lerp(c, Colors.black, amt)!;
Color _tint(Color c, double amt) => Color.lerp(c, Colors.white, amt)!;

class HrSubmissionDetailScreen extends StatefulWidget {
  final int submissionId;
  const HrSubmissionDetailScreen({super.key, required this.submissionId});

  @override
  State<HrSubmissionDetailScreen> createState() =>
      _HrSubmissionDetailScreenState();
}

class _HrSubmissionDetailScreenState extends State<HrSubmissionDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AcademyHrViewmodel>().loadDetail(widget.submissionId);
      }
    });
  }

  Future<void> _act(
      AcademyHrViewmodel vm, AcadSubmission s, bool approve) async {
    final res = await showModalBottomSheet<(String, String)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HrRemarksSheet(
        title: approve ? 'Approve Submission' : 'Reject Submission',
        subtitle: '${s.counsellorName} · ${s.periodLabel}',
        confirmLabel: approve ? 'Approve' : 'Reject',
        color: approve ? _kGreen : _kRed,
        icon: approve ? Icons.verified_rounded : Icons.cancel_rounded,
        remarksRequired: !approve,
      ),
    );
    if (res == null || !mounted) return;
    await vm.review(
      context: context,
      id: s.id,
      action: approve ? 'approved' : 'rejected',
      remarks: res.$2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;

    return Consumer<AcademyHrViewmodel>(
      builder: (context, vm, _) {
        final d = vm.detail;
        final s = d?.submission;
        final showActions = s != null && s.isPending;

        return Scaffold(
          backgroundColor: _kPageBg,
          bottomNavigationBar: showActions
              ? Container(
                  padding: EdgeInsets.fromLTRB(
                      sw * .04, 12, sw * .04, mq.padding.bottom + 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: const Border(top: BorderSide(color: _kLine)),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(22)),
                    boxShadow: [
                      BoxShadow(
                        color: _kInk.withValues(alpha: 0.07),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(children: [
                    Expanded(
                      child: HrGradientButton(
                        label: 'Reject',
                        icon: Icons.close_rounded,
                        color: _kRed,
                        onTap:
                            vm.actionLoading ? null : () => _act(vm, s, false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: HrGradientButton(
                        label: 'Approve',
                        icon: Icons.check_rounded,
                        color: _kGreen,
                        loading: vm.actionLoading,
                        onTap:
                            vm.actionLoading ? null : () => _act(vm, s, true),
                      ),
                    ),
                  ]),
                )
              : null,
          body: Column(children: [
            _Header(
              title: 'Submission #${widget.submissionId}',
              loading: vm.detailLoading,
              onRefresh: () => vm.loadDetail(widget.submissionId),
            ),
            Expanded(
              child: vm.detailLoading && d == null
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: _kCyan, strokeWidth: 2.5))
                  : d == null
                      ? ListView(
                          padding: EdgeInsets.all(sw * .04),
                          children: [
                            AcadErrorBanner(
                              message:
                                  vm.detailError ?? 'Could not load details',
                              onRetry: () =>
                                  vm.loadDetail(widget.submissionId),
                            ),
                          ],
                        )
                      : RefreshIndicator(
                          color: _kCyan,
                          onRefresh: () => vm.loadDetail(widget.submissionId,
                              silent: true),
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics()),
                            padding: EdgeInsets.fromLTRB(
                                sw * .04, 18, sw * .04, mq.padding.bottom + 24),
                            children: _body(d),
                          ),
                        ),
            ),
          ]),
        );
      },
    );
  }

  List<Widget> _body(AcadSubmissionDetail d) {
    final s = d.submission;
    return [
      AcadFadeIn(
        child: HrHeroCard(
          title: s.counsellorName,
          line1: '${acadDate(s.startDate)}  →  ${acadDate(s.endDate)}',
          line2: s.periodLabel,
          status: s.status,
        ),
      ),
      const SizedBox(height: 20),
      const _SectionLabel(text: 'CONVERSION OVERVIEW', color: _kCyan),
      const SizedBox(height: 10),
      _StatsGrid(items: hrSummaryStats(d.summary)),
      const SizedBox(height: 20),
      _InfoCard(
        icon: Icons.fact_check_rounded,
        title: 'Submission Info',
        color: _kViolet,
        child: Column(children: [
          AcademyInfoRow(
              icon: Icons.person_rounded,
              label: 'Submitted by',
              value: s.submittedByName),
          const SizedBox(height: 14),
          AcademyInfoRow(
              icon: Icons.event_rounded,
              label: 'Submitted on',
              value: acadDate(s.submittedAt)),
          const SizedBox(height: 14),
          AcademyInfoRow(
              icon: Icons.edit_note_rounded,
              label: 'Submit remarks',
              value: s.remarks),
          if (s.reviewedByName.isNotEmpty) ...[
            const SizedBox(height: 14),
            AcademyInfoRow(
                icon: Icons.admin_panel_settings_rounded,
                label: 'Reviewed by',
                value: s.reviewedByName),
            const SizedBox(height: 14),
            AcademyInfoRow(
                icon: Icons.event_available_rounded,
                label: 'Reviewed on',
                value: acadDate(s.reviewedAt)),
          ],
        ]),
      ),
      const SizedBox(height: 20),
      AcadListHeader(
          title: 'Records', count: d.records.length, color: _kPink),
      const SizedBox(height: 10),
      if (d.records.isEmpty)
        const _Empty(
          icon: Icons.inbox_outlined,
          title: 'No Records',
          subtitle: 'This submission has no records',
        )
      else
        ...List.generate(
          d.records.length,
          (i) => AcadFadeIn(
            key: ValueKey('drec_${d.records[i].recordType}_${d.records[i].id}'),
            index: i,
            child: HrRecordTile(r: d.records[i]),
          ),
        ),
    ];
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Header
// ═════════════════════════════════════════════════════════════════════════════
class _Header extends StatelessWidget {
  final String title;
  final bool loading;
  final VoidCallback onRefresh;
  const _Header({
    required this.title,
    required this.loading,
    required this.onRefresh,
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
            child: Icon(Icons.approval_rounded,
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
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('Review conversion details',
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
// Overview cards
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
// Info section card (accent bar + gradient title strip)
// ═════════════════════════════════════════════════════════════════════════════
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget child;
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          color.withValues(alpha: 0.12),
                          color.withValues(alpha: 0.02)
                        ]),
                      ),
                      child: Row(children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [_tint(color, 0.22), color],
                            ),
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.32),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(icon, size: 19, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Text(title,
                            style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: _kInk)),
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                      child: child,
                    ),
                  ]),
            ),
          ]),
        ),
      ),
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
      padding: const EdgeInsets.only(top: 30),
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