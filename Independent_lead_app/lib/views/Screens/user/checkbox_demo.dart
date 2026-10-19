import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/user_access_viewmodel.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
import 'package:provider/provider.dart';

class AllocateAccessCheckbox extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String emailId;
  final String password;

  const AllocateAccessCheckbox({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.emailId,
    required this.password,
  });

  @override
  State<AllocateAccessCheckbox> createState() => _AllocateAccessCheckboxState();
}

class _AllocateAccessCheckboxState extends State<AllocateAccessCheckbox> {
  bool isInitialized = false;
  bool isAllSelected = false;
  List<Map<String, dynamic>> dataList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      final userAccessProvider =
          Provider.of<UserAccessViewmodel>(context, listen: false);
      for (var module in userAccessProvider.moduleConfigs) {
        dataList.add({
          "title": module.title,
          "key": module.key,
          "icon": module.icon,
          "isChecked": false,
        });
      }
      isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.violetblue,
        title: const Text(
          'Allocate Access',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: AppColors.white),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.violetblue,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                icon:
                    Icon(isAllSelected ? Icons.remove_done : Icons.select_all),
                label: Text(
                  isAllSelected ? "Unselect All" : "Select All",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                onPressed: () {
                  setState(() {
                    isAllSelected = !isAllSelected;
                    for (var item in dataList) {
                      item["isChecked"] = isAllSelected;
                    }
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  value: dataList[index]["isChecked"],
                  onChanged: (value) {
                    setState(() {
                      dataList[index]["isChecked"] = value!;
                    });
                  },
                  title: Row(
                    children: [
                      Icon(dataList[index]["icon"],
                          color: AppColors.violetblue),
                      const SizedBox(width: 10),
                      Text(
                        dataList[index]["title"],
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Consumer<UserAccessViewmodel>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: GestureDetector(
              onTap: () {
                List<String> selectedModules = dataList
                    .where((item) => item["isChecked"] == true)
                    .map<String>((item) => item["key"] as String)
                    .toList();

                if (selectedModules.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please select at least one module."),
                      backgroundColor: AppColors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                provider.createUserAccess(
                  widget.firstName,
                  widget.lastName,
                  widget.emailId,
                  widget.password,
                  selectedModules,
                  context,
                );
              },
              child: CustomButton(
                name: "Save",
                loading: provider.createUserAccessLoader,
              ),
            ),
          );
        },
      ),
    );
  }
}
