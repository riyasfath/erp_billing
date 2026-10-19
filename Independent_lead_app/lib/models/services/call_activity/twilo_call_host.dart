import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:pokakbilling/models/services/call_activity/twillo_service.dart';

/// Hosts the hidden WebView that runs the Twilio JS SDK. Must stay mounted
/// for the lifetime of the app (not just while a call screen is open) —
/// mount this ONCE, high in the widget tree (see main.dart).
class TwilioCallHost extends StatefulWidget {
  const TwilioCallHost({super.key});

  @override
  State<TwilioCallHost> createState() => _TwilioCallHostState();
}

class _TwilioCallHostState extends State<TwilioCallHost> {
  WebViewController? _controller;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) =>
                TwilioCallService.instance.notifyPageLoaded(),
            onWebResourceError: (error) {
              debugPrint('[TwilioCallHost] WebView resource error: '
                  '${error.errorCode} ${error.description} (${error.url})');
            },
          ),
        )
        ..addJavaScriptChannel(
          'TwilioBridge',
          onMessageReceived: (msg) =>
              TwilioCallService.instance.handleBridgeMessage(msg.message),
        );

      final platform = controller.platform;
      if (platform is AndroidWebViewController) {
        await platform.setMediaPlaybackRequiresUserGesture(false);
        platform.setOnPlatformPermissionRequest((request) {
          request.grant();
        });
      }

      TwilioCallService.instance.attachController(controller);
      await controller.loadFlutterAsset('assets/twilio/call_bridge.html');

      if (!mounted) return;
      setState(() => _controller = controller);
      debugPrint('[TwilioCallHost] WebView controller attached OK.');
    } catch (e, st) {
      debugPrint('[TwilioCallHost] FAILED to initialize WebView: $e\n$st');
      if (mounted) setState(() => _initError = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      // Not ready yet (or failed) — render nothing visible, but stay
      // mounted so _init() can complete once the platform channel is up.
      return const SizedBox.shrink();
    }

    // Positioned off-canvas rather than Offstage — keeps the platform
    // view "onstage" so Android actually initializes it, while being
    // fully invisible and non-interactive to the user.
    return Positioned(
      left: -10000,
      top: -10000,
      width: 1,
      height: 1,
      child: IgnorePointer(
        child: WebViewWidget(controller: _controller!),
      ),
    );
  }
}
