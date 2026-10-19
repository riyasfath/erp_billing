import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokakbilling/views/academy/academy_widgets.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/academy/form_submission_viewmodel.dart';
import 'package:pokakbilling/views/academy/academy_theme.dart';

class FormSubmissionDetailScreen extends StatelessWidget {
  final int submissionId;
  const FormSubmissionDetailScreen({super.key, required this.submissionId});

  String _cap(String v) =>
      v.isEmpty ? '' : '${v[0].toUpperCase()}${v.substring(1)}';

  void _copy(BuildContext context, String label, String value) {
    if (value.trim().isEmpty) return;
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$label copied', style: const TextStyle(fontSize: 15)),
      backgroundColor: AppColors.c1,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;

    return Consumer<FormSubmissionViewmodel>(
      builder: (context, vm, _) {
        final s = vm.getById(submissionId);
        if (s == null) {
          return Scaffold(
            backgroundColor: AppColors.white,
            body: Center(
              child: vm.getLoader
                  ? const CircularProgressIndicator(color: AppColors.c1)
                  : Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: AppColors.c1.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person_off_rounded,
                            size: 38,
                            color: AppColors.c1.withValues(alpha: 0.6)),
                      ),
                      const SizedBox(height: 14),
                      const Text('Candidate not found',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cdark)),
                      const SizedBox(height: 8),
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Go back',
                              style: TextStyle(color: AppColors.c1))),
                    ]),
            ),
          );
        }

        final taken = s.isConverted;
        final accent = taken ? AppColors.c3 : AppColors.c2;
        final regStatus = s.status.isEmpty ? 'Pending' : _cap(s.status);

        return Scaffold(
          backgroundColor: AppColors.white,
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              // ── Hero header ─────────────────────────────────────────────
              Container(
                padding: EdgeInsets.only(
                    top: mq.padding.top + 12,
                    bottom: 26,
                    left: sw * .05,
                    right: sw * .05),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.c1, AppColors.c1.withValues(alpha: 0.80)],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.c1.withValues(alpha: 0.30),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(clipBehavior: Clip.none, children: [
                  // decorative circles
                  Positioned(
                    right: -40,
                    top: -30,
                    child: _bubble(130, 0.10),
                  ),
                  Positioned(
                    left: -30,
                    bottom: -50,
                    child: _bubble(100, 0.07),
                  ),
                  Column(children: [
                    // top bar
                    Row(children: [
                      _glassButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text('Candidate Details',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 40),
                    ]),
                    const SizedBox(height: 22),

                    // avatar with ring
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white.withValues(alpha: 0.35),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: AcademyAvatar(
                            name: s.fullName, size: 76, seed: s.id),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(s.fullName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2)),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (s.code.isNotEmpty)
                          _heroChip(Icons.tag_rounded, s.code),
                        _heroChip(Icons.event_rounded,
                            academyFormatDate(s.appliedDate)),
                        _heroStatus(taken),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // quick actions
                    Row(children: [
                      Expanded(
                        child: _actionButton(
                          icon: Icons.phone_rounded,
                          label: 'Copy Phone',
                          onTap: () => _copy(context, 'Phone number', s.phone),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _actionButton(
                          icon: Icons.email_rounded,
                          label: 'Copy Email',
                          onTap: () => _copy(context, 'Email', s.email),
                        ),
                      ),
                    ]),
                  ]),
                ]),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(
                    16, 18, 16, mq.padding.bottom + 28),
                child: Column(children: [
                  // ── Quick facts row ──────────────────────────────────────
                  Row(children: [
                    _factTile(
                      icon: s.isInternship
                          ? Icons.work_rounded
                          : Icons.card_giftcard_rounded,
                      label: 'Type',
                      value: s.isInternship ? 'Internship' : 'Free Course',
                      color: AppColors.c1,
                    ),
                    const SizedBox(width: 8),
                    _factTile(
                      icon: Icons.schedule_rounded,
                      label: 'Duration',
                      value: s.durationMonths > 0
                          ? '${s.durationMonths} Months'
                          : '—',
                      color: AppColors.c3,
                    ),
                    const SizedBox(width: 8),
                    _factTile(
                      icon: Icons.public_rounded,
                      label: 'Mode',
                      value:
                          s.courseMode.isEmpty ? '—' : _cap(s.courseMode),
                      color: AppColors.c2,
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // ── Status ───────────────────────────────────────────────
                  _Section(
                    icon: Icons.fact_check_rounded,
                    title: 'Status',
                    accent: accent,
                    children: [
                      _InfoItem(Icons.how_to_reg_rounded,
                          'Registration', regStatus),
                      _InfoItem(Icons.verified_rounded, 'Admission',
                          taken ? 'Taken' : 'Pending',
                          valueColor: accent),
                      _InfoItem(
                          Icons.category_rounded,
                          'Registration type',
                          s.isInternship
                              ? 'Internship form'
                              : 'Free course form',
                          full: true),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── General ──────────────────────────────────────────────
                  _Section(
                    icon: Icons.person_rounded,
                    title: 'General Information',
                    children: [
                      _InfoItem(Icons.email_rounded, 'Email address', s.email,
                          full: true,
                          onCopy: () => _copy(context, 'Email', s.email)),
                      _InfoItem(Icons.phone_rounded, 'Primary phone', s.phone,
                          full: true,
                          onCopy: () =>
                              _copy(context, 'Phone number', s.phone)),
                      _InfoItem(
                          Icons.cake_rounded, 'Date of birth', s.dateOfBirth),
                      _InfoItem(Icons.wc_rounded, 'Gender', s.gender),
                      _InfoItem(Icons.school_rounded, 'Qualification',
                          s.qualificationLabel,
                          full: true),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Course ───────────────────────────────────────────────
                  _Section(
                    icon: Icons.menu_book_rounded,
                    title: 'Course Details',
                    children: [
                      _InfoItem(Icons.auto_stories_rounded, 'Course name',
                          s.courseName,
                          full: true),
                      _InfoItem(
                          Icons.schedule_rounded,
                          'Duration',
                          s.durationMonths > 0
                              ? '${s.durationMonths} Months'
                              : ''),
                      _InfoItem(Icons.public_rounded, 'Course mode',
                          _cap(s.courseMode)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Address ──────────────────────────────────────────────
                  _Section(
                    icon: Icons.location_on_rounded,
                    title: 'Address',
                    children: [
                      _InfoItem(Icons.home_rounded, 'Address', s.address,
                          full: true),
                      _InfoItem(
                          Icons.place_rounded,
                          'District & State',
                          [s.district, s.state]
                              .where((e) => e.isNotEmpty)
                              .join(', ')),
                      _InfoItem(Icons.pin_drop_rounded, 'Pincode', s.pincode),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Marketing ────────────────────────────────────────────
                  _Section(
                    icon: Icons.campaign_rounded,
                    title: 'Marketing & Counseling',
                    children: [
                      _InfoItem(Icons.campaign_rounded, 'Source', s.source),
                      _InfoItem(Icons.support_agent_rounded, 'Counsellor',
                          s.counsellor),
                    ],
                  ),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Header helpers ────────────────────────────────────────────────────────
  Widget _bubble(double size, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white.withValues(alpha: alpha),
        ),
      );

  Widget _glassButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.20),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white.withValues(alpha: 0.35)),
        ),
        child: Icon(icon, color: AppColors.white, size: 17),
      ),
    );
  }

  Widget _heroChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.30)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: AppColors.white),
        const SizedBox(width: 5),
        Text(text,
            style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.white)),
      ]),
    );
  }

  Widget _heroStatus(bool taken) {
    final color = taken ? AppColors.c3 : AppColors.c2;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 5)
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(taken ? 'Admitted' : 'Pending',
            style: TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.w800, color: color)),
      ]),
    );
  }

  Widget _actionButton(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: AppColors.c1),
          const SizedBox(width: 7),
          Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.c1)),
        ]),
      ),
    );
  }

  Widget _factTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.14),
              color.withValues(alpha: 0.04),
            ],
          ),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: AppColors.white),
          ),
          const SizedBox(height: 8),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.cdark)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ctext)),
        ]),
      ),
    );
  }
}

