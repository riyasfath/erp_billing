import 'package:flutter/material.dart';
import 'package:ecommerce_app/app_colors.dart';

const List<Map<String, String>> _privacySections = [
  {
    'title': '1. Data Collection',
    'body':
        'We collect personal information you provide when signing up, placing orders, or contacting us. This may include your name, address, email, and payment details.',
  },
  {
    'title': '2. How We Use Your Data',
    'body':
        'Your data is used to process orders, provide customer service, personalize your shopping experience, and send updates about your account or promotions (if subscribed).',
  },
  {
    'title': '3. Data Sharing',
    'body':
        'We do not sell your personal data. Your information may be shared only with trusted logistics or payment partners necessary to complete your order.',
  },
  {
    'title': '4. Security',
    'body':
        'We implement appropriate security measures to protect your personal information. However, no method of transmission over the Internet is 100% secure.',
  },
  {
    'title': '5. Cookies',
    'body':
        'Shopivia may use cookies and tracking tools to enhance functionality and analyze app performance. You can manage cookie preferences in your browser settings.',
  },
  {
    'title': '6. Your Rights',
    'body':
        'You have the right to access, correct, or delete your personal data by contacting our support team.',
  },
];

/// "Privacy Policy" screen — numbered sections plus contact details at
/// the bottom, matching the Terms of Service screen's layout.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
                  ..._privacySections.map((s) => _section(s['title']!, s['body']!)),
                  const Text('7. Contact Us', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _contactCard(Icons.language, 'Website', 'shopivia.co')),
                      const SizedBox(width: 12),
                      Expanded(child: _contactCard(Icons.email_outlined, 'Email', 'hello@shopivia.co')),
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
          const Text('Privacy Policy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
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