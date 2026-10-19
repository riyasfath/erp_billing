import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/models/data-models/setup/category_model.dart';
import 'package:pokakbilling/models/services/setup/category_services.dart';
import 'package:pokakbilling/views/Screens/SetUp/category/category.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

class CategoryViewmodel extends ChangeNotifier {
  bool createLoading = false;
  bool getCatogoryLoader = false;
  bool deleteCategoryLoader = false;
  bool singleCategoryLoader = false;
  bool editLoading = false;
  var categoryList = <CategoryModel>[];
  var singleCategoryList = <CategoryModel>[];
  String selectedCategory = "";
  int selectedCategoryId = 0;

  CategoryViewmodel() {
    getAllCategory();
  }

  void selectCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  void updateSelectedCategoryId(int categoryId) {
    print("---- hai");
    selectedCategoryId = categoryId;
    notifyListeners();
  }

  Future<void> createCustomer(
    categoryName,
    description,
    BuildContext context,
  ) async {
    try {
      createLoading = true;
      notifyListeners();

      String? response = await CategoryServices.createCategory(
        categoryName,
        description,
      );

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Category Created Successfully!",
        );
        getAllCategory();
        pushAndRemoveUntilFun(context, const CategoryMain());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      createLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAllCategory() async {
    try {
      getCatogoryLoader = true;
      notifyListeners();
      List<CategoryModel> categoryItems =
          await CategoryServices.getAllCategories();

      if (categoryItems.isNotEmpty) {
        categoryList = categoryItems;
      } else {
        categoryList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      getCatogoryLoader = false;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(categoryId, BuildContext context) async {
    try {
      deleteCategoryLoader = true;
      notifyListeners();
      String? response = await CategoryServices.deleteCategory(categoryId);

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Category Deleted Successfully!",
        );
        getAllCategory();
        pushAndRemoveUntilFun(context, const CategoryMain());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      deleteCategoryLoader = false;
      notifyListeners();
    }
  }

  Future<void> getCategoryById(categoryId) async {
    try {
      singleCategoryLoader = true;
      notifyListeners();
      List<CategoryModel> categoryItems =
          await CategoryServices.getCategoryById(categoryId);

      if (categoryItems.isNotEmpty) {
        singleCategoryList = categoryItems;
      } else {
        singleCategoryList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      singleCategoryLoader = false;
      notifyListeners();
    }
  }

  Future<void> editCategory(
    categoryId,
    categoryName,
    categoryDescription,
    BuildContext context,
  ) async {
    try {
      editLoading = true;
      notifyListeners();

      String? response = await CategoryServices.editCategory(
        categoryId,
        categoryName,
        categoryDescription,
      );

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Category information has been successfully updated!",
        );
        getAllCategory();
        pushAndRemoveUntilFun(context, const CategoryMain());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      editLoading = false;
      notifyListeners();
    }
  }
}
