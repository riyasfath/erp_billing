// lib/views/Screens/marketing/report/addreport2.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
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
    final int sId = selectedSourceId ?? 0;
    final int lId = selectedLocationId ?? 0;
    final int cId = selectedCategoryId ?? 0;
    final int calls = int.tryParse(callsController.text) ?? 0;
    final int leads = int.tryParse(leadsController.text) ?? 0;

    return {
      'salesperson_id': widget.initialSalespersonId,
      'date': widget.initialDate,
      'sources': [
        {
          'source_id': sId,
          'locations': [
            {
              'location_id': lId,
              'categories': [
                {'category_id': cId, 'calls': calls, 'leads': leads}
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
    const Color borderColor = AppColors.softBorder;
    const Color categoryCardBg = Color(0xFFE0E2FE);

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

    InputDecoration dropdownDecoration({
      required String hint,
      required IconData icon,
      double iconSize = 16,
    }) {
      return InputDecoration(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 13,
          color: AppColors.hintTextGrey,
          height: 1.2,
        ),
        prefixIcon: Icon(icon, color: borderColor, size: iconSize),
        filled: true,
        fillColor: AppColors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.violetblue,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.violetblue,
        elevation: 0,
        title: const Text(
          'New Report',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // ---- BODY (no scroll) ----
      body: SafeArea(
        child: Column(
          children: [
            // Card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 20, 14, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sources & Data',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.violetblue,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // SOURCE (40px)
                    SizedBox(
                      height: 40,
                      child: DropdownButtonFormField<int>(
                        isExpanded: true,
                        initialValue: selectedSourceId,
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: borderColor),
                        decoration: dropdownDecoration(
                          hint: 'Select Source',
                          icon: Icons.share_outlined,
                          iconSize: 16,
                        ),
                        items: sourceVm.sources
                            .map((src_model.Source s) => DropdownMenuItem(
                                  value: s.id,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      s.name,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: onSourceChanged,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // LOCATION (40px)
                    const Text('LOCATION',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGrey,
                            fontSize: 14,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: DropdownButtonFormField<int>(
                        isExpanded: true,
                        initialValue: selectedLocationId,
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: borderColor),
                        decoration: dropdownDecoration(
                          hint: 'Select Location',
                          icon: Icons.location_on_outlined,
                        ),
                        items: locationVm.locations
                            .map((loc_model.Location l) => DropdownMenuItem(
                                  value: l.id,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      l.name,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => selectedLocationId = v),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // CATEGORIES
                    const Text('CATEGORIES',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGrey,
                            fontSize: 12,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 8),

                    // Category box #E0E2FE
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: categoryCardBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: categoryCardBg),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // CATEGORY (40px) single-line ellipsis
                          SizedBox(
                            height: 40,
                            child: DropdownButtonFormField<int>(
                              isExpanded: true,
                              initialValue: selectedCategoryId,
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  color: AppColors.hintTextGrey),
                              decoration: dropdownDecoration(
                                hint: 'Select Category',
                                icon: Icons.local_offer_outlined,
                              ),
                              items: _filteredCategories(categoryVm.categories)
                                  .map((cat_model.CategoryMarketing c) =>
                                      DropdownMenuItem(
                                        value: c.id,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            c.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: false,
                                            style:
                                                const TextStyle(fontSize: 13.0),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => selectedCategoryId = v),
                            ),
                          ),
                          const SizedBox(height: 12),

                          const Text('Number of calls',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.hintTextGrey)),
                          const SizedBox(height: 6),

                          // CALLS (40px)
                          SizedBox(
                            height: 40,
                            child: TextFormField(
                              controller: callsController,
                              keyboardType: TextInputType.number,
                              decoration: dropdownDecoration(
                                  hint: 'Enter Calls',
                                  icon: Icons.phone_outlined),
                            ),
                          ),
                          const SizedBox(height: 12),

                          const Text('Leads',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.hintTextGrey)),
                          const SizedBox(height: 6),

                          // LEADS (40px)
                          SizedBox(
                            height: 40,
                            child: TextFormField(
                              controller: leadsController,
                              keyboardType: TextInputType.number,
                              decoration: dropdownDecoration(
                                  hint: 'Enter Leads',
                                  icon: Icons.show_chart_outlined),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8), // small spacer above bottom bar
          ],
        ),
      ),

      // ---- BUTTONS AT THE VERY BOTTOM ----
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(16, 0, 16, 8), // minimal gap to edge
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Refresh Data — #E0E2FE
              SizedBox(
                width: 119,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data refreshed')),
                    );
                    context.read<SourceViewmodel>().fetchSources();
                    context.read<LocationViewmodel>().fetchLocations();
                    context
                        .read<CategoryMarketingViewmodel>()
                        .fetchCategories();
                  },
                  icon: const Icon(Icons.refresh,
                      color: AppColors.white, size: 18),
                  label: const Text(
                    'Refresh Data',
                    style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC1BABA),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(140, 40),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Save — #0BA100
              SizedBox(
                width: 190,
                height: 48,
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
                  icon: const Icon(Icons.save_outlined, color: AppColors.white),
                  label: const Text(
                    'Create Marketing Report',
                    style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0BA100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(200, 40),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
