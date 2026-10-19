import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/customer_viewmodel.dart';
import 'package:pokakbilling/views/Screens/customer/contract/view_contract.dart';
import 'package:pokakbilling/views/Screens/customer/create_new_customer.dart';
import 'package:pokakbilling/views/Screens/customer/view_customer.dart';
import 'package:pokakbilling/views/commonWidgets/popups/delete_popup.dart';
import 'package:provider/provider.dart';

class SingleCustomerCard extends StatelessWidget {
  final int index;
  const SingleCustomerCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final customerProvider = Provider.of<CustomerViewmodel>(context);
    final user = customerProvider.customerList[index];

    final hasContract = user.contractId != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: avatar + name/company/email ──────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar circle with initials
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.cxl,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.cborder,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _initials(user.firstName, user.lastName),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.c1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name / company / email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${user.firstName} ${user.lastName}"
                            .trim()
                            .toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cdark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (user.companyName.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          user.companyName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.ctext,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.email_outlined,
                            size: 11,
                            color: AppColors.ctext,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              user.email,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.ctext,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Contract badge
                if (hasContract)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.green.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: AppColors.green.withOpacity(0.30)),
                    ),
                    child: const Text(
                      'Contract',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.green,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Divider ───────────────────────────────────────────────────────
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.cborder,
          ),

          // ── Action buttons — scrollable, last button always fully visible ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            // padding right=24 gives room so the last button scrolls fully in
            padding: const EdgeInsets.fromLTRB(12, 10, 24, 12),
            child: Row(
              children: [
                // VIEW
                _ActionBtn(
                  label: 'View',
                  icon: Icons.visibility_outlined,
                  color: AppColors.c1,
                  filled: true,
                  onTap: () =>
                      pushNavigation(context, ViewCustomer(user: user)),
                ),
                const SizedBox(width: 8),
                // EDIT
                _ActionBtn(
                  label: 'Edit',
                  icon: Icons.edit_outlined,
                  color: AppColors.c3,
                  filled: false,
                  onTap: () => pushNavigation(
                    context,
                    CreateNewCustomer(isEdit: true, customer: user),
                  ),
                ),
                const SizedBox(width: 8),
                // DELETE
                Consumer<CustomerViewmodel>(
                  builder: (context, provider, _) => _ActionBtn(
                    label: 'Delete',
                    icon: Icons.delete_outline_rounded,
                    color: AppColors.tagRed,
                    filled: false,
                    onTap: () => showDeleteDialog(
                      context,
                      "Client",
                      () => provider.deleteCustomer(user.customerId, context),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // CONTRACT
                _ActionBtn(
                  label: hasContract ? 'View Contract' : 'Add Contract',
                  icon: hasContract
                      ? Icons.description_outlined
                      : Icons.note_add_outlined,
                  color: hasContract ? AppColors.green : AppColors.c1,
                  filled: false,
                  onTap: () {
                    if (hasContract) {
                      pushNavigation(
                        context,
                        ViewContractDetailsScreen(
                          contractId: user.contractId!,
                          customerId: user.customerId,
                        ),
                      );
                    } else {
                      pushNavigation(
                        context,
                        CreateNewCustomer(isEdit: true, customer: user),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String first, String last) {
    final f = first.isNotEmpty ? first[0].toUpperCase() : '';
    final l = last.isNotEmpty ? last[0].toUpperCase() : '';
    return '$f$l';
  }
}

// ─── Pill action button ───────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: filled ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: filled ? null : Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: filled ? Colors.white : color,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: filled ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
