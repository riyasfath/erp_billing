import 'package:erp_academy/core/app_colors.dart';
import 'package:erp_academy/core/utils/currency_format.dart';
import 'package:erp_academy/models/course_item_model.dart';
import 'package:erp_academy/models/installment_plan_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/course_detail_viewmodel.dart';
import '../../../viewmodels/course_viewmodel.dart';

const _purple = Color(0xFF6D28D9);
const _purpleSoft = Color(0xFFF3EEFF);
const _blue = Color(0xFF4F7FEF);
const _green = Color(0xFF16A34A);
const _greenSoft = Color(0xFFEAF8EF);
const _amber = Color(0xFFB45309);
const _amberSoft = Color(0xFFFFF7E6);
const _border = Color(0xFFE9EAF0);
const _bg = Color(0xFFF8F9FC);

class CourseDetailScreen extends StatelessWidget {
  final CourseItem course;
  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => CourseDetailViewModel(course),
        child: const _Body(),
      );
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CourseDetailViewModel>();
    final c = vm.course;

    return Scaffold(
      backgroundColor: _bg,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _backButton(context),
          const SizedBox(height: 8),
          _header(context, c),
          const SizedBox(height: 18),
          _tabBar(vm),
          const SizedBox(height: 16),
          switch (vm.tab) {
            0 => _StudyMaterialsTab(vm: vm),
            1 => _EnrolledTab(course: c),
            2 => _FeeTab(course: c),
            3 => _FacultyTab(course: c),
            _ => const _EmptyCard(
                icon: Icons.event_note_outlined,
                text: 'No classes scheduled for this batch.'),
          },
        ],
      ),
    );
  }

  // ---------------- Back ----------------
  Widget _backButton(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, size: 20, color: Colors.black87),
          label: const Text('Back to Courses',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87)),
          style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4)),
        ),
      );

  // ---------------- Header card ----------------
  Widget _header(BuildContext context, CourseItem c) => Container(
        padding: const EdgeInsets.all(16),
        decoration: _box(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                  color: _blue, borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.menu_book_outlined,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.title,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800)),
                    if (c.description.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(c.description,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.muted)),
                    ],
                  ]),
            ),
            IconButton(
              tooltip: 'Delete course',
              onPressed: () => _confirmDelete(context, c),
              style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFFFEEEE)),
              icon: const Icon(Icons.delete_outline, color: AppColors.red),
            ),
          ]),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (c.departmentName.isNotEmpty)
              _pill(c.departmentName.toUpperCase(), const Color(0xFFE8EEFF),
                  const Color(0xFF3B5BDB)),
            c.isActive
                ? _pill('Active', _greenSoft, _green)
                : _pill('Inactive', _amberSoft, _amber),
            _pill('${c.studentsCount} Students', _purpleSoft, _purple),
            _pill(CurrencyFormat.inr(c.totalFee), const Color(0xFFF1F5F9),
                Colors.black87),
          ]),
        ]),
      );

  Future<void> _confirmDelete(BuildContext context, CourseItem c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete course'),
        content: Text('Delete "${c.title}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.red))),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    final err = await context.read<CourseViewModel>().deleteCourse(c.id);
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    if (err == null) {
      Navigator.of(context).pop();
      messenger.showSnackBar(SnackBar(content: Text('"${c.title}" deleted')));
    } else {
      messenger.showSnackBar(
          SnackBar(content: Text(err), backgroundColor: AppColors.red));
    }
  }

  // ---------------- Tabs ----------------
  Widget _tabBar(CourseDetailViewModel vm) => Container(
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: _border))),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(CourseDetailViewModel.tabs.length, (i) {
              final sel = vm.tab == i;
              return GestureDetector(
                onTap: () => vm.setTab(i),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
                  margin: const EdgeInsets.only(right: 22),
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: sel ? _purple : Colors.transparent,
                            width: 2.5)),
                  ),
                  child: Text(CourseDetailViewModel.tabs[i],
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                          color: sel ? Colors.black : AppColors.muted)),
                ),
              );
            }),
          ),
        ),
      );
}

// =====================================================================
// Study Materials
// =====================================================================
class _StudyMaterialsTab extends StatelessWidget {
  const _StudyMaterialsTab({required this.vm});
  final CourseDetailViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextField(
        onChanged: vm.searchMaterials,
        decoration: _inputDecoration('Search materials...', Icons.search),
      ),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: _border),
                borderRadius: BorderRadius.circular(10)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: vm.materialType,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                items: CourseDetailViewModel.materialTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: vm.setMaterialType,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add Material is coming soon'))),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Material',
                style: TextStyle(fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ]),
      const SizedBox(height: 16),
      const _EmptyCard(
          icon: Icons.folder_open_outlined,
          text: 'No study materials found for this batch.'),
    ]);
  }
}

