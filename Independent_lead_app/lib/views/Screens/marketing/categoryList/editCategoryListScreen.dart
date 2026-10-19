import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/marketing_model/category.dart';
import 'package:pokakbilling/models/data-models/marketing_model/source.dart';
import 'package:pokakbilling/viewmodels/setup/categoryList_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
import 'package:provider/provider.dart';

class EditCategoryMarketingPage extends StatefulWidget {
  final CategoryMarketing category;

  const EditCategoryMarketingPage({super.key, required this.category});

  @override
  State<EditCategoryMarketingPage> createState() =>
      _EditCategoryMarketingPageState();
}

class _EditCategoryMarketingPageState extends State<EditCategoryMarketingPage> {
  late TextEditingController nameController;
  Source? selectedSource;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.category.name);
    final sourceVm = Provider.of<SourceViewmodel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (sourceVm.sources.isNotEmpty) {
        final matchingSource = sourceVm.sources.firstWhere(
            (s) => s.id == widget.category.source,
            orElse: () => sourceVm.sources.first);
        setState(() {
          selectedSource = matchingSource;
        });
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sourceVm = Provider.of<SourceViewmodel>(context);
    final categoryVm = Provider.of<CategoryMarketingViewmodel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.violetblue,
        title: const Text('Edit Category',
            style: TextStyle(color: AppColors.white, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.arrow_left, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: constraints.maxHeight - 32),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Card(
                      color: AppColors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 8,
                      shadowColor: Colors.grey.withOpacity(0.3),
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 520),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Category Name',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.headerPurple,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 43,
                              child: TextField(
                                controller: nameController,
                                style: const TextStyle(fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'Enter category name',
                                  hintStyle: const TextStyle(
                                      color: AppColors.softBorder),
                                  filled: true,
                                  fillColor: AppColors.inputFill,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: AppColors.softBorder),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: AppColors.softBorder),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Source',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.headerPurple,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 43,
                              child: DropdownButtonFormField<Source>(
                                initialValue: selectedSource,
                                items: sourceVm.sources
                                    .map((source) => DropdownMenuItem(
                                        value: source,
                                        child: Text(source.name)))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedSource = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.inputFill,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: AppColors.softBorder),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: AppColors.softBorder),
                                  ),
                                ),
                                hint: const Text('Select source'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: categoryVm.editCategoryLoading ||
                                selectedSource == null ||
                                nameController.text.trim().isEmpty
                            ? null
                            : () {
                                final name = nameController.text.trim();
                                final sourceId = selectedSource!.id;
                                categoryVm.editCategory(widget.category.id,
                                    name, sourceId, context);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.violetblue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: categoryVm.editCategoryLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: AppColors.white, strokeWidth: 2),
                              )
                            : const Text('Update',
                                style: TextStyle(
                                    fontSize: 16, color: AppColors.white)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.softBorder),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Cancel',
                            style: TextStyle(
                                fontSize: 16, color: AppColors.softBorder)),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
