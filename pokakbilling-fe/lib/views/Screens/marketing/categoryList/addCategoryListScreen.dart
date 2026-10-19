import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/marketing_model/source.dart';
import 'package:pokakbilling/viewmodels/setup/categoryList_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
import 'package:provider/provider.dart';

class AddCategoryMarketingPage extends StatefulWidget {
  const AddCategoryMarketingPage({super.key});

  @override
  State<AddCategoryMarketingPage> createState() =>
      _AddCategoryMarketingPageState();
}

class _AddCategoryMarketingPageState extends State<AddCategoryMarketingPage> {
  final TextEditingController nameController = TextEditingController();
  Source? selectedSource;

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
        title:
            const Text('Add Category', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.arrow_left, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          // Use a scroll view to avoid overflow on small screens
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    constraints.maxHeight - 32, // leave some breathing room
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Card (flexible width)
                    Card(
                      color: AppColors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 8,
                      shadowColor: Colors.grey.withValues(alpha: 0.3),
                      child: Container(
                        // responsive width: use full available width but limit max width
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
                                  hintText: 'Enter category name...',
                                  hintStyle: const TextStyle(
                                      color: AppColors.hintTextGrey),
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
                              'Source *',
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
                                    .map((s) => DropdownMenuItem(
                                        value: s, child: Text(s.name)))
                                    .toList(),
                                onChanged: (value) =>
                                    setState(() => selectedSource = value),
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
                                hint: const Text(
                                  'Select source...',
                                  style: TextStyle(color: AppColors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Buttons area - stays at bottom of content
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: categoryVm.addCategoryLoading ||
                                selectedSource == null ||
                                nameController.text.trim().isEmpty
                            ? null
                            : () {
                                categoryVm.createCategory(
                                    nameController.text.trim(),
                                    selectedSource!.id,
                                    context);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.violetblue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: categoryVm.addCategoryLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: AppColors.white, strokeWidth: 2),
                              )
                            : const Text('Save',
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
