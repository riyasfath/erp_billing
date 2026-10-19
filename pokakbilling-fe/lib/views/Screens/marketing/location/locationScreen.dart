import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/setup/location_viewmodel.dart';
import 'package:pokakbilling/views/Screens/marketing/location/addLocationScreen.dart';
import 'package:pokakbilling/views/Screens/marketing/location/editLocationScreen.dart';
import 'package:provider/provider.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LocationViewmodel(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.violetblue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              CupertinoIcons.arrow_left,
              color: AppColors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: false,
          titleSpacing: 0,
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: AppColors.white,
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                'Location',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              child: Consumer<LocationViewmodel>(
                builder: (context, vm, child) {
                  return ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: vm,
                            child: const AddLocationPage(),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.add,
                      color: AppColors.black,
                      size: 18,
                    ),
                    label: const Text(
                      'Locations',
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 2),
                      minimumSize: const Size(0, 28),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.lightGrey,
        body: Consumer<LocationViewmodel>(
          builder: (context, vm, child) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (vm.errorMessage != null) {
              return Center(child: Text('Error: ${vm.errorMessage}'));
            }
            if (vm.locations.isEmpty) {
              return const Center(child: Text('No locations available'));
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
              itemCount: vm.locations.length,
              itemBuilder: (context, index) {
                final location = vm.locations[index];
                return SourceCard(
                  title: location.name,
                  leadingIcon: Icons.location_on_outlined,
                  onEdit: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: vm,
                          child: EditLocationPage(location: location),
                        ),
                      ),
                    );
                  },
                  onDelete: () {
                    _showDeleteConfirmation(
                        context, vm, location.id, location.name);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, LocationViewmodel vm, int id, String name) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Location'),
          content: Text('Are you sure you want to delete "$name"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: vm.deleteLocationLoading
                  ? null
                  : () {
                      Navigator.of(dialogContext).pop();
                      vm.deleteLocation(id, context);
                    },
              child: vm.deleteLocationLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Delete',
                      style: TextStyle(color: AppColors.red),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class SourceCard extends StatelessWidget {
  final String title;
  final IconData leadingIcon;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SourceCard({
    super.key,
    required this.title,
    required this.leadingIcon,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    const double actionAreaWidth = 60.0;
    const double cardHeight = 54.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.center, // centers the card
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9, // 🔹 90% width
          height: cardHeight,
          child: Stack(
            children: [
              // Top border line
              Positioned(
                top: 0,
                left: 8,
                right: 8,
                child: Container(
                  height: 1.0,
                  color: AppColors.violetblue,
                ),
              ),

              LayoutBuilder(
                builder: (context, constraints) {
                  final leftWidth = (constraints.maxWidth - actionAreaWidth)
                      .clamp(0.0, constraints.maxWidth);

                  return Row(
                    children: [
                      // Left gradient section
                      SizedBox(
                        width: leftWidth,
                        height: cardHeight,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                            topRight: Radius.circular(44),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.violetblue,
                                  AppColors.primaryColor
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(leadingIcon,
                                    color: AppColors.white, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Right action area (narrow)
                      Container(
                        width: actionAreaWidth,
                        height: cardHeight,
                        decoration: const BoxDecoration(
                          color: AppColors.transparent,
                          border: Border(
                            top: BorderSide(
                              color: AppColors.violetblue,
                              width: 1.0,
                            ),
                            right: BorderSide(color: AppColors.violetblue),
                            bottom: BorderSide(color: AppColors.violetblue),
                          ),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: onEdit,
                              borderRadius: BorderRadius.circular(6),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: AppColors.hintTextGrey,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: onDelete,
                              borderRadius: BorderRadius.circular(6),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: AppColors.hintTextGrey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
