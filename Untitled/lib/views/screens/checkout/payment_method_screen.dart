import 'package:flutter/material.dart';
import 'package:ecommerce_app/app_colors.dart';

class _PaymentOption {
  final String code; // sent to the API exactly as-is
  final String label;
  final String subtitle;
  final IconData icon;
  const _PaymentOption(this.code, this.label, this.subtitle, this.icon);
}

// Only cod (Cash on Delivery) and online (Razorpay) are offered now.
const List<_PaymentOption> _paymentOptions = [
  _PaymentOption('cod', 'Cash on Delivery', 'Pay when your order arrives', Icons.payments_outlined),
  _PaymentOption('online', 'Online Payment', 'Pay now via card, UPI, netbanking & more', Icons.credit_card_outlined),
];

/// Payment method picker — pops with the selected code ('cod' or
/// 'online'). 'online' triggers the Razorpay checkout sheet from
/// CheckoutScreen after the order is placed.
class PaymentMethodScreen extends StatefulWidget {
  final String? initialSelection;

  const PaymentMethodScreen({super.key, this.initialSelection});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelection;
  }

  void _confirm() {
    if (_selected == null) return;
    Navigator.pop(context, _selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                itemCount: _paymentOptions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _optionCard(_paymentOptions[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _selected == null ? null : _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    disabledBackgroundColor: AppColors.borderGrey,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text('Confirm', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionCard(_PaymentOption option) {
    final bool selected = _selected == option.code;
    return GestureDetector(
      onTap: () => setState(() => _selected = option.code),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.primaryBlue : AppColors.borderGrey),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: AppColors.bgLight, borderRadius: BorderRadius.circular(10)),
              child: Icon(option.icon, size: 20, color: AppColors.primaryBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(option.subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primaryBlue : AppColors.borderGrey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          const Text(
            'Payment Method',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }
}