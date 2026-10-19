import 'package:flutter/material.dart';
import 'package:ecommerce_app/app_colors.dart';

/// What showCancelOrderSheet() returns — both fields the real
/// /cancel/ endpoint needs.
class CancelOrderResult {
  final String reason; // one of the codes below
  final String details;
  const CancelOrderResult({required this.reason, required this.details});
}

class _CancelReason {
  final String code;
  final String label;
  const _CancelReason(this.code, this.label);
}

// Matches the order API's
// `_reason_options: "changed_mind, delayed, mistake, found_cheaper, other"`.
const List<_CancelReason> _cancelReasons = [
  _CancelReason('changed_mind', 'Changed my mind'),
  _CancelReason('delayed', 'Delivery is taking too long'),
  _CancelReason('mistake', 'Ordered by mistake'),
  _CancelReason('found_cheaper', 'Found it cheaper elsewhere'),
  _CancelReason('other', 'Other'),
];

/// Shows a bottom sheet to pick a cancellation reason (+ optional
/// details). Returns null if dismissed without confirming.
Future<CancelOrderResult?> showCancelOrderSheet(BuildContext context) {
  return showModalBottomSheet<CancelOrderResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _CancelOrderSheet(),
  );
}

class _CancelOrderSheet extends StatefulWidget {
  const _CancelOrderSheet();

  @override
  State<_CancelOrderSheet> createState() => _CancelOrderSheetState();
}

class _CancelOrderSheetState extends State<_CancelOrderSheet> {
  String? _selectedReason;
  final TextEditingController _detailsController = TextEditingController();

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_selectedReason == null) return;
    Navigator.pop(
      context,
      CancelOrderResult(reason: _selectedReason!, details: _detailsController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Was a plain min-size Column with no scrolling — fine in
    // portrait, but in landscape the available height shrinks a lot
    // and the fixed "Cancel Order" button got pushed off the bottom
    // of the screen. Now the sheet caps its own height, the reasons
    // list scrolls inside that cap, and the action buttons stay
    // pinned below the scroll area so they're always visible.
    final double maxSheetHeight = MediaQuery.of(context).size.height * 0.9;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        child: Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(color: AppColors.borderGrey, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      const Text(
                        'Cancel Order',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tell us why so we can improve',
                        style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                      ),
                      const SizedBox(height: 14),
                      ..._cancelReasons.map((r) => RadioListTile<String>(
                            value: r.code,
                            groupValue: _selectedReason,
                            onChanged: (v) => setState(() => _selectedReason = v),
                            activeColor: AppColors.primaryBlue,
                            contentPadding: EdgeInsets.zero,
                            title: Text(r.label, style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
                          )),
                      const SizedBox(height: 10),
                      const Text(
                        'Additional details (optional)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderGrey),
                        ),
                        child: TextField(
                          controller: _detailsController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Anything else we should know?',
                            hintStyle: TextStyle(color: AppColors.hintGrey, fontSize: 13),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
              // Fixed action bar — stays visible below the scrollable
              // content no matter how little vertical space landscape
              // mode leaves.
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.borderGrey, width: 0.6)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.borderGrey),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: const Text('Keep Order', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _selectedReason == null ? null : _confirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.badgeRed,
                          disabledBackgroundColor: AppColors.borderGrey,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: const Text('Cancel Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}