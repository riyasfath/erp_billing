import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/viewmodels/login_viewmodel.dart';
import 'package:provider/provider.dart';

class _C {
  _C._();
  static const Color navy = AppColors.navy;
  static const Color cyan = AppColors.cyan;
  static const Color ice = AppColors.ice;
  static const Color white = AppColors.white;
  static const Color red = AppColors.red;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool _passwordVisible = false;
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _emailError;
  String? _passwordError;

  late final AnimationController _logoCtrl;
  late final AnimationController _sheetCtrl;
  late final AnimationController _fieldsCtrl;
  late final AnimationController _pulseCtrl;

  late final Animation<double> _logoFade;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _logoScale;
  late final Animation<double> _sheetSlide;
  late final Animation<double> _fieldsFade;
  late final Animation<Offset> _fieldsSlide;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _logoFade = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut);
    _logoSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));
    _logoScale = Tween<double>(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));

    _sheetCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _sheetSlide = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _sheetCtrl, curve: Curves.easeOut));

    _fieldsCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fieldsFade = CurvedAnimation(parent: _fieldsCtrl, curve: Curves.easeOut);
    _fieldsSlide = Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
        .animate(CurvedAnimation(parent: _fieldsCtrl, curve: Curves.easeOut));

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _logoCtrl.forward();
    Future.delayed(
        const Duration(milliseconds: 300), () => _sheetCtrl.forward());
    Future.delayed(
        const Duration(milliseconds: 550), () => _fieldsCtrl.forward());
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _sheetCtrl.dispose();
    _fieldsCtrl.dispose();
    _pulseCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';

    final hasAt = v.contains('@');
    final parts = v.split('@');
    final hasLocalPart = hasAt && parts[0].isNotEmpty;
    final hasDomain = hasAt && parts.length == 2 && parts[1].isNotEmpty;

    if (!hasLocalPart || !hasDomain) return 'Enter a valid email address';

    if (!parts[1].toLowerCase().endsWith('.com')) {
      return 'Only .com email addresses are accepted';
    }

    final domainWithoutCom =
        parts[1].substring(0, parts[1].toLowerCase().lastIndexOf('.com'));
    if (domainWithoutCom.isEmpty) return 'Enter a valid email address';

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    return null;
  }

  void _showValidationErrorDialog(
      {required String emailErr, required String passErr}) {
    final List<String> issues = [];
    if (emailErr.isNotEmpty) issues.add('• $emailErr');
    if (passErr.isNotEmpty) issues.add('• $passErr');
    final body = issues.join('\n');

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _C.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.10),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.30),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Invalid Input',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _C.navy,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Please enter a valid email and password to continue.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: _C.navy.withOpacity(0.55),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _C.red.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _C.red.withOpacity(0.18)),
                    ),
                    child: Text(
                      body,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _C.red,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(height: 0.5, color: _C.navy.withOpacity(0.08)),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_C.cyan, _C.navy],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'OK, GOT IT',
                          style: TextStyle(
                            color: _C.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
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

  void _showInvalidCredentialsDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _C.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _C.red.withOpacity(0.10),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _C.red.withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.lock_person_outlined,
                      color: _C.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Invalid Credentials',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _C.navy,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'The email or password you entered is incorrect. Please check your credentials and try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: _C.navy.withOpacity(0.55),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(height: 0.5, color: _C.navy.withOpacity(0.08)),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_C.cyan, _C.navy],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'TRY AGAIN',
                          style: TextStyle(
                            color: _C.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
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

  Future<void> _submit(LoginViewModel loginProvider) async {
    final emailErr = _validateEmail(_emailCtrl.text);
    final passErr = _validatePassword(_passwordCtrl.text);

    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
    });

    if (emailErr != null || passErr != null) {
      _showValidationErrorDialog(
        emailErr: emailErr ?? '',
        passErr: passErr ?? '',
      );
      return;
    }

    final success = await loginProvider.userLogin(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
      context,
    );

    if (mounted && !success) {
      _showInvalidCredentialsDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginViewModel>(context);
    final sh = MediaQuery.of(context).size.height;
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: _C.navy,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          _buildBackground(sw, sh),
          _buildLogoArea(sh),
          _buildBottomSheet(loginProvider, sh),
        ],
      ),
    );
  }

  Widget _buildBackground(double sw, double sh) {
    return Stack(
      children: [
        Positioned(
          top: -60,
          right: -60,
          child: AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, __) => Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _C.cyan.withOpacity(0.08 * _pulseAnim.value),
              ),
            ),
          ),
        ),
        Positioned(
          top: 80,
          left: -40,
          child: AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, __) => Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _C.cyan.withOpacity(0.06 * _pulseAnim.value),
              ),
            ),
          ),
        ),
        Positioned(
          top: sh * 0.22,
          right: 30,
          child: AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, __) => Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _C.cyan.withOpacity(0.10 * _pulseAnim.value),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoArea(double sh) {
    return Positioned(
      top: sh * 0.08,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _logoFade,
        child: SlideTransition(
          position: _logoSlide,
          child: ScaleTransition(
            scale: _logoScale,
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: _C.cyan.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _C.cyan.withOpacity(0.35),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _C.cyan.withOpacity(0.25),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Image.asset(
                        AppAssets.logo,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    color: _C.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sign in to continue',
                  style: TextStyle(
                    color: _C.ice.withOpacity(0.60),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheet(LoginViewModel loginProvider, double sh) {
    // ── FIX: read bottom safe-area inset (home bar / nav bar height) ──────
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return AnimatedBuilder(
      animation: _sheetSlide,
      builder: (_, child) => Align(
        alignment: Alignment.bottomCenter,
        child: Transform.translate(
          offset: Offset(0, _sheetSlide.value * 500),
          child: child,
        ),
      ),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: sh * 0.52),
        // ── FIX: add bottomInset so content never hides behind nav bar ────
        padding: EdgeInsets.fromLTRB(24, 32, 24, bottomInset + 16),
        decoration: const BoxDecoration(
          color: _C.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: FadeTransition(
          opacity: _fieldsFade,
          child: SlideTransition(
            position: _fieldsSlide,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sheet handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: _C.navy.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _C.navy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Enter your credentials to access your account',
                    style: TextStyle(
                      fontSize: 13,
                      color: _C.navy.withOpacity(0.45),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Email field
                  _buildFieldLabel('Email ID', isRequired: true),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _emailCtrl,
                    hint: 'Enter your email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    hasError: _emailError != null,
                    onChanged: (v) {
                      if (_emailError != null) {
                        setState(() => _emailError = _validateEmail(v));
                      }
                    },
                  ),
                  if (_emailError != null) _buildErrorText(_emailError!),

                  const SizedBox(height: 18),

                  // Password field
                  _buildFieldLabel('Password', isRequired: true),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _passwordCtrl,
                    hint: 'Enter your password',
                    icon: Icons.lock_outline_rounded,
                    obscure: !_passwordVisible,
                    hasError: _passwordError != null,
                    onChanged: (v) {
                      if (_passwordError != null) {
                        setState(() => _passwordError = _validatePassword(v));
                      }
                    },
                    suffix: IconButton(
                      onPressed: () =>
                          setState(() => _passwordVisible = !_passwordVisible),
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        color: _C.navy.withOpacity(0.45),
                        size: 20,
                      ),
                    ),
                  ),
                  if (_passwordError != null) _buildErrorText(_passwordError!),

                  const SizedBox(height: 32),

                  _buildLoginButton(loginProvider),

                  // ── FIX: extra bottom breathing room above safe-area ───
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _C.navy,
          ),
        ),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(
              color: _C.red,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
      ],
    );
  }

  Widget _buildErrorText(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 13, color: _C.red),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _C.red,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    bool hasError = false,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 14,
        color: _C.navy,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 13,
          color: _C.navy.withOpacity(0.30),
        ),
        prefixIcon: Icon(icon, size: 20, color: hasError ? _C.red : _C.cyan),
        suffixIcon: suffix,
        filled: true,
        fillColor: hasError ? _C.red.withOpacity(0.04) : _C.ice,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color:
                hasError ? _C.red.withOpacity(0.60) : _C.cyan.withOpacity(0.20),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color:
                hasError ? _C.red.withOpacity(0.60) : _C.cyan.withOpacity(0.20),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: hasError ? _C.red : _C.cyan,
            width: 1.8,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(LoginViewModel loginProvider) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_C.cyan, _C.navy],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(27),
          boxShadow: [
            BoxShadow(
              color: _C.cyan.withOpacity(0.40),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed:
              loginProvider.isLoading ? null : () => _submit(loginProvider),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(27),
            ),
          ),
          child: loginProvider.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: _C.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.login_rounded, color: _C.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'SIGN IN',
                      style: TextStyle(
                        color: _C.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