// ─── Section card with a 2-column info grid ──────────────────────────────────
class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final bool full;
  final Color? valueColor;
  final VoidCallback? onCopy;
  const _InfoItem(this.icon, this.label, this.value,
      {this.full = false, this.valueColor, this.onCopy});
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<_InfoItem> children;
  final Color? accent;
  const _Section({
    required this.icon,
    required this.title,
    required this.children,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final color = accent ?? AppColors.c1;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.c1.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // section header
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.10),
                color.withValues(alpha: 0.02),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.30),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, size: 18, color: AppColors.white),
            ),
            const SizedBox(width: 10),
            Text(title,
                style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.cdark)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
          child: LayoutBuilder(builder: (context, c) {
            const gap = 10.0;
            final half = (c.maxWidth - gap) / 2;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: children
                  .map((e) => SizedBox(
                        width: e.full ? c.maxWidth : half,
                        child: _InfoTile(item: e),
                      ))
                  .toList(),
            );
          }),
        ),
      ]),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final _InfoItem item;
  const _InfoTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final empty = item.value.trim().isEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.cxl,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cborder.withValues(alpha: 0.7)),
      ),
      child: Row(children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.c1.withValues(alpha: 0.15)),
          ),
          child: Icon(item.icon, size: 16, color: AppColors.c1),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ctext)),
            const SizedBox(height: 3),
            Text(empty ? '—' : item.value,
                maxLines: item.full ? 3 : 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: empty
                        ? AppColors.ctext.withValues(alpha: 0.6)
                        : (item.valueColor ?? AppColors.cdark))),
          ]),
        ),
        if (item.onCopy != null && !empty)
          GestureDetector(
            onTap: item.onCopy,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.c1.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.copy_rounded,
                  size: 15, color: AppColors.c1),
            ),
          ),
      ]),
    );
  }
}