import 'package:flutter/material.dart';
import 'package:medica_admin/core/helpers/app_colors.dart';
import 'package:medica_admin/features/clinics/UI/widgets/clinic_action_bottons.dart';
import '../../data/models/clinic_model.dart';

class ClinicsDataTable extends StatelessWidget {
  final List<ClinicModel> clinics;
  final Function(ClinicModel) onView;
  final Function(ClinicModel) onEdit;
  final Function(ClinicModel) onDelete;

  const ClinicsDataTable({
    super.key,
    required this.clinics,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (clinics.isEmpty) {
      return const Center(
        child: Text(
          "لا يوجد عيادات مطابقة للبحث",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.cardBackground),
          columns: const [
            DataColumn(
              label: Text(
                '#',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkHeader,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'العيادة',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkHeader,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'الهاتف',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkHeader,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'هاتف الطوارئ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkHeader,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'عدد الأطباء',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkHeader,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'التقييم',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkHeader,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'الإجراءات',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkHeader,
                ),
              ),
            ),
          ],
          rows: clinics.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final clinic = entry.value;

            return DataRow(
              cells: [
                DataCell(
                  Text(
                    '$index',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.lightPrimary,
                        backgroundImage: clinic.logo != null
                            ? NetworkImage(clinic.logo!)
                            : null,
                        child: clinic.logo == null
                            ? const Icon(
                                Icons.medical_services_outlined,
                                size: 16,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            clinic.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            clinic.address,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    clinic.phone,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ),
                DataCell(
                  Text(
                    clinic.emergencyPhone,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ),
                DataCell(
                  Text(
                    '${clinic.doctorsCount}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: AppColors.star),
                      const SizedBox(width: 4),
                      Text(
                        '${clinic.averageRating}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  ClinicActionButtons(
                    onView: () => onView(clinic),
                    onEdit: () => onEdit(clinic),
                    onDelete: () => onDelete(clinic),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
