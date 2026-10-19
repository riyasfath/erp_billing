import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloudflare_turnstile/cloudflare_turnstile.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/viewmodels/login_viewmodel.dart';
import 'package:provider/provider.dart';

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

  // ── Remember me / saved credentials ──
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _kRememberKey = 'login_remember_me';
  static const _kEmailKey = 'login_saved_email';
  static const _kPasswordKey = 'login_saved_password';
  bool _rememberMe = false;
  // ─────────────────────────────────────

  // ── Cloudflare Turnstile ──
  final TurnstileController _turnstileController = TurnstileController();
  final TurnstileOptions _turnstileOptions = TurnstileOptions(
    size: TurnstileSize.normal,
    theme: TurnstileTheme.light,
    retryAutomatically: true,
  );
  String? _turnstileToken;
  String? _turnstileError;
  // ───────────────────────────

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
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _sheetCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 550), () {
      if (mounted) _fieldsCtrl.forward();
    });

    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _sheetCtrl.dispose();
    _fieldsCtrl.dispose();
    _pulseCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _turnstileController.dispose();
    super.dispose();
  }

  // ── Saved credentials (secure storage) ───────────────────────
  Future<void> _loadSavedCredentials() async {
    try {
      final remember = await _storage.read(key: _kRememberKey) == 'true';
      if (!remember) return;
      final email = await _storage.read(key: _kEmailKey);
      final password = await _storage.read(key: _kPasswordKey);
      if (!mounted) return;
      setState(() {
        _rememberMe = true;
        if (email != null) _emailCtrl.text = email;
        if (password != null) _passwordCtrl.text = password;
      });
    } catch (e) {
      debugPrint('Failed to load saved credentials: $e');
    }
  }

  Future<void> _persistCredentials(
      String email, String password, bool remember) async {
    try {
      if (remember) {
        await _storage.write(key: _kRememberKey, value: 'true');
        await _storage.write(key: _kEmailKey, value: email);
        await _storage.write(key: _kPasswordKey, value: password);
      } else {
        await _storage.delete(key: _kRememberKey);
        await _storage.delete(key: _kEmailKey);
        await _storage.delete(key: _kPasswordKey);
      }
    } catch (e) {
      debugPrint('Failed to persist credentials: $e');
    }
  }

  // ── Validations ──────────────────────────────────────────────
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

  // ── Shared themed dialog ──────────────────────────────────────
  void _showErpDialog({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    String? detail,
    required String buttonText,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: ErpColors.ink.withValues(alpha: 0.45),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.18),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ErpGradientTile(icon: icon, color: color, size: 58, circle: true),
                  const SizedBox(height: 14),
                  Text(title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: ErpColors.ink)),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 13.5, color: ErpColors.slate, height: 1.5),
                  ),
                  if ((detail ?? '').isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: ErpColors.red.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: ErpColors.red.withValues(alpha: 0.20)),
                      ),
                      child: Text(detail!,
                          style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: ErpColors.red,
                              height: 1.6)),
                    ),
                  ],
                  const SizedBox(height: 20),
                  ErpPrimaryButton(
                    text: buttonText,
                    onTap: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Validation Error Dialog ───────────────────────────────────
  void _showValidationErrorDialog(
      {required String emailErr, required String passErr}) {
    final List<String> issues = [];
    if (emailErr.isNotEmpty) issues.add('• $emailErr');
    if (passErr.isNotEmpty) issues.add('• $passErr');
    final body = issues.join('\n');

    _showErpDialog(
      icon: Icons.warning_amber_rounded,
      color: ErpColors.amber,
      title: 'Invalid Input',
      message: 'Please enter a valid email and password to continue.',
      detail: body,
      buttonText: 'OK, GOT IT',
    );
  }

  // ── Invalid Credentials Dialog ────────────────────────────────
  void _showInvalidCredentialsDialog(String message) {
    _showErpDialog(
      icon: Icons.lock_person_rounded,
      color: ErpColors.red,
      title: 'Invalid Credentials',
      message: message.isNotEmpty
          ? message
          : 'The email or password you entered is incorrect. Please check your credentials and try again.',
      buttonText: 'TRY AGAIN',
    );
  }

  // ── Verification Required Dialog ────────────────────────────────
  void _showVerificationRequiredDialog() {
    _showErpDialog(
      icon: Icons.shield_rounded,
      color: ErpColors.orange,
      title: 'Verification Required',
      message: 'Please complete the human verification before signing in.',
      buttonText: 'OK',
    );
  }

  // ── Submit ────────────────────────────────────────────────────
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

    // Block submit until Cloudflare Turnstile has produced a token
    if (_turnstileToken == null || _turnstileToken!.isEmpty) {
      _showVerificationRequiredDialog();
      return;
    }

    // Clear old error before submitting
    loginProvider.clearError();

    // Capture values BEFORE the await — on success this screen may be
    // navigated away from and its controllers disposed.
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final remember = _rememberMe;

    await loginProvider.userLogin(
      email,
      password,
      _turnstileToken!,
      context,
    );

    final success = loginProvider.errorMessage == null;

    if (success) {
      // Save (or clear) the remembered credentials.
      await _persistCredentials(email, password, remember);
    }

    // Tells Android/iOS the login finished: on success the system shows its
    // "Save password?" prompt, on failure it discards the entered values.
    TextInput.finishAutofillContext(shouldSave: success);

    // Show dialog if error came back from ERP viewmodel
    if (mounted && loginProvider.errorMessage != null) {
      _showInvalidCredentialsDialog(loginProvider.errorMessage!);
      loginProvider.clearError();

      // Turnstile tokens are single-use — refresh so the user gets
      // a fresh token for the next attempt.
      await _turnstileController.refreshToken();
      if (mounted) setState(() => _turnstileToken = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginViewModel>(context);
    final sh = MediaQuery.of(context).size.height;
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ErpColors.cyanDeep,
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(gradient: ErpColors.headerGradient),
        child: Stack(
          children: [
            _buildBackground(sw, sh),
            _buildLogoArea(sh),
            _buildBottomSheet(loginProvider, sh),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(double sw, double sh) {
    Widget bubble(double size, double alpha) => AnimatedBuilder(
          animation: _pulseAnim,
          builder: (_, __) => Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: alpha * _pulseAnim.value),
            ),
          ),
        );

    return Stack(
      children: [
        Positioned(top: -60, right: -60, child: bubble(260, 0.12)),
        Positioned(top: 80, left: -40, child: bubble(140, 0.10)),
        Positioned(top: sh * 0.22, right: 30, child: bubble(60, 0.16)),
        Positioned(
          top: sh * 0.06,
          left: sw * 0.08,
          child: Transform.rotate(
            angle: -0.25,
            child: Icon(Icons.receipt_long_rounded,
                size: 70, color: Colors.white.withValues(alpha: 0.10)),
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
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.55), width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: ErpColors.cyanDeep.withValues(alpha: 0.35),
                        blurRadius: 30,
                        spreadRadius: 4,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Image.asset(AppAssets.logo, fit: BoxFit.contain),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Welcome Back',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3)),
                const SizedBox(height: 4),
                Text('Sign in to continue',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheet(LoginViewModel loginProvider, double sh) {
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
        padding: EdgeInsets.fromLTRB(22, 14, 22, bottomInset + 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(34),
            topRight: Radius.circular(34),
          ),
          boxShadow: [
            BoxShadow(
              color: ErpColors.cyanDeep.withValues(alpha: 0.25),
              blurRadius: 30,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: FadeTransition(
          opacity: _fieldsFade,
          child: SlideTransition(
            position: _fieldsSlide,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              // AutofillGroup lets the OS offer saved logins and show the
              // "Save password?" prompt after a successful sign in.
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sheet handle
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 18),
                          decoration: BoxDecoration(
                            color: ErpColors.line,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),

                      // Title block
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              ErpColors.cyan.withValues(alpha: 0.12),
                              ErpColors.cyan.withValues(alpha: 0.03),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: ErpColors.cyan.withValues(alpha: 0.18)),
                        ),
                        child: const Row(
                          children: [
                            ErpGradientTile(
                                icon: Icons.login_rounded,
                                color: ErpColors.cyan,
                                size: 46),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Login',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: ErpColors.ink)),
                                  SizedBox(height: 2),
                                  Text(
                                      'Enter your credentials to access your account',
                                      style: TextStyle(
                                          fontSize: 12.5,
                                          color: ErpColors.slate)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // ── Email Field
                      const ErpFieldLabel('Email ID', isRequired: true),
                      _buildTextField(
                        controller: _emailCtrl,
                        hint: 'Enter your email',
                        icon: Icons.email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        hasError: _emailError != null,
                        autofillHints: const [
                          AutofillHints.username,
                          AutofillHints.email,
                        ],
                        textInputAction: TextInputAction.next,
                        onChanged: (v) {
                          if (_emailError != null) {
                            setState(() => _emailError = _validateEmail(v));
                          }
                        },
                      ),
                      if (_emailError != null) ErpErrorText(_emailError!),

                      const SizedBox(height: 16),

                      // ── Password Field
                      const ErpFieldLabel('Password', isRequired: true),
                      _buildTextField(
                        controller: _passwordCtrl,
                        hint: 'Enter your password',
                        icon: Icons.lock_rounded,
                        obscure: !_passwordVisible,
                        hasError: _passwordError != null,
                        autofillHints: const [AutofillHints.password],
                        textInputAction: TextInputAction.done,
                        onChanged: (v) {
                          if (_passwordError != null) {
                            setState(
                                () => _passwordError = _validatePassword(v));
                          }
                        },
                        suffix: IconButton(
                          onPressed: () => setState(
                              () => _passwordVisible = !_passwordVisible),
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: _passwordVisible
                                ? ErpColors.cyanDeep
                                : ErpColors.slate,
                            size: 20,
                          ),
                        ),
                      ),
                      if (_passwordError != null)
                        ErpErrorText(_passwordError!),

                      const SizedBox(height: 14),

                      // ── Remember me
                      _buildRememberMe(),

                      const SizedBox(height: 14),

                      // ── Cloudflare Turnstile widget ──
                      Center(
                        child: CloudflareTurnstile(
                          siteKey: '0x4AAAAAAD06kaYZVN0kg0jC', // real Site Key
                          baseUrl:
                              'http://localhost/', // TODO: confirm this matches a domain registered for this Site Key in the Cloudflare dashboard
                          options: _turnstileOptions,
                          controller: _turnstileController,
                          onTokenReceived: (token) {
                            debugPrint('TURNSTILE: token received -> $token');
                            setState(() {
                              _turnstileToken = token;
                              _turnstileError = null;
                            });
                          },
                          onTokenExpired: () {
                            debugPrint('TURNSTILE: token expired');
                            setState(() => _turnstileToken = null);
                          },
                          onError: (error) {
                            debugPrint('TURNSTILE: error -> $error');
                            setState(() {
                              _turnstileToken = null;
                              _turnstileError = error.toString();
                            });
                          },
                        ),
                      ),
                      if (_turnstileError != null)
                        const Center(
                          child: ErpErrorText(
                              'Verification failed. Please try again.'),
                        ),

                      const SizedBox(height: 26),
                      ErpPrimaryButton(
                        text: 'SIGN IN',
                        icon: Icons.login_rounded,
                        loading: loginProvider.isLoading,
                        onTap: () => _submit(loginProvider),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_user_rounded,
                                size: 14, color: ErpColors.green),
                            const SizedBox(width: 5),
                            Text('Secured sign in',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: ErpColors.slate
                                        .withValues(alpha: 0.85))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRememberMe() {
    return ErpPressable(
      scale: 0.98,
      onTap: () => setState(() => _rememberMe = !_rememberMe),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              gradient: _rememberMe ? ErpColors.headerGradient : null,
              color: _rememberMe ? null : ErpColors.pageBg,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: _rememberMe ? Colors.transparent : ErpColors.line,
                width: 1.5,
              ),
            ),
            child: _rememberMe
                ? const Icon(Icons.check_rounded,
                    size: 15, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Text(
            'Remember me',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: _rememberMe ? ErpColors.cyanDeep : ErpColors.slate,
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
    Iterable<String>? autofillHints,
    TextInputAction? textInputAction,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      textInputAction: textInputAction,
      onChanged: onChanged,
      cursorColor: ErpColors.cyan,
      style: TextStyle(
          fontSize: 14.5,
          color: hasError ? ErpColors.red : ErpColors.ink,
          fontWeight: FontWeight.w600),
      decoration: erpInputDecoration(
        hint: hint,
        icon: icon,
        hasError: hasError,
      ).copyWith(suffixIcon: suffix),
    );
  }
}