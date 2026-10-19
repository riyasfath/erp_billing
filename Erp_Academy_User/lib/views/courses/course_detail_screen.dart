import 'package:erp_user/views/courses/live_tab.dart';
import 'package:erp_user/views/courses/modules_tab.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/widgets/image_placeholder.dart';
import '../../models/my_course.dart';
import '../../services/course_service.dart';
import '../../viewmodels/course_detail_viewmodel.dart';

class CourseDetailScreen extends StatelessWidget {
  final MyCourse course;
  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => CourseDetailViewModel(CourseService(), course),
        child: const _Body(),
      );
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CourseDetailViewModel>();
    final d = vm.detail;

    return Scaffold(
      backgroundColor: AppColors.page,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
            child: Row(children: [
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back)),
              const Text('Course Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ]),
          ),
          Expanded(
            child: d == null
                ? const Center(child: CircularProgressIndicator())
                : ListView(children: [
                    _header(vm.course),
                    _tabs(vm),
                    vm.tab == 0
                        ? ModulesTab(detail: d)
                        : LiveTab(detail: d),
                    const SizedBox(height: 24),
                  ]),
          ),
        ]),
      ),
    );
  }

  Widget _header(MyCourse c) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ImagePlaceholder(
              width: double.infinity, height: 190, radius: 16, color: c.color),
          const SizedBox(height: 14),
          Text(c.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(c.description,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.muted, height: 1.4)),
          const SizedBox(height: 14),
          Wrap(spacing: 10, runSpacing: 8, children: [
            _chip(Icons.person, c.instructor),
            _chip(Icons.person, '${c.participants} participants'),
          ]),
          const SizedBox(height: 16),
          Text('${c.progress}% Complete',
              style: const TextStyle(fontSize: 13, color: AppColors.muted)),
          const SizedBox(height: 8),
          FractionallySizedBox(
            widthFactor: .8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: c.progress / 100,
                minHeight: 5,
                backgroundColor: AppColors.chip,
                color: AppColors.indigo,
              ),
            ),
          ),
        ]),
      );

  Widget _chip(IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: const Color(0xFFEFEFF3),
            borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: AppColors.chipText),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF374151))),
        ]),
      );

  Widget _tabs(CourseDetailViewModel vm) => Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.border))),
        child: Row(
          children: List.generate(2, (i) {
            final sel = vm.tab == i;
            return Expanded(
              child: InkWell(
                onTap: () => vm.setTab(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color:
                                  sel ? AppColors.indigo : Colors.transparent,
                              width: 2.5))),
                  child: Text(['Modules', 'Live'][i],
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: sel ? AppColors.indigo : AppColors.muted)),
                ),
              ),
            );
          }),
        ),
      );
}