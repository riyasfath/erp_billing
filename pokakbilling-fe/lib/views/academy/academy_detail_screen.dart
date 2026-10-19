import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokakbilling/models/academy_models/academy_model.dart';
import 'package:pokakbilling/views/academy/academy_extras.dart';
import 'package:pokakbilling/views/academy/academy_theme.dart';
import 'package:pokakbilling/views/academy/academy_widgets.dart';

// ═════════════════════════════════════════════════════════════════════════════
// Colour hierarchy
//   • Cyan   → MAIN     (app bar, contact, main sections)
//   • Violet → SUB-MAIN (secondary sections, copy-email, slot-paid accent)
//   • Orange → VERY SUB (tiny accents: Pending status, one fact tile)
// ═════════════════════════════════════════════════════════════════════════════
const Color _kPageBg = Color(0xFFF0FAFD);
const Color _kInk = Color(0xFF0F172A);
const Color _kSlate = Color(0xFF64748B);
const Color _kLine = Color(0xFFD9ECF2);

const Color _kCyan = Color(0xFF06B6D4);
const Color _kCyanLight = Color(0xFF67E8F9);
const Color _kCyanDeep = Color(0xFF0E7490);
const Color _kViolet = Color(0xFF8B5CF6);
const Color _kOrange = Color(0xFFF97316);

const LinearGradient _kHeaderGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [_kCyanDeep, _kCyan, _kCyanLight],
);

Color _shade(Color c, double amt) => Color.lerp(c, Colors.black, amt)!;
Color _tint(Color c, double amt) => Color.lerp(c, Colors.white, amt)!;

class AcadFact {
  final IconData icon;
  final String label, value;
  final Color color;
  const AcadFact(this.icon, this.label, this.value, this.color);
}

class AcadDetailItem {
  final IconData icon;
  final String label, value;
  final bool full, copy;
  final Color? valueColor;
  const AcadDetailItem(this.icon, this.label, this.value,
      {this.full = false, this.copy = false, this.valueColor});
}

class AcadDetailSection {
  final String title;
  final IconData icon;
  final List<AcadDetailItem> items;
  final Color? accent;
  const AcadDetailSection(this.title, this.icon, this.items, {this.accent});
}

class AcademyDetailScreen extends StatelessWidget {
  final String title, name, phone, email, date, status;
  final String? code;
  final Color accent;
  final List<AcadFact> facts;
  final List<AcadDetailSection> sections;

  const AcademyDetailScreen({
    super.key,
    required this.title,
    required this.name,
    required this.phone,
    required this.email,
    required this.date,
    required this.status,
    required this.accent,
    required this.facts,
    required this.sections,
    this.code,
  });

  // ── Builders ───────────────────────────────────────────────────────────────
  static AcademyDetailScreen registration(AcadRegistration r) {
    // Slot paid → violet, Pending → cyan (status pill turns orange when Pending)
    final accent = r.hasSlot ? _kViolet : _kCyan;
    return AcademyDetailScreen(
      title: 'Candidate Details',
      name: r.name,
      phone: r.phone,
      email: r.email,
      date: acadDate(r.date),
      code: r.code,
      status: r.hasSlot ? 'Slot Paid' : 'Pending',
      accent: accent,
      facts: [
        AcadFact(Icons.menu_book_rounded, 'Course',
            r.course.isEmpty ? '—' : r.course, _kCyan),
        AcadFact(Icons.support_agent_rounded, 'Counsellor',
            r.counsellor.isEmpty ? '—' : r.counsellor, _kViolet),
        AcadFact(Icons.event_seat_rounded, 'Slot',
            r.hasSlot ? acadInr(r.slotAmount) : 'Not paid', _kOrange),
      ],
      sections: [
        AcadDetailSection('Contact', Icons.person_rounded, [
          AcadDetailItem(Icons.email_rounded, 'Email address', r.email,
              full: true, copy: true),
          AcadDetailItem(Icons.phone_rounded, 'Phone', r.phone,
              full: true, copy: true),
        ], accent: _kCyan),
        AcadDetailSection('Registration', Icons.how_to_reg_rounded, [
          AcadDetailItem(Icons.tag_rounded, 'Registration ID', r.code),
          AcadDetailItem(Icons.event_rounded, 'Registered on', acadDate(r.date)),
          AcadDetailItem(Icons.verified_rounded, 'Admission', 'Pending',
              valueColor: _kOrange),
          AcadDetailItem(Icons.event_seat_rounded, 'Slot amount',
              r.hasSlot ? acadInr(r.slotAmount) : 'Not paid'),
        ], accent: accent),
        AcadDetailSection('Course & Counsellor', Icons.menu_book_rounded, [
          AcadDetailItem(Icons.auto_stories_rounded, 'Course', r.course,
              full: true),
          AcadDetailItem(
              Icons.support_agent_rounded, 'Counsellor', r.counsellor,
              full: true),
        ], accent: _kViolet),
      ],
    );
  }

