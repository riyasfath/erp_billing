import 'package:ecommerce_app/views/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'onboarding_data.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  void nextPage() {
    if (currentPage < onboardingList.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  String getButtonText() {
    if (currentPage == 0) return "Get Started";
    return "Next";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageView.builder(
          controller: _controller,
          itemCount: onboardingList.length,
          onPageChanged: (index) {
            setState(() => currentPage = index);
          },
          itemBuilder: (context, index) {
            final data = onboardingList[index];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TOP
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.55,
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            "NIKE",
                            style: TextStyle(
                              fontSize: 120,
                              fontWeight: FontWeight.bold,
                              color: Colors.black.withOpacity(0.03),
                            ),
                          ),
                        ),
                        Positioned(
                          top: -60,
                          right: -60,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(top: 80, left: 20, child: _dot()),
                        Positioned(bottom: 40, left: 10, child: _dot()),
                        Positioned(bottom: 80, right: 30, child: _dot()),

                        /// IMAGE FIXED
                        Center(
                          child: SizedBox(
                            height: 240,
                            width: 300,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Transform.rotate(
                                angle: -0.15,
                                child: Image.asset(data.image),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    data.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    data.subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  const Spacer(),

                  /// BOTTOM
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          onboardingList.length,
                          (i) => _indicator(i == currentPage),
                        ),
                      ),

                      ElevatedButton(
                        onPressed: nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          getButtonText(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _dot() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _indicator(bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      width: active ? 18 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF2563EB) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
