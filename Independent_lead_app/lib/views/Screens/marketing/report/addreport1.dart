// lib/views/Screens/marketing/report/addreport1.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/setup/categoryList_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/location_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/marketing_report_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
import 'package:pokakbilling/views/Screens/marketing/report/addreport2.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/viewmodels/sales_person_viewmodel.dart';
import 'package:pokakbilling/models/data-models/salesperson_model.dart';

class AddReportStep1 extends StatefulWidget {
  const AddReportStep1({super.key});

  @override
  State<AddReportStep1> createState() => _AddReportStep1State();
}

class _AddReportStep1State extends State<AddReportStep1> {
  final TextEditingController dateController = TextEditingController();
  int? selectedSalespersonId;

  @override
  void initState() {
    super.initState();
    // ✅ Date format changed to yyyy-MM-dd
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final spVm = context.read<SalesPersonViewmodel>();
      if (spVm.salesPersonList.isNotEmpty) {
        setState(() =>
            selectedSalespersonId = spVm.salesPersonList.first.salesPersonId);
      } else {
        spVm.getAllSalesPerson();
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime.tryParse(DateFormat('yyyy-MM-dd').format(DateTime.now())) ??
              DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      // ✅ Show as Year-Month-Day
      dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color borderColor = Color(0xFFCAD5E2);
    final salesVm = context.watch<SalesPersonViewmodel>();

    if (selectedSalespersonId == null && salesVm.salesPersonList.isNotEmpty) {
      selectedSalespersonId = salesVm.salesPersonList.first.salesPersonId;
    }

    SalesPersonModel? getSelectedSalesperson() {
      if (selectedSalespersonId == null) return null;
      try {
        return salesVm.salesPersonList
            .firstWhere((s) => s.salesPersonId == selectedSalespersonId);
      } catch (_) {
        return null;
      }
    }

    final selectedSalesperson = getSelectedSalesperson();

    return Scaffold(
      backgroundColor: AppColors.violetblue,
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 28, 14, 40),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SALESPERSON *',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6A7282),
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: salesVm.getSalesPersonLoading
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<int>(
                              initialValue: selectedSalespersonId,
                              hint: const Text('Select Salesperson'),
                              isExpanded: true,
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.softBorder,
                              ),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.personal_injury_sharp,
                                  color: AppColors.softBorder,
                                ),
                                filled: true,
                                fillColor: AppColors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: borderColor),
                                ),
                              ),
                              items: salesVm.salesPersonList.map((s) {
                                return DropdownMenuItem<int>(
                                  value: s.salesPersonId,
                                  child: Text(s.fullName),
                                );
                              }).toList(),
                              onChanged: (v) => setState(() {
                                selectedSalespersonId = v;
                              }),
                            ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.lightPurple,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: selectedSalesperson == null
                          ? const Text(
                              'Email: -\nMobile: -',
                              style: TextStyle(color: AppColors.headerPurple),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Email: ',
                                      style: TextStyle(
                                        color: AppColors.headerPurple,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        selectedSalesperson.email.isNotEmpty
                                            ? selectedSalesperson.email
                                            : '-',
                                        style: const TextStyle(
                                          color: AppColors.headerPurple,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Mobile: ',
                                      style: TextStyle(
                                        color: AppColors.headerPurple,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        selectedSalesperson.mobile.isNotEmpty
                                            ? selectedSalesperson.mobile
                                            : '-',
                                        style: const TextStyle(
                                          color: AppColors.headerPurple,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'REPORT DATE *',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6A7282),
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 44,
                      child: TextField(
                        controller: dateController,
                        readOnly: true,
                        onTap: _pickDate,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Select Date',
                          suffixIcon: const Icon(
                            Icons.calendar_today_outlined,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: borderColor),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Select the date for this marketing report',
                      style: TextStyle(
                        color: Color(0xFF6A7282),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          height: 40,
          child: ElevatedButton.icon(
            onPressed: () {
              final mrVm = context.read<MarketingReportViewmodel>();
              final srcVm = context.read<SourceViewmodel>();
              final locVm = context.read<LocationViewmodel>();
              final catVm = context.read<CategoryMarketingViewmodel>();
              final spVm = context.read<SalesPersonViewmodel>();

              final selectedId = selectedSalespersonId ?? 0;

              final target = MultiProvider(
                providers: [
                  ChangeNotifierProvider.value(value: mrVm),
                  ChangeNotifierProvider.value(value: srcVm),
                  ChangeNotifierProvider.value(value: catVm),
                  ChangeNotifierProvider.value(value: locVm),
                  ChangeNotifierProvider.value(value: spVm),
                ],
                child: AddReportStep2(
                  initialSalespersonId: selectedId,
                  initialSalespersonName: selectedSalesperson?.fullName ?? '',
                  initialDate: dateController.text,
                ),
              );

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => target),
              );
            },
            icon: const Icon(
              Icons.add,
              color: AppColors.black,
              size: 16,
            ),
            label: const Text(
              'Add Source',
              style: TextStyle(
                color: AppColors.violetblue,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
    );
  }
}