  static AcademyDetailScreen admission(AcadAdmission a) {
    final p = a.payment;
    // Paid → violet, no payment → cyan
    final accent = a.hasPayment ? _kViolet : _kCyan;
    return AcademyDetailScreen(
      title: 'Student Details',
      name: a.name,
      phone: a.phone,
      email: a.email,
      date: acadDate(a.date),
      code: a.studentId,
      status: 'Admitted',
      accent: accent,
      facts: [
        AcadFact(Icons.menu_book_rounded, 'Course',
            a.course.isEmpty ? '—' : a.course, _kCyan),
        AcadFact(Icons.support_agent_rounded, 'Counsellor',
            a.counsellor.isEmpty ? '—' : a.counsellor, _kViolet),
        AcadFact(Icons.savings_rounded, 'Paid',
            p == null ? 'No payment' : acadInr(p.amount), _kOrange),
      ],
      sections: [
        AcadDetailSection('Contact', Icons.person_rounded, [
          AcadDetailItem(Icons.email_rounded, 'Email address', a.email,
              full: true, copy: true),
          AcadDetailItem(Icons.phone_rounded, 'Phone', a.phone,
              full: true, copy: true),
        ], accent: _kCyan),
        AcadDetailSection('Admission', Icons.school_rounded, [
          AcadDetailItem(Icons.badge_rounded, 'Student ID', a.studentId),
          AcadDetailItem(Icons.event_rounded, 'Admitted on', acadDate(a.date)),
          AcadDetailItem(Icons.auto_stories_rounded, 'Course', a.course,
              full: true),
          AcadDetailItem(
              Icons.support_agent_rounded, 'Counsellor', a.counsellor,
              full: true),
        ], accent: accent),
        AcadDetailSection(
            'First Payment',
            Icons.account_balance_wallet_rounded,
            p == null
                ? const [
                    AcadDetailItem(
                        Icons.hourglass_empty_rounded, 'Status', 'No payment yet',
                        full: true)
                  ]
                : [
                    AcadDetailItem(
                        Icons.currency_rupee_rounded, 'Amount', acadInr(p.amount),
                        valueColor: _kCyanDeep),
                    AcadDetailItem(Icons.category_rounded, 'Type',
                        acadCategoryLabel(p.type)),
                    AcadDetailItem(acadMethodIcon(p.method), 'Method',
                        acadMethodLabel(p.method)),
                    AcadDetailItem(
                        Icons.event_rounded, 'Date', acadDate(p.date)),
                    AcadDetailItem(
                        Icons.receipt_rounded, 'Transaction ID', p.transactionId,
                        full: true, copy: true),
                  ],
            accent: _kViolet),
      ],
    );
  }

