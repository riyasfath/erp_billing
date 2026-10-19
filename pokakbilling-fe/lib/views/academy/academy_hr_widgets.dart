import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/academy_models/academy_hr_model.dart';
import 'package:pokakbilling/models/academy_models/academy_model.dart';
import 'package:pokakbilling/views/academy/academy_extras.dart';
import 'package:pokakbilling/views/academy/academy_theme.dart';
import 'package:pokakbilling/views/academy/academy_widgets.dart';

// ── Status helpers ───────────────────────────────────────────────────────────
Color hrStatusColor(String s) {
  switch (s) {
    case 'approved':
      return kAcadGreen;
    case 'rejected':
      return AppColors.red;
    default:
      return AppColors.c2;
  }
}

String hrStatusLabel(String s) {
  switch (s) {
    case 'approved':
      return 'Approved';
    case 'rejected':
      return 'Rejected';
    case 'submitted':
      return 'Pending HR';
    default:
      return s.isEmpty ? '—' : s[0].toUpperCase() + s.substring(1);
  }
}

IconData hrStatusIcon(String s) {
  switch (s) {
    case 'approved':
      return Icons.verified_rounded;
    case 'rejected':
      return Icons.cancel_rounded;
    default:
      return Icons.hourglass_top_rounded;
  }
}

List<AcadStat> hrSummaryStats(AcadConvSummary s) => [
      AcadStat('Admissions', '${s.newAdmissions}', AppColors.c3,
          Icons.school_rounded),
      AcadStat('Registered', '${s.newRegistrations}', AppColors.c1,
          Icons.how_to_reg_rounded),
      AcadStat('Students', '${s.totalStudents}', AppColors.c2,
          Icons.groups_rounded),
      AcadStat('Collected', acadInrShort(s.totalCollected), kAcadGreen,
          Icons.savings_rounded),
    ];

// ── Gradient hero ────────────────────────────────────────────────────────────
class HrHeroCard extends StatelessWidget {
  final String title, line1;
  final String? line2, status;
  final IconData icon;
  const HrHeroCard({
    super.key,
    required this.title,
    required this.line1,
    this.line2,
    this.status,
    this.icon = Icons.assignment_turned_in_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.c1.withValues(alpha: 0.80), AppColors.c1],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withValues(alpha: 0.32),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(clipBehavior: Clip.none, children: [
        Positioned(
          right: -20,
          top: -20,
          child: Icon(icon,
              size: 110, color: AppColors.white.withValues(alpha: 0.10)),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: AppColors.white.withValues(alpha: 0.35)),
              ),
              child: const Text('COUNSELLOR CONVERSION',
                  style: TextStyle(
                      fontSize: 10.5,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white)),
            ),
            const Spacer(),
            if (status != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(hrStatusIcon(status!),
                      size: 13, color: hrStatusColor(status!)),
                  const SizedBox(width: 4),
                  Text(hrStatusLabel(status!),
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: hrStatusColor(status!))),
                ]),
              ),
          ]),
          const SizedBox(height: 14),
          Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.date_range_rounded,
                size: 15, color: AppColors.white.withValues(alpha: 0.9)),
            const SizedBox(width: 5),
            Flexible(
              child: Text(line1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.92),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
          if (line2 != null && line2!.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(line2!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.80),
                    fontSize: 12.5)),
          ],
        ]),
      ]),
    );
  }
}

// ── One admission / registration row ─────────────────────────────────────────
class HrRecordTile extends StatelessWidget {
  final AcadConvRecord r;
  const HrRecordTile({super.key, required this.r});

