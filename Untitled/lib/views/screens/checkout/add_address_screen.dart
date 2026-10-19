import 'package:ecommerce_app/models/adress_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/app_colors.dart';
import 'package:ecommerce_app/viewmodel/address_viewmodel.dart';

/// "Add Address" screen — real fields matching /api/accounts/addresses/:
/// full name, phone, address line 1/2, city, state, pincode, and a
/// default-address toggle. No "category" or pin-map fields — the real
/// API doesn't have them (the old mock UI did).
class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  bool _setAsDefault = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  Future<void> _saveAddress(AddressViewModel viewModel) async {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) return;

    final address = AddressModel(
      id: '', // server assigns this
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
      addressLine1: _addressLine1Controller.text.trim(),
      addressLine2: _addressLine2Controller.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      pincode: _pincodeController.text.trim(),
      isDefault: _setAsDefault,
    );

    final created = await viewModel.addAddress(address);

    if (!mounted) return;

    if (created != null) {
      Navigator.pop(context, created);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.addError ?? 'Could not save this address'),
          duration: const Duration(milliseconds: 1600),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.badgeRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddressViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Full Name'),
                      const SizedBox(height: 8),
                      _textField(_fullNameController, hint: 'e.g. John Doe',
                          validator: (v) => _requiredValidator(v, 'Full name')),
                      const SizedBox(height: 18),
                      _label('Phone'),
                      const SizedBox(height: 8),
                      _textField(_phoneController, hint: 'e.g. 1234567890',
                          keyboardType: TextInputType.phone,
                          validator: (v) => _requiredValidator(v, 'Phone')),
                      const SizedBox(height: 18),
                      _label('Address Line 1'),
                      const SizedBox(height: 8),
                      _textField(_addressLine1Controller, hint: 'Street, house/flat number',
                          validator: (v) => _requiredValidator(v, 'Address line 1')),
                      const SizedBox(height: 18),
                      _label('Address Line 2 (optional)'),
                      const SizedBox(height: 8),
                      _textField(_addressLine2Controller, hint: 'Apartment, landmark, etc.'),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('City'),
                                const SizedBox(height: 8),
                                _textField(_cityController, hint: 'e.g. New York',
                                    validator: (v) => _requiredValidator(v, 'City')),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('State'),
                                const SizedBox(height: 8),
                                _textField(_stateController, hint: 'e.g. NY',
                                    validator: (v) => _requiredValidator(v, 'State')),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _label('Pincode'),
                      const SizedBox(height: 8),
                      _textField(_pincodeController, hint: 'e.g. 100001',
                          keyboardType: TextInputType.number,
                          validator: (v) => _requiredValidator(v, 'Pincode')),
                      const SizedBox(height: 18),
                      _defaultToggle(),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: viewModel.isAdding ? null : () => _saveAddress(viewModel),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          child: viewModel.isAdding
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                )
                              : const Text(
                                  'Add Address',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Add Address',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark));
  }

  Widget _textField(
    TextEditingController controller, {
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.hintGrey, fontSize: 13),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _defaultToggle() {
    return Row(
      children: [
        Switch(
          value: _setAsDefault,
          onChanged: (v) => setState(() => _setAsDefault = v),
          activeColor: AppColors.primaryBlue,
        ),
        const SizedBox(width: 4),
        const Text('Set as default address', style: TextStyle(fontSize: 13, color: AppColors.textDark)),
      ],
    );
  }
}