import 'dart:async';

import 'package:ecommerce_app/utils/validators.dart';
import 'package:ecommerce_app/viewmodel/auth_viewmodel.dart';
import 'package:ecommerce_app/views/screens/login/login_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class OtpVerifyScreen extends StatefulWidget {
  /// Email the OTP was sent to — passed in from SignupScreen after a
  /// successful /register/ call, used as the body for /register-verify/.
  final String email;

  const OtpVerifyScreen({super.key, required this.email});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
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
        setState(() {
          _secondsLeft--;
        });
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

  Future<void> _verify(AuthViewModel authViewModel) async {
    final otp = _enteredOtp;
    final error = Validators.otp(otp);
    setState(() => _otpError = error);
    if (error != null) return;

    final success =
        await authViewModel.verifyOtp(email: widget.email, otp: otp);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SuccessScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.verifyError ?? 'Verification failed'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

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
                      decoration: const BoxDecoration(
                        color: Color(0xFF2562E8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    text: 'Verify ',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2562E8),
                    ),
                    children: [
                      TextSpan(
                        text: 'your account',
                        style: TextStyle(color: Color(0xFF121926)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  'We have sent a 6 digit code to\n${widget.email}.\n'
                  'Enter it below to confirm your account\n'
                  'and start shopping',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Color(0xFF6B7280),
                  ),
                ),

                const SizedBox(height: 34),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'OTP Code',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF121926),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

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
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Resend code in : ${_secondsLeft > 0 ? _timeText : "0:00"}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  height: 58,
                  child: ElevatedButton(
                    onPressed: authViewModel.isVerifying
                        ? null
                        : () => _verify(authViewModel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2562E8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: authViewModel.isVerifying
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Verify My Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: _secondsLeft == 0 ? _startTimer : null,
                  child: const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text.rich(
                      TextSpan(
                        text: "Don't receive OTP yet? ",
                        style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                        children: [
                          TextSpan(
                            text: 'Resend it',
                            style: TextStyle(
                              color: Color(0xFF2562E8),
                              fontWeight: FontWeight.w600,
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
    return Container(
      width: 54,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: hasError ? Colors.redAccent : const Color(0xFFE6E8EF),
          width: hasError ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF121926),
        ),
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