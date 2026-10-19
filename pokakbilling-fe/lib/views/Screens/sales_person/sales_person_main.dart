import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/sales_person_viewmodel.dart';
import 'package:pokakbilling/views/Screens/sales_person/add_sales_person.dart';
import 'package:pokakbilling/views/Screens/sales_person/single_sales_person.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/main_page_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_dropdown.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_text.dart';
import 'package:provider/provider.dart';

class SalesPersonMain extends StatefulWidget {
  const SalesPersonMain({super.key});

  @override
  State<SalesPersonMain> createState() => _SalesPersonMainState();
}

class _SalesPersonMainState extends State<SalesPersonMain> {
  String _query = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<SalesPersonViewmodel>(context, listen: false);
    if (provider.selectedSalesPersonId != 0) {
      provider.getSalesPersonById(provider.selectedSalesPersonId);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Reset ONLY sales person selection
  void _resetSalesPersonFilter() {
    final provider = Provider.of<SalesPersonViewmodel>(context, listen: false);
    provider.updateSelectedSalesPersonId(0);
    provider.selectSalesPerson("");
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: screenHeight * 0.18,
                decoration: const BoxDecoration(
                  color: AppColors.violetblue,
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: screenWidth * 0.02,
                    right: screenWidth * 0.03,
                  ),
                  child: AppBar(
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.white,
                      ),
                      onPressed: () {
                        final provider = Provider.of<SalesPersonViewmodel>(
                            context,
                            listen: false);
                        provider.updateSelectedSalesPersonId(0);
                        provider.selectSalesPerson("");
                        Navigator.pop(context);
                      },
                    ),
                    title: Text(
                      'Sales Person',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: screenWidth * 0.05,
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    actions: [
                      MainPageCustomButton(
                        text: "New Sales Person",
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const AddSalesPerson(
                                isEdit: false,
                              ),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: screenHeight * 0.15,
            left: screenWidth * 0.04,
            right: screenWidth * 0.04,
            child: Container(
              height: screenHeight - screenHeight * 0.18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _buildSearchCard(context),
                  Consumer<SalesPersonViewmodel>(
                    builder: (context, provider, child) {
                      // Show spinner while fetching
                      if (provider.getSalesPersonLoading ||
                          provider.singleSalesPersonLoading) {
                        return const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      // A specific sales person selected via dropdown
                      if (provider.selectedSalesPersonId != 0 &&
                          provider.singleSalesPersonList.isNotEmpty) {
                        return Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.only(top: 20),
                            itemBuilder: (context, index) {
                              int originalIndex =
                                  provider.salesPersonList.indexWhere(
                                (c) =>
                                    c.salesPersonId ==
                                    provider.singleSalesPersonList[index]
                                        .salesPersonId,
                              );
                              if (originalIndex == -1) return const SizedBox();
                              return SingleSalePersonCard(index: originalIndex);
                            },
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 20),
                            itemCount: provider.singleSalesPersonList.length,
                          ),
                        );
                      }

                      // Apply name search filter
                      final list = _query.isEmpty
                          ? provider.salesPersonList
                          : provider.salesPersonList
                              .where((sp) => "${sp.firstName} ${sp.lastName}"
                                  .toLowerCase()
                                  .contains(_query.trim().toLowerCase()))
                              .toList();

                      if (list.isEmpty) {
                        return const Expanded(
                          child: Center(
                            child: Text('No Sales Persons Available.'),
                          ),
                        );
                      }

                      return Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.only(top: 20),
                          itemBuilder: (context, index) {
                            // ✅ FIX: find the real index in the full list
                            // so SingleSalePersonCard receives the correct index
                            final originalIndex =
                                provider.salesPersonList.indexWhere(
                              (sp) =>
                                  sp.salesPersonId == list[index].salesPersonId,
                            );
                            if (originalIndex == -1) return const SizedBox();
                            return SingleSalePersonCard(index: originalIndex);
                          },
                          separatorBuilder: (context, index) => const Divider(
                            color: AppColors.grey,
                            thickness: 1.5,
                          ),
                          itemCount: list.length,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 4,
            offset: Offset(2, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            text: "Search",
            isMandatory: true,
          ),
          const SizedBox(height: 8),

          // ── Search by name ─────────────────────────────────────────────────
          TextField(
            controller: _searchController,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: 'Search sales person...',
              hintStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF9E9E9E),
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.violetblue,
              ),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: Color(0xFF9E9E9E),
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.violetblue),
              ),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),

          const SizedBox(height: 15),

          // ── Sales Person dropdown + reset icon ────────────────────────────
          Consumer<SalesPersonViewmodel>(
            builder: (context, provider, child) {
              final bool hasSalesPersonSelected =
                  provider.selectedSalesPerson.isNotEmpty ||
                      provider.selectedSalesPersonId != 0;

              return Row(
                children: [
                  Expanded(
                    child: CustomDropdown(
                      selectedValue: provider.selectedSalesPerson.isNotEmpty
                          ? provider.selectedSalesPerson
                          : null,
                      hint: "Select Sales Person",
                      dropdownItems: provider.salesPersonList
                          .map((c) => "${c.firstName} ${c.lastName}")
                          .toSet()
                          .toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          var selectedCustomer =
                              provider.salesPersonList.firstWhere(
                            (c) => "${c.firstName} ${c.lastName}" == newValue,
                          );
                          provider.updateSelectedSalesPersonId(
                              selectedCustomer.salesPersonId);
                          provider.getSalesPersonById(
                              selectedCustomer.salesPersonId);
                          provider.selectSalesPerson(newValue);
                        }
                      },
                    ),
                  ),
                  // Reset icon — only visible when a sales person is selected
                  if (hasSalesPersonSelected)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: IconButton(
                        onPressed: _resetSalesPersonFilter,
                        icon: const Icon(
                          Icons.clear,
                          color: AppColors.grey,
                          size: 20,
                        ),
                        tooltip: 'Clear Sales Person Filter',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
