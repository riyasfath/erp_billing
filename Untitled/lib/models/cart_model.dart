import 'adress_model.dart';

/// A single line item in the cart, as returned inside /api/cart/'s
/// `items` array.
///
/// PARSING NOTE: your /api/cart/ sample had an empty `items: []`, so the
/// exact field names for a FILLED item aren't confirmed yet. This reads
/// several common DRF naming patterns defensively (nested `product`
/// object vs flat fields, `unit_price` vs `price`, etc). Once you add a
/// real item and share that response, tell me and I'll tighten this to
/// match exactly — until then, some fields may come back empty/zero
/// even though the item exists.
class CartItemModel {
  final String cartItemId; // this cart item's own id — used for update/remove
  final String productId; // the underlying product's id
  final String name;
  final String size;
  final String color;
  final double price;
  final String imagePath;
  int quantity;

  /// Selection for the "Select All" checkout flow — purely client-side
  /// UI state, the cart API has no concept of it.
  bool selected;

  CartItemModel({
    required this.cartItemId,
    required this.productId,
    required this.name,
    required this.size,
    required this.color,
    required this.price,
    required this.imagePath,
    this.quantity = 1,
    this.selected = false,
  });

  double get subtotal => price * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? product = json['product'] is Map<String, dynamic>
        ? json['product'] as Map<String, dynamic>
        : null;

    final String cartItemId = json['id']?.toString() ?? '';

    final String productId = product != null
        ? (product['id']?.toString() ?? '')
        : (json['product']?.toString() ?? json['product_id']?.toString() ?? '');

    final String name = product?['name']?.toString() ??
        json['product_name']?.toString() ??
        json['name']?.toString() ??
        '';

    final List<dynamic> images = product != null
        ? ((product['images'] as List?) ?? [])
        : ((json['images'] as List?) ?? []);
    final String image = images.isNotEmpty
        ? (images.first is Map ? (images.first['image']?.toString() ?? '') : images.first.toString())
        : (json['image']?.toString() ?? '');

    final double price = double.tryParse(
          (json['price'] ??
                  json['unit_price'] ??
                  product?['discount_price'] ??
                  product?['price'] ??
                  '0')
              .toString(),
        ) ??
        0;

    final int quantity = json['quantity'] is int
        ? json['quantity'] as int
        : int.tryParse(json['quantity']?.toString() ?? '') ?? 1;

    return CartItemModel(
      cartItemId: cartItemId,
      productId: productId,
      name: name,
      size: json['size']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      price: price,
      imagePath: image,
      quantity: quantity,
    );
  }
}

/// The full /api/cart/ response.
class CartModel {
  final String id;
  final List<CartItemModel> items;
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;
  final AddressModel? address;

  CartModel({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
    this.address,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsJson = (json['items'] as List?) ?? [];
    return CartModel(
      id: json['id']?.toString() ?? '',
      items: itemsJson
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '') ?? 0,
      shipping: double.tryParse(json['shipping']?.toString() ?? '') ?? 0,
      tax: double.tryParse(json['tax']?.toString() ?? '') ?? 0,
      total: double.tryParse(json['total']?.toString() ?? '') ?? 0,
      address: json['address'] is Map<String, dynamic>
          ? AddressModel.fromJson(json['address'] as Map<String, dynamic>)
          : null,
    );
  }

  factory CartModel.empty() => CartModel(id: '', items: [], subtotal: 0, shipping: 0, tax: 0, total: 0);
}

/// Data sent to /api/cart/add/.
class AddToCartModel {
  final int productId;
  final int quantity;
  final String size;
  final String color;

  AddToCartModel({
    required this.productId,
    required this.quantity,
    required this.size,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
        'product': productId,
        'quantity': quantity,
        'size': size,
        'color': color,
      };
}