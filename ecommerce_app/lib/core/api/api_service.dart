import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_urls.dart';
import '../../models/product_model.dart';

class ApiService {
  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse(AppUrls.products));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load products");
    }
  }
}
