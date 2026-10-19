import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/app_colors.dart';
import 'package:ecommerce_app/models/cart_model.dart';
import 'package:ecommerce_app/viewmodel/cart_viewmodel.dart';
import 'package:ecommerce_app/views/screens/checkout/checkout_screen.dart';

/// The "My Cart" tab — now backed by the real cart API (GET/add/update/
/// remove) via CartViewModel instead of a cartItems list passed down
/// from a parent widget. [onBrowseProducts]/[onGoToWishlist] stay
/// optional callbacks so whatever hosts this tab can still wire up
/// "switch to the Shop tab" — if left null, a SnackBar nudges the user
/// instead.
class CartScreen extends StatefulWidget {
  final VoidCallback? onBrowseProducts;
  final VoidCallback? onGoToWishlist;

  const CartScreen({
    super.key,
    this.onBrowseProducts,
    this.onGoToWishlist,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartViewModel>().fetchCart();
    });
  }

  bool _isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  void _showSnack(String message, {bool isError = false, IconData icon = Icons.check_circle}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppColors.badgeRed : const Color(0xFF16A34A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(milliseconds: 1600),
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkout(BuildContext context, CartViewModel viewModel) {
    if (viewModel.selectedItems.isEmpty) {
      _showSnack('Select at least one item to checkout', isError: true, icon: Icons.error_outline);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CheckoutScreen(items: viewModel.selectedItems)),
    );
  }

  Future<void> _updateQuantity(CartViewModel viewModel, CartItemModel item, int newQuantity) async {
    if (newQuantity < 1) return;
    final success = await viewModel.updateQuantity(item.cartItemId, newQuantity);
    if (!success && mounted) {
      _showSnack(viewModel.error ?? 'Could not update quantity', isError: true, icon: Icons.error_outline);
    }
  }

  Future<void> _removeItem(CartViewModel viewModel, CartItemModel item) async {
    final success = await viewModel.removeItem(item.cartItemId);
    if (!mounted) return;
    if (success) {
      _showSnack('${item.name} removed from cart', icon: Icons.delete_outline);
    } else {
      _showSnack(viewModel.error ?? 'Could not remove this item', isError: true, icon: Icons.error_outline);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CartViewModel>();
    final bool landscape = _isLandscape(context);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            // Reduced vertical padding in landscape — was a fixed 16
            // on both sides, part of what pushed content below the
            // fold when the available height shrinks.
            padding: EdgeInsets.symmetric(vertical: landscape ? 8 : 16),
            child: Text(
              'My Cart',
              style: TextStyle(fontSize: landscape ? 17 : 20, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
          ),
          Expanded(child: _buildBody(context, viewModel, landscape)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, CartViewModel viewModel, bool landscape) {
    if (viewModel.isLoading && viewModel.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.error != null && viewModel.items.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 40, color: AppColors.textGrey),
              const SizedBox(height: 12),
              Text(viewModel.error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textGrey)),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: () => viewModel.fetchCart(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }
    return viewModel.items.isEmpty ? _buildEmptyState(landscape) : _buildFilledState(context, viewModel, landscape);
  }

  // -------------------------------------------------------------------
  // EMPTY STATE
  // -------------------------------------------------------------------
  // Was a fixed 180x180 icon circle + Center + no scrolling — comfortably
  // tall in portrait, but in landscape the whole thing is taller than
  // the available height and there was no way to reach the bottom
  // button. Now it scrolls, and the icon/spacing shrink in landscape
  // so it usually fits without scrolling at all.
  Widget _buildEmptyState(bool landscape) {
    final double iconBoxSize = landscape ? 110 : 180;
    final double iconSize = landscape ? 50 : 84;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconBoxSize,
            height: iconBoxSize,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: iconSize,
              color: AppColors.primaryBlue,
            ),
          ),
          SizedBox(height: landscape ? 16 : 28),
          Text(
            "Oops, your cart's feeling a little lonely!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: landscape ? 16 : 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
          ),
          const SizedBox(height: 10),
          const Text(
            "You haven't added anything yet. Found\nsomething you like? Let's put it in here!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textGrey, height: 1.4),
          ),
          SizedBox(height: landscape ? 18 : 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBrowseProducts ??
                      () => _showSnack('Switch to the Shop tab to browse products', icon: Icons.info_outline),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryBlue),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text(
                    'Browse Products',
                    style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onGoToWishlist ??
                      () => _showSnack('Switch to the Favorites tab', icon: Icons.info_outline),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text(
                    'Go to Wishlist',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // FILLED STATE
  // -------------------------------------------------------------------
  Widget _buildFilledState(BuildContext context, CartViewModel viewModel, bool landscape) {
    final int totalItems = viewModel.items.length;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: landscape ? 4 : 8),
          child: Row(
            children: [
              Checkbox(
                value: viewModel.allSelected,
                onChanged: (v) => viewModel.toggleSelectAll(v ?? false),
                activeColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              const Text('Select All', style: TextStyle(fontSize: 14, color: AppColors.textDark)),
              const Spacer(),
              Text.rich(
                TextSpan(
                  text: 'Total Item ',
                  style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
                  children: [
                    TextSpan(
                      text: '($totalItems Items)',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderGrey),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => viewModel.fetchCart(),
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: landscape ? 8 : 12),
              itemCount: viewModel.items.length,
              separatorBuilder: (_, __) => SizedBox(height: landscape ? 10 : 16),
              itemBuilder: (context, index) => _cartItemTile(context, viewModel, viewModel.items[index], index, landscape),
            ),
          ),
        ),
        _buildCheckoutBar(context, viewModel, landscape),
      ],
    );
  }

  Widget _buildCheckoutBar(BuildContext context, CartViewModel viewModel, bool landscape) {
    return Container(
      // Reduced vertical padding in landscape — was a fixed 14/18,
      // part of what pushed this bar (and the button on it) off the
      // bottom of a shorter landscape viewport.
      padding: EdgeInsets.fromLTRB(20, landscape ? 8 : 14, 20, landscape ? 10 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Total Charge', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                const SizedBox(height: 2),
                Text(
                  '\$${viewModel.selectedTotal.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: landscape ? 17 : 20, fontWeight: FontWeight.w800, color: AppColors.textDark),
                ),
              ],
            ),
          ),
          SizedBox(
            height: landscape ? 42 : 48,
            child: ElevatedButton(
              onPressed: () => _checkout(context, viewModel),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                padding: const EdgeInsets.symmetric(horizontal: 26),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Checkout Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 15),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartItemTile(BuildContext context, CartViewModel viewModel, CartItemModel item, int index, bool landscape) {
    final bool updating = viewModel.isUpdating(item.cartItemId);
    final bool removing = viewModel.isRemoving(item.cartItemId);
    final bool isNetworkImage = item.imagePath.startsWith('http://') || item.imagePath.startsWith('https://');
    final double thumbSize = landscape ? 52 : 64;

    return Opacity(
      opacity: removing ? 0.4 : 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: viewModel.isSelectedAt(index),
            onChanged: removing ? null : (_) => viewModel.toggleSelectAt(index),
            activeColor: AppColors.primaryBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          Container(
            width: thumbSize,
            height: thumbSize,
            decoration: BoxDecoration(
              color: AppColors.bgLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.imagePath.isEmpty
                  ? const Icon(Icons.image_outlined, color: AppColors.hintGrey, size: 24)
                  : isNetworkImage
                      ? Image.network(
                          item.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) =>
                              const Icon(Icons.image_outlined, color: AppColors.hintGrey, size: 24),
                        )
                      : Image.asset(
                          item.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) =>
                              const Icon(Icons.image_outlined, color: AppColors.hintGrey, size: 24),
                        ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                    ),
                    removing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : GestureDetector(
                            onTap: () => _confirmRemove(context, viewModel, item),
                            child: const Icon(Icons.delete_outline, size: 20, color: AppColors.textGrey),
                          ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'SIZE: ${item.size} • ${item.color}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textGrey, letterSpacing: 0.3),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primaryBlue),
                    ),
                    const Spacer(),
                    if (updating)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else ...[
                      _qtyButton(
                        icon: Icons.remove,
                        onTap: () {
                          if (item.quantity > 1) _updateQuantity(viewModel, item, item.quantity - 1);
                        },
                      ),
                      SizedBox(
                        width: 28,
                        child: Text(
                          '${item.quantity}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
                        ),
                      ),
                      _qtyButton(
                        icon: Icons.add,
                        onTap: () => _updateQuantity(viewModel, item, item.quantity + 1),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderGrey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 15, color: AppColors.textDark),
      ),
    );
  }

  // -------------------------------------------------------------------
  // REMOVE PRODUCT CONFIRMATION DIALOG
  // -------------------------------------------------------------------
  void _confirmRemove(BuildContext context, CartViewModel viewModel, CartItemModel item) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(dialogContext),
                    child: const Icon(Icons.close, size: 20, color: AppColors.textGrey),
                  ),
                ),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.badgeRed.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline, size: 30, color: AppColors.badgeRed),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Remove Product',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Are you sure to remove the product\nfrom cart?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.textGrey, height: 1.4),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.borderGrey),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: const Text('Cancel', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _removeItem(viewModel, item);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.badgeRed,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}