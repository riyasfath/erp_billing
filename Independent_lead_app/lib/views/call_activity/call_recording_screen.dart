import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pokakbilling/viewmodels/call_activity/call_recording_viewmodel.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/call_activity/call_recording_model.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// CALL RECORDINGS SCREEN
/// Opened from the "Recordings" quick action on the Call Activity dashboard.
/// Pulls from GET /call-recordings/  → { "count": n, "recordings": [...] }
/// Supports search, pull-to-refresh, loading/empty states, call details
/// (name, phone, date, duration), tapping to play the recording via the
/// device's default handler, and a download button that saves the file
/// locally, fires a "Download complete" notification, and can open the
/// file directly (via OPEN action or tapping the notification).
///
/// Uses only packages already in pubspec.yaml: dio, file_saver,
/// flutter_local_notifications, open_file, permission_handler.
///
/// ANDROID MANIFEST — add inside <manifest>, outside <application>:
///   <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
/// (Required on Android 13+ for the download-complete notification.
/// permission_handler's Permission.notification.request() triggers the
/// system prompt at runtime; this manifest entry just declares it.)
/// ─────────────────────────────────────────────────────────────────────────
/// ─────────────────────────────────────────────────────────────────────────
/// DOWNLOAD NOTIFICATION HELPER
/// Minimal, self-contained wrapper around flutter_local_notifications so
/// this screen can fire a "Download complete" notification with the saved
/// file path, and open the file when the user taps it. Initializes itself
/// lazily on first use — no changes needed in main.dart.
/// ─────────────────────────────────────────────────────────────────────────
class _DownloadNotifier {
  _DownloadNotifier._();
  static final _DownloadNotifier instance = _DownloadNotifier._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  int _nextId = 1000;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (response) {
        final path = response.payload;
        if (path != null && path.isNotEmpty) {
          OpenFile.open(path);
        }
      },
    );

    // Android 13+ requires runtime notification permission.
    await Permission.notification.request();

    _initialized = true;
  }

  Future<void> showDownloadComplete({
    required String title,
    required String filePath,
  }) async {
    await _ensureInitialized();

    const androidDetails = AndroidNotificationDetails(
      'call_recording_downloads',
      'Call recording downloads',
      channelDescription: 'Notifies when a call recording finishes downloading',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();

    await _plugin.show(
      _nextId++,
      'Download complete',
      '$title saved — tap to open\n$filePath',
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: filePath,
    );
  }
}

class CallRecordingsScreen extends StatefulWidget {
  const CallRecordingsScreen({super.key});

  @override
  State<CallRecordingsScreen> createState() => _CallRecordingsScreenState();
}

