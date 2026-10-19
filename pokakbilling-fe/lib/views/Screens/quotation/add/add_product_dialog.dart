import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/product_viewmodel.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_textfield.dart';
import 'package:provider/provider.dart';

class AddProductQuickDialog extends StatefulWidget {
  const AddProductQuickDialog({super.key});

  @override
  State<AddProductQuickDialog> createState() => _AddProductQuickDialogState();
}

class _AddProductQuickDialogState extends State<AddProductQuickDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _sgstController = TextEditingController(text: '9');
  final _cgstController = TextEditingController(text: '9');

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _unitPriceController.dispose();
    _stockController.dispose();
    _sgstController.dispose();
    _cgstController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<ProductViewModel>(context, listen: false);

      await provider.createProduct(
        _nameController.text.trim(),
        _descriptionController.text.trim(),
        "1", // Default unit ID - adjust as needed
        _unitPriceController.text.trim(),
        1, // Default category ID - adjust as needed
        _stockController.text.trim(),
        _sgstController.text.trim(),
        _cgstController.text.trim(),
        context,
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add New Product',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.violetblue,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CustomTextfield(
                  label: "Product Name",
                  hintText: "Enter product name",
                  screenWidth: 5,
                  textController: _nameController,
                  isMandatory: true,
                  isValidationRequired: true,
                ),
                const SizedBox(height: 12),
                CustomTextfield(
                  label: "Description",
                  hintText: "Enter description",
                  screenWidth: 5,
                  textController: _descriptionController,
                  isMandatory: true,
                  isValidationRequired: true,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextfield(
                        label: "Unit Price",
                        hintText: "0.00",
                        screenWidth: 5,
                        textController: _unitPriceController,
                        isMandatory: true,
                        isValidationRequired: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomTextfield(
                        label: "Stock",
                        hintText: "0",
                        screenWidth: 5,
                        textController: _stockController,
                        isMandatory: true,
                        isValidationRequired: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextfield(
                        label: "SGST %",
                        hintText: "9",
                        screenWidth: 5,
                        textController: _sgstController,
                        isMandatory: true,
                        isValidationRequired: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomTextfield(
                        label: "CGST %",
                        hintText: "9",
                        screenWidth: 5,
                        textController: _cgstController,
                        isMandatory: true,
                        isValidationRequired: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.violetblue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Add Product',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
