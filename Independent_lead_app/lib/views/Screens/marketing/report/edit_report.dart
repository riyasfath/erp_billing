// lib/views/Screens/marketing/report/edit_report.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/marketing_model/marketing_report.dart';
import 'package:pokakbilling/models/data-models/marketing_model/source.dart';
import 'package:pokakbilling/models/data-models/marketing_model/location.dart';
import 'package:pokakbilling/models/data-models/marketing_model/category.dart'
    as cat_mkt;
import 'package:pokakbilling/models/data-models/salesperson_model.dart';
import 'package:pokakbilling/viewmodels/sales_person_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/location_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/categoryList_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/marketing_report_viewmodel.dart';
import 'package:provider/provider.dart';

class EditMarketingReportPage extends StatefulWidget {
  final MarketingReport report;

  const EditMarketingReportPage({super.key, required this.report});

  @override
  State<EditMarketingReportPage> createState() =>
      _EditMarketingReportPageState();
}

class _EditMarketingReportPageState extends State<EditMarketingReportPage> {
  late TextEditingController dateController;
  late TextEditingController callsController;
  late TextEditingController leadsController;

  SalesPersonModel? selectedSalesperson;
  int? selectedSalespersonId;
  Source? selectedSource;
  Location? selectedLocation;
  cat_mkt.CategoryMarketing? selectedCategory;

