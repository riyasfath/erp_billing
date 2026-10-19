import 'package:erp_academy/core/app_colors.dart';
import 'package:erp_academy/models/modules_item.dart';
import 'package:erp_academy/widgets/page_header.dart';
import 'package:erp_academy/widgets/underline_tabs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/module_service.dart';
import '../../../viewmodels/module_detail_viewmodel.dart';
import 'upload_video_screen.dart';

class ModuleDetailScreen extends StatelessWidget {
  final String course;
  final ModuleItem module;
  const ModuleDetailScreen(
      {super.key, required this.course, required this.module});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => ModuleDetailViewModel(ModuleService(), module.number),
        child: _Body(course: course, module: module),
      );
}

class _Body extends StatelessWidget {
  final String course;
  final ModuleItem module;
  const _Body({required this.course, required this.module});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ModuleDetailViewModel>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Column(children: [
            PageHeader(course),
            const SizedBox(height: 18),
            // Modules tab selected. Tapping Live goes back to course page.
            UnderlineTabs(
                tabs: const ['Modules', 'Live'],
                index: 0,
                onChanged: (i) {
                  if (i == 1) Navigator.of(context).pop();
                }),
            Expanded(
              child: vm.loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 90),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Module ${module.number}: ${module.name}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF374151))),
                                const SizedBox(height: 4),
                                Text(
                                    '${vm.lessons.length} lessons • ${module.duration} total',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.muted)),
                              ]),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                              color: const Color(0xFFEDEDED),
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(module.description,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF374151))),
                        ),
                        const SizedBox(height: 14),
                        ...vm.lessons.map((l) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFFE5E7EB)),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Row(children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    width: 80,
                                    height: 58,
                                    color: l.color,
                                    child: const Icon(Icons.play_circle_outline,
                                        color: Colors.white70),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(l.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 14)),
                                        const SizedBox(height: 6),
                                        Text(l.duration,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: AppColors.muted)),
                                      ]),
                                ),
                              ]),
                            )),
                      ],
                    ),
            ),
          ]),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 16,
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                      builder: (_) => const UploadVideoScreen())),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                decoration: BoxDecoration(
                    color: const Color(0xFFDDE3FA),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(.12),
                          blurRadius: 10)
                    ]),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.bolt, size: 18, color: AppColors.text),
                  SizedBox(width: 8),
                  Text('Upload Video',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}