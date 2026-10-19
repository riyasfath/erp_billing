// import 'dart:io';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../admin/admin_api_client.dart';
import '../../admin/admin_model/admin_product_model.dart';
import '../../admin/admin_service/admin_product_service.dart';
import '../../admin/admin_service/admin_review_service.dart';

const Color _accent = Color(0xFF6366F1);
const Color _textDark = Color(0xFF0F172A);
const Color _textGrey = Color(0xFF64748B);
const Color _bg = Color(0xFFF5F6FA);
const Color _danger = Color(0xFFEF4444);
const Color _success = Color(0xFF16A34A);
const Color _pending = Color(0xFFF59E0B);

Color _reviewStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
      return _success;
    case 'rejected':
      return _danger;
    default:
      return _pending;
  }
}

/// Create (product == null) and edit (product != null) share this one
/// screen. Edit additionally exposes per-field quick actions that hit
/// their own dedicated endpoints (add size, change status, toggle
/// featured, upload/delete image) instead of waiting for a full save,
/// plus a Reviews section for approve/reject/reply.
class AdminProductFormScreen extends StatefulWidget {
  final AdminProductModel? product;

  const AdminProductFormScreen({super.key, this.product});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _service = AdminProductService();
  final _reviewService = AdminReviewService();
  final _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _brandController;
  late final TextEditingController _categoryController;
  late final TextEditingController _productTypeController;
  late final TextEditingController _sizesController; // create-only: comma-separated
  late final TextEditingController _colorsController; // create-only: comma-separated
  final TextEditingController _newSizeController = TextEditingController();

  bool get _isEdit => widget.product != null;

  bool _isFeatured = false;
  String _status = 'active';
  List<AdminProductImage> _existingImages = [];
  List<File> _newImages = [];
  List<AdminProductSize> _sizes = [];
  List<AdminProductReview> _reviews = [];

