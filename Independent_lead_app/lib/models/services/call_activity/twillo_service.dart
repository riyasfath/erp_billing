
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum TwilioCallStatus { ringing, connected, ended, error }

/// ─────────────────────────────────────────────────────────────────────────
/// Twilio calling, driven through a hidden WebView running the same
/// @twilio/voice-sdk JS SDK the web app already uses successfully.
///
/// WHY A WEBVIEW, NOT THE `twilio_voice` NATIVE PLUGIN:
/// The native plugin gated outgoing calls on a Firebase-Cloud-Messaging
/// backed "registration" step internally, even though Twilio's own SDKs
/// don't require that for placing outgoing calls (only for *receiving*
/// calls via push). That gate was the root cause of "No registered phone
/// account, call registerPhoneAccount() first" on every device tested —
/// logs showed isPhoneAccountEnabled() == true (Android's own Telecom side
/// was fine) yet call.place() failed anyway, immediately, right after an
/// "FCM token is empty, unable to register" line.
///
/// This class avoids that whole subsystem — no Firebase, no Android
/// PhoneAccount/ConnectionService, no per-OEM Telecom quirks — by using
/// exactly the same JS SDK + flow as the working web app.
/// ─────────────────────────────────────────────────────────────────────────
class TwilioCallService {
  TwilioCallService._();
  static final TwilioCallService instance = TwilioCallService._();

  // ── In-app log capture — share via the call screen's debug-log button ──
  final List<String> _logBuffer = [];
  static const int _maxLogLines = 300;
  List<String> get recentLogs => List.unmodifiable(_logBuffer);
  void _log(String message) {
    final line = '[${DateTime.now().toIso8601String()}] $message';
    debugPrint(line);
    _logBuffer.add(line);
    if (_logBuffer.length > _maxLogLines) _logBuffer.removeAt(0);
  }

  void clearLogs() => _logBuffer.clear();
  // ─────────────────────────────────────────────────────────────────────

  WebViewController? _controller;
  bool _deviceRegistered = false;

  Completer<void>? _pageLoadedCompleter;
  Completer<void>? _registerCompleter;

  final _statusController = StreamController<TwilioCallStatus>.broadcast();
  Stream<TwilioCallStatus> get statusStream => _statusController.stream;

  bool _muted = false;
  bool get isMuted => _muted;

  /// Called once by TwilioCallHost when the WebView is created.
  void attachController(WebViewController controller) {
    _controller = controller;
    _pageLoadedCompleter = Completer<void>();
  }

  /// Called by TwilioCallHost's NavigationDelegate.onPageFinished.
  void notifyPageLoaded() {
    _log('TwilioCallService: bridge page loaded.');
    if (_pageLoadedCompleter != null && !_pageLoadedCompleter!.isCompleted) {
      _pageLoadedCompleter!.complete();
    }
  }

  /// Called by TwilioCallHost's JavaScriptChannel onMessageReceived.
  void handleBridgeMessage(String raw) {
    _log('bridge event: $raw');
    Map<String, dynamic> data;
    try {
      data = jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      _log('bridge event: failed to parse ($e)');
      return;
    }

    switch (data['type'] as String?) {
      case 'registered':
        _deviceRegistered = true;
        if (_registerCompleter != null && !_registerCompleter!.isCompleted) {
          _registerCompleter!.complete();
        }
        break;
      case 'unregistered':
        _deviceRegistered = false;
        break;
      case 'connecting':
      case 'ringing':
        _statusController.add(TwilioCallStatus.ringing);
        break;
      case 'accepted':
        _statusController.add(TwilioCallStatus.connected);
        break;
      case 'disconnect':
      case 'reject':
      case 'cancel':
        _statusController.add(TwilioCallStatus.ended);
        break;
      case 'error':
        _log('bridge error: ${data['message']}');
        _statusController.add(TwilioCallStatus.error);
        break;
    }
  }

  Future<void> _ensurePageLoaded() async {
    if (_controller == null || _pageLoadedCompleter == null) {
      throw StateError(
          'TwilioCallService: WebView not attached yet — make sure TwilioCallHost is mounted before calling setToken().');
    }
    await _pageLoadedCompleter!.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw TimeoutException(
          'Twilio call bridge page did not finish loading in time'),
    );
  }

  /// Sets the Twilio access token for this session and registers the
  /// WebView-hosted Device. Tokens are short-lived, so call this fresh
  /// before every call.
  Future<void> setToken({
    required String accessToken,
    required String identity,
  }) async {
    _log('TwilioCallService.setToken: requesting microphone permission...');
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      throw StateError('Microphone permission is required to place calls.');
    }

    await _ensurePageLoaded();

    _log('TwilioCallService.setToken: initializing device in WebView...');
    _registerCompleter = Completer<void>();
    await _controller!
        .runJavaScript('window.initDevice(${jsonEncode(accessToken)});');

    try {
      await _registerCompleter!.future.timeout(const Duration(seconds: 12));
      _log('TwilioCallService.setToken: device registered.');
    } on TimeoutException {
      _log('TwilioCallService.setToken: TIMED OUT waiting for registration.');
      throw TimeoutException(
          'Twilio device did not register in time — check network/token.');
    }
  }

  /// Places an outgoing call to [to] — E.164 format phone number.
  Future<void> placeCall(String to) async {
    if (!_deviceRegistered || _controller == null) {
      throw StateError(
          'TwilioCallService.setToken() must complete before placing a call');
    }
    _log('TwilioCallService.placeCall: connecting to $to...');
    await _controller!.runJavaScript('window.connectCall(${jsonEncode(to)});');
  }

  Future<void> toggleMute() async {
    _muted = !_muted;
    await _controller?.runJavaScript('window.toggleMute($_muted);');
  }

  Future<void> toggleSpeaker() async {
    // No-op: WebView audio output routing isn't controllable the same way
    // native telecom audio is. Wire up a platform audio-routing plugin
    // here later if explicit speaker/earpiece switching becomes a must.
  }

  Future<void> hangUp() async {
    try {
      await _controller?.runJavaScript('window.hangUp();');
    } finally {
      _statusController.add(TwilioCallStatus.ended);
    }
  }

  void dispose() {
    _statusController.close();
  }
}
