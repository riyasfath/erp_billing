import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/viewmodels/access_viewmodel.dart';
import 'package:pokakbilling/views/Screens/auth/login_screen.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// ═════════════════════════════════════════════════════════════════════════════
// Shared gradient backdrop with soft bubbles (used by splash + onboarding)
// ═════════════════════════════════════════════════════════════════════════════
class _GradientWave extends StatelessWidget {
  final Widget child;
  const _GradientWave({required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ClipPath(
      clipper: BottomWaveClipper(),
      child: Container(
        height: size.height * 0.89,
        width: double.infinity,
        decoration: const BoxDecoration(gradient: ErpColors.headerGradient),
        child: Stack(
          children: [
            Positioned(
              top: -70,
              right: -70,
              child: _bubble(260, 0.12),
            ),
            Positioned(
              top: size.height * 0.18,
              left: -50,
              child: _bubble(150, 0.09),
            ),
            Positioned(
              bottom: size.height * 0.18,
              right: 30,
              child: _bubble(70, 0.14),
            ),
            Positioned.fill(child: child),
          ],
        ),
      ),
    );
  }

  static Widget _bubble(double s, double a) => Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: a),
          shape: BoxShape.circle,
        ),
      );
}

class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) => Container(
        height: 8,
        width: 100,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [ErpColors.cyanDeep, ErpColors.cyan, ErpColors.cyanLight]),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: ErpColors.cyan.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
      );
}

Widget _logoBadge(String asset, {double size = 130}) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.55), width: 5),
        boxShadow: [
          BoxShadow(
            color: ErpColors.cyanDeep.withValues(alpha: 0.35),
            blurRadius: 34,
            spreadRadius: 4,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipOval(
        child: Padding(
          padding: EdgeInsets.all(size * 0.18),
          child: Image.asset(asset, fit: BoxFit.contain),
        ),
      ),
    );

// Initial Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.75, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkOnboardingScreen(context);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void checkOnboardingScreen(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    final accessProvider = Provider.of<AccessViewModel>(context, listen: false);

    Timer(
      const Duration(seconds: 3),
      () {
        if (hasSeenOnboarding) {
          accessProvider.checkingIsLoggedIn
              ? pushReplacementNavigation(context, const ErpBottomBar(index: 0))
              : pushReplacementNavigation(context, const LoginScreen());
        } else {
          pushReplacementNavigation(context, const OnboardingScreen());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ErpColors.pageBg,
      body: Column(
        children: [
          _GradientWave(
            child: Center(
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _logoBadge(AppAssets.logo),
                      const SizedBox(height: 22),
                      const Text(
                        "POKAK",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35)),
                        ),
                        child: const Text(
                          "GROW YOUR BUSINESS TURNOVER",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          const _BottomBar(),
        ],
      ),
    );
  }
}

// Onboarding Screen with PageView
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      image: AppAssets.logo,
      title: 'POKAK',
      subtitle: 'GROW YOUR BUSINESS TURNOVER',
      description: 'Manage Your Business\nWith Us',
    ),
    OnboardingPage(
      image: AppAssets.splashframetwo,
      title: '',
      subtitle: '',
      description: 'Simple and powerful\nBilling App',
    ),
    OnboardingPage(
      image: AppAssets.splashframefour,
      title: '',
      subtitle: '',
      description: 'Most secure app\nWe dont save your informations',
    ),
    OnboardingPage(
      image: AppAssets.splashframethree,
      title: '',
      subtitle: '',
      description: 'Lets Started',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenOnboarding', true);
      if (mounted) {
        pushReplacementNavigation(context, const LoginScreen());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: ErpColors.pageBg,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return OnboardingPageWidget(page: _pages[index]);
            },
          ),
          Positioned(
            bottom: 140,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _pageController,
                  count: _pages.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 3.2,
                    spacing: 6,
                    activeDotColor: Colors.white,
                    dotColor: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
                const SizedBox(height: 16),
                ErpPressable(
                  onTap: _onNext,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOut,
                    height: 48,
                    padding: EdgeInsets.symmetric(horizontal: isLast ? 24 : 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: ErpColors.cyanDeep.withValues(alpha: 0.30),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isLast ? 'Get Started' : 'Next',
                          style: const TextStyle(
                            color: ErpColors.cyanDeep,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            gradient: ErpColors.headerGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 17,
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

// Onboarding Page Model
class OnboardingPage {
  final String image;
  final String title;
  final String subtitle;
  final String description;

  OnboardingPage({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}

// Onboarding Page Widget
class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;

  const OnboardingPageWidget({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    final isLogoPage = page.title.isNotEmpty;

    return Column(
      children: [
        _GradientWave(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              if (isLogoPage)
                _logoBadge(page.image, size: 150)
              else
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35)),
                  ),
                  child: Image.asset(page.image, width: 200),
                ),
              if (page.title.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(
                  page.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
              ],
              if (page.subtitle.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    page.subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  page.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const _BottomBar(),
      ],
    );
  }
}

// Wave Clipper

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Start from top-left
    path.lineTo(0, size.height * 0.92); // Move down 90% of height

    // Single curve control point at bottom center
    final controlPoint = Offset(size.width * 0.5, size.height * 1.1);
    final endPoint = Offset(size.width, size.height * 0.80);

    path.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      endPoint.dx,
      endPoint.dy,
    );

    // Complete the path
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Placeholder for your main app screen
class YourMainScreen extends StatelessWidget {
  const YourMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Main App Screen'),
      ),
    );
  }
}