  bool _isSaving = false;
  bool _isUploadingImages = false;
  bool _isAddingSize = false;
  final Set<int> _deletingImageIds = {};
  final Set<int> _busyReviewIds = {};

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(text: p != null ? p.price.toStringAsFixed(2) : '');
    _stockController = TextEditingController(text: p?.stockQuantity.toString() ?? '');
    _brandController = TextEditingController(text: p?.brandName ?? '');
    _categoryController = TextEditingController(text: p?.categoryName ?? '');
    _productTypeController = TextEditingController();
    _sizesController = TextEditingController();
    _colorsController = TextEditingController();
    _isFeatured = p?.isFeatured ?? false;
    _status = p?.status ?? 'active';
    _existingImages = p?.images ?? [];
    _sizes = p?.sizes ?? [];
    _reviews = p?.reviews ?? [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _brandController.dispose();
    _categoryController.dispose();
    _productTypeController.dispose();
    _sizesController.dispose();
    _colorsController.dispose();
    _newSizeController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? _danger : _success,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  Future<void> _pickImages() async {
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 85);
      if (picked.isEmpty) return;
      setState(() => _newImages.addAll(picked.map((x) => File(x.path))));
    } catch (e) {
      // Was failing silently before — this surfaces the real reason
      // (most commonly a missing iOS Info.plist permission string).
      _showSnack('Could not open the photo picker: $e', isError: true);
    }
  }

  Future<void> _uploadNewImages() async {
    if (widget.product == null || _newImages.isEmpty) return;
    setState(() => _isUploadingImages = true);
    try {
      await _service.uploadImages(widget.product!.id, _newImages);
      final refreshed = await _service.getDetail(widget.product!.id);
      if (!mounted) return;
      setState(() {
        _existingImages = refreshed.images;
        _newImages = [];
      });
      _showSnack('Images uploaded');
    } on AdminApiException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (_) {
      _showSnack('Could not upload images', isError: true);
    } finally {
      if (mounted) setState(() => _isUploadingImages = false);
    }
  }

  Future<void> _deleteExistingImage(AdminProductImage image) async {
    if (widget.product == null) return;
    setState(() => _deletingImageIds.add(image.id));
    try {
      await _service.deleteImage(widget.product!.id, image.id);
      setState(() => _existingImages = _existingImages.where((i) => i.id != image.id).toList());
      _showSnack('Image removed');
    } on AdminApiException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (_) {
      _showSnack('Could not remove image', isError: true);
    } finally {
      if (mounted) setState(() => _deletingImageIds.remove(image.id));
    }
  }

  Future<void> _addSize() async {
    final size = _newSizeController.text.trim();
    if (size.isEmpty || widget.product == null) return;
    setState(() => _isAddingSize = true);
    try {
      await _service.addSize(widget.product!.id, size);
      setState(() {
        _sizes = [..._sizes, AdminProductSize(id: -DateTime.now().millisecondsSinceEpoch, size: size)];
        _newSizeController.clear();
      });
      _showSnack('Size added');
    } on AdminApiException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (_) {
      _showSnack('Could not add size', isError: true);
    } finally {
      if (mounted) setState(() => _isAddingSize = false);
    }
  }

  Future<void> _toggleStatus(bool value) async {
    final newStatus = value ? 'active' : 'inactive';
    setState(() => _status = newStatus); // optimistic
    if (widget.product == null) return;
    try {
      await _service.changeStatus(widget.product!.id, newStatus);
    } on AdminApiException catch (e) {
      _showSnack(e.message, isError: true);
      if (mounted) setState(() => _status = value ? 'inactive' : 'active');
    } catch (_) {
      _showSnack('Could not update status', isError: true);
      if (mounted) setState(() => _status = value ? 'inactive' : 'active');
    }
  }

  Future<void> _toggleFeatured(bool value) async {
    setState(() => _isFeatured = value); // optimistic
    if (widget.product == null) return;
    try {
      final actual = await _service.toggleFeatured(widget.product!.id);
      if (mounted) setState(() => _isFeatured = actual);
    } on AdminApiException catch (e) {
      _showSnack(e.message, isError: true);
      if (mounted) setState(() => _isFeatured = !value);
    } catch (_) {
      _showSnack('Could not update featured status', isError: true);
      if (mounted) setState(() => _isFeatured = !value);
    }
  }

  // ---------------------------------------------------------------------
  // Reviews
  // ---------------------------------------------------------------------

  void _updateReview(int reviewId, AdminProductReview Function(AdminProductReview) update) {
    setState(() {
      _reviews = _reviews.map((r) => r.id == reviewId ? update(r) : r).toList();
    });
  }

  Future<void> _approveReview(AdminProductReview review) async {
    setState(() => _busyReviewIds.add(review.id));
    try {
      await _reviewService.approveReview(review.id);
      _updateReview(review.id, (r) => r.copyWith(status: 'approved'));
      _showSnack('Review approved');
    } on AdminApiException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (_) {
      _showSnack('Could not approve this review', isError: true);
    } finally {
      if (mounted) setState(() => _busyReviewIds.remove(review.id));
    }
  }

  Future<void> _rejectReview(AdminProductReview review) async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject review'),
        content: TextField(
          controller: reasonController,
          autofocus: true,
          maxLines: 2,
          decoration: const InputDecoration(hintText: 'Reason (e.g. Inappropriate language)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, reasonController.text.trim()),
            child: const Text('Reject', style: TextStyle(color: _danger)),
          ),
        ],
      ),
    );
    if (reason == null || reason.isEmpty) return;

    setState(() => _busyReviewIds.add(review.id));
    try {
      await _reviewService.rejectReview(review.id, reason);
      _updateReview(review.id, (r) => r.copyWith(status: 'rejected', rejectionReason: reason));
      _showSnack('Review rejected');
    } on AdminApiException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (_) {
      _showSnack('Could not reject this review', isError: true);
    } finally {
      if (mounted) setState(() => _busyReviewIds.remove(review.id));
    }
  }

  Future<void> _replyToReview(AdminProductReview review) async {
    final replyController = TextEditingController(text: review.adminReply ?? '');
    final reply = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(review.adminReply == null ? 'Reply to review' : 'Edit reply'),
        content: TextField(
          controller: replyController,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Thank you for your feedback!'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, replyController.text.trim()),
            child: const Text('Send', style: TextStyle(color: _accent)),
          ),
        ],
      ),
    );
    if (reply == null || reply.isEmpty) return;

    setState(() => _busyReviewIds.add(review.id));
    try {
      await _reviewService.replyToReview(review.id, reply);
      _updateReview(review.id, (r) => r.copyWith(adminReply: reply));
      _showSnack('Reply sent');
    } on AdminApiException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (_) {
      _showSnack('Could not send this reply', isError: true);
    } finally {
      if (mounted) setState(() => _busyReviewIds.remove(review.id));
    }
  }

  // ---------------------------------------------------------------------
  // Save (create / full update)
  // ---------------------------------------------------------------------

  bool _validate() {
    if (_nameController.text.trim().isEmpty) {
      _showSnack('Product name is required', isError: true);
      return false;
    }
    if (double.tryParse(_priceController.text.trim()) == null) {
      _showSnack('Enter a valid price', isError: true);
      return false;
    }
    if (int.tryParse(_stockController.text.trim()) == null) {
      _showSnack('Enter a valid stock quantity', isError: true);
      return false;
    }
    if (_brandController.text.trim().isEmpty || _categoryController.text.trim().isEmpty) {
      _showSnack('Brand and category are required', isError: true);
      return false;
    }
    return true;
  }

  Future<void> _save() async {
    if (!_validate()) return;
    setState(() => _isSaving = true);

    final price = double.parse(_priceController.text.trim());
    final stock = int.parse(_stockController.text.trim());

    try {
      if (_isEdit) {
        await _service.updateProductFull(
          id: widget.product!.id,
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          price: price,
          stockQuantity: stock,
          brand: _brandController.text.trim(),
          category: _categoryController.text.trim(),
          productType: _productTypeController.text.trim(),
          status: _status,
          images: _newImages,
        );
        _showSnack('Product updated');
      } else {
        await _service.createProduct(
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          price: price,
          stockQuantity: stock,
          brand: _brandController.text.trim(),
          category: _categoryController.text.trim(),
          productType: _productTypeController.text.trim(),
          sizes: _sizesController.text.trim(),
          colors: _colorsController.text.trim(),
          images: _newImages,
        );
        _showSnack('Product created');
      }
      if (mounted) Navigator.pop(context, true);
    } on AdminApiException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (_) {
      _showSnack('Could not save this product. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _textDark,
        title: Text(_isEdit ? 'Edit Product' : 'New Product', style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          _card(title: 'Photos', child: _imagesSection()),
          const SizedBox(height: 16),
          _card(
            title: 'Basic Info',
            child: Column(
              children: [
                _field('Name', _nameController),
                const SizedBox(height: 12),
                _field('Description', _descController, maxLines: 3),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _field('Price', _priceController, keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: _field('Stock Qty', _stockController, keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _field('Brand', _brandController)),
                    const SizedBox(width: 12),
                    Expanded(child: _field('Category', _categoryController)),
                  ],
                ),
                const SizedBox(height: 12),
                _field('Product Type (e.g. Shoes)', _productTypeController),
                if (!_isEdit) ...[
                  const SizedBox(height: 12),
                  _field('Sizes (comma separated, e.g. 8,9,10)', _sizesController),
                  const SizedBox(height: 12),
                  _field('Colors (comma separated, e.g. Red,Black)', _colorsController),
                ],
              ],
            ),
          ),
          if (_isEdit) ...[
            const SizedBox(height: 16),
            _card(title: 'Status & Visibility', child: _statusSection()),
            const SizedBox(height: 16),
            _card(title: 'Sizes', child: _sizesSection()),
            const SizedBox(height: 16),
            _card(title: 'Reviews (${_reviews.length})', child: _reviewsSection()),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                disabledBackgroundColor: _accent.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(_isEdit ? 'Save Changes' : 'Create Product', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _textDark)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, {int maxLines = 1, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _textGrey)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: _bg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _imagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 84,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._existingImages.map((img) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(img.url, width: 84, height: 84, fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(width: 84, height: 84, color: _bg)),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: _deletingImageIds.contains(img.id) ? null : () => _deleteExistingImage(img),
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: _deletingImageIds.contains(img.id)
                                  ? const Padding(padding: EdgeInsets.all(4), child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              ..._newImages.map((file) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Stack(
                      children: [
                        ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.file(file, width: 84, height: 84, fit: BoxFit.cover)),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => setState(() => _newImages.remove(file)),
                            child: Container(width: 22, height: 22, decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, size: 14, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  )),
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: const Icon(Icons.add_photo_alternate_outlined, color: _textGrey),
                ),
              ),
            ],
          ),
        ),
        if (_isEdit && _newImages.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isUploadingImages ? null : _uploadNewImages,
              icon: _isUploadingImages
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.cloud_upload_outlined, size: 18),
              label: Text(_isUploadingImages ? 'Uploading...' : 'Upload ${_newImages.length} photo(s) now'),
              style: OutlinedButton.styleFrom(foregroundColor: _accent, side: const BorderSide(color: _accent)),
            ),
          ),
        ],
        if (!_isEdit)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Photos picked here are sent when you create the product below.', style: TextStyle(fontSize: 11, color: _textGrey)),
          ),
      ],
    );
  }

  Widget _statusSection() {
    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Active', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          subtitle: const Text('Visible to shoppers in the app', style: TextStyle(fontSize: 11, color: _textGrey)),
          value: _status == 'active',
          activeColor: _accent,
          onChanged: _toggleStatus,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Featured', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          subtitle: const Text('Highlighted on the storefront', style: TextStyle(fontSize: 11, color: _textGrey)),
          value: _isFeatured,
          activeColor: _pending,
          onChanged: _toggleFeatured,
        ),
      ],
    );
  }

  Widget _sizesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _sizes
              .map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(10)),
                    child: Text(s.size, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ))
              .toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newSizeController,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'e.g. 11',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  filled: true,
                  fillColor: _bg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: _isAddingSize ? null : _addSize,
                style: ElevatedButton.styleFrom(backgroundColor: _accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isAddingSize
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _reviewsSection() {
    if (_reviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('No reviews yet', style: TextStyle(fontSize: 12, color: _textGrey)),
      );
    }
    return Column(
      children: _reviews.map((r) => _reviewTile(r)).toList(),
    );
  }

  Widget _reviewTile(AdminProductReview review) {
    final color = _reviewStatusColor(review.status);
    final bool busy = _busyReviewIds.contains(review.id);
    final bool isPending = review.status.toLowerCase() == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(review.user, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _textDark)),
              ),
              Row(
                children: List.generate(5, (i) => Icon(i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded, size: 15, color: const Color(0xFFF59E0B))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(review.comment, style: const TextStyle(fontSize: 12, color: _textDark, height: 1.4)),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text(review.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
              ),
              const Spacer(),
              if (busy)
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              else ...[
                if (isPending) ...[
                  TextButton(
                    onPressed: () => _approveReview(review),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    child: const Text('Approve', style: TextStyle(color: _success, fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                  const SizedBox(width: 14),
                  TextButton(
                    onPressed: () => _rejectReview(review),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    child: const Text('Reject', style: TextStyle(color: _danger, fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                  const SizedBox(width: 14),
                ],
                TextButton(
                  onPressed: () => _replyToReview(review),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: Text(review.adminReply == null ? 'Reply' : 'Edit reply', style: const TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ],
            ],
          ),
          if (review.rejectionReason != null) ...[
            const SizedBox(height: 8),
            Text('Rejected: ${review.rejectionReason}', style: const TextStyle(fontSize: 11, color: _danger, fontStyle: FontStyle.italic)),
          ],
          if (review.adminReply != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your reply', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _accent)),
                  const SizedBox(height: 3),
                  Text(review.adminReply!, style: const TextStyle(fontSize: 12, color: _textDark)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}