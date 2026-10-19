import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/expense_viewmodel.dart';
import 'package:provider/provider.dart';

class DashedBorderContainer extends StatelessWidget {
  final double width;
  final double height;
  final String? imagePath;

  const DashedBorderContainer({
    super.key,
    required this.width,
    required this.height,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseViewmodel>(
      builder: (context, notifier, child) {
        return InkWell(
          onTap: () => notifier.pickFile(),
          child: DottedBorder(
            strokeWidth: 1.5,
            borderType: BorderType.RRect,
            radius: const Radius.circular(2),
            dashPattern: const [12, 4],
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: AppColors.semiTransparentGrey,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0.5, horizontal: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppAssets.attachFile,
                      height: 25,
                    ),
                    Text(
                      notifier.selectedFileName ?? "Attach Receipt",
                      style: const TextStyle(
                        color: AppColors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildPlaceholder() {
    return const Center(
      child: Text(
        "No Image",
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
