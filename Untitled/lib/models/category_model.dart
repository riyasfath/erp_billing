import 'package:ecommerce_app/models/catgeroy_api_model.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/app_colors.dart';
import 'product_model.dart';

/// Data model for a category row shown on the "All Categories" page.
/// [filterValue] should match the `category` field used on ProductModel
/// (e.g. 'men', 'women', 'kids') so the products grid can filter by it.
///
/// The API only gives id + name — no icon, no color, no image. Rather
/// than guess an icon/color per category NAME (brittle — breaks for
/// any category the guess-map doesn't know about), [icon]/[iconBg] are
/// now just a single consistent app-wide style, and category identity
/// on screen comes from [heroImage] — a REAL photo of one of that
/// category's actual products — instead of any invented visual.
class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final Color iconBg;
  final int productCount;
  final int reviewCount;
  final double rating;
  final String filterValue;

  /// A real product image from this category (network URL), or null if
  /// the category currently has no products with an image. NEVER a
  /// placeholder/stock image — only actual API data.
  final String? heroImage;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.iconBg,
    required this.productCount,
    required this.reviewCount,
    required this.rating,
    required this.filterValue,
    this.heroImage,
  });

  /// Builds a display-ready CategoryModel from the raw API category plus
  /// the already-fetched product list — [allProducts] is filtered by
  /// `categoryName` to compute productCount/reviewCount/average rating
  /// AND to pick a real product photo to represent the category.
  factory CategoryModel.fromApi(CategoryApiModel api, List<ProductModel> allProducts) {
    final String key = api.name.toLowerCase();
    final matching = allProducts
        .where((p) => p.categoryName.toLowerCase() == key)
        .toList();

    final int reviewTotal = matching.fold<int>(0, (sum, p) => sum + (p.reviewCount ?? 0));
    final double avgRating = matching.isEmpty
        ? 0
        : matching.map((p) => p.rating).reduce((a, b) => a + b) / matching.length;

    final String realImage = matching
        .map((p) => p.imagePath)
        .firstWhere((path) => path.isNotEmpty, orElse: () => '');

    return CategoryModel(
      id: api.id.toString(),
      name: api.name,
      icon: Icons.local_offer_rounded,
      iconBg: AppColors.primaryBlue,
      productCount: matching.length,
      reviewCount: reviewTotal,
      rating: double.parse(avgRating.toStringAsFixed(1)),
      filterValue: key,
      heroImage: realImage.isNotEmpty ? realImage : null,
    );
  }
}