import 'package:ecommerce_app/views/screens/my_settings/faq_screen.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/app_colors.dart';

/// "Help & Support" screen — contact channels + a link to the FAQ list.
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  const Text('Contact Support', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  const Text(
                    "Your top up transaction successfully added, let's go !",
                    style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _contactCard(Icons.call_outlined, 'Phone Number', '+318914897')),
                      const SizedBox(width: 12),
                      Expanded(child: _contactCard(Icons.chat_bubble_outline, 'Whatsapp Number', '+62 8123 4567 890')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _contactCard(Icons.language, 'Website', 'shopivia.co')),
                      const SizedBox(width: 12),
                      Expanded(child: _contactCard(Icons.email_outlined, 'Email', 'hello@shopivia.co')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FAQScreen())),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderGrey),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(color: AppColors.bgLight, borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.help_outline, size: 16, color: AppColors.primaryBlue),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Our FAQ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                                Text("Let's find out the answer of your question", style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 18, color: AppColors.textGrey),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          const Text('Help & Support', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _contactCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.badgeRed),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }
}