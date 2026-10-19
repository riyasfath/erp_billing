import 'package:flutter/material.dart';
import 'package:ecommerce_app/app_colors.dart';

const List<Map<String, String>> _faqs = [
  {
    'q': 'How do I place an order?',
    'a': 'Simply browse the products, select the variant (size, color, etc.), tap "Add to Cart", and proceed to checkout. You\'ll be guided step-by-step to complete your purchase.',
  },
  {
    'q': 'What payment methods are accepted?',
    'a': 'We accept cash on delivery, bank transfer, e-wallet, and credit or debit cards.',
  },
  {'q': 'How do I track my order?', 'a': 'Go to My Account > My Orders, then tap any order to see its live tracking status.'},
  {'q': 'Can I cancel or change my order?', 'a': 'You can cancel an order before it ships from the Order Tracking screen.'},
  {'q': 'How long does shipping take?', 'a': 'Delivery times vary by method: Instant (1 day), Fast (2-3 days), or Regular (3-4 days).'},
  {'q': 'How do I return a product?', 'a': 'Open the delivered order, tap "Return Product", choose a reason, and submit your request.'},
  {'q': 'Where can I find my vouchers?', 'a': 'Your vouchers are listed under My Account > My Voucher.'},
  {'q': 'What is Shopivia Wallet?', 'a': 'Shopivia Wallet is an in-app balance you can top up and use for faster checkout.'},
  {'q': "Why can't I apply my voucher?", 'a': 'Check the voucher\'s expiry date and minimum spend requirement before applying it at checkout.'},
];

/// "FAQ's" screen — a simple expandable Q&A list.
class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

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
                  const Text(
                    'Frequently Asked Questions',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "This FAQ's last updated was 8 May 2025",
                    style: TextStyle(fontSize: 11, color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 14),
                  ..._faqs.map((faq) => _faqTile(faq['q']!, faq['a']!)),
                  const SizedBox(height: 20),
                  const Text(
                    'Still have unanswered questions?',
                    style: TextStyle(fontSize: 12, color: AppColors.textGrey),
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
          const Text("FAQ's", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _faqTile(String question, String answer) {
    return Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 12),
        iconColor: AppColors.primaryBlue,
        collapsedIconColor: AppColors.textGrey,
        title: Text(question, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(answer, style: const TextStyle(fontSize: 12, color: AppColors.textGrey, height: 1.5)),
          ),
        ],
      ),
    );
  }
}