  @override
  void initState() {
    super.initState();
    dateController = TextEditingController(text: widget.report.date);
    callsController =
        TextEditingController(text: widget.report.calls.toString());
    leadsController =
        TextEditingController(text: widget.report.leads.toString());
    selectedSalespersonId = widget.report.salespersonId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final salesVm = context.read<SalesPersonViewmodel>();
      final sourceVm = context.read<SourceViewmodel>();
      final locationVm = context.read<LocationViewmodel>();
      final categoryVm = context.read<CategoryMarketingViewmodel>();

      setState(() {
        selectedSalesperson = salesVm.salesPersonList
            .where((s) => s.salesPersonId == widget.report.salespersonId)
            .cast<SalesPersonModel?>()
            .followedBy([null]).first;

        selectedSource = sourceVm.sources
            .where((s) => s.id == widget.report.sourceId)
            .cast<Source?>()
            .followedBy([null]).first;

        selectedLocation = locationVm.locations
            .where((l) => l.id == widget.report.locationId)
            .cast<Location?>()
            .followedBy([null]).first;

        selectedCategory = categoryVm.categories
            .where((c) => c.id == widget.report.categoryId)
            .cast<cat_mkt.CategoryMarketing?>()
            .followedBy([null]).first;
      });
    });
  }

  @override
  void dispose() {
    dateController.dispose();
    callsController.dispose();
    leadsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final initial = DateTime.tryParse(dateController.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.violetblue,
            onPrimary: Colors.white,
            onSurface: Colors.black87,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {});
    }
  }

  // Opens a scrollable modal bottom sheet for category selection
  Future<void> _showCategoryPicker(
      List<cat_mkt.CategoryMarketing> options) async {
    final chosen = await showModalBottomSheet<cat_mkt.CategoryMarketing>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Select category',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: options.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final c = options[index];
                        final isSelected = selectedCategory?.id == c.id;
                        return ListTile(
                          title: Text(c.name),
                          trailing: isSelected
                              ? const Icon(Icons.check,
                                  color: AppColors.violetblue)
                              : null,
                          onTap: () {
                            Navigator.of(context).pop(c);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (chosen != null) {
      setState(() {
        selectedCategory = chosen;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportVm = context.watch<MarketingReportViewmodel>();
    final salesVm = context.watch<SalesPersonViewmodel>();
    final sourceVm = context.watch<SourceViewmodel>();
    final locationVm = context.watch<LocationViewmodel>();
    final categoryVm = context.watch<CategoryMarketingViewmodel>();

    final List<cat_mkt.CategoryMarketing> categoryOptions =
        selectedSource == null
            ? categoryVm.categories
            : categoryVm.categories
                .where((c) => c.source == selectedSource!.id)
                .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.violetblue,
        title: const Text('Edit Report',
            style: TextStyle(color: AppColors.white, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.arrow_left, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 8,
                    shadowColor: Colors.grey.withOpacity(0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Date'),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 43,
                            child: TextField(
                              controller: dateController,
                              readOnly: true,
                              onTap: _pickDate,
                              decoration: _input('Select date (YYYY-MM-DD)')
                                  .copyWith(
                                      suffixIcon: const Icon(Icons.date_range)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _label('Salesperson'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<SalesPersonModel>(
                            initialValue: selectedSalesperson,
                            items: salesVm.salesPersonList
                                .map((s) => DropdownMenuItem(
                                      value: s,
                                      child: Text('${s.firstName} ${s.lastName}'
                                          .trim()),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              setState(() {
                                selectedSalesperson = v;
                                selectedSalespersonId = v?.salesPersonId;
                              });
                            },
                            decoration: _input('Select salesperson'),
                          ),
                          const SizedBox(height: 16),
                          _label('Source'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<Source>(
                            initialValue: selectedSource,
                            items: sourceVm.sources
                                .map((s) => DropdownMenuItem(
                                    value: s, child: Text(s.name)))
                                .toList(),
                            onChanged: (v) {
                              setState(() {
                                selectedSource = v;
                                if (selectedCategory != null &&
                                    selectedSource != null &&
                                    selectedCategory!.source !=
                                        selectedSource!.id) {
                                  selectedCategory = null;
                                }
                              });
                            },
                            decoration: _input('Select source'),
                          ),
                          const SizedBox(height: 16),
                          _label('Location'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<Location>(
                            initialValue: selectedLocation,
                            items: locationVm.locations
                                .map((l) => DropdownMenuItem(
                                    value: l, child: Text(l.name)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => selectedLocation = v),
                            decoration: _input('Select location'),
                          ),
                          const SizedBox(height: 16),
                          _label('Category'),
                          const SizedBox(height: 8),

                          // --- Replaced Dropdown with scrollable modal picker ---
                          GestureDetector(
                            onTap: () {
                              // open modal bottom sheet containing the categoryOptions list
                              _showCategoryPicker(categoryOptions);
                            },
                            child: InputDecorator(
                              decoration: _input(selectedSource == null
                                  ? 'Select category (all)'
                                  : 'Select category (filtered by source)'),
                              isEmpty: selectedCategory == null,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      selectedCategory?.name ??
                                          'Choose category',
                                      style: TextStyle(
                                        color: selectedCategory == null
                                            ? const Color(0xFFCAD5E2)
                                            : Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(Icons.arrow_drop_down)
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                          _label('Calls'),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 43,
                            child: TextField(
                              controller: callsController,
                              keyboardType: TextInputType.number,
                              decoration: _input('Enter calls'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _label('Leads'),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 43,
                            child: TextField(
                              controller: leadsController,
                              keyboardType: TextInputType.number,
                              decoration: _input('Enter leads'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: reportVm.editReportLoading
                      ? null
                      : () {
                          final date = dateController.text.trim();
                          final calls =
                              int.tryParse(callsController.text.trim()) ?? 0;
                          final leads =
                              int.tryParse(leadsController.text.trim()) ?? 0;

                          if (date.isEmpty ||
                              selectedSalespersonId == null ||
                              selectedSource == null ||
                              selectedLocation == null ||
                              selectedCategory == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Please fill all required fields')),
                            );
                            return;
                          }

                          reportVm.editReport(
                            reportId: widget.report.id,
                            date: date,
                            salespersonId: selectedSalespersonId!,
                            sourceId: selectedSource!.id,
                            locationId: selectedLocation!.id,
                            categoryId: selectedCategory!.id,
                            calls: calls,
                            leads: leads,
                            context: context,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.violetblue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: reportVm.editReportLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Update',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFCAD5E2)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Cancel',
                      style: TextStyle(fontSize: 16, color: Color(0xFFCAD5E2))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _input(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFCAD5E2)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCAD5E2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCAD5E2)),
        ),
      );

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF643CB5)),
      );
}
