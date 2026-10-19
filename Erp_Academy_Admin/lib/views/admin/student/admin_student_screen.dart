import 'package:erp_academy/core/app_colors.dart';
import 'package:erp_academy/core/utils/coming_soon.dart';
import 'package:erp_academy/core/utils/date_format.dart';
import 'package:erp_academy/models/student_model.dart';
import 'package:erp_academy/views/admin/student/student_profile_screen.dart';
import 'package:erp_academy/widgets/status_chip.dart';
import 'package:erp_academy/widgets/student_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/student_viewmodel.dart';

const _purple = Color(0xFF6D28D9);
const _purpleSoft = Color(0xFFF3EEFF);
const _green = Color(0xFF16A34A);
const _greenSoft = Color(0xFFEAF8EF);
const _grey = Color(0xFF6B7280);
const _greySoft = Color(0xFFF1F2F4);
const _red = Color(0xFFDC2626);
const _border = Color(0xFFE9EAF0);
const _bg = Color(0xFFF8F9FC);

class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _search.text = context.read<StudentViewModel>().query;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _open(StudentListItem s) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => StudentProfileScreen(student: s)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudentViewModel>();
    final list = vm.students;

    return Scaffold(
      backgroundColor: _bg,
      body: RefreshIndicator(
        onRefresh: vm.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            _header(),
            const SizedBox(height: 12),
            _exportRow(),
            const SizedBox(height: 14),
            _stats(vm),
            const SizedBox(height: 14),
            _filters(vm),
            const SizedBox(height: 12),
            if (!vm.loading && vm.totalCount > 0)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                    'Showing ${list.length} of ${vm.totalCount} students',
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.muted)),
              ),
            if (vm.loading && vm.totalCount == 0)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (vm.error != null && vm.totalCount == 0)
              _message(Icons.cloud_off, vm.error!, 'Retry', vm.load)
            else if (list.isEmpty)
              _message(
                Icons.person_search_outlined,
                vm.hasFilters
                    ? 'No students match your filters'
                    : 'No students yet',
                vm.hasFilters ? 'Reset filters' : null,
                () {
                  _search.clear();
                  vm.clearFilters();
                },
              )
            else
              ...list.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _StudentCard(student: s, onOpen: () => _open(s)),
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
              child: const Icon(Icons.school_outlined, color: _purple),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Manage Students',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800)),
                    SizedBox(height: 2),
                    Text(
                        'View and manage student profiles and registration reports',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.muted)),
                  ]),
            ),
          ]),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () => showComingSoon(context, 'Add Student'),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add Student',
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

  Widget _exportRow() => Row(children: [
        Expanded(
            child: _exportBtn(Icons.remove_red_eye_outlined, 'View PDF',
                _purple, 'View PDF')),
        const SizedBox(width: 8),
        Expanded(
            child: _exportBtn(
                Icons.picture_as_pdf_outlined, 'Export PDF', _red, 'Export PDF')),
        const SizedBox(width: 8),
        Expanded(
            child: _exportBtn(
                Icons.grid_on_outlined, 'Excel', _green, 'Export Excel')),
      ]);

  Widget _exportBtn(IconData icon, String label, Color color, String feature) =>
      OutlinedButton.icon(
        onPressed: () => showComingSoon(context, feature),
        icon: Icon(icon, size: 16),
        label: Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          backgroundColor: color.withOpacity(.05),
          side: BorderSide(color: color.withOpacity(.25)),
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

  // ---------------- Stats ----------------
  Widget _stats(StudentViewModel vm) => Row(children: [
        Expanded(
            child: _statCard('TOTAL', vm.totalCount, _purple,
                Icons.groups_outlined, _purpleSoft)),
        const SizedBox(width: 10),
        Expanded(
            child: _statCard('ACTIVE', vm.activeCount, _green,
                Icons.verified_outlined, _greenSoft)),
        const SizedBox(width: 10),
        Expanded(
            child: _statCard('INACTIVE', vm.inactiveCount, _grey,
                Icons.pause_circle_outline, _greySoft)),
      ]);

  Widget _statCard(
          String label, int value, Color color, IconData icon, Color bg) =>
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
                  color: bg, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 14, color: color),
            ),
          ]),
          const SizedBox(height: 8),
          Text('$value',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w800, color: color)),
        ]),
      );

  // ---------------- Filters ----------------
  Widget _filters(StudentViewModel vm) => Container(
        padding: const EdgeInsets.all(12),
        decoration: _box(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
            controller: _search,
            onChanged: vm.search,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search code, name, phone, email...',
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
                  borderSide: const BorderSide(color: _border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _purple)),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _dropdown<String?>(
                value: vm.center,
                items: {null: 'All Center', for (final c in vm.centers) c: c},
                onChanged: vm.setCenter,
              ),
              const SizedBox(width: 8),
              _dropdown<String?>(
                value: vm.course,
                items: {
                  null: 'All Course',
                  for (final c in vm.courseNames) c: c
                },
                onChanged: vm.setCourse,
              ),
              const SizedBox(width: 8),
              _dropdown<String?>(
                value: vm.batch,
                items: {null: 'All Batch', for (final b in vm.batches) b: b},
                onChanged: vm.setBatch,
              ),
              const SizedBox(width: 8),
              _dropdown<StudentStatusFilter>(
                value: vm.status,
                items: const {
                  StudentStatusFilter.all: 'All Status',
                  StudentStatusFilter.active: 'Active',
                  StudentStatusFilter.inactive: 'Inactive',
                  StudentStatusFilter.completed: 'Completed',
                },
                onChanged: (v) => vm.setStatus(v ?? StudentStatusFilter.all),
              ),
              if (vm.hasFilters) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    _search.clear();
                    vm.clearFilters();
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Reset'),
                ),
              ],
            ]),
          ),
        ]),
      );

  Widget _dropdown<T>({
    required T value,
    required Map<T, String> items,
    required ValueChanged<T?> onChanged,
  }) =>
      Container(
        width: 150,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(10)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, size: 18),
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

  Widget _message(
          IconData icon, String text, String? action, VoidCallback onTap) =>
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
      border: Border.all(color: _border),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(.03), blurRadius: 10)
      ],
    );

