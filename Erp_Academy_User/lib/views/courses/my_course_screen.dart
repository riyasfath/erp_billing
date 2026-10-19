import 'package:erp_user/viewmodels/my_course_viewmodel.dart';
import 'package:erp_user/views/courses/course_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/widgets/image_placeholder.dart';
import '../../models/my_course.dart';

class MyCoursesScreen extends StatelessWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MyCoursesViewModel>();
    return Container(
      color: AppColors.page,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text('My Course',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        ),
        const Divider(height: 1, color: AppColors.border),
        Expanded(
          child: vm.loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: vm.courses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, i) => _CourseCard(vm.courses[i]),
                ),
        ),
      ]),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final MyCourse c;
  const _CourseCard(this.c);

  void _open(BuildContext context) => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CourseDetailScreen(course: c)));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _open(context),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 12)
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ImagePlaceholder(
              width: double.infinity, height: 170, radius: 14, color: c.color),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: c.progress / 100,
                      minHeight: 4,
                      backgroundColor: const Color(0xFFE5E7EB),
                      color: AppColors.button,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${c.progress}%',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.muted)),
                const Expanded(flex: 2, child: SizedBox()),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: Wrap(spacing: 14, runSpacing: 6, children: [
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.person,
                          size: 16, color: AppColors.button),
                      const SizedBox(width: 4),
                      Text('${c.participants} Participants',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    ]),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.access_time_filled,
                          size: 16, color: AppColors.button),
                      const SizedBox(width: 4),
                      Text(c.date,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    ]),
                  ]),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _open(context),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D4ED8),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  child: const Text('Continue',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(height: 4),
            ]),
          ),
        ]),
      ),
    );
  }
}