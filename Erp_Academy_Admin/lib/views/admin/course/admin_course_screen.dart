import 'package:erp_academy/core/app_colors.dart';
import 'package:erp_academy/core/utils/currency_format.dart';
import 'package:erp_academy/models/course_item_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/course_viewmodel.dart';
import 'course_details_screen.dart';

const _purple = Color(0xFF7C3AED);
const _purpleSoft = Color(0xFFF3EEFF);
const _green = Color(0xFF16A34A);
const _greenSoft = Color(0xFFEAF8EF);
const _amber = Color(0xFFF59E0B);
const _amberSoft = Color(0xFFFFF7E6);
const _cardBorder = Color(0xFFE9EAF0);

class AdminCoursesScreen extends StatefulWidget {
  const AdminCoursesScreen({super.key});

  @override
  State<AdminCoursesScreen> createState() => _AdminCoursesScreenState();
}

class _AdminCoursesScreenState extends State<AdminCoursesScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _search.text = context.read<CourseViewModel>().query;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: error ? AppColors.red : null,
      ));
  }

  void _openDetail(CourseItem c) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CourseDetailScreen(course: c)),
    );
  }

  Future<void> _confirmDelete(CourseItem c) async {
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
    if (ok != true || !mounted) return;
    final err = await context.read<CourseViewModel>().deleteCourse(c.id);
    if (!mounted) return;
    err == null
        ? _snack('"${c.title}" deleted')
        : _snack(err, error: true);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CourseViewModel>();
    final list = vm.courses;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: RefreshIndicator(
        onRefresh: vm.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            _header(),
            const SizedBox(height: 14),
            _stats(vm),
            const SizedBox(height: 14),
            _filters(vm),
            const SizedBox(height: 16),
            if (vm.loading && vm.totalCount == 0)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (vm.error != null && vm.totalCount == 0)
              _message(
                icon: Icons.cloud_off,
                text: vm.error!,
                action: 'Retry',
                onTap: vm.load,
              )
            else if (list.isEmpty)
              _message(
                icon: Icons.menu_book_outlined,
                text: vm.hasFilters
                    ? 'No courses match your filters'
                    : 'No courses yet',
                action: vm.hasFilters ? 'Clear filters' : null,
                onTap: () {
                  _search.clear();
                  vm.clearFilters();
                },
              )
            else
              ...list.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _CourseCard(
                      course: c,
                      deleting: vm.deletingIds.contains(c.id),
                      onView: () => _openDetail(c),
                      onDelete: () => _confirmDelete(c),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  // ---------------- Header ----------------
  Widget _header() => Container(
        padding: const EdgeInsets.all(16),
        decoration: _box(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: _purpleSoft,
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.menu_book_outlined, color: _purple),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Course Management',
                  style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ),
          ]),
          const SizedBox(height: 8),
          const Text(
              'Manage your academic courses, faculty assignments, and installment fee structures',
              style: TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () => _snack('Create Course is coming soon'),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Create Course',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ]),
      );

  // ---------------- Stats ----------------
  Widget _stats(CourseViewModel vm) => Row(children: [
        Expanded(
            child: _statCard('TOTAL', vm.totalCount, Colors.black87,
                Icons.menu_book_outlined, _purple, _purpleSoft)),
        const SizedBox(width: 10),
        Expanded(
            child: _statCard('ACTIVE', vm.activeCount, _green,
                Icons.people_outline, _green, _greenSoft)),
        const SizedBox(width: 10),
        Expanded(
            child: _statCard('INACTIVE', vm.inactiveCount, _amber,
                Icons.edit_outlined, _amber, _amberSoft)),
      ]);

  Widget _statCard(String label, int value, Color valueColor, IconData icon,
          Color iconColor, Color iconBg) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: _box(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 10,
                      letterSpacing: .8,
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted)),
            ),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 14, color: iconColor),
            ),
          ]),
          const SizedBox(height: 8),
          Text('$value',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: valueColor)),
        ]),
      );

  // ---------------- Search + filters ----------------
  Widget _filters(CourseViewModel vm) => Container(
        padding: const EdgeInsets.all(12),
        decoration: _box(),
        child: Column(children: [
          TextField(
            controller: _search,
            onChanged: vm.search,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search by course title or keyword...',
              hintStyle: const TextStyle(fontSize: 13, color: AppColors.muted),
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: vm.query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        _search.clear();
                        vm.search('');
                      }),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _cardBorder)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _purple)),
            ),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: _dropdown<CourseStatusFilter>(
                value: vm.statusFilter,
                items: const {
                  CourseStatusFilter.all: 'All Status',
                  CourseStatusFilter.active: 'Active',
                  CourseStatusFilter.inactive: 'Inactive',
                },
                onChanged: (v) => vm.setStatusFilter(v!),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _dropdown<String?>(
                value: vm.department,
                items: {
                  null: 'All Categories',
                  for (final d in vm.departments) d: d,
                },
                onChanged: vm.setDepartment,
              ),
            ),
          ]),
        ]),
      );

  Widget _dropdown<T>({
    required T value,
    required Map<T, String> items,
    required ValueChanged<T?> onChanged,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
            border: Border.all(color: _cardBorder),
            borderRadius: BorderRadius.circular(12)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            items: items.entries
                .map((e) => DropdownMenuItem<T>(
                      value: e.key,
                      child: Text(e.value,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      );

  Widget _message({
    required IconData icon,
    required String text,
    String? action,
    VoidCallback? onTap,
  }) =>
      Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Column(children: [
          Icon(icon, size: 44, color: AppColors.muted),
          const SizedBox(height: 10),
          Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted)),
          if (action != null) ...[
            const SizedBox(height: 10),
            TextButton(onPressed: onTap, child: Text(action)),
          ],
        ]),
      );
}

