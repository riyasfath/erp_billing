import 'package:erp_academy/core/app_colors.dart';
import 'package:erp_academy/core/utils/coming_soon.dart';
import 'package:erp_academy/core/utils/currency_format.dart';
import 'package:erp_academy/core/utils/text_format.dart';
import 'package:erp_academy/models/dashboard_model.dart';
import 'package:erp_academy/views/logout/logout_button.dart';
import 'package:erp_academy/widgets/header_action.dart';
import 'package:erp_academy/widgets/status_chip.dart';
import 'package:erp_academy/widgets/student_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/auth_viewmodel.dart';
import '../../../viewmodels/dashboard_viewmodel.dart';
import '../../../viewmodels/nav_viewmodel.dart';

const _purple = Color(0xFF6D28D9);
const _purpleSoft = Color(0xFFF3EEFF);
const _blue = Color(0xFF2563EB);
const _blueSoft = Color(0xFFEAF1FF);
const _green = Color(0xFF16A34A);
const _greenSoft = Color(0xFFEAF8EF);
const _orange = Color(0xFFEA580C);
const _orangeSoft = Color(0xFFFFF1E7);
const _border = Color(0xFFE9EAF0);
const _bg = Color(0xFFF8F9FC);

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String _today() {
    final d = DateTime.now();
    return '${_days[d.weekday - 1]}, ${_months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final name = context.watch<AuthViewModel>().user?.name ?? '';
    final d = vm.data;

    return Container(
      color: _bg,
      child: RefreshIndicator(
        onRefresh: vm.load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          children: [
            _header(name),
            const SizedBox(height: 18),
            _quickActions(context),
            const SizedBox(height: 18),
            if (vm.loading && d == null)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (vm.error != null && d == null)
              _errorCard(vm)
            else if (d != null) ...[
              _stats(d.stats),
              const SizedBox(height: 18),
              _RevenueCard(data: d),
              const SizedBox(height: 18),
              _EnrollmentsCard(items: d.enrollments),
              const SizedBox(height: 18),
              _RecentStudentsCard(items: d.recentInterns),
              const SizedBox(height: 18),
              _FacultyCard(items: d.topFaculty),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------- Header ----------------
  Widget _header(String name) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 12, color: _purple),
                  const SizedBox(width: 5),
                  Text(_today(),
                      style: const TextStyle(
                          fontSize: 12,
                          color: _purple,
                          fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 4),
                Text(
                    name.isEmpty
                        ? '${_greeting()},'
                        : '${_greeting()}, ${TextFormat.pretty(name)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800)),
                const Text('Academic Dashboard · students, courses & faculty',
                    style: TextStyle(fontSize: 12, color: AppColors.muted)),
              ]),
        ),
        const HeaderActions(),
        const LogoutButton(),
      ]);

  // ---------------- Quick actions ----------------
  Widget _quickActions(BuildContext context) {
    final nav = context.read<NavViewModel>();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        _chip(Icons.menu_book_outlined, 'Courses', _purple, Colors.white,
            () => nav.setIndex(1)),
        const SizedBox(width: 8),
        _chip(Icons.school_outlined, 'Students', _blueSoft, _blue,
            () => nav.setIndex(3)),
        const SizedBox(width: 8),
        _chip(Icons.layers_outlined, 'Classes', _greenSoft, _green,
            () => nav.setIndex(4)),
        const SizedBox(width: 8),
        _chip(Icons.person_add_alt_1_outlined, 'Add Student', _orangeSoft,
            _orange, () => showComingSoon(context, 'Add Student')),
      ]),
    );
  }

  Widget _chip(IconData i, String t, Color bg, Color fg, VoidCallback onTap) =>
      Material(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              Icon(i, size: 18, color: fg),
              const SizedBox(width: 8),
              Text(t,
                  style: TextStyle(
                      color: fg, fontSize: 13, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      );

  // ---------------- Stats ----------------
  Widget _stats(DashboardStats s) => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.35,
        children: [
          _statCard(Icons.school_outlined, 'Active Students',
              s.activeStudents, _blue, _blueSoft, 'TOTAL', AppColors.muted),
          _statCard(Icons.menu_book_outlined, 'Active Courses',
              s.activeCourses, _purple, _purpleSoft, 'Live', _purple),
          _statCard(Icons.how_to_reg_outlined, 'Total Faculty',
              s.facultyCount, _green, _greenSoft, '↗ High', _green),
          _statCard(Icons.credit_card_outlined, 'Pending Payments',
              s.pendingPayments, _orange, _orangeSoft, 'Action', _orange),
        ],
      );

  Widget _statCard(IconData icon, String label, int value, Color color,
          Color bg, String tag, Color tagColor) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: _box(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: color),
            ),
            const Spacer(),
            Text(tag,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: tagColor)),
          ]),
          const Spacer(),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 2),
          Text('$value',
              style:
                  const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        ]),
      );

  Widget _errorCard(DashboardViewModel vm) => Container(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
        decoration: _box(),
        child: Column(children: [
          const Icon(Icons.cloud_off, size: 40, color: AppColors.muted),
          const SizedBox(height: 10),
          Text(vm.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted)),
          TextButton(onPressed: vm.load, child: const Text('Retry')),
        ]),
      );
}

