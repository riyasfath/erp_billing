import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';

class SalesByCategory extends StatefulWidget {
  const SalesByCategory({super.key});

  @override
  State<SalesByCategory> createState() => _SalesByCategoryPageState();
}

class _SalesByCategoryPageState extends State<SalesByCategory> {
  late TextEditingController customerNameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var containerHeight = 55;
  var spacing = 20;
  var totalItems = 15;

  @override
  void dispose() {
    customerNameController.dispose();
    super.dispose();
  }

  DateTime? fromDate;
  DateTime? toDate;
  String? selectedDateRange;
  final List<String> dateRanges = [
    'Today',
    'This Week',
    'This Month',
    'This Quarter',
    'This Year',
    'Yesterday',
  ];

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != (isFromDate ? fromDate : toDate)) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.violetblue,
        title: const Text(
          'Sales By Category',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: Image.asset(AppAssets.homeIcon),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const BottomBar(index: 0),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                key: formKey,
                child: TextFormField(
                  controller: customerNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'required';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: "Category",
                    hintStyle: TextStyle(
                      color: AppColors.violetblue,
                    ),
                    suffixIcon: Icon(Icons.arrow_drop_down),
                    labelStyle: TextStyle(
                      color: AppColors.violetblue,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDate(context, true),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: fromDate != null
                          ? DateFormat('dd/MM/yyyy').format(fromDate!)
                          : 'From',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDate(context, false),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: toDate != null
                          ? DateFormat('dd/MM/yyyy').format(toDate!)
                          : 'To',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.violetblue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () {
                  // Handle run report action
                },
                child: const Text(
                  'Generate Report',
                  style: TextStyle(color: AppColors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
