import 'dart:io';
import 'dart:typed_data';

import 'package:ecommerce_app/viewmodel/favorites_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/pincode_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/product_details_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/product_review_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/recently_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/related_products_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ecommerce_app/views/screens/category/full_screen_image_viewer.dart';
import 'package:ecommerce_app/views/screens/order/direct_buy_screen.dart';
import 'package:ecommerce_app/app_colors.dart';
import 'package:ecommerce_app/models/product_detail_model.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/viewmodel/cart_viewmodel.dart';

/// Product Details page — reached by tapping any product card.
/// [product] is the lightweight card data (used for an instant first
/// paint); the full description/sizes/colors/reviews are then fetched
/// from GET /api/products/{id}/ via ProductDetailViewModel.
class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedColorIndex = 0;
  String? _selectedSize;
  final PageController _imageController = PageController();
  int _imagePage = 0;
  bool _isSharingPdf = false;
  final TextEditingController _pincodeController = TextEditingController();

  static const Map<String, Color> _namedColors = {
    'red': Colors.red,
    'orange': Colors.orange,
    'yellow': Color(0xFFF5C518),
    'green': Colors.green,
    'blue': Colors.blue,
    'navy': Color(0xFF1B1F3B),
    'purple': Colors.purple,
    'pink': Colors.pink,
    'black': Colors.black,
    'white': Color(0xFFE5E7EB),
    'grey': Colors.grey,
    'gray': Colors.grey,
    'brown': Colors.brown,
    'beige': Color(0xFFF5F5DC),
  };

  Color _colorFromName(String name) =>
      _namedColors[name.toLowerCase()] ?? AppColors.borderGrey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductDetailViewModel>().fetchDetail(widget.product.id);
      context.read<RecentlyViewedViewModel>().addProduct(widget.product);
      context.read<RelatedProductsViewModel>().fetchRelated(widget.product.id);
      context.read<ProductReviewViewModel>().fetchMyReviews();
    });
  }

  @override
  void dispose() {
    _imageController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  /// Once real detail arrives, pick sensible defaults for size if we
  /// haven't already.
  void _applyDetailDefaults(ProductDetailModel detail) {
    if (_selectedSize == null && detail.sizes.isNotEmpty) {
      _selectedSize = detail.sizes.first;
    }
  }

  void _showSnack(String message, {bool isError = false, IconData icon = Icons.check_circle}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppColors.badgeRed : const Color(0xFF16A34A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(milliseconds: 1800),
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

  Future<void> _addToCart(ProductDetailModel? detail) async {
    if (detail != null && detail.sizes.isNotEmpty && _selectedSize == null) {
      _showSnack('Please select a size', isError: true, icon: Icons.error_outline);
      return;
    }

    final String productId = detail?.id ?? widget.product.id;
    final String size = _selectedSize ?? '';
    final String color = (detail != null && detail.colors.isNotEmpty)
        ? detail.colors[_selectedColorIndex]
        : 'N/A';
    final String productName = detail?.name ?? widget.product.name;

    final cartViewModel = context.read<CartViewModel>();
    final success = await cartViewModel.addToCart(
      productId: productId,
      quantity: 1,
      size: size,
      color: color,
    );

    if (!mounted) return;

    if (success) {
      _showSnack('$productName added to your cart', icon: Icons.check_circle);
    } else {
      _showSnack(_friendlyAddToCartError(cartViewModel.addError), isError: true, icon: Icons.error_outline);
    }
  }

  String _friendlyAddToCartError(String? raw) {
    if (raw == null) return 'Could not add to cart. Please try again.';
    final lower = raw.toLowerCase();
    if (lower.contains('size') && lower.contains('color')) {
      return 'Please select a size and color first';
    }
    if (lower.contains('size')) return 'Please select a size';
    if (lower.contains('color')) return 'Please select a color';
    if (lower.contains('stock')) return 'This item is out of stock';
    return raw;
  }

  void _buyNow(ProductDetailModel? detail) {
    if (detail != null && detail.sizes.isNotEmpty && _selectedSize == null) {
      _showSnack('Please select a size', isError: true, icon: Icons.error_outline);
      return;
    }

    final String productId = detail?.id ?? widget.product.id;
    final String productName = detail?.name ?? widget.product.name;
    final String imageUrl = (detail != null && detail.images.isNotEmpty)
        ? detail.images.first
        : widget.product.imagePath;
    final double price = detail?.price ?? widget.product.price;
    final String size = _selectedSize ?? '';
    final String color = (detail != null && detail.colors.isNotEmpty)
        ? detail.colors[_selectedColorIndex]
        : 'N/A';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DirectBuyScreen(
          productId: productId,
          productName: productName,
          imageUrl: imageUrl,
          price: price,
          size: size,
          color: color,
        ),
      ),
    );
  }

  /// NOTE: uses a placeholder domain (kicks.app) — replace with the
  /// real production domain once one exists. Tapping this link will
  /// only open the app directly (instead of a browser/404) once
  /// Android App Links / iOS Universal Links are configured for that
  /// domain and the app is set up to parse `/product/{id}` and
  /// navigate to ProductDetailScreen — that wiring isn't done yet.
  Future<void> _shareProductLink(ProductDetailModel? detail) async {
    final String id = detail?.id ?? widget.product.id;
    final String name = detail?.name ?? widget.product.name;
    final String link = 'https://kicks.app/product/$id';

    await Share.share('Check out $name on Kicks!\n$link', subject: name);
  }

  Future<void> _openShareOptions(ProductDetailModel? detail) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.link_rounded, color: AppColors.primaryBlue),
                  title: const Text('Share Product Link', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: const Text('Send a link straight to this product', style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _shareProductLink(detail);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.primaryBlue),
                  title: const Text('Share as PDF', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: const Text('A formatted product sheet with photo & details', style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _shareAsPdf(detail);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _shareAsPdf(ProductDetailModel? detail) async {
    if (_isSharingPdf) return;
    setState(() => _isSharingPdf = true);

    try {
      final String name = detail?.name ?? widget.product.name;
      final String brand = detail?.brand ?? widget.product.brand;
      final double price = detail?.price ?? widget.product.price;
      final double? oldPrice = detail?.oldPrice ?? widget.product.oldPrice;
      final double rating = (detail?.rating ?? widget.product.rating).toDouble();
      final String description = detail?.description.isNotEmpty == true
          ? detail!.description
          : 'No description provided for this product.';
      final String imageUrl = (detail != null && detail.images.isNotEmpty)
          ? detail.images.first
          : widget.product.imagePath;

      Uint8List? imageBytes;
      if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        try {
          final response = await http.get(Uri.parse(imageUrl)).timeout(const Duration(seconds: 10));
          if (response.statusCode == 200) imageBytes = response.bodyBytes;
        } catch (_) {
          // no image in the PDF — not fatal
        }
      }

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (imageBytes != null)
                  pw.Center(
                    child: pw.Container(
                      height: 220,
                      child: pw.Image(pw.MemoryImage(imageBytes), fit: pw.BoxFit.contain),
                    ),
                  ),
                pw.SizedBox(height: 20),
                pw.Text(brand.toUpperCase(), style: pw.TextStyle(fontSize: 11, color: PdfColors.blue700, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(name, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Row(
                  children: [
                    pw.Text('\$${price.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    if (oldPrice != null) ...[
                      pw.SizedBox(width: 10),
                      pw.Text(
                        '\$${oldPrice.toStringAsFixed(2)}',
                        style: pw.TextStyle(fontSize: 13, color: PdfColors.grey600, decoration: pw.TextDecoration.lineThrough),
                      ),
                    ],
                    pw.SizedBox(width: 14),
                    pw.Text('Rating: ${rating.toStringAsFixed(1)} / 5', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Text('DESCRIPTION', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                pw.SizedBox(height: 6),
                pw.Text(description, style: const pw.TextStyle(fontSize: 12, lineSpacing: 3)),
                if (detail != null && detail.sizes.isNotEmpty) ...[
                  pw.SizedBox(height: 16),
                  pw.Text('AVAILABLE SIZES', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                  pw.SizedBox(height: 6),
                  pw.Text(detail.sizes.join(', '), style: const pw.TextStyle(fontSize: 12)),
                ],
                if (detail != null && detail.colors.isNotEmpty) ...[
                  pw.SizedBox(height: 12),
                  pw.Text('AVAILABLE COLORS', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                  pw.SizedBox(height: 6),
                  pw.Text(detail.colors.join(', '), style: const pw.TextStyle(fontSize: 12)),
                ],
                pw.SizedBox(height: 24),
                pw.Divider(color: PdfColors.grey300),
                pw.SizedBox(height: 8),
                pw.Text('Shared from Kicks', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500)),
              ],
            );
          },
        ),
      );

      final bytes = await pdf.save();
      final tempDir = await getTemporaryDirectory();
      final safeFileName = name.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_').toLowerCase();
      final file = File('${tempDir.path}/$safeFileName.pdf');
      await file.writeAsBytes(bytes);

      if (!mounted) return;
      await Share.shareXFiles([XFile(file.path)], text: 'Check out $name on Kicks!');
    } catch (e) {
      _showSnack('Could not create the PDF to share', isError: true, icon: Icons.error_outline);
    } finally {
      if (mounted) setState(() => _isSharingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailViewModel = context.watch<ProductDetailViewModel>();
    final cartViewModel = context.watch<CartViewModel>();
    final favoritesViewModel = context.watch<FavoritesViewModel>();
    final detail = detailViewModel.detail;
    if (detail != null) _applyDetailDefaults(detail);

    final String productId = detail?.id ?? widget.product.id;
    final bool isFavorite = favoritesViewModel.isFavorite(productId);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageHeader(detail, productId, isFavorite),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  detail?.brand ?? widget.product.brand,
                                  style: const TextStyle(
                                      color: AppColors.primaryBlue, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                                ),
                              ),
                              const Icon(Icons.star, size: 15, color: AppColors.star),
                              const SizedBox(width: 4),
                              Text('${detail?.rating ?? widget.product.rating}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(detail?.name ?? widget.product.name,
                              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                          const SizedBox(height: 8),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            children: [
                              Text('\$${(detail?.price ?? widget.product.price).toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                              if ((detail?.oldPrice ?? widget.product.oldPrice) != null)
                                Text(
                                  '\$${(detail?.oldPrice ?? widget.product.oldPrice)!.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textGrey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 18),
                          _buildPincodeChecker(),

                          if (detailViewModel.isLoading && detail == null) ...[
                            const SizedBox(height: 30),
                            const Center(child: CircularProgressIndicator()),
                          ],

                          if (detailViewModel.error != null && detail == null) ...[
                            const SizedBox(height: 24),
                            Text(detailViewModel.error!, style: const TextStyle(color: AppColors.badgeRed, fontSize: 13)),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () => context.read<ProductDetailViewModel>().fetchDetail(widget.product.id),
                              child: const Text('Retry'),
                            ),
                          ],

                          if (detail != null) ...[
                            if (detail.colors.isNotEmpty) ...[
                              const SizedBox(height: 22),
                              const Text('SELECT COLOR',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textGrey, letterSpacing: 0.5)),
                              const SizedBox(height: 10),
                              Wrap(spacing: 14, runSpacing: 12, children: List.generate(detail.colors.length, (i) => _colorSwatch(detail, i))),
                            ],

                            if (detail.sizes.isNotEmpty) ...[
                              const SizedBox(height: 22),
                              const Text('SELECT SIZE',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textGrey, letterSpacing: 0.5)),
                              const SizedBox(height: 10),
                              Wrap(spacing: 10, runSpacing: 10, children: detail.sizes.map(_sizeChip).toList()),
                            ],

                            const SizedBox(height: 24),
                            const Text('PRODUCT DESCRIPTION',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textGrey, letterSpacing: 0.5)),
                            const SizedBox(height: 8),
                            Text(
                              detail.description.isNotEmpty
                                  ? detail.description
                                  : 'No description provided for this product yet.',
                              style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.textGrey),
                            ),

                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(
                                  detail.stockQuantity > 0 ? Icons.check_circle_outline : Icons.remove_circle_outline,
                                  size: 16,
                                  color: detail.stockQuantity > 0 ? AppColors.success : AppColors.badgeRed,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  detail.stockQuantity > 0 ? '${detail.stockQuantity} in stock' : 'Out of stock',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textDark),
                                ),
                              ],
                            ),

                            if (detail.hasSpecifications) ...[
                              const SizedBox(height: 20),
                              _buildSpecifications(detail),
                            ],

                            const SizedBox(height: 26),
                            Row(
                              children: [
                                Expanded(
                                  child: Text('CUSTOMER REVIEWS (${detail.reviewCount})',
                                      style: const TextStyle(
                                          fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textGrey, letterSpacing: 0.5)),
                                ),
                                _buildRateProductButton(detail),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (detail.reviews.isEmpty)
                              const Text('No reviews yet.', style: TextStyle(fontSize: 12, color: AppColors.textGrey))
                            else
                              ...detail.reviews.map((r) => Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: _review(r),
                                  )),

                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: AppColors.bgLight, borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.info_outline, size: 18, color: AppColors.primaryBlue),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text('Shipping Information',
                                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textDark)),
                                        SizedBox(height: 3),
                                        Text('Delivery usually takes 2-4 business days. Returns accepted within 30 days of purchase.',
                                            style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // "Similar Products" sits outside the horizontal
                    // padding above so its cards can scroll edge-to-edge.
                    _buildSimilarProducts(),
                  ],
                ),
              ),
            ),
            _buildBottomBar(detail, cartViewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader(ProductDetailModel? detail, String productId, bool isFavorite) {
    final List<String> images = (detail?.images.isNotEmpty ?? false)
        ? detail!.images
        : (widget.product.imagePath.isNotEmpty ? [widget.product.imagePath] : []);

    return Stack(
      children: [
        Container(
          height: 380,
          width: double.infinity,
          color: AppColors.bgLight,
          child: images.isEmpty
              ? const Center(child: Icon(Icons.image_outlined, size: 60, color: AppColors.hintGrey))
              : GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullScreenImageViewer(images: images, initialIndex: _imagePage),
                      ),
                    );
                  },
                  child: PageView.builder(
                    controller: _imageController,
                    itemCount: images.length,
                    onPageChanged: (i) => setState(() => _imagePage = i),
                    itemBuilder: (context, index) {
                      final url = images[index];
                      final bool isNetwork = url.startsWith('http://') || url.startsWith('https://');
                      return isNetwork
                          ? Image.network(
                              url,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stack) =>
                                  const Icon(Icons.image_outlined, size: 60, color: AppColors.hintGrey),
                            )
                          : Image.asset(
                              url,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stack) =>
                                  const Icon(Icons.image_outlined, size: 60, color: AppColors.hintGrey),
                            );
                    },
                  ),
                ),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                final bool active = i == _imagePage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: (active ? AppColors.primaryBlue : AppColors.borderGrey),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
        Positioned(
          top: 12,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _circleIconButton(Icons.arrow_back, () => Navigator.pop(context)),
              Row(
                children: [
                  _circleIconButton(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    () => context.read<FavoritesViewModel>().toggleFavorite(productId),
                    color: isFavorite ? AppColors.badgeRed : AppColors.textDark,
                  ),
                  const SizedBox(width: 10),
                  _isSharingPdf
                      ? Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          padding: const EdgeInsets.all(10),
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        )
                      : _circleIconButton(Icons.share_outlined, () => _openShareOptions(detail)),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 70,
          left: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Text((detail?.badge ?? widget.product.badge) ?? 'NEW ARRIVAL',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          ),
        ),
        // Discoverable zoom hint — tapping the image opens the
        // full-screen pinch-to-zoom + multi-angle swipe viewer, but
        // nothing about a plain image implied that, so this small
        // pill makes it explicit.
        if (images.isNotEmpty)
          Positioned(
            bottom: images.length > 1 ? 40 : 14,
            right: 20,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.zoom_in_rounded, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text('Tap to zoom', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onTap, {Color color = AppColors.textDark}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _colorSwatch(ProductDetailModel detail, int index) {
    final bool selected = _selectedColorIndex == index;
    final String colorName = detail.colors[index];
    final Color color = _colorFromName(colorName);
    final String displayName = colorName.isNotEmpty
        ? '${colorName[0].toUpperCase()}${colorName.substring(1).toLowerCase()}'
        : colorName;

    return GestureDetector(
      onTap: () => setState(() => _selectedColorIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primaryBlue : AppColors.borderGrey,
            width: selected ? 1.6 : 1,
          ),
          color: selected ? AppColors.primaryBlue.withOpacity(0.06) : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(color: AppColors.borderGrey, width: 1),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? AppColors.primaryBlue : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sizeChip(String size) {
    final bool selected = _selectedSize == size;
    return GestureDetector(
      onTap: () => setState(() => _selectedSize = size),
      child: Container(
        width: 68,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppColors.primaryBlue : AppColors.borderGrey),
        ),
        child: Text(size,
            style: TextStyle(color: selected ? Colors.white : AppColors.textDark, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  Widget _review(ReviewModel review) {
    final String initial = review.user.isNotEmpty ? review.user[0] : '?';
    final String timeLabel = review.createdAt != null
        ? _timeAgo(review.createdAt!)
        : '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.avatarBg,
          child: Text(initial, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(review.user, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textDark))),
                  Row(children: List.generate(5, (i) => Icon(Icons.star, size: 13, color: i < review.rating ? AppColors.star : AppColors.borderGrey))),
                ],
              ),
              if (timeLabel.isNotEmpty) Text(timeLabel, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
              const SizedBox(height: 4),
              Text(review.comment, style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.textGrey)),
              if (review.adminReply != null && review.adminReply!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.bgLight, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    'Reply: ${review.adminReply}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textGrey, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 7) return '${(diff.inDays / 7).floor()} week${diff.inDays >= 14 ? 's' : ''} ago';
    if (diff.inDays >= 1) return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    if (diff.inHours >= 1) return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    return 'Just now';
  }

  /// Key highlights (Material, Sole Type, Heel Height, Care
  /// Instructions, Fit Type) as clear rows — pulled out of the
  /// description so shoppers don't have to hunt for them in a
  /// paragraph. Only fields that are actually present are shown.
  Widget _buildSpecifications(ProductDetailModel detail) {
    final specs = <(IconData, String, String)>[
      if (detail.materialType != null) (Icons.texture_rounded, 'Material', detail.materialType!),
      if (detail.soleType != null) (Icons.layers_outlined, 'Sole Type', detail.soleType!),
      if (detail.heelHeight != null) (Icons.height_rounded, 'Heel Height', detail.heelHeight!),
      if (detail.fitType != null) (Icons.straighten_rounded, 'Fit Type', detail.fitType!),
      if (detail.careInstructions != null) (Icons.local_laundry_service_outlined, 'Care Instructions', detail.careInstructions!),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PRODUCT SPECIFICATIONS',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textGrey, letterSpacing: 0.5),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < specs.length; i++) ...[
            if (i > 0) const Divider(height: 18, color: AppColors.borderGrey),
            _specRow(specs[i].$1, specs[i].$2, specs[i].$3),
          ],
        ],
      ),
    );
  }

  Widget _specRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 15, color: AppColors.primaryBlue),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRateProductButton(ProductDetailModel detail) {
    final reviewViewModel = context.watch<ProductReviewViewModel>();
    final existing = reviewViewModel.existingReviewFor(detail.id);

    return GestureDetector(
      onTap: () => _openRateProductSheet(detail, existing),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(existing != null ? Icons.star_rounded : Icons.star_border_rounded, size: 15, color: AppColors.primaryBlue),
            const SizedBox(width: 4),
            Text(
              existing != null ? 'Edit Your Rating' : 'Rate Product',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryBlue),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom sheet with tappable stars + an optional comment, posting
  /// to POST /api/products/reviews/. On success, refetches the product
  /// detail (so the new review appears in the list below) and the
  /// user's own reviews (so the button flips to "Edit Your Rating").
  Future<void> _openRateProductSheet(ProductDetailModel detail, dynamic existing) async {
    int selectedRating = existing?.rating ?? 0;
    final commentController = TextEditingController(text: existing?.comment ?? '');

    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final reviewViewModel = context.watch<ProductReviewViewModel>();
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        existing != null ? 'Edit Your Rating' : 'Rate ${detail.name}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (i) {
                            final starIndex = i + 1;
                            return GestureDetector(
                              onTap: () => setSheetState(() => selectedRating = starIndex),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  starIndex <= selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                                  size: 36,
                                  color: AppColors.star,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderGrey),
                        ),
                        child: TextField(
                          controller: commentController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Share your thoughts about this product (optional)',
                            hintStyle: TextStyle(color: AppColors.hintGrey, fontSize: 13),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: (selectedRating == 0 || reviewViewModel.isSubmitting)
                              ? null
                              : () async {
                                  final success = await reviewViewModel.submitReview(
                                    productId: detail.id,
                                    rating: selectedRating,
                                    comment: commentController.text.trim(),
                                  );
                                  if (success && sheetContext.mounted) {
                                    Navigator.pop(sheetContext, true);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            disabledBackgroundColor: AppColors.borderGrey,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          child: reviewViewModel.isSubmitting
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Submit Rating', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                        ),
                      ),
                      if (reviewViewModel.submitError != null) ...[
                        const SizedBox(height: 10),
                        Text(reviewViewModel.submitError!, style: const TextStyle(color: AppColors.badgeRed, fontSize: 12)),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (submitted == true && mounted) {
      _showSnack('Thanks for your rating!', icon: Icons.check_circle);
      context.read<ProductDetailViewModel>().fetchDetail(widget.product.id);
      context.read<ProductReviewViewModel>().fetchMyReviews();
    }
  }

  Widget _buildSimilarProducts() {
    final relatedViewModel = context.watch<RelatedProductsViewModel>();

    return Padding(
      padding: const EdgeInsets.only(top: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'SIMILAR PRODUCTS',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textGrey, letterSpacing: 0.5),
            ),
          ),
          const SizedBox(height: 12),
          if (relatedViewModel.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (relatedViewModel.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                relatedViewModel.error!,
                style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
            )
          else if (relatedViewModel.products.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.inventory_2_outlined, size: 16, color: AppColors.textGrey),
                  SizedBox(width: 8),
                  Text(
                    'No similar products found',
                    style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: 210,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: relatedViewModel.products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) => _similarProductCard(relatedViewModel.products[index]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _similarProductCard(ProductModel product) {
    final bool isNetworkImage = product.imagePath.startsWith('http');
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
        );
      },
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderGrey),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 110,
              color: AppColors.bgLight,
              child: product.imagePath.isEmpty
                  ? const Icon(Icons.image_outlined, color: AppColors.hintGrey, size: 26)
                  : isNetworkImage
                      ? Image.network(product.imagePath, fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Icon(Icons.image_outlined, color: AppColors.hintGrey, size: 26))
                      : Image.asset(product.imagePath, fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Icon(Icons.image_outlined, color: AppColors.hintGrey, size: 26)),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkPincode() async {
    final pincode = _pincodeController.text.trim();
    if (pincode.length < 4) {
      _showSnack('Enter a valid pincode', isError: true, icon: Icons.error_outline);
      return;
    }
    FocusScope.of(context).unfocus();
    await context.read<PincodeViewModel>().checkPincode(pincode);
  }

  Widget _buildPincodeChecker() {
    final pincodeViewModel = context.watch<PincodeViewModel>();
    final result = pincodeViewModel.result;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: AppColors.primaryBlue),
              SizedBox(width: 6),
              Text(
                'Check Delivery Availability',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderGrey),
                  ),
                  child: TextField(
                    controller: _pincodeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlignVertical: TextAlignVertical.center,
                    onSubmitted: (_) => _checkPincode(),
                    style: const TextStyle(fontSize: 14, color: AppColors.textDark, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      counterText: '',
                      prefixIcon: Icon(Icons.pin_drop_outlined, size: 18, color: AppColors.iconGrey),
                      prefixIconConstraints: BoxConstraints(minWidth: 42, minHeight: 20),
                      hintText: 'Enter 6-digit pincode',
                      hintStyle: TextStyle(color: AppColors.hintGrey, fontSize: 13, fontWeight: FontWeight.w400),
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: pincodeViewModel.isChecking ? null : _checkPincode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: pincodeViewModel.isChecking
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Check', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ),
            ],
          ),
          if (pincodeViewModel.error != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.error_outline, size: 16, color: AppColors.badgeRed),
                const SizedBox(width: 6),
                Expanded(child: Text(pincodeViewModel.error!, style: const TextStyle(fontSize: 12, color: AppColors.badgeRed))),
              ],
            ),
          ] else if (result != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: (result.available ? AppColors.success : AppColors.badgeRed).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    result.available ? Icons.check_circle : Icons.cancel,
                    size: 16,
                    color: result.available ? AppColors.success : AppColors.badgeRed,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.message.isNotEmpty
                          ? result.message
                          : (result.available ? 'Delivery available to this pincode.' : 'Delivery is not available to this pincode.'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: result.available ? AppColors.success : AppColors.badgeRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar(ProductDetailModel? detail, CartViewModel cartViewModel) {
    final double price = detail?.price ?? widget.product.price;
    final bool outOfStock = detail != null && detail.stockQuantity <= 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TOTAL PRICE', style: TextStyle(fontSize: 10, color: AppColors.textGrey)),
          Text('\$${price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: outOfStock ? null : () => _buyNow(detail),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: outOfStock ? AppColors.borderGrey : AppColors.primaryBlue),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    outOfStock ? 'OUT OF STOCK' : 'BUY NOW',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: outOfStock ? AppColors.textGrey : AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (outOfStock || cartViewModel.isAdding) ? null : () => _addToCart(detail),
                  icon: cartViewModel.isAdding
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.shopping_bag_outlined, size: 18),
                  label: Text(
                    outOfStock ? 'OUT OF STOCK' : (cartViewModel.isAdding ? 'ADDING...' : 'ADD TO CART'),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.borderGrey,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}