class _CallRecordingsScreenState extends State<CallRecordingsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CallRecordingsViewmodel>().getCallRecordings();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final topPad = mq.padding.top;

    return Scaffold(
      backgroundColor: AppColors.cxl,
      body: Column(
        children: [
          _buildHeader(context, topPad),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.c1,
              onRefresh: () =>
                  context.read<CallRecordingsViewmodel>().refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                padding:
                    EdgeInsets.fromLTRB(16, 14, 16, mq.padding.bottom + 24),
                child: _buildBody(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, double topPad) {
    return Consumer<CallRecordingsViewmodel>(
      builder: (context, vm, _) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(20, topPad + 14, 20, 16),
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(
              bottom: BorderSide(color: AppColors.cborder, width: 1.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 34,
                      height: 34,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: AppColors.cxl,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.cborder),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.c1, size: 17),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Call Recordings',
                          style: TextStyle(
                            color: AppColors.cdark,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${vm.recordingsData.count} recordings',
                          style: const TextStyle(
                              color: AppColors.ctext, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.cxl,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cborder),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded,
                        size: 16, color: AppColors.ctext),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onSubmitted: (v) => context
                            .read<CallRecordingsViewmodel>()
                            .updateSearch(v),
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.cdark),
                        decoration: InputDecoration(
                          hintText: 'Search recordings by name or number…',
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: AppColors.ctext.withOpacity(0.60),
                          ),
                          border: InputBorder.none,
                          isCollapsed: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
                        ),
                      ),
                    ),
                    if (_searchCtrl.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          context
                              .read<CallRecordingsViewmodel>()
                              .updateSearch('');
                        },
                        child: const Icon(Icons.close_rounded,
                            size: 14, color: AppColors.c1),
                      ),
                  ],
                ),
              ),
              if (vm.getRecordingsLoader) ...[
                const SizedBox(height: 10),
                const LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: AppColors.cxl,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.c1),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ── Body ─────────────────────────────────────────────────────────────
  Widget _buildBody(BuildContext context) {
    return Consumer<CallRecordingsViewmodel>(
      builder: (context, vm, _) {
        if (vm.getRecordingsLoader && !vm.recordingsLoaded) {
          return _loadingState();
        }

        final items = vm.recordingsData.recordings;
        if (items.isEmpty) {
          return _emptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items.map((r) => _RecordingCard(recording: r)).toList(),
        );
      },
    );
  }

  // ── Shared loading / empty states ───────────────────────────────────────
  Widget _loadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 90),
      child: Center(
        child: Column(
          children: const [
            SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.c1),
              ),
            ),
            SizedBox(height: 12),
            Text('Loading…',
                style: TextStyle(
                    color: AppColors.ctext,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.c1.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cborder),
              ),
              child: Icon(Icons.mic_off_rounded,
                  color: AppColors.c1.withOpacity(0.55), size: 24),
            ),
            const SizedBox(height: 12),
            const Text('No recordings yet',
                style: TextStyle(
                    color: AppColors.cdark,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'Recorded calls will appear here once available.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.ctext.withOpacity(0.60),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────
/// RECORDING CARD — call details + duration, a play button that opens the
/// recording via the device's default handler, and a download button that
/// saves the file locally. No in-app audio player / no audioplayers dep.
/// ─────────────────────────────────────────────────────────────────────────
class _RecordingCard extends StatefulWidget {
  final CallRecordingModel recording;
  const _RecordingCard({required this.recording});

  @override
  State<_RecordingCard> createState() => _RecordingCardState();
}

class _RecordingCardState extends State<_RecordingCard> {
  bool _downloading = false;

  bool get _hasUrl =>
      widget.recording.recordingUrl != null &&
      widget.recording.recordingUrl!.isNotEmpty;

  Future<void> _openRecording() async {
    final url = widget.recording.recordingUrl;
    if (url == null || url.isEmpty) {
      _toast('No recording file available');
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !await canLaunchUrl(uri)) {
      _toast('Unable to open this recording');
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _download() async {
    if (!_hasUrl) {
      _toast('No recording file available');
      return;
    }
    if (_downloading) return;
    setState(() => _downloading = true);
    try {
      final url = widget.recording.recordingUrl!;
      final dio = Dio();
      final response = await dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if (response.statusCode != 200 || response.data == null) {
        throw Exception('Download failed (${response.statusCode})');
      }
      final bytes = Uint8List.fromList(response.data!);

      final ext = _extensionFromUrl(url).replaceFirst('.', '');
      final safeName =
          widget.recording.name.replaceAll(RegExp(r'[^\w\-]+'), '_');
      final fileName = '${safeName}_${DateTime.now().millisecondsSinceEpoch}';

      // saveFile returns the path it actually wrote to.
      final savedPath = await FileSaver.instance.saveFile(
        name: fileName,
        bytes: bytes,
        fileExtension: ext.isEmpty ? 'mp3' : ext,
        mimeType: MimeType.other,
      );

      await _DownloadNotifier.instance.showDownloadComplete(
        title: widget.recording.name,
        filePath: savedPath,
      );

      _toastWithOpen('Downloaded — tap Open to view it', savedPath);
    } catch (e, st) {
      debugPrint('Download failed: $e\n$st');
      _toast('Download failed: $e');
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  String _extensionFromUrl(String url) {
    final clean = url.split('?').first;
    final dot = clean.lastIndexOf('.');
    if (dot == -1 || dot == clean.length - 1) return '.mp3';
    final ext = clean.substring(dot);
    return ext.length <= 5 ? ext : '.mp3';
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  void _toastWithOpen(String msg, String filePath) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'OPEN',
          textColor: AppColors.white,
          onPressed: () => OpenFile.open(filePath),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.recording;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.c1.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.c1.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.mic_rounded, size: 17, color: AppColors.c1),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.name,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cdark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    r.phone.isNotEmpty ? r.phone : '—',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.ctext.withOpacity(0.65)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (r.callDate != null)
                  Text(r.callDate!,
                      style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cdark)),
                const SizedBox(height: 2),
                Text(r.duration ?? '--',
                    style: TextStyle(
                        fontSize: 9.5,
                        color: AppColors.ctext.withOpacity(0.60))),
              ],
            ),
            const SizedBox(width: 8),
            // Play button — opens the recording externally.
            GestureDetector(
              onTap: _openRecording,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _hasUrl
                      ? AppColors.c1
                      : AppColors.ctext.withOpacity(0.25),
                  shape: BoxShape.circle,
                  boxShadow: _hasUrl
                      ? [
                          BoxShadow(
                            color: AppColors.c1.withOpacity(0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: const Icon(Icons.play_arrow_rounded,
                    size: 16, color: AppColors.white),
              ),
            ),
            const SizedBox(width: 8),
            // Download button — saves the file locally.
            GestureDetector(
              onTap: _download,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.cxl,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cborder),
                ),
                child: _downloading
                    ? const Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.c1),
                        ),
                      )
                    : Icon(Icons.download_rounded,
                        size: 16,
                        color: _hasUrl
                            ? AppColors.c1
                            : AppColors.ctext.withOpacity(0.35)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