  @override
  Widget build(BuildContext context) {
    final accent = r.isAdmission ? AppColors.c3 : AppColors.c2;
    final p = r.payment;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [accent.withValues(alpha: 0.08), AppColors.white],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(children: [
        Row(children: [
          AcademyAvatar(name: r.name, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.cdark)),
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.phone_rounded,
                    size: 12.5, color: AppColors.c1),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(r.phone,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12.5, color: AppColors.ctext)),
                ),
              ]),
            ]),
          ),
          const SizedBox(width: 8),
          AcadStatusPill(
              label: r.isAdmission ? 'Admission' : 'Registration',
              color: accent),
        ]),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(spacing: 6, runSpacing: 6, children: [
            if (r.studentId.isNotEmpty)
              AcadMiniTag(text: r.studentId, icon: Icons.badge_rounded),
            if (r.course.isNotEmpty)
              AcadMiniTag(
                  text: r.course,
                  icon: Icons.menu_book_rounded,
                  color: AppColors.c3),
            if (p != null)
              AcadMiniTag(
                  text: '${acadInr(p.amount)} · ${acadMethodLabel(p.method)}',
                  icon: acadMethodIcon(p.method),
                  color: kAcadGreen),
            AcadMiniTag(
                text: acadDate(r.date),
                icon: Icons.event_rounded,
                color: AppColors.ctext),
          ]),
        ),
      ]),
    );
  }
}

// ── Remarks bottom sheet (used for submit + approve/reject) ──────────────────
class HrRemarksSheet extends StatefulWidget {
  final String title, subtitle, confirmLabel;
  final Color color;
  final IconData icon;
  final bool remarksRequired;
  final String? periodLabel; // when set, shows an editable period field

  const HrRemarksSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.confirmLabel,
    required this.color,
    required this.icon,
    this.remarksRequired = false,
    this.periodLabel,
  });

  @override
  State<HrRemarksSheet> createState() => _HrRemarksSheetState();
}

class _HrRemarksSheetState extends State<HrRemarksSheet> {
  late final TextEditingController _period =
      TextEditingController(text: widget.periodLabel ?? '');
  final TextEditingController _remarks = TextEditingController();
  String? _err;

  @override
  void dispose() {
    _period.dispose();
    _remarks.dispose();
    super.dispose();
  }

  void _confirm() {
    if (widget.periodLabel != null && _period.text.trim().isEmpty) {
      setState(() => _err = 'Enter a period label');
      return;
    }
    if (widget.remarksRequired && _remarks.text.trim().isEmpty) {
      setState(() => _err = 'Remarks are required');
      return;
    }
    Navigator.pop(context, (_period.text.trim(), _remarks.text.trim()));
  }

  InputDecoration _dec(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.ctext, fontSize: 14.5),
        prefixIcon: Icon(icon, color: AppColors.c1, size: 20),
        filled: true,
        fillColor: AppColors.cxl,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.cborder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.cborder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: widget.color, width: 1.6),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.fromLTRB(18, 10, 18, mq.padding.bottom + 20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
                color: AppColors.cborder,
                borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(height: 16),
          Row(children: [
            AcadGradientIcon(
                icon: widget.icon, color: widget.color, size: 46, radius: 14),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.cdark)),
                    const SizedBox(height: 2),
                    Text(widget.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.ctext)),
                  ]),
            ),
          ]),
          const SizedBox(height: 16),
          if (widget.periodLabel != null) ...[
            TextField(
              controller: _period,
              decoration: _dec('Period label (e.g. October 2026)',
                  Icons.calendar_month_rounded),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _remarks,
            maxLines: 3,
            decoration: _dec(
                widget.remarksRequired ? 'Remarks (required)' : 'Remarks',
                Icons.edit_note_rounded),
          ),
          if (_err != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(_err!,
                  style: const TextStyle(
                      color: AppColors.red,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600)),
            ),
          ],
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.cxl,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cborder),
                  ),
                  child: const Text('Cancel',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ctext)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: HrGradientButton(
                label: widget.confirmLabel,
                icon: widget.icon,
                color: widget.color,
                onTap: _confirm,
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

// ── Gradient action button ───────────────────────────────────────────────────
class HrGradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool loading;
  const HrGradientButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null || loading;
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedOpacity(
        opacity: onTap == null ? 0.5 : 1,
        duration: const Duration(milliseconds: 200),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.80), color]),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (loading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: AppColors.white, strokeWidth: 2),
              )
            else ...[
              Icon(icon, color: AppColors.white, size: 19),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white)),
            ],
          ]),
        ),
      ),
    );
  }
}