BoxDecoration _box() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _cardBorder),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(.03), blurRadius: 10)
      ],
    );

// ---------------- Course card ----------------
class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.course,
    required this.deleting,
    required this.onView,
    required this.onDelete,
  });

  final CourseItem course;
  final bool deleting;
  final VoidCallback onView;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final c = course;
    return GestureDetector(
      onTap: onView, // tap anywhere on the card opens details
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: _box(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 6,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6366F1), _purple]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    if (c.departmentName.isNotEmpty)
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              color: const Color(0xFFE8EEFF),
                              borderRadius: BorderRadius.circular(20)),
                          child: Text(c.departmentName.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 10,
                                  letterSpacing: .8,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF3B5BDB))),
                        ),
                      ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: c.isActive ? _greenSoft : _amberSoft,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: (c.isActive ? _green : _amber)
                                .withOpacity(.4)),
                      ),
                      child: Text(c.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: c.isActive
                                  ? _green
                                  : const Color(0xFFB45309))),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Text(c.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                  if (c.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(c.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.muted)),
                  ],
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FC),
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      Expanded(
                        child: _info('ENROLLED', Icons.people_outline,
                            '${c.studentsCount} Students'),
                      ),
                      Expanded(
                        child: _info('COURSE FEE', null,
                            CurrencyFormat.inr(c.totalFee),
                            valueColor: _purple),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  const Text('ASSIGNED FACULTY',
                      style: TextStyle(
                          fontSize: 10,
                          letterSpacing: .8,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted)),
                  const SizedBox(height: 6),
                  if (c.faculties.isEmpty)
                    const Text('No faculty assigned',
                        style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: AppColors.muted))
                  else
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: c.faculties
                          .map((f) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    color: _purpleSoft,
                                    borderRadius: BorderRadius.circular(6)),
                                child: Text(f.name,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: _purple)),
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onView,
                        icon: const Icon(Icons.remove_red_eye_outlined,
                            size: 16),
                        label: const Text('View'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _purple,
                          side: const BorderSide(color: _cardBorder),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: deleting ? null : onDelete,
                        icon: deleting
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.delete_outline, size: 16),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.red,
                          side:
                              BorderSide(color: AppColors.red.withOpacity(.3)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ]),
                ]),
          ),
        ]),
      ),
    );
  }

  Widget _info(String label, IconData? icon, String value,
          {Color valueColor = Colors.black87}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                letterSpacing: .8,
                fontWeight: FontWeight.w700,
                color: AppColors.muted)),
        const SizedBox(height: 4),
        Row(children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: _purple),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: valueColor)),
          ),
        ]),
      ]);
}