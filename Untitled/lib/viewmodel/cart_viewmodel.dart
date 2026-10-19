import 'package:flutter/foundation.dart';

import 'package:ecommerce_app/core/api_exception.dart';
import 'package:ecommerce_app/core/view_status.dart';
import 'package:ecommerce_app/models/cart_model.dart';
import 'package:ecommerce_app/service/cart_service.dart';

class CartViewModel extends ChangeNotifier {
  final CartService _cartService;

  CartViewModel({CartService? cartService})
      : _cartService = cartService ?? CartService();

  ViewStatus status = ViewStatus.idle;
  String? error;
  CartModel cart = CartModel.empty();

  bool isAdding = false;
  String? addError;

  final Set<String> _updatingIds = {};
  final Set<String> _removingIds = {};

  // Selection for "Select All" / checkout — client-side only, the API
  // has no concept of it. Tracked by INDEX in the items list rather
  // than cartItemId — if the backend's item id ever comes back
  // empty/duplicate for more than one item (unconfirmed against a real
  // filled cart response), string-keyed selection would make selecting
  // one item accidentally select every item sharing that id. Index is
  // always unique regardless of what the id field turns out to be.
  final Set<int> _selectedIndexes = {};

  bool get isLoading => status == ViewStatus.loading;
  List<CartItemModel> get items => cart.items;
  bool isUpdating(String cartItemId) => _updatingIds.contains(cartItemId);
  bool isRemoving(String cartItemId) => _removingIds.contains(cartItemId);
  bool isSelectedAt(int index) => _selectedIndexes.contains(index);
  bool get allSelected => items.isNotEmpty && _selectedIndexes.length == items.length;

  List<CartItemModel> get selectedItems => [
        for (int i = 0; i < items.length; i++)
          if (_selectedIndexes.contains(i)) items[i]
      ];
  double get selectedTotal =>
      selectedItems.fold(0, (sum, i) => sum + i.subtotal);

  Future<void> fetchCart() async {
    status = ViewStatus.loading;
    error = null;
    notifyListeners();

    try {
      cart = await _cartService.getCart();
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

  Future<bool> addToCart({
    required String productId,
    required int quantity,
    required String size,
    required String color,
  }) async {
    final int? id = int.tryParse(productId);
    if (id == null) {
      addError = 'Invalid product.';
      notifyListeners();
      return false;
    }

    isAdding = true;
    addError = null;
    notifyListeners();

    try {
      final model = AddToCartModel(productId: id, quantity: quantity, size: size, color: color);
      cart = await _cartService.addToCart(model);
      isAdding = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      isAdding = false;
      addError = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      isAdding = false;
      addError = 'Could not add this item to your cart. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateQuantity(String cartItemId, int quantity) async {
    if (quantity < 1) return false;

    _updatingIds.add(cartItemId);
    notifyListeners();

    try {
      cart = await _cartService.updateCartItem(cartItemId: cartItemId, quantity: quantity);
      _updatingIds.remove(cartItemId);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _updatingIds.remove(cartItemId);
      error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _updatingIds.remove(cartItemId);
      error = 'Could not update the quantity. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeItem(String cartItemId) async {
    _removingIds.add(cartItemId);
    notifyListeners();

    try {
      cart = await _cartService.removeCartItem(cartItemId);
      // Indexes shift after a removal — clearing selection is simpler
      // and safer than trying to remap old indexes onto the new list.
      _selectedIndexes.clear();
      _removingIds.remove(cartItemId);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _removingIds.remove(cartItemId);
      error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _removingIds.remove(cartItemId);
      error = 'Could not remove this item. Please try again.';
      notifyListeners();
      return false;
    }
  }

  bool isSelectingAddress = false;
  String? selectAddressError;

  Future<bool> selectAddress(String addressId) async {
    isSelectingAddress = true;
    selectAddressError = null;
    notifyListeners();

    try {
      cart = await _cartService.selectAddress(addressId);
      isSelectingAddress = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      isSelectingAddress = false;
      selectAddressError = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      isSelectingAddress = false;
      selectAddressError = 'Could not select this address. Please try again.';
      notifyListeners();
      return false;
    }
  }

  void toggleSelectAt(int index) {
    if (_selectedIndexes.contains(index)) {
      _selectedIndexes.remove(index);
    } else {
      _selectedIndexes.add(index);
    }
    notifyListeners();
  }

  void toggleSelectAll(bool selectAll) {
    _selectedIndexes
      ..clear()
      ..addAll(selectAll ? List.generate(items.length, (i) => i) : const Iterable.empty());
    notifyListeners();
  }

  /// Wipes every bit of state back to a fresh install — called on
  /// logout so the next person to log in on this device never sees a
  /// leftover cart from the previous user.
  void reset() {
    cart = CartModel.empty();
    status = ViewStatus.idle;
    error = null;
    isAdding = false;
    addError = null;
    _updatingIds.clear();
    _removingIds.clear();
    _selectedIndexes.clear();
    isSelectingAddress = false;
    selectAddressError = null;
    notifyListeners();
  }
}