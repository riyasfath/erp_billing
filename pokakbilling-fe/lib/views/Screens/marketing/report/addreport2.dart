import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/models/data-models/marketing_model/source.dart'
    as src_model;
import 'package:pokakbilling/models/data-models/marketing_model/location.dart'
    as loc_model;
import 'package:pokakbilling/models/data-models/marketing_model/category.dart'
    as cat_model;
import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/categoryList_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/location_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/marketing_report_viewmodel.dart';

// ── Shared design tokens ──────────────────────────────────────────────────────
const _kIndigo = Color(0xFF6366F1);
const _kIndigoDark = Color(0xFF4338CA);
const _kIndigoLight = Color(0xFF818CF8);
const _kBg = Color(0xFFF5F4FF);
const _kCardBg = Colors.white;
const _kInk = Color(0xFF1E1B4B);
const _kSub = Color(0xFF6B7280);
const _kBorder = Color(0xFFE5E7EB);
const _kSoftLilac = Color(0xFFF0EEFF);
const _kGreen = Color(0xFF10B981);
const _kAmber = Color(0xFFF59E0B);
const _kCyan = Color(0xFF06B6D4);

class AddReportStep2 extends StatefulWidget {
  final int initialSalespersonId;
  final String initialSalespersonName;
  final String initialDate;

  const AddReportStep2({
    super.key,
    required this.initialSalespersonId,
    required this.initialSalespersonName,
    required this.initialDate,
  });

  @override
  State<AddReportStep2> createState() => _AddReportStep2State();
}

class _AddReportStep2State extends State<AddReportStep2> {
  int? selectedSourceId;
  int? selectedLocationId;
  int? selectedCategoryId;

  final TextEditingController callsController = TextEditingController();
  final TextEditingController leadsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    callsController.text = '0';
    leadsController.text = '0';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sVm = context.read<SourceViewmodel>();
      final lVm = context.read<LocationViewmodel>();
      final cVm = context.read<CategoryMarketingViewmodel>();

