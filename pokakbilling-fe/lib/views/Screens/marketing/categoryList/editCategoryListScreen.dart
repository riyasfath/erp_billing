// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/models/data-models/marketing_model/category.dart';
// import 'package:pokakbilling/models/data-models/marketing_model/source.dart';
// import 'package:pokakbilling/viewmodels/setup/categoryList_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
// import 'package:provider/provider.dart';

// class EditCategoryMarketingPage extends StatefulWidget {
//   final CategoryMarketing category;

//   const EditCategoryMarketingPage({super.key, required this.category});

//   @override
//   State<EditCategoryMarketingPage> createState() =>
//       _EditCategoryMarketingPageState();
// }

// class _EditCategoryMarketingPageState extends State<EditCategoryMarketingPage> {
//   late TextEditingController nameController;
//   Source? selectedSource;

//   @override
//   void initState() {
//     super.initState();
//     nameController = TextEditingController(text: widget.category.name);
//     final sourceVm = Provider.of<SourceViewmodel>(context, listen: false);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (sourceVm.sources.isNotEmpty) {
//         final matchingSource = sourceVm.sources.firstWhere(
//             (s) => s.id == widget.category.source,
//             orElse: () => sourceVm.sources.first);
//         setState(() {
//           selectedSource = matchingSource;
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     nameController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final sourceVm = Provider.of<SourceViewmodel>(context);
//     final categoryVm = Provider.of<CategoryMarketingViewmodel>(context);

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.violetblue,
//         title: const Text('Edit Category',
//             style: TextStyle(color: AppColors.white, fontSize: 16)),
//         leading: IconButton(
//           icon: const Icon(CupertinoIcons.arrow_left, color: AppColors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SafeArea(
//         child: LayoutBuilder(builder: (context, constraints) {
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16.0),
//             child: ConstrainedBox(
//               constraints:
//                   BoxConstraints(minHeight: constraints.maxHeight - 32),
//               child: IntrinsicHeight(
//                 child: Column(
//                   children: [
//                     Card(
//                       color: AppColors.white,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                       elevation: 8,
//                       shadowColor: Colors.grey.withOpacity(0.3),
//                       child: Container(
//                         width: double.infinity,
//                         constraints: const BoxConstraints(maxWidth: 520),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'Category Name',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: AppColors.headerPurple,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             SizedBox(
//                               height: 43,
//                               child: TextField(
//                                 controller: nameController,
//                                 style: const TextStyle(fontSize: 14),
//                                 decoration: InputDecoration(
//                                   hintText: 'Enter category name',
//                                   hintStyle: const TextStyle(
//                                       color: AppColors.softBorder),
//                                   filled: true,
//                                   fillColor: AppColors.inputFill,
//                                   contentPadding: const EdgeInsets.symmetric(
//                                       horizontal: 12, vertical: 8),
//                                   enabledBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                     borderSide: const BorderSide(
//                                         color: AppColors.softBorder),
//                                   ),
//                                   focusedBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                     borderSide: const BorderSide(
//                                         color: AppColors.softBorder),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             const Text(
//                               'Source',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: AppColors.headerPurple,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             SizedBox(
//                               height: 43,
//                               child: DropdownButtonFormField<Source>(
//                                 initialValue: selectedSource,
//                                 items: sourceVm.sources
//                                     .map((source) => DropdownMenuItem(
//                                         value: source,
//                                         child: Text(source.name)))
//                                     .toList(),
//                                 onChanged: (value) {
//                                   setState(() {
//                                     selectedSource = value;
//                                   });
//                                 },
//                                 decoration: InputDecoration(
//                                   filled: true,
//                                   fillColor: AppColors.inputFill,
//                                   contentPadding: const EdgeInsets.symmetric(
//                                       horizontal: 12, vertical: 8),
//                                   enabledBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                     borderSide: const BorderSide(
//                                         color: AppColors.softBorder),
//                                   ),
//                                   focusedBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                     borderSide: const BorderSide(
//                                         color: AppColors.softBorder),
//                                   ),
//                                 ),
//                                 hint: const Text('Select source'),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const Spacer(),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: categoryVm.editCategoryLoading ||
//                                 selectedSource == null ||
//                                 nameController.text.trim().isEmpty
//                             ? null
//                             : () {
//                                 final name = nameController.text.trim();
//                                 final sourceId = selectedSource!.id;
//                                 categoryVm.editCategory(widget.category.id,
//                                     name, sourceId, context);
//                               },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.violetblue,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: categoryVm.editCategoryLoading
//                             ? const SizedBox(
//                                 height: 20,
//                                 width: 20,
//                                 child: CircularProgressIndicator(
//                                     color: AppColors.white, strokeWidth: 2),
//                               )
//                             : const Text('Update',
//                                 style: TextStyle(
//                                     fontSize: 16, color: AppColors.white)),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     SizedBox(
//                       width: double.infinity,
//                       child: OutlinedButton(
//                         onPressed: () => Navigator.pop(context, false),
//                         style: OutlinedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           side: const BorderSide(color: AppColors.softBorder),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8)),
//                         ),
//                         child: const Text('Cancel',
//                             style: TextStyle(
//                                 fontSize: 16, color: AppColors.softBorder)),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/marketing_model/category.dart';
import 'package:pokakbilling/models/data-models/marketing_model/source.dart'
    as SModel;
