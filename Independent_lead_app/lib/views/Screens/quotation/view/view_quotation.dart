import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/core/utils/text_utils.dart';
import 'package:pokakbilling/viewmodels/quotation/quotation_viewmodel.dart';
import 'package:pokakbilling/views/Screens/quotation/view/quotation_items.dart';
import 'package:pokakbilling/views/Screens/quotation/view/view_contract_details.dart';
import 'package:pokakbilling/views/Screens/quotation/view/view_terms_and_conditions.dart';
import 'package:provider/provider.dart';

class ViewQuotation extends StatefulWidget {
  const ViewQuotation({super.key});

  @override
  State<ViewQuotation> createState() => _ViewQuotationState();
}

class _ViewQuotationState extends State<ViewQuotation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quotationProvider = Provider.of<QuotationViewmodel>(context);
    final quotation = quotationProvider.singleQuotation;
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;

    if (quotation == null) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.c1,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    final name = (quotation.clientNameDisplay?.isNotEmpty == true)
        ? quotation.clientNameDisplay!
        : quotation.clientName ?? '—';

    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((e) => e[0]).take(2).join()
        : '';

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            _buildHeader(
              context,
              sw,
              topPad,
              quotation.quotationId,
              name,
              initials,
            ),

            // ── Scrollable body ───────────────────────────────────────
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                    child: Column(
                      children: [
                        // Section 1 — Quotation Info
                        _buildSection(
                          icon: Icons.description_outlined,
                          title: 'Quotation Info',
                          rows: [
                            _InfoRow(Icons.person_outline_rounded,
                                'Client Name', name),
                            _InfoRow(Icons.tag_rounded, 'Quotation No',
                                quotation.quotationNumber),
                            _InfoRow(Icons.calendar_today_outlined, 'Date',
                                quotation.date),
                            _InfoRow(Icons.work_outline_rounded, 'Project',
                                quotation.projectName ?? '—'),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Section 2 — Company
                        _buildSection(
                          icon: Icons.business_outlined,
                          title: 'Company',
                          rows: [
                            _InfoRow(Icons.location_on_outlined, 'Location',
                                quotation.companyLocation ?? '—'),
                            _InfoRow(Icons.home_outlined, 'Address',
                                quotation.companyAddress ?? '—'),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Section 3 — Products — Visible light box
                        _buildSectionShell(
                          icon: Icons.inventory_2_outlined,
                          title: 'Products',
                          child: _buildProductsSection(quotation),
                        ),
                        const SizedBox(height: 14),

                        // Section 4 — Amount
                        _buildSection(
                          icon: Icons.calculate_outlined,
                          title: 'Amount',
                          rows: [
                            _InfoRow(
                              Icons.currency_rupee_rounded,
                              'Grand Total',
                              quotation.grandTotal,
                            ),
                          ],
                          highlightLast: true,
                        ),
                        const SizedBox(height: 14),

                        // Section 5 — Terms & Conditions
                        _buildSectionShell(
                          icon: Icons.article_outlined,
                          title: 'Terms & Conditions',
                          child: const ViewTermsAndConditions(),
                        ),
                        const SizedBox(height: 14),

                        // Section 6 — Contract
                        _buildSectionShell(
                          icon: Icons.description_outlined,
                          title: 'Contract',
                          child: const ViewContractDetails(),
                        ),
                        const SizedBox(height: 24),

                        // Go Back button
                        _buildExitButton(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────
  Widget _buildHeader(
    BuildContext context,
    double sw,
    double topPad,
    dynamic id,
    String name,
    String initials,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topPad + 14,
        bottom: 20,
        left: sw * 0.05,
        right: sw * 0.05,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.cborder, width: 1.5),
        ),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.cxl,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cborder),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.c3,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.c1.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.c1.withOpacity(0.20)),
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: AppColors.c1,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.cdark,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                const Text(
                  'Quotation View',
                  style: TextStyle(
                    color: AppColors.ctext,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // ID badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.c1.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.c1.withOpacity(0.25)),
            ),
            child: Text(
              'ID #$id',
              style: TextStyle(
                color: AppColors.c1,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section card with info rows ─────────────────────────────────
  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<_InfoRow> rows,
    bool highlightLast = false,
  }) {
    final visibleRows = rows.where((r) => r.value.isNotEmpty).toList();
    if (visibleRows.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.c1.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // c1 top accent bar
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.c1,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),

          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.c1.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.c1, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                capitalizeWords(title),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cdark,
                ),
              ),
            ]),
          ),

          Divider(
            height: 20,
            thickness: 1,
            indent: 14,
            endIndent: 14,
            color: AppColors.c1.withOpacity(0.10),
          ),

          // Rows
          ...visibleRows.asMap().entries.map((entry) {
            final i = entry.key;
            final row = entry.value;
            final isLast = i == visibleRows.length - 1;
            final highlight = highlightLast && isLast;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: highlight
                        ? BoxDecoration(
                            color: AppColors.c1.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(10),
                          )
                        : null,
                    child: Padding(
                      padding: highlight
                          ? const EdgeInsets.symmetric(horizontal: 10)
                          : EdgeInsets.zero,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: highlight
                                  ? AppColors.c1.withOpacity(0.12)
                                  : AppColors.c1.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              row.icon,
                              size: 14,
                              color: highlight
                                  ? AppColors.c1
                                  : AppColors.c1.withOpacity(0.65),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  row.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.ctext.withOpacity(0.55),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  row.value,
                                  style: TextStyle(
                                    fontSize: highlight ? 15 : 13,
                                    color: highlight
                                        ? AppColors.c1
                                        : AppColors.cdark,
                                    fontWeight: highlight
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 56,
                    endIndent: 14,
                    color: AppColors.c1.withOpacity(0.08),
                  ),
              ],
            );
          }),

          const SizedBox(height: 14),
        ],
      ),
    );
  }

  // ── Section shell with light cyan content area ──────────────────
  Widget _buildSectionShell({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.c1.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // c1 top accent bar
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.c1,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.c1.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: AppColors.c1, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cdark,
                    ),
                  ),
                ]),
                Divider(
                  height: 20,
                  thickness: 1,
                  color: AppColors.c1.withOpacity(0.10),
                ),

                // Light background panel for terms / contract / products
                Container(
                  constraints: const BoxConstraints(minHeight: 40),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.c1.withOpacity(0.12)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection(quotation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (quotation.items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
            child: Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.c1.withOpacity(0.35),
                  size: 24,
                ),
                const SizedBox(height: 6),
                Text(
                  'No products added',
                  style: TextStyle(
                    color: AppColors.ctext.withOpacity(0.55),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: List.generate(
              quotation.items.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  bottom: index < quotation.items.length - 1 ? 10 : 0,
                ),
                child: QuotationItems(index: index),
              ),
            ),
          ),
      ],
    );
  }

  // ── Go Back button ─────────────────────────────────────────────
  Widget _buildExitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.c1,
          foregroundColor: AppColors.white,
          elevation: 0,
          shadowColor: AppColors.c1.withOpacity(0.30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.white,
              size: 14,
            ),
            SizedBox(width: 8),
            Text(
              'Go Back',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Row model ──────────────────────────────────────────────────
class _InfoRow {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);
}
