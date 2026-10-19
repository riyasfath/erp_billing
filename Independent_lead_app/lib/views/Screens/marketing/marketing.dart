import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/views/Screens/marketing/MarketingDataScreen.dart';
import 'package:pokakbilling/views/Screens/marketing/report/marketing_report.dart';

class MarketingScreen extends StatefulWidget {
  const MarketingScreen({super.key});

  @override
  State<MarketingScreen> createState() => _MarketingScreenState();
}

class _MarketingScreenState extends State<MarketingScreen> {
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.violetblue,
        title: const Text(
          'Marketing',
          style: TextStyle(color: AppColors.white, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(
            CupertinoIcons.arrow_left,
            color: AppColors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SizedBox(
        height: height,
        width: width,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 40, left: 31, right: 31),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GradientCard(
                  text: "Marketing\ndata",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MarketingDataScreen()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                GradientCard(
                  text: "Marketing\nReports",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MarketingReportScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GradientCard extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const GradientCard({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 326,
      height: 82,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.violetblue,
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Row(
            children: [
              // Gradient section (left part)
              Expanded(
                flex: 4,
                child: Container(
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: AppColors.buttonGradient,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onPressed,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // White section with arrow (right part)
              Expanded(
                flex: 1,
                child: Container(
                  height: double.infinity,
                  color: Colors.white,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onPressed,
                      child: const Center(
                        child: Icon(
                          Icons.chevron_right,
                          color: AppColors.violetblue,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
