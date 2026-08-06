import 'package:flutter/material.dart';
import 'package:medica_admin/core/helpers/app_colors.dart';
import 'package:medica_admin/features/clinics/data/models/clinic_model.dart';
import 'package:medica_admin/features/secretaries/UI/widgets/secretary_dialogs.dart';

class SecretariesHeader extends StatelessWidget {
  final List<ClinicModel> clinics;
  final int? selectedClinicId;
  final ValueChanged<int?> onClinicChanged;

  const SecretariesHeader({
    super.key,
    required this.clinics,
    required this.selectedClinicId,
    required this.onClinicChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // زر الإضافة
            ElevatedButton.icon(
              onPressed: selectedClinicId == null
                  ? null
                  : () => SecretaryDialogs.showAddDialog(
                      context,
                      selectedClinicId!,
                    ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "إضافة سكرتيرة",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // قائمة اختيار العيادة (Filter Dropdown)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: selectedClinicId,
                  hint: const Text("اختر العيادة لعرض السكرتارية"),
                  items: clinics.map((clinic) {
                    return DropdownMenuItem<int>(
                      value: clinic.id,
                      child: Text(clinic.name),
                    );
                  }).toList(),
                  onChanged: onClinicChanged,
                ),
              ),
            ),
          ],
        ),
        const Text(
          "إدارة السكرتارية",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.darkHeader,
          ),
        ),
      ],
    );
  }
}
