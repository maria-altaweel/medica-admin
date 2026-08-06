import 'package:flutter/material.dart';
import 'package:medica_admin/core/helpers/app_colors.dart';

class ClinicsHeader extends StatelessWidget {
  final VoidCallback onRefresh;
  final VoidCallback onAddClinic;

  const ClinicsHeader({
    super.key,
    required this.onRefresh,
    required this.onAddClinic,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'العيادات',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.darkHeader,
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh, color: AppColors.primary),
              tooltip: 'تحديث البيانات',
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: onAddClinic,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('إضافة عيادة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
