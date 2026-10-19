import 'package:ecommerce_app/models/product_model.dart';

/// Sample/mock data — swap for your real API/database later.
/// imagePath values point at your real assets (assets/images/shoe1.png,
/// shoe2.png, shoe3.png) — cycled since there are only 3 sample images.

const List<ProductModel> recentlyViewed = [
  ProductModel(
    id: 'nike_club_max',
    name: 'Nike Club Max',
    brand: 'NIKE',
    price: 89.99,
    oldPrice: 100.99,
    rating: 4.9,
    reviewCount: 3240,
    imagePath: 'assets/images/shoe1.png',
  ),
  ProductModel(
    id: 'nike_air_zoom',
    name: 'Nike Air Zoom',
    brand: 'NIKE',
    price: 109.99,
    rating: 4.7,
    reviewCount: 1180,
    imagePath: 'assets/images/shoe2.png',
  ),
  ProductModel(
    id: 'adidas_runner',
    name: 'Adidas Runner',
    brand: 'ADIDAS',
    price: 99.99,
    rating: 4.6,
    reviewCount: 860,
    imagePath: 'assets/images/shoe3.png',
  ),
];

// Home dashboard "New Arrivals" — exactly the 2 cards shown in the Figma
// (no text badge on the card itself, just the section title).
const List<ProductModel> newArrivals = [
  ProductModel(
    id: 'jordan1_retro_1',
    name: 'Air Jordan 1 Retro High',
    brand: 'JORDAN',
    price: 139.00,
    oldPrice: 180.00,
    rating: 4.8,
    imagePath: 'assets/images/shoe1.png',
    category: 'men',
  ),
  ProductModel(
    id: 'jordan1_retro_2',
    name: 'Air Jordan 1 Retro High',
    brand: 'JORDAN',
    price: 139.00,
    oldPrice: 180.00,
    rating: 4.8,
    imagePath: 'assets/images/shoe2.png',
    category: 'women',
  ),
];

// NOTE: "Best Seller Deals" intentionally has NO product list.
// In the real Figma that section is just the "Beyond The Limit"
// featured banner — there is no bestSellerDeals grid anymore.

const List<ProductModel> mostPopular = [
  ProductModel(
    id: 'nike_air_max_270_1',
    name: 'Nike Air Max 270',
    brand: 'NIKE',
    price: 180.00,
    rating: 4.7,
    imagePath: 'assets/images/shoe3.png',
    category: 'men',
  ),
  ProductModel(
    id: 'nike_air_max_270_2',
    name: 'Nike Air Max 270',
    brand: 'NIKE',
    price: 180.00,
    rating: 4.7,
    imagePath: 'assets/images/shoe1.png',
    category: 'kids',
  ),
];

// "Search & Results" screen data — matches the Shop tab grid exactly.
const List<ProductModel> searchResults = [
  ProductModel(
    id: 'search_jordan1_low_g',
    name: 'Air Jordan 1 Low G',
    brand: 'JORDAN',
    price: 140.00,
    rating: 4.8,
    badge: 'New Arrival',
    imagePath: 'assets/images/shoe1.png',
    category: 'men',
  ),
  ProductModel(
    id: 'search_nike_pegasus_40',
    name: 'Nike Pegasus 40',
    brand: 'NIKE',
    price: 130.00,
    rating: 4.5,
    badge: 'Best Seller',
    imagePath: 'assets/images/shoe2.png',
    category: 'women',
  ),
  ProductModel(
    id: 'search_adidas_ultraboost',
    name: 'Adidas Ultraboost',
    brand: 'ADIDAS',
    price: 190.00,
    rating: 4.7,
    imagePath: 'assets/images/shoe3.png',
    category: 'men',
  ),
  ProductModel(
    id: 'search_nb_9060',
    name: 'New Balance 9060',
    brand: 'NEW BALANCE',
    price: 150.00,
    rating: 4.9,
    badge: 'Trending',
    imagePath: 'assets/images/shoe1.png',
    category: 'kids',
  ),
];

// ----- "View All" pages data -----

