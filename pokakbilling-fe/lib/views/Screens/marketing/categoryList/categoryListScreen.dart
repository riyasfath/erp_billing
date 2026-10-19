import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/marketing_model/category.dart';
import 'package:pokakbilling/models/data-models/marketing_model/source.dart';
import 'package:pokakbilling/viewmodels/setup/categoryList_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
import 'package:pokakbilling/views/Screens/marketing/categoryList/addCategoryListScreen.dart';
import 'package:pokakbilling/views/Screens/marketing/categoryList/editCategoryListScreen.dart';
import 'package:provider/provider.dart';

class CategoryMarketingScreen extends StatelessWidget {
  const CategoryMarketingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CategoryMarketingViewmodel()),
        ChangeNotifierProvider(create: (_) => SourceViewmodel()),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.violetblue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(CupertinoIcons.arrow_left, color: AppColors.white),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: false,
          titleSpacing: 0,
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_offer_outlined,
                  color: AppColors.white, size: 16),
              SizedBox(width: 4),
              Text(
                'Category',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            Consumer2<CategoryMarketingViewmodel, SourceViewmodel>(
              builder: (context, categoryVm, sourceVm, child) {
                return Container(
                  margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MultiProvider(
                            providers: [
                              ChangeNotifierProvider.value(value: categoryVm),
                              ChangeNotifierProvider.value(value: sourceVm),
                            ],
                            child: const AddCategoryMarketingPage(),
                          ),
                        ),
                      );
                    },
                    icon:
                        const Icon(Icons.add, color: AppColors.black, size: 18),
                    label: const Text(
                      'Categories',
                      style: TextStyle(
                          color: AppColors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 2),
                      minimumSize: const Size(0, 28),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        backgroundColor: AppColors.lightGrey,
        body: Consumer2<CategoryMarketingViewmodel, SourceViewmodel>(
          builder: (context, categoryVm, sourceVm, child) {
            if (categoryVm.isLoading || sourceVm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (categoryVm.errorMessage != null) {
              return Center(child: Text('Error: ${categoryVm.errorMessage}'));
            }
            if (categoryVm.categories.isEmpty) {
              return const Center(child: Text('No categories available'));
            }

            final sources = sourceVm.sources;

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
              itemCount: categoryVm.categories.length,
              itemBuilder: (context, index) {
                final category = categoryVm.categories[index];
                return CategoryMarketingCard(
                  category: category,
                  sources: sources,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Category Card with new styled UI
class CategoryMarketingCard extends StatelessWidget {
  final CategoryMarketing category;
  final List<Source> sources;

  const CategoryMarketingCard({
    required this.category,
    required this.sources,
    super.key,
  });

  String get sourceName {
    final sourceObj = sources.firstWhere(
      (s) => s.id == category.source,
      orElse: () => Source(id: 0, name: '-', categories: []),
    );
    return sourceObj.name;
  }

  void _showDeleteConfirmation(
      BuildContext context, CategoryMarketingViewmodel vm) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: Text('Are you sure you want to delete "${category.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: vm.deleteCategoryLoading
                  ? null
                  : () {
                      Navigator.of(dialogContext).pop();
                      vm.deleteCategory(category.id, context);
                    },
              child: vm.deleteCategoryLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Delete',
                      style: TextStyle(color: AppColors.red),
                    ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CategoryMarketingViewmodel>(context, listen: false);

    const double actionAreaWidth = 60.0;
    const double cardHeight = 60.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: cardHeight,
          child: Stack(
            children: [
              // Top border line
              Positioned(
                top: 0,
                left: 8,
                right: 8,
                child: Container(
                  height: 1.0,
                  color: AppColors.violetblue,
                ),
              ),

              LayoutBuilder(
                builder: (context, constraints) {
                  final leftWidth = (constraints.maxWidth - actionAreaWidth)
                      .clamp(0.0, constraints.maxWidth);

                  return Row(
                    children: [
                      // Left gradient section
                      SizedBox(
                        width: leftWidth,
                        height: cardHeight,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                            topRight: Radius.circular(44),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.violetblue,
                                  AppColors.primaryColor
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.local_offer_outlined,
                                    color: AppColors.white, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category.name,
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Source: $sourceName',
                                        style: const TextStyle(
                                          color: Colors
                                              .white70, // keep as Material white70 for subtle contrast
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Right action area
                      Container(
                        width: actionAreaWidth,
                        height: cardHeight,
                        decoration: const BoxDecoration(
                          color: AppColors.transparent,
                          border: Border(
                            top: BorderSide(
                                color: AppColors.violetblue, width: 1.0),
                            right: BorderSide(color: AppColors.violetblue),
                            bottom: BorderSide(color: AppColors.violetblue),
                          ),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MultiProvider(
                                      providers: [
                                        ChangeNotifierProvider.value(value: vm),
                                        ChangeNotifierProvider.value(
                                          value: Provider.of<SourceViewmodel>(
                                              context,
                                              listen: false),
                                        ),
                                      ],
                                      child: EditCategoryMarketingPage(
                                          category: category),
                                    ),
                                  ),
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(Icons.edit_outlined,
                                    size: 18, color: AppColors.hintTextGrey),
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () => _showDeleteConfirmation(context, vm),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(Icons.delete_outline,
                                    size: 18, color: AppColors.hintTextGrey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
