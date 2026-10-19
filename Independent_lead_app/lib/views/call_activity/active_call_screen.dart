import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pokakbilling/models/services/call_activity/twillo_service.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/models/call_activity/call_lead_model.dart';
import 'package:pokakbilling/viewmodels/call_activity/dashboard_viewmodel.dart';

class ActiveCallScreen extends StatefulWidget {
  final CallLeadModel lead;
  const ActiveCallScreen({super.key, required this.lead});

  @override
  State<ActiveCallScreen> createState() => _ActiveCallScreenState();

  static Future<void> showAsPopup(BuildContext context, CallLeadModel lead) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: const Color(0xFF060B12).withOpacity(0.78),
        pageBuilder: (_, __, ___) => ActiveCallScreen(lead: lead),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween(begin: 0.88, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _ActiveCallScreenState extends State<ActiveCallScreen>
    with TickerProviderStateMixin {
  static const _bgTop = Color(0xFF122A45);
  static const _bgMid = Color(0xFF0E2038);
  static const _bgBottom = Color(0xFF081524);
  static const _accent = Color(0xFF34E0C9);
  static const _accentDeep = Color(0xFF1FA593);
  static const _endRed = Color(0xFFFF5A5F);
  static const _recallGreen = Color(0xFF3ADB7A);

  static const _ringTimeout = Duration(seconds: 20);

  TwilioCallStatus _status = TwilioCallStatus.ringing;
  bool _connecting = true;
  StreamSubscription<TwilioCallStatus>? _statusSub;
  Timer? _timer;
  Timer? _watchdog;
  int _seconds = 0;
  int _lastSeconds = 0;
  String? _error;

  late final AnimationController _pulseController;
  late final AnimationController _endBtnController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _endBtnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      lowerBound: 0.0,
      upperBound: 0.08,
    );

    _statusSub = TwilioCallService.instance.statusStream.listen(_onStatus);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startCall();
    });
  }

  Future<void> _startCall() async {
    setState(() {
      _connecting = true;
      _error = null;
      _status = TwilioCallStatus.ringing;
      _seconds = 0;
    });
    _armWatchdog();
    try {
      debugPrint('[ActiveCallScreen] Step 1: fetching Twilio token...');
      final vm = context.read<CallActivityViewmodel>();
      final tokenModel = await vm.fetchTwilioToken();
      debugPrint(
          '[ActiveCallScreen] Step 1 done: got token for identity=${tokenModel.identity}');

      debugPrint('[ActiveCallScreen] Step 2: TwilioCallService.setToken...');
      await TwilioCallService.instance.setToken(
        accessToken: tokenModel.token,
        identity: tokenModel.identity,
      );
      debugPrint('[ActiveCallScreen] Step 2 done: token set.');

      if (!mounted) return;
      setState(() => _connecting = false);

      debugPrint(
          '[ActiveCallScreen] Step 3: placing call to ${widget.lead.phone}...');
      await TwilioCallService.instance.placeCall(widget.lead.phone);
      debugPrint('[ActiveCallScreen] Step 3 done: placeCall() returned.');
    } catch (e) {
      debugPrint('[ActiveCallScreen] _startCall FAILED: $e');
      _watchdog?.cancel();
      if (!mounted) return;
      setState(() {
        _connecting = false;
        _status = TwilioCallStatus.error;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _armWatchdog() {
    _watchdog?.cancel();
    _watchdog = Timer(_ringTimeout, () {
      if (!mounted) return;
      if (_status == TwilioCallStatus.ringing) {
        debugPrint('[ActiveCallScreen] Watchdog: no further call event after '
            '${_ringTimeout.inSeconds}s — forcing error state.');
        setState(() {
          _connecting = false;
          _status = TwilioCallStatus.error;
          _error = 'No response from the calling service on this device. Tap '
              'Retry, or check Settings for this app\'s battery/background '
              'permissions.';
        });
      }
    });
  }

  void _onStatus(TwilioCallStatus status) {
    if (!mounted) return;
    _watchdog?.cancel();
    setState(() => _status = status);

    if (status == TwilioCallStatus.ringing) {
      // Still not connected — re-arm in case it hangs here indefinitely.
      _armWatchdog();
    }

    if (status == TwilioCallStatus.connected) {
      _timer?.cancel();
      _seconds = 0;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _seconds++);
      });
    }

    if (status == TwilioCallStatus.ended || status == TwilioCallStatus.error) {
      _timer?.cancel();
      _lastSeconds = _seconds;
    }
  }

  String get _statusLabel {
    if (_connecting) return 'Connecting…';
    switch (_status) {
      case TwilioCallStatus.ringing:
        return 'Ringing…';
      case TwilioCallStatus.connected:
        return _formatDuration(_seconds);
      case TwilioCallStatus.ended:
        return 'Call ended';
      case TwilioCallStatus.error:
        return _error ?? 'Could not place call';
    }
  }

  String _formatDuration(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _endCall() async {
    _watchdog?.cancel();
    try {
      await TwilioCallService.instance.hangUp();
    } catch (_) {
      // Already reported via statusStream.
    }
    if (!mounted) return;
    setState(() {
      _lastSeconds = _seconds;
      _status = TwilioCallStatus.ended;
    });
  }

  Future<void> _recall() async {
    setState(() {
      _status = TwilioCallStatus.ringing;
      _error = null;
      _seconds = 0;
    });
    await _startCall();
  }

  Future<void> _shareDebugLog() async {
    final logs = TwilioCallService.instance.recentLogs;
    final buffer = StringBuffer()
      ..writeln('Twilio call debug log')
      ..writeln('Lead: ${widget.lead.name} (${widget.lead.phone})')
      ..writeln('Captured: ${DateTime.now().toIso8601String()}')
      ..writeln('---');
    if (logs.isEmpty) {
      buffer.writeln('(no log lines captured)');
    } else {
      for (final line in logs) {
        buffer.writeln(line);
      }
    }
    await Share.share(buffer.toString(), subject: 'Twilio call debug log');
  }

  String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  bool get _isLive =>
      _connecting ||
      _status == TwilioCallStatus.ringing ||
      _status == TwilioCallStatus.connected;

  @override
  void dispose() {
    _statusSub?.cancel();
    _timer?.cancel();
    _watchdog?.cancel();
    _pulseController.dispose();
    _endBtnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                width: 320,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.fromLTRB(26, 40, 26, 30),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_bgTop, _bgMid, _bgBottom],
                    stops: [0.0, 0.55, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withOpacity(0.18),
                      blurRadius: 60,
                      spreadRadius: -8,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 40,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAvatar(),
                    const SizedBox(height: 22),
                    Text(
                      widget.lead.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.lead.phone,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: _accent.withOpacity(0.85),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 26),
                    _buildStatusBadge(),
                    const SizedBox(height: 36),
                    _buildActionRow(),
                    if (_status == TwilioCallStatus.error) ...[
                      const SizedBox(height: 14),
                      _buildShareLogLink(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return SizedBox(
      width: 132,
      height: 132,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isLive)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) {
                return Stack(
                  alignment: Alignment.center,
                  children: List.generate(3, (i) {
                    final delay = i * 0.33;
                    var t = (_pulseController.value + delay) % 1.0;
                    final scale = 0.7 + (t * 0.6);
                    final opacity = (1 - t).clamp(0.0, 1.0) * 0.35;
                    return Opacity(
                      opacity: opacity,
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: _accent, width: 1.6),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_accent, _accentDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _accent.withOpacity(0.4),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(widget.lead.name),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    IconData? icon;
    switch (_status) {
      case TwilioCallStatus.error:
        color = _endRed;
        icon = Icons.error_outline_rounded;
        break;
      case TwilioCallStatus.ended:
        color = Colors.white54;
        icon = Icons.call_end_rounded;
        break;
      case TwilioCallStatus.connected:
        color = _recallGreen;
        icon = Icons.podcasts_rounded;
        break;
      default:
        color = _accent;
        icon = null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 1.5),
              child: Icon(icon, size: 15, color: color),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              _statusLabel,
              softWrap: true,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color:
                    color == _accent ? Colors.white.withOpacity(0.92) : color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (_status == TwilioCallStatus.ended) ...[
            const SizedBox(width: 8),
            Text(
              '· ${_formatDuration(_lastSeconds)}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShareLogLink() {
    return GestureDetector(
      onTap: _shareDebugLog,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.ios_share_rounded,
              size: 14, color: Colors.white.withOpacity(0.55)),
          const SizedBox(width: 6),
          Text(
            'Send Debug Log',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.55),
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow() {
    if (_status == TwilioCallStatus.error) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _pillButton(
            label: 'Retry',
            color: _accent,
            icon: Icons.refresh_rounded,
            onTap: _recall,
          ),
          const SizedBox(width: 14),
          _pillButton(
            label: 'Close',
            color: Colors.white24,
            filled: false,
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      );
    }

    if (_status == TwilioCallStatus.ended) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _pillButton(
            label: 'Recall',
            color: _recallGreen,
            icon: Icons.replay_rounded,
            onTap: _recall,
          ),
          const SizedBox(width: 14),
          _pillButton(
            label: 'Close',
            color: Colors.white24,
            filled: false,
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      );
    }

    return Column(
      children: [
        GestureDetector(
          onTapDown: (_) => _endBtnController.forward(),
          onTapUp: (_) => _endBtnController.reverse(),
          onTapCancel: () => _endBtnController.reverse(),
          onTap: _endCall,
          child: AnimatedBuilder(
            animation: _endBtnController,
            builder: (_, child) {
              final scale = 1.0 - _endBtnController.value;
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [_endRed, Color(0xFFC62828)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _endRed.withOpacity(0.45),
                    blurRadius: 22,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.call_end_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Cancel Call',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.65),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _pillButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
    IconData? icon,
    bool filled = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        decoration: BoxDecoration(
          color:
              filled ? color.withOpacity(0.18) : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: filled ? color : Colors.white24,
            width: 1.4,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
