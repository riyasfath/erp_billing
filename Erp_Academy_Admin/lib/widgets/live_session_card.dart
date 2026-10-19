import 'package:erp_academy/models/live_session.dart';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class LiveSessionCard extends StatelessWidget {
  final LiveSession session;
  const LiveSessionCard(this.session, {super.key});

  @override
  Widget build(BuildContext context) {
    final s = session;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 12)
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 150,
            width: double.infinity,
            color: Colors.blueGrey.shade200, // TODO: Image.asset
            child: Stack(children: [
              const Center(
                  child: Icon(Icons.groups, size: 56, color: Colors.white70)),
              Positioned(
                  left: 8, top: 8, child: _pill(s.startedAgo, Colors.white, AppColors.text)),
              if (s.isLive)
                Positioned(
                    right: 8, top: 8, child: _pill('Live', AppColors.red, Colors.white)),
              Positioned(
                  right: 8,
                  bottom: 8,
                  child: _pill('${s.viewers} viewers', Colors.black87, Colors.white)),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
              child: Text(s.tag,
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600))),
          Text(s.module, style: const TextStyle(fontSize: 12)),
        ]),
        const SizedBox(height: 6),
        Text(s.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Row(children: [
          const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.lightBlue,
              child: Icon(Icons.person, size: 18)),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.facultyName,
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            Text(s.facultyRole,
                style: const TextStyle(fontSize: 10, color: AppColors.muted)),
          ]),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: _btn(Icons.shield_outlined, 'Join as Moderator',
                  AppColors.navy, Colors.white)),
          const SizedBox(width: 8),
          Expanded(
              child: _btn(Icons.speed, 'Stream Health', AppColors.lightBlue,
                  AppColors.primary)),
        ]),
      ]),
    );
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
}