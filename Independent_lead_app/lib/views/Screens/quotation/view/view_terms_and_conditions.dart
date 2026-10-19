import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/quotation/quotation_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/terms&condition_viewmodel.dart';
import 'package:provider/provider.dart';

class ViewTermsAndConditions extends StatefulWidget {
  const ViewTermsAndConditions({super.key});

  @override
  State<ViewTermsAndConditions> createState() => _ViewTermsAndConditionsState();
}

class _ViewTermsAndConditionsState extends State<ViewTermsAndConditions> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final quotation = Provider.of<QuotationViewmodel>(context, listen: false)
          .singleQuotation;

      final termsProvider = Provider.of<TermsViewModel>(context, listen: false);

      await termsProvider.loadTermsForQuotation(quotation?.termsTemplateId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TermsViewModel>(
      builder: (context, termsProvider, child) {
        // ── LOADING ─────────────────────────────
        if (termsProvider.isDetailsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final termsTitle = termsProvider.selectedTermsTitle;
        final termsList = termsProvider.selectedTermsPoints;

        // ── EMPTY STATE ─────────────────────────
        if (termsList.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cborder),
              boxShadow: [
                BoxShadow(
                  color: AppColors.c1.withOpacity(0.07),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              "No Terms & Conditions Available",
              style: TextStyle(
                color: AppColors.ctext,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        // ── MAIN CARD ───────────────────────────
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cborder),
            boxShadow: [
              BoxShadow(
                color: AppColors.c1.withOpacity(0.07),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HEADER ───────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.article,
                        color: AppColors.c1,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "Terms & Conditions",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ctext,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.cborder,
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        termsTitle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cdark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── TERMS LIST ───────────────────
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: termsList.map((term) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bullet dot
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: AppColors.c1,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Text
                          Expanded(
                            child: Text(
                              term,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.ctext,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
