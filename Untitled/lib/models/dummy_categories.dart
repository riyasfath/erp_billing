import 'package:flutter/material.dart';
import 'package:ecommerce_app/models/category_model.dart';
import 'package:ecommerce_app/models/product_model.dart';

/// Sample/mock data for the "All Categories" flow — swap for your real
/// API/database later. Product previews reuse the same 3 sample shoe
/// images already in the project since this is a sneaker storefront;
/// only 'men' / 'women' / 'kids' have real filterable products today.

const List<CategoryModel> categories = [
  CategoryModel(
    id: 'men',
    name: 'For Men',
    icon: Icons.male_rounded,
    iconBg: Color(0xFF3B82F6),
    productCount: 3280,
    reviewCount: 52000,
    rating: 4.7,
    filterValue: 'men',
  ),
  CategoryModel(
    id: 'women',
    name: 'For Women',
    icon: Icons.female_rounded,
    iconBg: Color(0xFFEC4899),
    productCount: 2860,
    reviewCount: 41200,
    rating: 4.8,
    filterValue: 'women',
  ),
  CategoryModel(
    id: 'kids',
    name: 'For Kids',
    icon: Icons.child_care_rounded,
    iconBg: Color(0xFFF59E0B),
    productCount: 1540,
    reviewCount: 22300,
    rating: 4.6,
    filterValue: 'kids',
  ),
  CategoryModel(
    id: 'electronics',
    name: 'Electronics & Gadgets',
    icon: Icons.devices_other_rounded,
    iconBg: Color(0xFF10B981),
    productCount: 2140,
    reviewCount: 38500,
    rating: 4.6,
    filterValue: 'electronics',
  ),
  CategoryModel(
    id: 'beauty',
    name: 'Beauty & Personal Care',
    icon: Icons.spa_rounded,
    iconBg: Color(0xFFEF6F5B),
    productCount: 1870,
    reviewCount: 45200,
    rating: 4.7,
    filterValue: 'beauty',
  ),
];

// Product grid shown on CategoryProductsScreen for each category id.
final Map<String, List<ProductModel>> categoryProductsMap = {
  'men': List.generate(
    6,
    (i) => ProductModel(
      id: 'cat_men_af1_$i',
      name: "Nike Air Force 1 '07 - White",
      brand: 'NIKE',
      price: 110.00,
      rating: 4.9,
      reviewCount: 860,
      imagePath: 'assets/images/shoe${(i % 3) + 1}.png',
      category: 'men',
    ),
  ),
  'women': List.generate(
    6,
    (i) => ProductModel(
      id: 'cat_women_nb574_$i',
      name: 'New Balance 574 Core Sneakers',
      brand: 'NEW BALANCE',
      price: 95.00,
      rating: 4.9,
      reviewCount: 540,
      imagePath: 'assets/images/shoe${(i % 3) + 1}.png',
      category: 'women',
    ),
  ),
  'kids': List.generate(
    6,
    (i) => ProductModel(
      id: 'cat_kids_am270_$i',
      name: 'Nike Air Max 270',
      brand: 'NIKE',
      price: 130.00,
      rating: 4.7,
      reviewCount: 410,
      imagePath: 'assets/images/shoe${(i % 3) + 1}.png',
      category: 'kids',
    ),
  ),
  'electronics': List.generate(
    6,
    (i) => ProductModel(
      id: 'cat_elec_$i',
      name: 'Placeholder Gadget Item',
      brand: 'GENERIC',
      price: 59.00,
      rating: 4.4,
      reviewCount: 120,
      imagePath: 'assets/images/shoe${(i % 3) + 1}.png',
      category: 'electronics',
    ),
  ),
  'beauty': List.generate(
    6,
    (i) => ProductModel(
      id: 'cat_beauty_$i',
      name: 'Placeholder Care Item',
      brand: 'GENERIC',
      price: 24.00,
      rating: 4.5,
      reviewCount: 95,
      imagePath: 'assets/images/shoe${(i % 3) + 1}.png',
      category: 'beauty',
    ),
  ),
};