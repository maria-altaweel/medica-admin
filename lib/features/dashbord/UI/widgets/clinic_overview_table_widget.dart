import 'package:flutter/material.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';
import 'package:medica_admin/features/dashbord/data/models/dashboard_model.dart';

class ClinicsOverviewTableWidget extends StatelessWidget {
  final List<ClinicOverview> clinicsOverview;
  final Function(int clinicId)? onViewClinicDetails;
  final VoidCallback? onShowAllClinics;

  const ClinicsOverviewTableWidget({
    super.key,
    required this.clinicsOverview,
    this.onViewClinicDetails,
    this.onShowAllClinics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'نظرة عامة علي العيادات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.textField),
              columns: const [
                DataColumn(
                  label: Text(
                    '#',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'العيادة',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'المرضى',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'الأطباء',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'السكرتارية',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'مواعيد اليوم',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'إيرادات الشهر',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'التفاصيل',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
              rows: List.generate(clinicsOverview.length, (index) {
                final clinic = clinicsOverview[index];
                final todayTotal = clinic.todayAppointments['total'] ?? 0;
                return DataRow(
                  cells: [
                    DataCell(Text('${index + 1}')),
                    DataCell(
                      Text(
                        clinic.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    DataCell(Text('${clinic.patientsCount}')),
                    DataCell(Text('${clinic.doctorsCount}')),
                    DataCell(Text('${clinic.secretariesCount}')),
                    DataCell(Text('$todayTotal')),
                    DataCell(
                      Text(
                        '${clinic.monthlyRevenue} \$',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                    DataCell(
                      OutlinedButton.icon(
                        onPressed: () {
                          if (onViewClinicDetails != null) {
                            onViewClinicDetails!(clinic.id);
                          }
                        },
                        icon: const Icon(
                          Icons.remove_red_eye,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        label: const Text(
                          'عرض التفاصيل',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 0.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          // زر "عرض جميع العيادات" المعدل ليطابق الصورة
          Center(
            child: OutlinedButton.icon(
              onPressed: onShowAllClinics,
              icon: const Icon(
                Icons.arrow_back,
                size: 16,
                color: AppColors.primary,
              ),
              label: const Text(
                'عرض جميع العيادات',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                backgroundColor: AppColors
                    .textField, // لون الخلفية الفاتح الموجود في التصميم
                side: const BorderSide(color: AppColors.borderColor, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