import 'package:pokakbilling/viewmodels/setup/categoryList_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
import 'package:provider/provider.dart';

const _kIndigo = Color(0xFF6366F1);
const _kIndigoLight = Color(0xFF818CF8);
const _kIndigoDark = Color(0xFF4338CA);
const _kMetricInk = Color(0xFF1E1B4B);
const _kSoftLilac = Color(0xFFF0EEFF);

InputDecoration _editFieldDeco(String hint, {bool isDark = false}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
        color: isDark ? Colors.white30 : Colors.black38, fontSize: 13.5),
    filled: true,
    fillColor: isDark ? Colors.white.withValues(alpha: 0.07) : _kSoftLilac,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
          color: isDark
              ? _kIndigoLight.withValues(alpha: 0.2)
              : _kIndigo.withValues(alpha: 0.2),
          width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: _kIndigo.withValues(alpha: 0.55), width: 1.5),
    ),
  );
}

// ── Shared field label ────────────────────────────────────────────────────────
Widget _fieldLabel(String text, bool isDark) => Text(text,
    style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12.5,
        color: isDark ? _kIndigoLight : _kIndigoDark));

class EditCategoryMarketingPage extends StatefulWidget {
  final CategoryMarketing category;
  const EditCategoryMarketingPage({super.key, required this.category});
  @override
  State<EditCategoryMarketingPage> createState() =>
      _EditCategoryMarketingPageState();
}

class _EditCategoryMarketingPageState extends State<EditCategoryMarketingPage> {
  late TextEditingController nameController;
  SModel.Source? selectedSource;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

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
        setState(() => selectedSource = matchingSource);
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
      backgroundColor:
          _isDark ? const Color(0xFF0F0D1E) : const Color(0xFFF5F4FF),
      appBar: AppBar(
        backgroundColor: _isDark ? const Color(0xFF1A1730) : _kIndigo,
        elevation: 0,
        title: const Text('Edit Category',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.arrow_left, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: constraints.maxHeight - 32),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: _isDark
                            ? Colors.white.withValues(alpha: 0.07)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: _isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : _kIndigo.withValues(alpha: 0.15)),
                        boxShadow: _isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: _kIndigo.withValues(alpha: 0.07),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _isDark
                                    ? _kIndigo.withValues(alpha: 0.2)
                                    : _kIndigo.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Icon(Icons.local_offer_rounded,
                                    color:
                                        _isDark ? _kIndigoLight : _kIndigoDark,
                                    size: 18),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text('Category Details',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color:
                                        _isDark ? Colors.white : _kMetricInk)),
                          ]),
                          const SizedBox(height: 18),
                          _fieldLabel('Category Name', _isDark),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 46,
                            child: TextField(
                              controller: nameController,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: _isDark ? Colors.white : _kMetricInk),
                              decoration: _editFieldDeco('Enter category name',
                                  isDark: _isDark),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _fieldLabel('Source', _isDark),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 46,
                            child: DropdownButtonFormField<SModel.Source>(
                              initialValue: selectedSource,
                              dropdownColor: _isDark
                                  ? const Color(0xFF2A2750)
                                  : Colors.white,
                              icon: Icon(Icons.keyboard_arrow_down_rounded,
                                  color: _isDark ? _kIndigoLight : _kIndigo,
                                  size: 20),
                              style: TextStyle(
                                  color: _isDark ? Colors.white : _kMetricInk,
                                  fontSize: 14),
                              items: sourceVm.sources
                                  .map((source) => DropdownMenuItem(
                                      value: source,
                                      child: Text(source.name,
                                          style: TextStyle(
                                              color: _isDark
                                                  ? Colors.white
                                                  : _kMetricInk))))
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => selectedSource = value),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: _isDark
                                    ? Colors.white.withValues(alpha: 0.07)
                                    : _kSoftLilac,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 11),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: _isDark
                                          ? _kIndigoLight.withValues(alpha: 0.2)
                                          : _kIndigo.withValues(alpha: 0.2)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: _kIndigo.withValues(alpha: 0.55),
                                      width: 1.5),
                                ),
                              ),
                              hint: Text('Select source',
                                  style: TextStyle(
                                      color: _isDark
                                          ? Colors.white30
                                          : Colors.black38,
                                      fontSize: 13.5)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
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
                          backgroundColor: _kIndigo,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: categoryVm.editCategoryLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Update Category',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: _isDark
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : _kIndigo.withValues(alpha: 0.25)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Cancel',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color:
                                    _isDark ? Colors.white60 : Colors.black54)),
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
