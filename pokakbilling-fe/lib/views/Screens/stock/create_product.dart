// import 'package:flutter/material.dart';
// import 'package:pokakbilling/models/data-models/product_model.dart';
// import 'package:pokakbilling/viewmodels/setup/category_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/product_viewmodel.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/viewmodels/setup/unit_viewmodel.dart';
// import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
// import 'package:pokakbilling/views/commonWidgets/buttons/exit_custom_button.dart';
// import 'package:pokakbilling/views/commonWidgets/textfields/custom_dropdown.dart';
// import 'package:pokakbilling/views/commonWidgets/textfields/mandatory_textfield.dart';
// import 'package:provider/provider.dart';

// class AddProduct extends StatefulWidget {
//   final bool isEdit;
//   final ProductModel? product;
//   const AddProduct({super.key, required this.isEdit, this.product});

//   @override
//   State<AddProduct> createState() => _AddProductState();
// }

// class _AddProductState extends State<AddProduct> {
//   late TextEditingController nameController;
//   late TextEditingController categoryController;
//   late TextEditingController descriptionController;
//   late TextEditingController unitController;
//   late TextEditingController unitPriceController;
//   late TextEditingController sgstController;
//   late TextEditingController cgstController;
//   late TextEditingController stockController;

//   @override
//   void initState() {
//     super.initState();
//     nameController =
//         TextEditingController(text: widget.product?.productName ?? '');
//     categoryController = TextEditingController(
//         text: widget.product?.categoryName.toString() ?? '');
//     descriptionController =
//         TextEditingController(text: widget.product?.productDescription ?? '');
//     unitController =
//         TextEditingController(text: widget.product?.unitName ?? '');
//     unitPriceController =
//         TextEditingController(text: widget.product?.unitPrice ?? '');
//     stockController =
//         TextEditingController(text: widget.product?.stock.toString() ?? '');
//     sgstController = TextEditingController(text: widget.product?.sgst ?? '');
//     cgstController = TextEditingController(text: widget.product?.cgst ?? '');

//     Future.microtask(() {
//       if (mounted && widget.isEdit && widget.product != null) {
//         final categoryProvider =
//             Provider.of<CategoryViewmodel>(context, listen: false);

//         categoryProvider.updateSelectedCategoryId(widget.product!.categoryId);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     nameController.dispose();
//     categoryController.dispose();
//     descriptionController.dispose();
//     unitController.dispose();
//     unitPriceController.dispose();
//     stockController.dispose();
//     sgstController.dispose();
//     cgstController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final formKey = GlobalKey<FormState>();
//     final categoryProvider = Provider.of<CategoryViewmodel>(context);