  void _copy(BuildContext context, String label, String value) {
    if (value.trim().isEmpty) return;
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$label copied', style: const TextStyle(fontSize: 15)),
      backgroundColor: _kCyan,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;

    return Scaffold(
      backgroundColor: _kPageBg,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          Container(
            clipBehavior: Clip.antiAlias,
            padding: EdgeInsets.only(
                top: mq.padding.top + 12,
                bottom: 26,
                left: sw * .05,
                right: sw * .05),
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
            child: Stack(clipBehavior: Clip.none, children: [
              Positioned(right: -40, top: -30, child: _bubble(140, 0.10)),
              Positioned(left: -30, bottom: -50, child: _bubble(100, 0.08)),
              Positioned(
                right: 6,
                top: 56,
                child: Transform.rotate(
                  angle: -0.25,
                  child: Icon(Icons.person_rounded,
                      size: 92, color: Colors.white.withValues(alpha: 0.12)),
                ),
              ),
              Column(children: [
                Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 19),
                    ),
                  ),
                  Expanded(
                    child: Text(title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 42),
                ]),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.38),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: AcademyAvatar(name: name, size: 76),
                  ),
                ),
                const SizedBox(height: 12),
                Text(name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (code != null && code!.isNotEmpty)
                      _heroChip(Icons.tag_rounded, code!),
                    _heroChip(Icons.event_rounded, date),
                    _heroStatus(),
                  ],
                ),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                    child: _actionButton(Icons.phone_rounded, 'Copy Phone',
                        _kCyan, () => _copy(context, 'Phone number', phone)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _actionButton(Icons.email_rounded, 'Copy Email',
                        _kViolet, () => _copy(context, 'Email', email)),
                  ),
                ]),
              ]),
            ]),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 18, 16, mq.padding.bottom + 28),
            child: Column(children: [
              Row(children: [
                for (var i = 0; i < facts.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  _factTile(facts[i]),
                ],
              ]),
              const SizedBox(height: 16),
              for (final s in sections) ...[
                _Section(section: s, onCopy: (l, v) => _copy(context, l, v)),
                const SizedBox(height: 14),
              ],
            ]),
          ),
        ],
      ),
    );
  }

  Widget _bubble(double size, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: alpha),
        ),
      );

  Widget _heroChip(IconData icon, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.34)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(text,
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
        ]),
      );

  Widget _heroStatus() {
    final c = status == 'Pending' ? _kOrange : accent;
    return _heroStatusBox(c);
  }

  Widget _heroStatusBox(Color accent) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: accent.withValues(alpha: 0.6), blurRadius: 5)
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(status,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: _shade(accent, 0.15))),
        ]),
      );

  Widget _actionButton(
          IconData icon, String label, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _shade(color, 0.1))),
          ]),
        ),
      );

  Widget _factTile(AcadFact f) => Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: f.color.withValues(alpha: 0.20)),
            boxShadow: [
              BoxShadow(
                color: f.color.withValues(alpha: 0.14),
                blurRadius: 12,
                offset: const Offset(0, 5),
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
                        f.color.withValues(alpha: 0.10),
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
                  height: 4,
                  decoration: BoxDecoration(
                    gradient:
                        LinearGradient(colors: [_tint(f.color, 0.25), f.color]),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 14),
                child: Column(children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_tint(f.color, 0.22), f.color],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: f.color.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(f.icon, size: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(f.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: _kInk)),
                  const SizedBox(height: 2),
                  Text(f.label,
                      style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: _shade(f.color, 0.1))),
                ]),
              ),
            ]),
          ),
        ),
      );
}

// ═════════════════════════════════════════════════════════════════════════════
// Section card
// ═════════════════════════════════════════════════════════════════════════════
class _Section extends StatelessWidget {
  final AcadDetailSection section;
  final void Function(String label, String value) onCopy;
  const _Section({required this.section, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    final color = section.accent ?? _kCyan;
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
        child: Stack(children: [
          // accent bar (Stack instead of IntrinsicHeight: LayoutBuilder below
          // does not support intrinsic sizing)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 6,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_tint(color, 0.25), color],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 6),
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
                        child:
                            Icon(section.icon, size: 19, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Text(section.title,
                          style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: _kInk)),
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
                        children: section.items
                            .map((e) => SizedBox(
                                  width: e.full ? c.maxWidth : half,
                                  child: _Tile(
                                      item: e, color: color, onCopy: onCopy),
                                ))
                            .toList(),
                      );
                    }),
                  ),
                ]),
          ),
        ]),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final AcadDetailItem item;
  final Color color;
  final void Function(String, String) onCopy;
  const _Tile({required this.item, required this.color, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    final empty = item.value.trim().isEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
      decoration: BoxDecoration(
        color: _kPageBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kLine),
      ),
      child: Row(children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(item.icon, size: 16, color: _shade(color, 0.1)),
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
                    color: _kSlate)),
            const SizedBox(height: 3),
            Text(empty ? '—' : item.value,
                maxLines: item.full ? 3 : 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: empty
                        ? _kSlate.withValues(alpha: 0.6)
                        : (item.valueColor ?? _kInk))),
          ]),
        ),
        if (item.copy && !empty)
          GestureDetector(
            onTap: () => onCopy(item.label, item.value),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.copy_rounded, size: 15, color: color),
            ),
          ),
      ]),
    );
  }
}