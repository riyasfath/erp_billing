// import 'package:ecommerce_app/core/api_client.dart';
import 'package:ecommerce_app/core/api_client.dart';
import 'package:ecommerce_app/core/providers.dart';
import 'package:ecommerce_app/models/cart_model.dart';

/// Network calls for the cart: get, add, update quantity, remove.
/// add/update/remove each re-fetch the full cart afterward so
/// CartViewModel always has the authoritative server state — your
/// /add/ and /update/ endpoints weren't confirmed to return the full
/// cart themselves, so this is the safe default.
class CartService {
  final ApiClient _apiClient;

  CartService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<CartModel> getCart() async {
    final data = await _apiClient.get(ApiEndpoints.cart);
    return CartModel.fromJson(data);
  }

  Future<CartModel> addToCart(AddToCartModel model) async {
    await _apiClient.post(ApiEndpoints.cartAdd, model.toJson());
    return getCart();
  }

  Future<CartModel> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) async {
    await _apiClient.put(ApiEndpoints.cartUpdate(cartItemId), {'quantity': quantity});
    return getCart();
  }

  Future<CartModel> removeCartItem(String cartItemId) async {
    await _apiClient.delete(ApiEndpoints.cartRemove(cartItemId));
    return getCart();
  }

  Future<CartModel> selectAddress(String addressId) async {
    final id = int.tryParse(addressId);
    await _apiClient.post(ApiEndpoints.cartSelectAddress, {'address_id': id ?? addressId});
    return getCart();
  }
}