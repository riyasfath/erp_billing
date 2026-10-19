import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';

class HelpSupport extends StatelessWidget {
  const HelpSupport({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Help & Support",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SizedBox(
        height: height,
        width: width,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'QUICK HELP LINKS',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                _buildHelpTile('Help Document', AppAssets.helpdocument, () {}),
                _buildHelpTile('Help Videos', AppAssets.helpvedios, () {}),
                _buildHelpTile('Mail Us', AppAssets.mailus, () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHelpTile(String title, String assetPath, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.violetblue, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        leading: Image.asset(assetPath,
            width: 24, height: 24, color: AppColors.violetblue),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 14, color: AppColors.violetblue),
        onTap: onTap,
      ),
    );
  }
}
