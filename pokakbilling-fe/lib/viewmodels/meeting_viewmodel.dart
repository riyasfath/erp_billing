import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/models/data-models/meeting_model.dart';
import 'package:pokakbilling/models/services/meeting_services.dart';
import 'package:pokakbilling/views/Screens/leads/meeting/meeting.dart';
import 'package:pokakbilling/views/Screens/leads/meeting/shedule_dialoge.dart';

class MeetingViewmodel extends ChangeNotifier {
  String selectedTime = "";
  DateTime selectedDate = DateTime.now();
  int selectedTimeIndex = 0;

  bool createLoading = false;
  bool getMeetingLoader = false;

  var meetingList = <MeetingModel>[];

  String selectedStatus = "";
  String selectedStatusKey = "";

  final List<String> timeSlots = [
    "09:00:00",
    "10:00:00",
    "11:00:00",
    "12:00:00",
    "13:00:00",
    "14:00:00",
    "15:00:00",
    "16:00:00",
    "17:00:00",
  ];

  var statusList = ["Scheduled", "Completed", "Cancelled"];

  MeetingViewmodel() {
    getAllMeetings();
  }

  /// ✅ RESET (for session expiry)
  void reset() {
    meetingList = [];
    selectedTime = "";
    selectedDate = DateTime.now();
    selectedTimeIndex = 0;
    selectedStatus = "";
    selectedStatusKey = "";
    createLoading = false;
    getMeetingLoader = false;
    notifyListeners();
  }

  /// (optional alias)
  void clearData() => reset();

  void selectStatus(String status) {
    selectedStatus = status;

    switch (status) {
      case "Scheduled":
        selectedStatusKey = "scheduled";
        break;
      case "Completed":
        selectedStatusKey = "completed";
        break;
      case "Cancelled":
        selectedStatusKey = "canceled";
        break;
      default:
        selectedStatusKey = "";
    }

    notifyListeners();
  }

  void updateTimeIndex(String time, int index) {
    selectedTime = time;
    selectedTimeIndex = index;
    notifyListeners();
  }

  void updateDate(DateTime newDate) {
    selectedDate = newDate;
    notifyListeners();
  }

  Future<void> createMeetingSchedule(
    int leadId,
    String date,
    String time,
    String status,
    String title,
    BuildContext context, {
    String? meetingType,
    String? meetingPlace,
    String? description,
  }) async {
    try {
      createLoading = true;
      notifyListeners();

      String? response = await MeetingServices.createMeeting(
        leadId: leadId,
        date: date,
        time: time,
        status: status,
        title: title,
        meetingType: meetingType,
        meetingPlace: meetingPlace,
        description: description,
      );

      if (response == null) {
        await getAllMeetings();
        if (!context.mounted) return;

        createLoading = false;
        notifyListeners();

        // await showDialog(
        //   context: context,
        //   builder: (BuildContext ctx) => const MeetingScheduledDialog(),
        // );
        // if (!context.mounted) return;
        // pushAndRemoveUntilFun(context, const MeetingScreen());
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext ctx) => const MeetingScheduledDialog(),
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            Navigator.of(context, rootNavigator: true).pop(); // close dialog

            pushAndRemoveUntilFun(
              context,
              const MeetingScreen(),
            );
          }
        });
      } else {
        if (!context.mounted) return;

        createLoading = false;
        notifyListeners();

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(response)));
      }
    } catch (e) {
      debugPrint('createMeetingSchedule error: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create meeting')),
        );
      }
    } finally {
      createLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAllMeetings() async {
    try {
      getMeetingLoader = true;
      notifyListeners();

      List<MeetingModel> meetingItems = await MeetingServices.getMeetings();

      if (meetingItems.isNotEmpty) {
        meetingList = meetingItems;
      } else {
        meetingList.clear();
      }
    } catch (e) {
      debugPrint('getAllMeetings error: $e');
      meetingList.clear();
    } finally {
      getMeetingLoader = false;
      notifyListeners();
    }
  }

  Future<MeetingModel?> getMeetingById(int id) async {
    try {
      return await MeetingServices.getMeetingById(id);
    } catch (e) {
      debugPrint('getMeetingById error: $e');
      return null;
    }
  }

  Future<String?> updateMeeting(int id, Map<String, dynamic> patchData) async {
    final res = await MeetingServices.updateMeeting(id, patchData);
    if (res == null) await getAllMeetings();
    return res;
  }

  Future<String?> deleteMeeting(int id) async {
    final res = await MeetingServices.deleteMeeting(id);
    if (res == null) await getAllMeetings();
    return res;
  }
}
