import 'package:ecommerce_app/models/adress_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/app_colors.dart';
import 'package:ecommerce_app/viewmodel/address_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/cart_viewmodel.dart';
import 'package:ecommerce_app/views/screens/checkout/add_address_screen.dart';

/// "My Addresses" — lists saved addresses (GET /api/accounts/addresses/)
/// and lets the user pick one for the current order, which calls
/// POST /api/cart/select-address/ before returning the chosen address
/// to CheckoutScreen.
class MyAddressScreen extends StatefulWidget {
  const MyAddressScreen({super.key});

  @override
  State<MyAddressScreen> createState() => _MyAddressScreenState();
}

class _MyAddressScreenState extends State<MyAddressScreen> {
  String? _selectingId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressViewModel>().fetchAddresses();
    });
  }

  Future<void> _selectAddress(AddressModel address) async {
    setState(() => _selectingId = address.id);
    final cartViewModel = context.read<CartViewModel>();
    final success = await cartViewModel.selectAddress(address.id);

    if (!mounted) return;
    setState(() => _selectingId = null);

    if (success) {
      Navigator.pop(context, address);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cartViewModel.selectAddressError ?? 'Could not select this address'),
          duration: const Duration(milliseconds: 1600),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.badgeRed,
        ),
      );
    }
  }

  Future<void> _addNewAddress() async {
    final created = await Navigator.push<AddressModel>(
      context,
      MaterialPageRoute(builder: (_) => const AddAddressScreen()),
    );
    if (created != null) {
      // Auto-select the address they just added, same as tapping it.
      await _selectAddress(created);
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressViewModel = context.watch<AddressViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody(addressViewModel)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _addNewAddress,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryBlue),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  icon: const Icon(Icons.add, color: AppColors.primaryBlue, size: 18),
                  label: const Text(
                    'Add New Address',
                    style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AddressViewModel viewModel) {
    if (viewModel.isLoading && viewModel.addresses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.error != null && viewModel.addresses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(viewModel.error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textGrey)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => viewModel.fetchAddresses(),
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
    if (viewModel.addresses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off_outlined, size: 48, color: AppColors.textGrey),
              const SizedBox(height: 14),
              const Text(
                "You haven't saved any addresses yet",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
              const SizedBox(height: 6),
              const Text(
                "Add one below so we know where to deliver your order",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      itemCount: viewModel.addresses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _addressCard(viewModel.addresses[index]),
    );
  }

  Widget _addressCard(AddressModel address) {
    final bool selecting = _selectingId == address.id;

    return GestureDetector(
      onTap: selecting ? null : () => _selectAddress(address),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: AppColors.bgLight, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.location_on_outlined, size: 18, color: AppColors.primaryBlue),
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
                          address.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                        ),
                      ),
                      if (address.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Default',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primaryBlue),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.fullAddress,
                    style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.phone,
                    style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            selecting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right, color: AppColors.textGrey),
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
            'My Addresses',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }
}