// =====================================================================
// Enrolled Students
// =====================================================================
class _EnrolledTab extends StatelessWidget {
  const _EnrolledTab({required this.course});
  final CourseItem course;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: _box(),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: _purpleSoft, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.people_outline, color: _purple),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('TOTAL ENROLLED',
                style: TextStyle(
                    fontSize: 10,
                    letterSpacing: .8,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted)),
            const SizedBox(height: 2),
            Text('${course.studentsCount} Students',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          ]),
        ]),
      ),
      const SizedBox(height: 16),
      _EmptyCard(
          icon: Icons.person_search_outlined,
          text: course.studentsCount == 0
              ? 'No students enrolled in this course yet.'
              : 'Student list will be shown here.'),
    ]);
  }
}

// =====================================================================
// Fee Configuration (real data)
// =====================================================================
class _FeeTab extends StatelessWidget {
  const _FeeTab({required this.course});
  final CourseItem course;

  @override
  Widget build(BuildContext context) {
    final c = course;
    final taxAmount = c.totalFee * c.totalTaxPercentage / 100;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: _box(),
        child: Column(children: [
          _feeRow('Course Fee', CurrencyFormat.inr(c.totalFee)),
          _feeRow('SGST (${CurrencyFormat.percent(c.sgst)})',
              CurrencyFormat.inr(c.totalFee * c.sgst / 100)),
          _feeRow('CGST (${CurrencyFormat.percent(c.cgst)})',
              CurrencyFormat.inr(c.totalFee * c.cgst / 100)),
          _feeRow('Total Tax (${CurrencyFormat.percent(c.totalTaxPercentage)})',
              CurrencyFormat.inr(taxAmount)),
          const Divider(height: 22),
          _feeRow('Total Payable', CurrencyFormat.inr(c.totalFee + taxAmount),
              bold: true),
        ]),
      ),
      const SizedBox(height: 18),
      const Text('INSTALLMENT PLANS',
          style: TextStyle(
              fontSize: 11,
              letterSpacing: .8,
              fontWeight: FontWeight.w700,
              color: AppColors.muted)),
      const SizedBox(height: 10),
      if (c.installmentPlans.isEmpty)
        const _EmptyCard(
            icon: Icons.payments_outlined,
            text: 'No installment plans configured.')
      else
        ...c.installmentPlans.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PlanCard(plan: p),
            )),
    ]);
  }

  Widget _feeRow(String label, String value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: bold ? 15 : 13,
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                    color: bold ? Colors.black : AppColors.muted)),
          ),
          Text(value,
              style: TextStyle(
                  fontSize: bold ? 17 : 14,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
                  color: bold ? _purple : Colors.black87)),
        ]),
      );
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan});
  final InstallmentPlan plan;

  @override
  Widget build(BuildContext context) {
    final p = plan;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _box(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('${p.totalInstallments} Installments',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const Spacer(),
          p.isActive
              ? _pill('Active', _greenSoft, _green)
              : _pill('Inactive', _amberSoft, _amber),
        ]),
        const SizedBox(height: 10),
        ...p.items.map((i) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                  color: _bg, borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: _purpleSoft,
                  child: Text('${i.installmentNumber}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _purple)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Due in ${i.dueDays} days',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.muted)),
                ),
                Text(CurrencyFormat.inr(i.amount),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800)),
              ]),
            )),
      ]),
    );
  }
}

// =====================================================================
// Faculty (real data)
// =====================================================================
class _FacultyTab extends StatelessWidget {
  const _FacultyTab({required this.course});
  final CourseItem course;

  @override
  Widget build(BuildContext context) {
    if (course.faculties.isEmpty) {
      return const _EmptyCard(
          icon: Icons.person_off_outlined, text: 'No faculty assigned.');
    }
    return Column(
      children: course.faculties
          .map((f) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: _box(),
                child: Row(children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: _purpleSoft,
                    child: Text(_initials(f.name),
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, color: _purple)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(f.name,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                  const Text('Faculty',
                      style: TextStyle(fontSize: 12, color: AppColors.muted)),
                ]),
              ))
          .toList(),
    );
  }

  static String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

// =====================================================================
// Shared bits
// =====================================================================
class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Column(children: [
          Icon(icon, size: 40, color: AppColors.muted.withOpacity(.6)),
          const SizedBox(height: 10),
          Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.muted)),
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

Widget _pill(String text, Color bg, Color fg) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w800, color: fg)),
    );

InputDecoration _inputDecoration(String hint, IconData icon) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: AppColors.muted),
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _purple)),
    );