// New Arrivals -> Flash Sale style page
const List<ProductModel> flashSaleLatestDeals = [
  ProductModel(
    id: 'flash_ultraboost_1',
    name: 'Adidas Ultraboost 22 – Core Black / Women\'s',
    brand: 'ADIDAS',
    price: 149.00,
    oldPrice: 190.00,
    rating: 4.9,
    imagePath: 'assets/images/shoe3.png',
    soldCount: 28,
    totalStock: 30,
  ),
  ProductModel(
    id: 'flash_ultraboost_2',
    name: 'Adidas Ultraboost 22 – Core Black / Women\'s',
    brand: 'ADIDAS',
    price: 149.00,
    oldPrice: 190.00,
    rating: 4.9,
    imagePath: 'assets/images/shoe1.png',
    soldCount: 28,
    totalStock: 30,
  ),
  ProductModel(
    id: 'flash_ultraboost_3',
    name: 'Adidas Ultraboost 22 – Core Black / Women\'s',
    brand: 'ADIDAS',
    price: 149.00,
    oldPrice: 190.00,
    rating: 4.9,
    imagePath: 'assets/images/shoe2.png',
    soldCount: 28,
    totalStock: 30,
  ),
];

const List<ProductModel> flashSaleOtherDeals = [
  ProductModel(
    id: 'flash_reebok_1',
    name: 'Reebok Club C 85 – Chalk / Glen Green',
    brand: 'REEBOK',
    price: 62.00,
    oldPrice: 85.00,
    rating: 4.6,
    imagePath: 'assets/images/shoe1.png',
    soldCount: 23,
    totalStock: 30,
  ),
  ProductModel(
    id: 'flash_reebok_2',
    name: 'Reebok Club C 85 – Chalk / Glen Green',
    brand: 'REEBOK',
    price: 62.00,
    oldPrice: 85.00,
    rating: 4.6,
    imagePath: 'assets/images/shoe2.png',
    soldCount: 23,
    totalStock: 30,
  ),
  ProductModel(
    id: 'flash_reebok_3',
    name: 'Reebok Club C 85 – Chalk / Glen Green',
    brand: 'REEBOK',
    price: 62.00,
    oldPrice: 85.00,
    rating: 4.6,
    imagePath: 'assets/images/shoe3.png',
    soldCount: 23,
    totalStock: 30,
  ),
  ProductModel(
    id: 'flash_reebok_4',
    name: 'Reebok Club C 85 – Chalk / Glen Green',
    brand: 'REEBOK',
    price: 62.00,
    oldPrice: 85.00,
    rating: 4.6,
    imagePath: 'assets/images/shoe1.png',
    soldCount: 23,
    totalStock: 30,
  ),
];

// Best Seller Deals -> "Our Best Seller" page
const List<ProductModel> bestSellerToday = [
  ProductModel(
    id: 'best_ultraboost_1',
    name: 'Adidas Ultraboost 22 – Core Black / Women\'s',
    brand: 'ADIDAS',
    price: 149.00,
    oldPrice: 190.00,
    rating: 4.9,
    imagePath: 'assets/images/shoe2.png',
    soldCount: 28,
    totalStock: 30,
  ),
  ProductModel(
    id: 'best_ultraboost_2',
    name: 'Adidas Ultraboost 22 – Core Black / Women\'s',
    brand: 'ADIDAS',
    price: 149.00,
    oldPrice: 190.00,
    rating: 4.9,
    imagePath: 'assets/images/shoe3.png',
    soldCount: 28,
    totalStock: 30,
  ),
];

const List<ProductModel> bestSellerOther = [
  ProductModel(
    id: 'best_reebok_1',
    name: 'Reebok Club C 85 – Chalk / Glen Green',
    brand: 'REEBOK',
    price: 62.00,
    oldPrice: 85.00,
    rating: 4.6,
    imagePath: 'assets/images/shoe1.png',
    soldCount: 23,
    totalStock: 30,
  ),
  ProductModel(
    id: 'best_reebok_2',
    name: 'Reebok Club C 85 – Chalk / Glen Green',
    brand: 'REEBOK',
    price: 62.00,
    oldPrice: 85.00,
    rating: 4.6,
    imagePath: 'assets/images/shoe2.png',
    soldCount: 23,
    totalStock: 30,
  ),
  ProductModel(
    id: 'best_reebok_3',
    name: 'Reebok Club C 85 – Chalk / Glen Green',
    brand: 'REEBOK',
    price: 62.00,
    oldPrice: 85.00,
    rating: 4.6,
    imagePath: 'assets/images/shoe3.png',
    soldCount: 23,
    totalStock: 30,
  ),
  ProductModel(
    id: 'best_reebok_4',
    name: 'Reebok Club C 85 – Chalk / Glen Green',
    brand: 'REEBOK',
    price: 62.00,
    oldPrice: 85.00,
    rating: 4.6,
    imagePath: 'assets/images/shoe1.png',
    soldCount: 23,
    totalStock: 30,
  ),
];

