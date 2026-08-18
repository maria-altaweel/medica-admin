import 'package:flutter/material.dart';
import 'package:medica_admin/core/helpers/app_colors.dart';

class SalariesHeaderWidget extends StatelessWidget {
  final VoidCallback onGeneratePressed;

  const SalariesHeaderWidget({super.key, required this.onGeneratePressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "قائمة الرواتب",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.darkHeader,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "إدارة وعرض رواتب الأطباء للعيادات",
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: onGeneratePressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          icon: const Icon(Icons.add_chart, size: 20, color: Colors.white),
          label: const Text(
            "توليد رواتب جديدة",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
