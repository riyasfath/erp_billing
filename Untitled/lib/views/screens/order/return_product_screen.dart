// import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/app_colors.dart';
import 'package:ecommerce_app/models/order_model.dart';
import 'package:ecommerce_app/viewmodel/order_detail_viewmodel.dart';

class _ReturnReason {
  final String code;
  final String label;
  const _ReturnReason(this.code, this.label);
}

// Matches the order API's
// `_reason_options: "defective, wrong_item, size_issue, changed_mind"`.
const List<_ReturnReason> _returnReasons = [
  _ReturnReason('defective', 'Product damaged / defective'),
  _ReturnReason('wrong_item', 'Wrong item delivered'),
  _ReturnReason('size_issue', "Size doesn't fit"),
  _ReturnReason('changed_mind', 'Changed my mind'),
];

/// "Return Product" screen — pick a reason (+ optional comment) for
/// each item in the order, then submit via
/// POST /api/orders/{id}/return/. Pops with `true` on success so the
/// caller (OrderTrackingScreen) can show a return-in-progress state.
class ReturnProductScreen extends StatefulWidget {
  final OrderModel order;

  const ReturnProductScreen({super.key, required this.order});

  @override
  State<ReturnProductScreen> createState() => _ReturnProductScreenState();
}

class _ReturnProductScreenState extends State<ReturnProductScreen> {
  // One selected reason per order item (keyed by item id).
  final Map<int, String> _selectedReasons = {};
  final Map<int, TextEditingController> _commentControllers = {};

  @override
  void initState() {
    super.initState();
    for (final item in widget.order.items) {
      _commentControllers[item.id] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _commentControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppColors.badgeRed : AppColors.primaryBlue,
      ),
    );
  }

  Future<void> _submit(OrderDetailViewModel viewModel) async {
    if (_selectedReasons.isEmpty) {
      _showSnack('Please choose a reason for at least one item', isError: true);
      return;
    }

    final items = _selectedReasons.entries
        .map((e) => ReturnItemRequest(
              itemId: e.key,
              reason: e.value,
              comment: _commentControllers[e.key]?.text.trim() ?? '',
            ))
        .toList();

    final success = await viewModel.returnOrder(items);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    } else {
      _showSnack(viewModel.returnError ?? 'Could not submit the return', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OrderDetailViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.order.items
                      .map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: _itemReturnCard(item),
                          ))
                      .toList(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: viewModel.isReturning ? null : () => _submit(viewModel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: viewModel.isReturning
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text('Submit Return', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemReturnCard(OrderItemModel item) {
    final bool isNetworkImage = item.imageUrl.startsWith('http');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: AppColors.bgLight, borderRadius: BorderRadius.circular(10)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: item.imageUrl.isEmpty
                    ? const Icon(Icons.image_outlined, color: AppColors.hintGrey, size: 20)
                    : isNetworkImage
                        ? Image.network(item.imageUrl, fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Icon(Icons.image_outlined, color: AppColors.hintGrey, size: 20))
                        : Image.asset(item.imageUrl, fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Icon(Icons.image_outlined, color: AppColors.hintGrey, size: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.productName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Reason for return',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
        ),
        ..._returnReasons.map((reason) => RadioListTile<String>(
              value: reason.code,
              groupValue: _selectedReasons[item.id],
              onChanged: (v) => setState(() => _selectedReasons[item.id] = v!),
              activeColor: AppColors.primaryBlue,
              contentPadding: EdgeInsets.zero,
              title: Text(reason.label, style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
            )),
        const SizedBox(height: 8),
        const Text(
          'Additional Details (optional)',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderGrey),
          ),
          child: TextField(
            controller: _commentControllers[item.id],
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Please describe the issue in detail...',
              hintStyle: TextStyle(color: AppColors.hintGrey, fontSize: 13),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(14),
            ),
          ),
        ),
      ],
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
            'Return Product',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }
}