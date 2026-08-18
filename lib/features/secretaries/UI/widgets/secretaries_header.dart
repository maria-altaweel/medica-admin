import 'package:flutter/material.dart';
import 'package:medica_admin/core/helpers/app_colors.dart';
import 'package:medica_admin/features/clinics/data/models/clinic_model.dart';
import 'package:medica_admin/features/secretaries/UI/widgets/secretary_dialogs.dart';

class SecretariesHeader extends StatelessWidget {
  final List<ClinicModel> clinics;
  final int? selectedClinicId;
  final ValueChanged<int?> onClinicChanged;
  final VoidCallback?
  onOpenClinicDialog; // 👈 أضفنا هذا الإجراء لفتح الديالوج الموحد

  const SecretariesHeader({
    super.key,
    required this.clinics,
    required this.selectedClinicId,
    required this.onClinicChanged,
    this.onOpenClinicDialog,
  });

  @override
  Widget build(BuildContext context) {
    // العثور على اسم العيادة الحالية لعرضها داخل الزر
    ClinicModel? currentClinic;
    try {
      if (selectedClinicId != null && clinics.isNotEmpty) {
        currentClinic = clinics.firstWhere((c) => c.id == selectedClinicId);
      }
    } catch (_) {
      currentClinic = clinics.isNotEmpty ? clinics.first : null;
    }

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

            // زر اختيار العيادة الذي يفتح الـ SelectClinicDialog الموحد
            InkWell(
              onTap: () {
                if (onOpenClinicDialog != null) {
                  onOpenClinicDialog!();
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_hospital,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currentClinic?.name ?? "اختر العيادة",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.textSecondary,
                    ),
                  ],
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
