import 'package:flutter/material.dart';
import 'package:ecommerce_app/app_colors.dart';

/// "Change Map Pin" screen — a simplified stand-in for a real map SDK
/// (Google Maps / Mapbox). Shows a search bar, a centered pin, and a
/// location summary card; "Save Pin Location" returns the address text
/// to the caller. Wire in an actual map package later if needed.
class ChangeMapPinScreen extends StatefulWidget {
  const ChangeMapPinScreen({super.key});

  @override
  State<ChangeMapPinScreen> createState() => _ChangeMapPinScreenState();
}

class _ChangeMapPinScreenState extends State<ChangeMapPinScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _pinAddress = 'Level 8, Tower Sigma Level 5, Nova District, Capitala Avenue (60910)';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Stack(
        children: [
          // Placeholder "map" background.
          Container(
            color: AppColors.success.withOpacity(0.12),
            child: const Center(
              child: Icon(Icons.location_on, color: AppColors.badgeRed, size: 54),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back, size: 18, color: AppColors.textDark),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, size: 18, color: AppColors.iconGrey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Search Destination here',
                                hintStyle: TextStyle(color: AppColors.hintGrey, fontSize: 13),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          const Icon(Icons.mic_none_rounded, size: 18, color: AppColors.iconGrey),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 6)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_outlined, color: AppColors.primaryBlue, size: 28),
                    const SizedBox(height: 8),
                    const Text(
                      'Pin Map Location',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _pinAddress,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: AppColors.textGrey, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, _pinAddress),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: const Text(
                          'Save Pin Location',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
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
    );
  }
}