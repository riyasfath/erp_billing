import 'package:flutter/material.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/viewmodels/customer_viewmodel.dart';
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

    final isLead = user.moduleType == 'lead';
    final typeColor = isLead ? ErpColors.violet : ErpColors.green;
    final fullName = "${user.firstName} ${user.lastName}".trim();
    final avatarColor =
        ErpColors.rotation[fullName.hashCode.abs() % ErpColors.rotation.length];
    final contact = user.mobile.isNotEmpty ? user.mobile : user.phone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Top accent ──────────────────────────────────────────────────────
        Container(
          height: 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [ErpColors.tint(typeColor, 0.3), typeColor]),
          ),
        ),

        // ── Avatar + name / company / contact ───────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [ErpColors.tint(avatarColor, 0.22), avatarColor],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: avatarColor.withValues(alpha: 0.32),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _initials(user.firstName, user.lastName),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: ErpColors.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (user.companyName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(children: [
                        const Icon(Icons.business_rounded,
                            size: 12, color: ErpColors.cyanDeep),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            user.companyName,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: ErpColors.slate,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
                    ],
                    const SizedBox(height: 6),
                    Wrap(spacing: 6, runSpacing: 6, children: [
                      if (contact.isNotEmpty)
                        ErpMetaChip(
                          icon: Icons.phone_rounded,
                          text: contact,
                          color: ErpColors.cyanDeep,
                        ),
                      if (user.email.isNotEmpty)
                        ErpMetaChip(
                          icon: Icons.email_rounded,
                          text: user.email,
                          color: ErpColors.violet,
                        ),
                    ]),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              ErpStatusChip(
                label: isLead ? 'Lead' : 'Client',
                color: typeColor,
              ),
            ],
          ),
        ),

        // ── Divider ─────────────────────────────────────────────────────────
        const Divider(height: 1, thickness: 1, color: ErpColors.line),

        // ── Action buttons ──────────────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 10, 24, 12),
          child: Row(
            children: [
              // VIEW
              _ActionBtn(
                label: 'View',
                icon: Icons.visibility_rounded,
                color: ErpColors.cyan,
                filled: true,
                onTap: () => pushNavigation(context, ViewCustomer(user: user)),
              ),
              const SizedBox(width: 8),
              // EDIT
              _ActionBtn(
                label: 'Edit',
                icon: Icons.edit_rounded,
                color: ErpColors.violet,
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
                  icon: Icons.delete_rounded,
                  color: ErpColors.red,
                  filled: false,
                  onTap: () => showDeleteDialog(
                    context,
                    "Customer",
                    () => provider.deleteCustomer(user.customerId, context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _initials(String first, String last) {
    final f = first.isNotEmpty ? first[0].toUpperCase() : '';
    final l = last.isNotEmpty ? last[0].toUpperCase() : '';
    final s = '$f$l';
    return s.isEmpty ? '?' : s;
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
    return ErpPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          gradient: filled
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [ErpColors.tint(color, 0.2), color],
                )
              : null,
          color: filled ? null : color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
          border:
              filled ? null : Border.all(color: color.withValues(alpha: 0.28)),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.32),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : const [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: filled ? Colors.white : color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: filled ? Colors.white : ErpColors.shade(color, 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}