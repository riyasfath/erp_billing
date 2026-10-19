import 'package:ecommerce_app/models/catgeroy_api_model.dart';
import 'package:flutter/foundation.dart';

import 'package:ecommerce_app/core/api_exception.dart';
import 'package:ecommerce_app/core/view_status.dart';
import 'package:ecommerce_app/service/category_service.dart';

class CategoryViewModel extends ChangeNotifier {
  final CategoryService _categoryService;

  CategoryViewModel({CategoryService? categoryService})
      : _categoryService = categoryService ?? CategoryService();

  ViewStatus status = ViewStatus.idle;
  String? error;
  List<CategoryApiModel> categories = [];

  bool get isLoading => status == ViewStatus.loading;

  Future<void> fetchCategories() async {
    status = ViewStatus.loading;
    error = null;
    notifyListeners();

    try {
      categories = await _categoryService.getCategories();
      status = ViewStatus.success;
    } on ApiException catch (e) {
      status = ViewStatus.error;
      error = e.message;
    } catch (_) {
      status = ViewStatus.error;
      error = 'Something went wrong. Please try again.';
    }

    notifyListeners();
  }
}