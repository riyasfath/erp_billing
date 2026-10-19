import 'package:flutter/material.dart';
import 'package:ecommerce_app/app_colors.dart';

const List<Map<String, String>> _termsSections = [
  {
    'title': '1. Acceptance of Terms',
    'body':
        'By accessing and using Shopivia, you agree to be bound by these Terms of Service. If you do not agree with any part of the terms, please do not use the app.',
  },
  {
    'title': '2. Account & Eligibility',
    'body':
        'You must be at least 18 years old to create an account and make purchases on Shopivia. You are responsible for maintaining the confidentiality of your login credentials.',
  },
  {
    'title': '3. Orders & Payments',
    'body':
        'All orders are subject to availability and confirmation. Shopivia reserves the right to cancel any order due to stock issues, payment verification, or system error. Accepted payment methods include credit/debit cards, e-wallets, and Shopivia Wallet.',
  },
  {
    'title': '4. Shipping & Delivery',
    'body':
        'Estimated delivery times are provided during checkout. Actual delivery may vary due to logistics and location. Delays will be communicated as needed.',
  },
  {
    'title': '5. Returns & Refunds',
    'body':
        'Returns and refunds are subject to our Return Policy. Eligible returns must be requested within 7 days of product delivery.',
  },
  {
    'title': '6. User Conduct',
    'body':
        "You agree not to misuse the platform, upload harmful content, or interfere with other users' experiences.",
  },
  {
    'title': '7. Modifications',
    'body':
        'We may update these terms from time to time. Continued use of Shopivia after updates means you accept the revised terms.',
  },
];

/// "Terms of Services" screen — numbered legal sections plus contact
/// details at the bottom.
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
                  Row(
                    children: const [
                      Text('Last Updated', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                      Spacer(),
                      Text('8 May 2025', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ..._termsSections.map((s) => _section(s['title']!, s['body']!)),
                  const Text('8. Contact Us', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 6),
                  const Text(
                    'If you have any questions regarding this Privacy Policy, please contact us at:',
                    style: TextStyle(fontSize: 12, color: AppColors.textGrey, height: 1.5),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _contactCard(Icons.call_outlined, 'Phone Number', '+318914897')),
                      const SizedBox(width: 12),
                      Expanded(child: _contactCard(Icons.chat_bubble_outline, 'Whatsapp Number', '+62 8123 4567 890')),
                    ],
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
          const Text('Terms of Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(fontSize: 12, color: AppColors.textGrey, height: 1.5)),
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
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        ],
      ),
    );
  }
}