// ---------------- Student card ----------------
class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student, required this.onOpen});

  final StudentListItem student;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final s = student;
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _box(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            StudentAvatar(
                name: s.fullName, imageUrl: s.profileImage, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Row(children: [
                      const Icon(Icons.mail_outline,
                          size: 13, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(s.loginEmail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.muted)),
                      ),
                    ]),
                  ]),
            ),
            const SizedBox(width: 8),
            StatusChip(s.status, small: true),
          ]),
          const SizedBox(height: 12),
          Wrap(spacing: 6, runSpacing: 6, children: [
            _tag(Icons.badge_outlined, s.studentCode, highlight: true),
            _tag(Icons.menu_book_outlined,
                s.hasCourse ? s.courseTitle : 'Not Assigned',
                muted: !s.hasCourse),
            if (s.batchNumber != null)
              _tag(Icons.groups_outlined, s.batchNumber!),
            if (s.centerName.isNotEmpty)
              _tag(Icons.location_on_outlined, s.centerName),
            if (s.counsellorName.isNotEmpty)
              _tag(Icons.support_agent, s.counsellorName),
            _tag(Icons.calendar_today_outlined, AppDate.format(s.startDate)),
          ]),
          const SizedBox(height: 10),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 6),
          Row(children: [
            _iconBtn(Icons.remove_red_eye_outlined, _purple, onOpen),
            _iconBtn(Icons.edit_outlined, const Color(0xFF2563EB),
                () => showComingSoon(context, 'Edit Student')),
            _iconBtn(Icons.delete_outline, _red,
                () => showComingSoon(context, 'Delete Student')),
            const Spacer(),
            SizedBox(
              height: 36,
              child: ElevatedButton.icon(
                onPressed: () => showComingSoon(context, 'Create Receipt'),
                icon: const Icon(Icons.receipt_long_outlined, size: 16),
                label: const Text('Create Receipt',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _tag(IconData icon, String text,
          {bool highlight = false, bool muted = false}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: highlight ? _purpleSoft : const Color(0xFFF5F6F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon,
              size: 13,
              color: highlight ? _purple : AppColors.muted),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
                    fontStyle: muted ? FontStyle.italic : FontStyle.normal,
                    color: highlight
                        ? _purple
                        : (muted ? AppColors.muted : Colors.black87))),
          ),
        ]),
      );

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) =>
      IconButton(
        onPressed: onTap,
        visualDensity: VisualDensity.compact,
        icon: Icon(icon, size: 20, color: color),
      );
}