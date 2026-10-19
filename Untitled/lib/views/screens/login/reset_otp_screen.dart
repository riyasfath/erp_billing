import 'dart:async';

import 'package:ecommerce_app/utils/validators.dart';
import 'package:ecommerce_app/viewmodel/password_reset_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'reset_password_screen.dart';

const Color _accent = Color(0xFF6366F1);
const Color _accent2 = Color(0xFF8B5CF6);
const Color _textDark = Color(0xFF0F172A);
const Color _textGrey = Color(0xFF64748B);
const Color _fieldBg = Color(0xFFF5F6FA);

/// OTP step for the forgot-password flow. Separate from the signup
/// OtpVerifyScreen because it hits a different endpoint
/// (/api/accounts/verify-otp/, not /register-verify/).
class ResetOtpVerifyScreen extends StatefulWidget {
  final String email;

  const ResetOtpVerifyScreen({super.key, required this.email});

  @override
  State<ResetOtpVerifyScreen> createState() => _ResetOtpVerifyScreenState();
}

class _ResetOtpVerifyScreenState extends State<ResetOtpVerifyScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _secondsLeft = 120;
  Timer? _timer;
  String? _otpError;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = 120;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _timeText {
    final m = (_secondsLeft ~/ 60).toString();
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _enteredOtp => _controllers.map((c) => c.text).join();

  Future<void> _verify(PasswordResetViewModel viewModel) async {
    final otp = _enteredOtp;
    final error = Validators.otp(otp);
    setState(() => _otpError = error);
    if (error != null) return;

    final success =
        await viewModel.verifyResetOtp(email: widget.email, otp: otp);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: widget.email, otp: otp),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.verifyOtpError ?? 'Verification failed'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _resendOtp(PasswordResetViewModel viewModel) async {
    final success = await viewModel.forgotPassword(email: widget.email);
    if (!mounted) return;

    if (success) {
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP resent')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.forgotError ?? 'Could not resend OTP'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PasswordResetViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 18),

                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Center(
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_accent, _accent2],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _accent.withOpacity(0.35),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.lock_reset_rounded, color: Colors.white, size: 36),
                  ),
                ),

                const SizedBox(height: 28),

                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    text: 'Verify ',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: _accent,
                      letterSpacing: -0.5,
                    ),
                    children: [
                      TextSpan(
                        text: 'reset code',
                        style: TextStyle(color: _textDark),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'We have sent a 6 digit code to\n${widget.email}.\n'
                  'Enter it below to reset your password',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.6,
                    color: _textGrey,
                  ),
                ),

                const SizedBox(height: 32),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'OTP Code',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark),
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return _OtpBox(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      hasError: _otpError != null,
                      onChanged: (value) {
                        if (_otpError != null) {
                          setState(() => _otpError = null);
                        }
                        if (value.isNotEmpty && index < 5) {
                          FocusScope.of(context)
                              .requestFocus(_focusNodes[index + 1]);
                        }
                        if (value.isEmpty && index > 0) {
                          FocusScope.of(context)
                              .requestFocus(_focusNodes[index - 1]);
                        }
                      },
                    );
                  }),
                ),

                if (_otpError != null) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _otpError!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                    ),
                  ),
                ],

                const SizedBox(height: 22),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(color: _fieldBg, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer_outlined, size: 15, color: _secondsLeft > 0 ? _accent : _textGrey),
                        const SizedBox(width: 6),
                        Text(
                          'Resend code in : ${_secondsLeft > 0 ? _timeText : "0:00"}',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _secondsLeft > 0 ? _accent : _textGrey),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  height: 60,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(colors: [_accent, _accent2]),
                      boxShadow: [
                        BoxShadow(
                          color: _accent.withOpacity(0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: viewModel.isVerifyingOtp ? null : () => _verify(viewModel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                      child: viewModel.isVerifyingOtp
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Text(
                              'Verify Code',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                GestureDetector(
                  onTap: _secondsLeft == 0 ? () => _resendOtp(viewModel) : null,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text.rich(
                      TextSpan(
                        text: "Don't receive OTP yet? ",
                        style: const TextStyle(fontSize: 14, color: _textGrey),
                        children: [
                          TextSpan(
                            text: 'Resend it',
                            style: TextStyle(
                              color: _secondsLeft == 0 ? _accent : _textGrey.withOpacity(0.5),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final bool hasError;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool filled = controller.text.isNotEmpty;
    return Container(
      width: 50,
      height: 58,
      decoration: BoxDecoration(
        color: filled ? _accent.withOpacity(0.08) : _fieldBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasError ? Colors.redAccent : (filled ? _accent : Colors.transparent),
          width: hasError ? 1.4 : 1.4,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(bottom: 6),
        ),
        onChanged: onChanged,
      ),
    );
  }
}