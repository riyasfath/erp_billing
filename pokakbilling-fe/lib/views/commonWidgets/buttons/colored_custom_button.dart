import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

class ColoredCustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool loading;
  final GlobalKey<FormState>? formKey; // Add form key

  const ColoredCustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
    this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: loading
          ? null
          : () {
              if (formKey == null ||
                  (formKey!.currentState != null &&
                      formKey!.currentState!.validate())) {
                onPressed();
              }
            },
      child: Container(
        height: 40,
        width: double.infinity,
        decoration: BoxDecoration(
          // color: loading ? AppColors.primaryColor : AppColors.primaryColor,
          color: loading ? const Color(0xFF22884B) : const Color(0xFF22884B),

          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String? name;
  final Widget? child;
  final bool loading;

  const CustomButton({
    super.key,
    this.name,
    this.child,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Center(
        child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : child ??
                Text(
                  name ?? '',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }
}
