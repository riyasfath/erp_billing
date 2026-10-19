import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/client_contract_viewmodel.dart';
import 'package:pokakbilling/viewmodels/quotation/quotation_viewmodel.dart';
import 'package:provider/provider.dart';

class ViewContractDetails extends StatefulWidget {
  const ViewContractDetails({super.key});

  @override
  State<ViewContractDetails> createState() => _ViewContractDetailsState();
}

class _ViewContractDetailsState extends State<ViewContractDetails> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final quotation = Provider.of<QuotationViewmodel>(context, listen: false)
          .singleQuotation;

      final contractProvider =
          Provider.of<ContractViewmodel>(context, listen: false);

      contractProvider.currentContract = null;

      if (quotation?.contractId != null && quotation!.contractId! > 0) {
        await contractProvider.getContractById(quotation.contractId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContractViewmodel>(
      builder: (context, contractProvider, child) {
        // ── Loading ────────────────────────────────────────────────
        if (contractProvider.detailsLoading) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.c1,
                strokeWidth: 2.5,
              ),
            ),
          );
        }

        final contract = contractProvider.currentContract;

        // ── No Contract ────────────────────────────────────────────
        if (contract == null) {
          return _emptyState();
        }

        final sections = contract.sections;

        // ── Contract Name Row ──────────────────────────────────────
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contract name — styled like an info row
              _contractNameRow(contract.name),

              if (sections.isNotEmpty) ...[
                const SizedBox(height: 10),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.c1.withOpacity(0.08),
                ),
                const SizedBox(height: 10),
              ],

              // ── Sections ─────────────────────────────────────────
              ...sections.asMap().entries.map((entry) {
                final isLast = entry.key == sections.length - 1;
                final section = entry.value;
                return _buildSection(section, isLast: isLast);
              }),
            ],
          ),
        );
      },
    );
  }

  // ── Contract name row — matches _InfoRow style in ViewQuotation ──
  Widget _contractNameRow(String name) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.c1.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.handshake_outlined,
            size: 14,
            color: AppColors.c1.withOpacity(0.65),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contract Name',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.ctext.withOpacity(0.55),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.cdark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Single section ─────────────────────────────────────────────
  Widget _buildSection(dynamic section, {required bool isLast}) {
    final points = section.points as List;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title — matches label style
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.c1.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.article_outlined,
                  size: 14,
                  color: AppColors.c1.withOpacity(0.65),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  section.title,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.ctext.withOpacity(0.55),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),

          // Points listed below, indented to align with text column
          if (points.isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 42), // 30 icon + 12 gap
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: points.map<Widget>((point) {
                  final raw = point.content as String;
                  final text = raw.isNotEmpty
                      ? raw[0].toUpperCase() + raw.substring(1).toLowerCase()
                      : '';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: AppColors.c1.withOpacity(0.55),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            text,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.cdark,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
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
        ],
      ),
    );
  }

  // ── Empty state — consistent with "No products added" style ─────
  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(
            Icons.description_outlined,
            color: AppColors.c1.withOpacity(0.35),
            size: 24,
          ),
          const SizedBox(height: 6),
          Text(
            'No contract available',
            style: TextStyle(
              color: AppColors.ctext.withOpacity(0.55),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
