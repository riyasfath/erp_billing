import 'package:ecommerce_app/utils/validators.dart';
import 'package:ecommerce_app/viewmodel/password_reset_viewmodel.dart';
import 'package:ecommerce_app/views/screens/login/reset_otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const Color _accent = Color(0xFF6366F1);
const Color _accent2 = Color(0xFF8B5CF6);
const Color _textDark = Color(0xFF0F172A);
const Color _textGrey = Color(0xFF64748B);
const Color _fieldBg = Color(0xFFF5F6FA);

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendEmail(PasswordResetViewModel viewModel) async {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) return;

    final email = _emailController.text.trim();
    final success = await viewModel.forgotPassword(email: email);

    if (!mounted) return;

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetOtpVerifyScreen(email: email),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.forgotError ?? 'Could not send OTP'),
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      child: const Icon(Icons.key_rounded, color: Colors.white, size: 36),
                    ),
                  ),

                  const SizedBox(height: 28),

                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      text: 'Forgot ',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                        letterSpacing: -0.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'password',
                          style: TextStyle(color: _accent),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "No worries — we'll send you a reset code so\n"
                    'you can create a new one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.5, height: 1.6, color: _textGrey),
                  ),

                  const SizedBox(height: 36),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Email',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    constraints: const BoxConstraints(minHeight: 58),
                    decoration: BoxDecoration(
                      color: _fieldBg,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                      style: const TextStyle(fontSize: 15, color: _textDark),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.mail_outline_rounded, color: _textGrey, size: 21),
                        hintText: 'user.name@example.com',
                        hintStyle: TextStyle(color: Color(0xFFA1A8B5), fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 17, horizontal: 4),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

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
                        onPressed: viewModel.isSendingOtp ? null : () => _sendEmail(viewModel),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        ),
                        child: viewModel.isSendingOtp
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                              )
                            : const Text(
                                'Send Email',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}