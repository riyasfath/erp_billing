import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/marketing_model/category.dart';
import 'package:pokakbilling/models/services/categoryList_service.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

class CategoryMarketingViewmodel extends ChangeNotifier {
  List<CategoryMarketing> _categories = [];
  bool _isLoading = false;
  bool _addCategoryLoading = false;
  bool _editCategoryLoading = false;
  bool _deleteCategoryLoading = false;
  String? _errorMessage;
  bool _disposed = false;

  List<CategoryMarketing> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get addCategoryLoading => _addCategoryLoading;
  bool get editCategoryLoading => _editCategoryLoading;
  bool get deleteCategoryLoading => _deleteCategoryLoading;
  String? get errorMessage => _errorMessage;

  CategoryMarketingViewmodel() {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    if (_disposed) return;

    _isLoading = true;
    _safeNotifyListeners();

    try {
      final fetchedCategories = await CategoryMarketingServices.getCategories();

      if (!_disposed) {
        _categories = fetchedCategories;
        _errorMessage = null;
      }
    } catch (e) {
      if (!_disposed) {
        _errorMessage = e.toString();
        _categories = [];
      }
    }

    if (!_disposed) {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // CREATE - Add new category
  Future<void> createCategory(
      String name, int source, BuildContext context) async {
    if (_disposed) return;

    try {
      _addCategoryLoading = true;
      _safeNotifyListeners();

      String? response =
          await CategoryMarketingServices.createCategory(name, source);

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Category Created Successfully!",
        );
        await fetchCategories();
        Navigator.pop(context, true);
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
      if (!_disposed && context.mounted) {
        showOverlayError(context, "Failed to create category");
      }
    } finally {
      if (!_disposed) {
        _addCategoryLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  // UPDATE - Edit existing category
  Future<void> editCategory(
      int categoryId, String name, int source, BuildContext context) async {
    if (_disposed) return;

    try {
      _editCategoryLoading = true;
      _safeNotifyListeners();

      String? response = await CategoryMarketingServices.updateCategory(
          categoryId, name, source);

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Category Updated Successfully!",
        );
        await fetchCategories();
        Navigator.pop(context, true);
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
      if (!_disposed && context.mounted) {
        showOverlayError(context, "Failed to update category");
      }
    } finally {
      if (!_disposed) {
        _editCategoryLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  // DELETE - Remove category
  Future<void> deleteCategory(int categoryId, BuildContext context) async {
    if (_disposed) return;

    try {
      _deleteCategoryLoading = true;
      _safeNotifyListeners();

      String? response =
          await CategoryMarketingServices.deleteCategory(categoryId);

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Category Deleted Successfully!",
        );
        await fetchCategories();
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
      if (!_disposed && context.mounted) {
        showOverlayError(context, "Failed to delete category");
      }
    } finally {
      if (!_disposed) {
        _deleteCategoryLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  // Clear error message
  void clearError() {
    if (!_disposed) {
      _errorMessage = null;
      _safeNotifyListeners();
    }
  }

  // Safe notify listeners method
  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
