import 'package:erp_academy/models/recording_item_model.dart';
import 'package:erp_academy/models/shedule_live_data.dart';

import '../models/live_session.dart';

class LiveService {
  Future<List<RecordingItem>> getRecordings() async => const [
        RecordingItem(
          'Distributed Systems & Consensus Models',
          'Concluded Yesterday • 1h 42m duration',
          'Cloud Processing Complete • 1.4 GB',
          'Auto-published to Module 4',
          '112 Student Views in 24h',
        ),
      ];

  Future<List<LiveSession>> getSessions({required bool completed}) async =>
      completed
          ? const [
              LiveSession(
                tag: 'DIGITAL MARKETING FOUNDATIONS',
                title: 'SEO Strategy Workshop - Week 3',
                module: 'Module 1',
                facultyName: 'Dr. Julian Aris',
                facultyRole: 'Lead Faculty • Studio A',
                startedAgo: 'Ended yesterday',
                viewers: 112,
                isLive: false,
              ),
            ]
          : const [
              LiveSession(
                tag: 'AI & MACHINE LEARNING SPECIALIZATION',
                title: 'Deep Learning & Neural Networks\n- Week 6 Q&A',
                module: 'Module 2',
                facultyName: 'Dr. Julian Aris',
                facultyRole: 'Lead Faculty • Studio B',
                startedAgo: 'Started 18m ago',
                viewers: 64,
                isLive: true,
              ),
            ];

  Future<List<String>> getMilestones() async => const [
        'Module 01: Foundations',
        'Module 02: AI & Machine Learning Specialization',
        'Module 04: Convolutional Neural Networks & Vision',
      ];

  /// Later: schedule API call.
  Future<bool> scheduleLive(ScheduleLiveData d) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  /// Later: save draft API call.
  Future<bool> saveDraft(ScheduleLiveData d) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }
}