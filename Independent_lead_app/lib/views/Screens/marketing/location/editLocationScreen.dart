import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/marketing_model/location.dart';
import 'package:pokakbilling/viewmodels/setup/location_viewmodel.dart';
import 'package:provider/provider.dart';

class EditLocationPage extends StatefulWidget {
  final Location location;

  const EditLocationPage({super.key, required this.location});

  @override
  State<EditLocationPage> createState() => _EditLocationPageState();
}

class _EditLocationPageState extends State<EditLocationPage> {
  late TextEditingController locationController;

  @override
  void initState() {
    super.initState();
    locationController = TextEditingController(text: widget.location.name);
  }

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // ✅ allows screen to resize instead of overflow
      appBar: AppBar(
        backgroundColor: AppColors.violetblue,
        title: const Text(
          'Edit Location',
          style: TextStyle(color: AppColors.white, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(
            CupertinoIcons.arrow_left,
            color: AppColors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // ✅ scrolls only when keyboard appears
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Card near the top
                        Card(
                          color: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                          shadowColor: Colors.grey.withOpacity(0.3),
                          child: Container(
                            height: 179,
                            width: 350,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Name',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.headerPurple,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 43,
                                  width: 327,
                                  child: TextField(
                                    controller: locationController,
                                    style: const TextStyle(fontSize: 14),
                                    decoration: InputDecoration(
                                      hintText: 'Enter location name',
                                      hintStyle: const TextStyle(
                                          color: AppColors.hintTextGrey),
                                      filled: true,
                                      fillColor: AppColors.inputFill,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: AppColors.softBorder),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: AppColors.softBorder),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Update button
                        Consumer<LocationViewmodel>(
                          builder: (context, provider, child) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: provider.editLocationLoading
                                    ? null
                                    : () {
                                        final name =
                                            locationController.text.trim();
                                        if (name.isNotEmpty) {
                                          provider.editLocation(
                                              widget.location.id,
                                              name,
                                              context);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.violetblue,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: provider.editLocationLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: AppColors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Update',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppColors.white,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Cancel button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side:
                                  const BorderSide(color: AppColors.softBorder),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.softBorder,
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
          },
        ),
      ),
    );
  }
}