      if (sVm.sources.isNotEmpty) {
        selectedSourceId ??= sVm.sources.first.id;
      } else {
        sVm.fetchSources();
      }
      if (lVm.locations.isNotEmpty) {
        selectedLocationId ??= lVm.locations.first.id;
      } else {
        lVm.fetchLocations();
      }
      if (cVm.categories.isNotEmpty) {
        selectedCategoryId ??= cVm.categories.first.id;
      } else {
        cVm.fetchCategories();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    callsController.dispose();
    leadsController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildNestedPayloadSingle() {
    return {
      'salesperson_id': widget.initialSalespersonId,
      'date': widget.initialDate,
      'sources': [
        {
          'source_id': selectedSourceId ?? 0,
          'locations': [
            {
              'location_id': selectedLocationId ?? 0,
              'categories': [
                {
                  'category_id': selectedCategoryId ?? 0,
                  'calls': int.tryParse(callsController.text) ?? 0,
                  'leads': int.tryParse(leadsController.text) ?? 0,
                }
              ]
            }
          ]
        }
      ]
    };
  }

  List<cat_model.CategoryMarketing> _filteredCategories(
      List<cat_model.CategoryMarketing> all) {
    if (selectedSourceId == null) return all;
    return all.where((c) => c.source == selectedSourceId).toList();
  }

  @override
  Widget build(BuildContext context) {
    final sourceVm = context.watch<SourceViewmodel>();
    final locationVm = context.watch<LocationViewmodel>();
    final categoryVm = context.watch<CategoryMarketingViewmodel>();
    final reportVm = context.watch<MarketingReportViewmodel>();

    if (selectedSourceId == null && sourceVm.sources.isNotEmpty) {
      selectedSourceId = sourceVm.sources.first.id;
    }
    if (selectedLocationId == null && locationVm.locations.isNotEmpty) {
      selectedLocationId = locationVm.locations.first.id;
    }
    if (selectedCategoryId == null && categoryVm.categories.isNotEmpty) {
      final filtered = _filteredCategories(categoryVm.categories);
      selectedCategoryId = filtered.isNotEmpty
          ? filtered.first.id
          : categoryVm.categories.first.id;
    }

    void onSourceChanged(int? sourceId) {
      setState(() {
        selectedSourceId = sourceId;
        final filtered = _filteredCategories(categoryVm.categories);
        if (selectedCategoryId == null ||
            filtered.every((c) => c.id != selectedCategoryId)) {
          selectedCategoryId = filtered.isNotEmpty ? filtered.first.id : null;
        }
      });
    }

    return Scaffold(
      backgroundColor: _kBg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: _kIndigo,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'New Report',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Step 2 of 2',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Step indicator
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.check, size: 12, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(width: 16, height: 2, color: Colors.white60),
                    const SizedBox(width: 4),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('2',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: _kIndigo)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // ── Summary pill ─────────────────────────────────────────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _kSoftLilac,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kIndigo.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _kIndigo.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_outline,
                          size: 16, color: _kIndigo),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.initialSalespersonName.isNotEmpty
                                ? widget.initialSalespersonName
                                : 'Salesperson',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _kInk,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.initialDate,
                            style: const TextStyle(fontSize: 11, color: _kSub),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _kGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Step 1 ✓',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _kGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Source card ───────────────────────────────────────────
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(Icons.share_outlined, 'SOURCE', _kIndigo),
                    const SizedBox(height: 12),
                    _styledDropdown(
                      value: selectedSourceId,
                      hint: 'Select Source',
                      icon: Icons.share_outlined,
                      accentColor: _kIndigo,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: selectedSourceId,
                          isExpanded: true,
                          hint: const Text('Select Source',
                              style: TextStyle(fontSize: 14, color: _kSub)),
                          icon: const Icon(Icons.keyboard_arrow_down,
                              size: 18, color: _kSub),
                          dropdownColor: _kCardBg,
                          style: const TextStyle(
                              fontSize: 14,
                              color: _kInk,
                              fontWeight: FontWeight.w500),
                          items: sourceVm.sources
                              .map((src_model.Source s) => DropdownMenuItem(
                                    value: s.id,
                                    child: Text(s.name,
                                        overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: onSourceChanged,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Location card ─────────────────────────────────────────
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(
                        Icons.location_on_outlined, 'LOCATION', _kCyan),
                    const SizedBox(height: 12),
                    _styledDropdown(
                      value: selectedLocationId,
                      hint: 'Select Location',
                      icon: Icons.location_on_outlined,
                      accentColor: _kCyan,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: selectedLocationId,
                          isExpanded: true,
                          hint: const Text('Select Location',
                              style: TextStyle(fontSize: 14, color: _kSub)),
                          icon: const Icon(Icons.keyboard_arrow_down,
                              size: 18, color: _kSub),
                          dropdownColor: _kCardBg,
                          style: const TextStyle(
                              fontSize: 14,
                              color: _kInk,
                              fontWeight: FontWeight.w500),
                          items: locationVm.locations
                              .map((loc_model.Location l) => DropdownMenuItem(
                                    value: l.id,
                                    child: Text(l.name,
                                        overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => selectedLocationId = v),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Category + calls/leads card ───────────────────────────
              _buildCard(
                accentColor: _kAmber,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(Icons.local_offer_outlined,
                        'CATEGORY & METRICS', _kAmber),
                    const SizedBox(height: 12),
                    _styledDropdown(
                      value: selectedCategoryId,
                      hint: 'Select Category',
                      icon: Icons.local_offer_outlined,
                      accentColor: _kAmber,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: selectedCategoryId,
                          isExpanded: true,
                          hint: const Text('Select Category',
                              style: TextStyle(fontSize: 14, color: _kSub)),
                          icon: const Icon(Icons.keyboard_arrow_down,
                              size: 18, color: _kSub),
                          dropdownColor: _kCardBg,
                          style: const TextStyle(
                              fontSize: 14,
                              color: _kInk,
                              fontWeight: FontWeight.w500),
                          items: _filteredCategories(categoryVm.categories)
                              .map((cat_model.CategoryMarketing c) =>
                                  DropdownMenuItem(
                                    value: c.id,
                                    child: Text(c.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => selectedCategoryId = v),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Calls + Leads row
                    Row(
                      children: [
                        Expanded(
                          child: _metricField(
                            controller: callsController,
                            label: 'Calls Made',
                            icon: Icons.phone_outlined,
                            color: _kGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _metricField(
                            controller: leadsController,
                            label: 'Leads',
                            icon: Icons.trending_up_outlined,
                            color: _kIndigo,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),

      // ── Bottom action bar ─────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        decoration: BoxDecoration(
          color: _kCardBg,
          border: Border(
              top: BorderSide(color: _kIndigo.withValues(alpha: 0.1), width: 1)),
          boxShadow: [
            BoxShadow(
              color: _kIndigo.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                // Refresh
                SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<SourceViewmodel>().fetchSources();
                      context.read<LocationViewmodel>().fetchLocations();
                      context
                          .read<CategoryMarketingViewmodel>()
                          .fetchCategories();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Data refreshed'),
                          backgroundColor: _kIndigo,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh_rounded,
                        size: 16, color: _kSub),
                    label: const Text(
                      'Refresh',
                      style: TextStyle(
                          color: _kSub,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _kBorder),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Save
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: reportVm.addReportLoading
                          ? null
                          : () async {
                              final nested = _buildNestedPayloadSingle();
                              await context
                                  .read<MarketingReportViewmodel>()
                                  .createReport(
                                    date: widget.initialDate,
                                    salespersonId: widget.initialSalespersonId,
                                    sourceId: 0,
                                    locationId: 0,
                                    categoryId: 0,
                                    calls: 0,
                                    leads: 0,
                                    context: context,
                                    extraData: nested,
                                  );
                            },
                      icon: reportVm.addReportLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.save_outlined,
                              color: Colors.white, size: 18),
                      label: Text(
                        reportVm.addReportLoading
                            ? 'Saving...'
                            : 'Create Report',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kGreen,
                        disabledBackgroundColor: _kGreen.withValues(alpha: 0.5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child, Color? accentColor}) {
    final color = accentColor ?? _kIndigo;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.12), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader(IconData icon, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _kSub,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _styledDropdown({
    required int? value,
    required String hint,
    required IconData icon,
    required Color accentColor,
    required Widget child,
  }) {
    return Container(
      height: 46,
      padding: const EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(
        color: _kBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 13, color: accentColor),
          ),
          const SizedBox(width: 8),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _metricField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 11, color: color),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: _kSub),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Center(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
