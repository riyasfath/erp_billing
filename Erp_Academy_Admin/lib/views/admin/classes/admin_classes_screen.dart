import 'package:erp_academy/core/app_colors.dart';
import 'package:erp_academy/core/utils/coming_soon.dart';
import 'package:erp_academy/models/class_model.dart';
import 'package:erp_academy/views/admin/classes/class_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/class_viewmodel.dart';

const _purple = Color(0xFF6D28D9);
const _indigo = Color(0xFF4F46E5);
const _purpleSoft = Color(0xFFF3EEFF);
const _tint = Color(0xFFF1EEFB);
const _red = Color(0xFFDC2626);
const _border = Color(0xFFE9EAF0);
const _bg = Color(0xFFF8F9FC);

class AdminClassesScreen extends StatelessWidget {
  const AdminClassesScreen({super.key});

  void _open(BuildContext context, ClassItem c) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ClassDetailScreen(item: c)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ClassViewModel>();
    final list = vm.classes;

    return Scaffold(
      backgroundColor: _bg,
      body: RefreshIndicator(
        onRefresh: vm.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            _header(context, vm),
            const SizedBox(height: 14),
            _statsAndFilter(vm),
            const SizedBox(height: 16),
            if (vm.loading && vm.totalClasses == 0)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (vm.error != null && vm.totalClasses == 0)
              _message(Icons.cloud_off, vm.error!, 'Retry', vm.load)
            else if (list.isEmpty)
              _message(Icons.layers_clear_outlined, 'No classes found',
                  vm.centerId != null ? 'Show all centers' : null,
                  () => vm.setCenter(null))
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: .78,
                ),
                itemBuilder: (_, i) => _ClassCard(
                  item: list[i],
                  onOpen: () => _open(context, list[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, ClassViewModel vm) => Container(
        padding: const EdgeInsets.all(16),
        decoration: _box(),
        child: Column(children: [
          Row(children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                  color: _purpleSoft, shape: BoxShape.circle),
              child: const Icon(Icons.layers_outlined, color: _purple),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Classes',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800)),
                    Text('Manage classes and their sections',
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
              onPressed: () => _showAddClass(context, vm),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add New Class',
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

  Widget _statsAndFilter(ClassViewModel vm) => Row(children: [
        _miniStat('${vm.totalClasses}', 'Classes'),
        const SizedBox(width: 8),
        _miniStat('${vm.totalSections}', 'Sections'),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: _border),
                borderRadius: BorderRadius.circular(12)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: vm.centerId,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                items: [
                  const DropdownMenuItem<int?>(
                      value: null, child: Text('All Centers')),
                  ...vm.centers.map((c) => DropdownMenuItem<int?>(
                        value: c.$1,
                        child: Text(c.$2,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      )),
                ],
                onChanged: vm.setCenter,
              ),
            ),
          ),
        ),
      ]);

  Widget _miniStat(String value, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: _box(),
        child: Column(children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: _purple)),
          Text(label,
              style: const TextStyle(fontSize: 10, color: AppColors.muted)),
        ]),
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
          if (action != null)
            TextButton(onPressed: onTap, child: Text(action)),
        ]),
      );

  // ---------------- Add New Class dialog (UI ready, API pending) ----------
  void _showAddClass(BuildContext context, ClassViewModel vm) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    int? centerId;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: const EdgeInsets.fromLTRB(22, 22, 12, 0),
          title: Row(children: [
            const Expanded(
              child: Text('Add New Class',
                  style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ),
            IconButton(
                onPressed: () => Navigator.pop(dialogCtx),
                icon: const Icon(Icons.close)),
          ]),
          content: Form(
            key: formKey,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Class Name',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: _dec('Enter class name'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Class name is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('Center',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<int>(
                    value: centerId,
                    isExpanded: true,
                    decoration: _dec('Choose Center'),
                    items: vm.centers
                        .map((c) => DropdownMenuItem(
                            value: c.$1, child: Text(c.$2)))
                        .toList(),
                    onChanged: (v) => setState(() => centerId = v),
                    validator: (v) =>
                        v == null ? 'Please select a center' : null,
                  ),
                ]),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;
                Navigator.pop(dialogCtx);
                showComingSoon(context, 'Save Class');
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: _purple, foregroundColor: Colors.white),
              child: const Text('Save Class'),
            ),
          ],
        ),
      ),
    ).whenComplete(nameCtrl.dispose);
  }

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _purple)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _red)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _red)),
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

// ---------------- Class card ----------------
class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.item, required this.onOpen});

  final ClassItem item;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final c = item;
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: _box(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              color: _tint,
              child: Stack(children: [
                Center(
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                            color: _purple.withOpacity(.12), blurRadius: 12)
                      ],
                    ),
                    child: const Icon(Icons.layers_outlined,
                        color: _indigo, size: 28),
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 0,
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        size: 20, color: AppColors.muted),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    onSelected: (v) => showComingSoon(
                        context, v == 'edit' ? 'Edit Class' : 'Delete Class'),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 10),
                          Text('Edit'),
                        ]),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [
                          Icon(Icons.delete_outline, size: 18, color: _red),
                          SizedBox(width: 10),
                          Text('Delete', style: TextStyle(color: _red)),
                        ]),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14.5, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(c.centerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11.5, color: AppColors.muted)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: _purpleSoft,
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.layers_outlined,
                            size: 13, color: _purple),
                        const SizedBox(width: 4),
                        Text('${c.sectionsCount} Sections',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: _purple)),
                      ]),
                    ),
                  ]),
            ),
          ),
        ]),
      ),
    );
  }
}