//     return Scaffold(
//       backgroundColor: AppColors.white,
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Container(
//                 height: 150,
//                 decoration: const BoxDecoration(
//                   color: AppColors.violetblue,
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.only(
//                     left: 10,
//                     right: 10,
//                   ),
//                   child: AppBar(
//                     leading: IconButton(
//                       icon: const Icon(
//                         Icons.arrow_back,
//                         color: AppColors.white,
//                       ),
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                     ),
//                     title: Text(
//                       widget.isEdit ? 'Edit Product' : 'theng Product',
//                       style: const TextStyle(
//                         color: AppColors.white,
//                         fontWeight: FontWeight.w500,
//                         fontSize: 18,
//                       ),
//                     ),
//                     backgroundColor: Colors.transparent,
//                     elevation: 0,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Positioned(
//             top: 115,
//             left: 20,
//             right: 20,
//             bottom: 30,
//             child: Container(
//               height: 620,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     Card(
//                       color: AppColors.white,
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Form(
//                         key: formKey,
//                         child: Padding(
//                           padding: const EdgeInsets.all(15),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               MandatoryTextField(
//                                 controller: nameController,
//                                 label: 'Product Name',
//                                 isRequired: true,
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'Required';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                               const SizedBox(height: 15),
//                               Consumer<CategoryViewmodel>(
//                                 builder: (context, provider, child) {
//                                   return CustomDropdown(
//                                     selectedValue: provider.categoryList.any(
//                                             (c) =>
//                                                 c.categoryName ==
//                                                 categoryController.text)
//                                         ? categoryController.text
//                                         : null,
//                                     hint: "Select Category",
//                                     dropdownItems: provider.categoryList
//                                         .map((c) => c.categoryName)
//                                         .toSet()
//                                         .toList(),
//                                     onChanged: (String? newValue) {
//                                       if (newValue != null) {
//                                         String selectedName =
//                                             newValue.split(" (")[0];
//                                         var selectedCategory =
//                                             provider.categoryList.firstWhere(
//                                           (c) => c.categoryName == selectedName,
//                                         );

//                                         provider.updateSelectedCategoryId(
//                                             selectedCategory.categoryId);
//                                         provider.selectCategory(
//                                             selectedCategory.categoryName);
//                                         categoryController.text =
//                                             selectedCategory.categoryName;
//                                       }
//                                     },
//                                   );
//                                 },
//                               ),

//                               const SizedBox(height: 10),
//                               MandatoryTextField(
//                                 controller: descriptionController,
//                                 label: 'Product Description',
//                                 isRequired: true,
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'Required';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                               const SizedBox(height: 10),
//                               Consumer<UnitViewmodel>(
//                                 builder: (context, provider, child) {
//                                   return CustomDropdown(
//                                     selectedValue: provider.unitList
//                                             .map((c) => c.unitName)
//                                             .contains(unitController.text)
//                                         ? unitController.text
//                                         : null,
//                                     hint: "Select Unit",
//                                     dropdownItems: provider.unitList
//                                         .map((c) => c.unitName)
//                                         .toSet()
//                                         .toList(),
//                                     onChanged: (String? newValue) {
//                                       if (newValue != null) {
//                                         provider.selectUnit(newValue);
//                                         unitController.text = newValue;
//                                       }
//                                     },
//                                   );
//                                 },
//                               ),

//                               // ------------ unit end -------------

//                               const SizedBox(height: 15),
//                               MandatoryTextField(
//                                 controller: unitPriceController,
//                                 label: 'Unit Price',
//                                 isRequired: true,
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'Required';
//                                   }
//                                   return null;
//                                 },
//                               ),

//                               const SizedBox(height: 10),
//                               MandatoryTextField(
//                                 controller: stockController,
//                                 label: 'Stock',
//                                 isRequired: false,
//                               ),

//                               const SizedBox(height: 10),
//                               MandatoryTextField(
//                                 controller: sgstController,
//                                 label: 'Sgst',
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'Required';
//                                   }
//                                   return null;
//                                 },
//                                 isRequired: true,
//                               ),
//                               const SizedBox(height: 10),
//                               MandatoryTextField(
//                                 controller: cgstController,
//                                 label: 'Sgst',
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'Required';
//                                   }
//                                   return null;
//                                 },
//                                 isRequired: true,
//                               ),
//                               const SizedBox(height: 15),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 15),
//                     Consumer<ProductViewModel>(
//                       builder: (context, provider, child) {
//                         return ColoredCustomButton(
//                           text: widget.isEdit ? "Edit" : "Save",
//                           onPressed: () {
//                             // int? selectedCategoryId =
//                             //     categoryProvider.selectedCategory?.categoryId;

//                             widget.isEdit
//                                 ? provider.editProduct(
//                                     widget.product?.productId,
//                                     nameController.text,
//                                     descriptionController.text,
//                                     unitController.text,
//                                     unitPriceController.text,
//                                     categoryProvider.selectedCategoryId,
//                                     stockController.text,
//                                     sgstController.text,
//                                     cgstController.text,
//                                     context,
//                                   )
//                                 : provider.createProduct(
//                                     nameController.text,
//                                     descriptionController.text,
//                                     unitController.text,
//                                     unitPriceController.text,
//                                     categoryProvider.selectedCategoryId,
//                                     stockController.text,
//                                     sgstController.text,
//                                     cgstController.text,
//                                     context,
//                                   );
//                           },
//                           loading: provider.addProductLoader,
//                           formKey: formKey,
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 15),
//                     const ExitCustomButton(text: "Exit"),
//                     const SizedBox(height: 15),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
