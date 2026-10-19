import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/setup/categoryList_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
import 'package:pokakbilling/views/Screens/marketing/categoryList/editCategoryListScreen.dart';
import 'package:pokakbilling/models/data-models/marketing_model/source.dart';

class CategoryTab extends StatefulWidget {
  const CategoryTab({super.key});

  @override
  State<CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends State<CategoryTab> {
  final TextEditingController _search = TextEditingController();

  Future<void> _confirmAndDeleteCategory(BuildContext context,
      CategoryMarketingViewmodel categoryVm, int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) =>
          ChangeNotifierProvider<CategoryMarketingViewmodel>.value(
        value: categoryVm,
        child: Consumer<CategoryMarketingViewmodel>(
          builder: (dialogCtx, vm, _) => AlertDialog(
            title: const Text('Delete category'),
            content:
                const Text('Are you sure you want to delete this category?'),
            actions: [
              TextButton(
                  onPressed: vm.deleteCategoryLoading
                      ? null
                      : () => Navigator.of(dialogCtx).pop(false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: vm.deleteCategoryLoading
                      ? null
                      : () => Navigator.of(dialogCtx).pop(true),
                  child: vm.deleteCategoryLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Delete',
                          style: TextStyle(color: AppColors.red))),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      await categoryVm.deleteCategory(id, context);
      await categoryVm.fetchCategories();
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Category deleted')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CategoryMarketingViewmodel, SourceViewmodel>(
      builder: (context, categoryVm, sourceVm, _) {
        if (categoryVm.isLoading || sourceVm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (categoryVm.errorMessage != null) {
          return Center(child: Text('Error: ${categoryVm.errorMessage}'));
        }
        if (categoryVm.categories.isEmpty) {
          return const Center(child: Text('No categories found'));
        }

        final sources = sourceVm.sources;
        final q = _search.text.trim().toLowerCase();
        final items = categoryVm.categories
            .where((c) => c.name.toLowerCase().contains(q))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: SizedBox(
                height: 42,
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search Category.',
                    hintStyle: const TextStyle(
                      color: Color(0xFFA9A0A0),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon:
                        const Icon(Icons.search, color: Color(0xFF37343C)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(17),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                children: [
                  Text('Top',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  SizedBox(width: 3),
                  Icon(Icons.arrow_upward, size: 16, color: Color(0xFF13C313)),
                ],
              ),
            ),
            const SizedBox(height: 6),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 120),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final category = items[index];
                  final sourceObj = sources.firstWhere(
                    (s) => s.id == category.source,
                    orElse: () => Source(id: 0, name: '-', categories: []),
                  );

                  return Container(
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: AppColors.listCardGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Expand left content to let text ellipsize
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Row 1: icon + title
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 28,
                                      child: Icon(Icons.local_offer,
                                          color: AppColors.violetblue,
                                          size: 22),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        category.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2C2A74),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                // Row 2: "Source: <name>" aligned under the title (not the icon)
                                Row(
                                  children: [
                                    const SizedBox(
                                        width:
                                            36), // 28(icon gutter) + 8(spacing)
                                    Flexible(
                                      child: RichText(
                                        text: TextSpan(
                                          text: 'Source: ',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                Colors.black, // label in black
                                          ),
                                          children: [
                                            TextSpan(
                                              text: sourceObj.name,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors
                                                    .violetblue, // name in violetblue
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.white, // white 3 dots
                              size: 22,
                            ),
                            onSelected: (value) async {
                              if (value == 'edit') {
                                await Navigator.push<bool?>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MultiProvider(
                                      providers: [
                                        ChangeNotifierProvider.value(
                                            value: categoryVm),
                                        ChangeNotifierProvider.value(
                                            value: sourceVm),
                                      ],
                                      child: EditCategoryMarketingPage(
                                          category: category),
                                    ),
                                  ),
                                );
                                await categoryVm.fetchCategories();
                              } else if (value == 'delete') {
                                await _confirmAndDeleteCategory(
                                    context, categoryVm, category.id);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(
                                  value: 'delete', child: Text('Delete')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
