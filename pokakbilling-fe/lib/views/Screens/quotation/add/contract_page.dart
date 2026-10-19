import 'package:flutter/material.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';
import 'package:pokakbilling/viewmodels/product_viewmodel.dart';
import 'package:pokakbilling/viewmodels/quotation/quotation_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/contract_viewmodel.dart';
import 'package:provider/provider.dart';

// ── Section accent for this screen (matches the Contract section in View) ──
const Color _kAccent = ErpColors.orange;

class ContractPage extends StatefulWidget {
  final String quotationNumber;
  final String quotationDate;
  final int clientId;
  final int termsId;
  final String deliveryAddress;
  final String deliveryLocation;
  final String projectName;

  const ContractPage({
    super.key,
    required this.quotationNumber,
    required this.quotationDate,
    required this.clientId,
    required this.termsId,
    required this.deliveryAddress,
    required this.deliveryLocation,
    required this.projectName,
  });

  @override
  State<ContractPage> createState() => _ContractPageState();
}

class _ContractPageState extends State<ContractPage>
    with SingleTickerProviderStateMixin {
  late TextEditingController _contractDetailsCtrl;
  late AnimationController _entryCtrl;
  late Animation<double> _fadeA;
  late Animation<Offset> _slideA;

  @override
  void initState() {
    super.initState();
    _contractDetailsCtrl = TextEditingController();

    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _fadeA = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideA = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _contractDetailsCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  // ── Stock validation ──────────────────────────────────────────────────────
  String? _validateItemsBeforeSubmit(
    QuotationViewmodel quotationProvider,
    ProductViewModel productProvider,
  ) {
    for (final item in quotationProvider.itemList) {
      if (item.selectedProduct.isEmpty || item.selectedProduct == '0') {
        return 'Please select a product for all items';
      }
      final qty = int.tryParse(item.quantity) ?? 0;
      if (qty <= 0) return 'Please enter a valid quantity for all items';

      final productId = int.tryParse(item.selectedProduct);
      if (productId != null) {
        final stock = productProvider.getStockForProduct(productId);
        if (qty > stock) {
          String name = 'a product';
          try {
            name = productProvider.productList
                .firstWhere((p) => p.productId == productId)
                .productName;
          } catch (_) {}
          return 'Quantity for "$name" exceeds available stock ($stock)';
        }
      }
    }
    return null;
  }

  // ── Template selected (same logic as the old dropdown onChanged) ──────────
  Future<void> _onTemplateSelected(
    String? newValue,
    ContractViewmodel provider,
    QuotationViewmodel quotationProvider,
  ) async {
    if (newValue != null) {
      final selectedName = newValue.split(' (')[0];
      final selected = provider.contractHeadingList.firstWhere(
        (c) => c.contractHeading == selectedName,
      );
      quotationProvider.updateContractId(selected.contractId);
      await quotationProvider.getCompleteContractInfo(selected.contractId);
      _contractDetailsCtrl.text = selected.contractHeading.toString();
      setState(() {});
    }
  }

  // ── Counts for the summary bar ────────────────────────────────────────────
  (int, int) _counts(QuotationViewmodel p) {
    int sections = 0, points = 0;
    for (final contract in p.contractInfoList) {
      final list = p.editableSectionsMap[contract.id] ?? [];
      sections += list.length;
      for (final s in list) {
        points += s.points.length;
      }
    }
    return (sections, points);
  }

  // ── Card shell ────────────────────────────────────────────────────────────
  Widget _card({
    required Widget child,
    Color color = _kAccent,
    EdgeInsets padding = const EdgeInsets.fromLTRB(16, 14, 16, 16),
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ErpColors.line),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ErpColors.tint(color, 0.35), color],
              ),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }

  Widget _cardTitle(IconData icon, Color color, String title, String subtitle,
      {Widget? trailing}) {
    return Row(children: [
      ErpGradientTile(icon: icon, color: color, size: 40),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                    color: ErpColors.ink)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: ErpColors.slate)),
          ],
        ),
      ),
      if (trailing != null) trailing,
    ]);
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: ErpColors.pageBg,
      resizeToAvoidBottomInset: true,
      body: Column(children: [
        _buildHeader(sw, topPad),
        Expanded(
          child: FadeTransition(
            opacity: _fadeA,
            child: SlideTransition(
              position: _slideA,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(sw * 0.04, 18, sw * 0.04, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Template picker ─────────────────────────────────
                    ErpFadeIn(index: 0, child: _buildTemplateCard()),

                    // ── Editable contract sections ─────────────────────
                    Consumer<QuotationViewmodel>(
                      builder: (context, provider, child) {
                        if (provider.getCompleteContractInfoLoading) {
                          return const _LoadingSections();
                        }

                        if (provider.contractInfoList.isEmpty) {
                          return const ErpFadeIn(
                              index: 1, child: _EmptyContractState());
                        }

                        int running = 0;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionsHeading(provider),
                            ...List.generate(provider.contractInfoList.length,
                                (contractIndex) {
                              final contract =
                                  provider.contractInfoList[contractIndex];
                              final sectionModels =
                                  provider.editableSectionsMap[contract.id] ??
                                      [];

                              return Column(
                                children:
                                    sectionModels.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final sectionModel = entry.value;
                                  final color = ErpColors.rotation[
                                      (running++) % ErpColors.rotation.length];
                                  return ErpFadeIn(
                                    index: idx + 1,
                                    child: _buildSectionCard(
                                        idx, sectionModel, color),
                                  );
                                }).toList(),
                              );
                            }),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),

      // ── Save bar ──────────────────────────────────────────────────────────
      bottomNavigationBar: _buildSaveBar(),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(double sw, double topPad) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: ErpColors.headerGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: ErpColors.cyan.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(children: [
        Positioned(
          right: -30,
          top: -44,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: -26,
          bottom: -34,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: 12,
          bottom: 40,
          child: Transform.rotate(
            angle: -0.25,
            child: Icon(Icons.gavel_rounded,
                size: 92, color: Colors.white.withValues(alpha: 0.12)),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: topPad + 12,
            bottom: 20,
            left: sw * 0.045,
            right: sw * 0.045,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                ErpPressable(
                  onTap: () => Navigator.pop(context),
                  child: const ErpGlassCircle(
                      icon: Icons.arrow_back_ios_new_rounded, iconSize: 19),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contract',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Review & edit contract sections',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 18),

              // Stepper
              const _Stepper(),
              const SizedBox(height: 14),

              // Quotation summary card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: ErpColors.cyanDeep.withValues(alpha: 0.22),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: ErpColors.headerGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.request_quote_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.projectName.isNotEmpty
                              ? widget.projectName
                              : 'Quotation',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: ErpColors.ink,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(spacing: 6, runSpacing: 6, children: [
                          ErpMetaChip(
                            icon: Icons.tag_rounded,
                            text: widget.quotationNumber,
                            color: ErpColors.cyanDeep,
                          ),
                          ErpMetaChip(
                            icon: Icons.calendar_today_rounded,
                            text: widget.quotationDate,
                            color: ErpColors.violet,
                          ),
                          if (widget.deliveryLocation.isNotEmpty)
                            ErpMetaChip(
                              icon: Icons.place_rounded,
                              text: widget.deliveryLocation,
                              color: ErpColors.orange,
                            ),
                        ]),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  // ── Template card ─────────────────────────────────────────────────────────
  Widget _buildTemplateCard() {
    return Consumer2<ContractViewmodel, QuotationViewmodel>(
      builder: (context, provider, quotationProvider, child) {
        final headings = provider.contractHeadingList
            .map((c) => c.contractHeading)
            .toSet()
            .toList();
        final selectedValue = headings.contains(_contractDetailsCtrl.text)
            ? _contractDetailsCtrl.text
            : null;
        final hasSelection = selectedValue != null;

        return _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardTitle(
                Icons.description_rounded,
                _kAccent,
                'Contract Template',
                '${headings.length} template${headings.length == 1 ? '' : 's'} available',
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1, thickness: 1, color: ErpColors.line),
              ),
              const ErpFieldLabel('Select Template', isRequired: true),
              ErpPressable(
                onTap: () async {
                  final picked = await showModalBottomSheet<String>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => _TemplateSheet(
                      headings: headings,
                      selected: selectedValue,
                    ),
                  );
                  if (picked != null && picked != selectedValue) {
                    await _onTemplateSelected(
                        picked, provider, quotationProvider);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: hasSelection
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              ErpColors.tint(_kAccent, 0.15),
                              _kAccent,
                            ],
                          )
                        : null,
                    color: hasSelection ? null : ErpColors.pageBg,
                    borderRadius: BorderRadius.circular(16),
                    border: hasSelection
                        ? null
                        : Border.all(color: ErpColors.line, width: 1.2),
                    boxShadow: hasSelection
                        ? [
                            BoxShadow(
                              color: _kAccent.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: hasSelection
                            ? Colors.white.withValues(alpha: 0.22)
                            : _kAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: hasSelection
                            ? Border.all(
                                color: Colors.white.withValues(alpha: 0.4))
                            : null,
                      ),
                      child: Icon(
                        hasSelection
                            ? Icons.check_rounded
                            : Icons.library_books_rounded,
                        size: 20,
                        color: hasSelection
                            ? Colors.white
                            : ErpColors.shade(_kAccent, 0.1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasSelection ? 'Selected template' : 'Tap to choose',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: hasSelection
                                  ? Colors.white.withValues(alpha: 0.85)
                                  : ErpColors.slate,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            selectedValue ?? 'Choose a contract template',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              color: hasSelection
                                  ? Colors.white
                                  : ErpColors.ink.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: hasSelection
                            ? Colors.white
                            : _kAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        hasSelection ? 'Change' : 'Browse',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: ErpColors.shade(_kAccent, 0.1),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
              if (provider.contractHeadingList.isEmpty) ...[
                const SizedBox(height: 10),
                const Row(children: [
                  Icon(Icons.info_outline_rounded,
                      size: 14, color: ErpColors.slate),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'No contract templates found.',
                      style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: ErpColors.slate),
                    ),
                  ),
                ]),
              ],
            ],
          ),
        );
      },
    );
  }

  // ── "Sections" heading row ────────────────────────────────────────────────
  Widget _sectionsHeading(QuotationViewmodel provider) {
    final (sections, points) = _counts(provider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
      child: Row(children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [ErpColors.cyan, ErpColors.orange],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'CONTRACT SECTIONS',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
              color: ErpColors.ink,
            ),
          ),
        ),
        ErpStatusChip(label: '$sections sections', color: ErpColors.cyanDeep),
        const SizedBox(width: 6),
        ErpStatusChip(label: '$points points', color: _kAccent),
      ]),
    );
  }

  // ── One editable section ──────────────────────────────────────────────────
  Widget _buildSectionCard(int idx, dynamic sectionModel, Color color) {
    final List points = sectionModel.points;
    return _card(
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [ErpColors.tint(color, 0.2), color],
                ),
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.32),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${idx + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
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
                    'Section ${idx + 1}',
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                      color: ErpColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Edit the title and points below',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: ErpColors.slate,
                    ),
                  ),
                ],
              ),
            ),
            ErpStatusChip(
              label: '${points.length} item${points.length == 1 ? '' : 's'}',
              color: color,
            ),
          ]),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, thickness: 1, color: ErpColors.line),
          ),

          // Title
          const ErpFieldLabel('Section Title'),
          TextFormField(
            controller: sectionModel.titleController,
            cursorColor: color,
            style: const TextStyle(
              color: ErpColors.ink,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
            decoration: erpInputDecoration(
              hint: 'Enter section title',
              icon: Icons.title_rounded,
              color: color,
            ),
          ),
          const SizedBox(height: 16),

          // Points heading
          Row(children: [
            Icon(Icons.format_list_bulleted_rounded,
                size: 16, color: ErpColors.shade(color, 0.1)),
            const SizedBox(width: 6),
            const Text(
              'Points',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: ErpColors.ink,
              ),
            ),
          ]),
          const SizedBox(height: 10),

          // Points as a timeline
          ...points.asMap().entries.map((pe) {
            final pi = pe.key;
            final editablePoint = pe.value;
            final isLast = pi == points.length - 1;
            return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Point number
                  Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.20),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${pi + 1}',
                        style: TextStyle(
                          color: ErpColors.shade(color, 0.15),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                      child: TextFormField(
                        controller: editablePoint.controller,
                        cursorColor: color,
                        maxLines: null,
                        style: const TextStyle(
                          color: ErpColors.ink,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter point…',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: ErpColors.slate.withValues(alpha: 0.7),
                          ),
                          filled: true,
                          fillColor: color.withValues(alpha: 0.05),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                                color: color.withValues(alpha: 0.18)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                                color: color.withValues(alpha: 0.18)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: color, width: 1.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
            );
          }),
          if (points.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  'No points in this section',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: ErpColors.slate,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Save bar ──────────────────────────────────────────────────────────────
  Widget _buildSaveBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: ErpColors.cyanDeep.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 14,
      ),
      child: Consumer2<QuotationViewmodel, ProductViewModel>(
        builder: (context, quotationProvider, productProvider, child) {
          final isLoading = quotationProvider.addQuotationLoader;
          final (sections, points) = _counts(quotationProvider);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                _miniStat(Icons.inventory_2_rounded,
                    '${quotationProvider.itemList.length}', 'Products',
                    ErpColors.blue),
                const SizedBox(width: 8),
                _miniStat(Icons.view_agenda_rounded, '$sections', 'Sections',
                    ErpColors.violet),
                const SizedBox(width: 8),
                _miniStat(Icons.currency_rupee_rounded,
                    '${quotationProvider.grandTotal}', 'Total',
                    ErpColors.green),
              ]),
              const SizedBox(height: 12),
              ErpPrimaryButton(
                text: isLoading ? 'Saving…' : 'Save Quotation',
                icon: Icons.save_rounded,
                loading: isLoading,
                onTap: () {
                  final error = _validateItemsBeforeSubmit(
                      quotationProvider, productProvider);
                  if (error != null) {
                    erpToast(
                      context,
                      error,
                      color: ErpColors.red,
                      icon: Icons.error_outline_rounded,
                    );
                    return;
                  }

                  quotationProvider.createQuotation(
                    widget.quotationNumber,
                    widget.quotationDate,
                    widget.clientId,
                    widget.termsId,
                    widget.deliveryAddress,
                    widget.deliveryLocation,
                    widget.projectName,
                    context,
                    productViewModel: productProvider,
                  );
                },
              ),
              if (points > 0) ...[
                const SizedBox(height: 6),
                Text(
                  '$points contract point${points == 1 ? '' : 's'} will be saved',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: ErpColors.slate,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _miniStat(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: ErpColors.shade(color, 0.12)),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: ErpColors.shade(color, 0.2),
                    ),
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: ErpColors.slate,
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Stepper (Step 1 done, Step 2 active)
// ═════════════════════════════════════════════════════════════════════════════
class _Stepper extends StatelessWidget {
  const _Stepper();

  @override
  Widget build(BuildContext context) {
    Widget dot({required bool done, required String n, required String label}) {
      return Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: done ? Colors.white.withValues(alpha: 0.25) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                : Text(n,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: ErpColors.cyanDeep)),
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white.withValues(alpha: done ? 0.85 : 1))),
      ]);
    }

    return Row(children: [
      dot(done: true, n: '1', label: 'Details'),
      Expanded(
        child: Container(
          height: 3,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
      dot(done: false, n: '2', label: 'Contract'),
    ]);
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Loading placeholder (pulsing skeleton cards)
// ═════════════════════════════════════════════════════════════════════════════
class _LoadingSections extends StatefulWidget {
  const _LoadingSections();

  @override
  State<_LoadingSections> createState() => _LoadingSectionsState();
}

class _LoadingSectionsState extends State<_LoadingSections>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _bar(double w, double h) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: ErpColors.line,
          borderRadius: BorderRadius.circular(8),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Opacity(
        opacity: 0.45 + 0.55 * _c.value,
        child: Column(
          children: List.generate(2, (i) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: ErpColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: ErpColors.line,
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _bar(120, 12),
                        const SizedBox(height: 6),
                        _bar(80, 9),
                      ],
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _bar(double.infinity, 44),
                  const SizedBox(height: 10),
                  _bar(double.infinity, 38),
                  const SizedBox(height: 8),
                  _bar(double.infinity, 38),
                  if (i == 0) ...[
                    const SizedBox(height: 14),
                    const Center(
                      child: Text(
                        'Loading contract sections…',
                        style: TextStyle(
                          color: _kAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Empty state
// ═════════════════════════════════════════════════════════════════════════════
class _EmptyContractState extends StatelessWidget {
  const _EmptyContractState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ErpColors.line),
      ),
      child: Column(children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: _kAccent.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: _kAccent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
            const ErpGradientTile(
              icon: Icons.description_rounded,
              color: _kAccent,
              size: 46,
              circle: true,
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'No contract selected',
          style: TextStyle(
            color: ErpColors.ink,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Choose a contract template above\nto load and edit its sections.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: ErpColors.slate,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        ),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Template picker sheet — returns the chosen heading string
// ═════════════════════════════════════════════════════════════════════════════
class _TemplateSheet extends StatefulWidget {
  final List<String> headings;
  final String? selected;
  const _TemplateSheet({required this.headings, this.selected});

  @override
  State<_TemplateSheet> createState() => _TemplateSheetState();
}

class _TemplateSheetState extends State<_TemplateSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final list = widget.headings
        .where((h) =>
            _query.trim().isEmpty ||
            h.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom +
              MediaQuery.of(context).padding.bottom +
              12,
        ),
        child: Column(children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: ErpColors.line,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            const ErpGradientTile(
                icon: Icons.library_books_rounded, color: _kAccent, size: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contract Templates',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: ErpColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.headings.length} available',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ErpColors.slate,
                    ),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 14),
          TextField(
            cursorColor: _kAccent,
            style: const TextStyle(
                color: ErpColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w600),
            decoration: erpInputDecoration(
              hint: 'Search templates…',
              icon: Icons.search_rounded,
              color: _kAccent,
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 30, color: _kAccent.withValues(alpha: 0.5)),
                        const SizedBox(height: 8),
                        const Text(
                          'No matching templates',
                          style: TextStyle(
                            color: ErpColors.slate,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final h = list[i];
                      final isSel = h == widget.selected;
                      final c = ErpColors
                          .rotation[i % ErpColors.rotation.length];
                      return ErpFadeIn(
                        index: i,
                        child: ErpPressable(
                          onTap: () => Navigator.pop(context, h),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? _kAccent.withValues(alpha: 0.08)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSel
                                    ? _kAccent.withValues(alpha: 0.6)
                                    : ErpColors.line,
                                width: isSel ? 1.5 : 1,
                              ),
                            ),
                            child: Row(children: [
                              ErpGradientTile(
                                icon: isSel
                                    ? Icons.check_rounded
                                    : Icons.description_rounded,
                                color: isSel ? _kAccent : c,
                                size: 36,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  h,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSel
                                        ? FontWeight.w900
                                        : FontWeight.w700,
                                    color: ErpColors.ink,
                                  ),
                                ),
                              ),
                              Icon(
                                isSel
                                    ? Icons.check_circle_rounded
                                    : Icons.chevron_right_rounded,
                                color: isSel ? _kAccent : ErpColors.slate,
                                size: 22,
                              ),
                            ]),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}