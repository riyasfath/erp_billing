import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../admin/admin_model/admin_product_model.dart';
import '../../admin/admin_viewmodel/admin_product_viewmodel.dart';
import 'admin_product_form.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  static const Color _accent = Color(0xFF6366F1);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textGrey = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProductViewModel>().fetchProducts();
    });
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF16A34A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  Future<void> _confirmDelete(AdminProductViewModel viewModel, AdminProductModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('"${product.name}" will be permanently removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444)))),
        ],
      ),
    );
    if (confirmed != true) return;
    final success = await viewModel.deleteProduct(product);
    _showSnack(success ? 'Product deleted' : (viewModel.error ?? 'Could not delete'), isError: !success);
  }

  Future<void> _openProduct({AdminProductModel? product}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AdminProductFormScreen(product: product)),
    );
    if (result == true && mounted) {
      context.read<AdminProductViewModel>().fetchProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminProductViewModel>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'admin_products_fab',
        backgroundColor: _accent,
        onPressed: () => _openProduct(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: _buildBody(viewModel),
    );
  }

  Widget _buildBody(AdminProductViewModel viewModel) {
    if (viewModel.isLoading && viewModel.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.error != null && viewModel.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(viewModel.error!, style: const TextStyle(color: _textGrey)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () => viewModel.fetchProducts(), child: const Text('Retry')),
          ],
        ),
      );
    }
    if (viewModel.products.isEmpty) {
      return const Center(child: Text('No products yet', style: TextStyle(color: _textGrey)));
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.fetchProducts(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
        itemCount: viewModel.products.length + (viewModel.hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= viewModel.products.length) {
            return Center(
              child: viewModel.isLoadingMore
                  ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())
                  : TextButton(onPressed: () => viewModel.loadMore(), child: const Text('Load More')),
            );
          }
          return _productTile(viewModel, viewModel.products[index]);
        },
      ),
    );
  }

  Widget _productTile(AdminProductViewModel viewModel, AdminProductModel product) {
    final bool busy = viewModel.isBusy(product.id);
    final bool active = product.status.toLowerCase() == 'active';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: busy ? null : () => _openProduct(product: product),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 6))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: product.firstImageUrl != null
                      ? Image.network(
                          product.firstImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => Container(color: const Color(0xFFF1F5F9), child: const Icon(Icons.image_outlined, color: _textGrey)),
                        )
                      : Container(color: const Color(0xFFF1F5F9), child: const Icon(Icons.image_outlined, color: _textGrey)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark)),
                    const SizedBox(height: 3),
                    Text('${product.brandName} · ${product.categoryName}', style: const TextStyle(fontSize: 11, color: _textGrey)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _textDark)),
                        const SizedBox(width: 8),
                        Text('Stock: ${product.stockQuantity}', style: const TextStyle(fontSize: 11, color: _textGrey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: busy ? null : () => viewModel.changeStatus(product, active ? 'inactive' : 'active'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: (active ? const Color(0xFF16A34A) : _textGrey).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (busy)
                                  const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 1.5))
                                else
                                  Icon(active ? Icons.check_circle : Icons.pause_circle_outline, size: 12, color: active ? const Color(0xFF16A34A) : _textGrey),
                                const SizedBox(width: 4),
                                Text(active ? 'Active' : 'Inactive', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: active ? const Color(0xFF16A34A) : _textGrey)),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: busy ? null : () => _confirmDelete(viewModel, product),
                          icon: const Icon(Icons.delete_outline_rounded, size: 19, color: Color(0xFFEF4444)),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}