// Most Popular -> "Our Popular Product" page (plain, no sold badge)
const List<ProductModel> popularThisWeek = [
  ProductModel(
    id: 'popular_nb530_1',
    name: 'New Balance 530 – White/Silver',
    brand: 'NEW BALANCE',
    price: 99.00,
    rating: 4.7,
    imagePath: 'assets/images/shoe1.png',
  ),
  ProductModel(
    id: 'popular_nb530_2',
    name: 'New Balance 530 – White/Silver',
    brand: 'NEW BALANCE',
    price: 99.00,
    rating: 4.7,
    imagePath: 'assets/images/shoe2.png',
  ),
];

const List<ProductModel> otherPopularProduct = [
  ProductModel(
    id: 'popular_af1_1',
    name: 'Nike Air Force 1 \'07 - White',
    brand: 'NIKE',
    price: 110.00,
    rating: 4.9,
    imagePath: 'assets/images/shoe3.png',
  ),
  ProductModel(
    id: 'popular_af1_2',
    name: 'Nike Air Force 1 \'07 - White',
    brand: 'NIKE',
    price: 110.00,
    rating: 4.9,
    imagePath: 'assets/images/shoe1.png',
  ),
  ProductModel(
    id: 'popular_af1_3',
    name: 'Nike Air Force 1 \'07 - White',
    brand: 'NIKE',
    price: 110.00,
    rating: 4.9,
    imagePath: 'assets/images/shoe2.png',
  ),
  ProductModel(
    id: 'popular_af1_4',
    name: 'Nike Air Force 1 \'07 - White',
    brand: 'NIKE',
    price: 110.00,
    rating: 4.9,
    imagePath: 'assets/images/shoe3.png',
  ),
];

// Special For You -> "Special For You" full page (plain, no sold badge)
const List<ProductModel> onlyForYou = [
  ProductModel(
    id: 'onlyforyou_dunk_1',
    name: 'Nike Dunk Low Retro – White/Black Panda',
    brand: 'NIKE',
    price: 110.00,
    rating: 4.8,
    imagePath: 'assets/images/shoe1.png',
  ),
  ProductModel(
    id: 'onlyforyou_dunk_2',
    name: 'Nike Dunk Low Retro – White/Black Panda',
    brand: 'NIKE',
    price: 110.00,
    rating: 4.8,
    imagePath: 'assets/images/shoe2.png',
  ),
];

const List<ProductModel> otherSpecialOffer = [
  ProductModel(
    id: 'special_dunk_1',
    name: 'Nike Dunk Low Retro – White/Black Panda',
    brand: 'NIKE',
    price: 110.00,
    rating: 4.8,
    imagePath: 'assets/images/shoe3.png',
  ),
  ProductModel(
    id: 'special_dunk_2',
    name: 'Nike Dunk Low Retro – White/Black Panda',
    brand: 'NIKE',
    price: 110.00,
    rating: 4.8,
    imagePath: 'assets/images/shoe1.png',
  ),
  ProductModel(
    id: 'special_dunk_3',
    name: 'Nike Dunk Low Retro – White/Black Panda',
    brand: 'NIKE',
    price: 110.00,
    rating: 4.8,
    imagePath: 'assets/images/shoe2.png',
  ),
  ProductModel(
    id: 'special_dunk_4',
    name: 'Nike Dunk Low Retro – White/Black Panda',
    brand: 'NIKE',
    price: 110.00,
    rating: 4.8,
    imagePath: 'assets/images/shoe3.png',
  ),
];

const List<ProductModel> specialForYou = [
  ProductModel(
    id: 'nb574_1',
    name: 'New Balance 574 Core Sneakers',
    brand: 'NEW BALANCE',
    price: 95.00,
    rating: 4.9,
    imagePath: 'assets/images/shoe2.png',
    category: 'women',
  ),
  ProductModel(
    id: 'nb574_2',
    name: 'New Balance 574 Core Sneakers',
    brand: 'NEW BALANCE',
    price: 95.00,
    rating: 4.9,
    imagePath: 'assets/images/shoe3.png',
    category: 'men',
  ),
];