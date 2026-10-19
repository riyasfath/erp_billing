// lib/views/Screens/marketing/report/filterScreen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/setup/marketing_report_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/categoryList_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/location_viewmodel.dart';
import 'package:pokakbilling/viewmodels/sales_person_viewmodel.dart';

class MarketingReportFilterPage extends StatefulWidget {
  const MarketingReportFilterPage({super.key});

  @override
  State<MarketingReportFilterPage> createState() =>
      _MarketingReportFilterPageState();
}

class _MarketingReportFilterPageState extends State<MarketingReportFilterPage> {
  final DateFormat _displayFormat = DateFormat('dd - MM - yyyy');
  final DateFormat _apiFormat = DateFormat('yyyy-MM-dd');

  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  int? _selectedSourceId;
  int? _selectedCategoryId;
  int? _selectedLocationId;
  int? _selectedSalespersonId;

  static const Color uiColor = Color(0xFF6A7282);
  static const Color fieldBorderColor = Color(0xFFE6E6EA);

  // base field height; will scale on large screens using MediaQuery
  static const double baseFieldHeight = 40.0;
  static const double fieldRadius = 8.0;

  static const TextStyle headingStyle =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: uiColor);

  static const TextStyle fieldTextStyle = TextStyle(
      fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87);

  @override
  void initState() {
    super.initState();
    final vm = context.read<MarketingReportViewmodel>();
    if (vm.fromDate != null && vm.fromDate!.isNotEmpty) {
      _fromController.text = vm.fromDate!;
    }
    if (vm.toDate != null && vm.toDate!.isNotEmpty) {
      _toController.text = vm.toDate!;
    }
    _selectedSourceId = vm.selectedSourceId;
    _selectedCategoryId = vm.selectedCategoryId;
    _selectedLocationId = vm.selectedLocationId;
    _selectedSalespersonId = vm.selectedSalespersonId;
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, TextEditingController controller,
      {DateTime? firstDate, DateTime? lastDate}) async {
    DateTime now = DateTime.now();
    DateTime initialDate = now;
    try {
      if (controller.text.isNotEmpty) {
        initialDate = _apiFormat.parse(controller.text);
      }
    } catch (_) {}

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime(now.year - 10),
      lastDate: lastDate ?? DateTime(now.year + 10),
    );

    if (picked != null) {
      controller.text = _apiFormat.format(picked);
      setState(() {});
    }
  }

  InputDecoration _inputDecoration({
    required String hint,
    IconData? prefixIcon,
    Widget? suffix,
    double horizontalPadding = 16,
    double verticalPadding = 14,
  }) {
    return InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: verticalPadding),
      hintText: hint,
      hintStyle: fieldTextStyle.copyWith(color: uiColor.withOpacity(0.7)),
      prefixIcon: prefixIcon != null
          ? Padding(
              padding: const EdgeInsets.only(left: 10, right: 8),
              child: Icon(prefixIcon, size: 20, color: uiColor),
            )
          : null,
      prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(fieldRadius),
        borderSide: const BorderSide(color: fieldBorderColor, width: 1.4),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(fieldRadius),
        borderSide: const BorderSide(color: fieldBorderColor, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(fieldRadius),
        borderSide: BorderSide(
            color: AppColors.violetblue.withOpacity(0.9), width: 1.6),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text.toUpperCase(), style: headingStyle),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required List<T> items,
    required int? selectedId,
    required void Function(int?) onChanged,
    required String Function(T) getName,
    required int Function(T) getId,
    required IconData icon,
    String? hint,
    double fieldHeight = baseFieldHeight,
  }) {
    final itemList = items.map((item) {
      final id = getId(item);
      final name = getName(item);
      return DropdownMenuItem<int>(
        value: id,
        child: Text(name, style: fieldTextStyle),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        SizedBox(
          height: fieldHeight,
          child: DropdownButtonFormField<int>(
            isExpanded: true,
            initialValue: selectedId,
            style: fieldTextStyle,
            dropdownColor: Colors.white,
            icon:
                const Icon(Icons.keyboard_arrow_down, size: 18, color: uiColor),
            items: itemList,
            onChanged: onChanged,
            decoration: _inputDecoration(
              hint: hint ?? 'Choose',
              prefixIcon: icon,
              horizontalPadding: 14,
              verticalPadding: 12,
            ),
            hint: Text(hint ?? 'Choose',
                style:
                    fieldTextStyle.copyWith(color: uiColor.withOpacity(0.6))),
          ),
        ),
      ],
    );
  }

  void _clearAllFilters() {
    setState(() {
      _fromController.text = '';
      _toController.text = '';
      _selectedSourceId = null;
      _selectedCategoryId = null;
      _selectedLocationId = null;
      _selectedSalespersonId = null;
    });

    final vm = context.read<MarketingReportViewmodel>();
    vm.clearFilters();
    Navigator.of(context).pop('clear');
  }

  void _saveFilters() {
    final vm = context.read<MarketingReportViewmodel>();
    final from = _fromController.text.isNotEmpty ? _fromController.text : null;
    final to = _toController.text.isNotEmpty ? _toController.text : null;

    vm.applyFilters(
      from: from,
      to: to,
      sourceId: _selectedSourceId,
      categoryId: _selectedCategoryId,
      locationId: _selectedLocationId,
      salespersonId: _selectedSalespersonId,
    );

    Navigator.of(context).pop('save');
  }

  String formatDisplay(String apiDate) {
    try {
      final dt = _apiFormat.parse(apiDate);
      return _displayFormat.format(dt);
    } catch (_) {
      return apiDate;
    }
  }

  // Modified _dateBox to accept optional textSize and explicit fieldHeight (already supported)
  Widget _dateBox({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
    required IconData icon,
    double fieldHeight = baseFieldHeight,
    double? textSize,
  }) {
    final text = controller.text.isEmpty ? '' : formatDisplay(controller.text);
    final double effectiveFontSize = textSize ?? fieldTextStyle.fontSize ?? 15;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: fieldHeight,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(fieldRadius),
              border: Border.all(color: fieldBorderColor, width: 1.2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text.isEmpty ? 'dd - mm - yyyy' : text,
                    style: text.isEmpty
                        ? fieldTextStyle.copyWith(
                            color: Colors.black, fontSize: effectiveFontSize)
                        : fieldTextStyle.copyWith(fontSize: effectiveFontSize),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (text.isNotEmpty) ...[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        controller.text = '';
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.clear, size: 20, color: Colors.black38),
                    ),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Icon(icon, size: 18, color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sourceVm = Provider.of<SourceViewmodel>(context);
    final categoryVm = Provider.of<CategoryMarketingViewmodel>(context);
    final locationVm = Provider.of<LocationViewmodel>(context);
    final salespersonVm = Provider.of<SalesPersonViewmodel>(context);

    final sources = sourceVm.sources ?? [];
    final categories = categoryVm.categories ?? [];
    final locations = locationVm.locations ?? [];
    final salespersons = salespersonVm.salesPersonList;

    final media = MediaQuery.of(context);
    final screenH = media.size.height;
    final double adaptiveFieldHeight =
        (screenH > 800) ? baseFieldHeight + 10 : baseFieldHeight;
    final double verticalSpacing = (screenH > 820) ? 18.0 : 12.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: AppColors.violetblue,
          elevation: 0,
          centerTitle: false,
          titleSpacing: 0,
          // remove left-side automatic back/close button
          automaticallyImplyLeading: false,
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 4),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Marketing Reports',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            // Export button on the right side of the appbar (white pill with icon)
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: SizedBox(
                height: 30,
                width: 82,
                child: TextButton.icon(
                  onPressed: () {
                    // TODO: implement export action
                  },
                  icon: const Icon(
                    Icons.upload_outlined,
                    size: 16,
                    color: AppColors.violetblue,
                  ),
                  label: const Text(
                    'Export',
                    style: TextStyle(
                      color: AppColors.violetblue,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.zero, // so the height/width are exact
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),
            ),
          ]),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // "Filters" header under appbar (with icon and a close button at the end)
            Container(
              width: double.infinity,
              height: 39, // 🔹 Fixed height
              color: const Color(0xFFF0E8FF),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12), // remove vertical padding
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.center, // center contents vertically
                children: [
                  const Icon(Icons.filter_alt_outlined,
                      color: Colors.black, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Filters',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: const SizedBox(
                      height: 28,
                      width: 28,
                      child: Icon(Icons.close, size: 12, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),

            // The rest of the UI (scrollable filter form)
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                return SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 36,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    // Changed from Expanded to SizedBox with fixed width 118 and height 29
                                    SizedBox(
                                      width: 118,
                                      child: _dateBox(
                                        label: 'FROM DATE',

                                        controller: _fromController,
                                        onTap: () async => await _pickDate(
                                            context, _fromController),
                                        icon: Icons.calendar_today_outlined,
                                        fieldHeight: 29,
                                        textSize: 12, // reduced text size
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 118,
                                      child: _dateBox(
                                        label: 'TO DATE',
                                        controller: _toController,
                                        onTap: () async => await _pickDate(
                                            context, _toController),
                                        icon: Icons.calendar_today_outlined,
                                        fieldHeight: 29,
                                        textSize: 12, // reduced text size
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: verticalSpacing),
                                _buildDropdown(
                                  label: 'SOURCE',
                                  items: sources,
                                  selectedId: _selectedSourceId,
                                  onChanged: (v) =>
                                      setState(() => _selectedSourceId = v),
                                  getName: (item) =>
                                      (item.name ?? item.toString()),
                                  getId: (item) => item.id,
                                  icon: Icons.circle_sharp,
                                  hint: 'Choose a source...',
                                  fieldHeight: adaptiveFieldHeight,
                                ),
                                SizedBox(height: verticalSpacing),
                                _buildDropdown(
                                  label: 'CATEGORY',
                                  items: categories,
                                  selectedId: _selectedCategoryId,
                                  onChanged: (v) =>
                                      setState(() => _selectedCategoryId = v),
                                  getName: (item) =>
                                      (item.name ?? item.toString()),
                                  getId: (item) => item.id,
                                  icon: Icons.local_offer_outlined,
                                  hint: 'Choose a category...',
                                  fieldHeight: adaptiveFieldHeight,
                                ),
                                SizedBox(height: verticalSpacing),
                                _buildDropdown(
                                  label: 'LOCATION',
                                  items: locations,
                                  selectedId: _selectedLocationId,
                                  onChanged: (v) =>
                                      setState(() => _selectedLocationId = v),
                                  getName: (item) =>
                                      (item.name ?? item.toString()),
                                  getId: (item) => item.id,
                                  icon: Icons.location_on_outlined,
                                  hint: 'Choose a location...',
                                  fieldHeight: adaptiveFieldHeight,
                                ),
                                SizedBox(height: verticalSpacing),
                                _buildDropdown(
                                  label: 'SALESPERSON',
                                  items: salespersons,
                                  selectedId: _selectedSalespersonId,
                                  onChanged: (v) => setState(
                                      () => _selectedSalespersonId = v),
                                  getName: (item) =>
                                      '${item.firstName} ${item.lastName}'
                                          .trim(),
                                  getId: (item) => item.salesPersonId,
                                  icon: Icons.person_outline,
                                  hint: 'Choose a salesperson...',
                                  fieldHeight: adaptiveFieldHeight,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // keep layout spacing same as before; footer is outside Expanded to stay fixed at bottom
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),

            // ---------------------
            // Footer at bottom: pale-purple background and fixed-size buttons
            // Placed outside the scroll area so it stays anchored to the bottom
            // ---------------------
            Container(
              color: const Color(0xFFF0E8FF), // same as top Filters strip
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              child: SafeArea(
                top: false,
                bottom: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Clear Filters
                    SizedBox(
                      width: 136,
                      height: 32,
                      child: OutlinedButton.icon(
                        onPressed: _clearAllFilters,
                        icon: const Icon(Icons.close,
                            size: 11, color: Colors.black54),
                        label: const Text(
                          'Clear Filters',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                              color: fieldBorderColor, width: 1.0),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Save
                    SizedBox(
                      width: 144,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: _saveFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.violetblue,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                          minimumSize: const Size(160, 32),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
