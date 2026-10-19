// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/themes/app_assets.dart';
// import 'package:pokakbilling/core/navigations.dart';
// import 'package:pokakbilling/viewmodels/access_viewmodel.dart';
// import 'package:pokakbilling/views/Screens/auth/login_screen.dart';
// import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// // Initial Splash Screen
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       checkOnboardingScreen(context);
//     });
//   }

//   void checkOnboardingScreen(context) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
//     final accessProvider = Provider.of<AccessViewModel>(context, listen: false);

//     Timer(
//       const Duration(seconds: 3),
//       () {
//         if (hasSeenOnboarding) {
//           accessProvider.checkingIsLoggedIn
//               ? pushReplacementNavigation(context, const BottomBar(index: 0))
//               : pushReplacementNavigation(context, const LoginScreen());
//         } else {
//           pushReplacementNavigation(context, const OnboardingScreen());
//         }
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           ClipPath(
//             clipper: BottomWaveClipper(),
//             child: Container(
//               height: MediaQuery.of(context).size.height * 0.89,
//               // color: const Color(0xff643CB5),
//               color: AppColors.primaryColor,
//               child: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Image.asset(AppAssets.logo),
//                     const SizedBox(height: 10),
//                     const Text(
//                       "POKAK",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 17,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const Text(
//                       "GROW YOUR BUSINESS TURNOVER",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 17,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 40),
//           Container(
//             height: 8,
//             width: 100,
//             decoration: BoxDecoration(
//               color: AppColors.primaryColor,
//               borderRadius: BorderRadius.circular(10),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// // Onboarding Screen with PageView
// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({super.key});

//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends State<OnboardingScreen> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;

//   final List<OnboardingPage> _pages = [
//     OnboardingPage(
//       image: AppAssets.logo,
//       title: 'POKAK',
//       subtitle: 'GROW YOUR BUSINESS TURNOVER',
//       description: 'Manage Your Business\nWith Us',
//     ),
//     OnboardingPage(
//       image: AppAssets.splashframetwo,
//       title: '',
//       subtitle: '',
//       description: 'Simple and powerful\nBilling App',
//     ),
//     OnboardingPage(
//       image: AppAssets.splashframefour,
//       title: '',
//       subtitle: '',
//       description: 'Most secure app\nWe dont save your informations',
//     ),
//     OnboardingPage(
//       image: AppAssets.splashframethree,
//       title: '',
//       subtitle: '',
//       description: 'Lets Started',
//     ),
//   ];

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           PageView.builder(
//             controller: _pageController,
//             onPageChanged: (index) {
//               setState(() {
//                 _currentPage = index;
//               });
//             },
//             itemCount: _pages.length,
//             itemBuilder: (context, index) {
//               return OnboardingPageWidget(page: _pages[index]);
//             },
//           ),
//           Positioned(
//             bottom: 140,
//             left: 0,
//             right: 0,
//             child: Column(
//               children: [
//                 SmoothPageIndicator(
//                   controller: _pageController,
//                   count: _pages.length,
//                   effect: const WormEffect(
//                     dotHeight: 9,
//                     dotWidth: 9,
//                     activeDotColor: Colors.white,
//                     dotColor: Colors.grey,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Container(
//                   height: 42,
//                   width: 88,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(40),
//                   ),
//                   child: IconButton(
//                     onPressed: () async {
//                       if (_currentPage < _pages.length - 1) {
//                         _pageController.nextPage(
//                           duration: const Duration(milliseconds: 300),
//                           curve: Curves.easeInOut,
//                         );
//                       } else {
//                         SharedPreferences prefs =
//                             await SharedPreferences.getInstance();
//                         await prefs.setBool('hasSeenOnboarding', true);
//                         if (context.mounted) {
//                           pushReplacementNavigation(
//                               context, const LoginScreen());
//                         }
//                       }
//                     },
//                     icon: const Icon(
//                       Icons.arrow_forward,
//                       color: AppColors.violetblue,
//                       size: 20,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Onboarding Page Model
// class OnboardingPage {
//   final String image;
//   final String title;
//   final String subtitle;
//   final String description;

//   OnboardingPage({
//     required this.image,
//     required this.title,
//     required this.subtitle,
//     required this.description,
//   });
// }

// // Onboarding Page Widget
// class OnboardingPageWidget extends StatelessWidget {
//   final OnboardingPage page;

//   const OnboardingPageWidget({super.key, required this.page});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         ClipPath(
//           clipper: BottomWaveClipper(),
//           child: Container(
//             height: MediaQuery.of(context).size.height * 0.89,
//             width: double.infinity,
//             color: AppColors.violetblue,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 20),
//                 Image.asset(
//                   page.image,
//                   width: 200,
//                 ),
//                 if (page.title.isNotEmpty) ...[
//                   const SizedBox(height: 10),
//                   Text(
//                     page.title,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//                 if (page.subtitle.isNotEmpty) ...[
//                   const SizedBox(height: 5),
//                   Text(
//                     page.subtitle,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ],
//                 const SizedBox(height: 60),
//                 Text(
//                   page.description,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 40),
//         Container(
//           height: 8,
//           width: 100,
//           decoration: BoxDecoration(
//             color: AppColors.violetblue,
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // Wave Clipper

// class BottomWaveClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final path = Path();

//     // Start from top-left
//     path.lineTo(0, size.height * 0.92); // Move down 90% of height

//     // Single curve control point at bottom center
//     final controlPoint = Offset(size.width * 0.5, size.height * 1.1);
//     final endPoint = Offset(size.width, size.height * 0.80);

//     path.quadraticBezierTo(
//       controlPoint.dx,
//       controlPoint.dy,
//       endPoint.dx,
//       endPoint.dy,
//     );

//     // Complete the path
//     path.lineTo(size.width, 0);
//     path.close();

//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }

// // Placeholder for your main app screen
// class YourMainScreen extends StatelessWidget {
//   const YourMainScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(
//         child: Text('Main App Screen'),import 'dart:async';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/viewmodels/access_viewmodel.dart';
import 'package:pokakbilling/views/Screens/auth/login_screen.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// ─── Strict 3-color palette ───────────────────────────────────────────────────
class _C {
  _C._();
  static const Color navy = AppColors.navy;
  static const Color cyan = AppColors.cyan;
  static const Color ice = AppColors.ice;
  static const Color white = AppColors.white;
}
// ─────────────────────────────────────────────────────────────────────────────

// ══════════════════════════════════════════════════════════════════════════════
//  SPLASH SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Logo animations
  late final AnimationController _logoCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _logoSlide;

  // Text animations
  late final AnimationController _textCtrl;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  // Progress bar
  late final AnimationController _barCtrl;
  late final Animation<double> _barProgress;

  // Pulse glow
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    // Logo
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _logoScale = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));
    _logoFade = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut);
    _logoSlide = Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut));

    // Text
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _textFade = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut);
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.20), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));

    // Progress bar (3 seconds)
    _barCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000));
    _barProgress = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _barCtrl, curve: Curves.easeInOut));

    // Pulse
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // Stagger
    _logoCtrl.forward();
    Future.delayed(
        const Duration(milliseconds: 400), () => _textCtrl.forward());
    Future.delayed(const Duration(milliseconds: 600), () => _barCtrl.forward());

    // Navigate after 3.5s
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNavigation();
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _barCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _checkNavigation() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    final accessProvider = Provider.of<AccessViewModel>(context, listen: false);

    Timer(const Duration(milliseconds: 3500), () {
      if (!mounted) return;
      if (hasSeenOnboarding) {
        accessProvider.checkingIsLoggedIn
            ? pushReplacementNavigation(context, const BottomBar(index: 0))
            : pushReplacementNavigation(context, const LoginScreen());
      } else {
        pushReplacementNavigation(context, const OnboardingScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: _C.navy,
      body: Stack(
        children: [
          // ── Decorative background circles ────────────────────────
          _buildBackground(sw, sh),

          // ── Center content ───────────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo with glow ring
                FadeTransition(
                  opacity: _logoFade,
                  child: SlideTransition(
                    position: _logoSlide,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: _buildLogoRing(),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // App name + tagline
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: _buildTextBlock(),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom progress bar ──────────────────────────────────
          Positioned(
            bottom: 60,
            left: sw * 0.20,
            right: sw * 0.20,
            child: FadeTransition(
              opacity: _textFade,
              child: _buildProgressBar(),
            ),
          ),

          // ── Version tag ──────────────────────────────────────────
          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _textFade,
              child: Text(
                'v1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _C.ice.withOpacity(0.30),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(double sw, double sh) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -80,
          child: AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, __) => Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _C.cyan.withOpacity(0.07 * _pulseAnim.value),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -80,
          child: AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, __) => Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _C.cyan.withOpacity(0.05 * _pulseAnim.value),
              ),
            ),
          ),
        ),
        Positioned(
          top: sh * 0.35,
          right: 20,
          child: AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, __) => Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _C.cyan.withOpacity(0.08 * _pulseAnim.value),
              ),
            ),
          ),
        ),
        Positioned(
          top: sh * 0.20,
          left: 30,
          child: AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, __) => Container(
              width: 40,
              height: 40,
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

  Widget _buildLogoRing() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, child) => Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _C.cyan.withOpacity(0.05 * _pulseAnim.value),
            ),
          ),
          // Middle ring
          Container(
            width: 124,
            height: 124,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _C.cyan.withOpacity(0.08 * _pulseAnim.value),
              border: Border.all(
                color: _C.cyan.withOpacity(0.15 * _pulseAnim.value),
                width: 1.5,
              ),
            ),
          ),
          // Inner logo container
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_C.cyan, _C.navy],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: _C.cyan.withOpacity(0.50),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _C.cyan.withOpacity(0.35 * _pulseAnim.value),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: ClipOval(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Image.asset(
                  AppAssets.logo,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextBlock() {
    return Column(
      children: [
        // App name with gradient text effect
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [_C.cyan, _C.white],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: const Text(
            'POKAK',
            style: TextStyle(
              color: _C.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: 6,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Divider line
        Container(
          width: 40,
          height: 2,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_C.cyan, _C.navy],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'GROW YOUR BUSINESS TURNOVER',
          style: TextStyle(
            color: _C.ice.withOpacity(0.65),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.5,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _barProgress,
          builder: (_, __) => ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Stack(
              children: [
                // Track
                Container(
                  height: 3,
                  width: double.infinity,
                  color: _C.white.withOpacity(0.10),
                ),
                // Fill
                FractionallySizedBox(
                  widthFactor: _barProgress.value,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_C.cyan, _C.white],
                      ),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: _C.cyan.withOpacity(0.50),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Loading...',
          style: TextStyle(
            color: _C.ice.withOpacity(0.35),
            fontSize: 11,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  ONBOARDING SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  late final AnimationController _btnCtrl;
  late final Animation<double> _btnScale;

  final List<_OnboardData> _pages = [
    _OnboardData(
      image: AppAssets.logo,
      title: 'POKAK',
      subtitle: 'Grow Your Business Turnover',
      description: 'Manage your entire business\nfrom one powerful app.',
      gradientColors: [AppColors.navy, Color(0xFF3A4D6B)],
    ),
    _OnboardData(
      image: AppAssets.splashframetwo,
      title: 'Smart Billing',
      subtitle: 'Simple & Powerful',
      description: 'Create invoices, manage\nquotations effortlessly.',
      gradientColors: [AppColors.navy, Color(0xFF1A3A5C)],
    ),
    _OnboardData(
      image: AppAssets.splashframefour,
      title: 'Secure & Private',
      subtitle: 'Your data is safe',
      description: 'We never store your\npersonal information.',
      gradientColors: [AppColors.navy, Color(0xFF0D2137)],
    ),
    _OnboardData(
      image: AppAssets.splashframethree,
      title: "Let's Go!",
      subtitle: 'Ready to start?',
      description: 'Join thousands of businesses\nalready using POKAK.',
      gradientColors: [AppColors.navy, AppColors.cyan],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _btnCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _btnScale = Tween<double>(begin: 1.0, end: 0.92)
        .animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _btnCtrl.dispose();
    super.dispose();
  }

  bool get _isLastPage => _currentPage == _pages.length - 1;

  Future<void> _handleNext() async {
    await _btnCtrl.forward();
    await _btnCtrl.reverse();

    if (_isLastPage) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenOnboarding', true);
      if (mounted) {
        pushReplacementNavigation(context, const LoginScreen());
      }
    } else {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.navy,
      body: Stack(
        children: [
          // Pages
          PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) => _OnboardPageWidget(
              data: _pages[i],
              isActive: _currentPage == i,
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            _C.navy.withOpacity(0.95),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Skip button
          AnimatedOpacity(
            opacity: _isLastPage ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: _isLastPage
                  ? null
                  : () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('hasSeenOnboarding', true);
                      if (mounted) {
                        pushReplacementNavigation(context, const LoginScreen());
                      }
                    },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _C.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _C.white.withOpacity(0.15),
                  ),
                ),
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: _C.ice.withOpacity(0.70),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // Page indicator
          SmoothPageIndicator(
            controller: _pageCtrl,
            count: _pages.length,
            effect: WormEffect(
              dotHeight: 8,
              dotWidth: 8,
              spacing: 6,
              activeDotColor: _C.cyan,
              dotColor: _C.white.withOpacity(0.20),
              paintStyle: PaintingStyle.fill,
            ),
          ),

          // Next / Get Started button
          ScaleTransition(
            scale: _btnScale,
            child: GestureDetector(
              onTap: _handleNext,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(
                  horizontal: _isLastPage ? 20 : 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_C.cyan, _C.navy],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _C.cyan.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isLastPage) ...[
                      const Text(
                        "Get Started",
                        style: TextStyle(
                          color: _C.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: _C.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Onboarding page data model ───────────────────────────────────────────────
class _OnboardData {
  final String image;
  final String title;
  final String subtitle;
  final String description;
  final List<Color> gradientColors;

  const _OnboardData({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.gradientColors,
  });
}

// ─── Onboarding page widget ───────────────────────────────────────────────────
class _OnboardPageWidget extends StatefulWidget {
  final _OnboardData data;
  final bool isActive;

  const _OnboardPageWidget({
    required this.data,
    required this.isActive,
  });

  @override
  State<_OnboardPageWidget> createState() => _OnboardPageWidgetState();
}

class _OnboardPageWidgetState extends State<_OnboardPageWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _imgScale;
  late final Animation<double> _imgFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _textFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _imgScale = Tween<double>(begin: 0.80, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _imgFade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _textFade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    if (widget.isActive) _ctrl.forward();
  }

  @override
  void didUpdateWidget(_OnboardPageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _ctrl.reset();
      _ctrl.forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.data.gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // Background decorative circles
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _C.cyan.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            top: sh * 0.15,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _C.cyan.withOpacity(0.06),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 180),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image
                FadeTransition(
                  opacity: _imgFade,
                  child: ScaleTransition(
                    scale: _imgScale,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: _C.cyan.withOpacity(0.10),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _C.cyan.withOpacity(0.20),
                          width: 1.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Image.asset(
                          widget.data.image,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // Text block
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: Column(
                      children: [
                        // Title with gradient
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [_C.cyan, _C.white],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(bounds),
                          child: Text(
                            widget.data.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: _C.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Accent divider
                        Container(
                          width: 36,
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_C.cyan, _C.white],
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Subtitle
                        Text(
                          widget.data.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _C.cyan.withOpacity(0.90),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Description
                        Text(
                          widget.data.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _C.ice.withOpacity(0.65),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
//       ),
//     );
//   }
// }
