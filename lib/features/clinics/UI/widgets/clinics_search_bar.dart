import 'package:flutter/material.dart';
import 'package:medica_admin/core/helpers/app_colors.dart';

class ClinicsSearchBar extends StatelessWidget {
  final TextEditingController controller;

  const ClinicsSearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'ابحث عن عيادة...',
          hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 14),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: AppColors.textTertiary,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }
}
