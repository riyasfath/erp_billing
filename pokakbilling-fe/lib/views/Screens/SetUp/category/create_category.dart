import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/models/data-models/setup/category_model.dart';
import 'package:pokakbilling/viewmodels/setup/category_viewmodel.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/exit_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/cancel_custom_button.dart';
import 'package:provider/provider.dart';

class CreateCategory extends StatefulWidget {
  final bool isEdit;
  final CategoryModel? category;
  const CreateCategory({super.key, required this.isEdit, this.category});

  @override
  State<CreateCategory> createState() => _CreateCategoryState();
}

class _CreateCategoryState extends State<CreateCategory> {
  late TextEditingController categorynameController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    categorynameController =
        TextEditingController(text: widget.category?.categoryName ?? '');
    descriptionController =
        TextEditingController(text: widget.category?.categoryDescription ?? '');
  }

  @override
  void dispose() {
    categorynameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 150,
                decoration: const BoxDecoration(
                  color: AppColors.violetblue,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: AppBar(
                    leading: IconButton(
                      icon: Image.asset(AppAssets.homeIcon),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ErpBottomBar(index: 0),
                          ),
                        );
                      },
                    ),
                    title: Text(
                      widget.isEdit ? 'Edit Category' : 'Create Category',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 120,
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      color: AppColors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Form(
                        key: formKey,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: categorynameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'required';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Category Name',
                                  hintText: "",
                                  labelStyle: TextStyle(
                                    color: AppColors.violetblue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: descriptionController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'required';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                  hintText: "",
                                  labelStyle: TextStyle(
                                    color: AppColors.violetblue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 120),
                    Consumer<CategoryViewmodel>(
                      builder: (context, provider, child) {
                        return ColoredCustomButton(
                          text: widget.isEdit ? "Edit" : "Save",
                          onPressed: () async {
                            widget.isEdit
                                ? await provider.editCategory(
                                    widget.category?.categoryId,
                                    categorynameController.text,
                                    descriptionController.text,
                                    context,
                                  )
                                : await provider.createCustomer(
                                    categorynameController.text,
                                    descriptionController.text,
                                    context,
                                  );
                          },
                          loading: widget.isEdit
                              ? provider.editLoading
                              : provider.createLoading,
                          formKey: formKey,
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const ExitCustomButton(
                      text: "Exit",
                    ),
                    const SizedBox(height: 20),
                    const CancelCustomButton(
                      text: "Back",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
