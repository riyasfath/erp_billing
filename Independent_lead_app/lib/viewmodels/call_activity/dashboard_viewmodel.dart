import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pokakbilling/models/call_activity/dashboard_model.dart';
import 'package:pokakbilling/models/call_activity/call_lead_model.dart';
import 'package:pokakbilling/models/call_activity/call_details_model.dart';
import 'package:pokakbilling/models/call_activity/twilio_token_model.dart';
import 'package:pokakbilling/models/services/call_activity/dashboard_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CallActivityViewmodel extends ChangeNotifier {
  // ── Dashboard ────────────────────────────────────────────────────────
  bool getDashboardLoader = false;
  CallActivityDashboardModel dashboard = CallActivityDashboardModel.empty();

  static const String _cachedDashboardKey = 'cached_call_activity_dashboard';

  String? selectedPeriod;
  String? selectedStatus;
  String? selectedStage;

  // ── Performance Summary ─────────────────────────────────────────────
  bool getPerformanceSummaryLoader = false;
  bool performanceSummaryLoaded = false;
  CallPerformanceSummaryModel performanceSummary =
      CallPerformanceSummaryModel.empty();

  // ── Today's Tasks ────────────────────────────────────────────────────
  bool getTodayTasksLoader = false;
  bool todayTasksLoaded = false;
  TodayTasksResponseModel todayTasksData = TodayTasksResponseModel.empty();

  // ── Call History ─────────────────────────────────────────────────────
  bool getHistoryLoader = false;
  bool historyLoaded = false;
  CallHistoryResponseModel historyData = CallHistoryResponseModel.empty();

  // ── Follow-ups ───────────────────────────────────────────────────────
  bool getFollowUpsLoader = false;
  bool followUpsLoaded = false;
  CallFollowUpResponseModel followUpsData = CallFollowUpResponseModel.empty();

  // ── Callable Leads ("Start New Call" picker page) ────────────────────
  bool getCallableLeadsLoader = false;
  CallLeadListResponseModel callableLeads = CallLeadListResponseModel.empty();

  // ── Call Details (Call Details page) ─────────────────────────────────
  bool getCallDetailsLoader = false;
  bool updatingCallDetails = false;
  CallDetailsModel? callDetails;

  // ── ✅ Twilio Access Token (in-app calling via Twilio Voice SDK) ──────
  bool fetchingTwilioToken = false;

  CallActivityViewmodel() {
    _init();
  }

  Future<void> _init() async {
    await _loadCachedDashboard();
    await getDashboardStats();
    await getPerformanceSummary();
  }

  // ── Dashboard cache ──────────────────────────────────────────────────
  Future<void> _loadCachedDashboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cachedDashboardKey);

      if (cachedJson != null) {
        final decoded = jsonDecode(cachedJson) as Map<String, dynamic>;
        dashboard = CallActivityDashboardModel.fromJson(decoded);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cached call activity dashboard: $e');
    }
  }

  Future<void> _saveDashboardToCache(CallActivityDashboardModel model) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(model.toJson());
      await prefs.setString(_cachedDashboardKey, encoded);
    } catch (e) {
      debugPrint('Error saving call activity dashboard cache: $e');
    }
  }

  Future<void> clearCachedDashboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cachedDashboardKey);
      dashboard = CallActivityDashboardModel.empty();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing call activity dashboard cache: $e');
    }
  }

  /// Pass any of period/status/stage to update the active filter,
  /// otherwise the previously selected filter is re-used.
  /// Also refreshes the Performance Summary with the same filters.
  Future<void> getDashboardStats({
    String? period,
    String? status,
    String? stage,
    bool clearPeriod = false,
    bool clearStatus = false,
    bool clearStage = false,
  }) async {
    try {
      getDashboardLoader = true;
      notifyListeners();

      if (clearPeriod) selectedPeriod = null;
      if (clearStatus) selectedStatus = null;
      if (clearStage) selectedStage = null;

      if (period != null) selectedPeriod = period;
      if (status != null) selectedStatus = status;
      if (stage != null) selectedStage = stage;

      final result = await CallActivityService.getDashboard(
        period: selectedPeriod,
        status: selectedStatus,
        stage: selectedStage,
      );

      dashboard = result;

      await _saveDashboardToCache(result);
    } catch (e) {
      debugPrint('Call Activity Dashboard Fetch Error : $e');
    } finally {
      getDashboardLoader = false;
      notifyListeners();
    }

    // Keep the breakdown cards in sync with the same filters.
    await getPerformanceSummary(force: true);
  }

  // ── Performance Summary ──────────────────────────────────────────────
  Future<void> getPerformanceSummary({bool force = false}) async {
    if (performanceSummaryLoaded && !force) return;
    try {
      getPerformanceSummaryLoader = true;
      notifyListeners();

      performanceSummary = await CallActivityService.getPerformanceSummary(
        period: selectedPeriod,
        status: selectedStatus,
        stage: selectedStage,
      );
      performanceSummaryLoaded = true;
    } catch (e) {
      debugPrint('Performance Summary Fetch Error : $e');
    } finally {
      getPerformanceSummaryLoader = false;
      notifyListeners();
    }
  }

  // ── Today's Tasks ────────────────────────────────────────────────────
  Future<void> getTodayTasks({bool force = false}) async {
    if (todayTasksLoaded && !force) return;
    try {
      getTodayTasksLoader = true;
      notifyListeners();

      todayTasksData = await CallActivityService.getTodayTasks();
      todayTasksLoaded = true;
    } catch (e) {
      debugPrint('Today Tasks Fetch Error : $e');
    } finally {
      getTodayTasksLoader = false;
      notifyListeners();
    }
  }

  // ── Call History ─────────────────────────────────────────────────────
  Future<void> getCallHistory({bool force = false, String? search}) async {
    if (historyLoaded && !force && search == null) return;
    try {
      getHistoryLoader = true;
      notifyListeners();

      historyData = await CallActivityService.getCallHistory(search: search);
      historyLoaded = true;
    } catch (e) {
      debugPrint('Call History Fetch Error : $e');
    } finally {
      getHistoryLoader = false;
      notifyListeners();
    }
  }

  // ── Follow-ups ───────────────────────────────────────────────────────
  Future<void> getFollowUps({bool force = false}) async {
    if (followUpsLoaded && !force) return;
    try {
      getFollowUpsLoader = true;
      notifyListeners();

      followUpsData = await CallActivityService.getFollowUps();
      followUpsLoaded = true;
    } catch (e) {
      debugPrint('Call Follow-ups Fetch Error : $e');
    } finally {
      getFollowUpsLoader = false;
      notifyListeners();
    }
  }

  // ── Callable Leads (Select Lead For Call page) ───────────────────────
  Future<void> getCallableLeads({String? search}) async {
    try {
      getCallableLeadsLoader = true;
      notifyListeners();

      callableLeads = await CallActivityService.getCallableLeads(
        search: search,
      );
    } catch (e) {
      debugPrint('Callable Leads Fetch Error : $e');
    } finally {
      getCallableLeadsLoader = false;
      notifyListeners();
    }
  }

  // ── Call Details (Call Details page) ─────────────────────────────────
  Future<void> getCallDetails(int leadId) async {
    try {
      getCallDetailsLoader = true;
      callDetails = null;
      notifyListeners();

      callDetails = await CallActivityService.getCallDetails(leadId);
    } catch (e) {
      debugPrint('Call Details Fetch Error : $e');
      callDetails = CallDetailsModel.empty(leadId);
    } finally {
      getCallDetailsLoader = false;
      notifyListeners();
    }
  }

  Future<bool> updateCallDetails({
    required int leadId,
    String? leadStatus,
    String? followUpDate,
    String? notes,
  }) async {
    try {
      updatingCallDetails = true;
      notifyListeners();

      final ok = await CallActivityService.updateCallDetails(
        leadId: leadId,
        leadStatus: leadStatus,
        followUpDate: followUpDate,
        notes: notes,
      );

      if (ok) {
        // Keep dashboard stats/tabs in sync after a status change.
        // Intentionally not awaited so Save doesn't block on a second call.
        getDashboardStats();
      }

      return ok;
    } catch (e) {
      debugPrint('Update Call Details Error : $e');
      return false;
    } finally {
      updatingCallDetails = false;
      notifyListeners();
    }
  }

  // ── ✅ Twilio Access Token (in-app calling via Twilio Voice SDK) ──────
  // Called right before placing a call from ActiveCallScreen — tokens are
  // short-lived, so we fetch fresh every time rather than caching.
  Future<TwilioTokenModel> fetchTwilioToken() async {
    try {
      fetchingTwilioToken = true;
      notifyListeners();

      return await CallActivityService.getTwilioAccessToken();
    } finally {
      fetchingTwilioToken = false;
      notifyListeners();
    }
  }

  /// Refresh whichever tab is currently active.
  Future<void> refreshTab(int tabIndex) async {
    switch (tabIndex) {
      case 0:
        await getDashboardStats();
        break;
      case 1:
        await getTodayTasks(force: true);
        break;
      case 2:
        await getFollowUps(force: true);
        break;
      case 3:
        await getCallHistory(force: true);
        break;
    }
  }

  void reset() {
    dashboard = CallActivityDashboardModel.empty();
    performanceSummary = CallPerformanceSummaryModel.empty();
    todayTasksData = TodayTasksResponseModel.empty();
    historyData = CallHistoryResponseModel.empty();
    followUpsData = CallFollowUpResponseModel.empty();
    callableLeads = CallLeadListResponseModel.empty();
    callDetails = null;

    performanceSummaryLoaded = false;
    todayTasksLoaded = false;
    historyLoaded = false;
    followUpsLoaded = false;

    getDashboardLoader = false;
    getPerformanceSummaryLoader = false;
    getTodayTasksLoader = false;
    getHistoryLoader = false;
    getFollowUpsLoader = false;
    getCallableLeadsLoader = false;
    getCallDetailsLoader = false;
    updatingCallDetails = false;
    fetchingTwilioToken = false;

    selectedPeriod = null;
    selectedStatus = null;
    selectedStage = null;

    clearCachedDashboard();

    notifyListeners();
  }
}
