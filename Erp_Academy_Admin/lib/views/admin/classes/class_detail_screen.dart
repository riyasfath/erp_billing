import 'package:erp_academy/core/app_colors.dart';
import 'package:erp_academy/core/utils/coming_soon.dart';
import 'package:erp_academy/core/utils/date_format.dart';
import 'package:erp_academy/models/class_model.dart';
import 'package:erp_academy/services/class_service.dart';
import 'package:erp_academy/widgets/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/class_detail_viewmodel.dart';

const _purple = Color(0xFF6D28D9);
const _purpleSoft = Color(0xFFF3EEFF);
const _border = Color(0xFFE9EAF0);
const _bg = Color(0xFFF8F9FC);

class ClassDetailScreen extends StatelessWidget {
  const ClassDetailScreen({super.key, required this.item});

  final ClassItem item;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (ctx) => ClassDetailViewModel(ctx.read<ClassService>(), item),
        child: const _Body(),
      );
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ClassDetailViewModel>();
    final info = vm.info;
    final list = vm.sections;

    return Scaffold(
      backgroundColor: _bg,
      body: RefreshIndicator(
        onRefresh: vm.load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            // Breadcrumb / back
            Row(children: [
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back,
                    size: 20, color: Colors.black87),
                label: const Text('Classes',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87)),
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4)),
              ),
              const Icon(Icons.chevron_right,
                  size: 18, color: AppColors.muted),
              const Text('Class Detail',
                  style: TextStyle(fontSize: 13, color: AppColors.muted)),
            ]),
            const SizedBox(height: 6),

            // Header card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _box(),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                color: _purpleSoft,
                                borderRadius: BorderRadius.circular(14)),
                            child: const Icon(Icons.layers_outlined,
                                color: _purple, size: 26),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(info.name,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 2),
                                  Text(info.centerName,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.muted)),
                                ]),
                          ),
                          StatusChip(info.isActive ? 'Active' : 'Inactive',
                              small: true),
                        ]),
                    const SizedBox(height: 14),
                    Row(children: [
                      _infoPill(Icons.layers_outlined,
                          '${vm.detail?.sections.length ?? info.sectionsCount} Sections'),
                      const SizedBox(width: 8),
                      _infoPill(Icons.event_outlined,
                          'Created ${AppDate.format(info.createdAt)}'),
                    ]),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            showComingSoon(context, 'Add New Section'),
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Add New Section',
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
            ),
            const SizedBox(height: 14),

            // Filters
            TextField(
              controller: _search,
              onChanged: vm.search,
              decoration: InputDecoration(
                hintText: 'Search sections...',
                hintStyle:
                    const TextStyle(fontSize: 13, color: AppColors.muted),
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _purple)),
              ),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: _dropdown(
                  value: vm.course,
                  allLabel: 'All Courses',
                  options: vm.courses,
                  onChanged: vm.setCourse,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dropdown(
                  value: vm.batch,
                  allLabel: 'All Batches',
                  options: vm.batches,
                  onChanged: vm.setBatch,
                ),
              ),
            ]),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ClassDetailViewModel.days.map((d) {
                  final sel = vm.day == d;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(d),
                      selected: sel,
                      onSelected: (_) => vm.setDay(d),
                      showCheckmark: false,
                      selectedColor: _purple,
                      backgroundColor: const Color(0xFFF1F2F4),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: sel ? Colors.white : Colors.black87),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Sections
            if (vm.loading && vm.detail == null)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (vm.error != null && vm.detail == null)
              _empty(Icons.cloud_off, vm.error!, 'Retry', vm.load)
            else if (list.isEmpty)
              _empty(
                Icons.event_busy_outlined,
                'No sections found.',
                vm.hasFilters ? 'Clear filters' : null,
                () {
                  _search.clear();
                  vm.clearFilters();
                },
              )
            else
              ...list.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SectionCard(section: s),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _infoPill(IconData icon, String text) => Flexible(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
              color: const Color(0xFFF5F6F9),
              borderRadius: BorderRadius.circular(8)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 14, color: _purple),
            const SizedBox(width: 5),
            Flexible(
              child: Text(text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
      );

  Widget _dropdown({
    required String? value,
    required String allLabel,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(12)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            items: [
              DropdownMenuItem<String?>(value: null, child: Text(allLabel)),
              ...options.map((o) => DropdownMenuItem<String?>(
                    value: o,
                    child:
                        Text(o, maxLines: 1, overflow: TextOverflow.ellipsis),
                  )),
            ],
            onChanged: onChanged,
          ),
        ),
      );

  Widget _empty(
          IconData icon, String text, String? action, VoidCallback onTap) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        decoration: _box(),
        child: Column(children: [
          Icon(icon, size: 40, color: AppColors.muted),
          const SizedBox(height: 10),
          Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted)),
          if (action != null)
            TextButton(onPressed: onTap, child: Text(action)),
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

// ---------------- Section card ----------------
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});
  final ClassSection section;

  @override
  Widget build(BuildContext context) {
    final s = section;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _box(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
                color: _purpleSoft, borderRadius: BorderRadius.circular(10)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.schedule, size: 15, color: _purple),
              const SizedBox(width: 5),
              Text(s.time.isEmpty ? '—' : s.time,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _purple)),
            ]),
          ),
          const Spacer(),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => showComingSoon(context, 'Edit Section'),
            icon: const Icon(Icons.edit_outlined,
                size: 19, color: Color(0xFF2563EB)),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => showComingSoon(context, 'Delete Section'),
            icon: const Icon(Icons.delete_outline,
                size: 19, color: Color(0xFFDC2626)),
          ),
        ]),
        const SizedBox(height: 10),
        if (s.days.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: s.days
                .map((d) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF1F2F4),
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(d,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700)),
                    ))
                .toList(),
          ),
        const SizedBox(height: 12),
        Row(children: [
          _kv('Course', s.course.isEmpty ? '—' : s.course),
          _kv('Batch', s.batch.isEmpty ? '—' : s.batch),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _kv('Students', '${s.students}'),
          _kv('Duration', s.duration.isEmpty ? '—' : s.duration),
        ]),
      ]),
    );
  }

  Widget _kv(String label, String value) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: .7,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted)),
          const SizedBox(height: 2),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
        ]),
      );
}