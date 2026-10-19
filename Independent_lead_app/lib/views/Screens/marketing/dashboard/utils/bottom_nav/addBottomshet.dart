import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/setup/location_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/categoryList_viewmodel.dart';
import 'package:pokakbilling/models/data-models/marketing_model/source.dart';

/// Shared sheet container style
class _SheetContainer extends StatelessWidget {
  final Widget child;
  const _SheetContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.8;
    return SafeArea(
      child: LayoutBuilder(builder: (context, constraints) {
        return Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          ),
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: 0, maxHeight: constraints.maxHeight),
              child: IntrinsicHeight(child: child),
            ),
          ),
        );
      }),
    );
  }
}

const Color _borderColor = Color(0xFFCAD5E2);

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: _borderColor),
    filled: true,
    fillColor: AppColors.inputFill,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _borderColor, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  );
}

/// Add Location bottom sheet
/// Add Location card (same UI/behavior as Add Source)

// Define border color constant

class AddLocationBottomSheet extends StatefulWidget {
  const AddLocationBottomSheet({super.key});

  @override
  State<AddLocationBottomSheet> createState() => _AddLocationBottomSheetState();
}

class _AddLocationBottomSheetState extends State<AddLocationBottomSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  InputDecoration _locationInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _borderColor),
      filled: true,
      fillColor: AppColors.inputFill,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _borderColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 60, 12, 0),
          child: Container(
            height: 512,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 24,
                  offset: Offset(0, 12),
                  color: Color(0x22000000),
                ),
              ],
            ),
            child: Consumer<LocationViewmodel>(
              builder: (context, vm, _) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Add New Location',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.violetblue,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close,
                                size: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Input + image block
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Name',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.violetblue,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // TextField (text color black ✅)
                            SizedBox(
                              height: 43,
                              child: TextField(
                                controller: _controller,
                                style: const TextStyle(
                                  color: Colors.black, // ✅ text color changed
                                ),
                                decoration: _locationInputDecoration(
                                  'Enter location name...',
                                ),
                              ),
                            ),

                            const SizedBox(height: 56),

                            // Hide map when keyboard opens
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 150),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              child: isKeyboardOpen
                                  ? const SizedBox.shrink(
                                      key: ValueKey('no_img'))
                                  : Column(
                                      key: const ValueKey('with_img'),
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.asset(
                                            'assets/images/map.png',
                                            height: 200,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Buttons (unchanged)
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: OutlinedButton(
                                onPressed: vm.addLocationLoading
                                    ? null
                                    : () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: _borderColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _borderColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: vm.addLocationLoading
                                    ? null
                                    : () {
                                        final name = _controller.text.trim();
                                        if (name.isEmpty) return;
                                        vm.createLocation(name, context);
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.violetblue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: vm.addLocationLoading
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Save',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Add Source bottom sheet
/// Add Source card (replaces the old bottom sheet)
/// Add Source card (replaces the old bottom sheet)
class AddSourceBottomSheet extends StatefulWidget {
  const AddSourceBottomSheet({super.key});

  @override
  State<AddSourceBottomSheet> createState() => _AddSourceBottomSheetState();
}

class _AddSourceBottomSheetState extends State<AddSourceBottomSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  InputDecoration _sourceInputDecoration(String hint) {
    // Same base as _inputDecoration but adjusted for 43px field height
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _borderColor),
      filled: true,
      fillColor: AppColors.inputFill,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _borderColor, width: 1.5),
      ),
      // Height control -> 43px total (approx) via tight content padding
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Transparent backdrop; centered card with fixed height 512
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 60, 12, 0),
          child: Container(
            height: 512,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 24,
                  offset: Offset(0, 12),
                  color: Color(0x22000000),
                ),
              ],
            ),
            child: Consumer<SourceViewmodel>(
              builder: (context, vm, _) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Add New Source',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.violetblue,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close,
                                size: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Input block
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Name',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.violetblue,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // EXACT 43px TextField, with text + border color #CAD5E2
                            SizedBox(
                              height: 43,
                              child: TextField(
                                controller: _controller,
                                style: const TextStyle(
                                  color: Colors.black, // #CAD5E2 text color
                                ),
                                decoration: _sourceInputDecoration(
                                  'Enter Source name...',
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Hint line (info icon + helper text) in #CAD5E2
                            const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Icon(Icons.info_outline,
                                      size: 18, color: _borderColor),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Add a new marketing source like Google Ads, Facebook, or Organic',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: _borderColor, // #CAD5E2
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Action buttons — 48px height, 14px, weight 500 text
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: OutlinedButton(
                                onPressed: vm.addSourceLoading
                                    ? null
                                    : () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: _borderColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _borderColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: vm.addSourceLoading
                                    ? null
                                    : () {
                                        final name = _controller.text.trim();
                                        if (name.isEmpty) return;
                                        vm.createSource(name, context);
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.violetblue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: vm.addSourceLoading
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Save',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Add Category bottom sheet
/// Add Category card (same UI/behavior as Add Source)
/// Add Category card (same UI/behavior as Add Source)

class AddCategoryBottomSheet extends StatefulWidget {
  const AddCategoryBottomSheet({super.key});

  @override
  State<AddCategoryBottomSheet> createState() => _AddCategoryBottomSheetState();
}

class _AddCategoryBottomSheetState extends State<AddCategoryBottomSheet> {
  final TextEditingController _nameCtrl = TextEditingController();
  Source? _selectedSource;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  // Field decoration — centered text & hint, black color
  InputDecoration _field43Decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _borderColor), // black hint
      filled: true,
      fillColor: AppColors.inputFill,
      isDense: false, // allow proper vertical centering
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _borderColor, width: 1.5),
      ),
      // ~43px visual height and true vertical centering
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 60, 12, 0),
          child: Container(
            height: 512,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 24,
                  offset: Offset(0, 12),
                  color: Color(0x22000000),
                ),
              ],
            ),
            child: Consumer2<SourceViewmodel, CategoryMarketingViewmodel>(
              builder: (context, sourceVm, categoryVm, _) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Add New Category',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.violetblue,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close,
                                size: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Inputs
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Name',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.violetblue,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Category name field
                              SizedBox(
                                height: 43,
                                child: TextField(
                                  controller: _nameCtrl,
                                  maxLines: 1,
                                  textAlignVertical: TextAlignVertical.center,
                                  style: const TextStyle(
                                      color:
                                          Colors.black), // typed text -> black
                                  decoration: _field43Decoration(
                                      'Enter Categories name...'),
                                ),
                              ),
                              const SizedBox(height: 12),

                              const Text(
                                'Source *',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.violetblue,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Dropdown — hint & selected text centered vertically
                              SizedBox(
                                height: 43,
                                child: DropdownButtonFormField<Source>(
                                  initialValue: _selectedSource,
                                  isDense:
                                      true, // Ensures proper vertical alignment
                                  icon: const Icon(Icons.arrow_drop_down),
                                  style: const TextStyle(color: _borderColor),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    hintText: 'Select a source...',
                                    hintStyle:
                                        const TextStyle(color: Colors.black),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          const BorderSide(color: _borderColor),
                                    ),
                                  ),
                                  alignment: Alignment
                                      .centerLeft, // aligns selected text vertically center
                                  hint: const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Select a source...',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  onChanged: (v) =>
                                      setState(() => _selectedSource = v),
                                  selectedItemBuilder: (context) {
                                    final items = sourceVm.sources;
                                    return items.map((s) {
                                      return Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          s.name,
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      );
                                    }).toList();
                                  },
                                  items: sourceVm.sources.map((s) {
                                    return DropdownMenuItem<Source>(
                                      value: s,
                                      child: Text(
                                        s.name,
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Helper line
                            ]),
                      ),

                      const Spacer(),

                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: OutlinedButton(
                                onPressed: categoryVm.addCategoryLoading
                                    ? null
                                    : () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: _borderColor),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: _borderColor),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: categoryVm.addCategoryLoading
                                    ? null
                                    : () {
                                        final name = _nameCtrl.text.trim();
                                        if (name.isEmpty ||
                                            _selectedSource == null) {
                                          return;
                                        }
                                        categoryVm.createCategory(
                                            name, _selectedSource!.id, context);
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.violetblue,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: categoryVm.addCategoryLoading
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2),
                                      )
                                    : const Text(
                                        'Save',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
