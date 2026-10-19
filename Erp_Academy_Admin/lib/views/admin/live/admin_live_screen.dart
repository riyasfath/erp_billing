import 'package:erp_academy/core/app_colors.dart';
import 'package:erp_academy/widgets/header_action.dart';
import 'package:erp_academy/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/live_viewmodel.dart';

class AdminLiveScreen extends StatelessWidget {
  const AdminLiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LiveViewModel>();
    const tabs = ['Live Now (1)', 'Upcoming (8)', 'Past (45)'];

    return Stack(children: [
      ListView(padding: const EdgeInsets.fromLTRB(20, 14, 20, 90), children: [
        const Row(children: [
          Expanded(
              child: Text('Live Session',
                  style:
                      TextStyle(fontSize: 24, fontWeight: FontWeight.w700))),
          HeaderActions(),
        ]),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: const Color(0xFFF5F6F8),
              borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: List.generate(3, (i) {
              final sel = vm.tabIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => vm.setTab(i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        color: sel ? Colors.white : null,
                        borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.center,
                    child: Text(tabs[i],
                        style: TextStyle(
                            fontSize: 12,
                            color: sel ? AppColors.primary : AppColors.text,
                            fontWeight:
                                sel ? FontWeight.w600 : FontWeight.w400)),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 24),
        const SectionTitle('Active Transmission', action: 'Real-time Telemetry'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(.08), blurRadius: 12)
              ]),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 150,
                width: double.infinity,
                color: Colors.blueGrey.shade200, // TODO: Image.asset
                child: Stack(children: [
                  const Center(
                      child: Icon(Icons.groups,
                          size: 56, color: Colors.white70)),
                  Positioned(
                      left: 8,
                      top: 8,
                      child:
                          _pill('Started 18m ago', Colors.white, AppColors.text)),
                  Positioned(
                      right: 8,
                      top: 8,
                      child: _pill('Live', AppColors.red, Colors.white)),
                  Positioned(
                      right: 8,
                      bottom: 8,
                      child: _pill('64 viewers', Colors.black87, Colors.white)),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('AI & MACHINE LEARNING SPECIALIZATION',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                  Text('Module 2', style: TextStyle(fontSize: 12)),
                ]),
            const SizedBox(height: 6),
            const Text('Deep Learning & Neural Networks\n- Week 6 Q&A',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            const Row(children: [
              CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.lightBlue,
                  child: Icon(Icons.person, size: 18)),
              SizedBox(width: 8),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Dr. Julian Aris',
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700)),
                Text('Lead Faculty • Studio B',
                    style:
                        TextStyle(fontSize: 10, color: AppColors.muted)),
              ]),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: _btn(Icons.shield_outlined, 'Join as Moderator',
                      AppColors.navy, Colors.white)),
              const SizedBox(width: 8),
              Expanded(
                  child: _btn(Icons.speed, 'Stream Health',
                      AppColors.lightBlue, AppColors.primary)),
            ]),
          ]),
        ),
        const SizedBox(height: 24),
        const SectionTitle('Recent Recordings', action: 'View All 45'),
        const SizedBox(height: 12),
        ...vm.recordings.map((r) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                        child: Text(r.title,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600))),
                    const Icon(Icons.check_circle, color: AppColors.primary),
                  ]),
                  Text(r.meta,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.muted)),
                  const SizedBox(height: 10),
                  _tag(Icons.cloud_done_outlined, r.processing),
                  const SizedBox(height: 6),
                  _tag(Icons.upload, r.published),
                  const SizedBox(height: 10),
                  Text(r.views,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.muted)),
                ])),
      ]),
      Positioned(
        right: 20,
        bottom: 16,
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Schedule Class'),
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: const StadiumBorder()),
        ),
      ),
    ]);
  }

  Widget _pill(String t, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(5)),
        child: Text(t, style: TextStyle(fontSize: 9, color: fg)),
      );

  Widget _btn(IconData i, String t, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(i, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(t,
              style: TextStyle(
                  fontSize: 12, color: fg, fontWeight: FontWeight.w600))
        ]),
      );

  Widget _tag(IconData i, String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
            color: AppColors.lightBlue,
            borderRadius: BorderRadius.circular(6)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(i, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(t, style: const TextStyle(fontSize: 11))
        ]),
      );
}