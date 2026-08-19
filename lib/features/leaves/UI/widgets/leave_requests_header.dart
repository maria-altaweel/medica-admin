import 'package:flutter/material.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';
import 'package:medica_admin/features/clinics/data/models/clinic_model.dart';

class LeaveRequestsHeader extends StatelessWidget {
  final ClinicModel currentClinic;
  final List<ClinicModel> clinics;
  final ValueChanged<ClinicModel> onClinicChanged;
  final VoidCallback? onOpenClinicDialog;
  final VoidCallback? onRefresh; // 👈 دالة زر التحديث الجديد

  const LeaveRequestsHeader({
    super.key,
    required this.currentClinic,
    required this.clinics,
    required this.onClinicChanged,
    this.onOpenClinicDialog,
    this.onRefresh, // 👈 تمريرها في البناء
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'طلبات إجازة الأطباء',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.darkHeader,
          ),
        ),
        Row(
          children: [
            // 👇 زر التحديث (Refresh) المنفصل بجانب العيادة
            if (onRefresh != null) ...[
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, color: AppColors.primary),
                tooltip: 'تحديث البيانات',
              ),
              const SizedBox(width: 10),
            ],

            // زر اختيار العيادة
            InkWell(
              onTap: () {
                if (onOpenClinicDialog != null) {
                  onOpenClinicDialog!();
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  border: Border.all(color: AppColors.borderColor),
                  borderRadius: BorderRadius.circular(8),
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
                      currentClinic.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
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
      ],
    );
  }
}