BoxDecoration _box() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _border),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(.03), blurRadius: 10)
      ],
    );

Widget _cardTitle(IconData icon, String title, Color color,
        {Widget? trailing}) =>
    Row(children: [
      Icon(icon, size: 20, color: color),
      const SizedBox(width: 8),
      Expanded(
        child: Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      ),
      if (trailing != null) trailing,
    ]);

/// 128241.14 → "1.3L", 15000 → "15K"
String _compactInr(double v) {
  if (v >= 10000000) return '₹${(v / 10000000).toStringAsFixed(1)}Cr';
  if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
  if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(0)}K';
  return '₹${v.toStringAsFixed(0)}';
}

// =====================================================================
// Revenue snapshot (bar chart + list)
// =====================================================================
class _RevenueCard extends StatelessWidget {
  const _RevenueCard({required this.data});
  final AcademicDashboard data;

  @override
  Widget build(BuildContext context) {
    final items = data.revenue;
    final max = items.isEmpty
        ? 1.0
        : items.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardTitle(Icons.trending_up, 'Revenue Snapshot', _green),
        const SizedBox(height: 4),
        Text('Total ${CurrencyFormat.inr(data.totalRevenue)} in last '
            '${items.length} months',
            style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 18),
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
                child: Text('No revenue data',
                    style: TextStyle(color: AppColors.muted))),
          )
        else ...[
          SizedBox(
            height: 170,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: items.map((r) {
                final h = max <= 0 ? 0.0 : (r.amount / max) * 120;
                final isMax = r.amount == max;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(_compactInr(r.amount),
                          style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: isMax ? _green : AppColors.muted)),
                      const SizedBox(height: 4),
                      Container(
                        height: h < 4 ? 4 : h,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: isMax
                                ? const [Color(0xFF16A34A), Color(0xFF4ADE80)]
                                : const [
                                    Color(0xFF7C3AED),
                                    Color(0xFFA78BFA)
                                  ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(r.month,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 8),
          ...items.reversed.map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  Container(
                      width: 3,
                      height: 22,
                      decoration: BoxDecoration(
                          color: _green,
                          borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 10),
                  Text('Month: ${r.month}',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.muted)),
                  const Spacer(),
                  Text(CurrencyFormat.inr(r.amount),
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800)),
                ]),
              )),
        ],
      ]),
    );
  }
}

// =====================================================================
// Course enrollments
// =====================================================================
class _EnrollmentsCard extends StatelessWidget {
  const _EnrollmentsCard({required this.items});
  final List<EnrollmentPoint> items;

  @override
  Widget build(BuildContext context) {
    final max = items.isEmpty
        ? 1
        : items.map((e) => e.students).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardTitle(Icons.pie_chart_outline, 'Course Enrollments', _purple),
        const SizedBox(height: 14),
        if (items.isEmpty)
          const Text('No enrollments yet',
              style: TextStyle(color: AppColors.muted))
        else
          ...items.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(children: [
                  Row(children: [
                    Expanded(
                      child: Text(e.course,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text('${e.students} Students',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w800)),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: max == 0 ? 0 : e.students / max,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFEDEBFA),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(_purple),
                    ),
                  ),
                ]),
              )),
      ]),
    );
  }
}

// =====================================================================
// Recent students
// =====================================================================
class _RecentStudentsCard extends StatelessWidget {
  const _RecentStudentsCard({required this.items});
  final List<RecentIntern> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardTitle(
          Icons.groups_outlined,
          'Recent Students',
          _blue,
          trailing: TextButton(
            onPressed: () => context.read<NavViewModel>().setIndex(3),
            child: const Text('View All',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 6),
        if (items.isEmpty)
          const Text('No recent students',
              style: TextStyle(color: AppColors.muted))
        else
          ...List.generate(items.length, (i) {
            final s = items[i];
            return Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(children: [
                  StudentAvatar(name: s.name, size: 38),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(TextFormat.pretty(s.name),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(s.course ?? 'Not Assigned',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.muted,
                                  fontStyle: s.course == null
                                      ? FontStyle.italic
                                      : FontStyle.normal)),
                        ]),
                  ),
                  StatusChip(s.status, small: true),
                ]),
              ),
              if (i != items.length - 1)
                const Divider(height: 1, color: _border),
            ]);
          }),
      ]),
    );
  }
}

// =====================================================================
// Faculty directory
// =====================================================================
class _FacultyCard extends StatelessWidget {
  const _FacultyCard({required this.items});
  final List<TopFaculty> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardTitle(Icons.badge_outlined, 'Faculty Directory', _green),
        const SizedBox(height: 10),
        if (items.isEmpty)
          const Text('No faculty data',
              style: TextStyle(color: AppColors.muted))
        else
          ...items.map((f) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: _bg, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  StudentAvatar(name: f.name, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(TextFormat.pretty(f.name),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700)),
                          Text('${f.students} Students',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.muted)),
                        ]),
                  ),
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                        color: _green, shape: BoxShape.circle),
                  ),
                ]),
              )),
      ]),
    );
  }
}