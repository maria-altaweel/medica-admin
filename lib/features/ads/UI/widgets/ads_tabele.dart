import 'package:flutter/material.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';
import 'package:medica_admin/features/ads/data/models/ad_model.dart';

class AdsTable extends StatelessWidget {
  final List<AdModel> adsList;

  final Function(AdModel) onEdit;
  final Function(int) onDelete;
  final Function(int) onToggleStatus; // استلام الـ id فقط كما هو في الكيوبت

  const AdsTable({
    super.key,
    required this.adsList,

    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    if (adsList.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.scaffoldBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: const Center(
          child: Text(
            'لا توجد إعلانات مضافة لهذه العيادة حالياً',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.textField),
                headingRowHeight: 55,
                dataRowHeight: 80,
                columnSpacing: 50,
                columns: const [
                  DataColumn(
                    label: Text(
                      'الصورة',
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
                      'الحالة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'تاريخ الإنشاء',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'الإجراءات',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
                rows: adsList.map((ad) {
                  return DataRow(
                    cells: [
                      // 1. الصورة
                      DataCell(
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: (ad.image != null && ad.image!.isNotEmpty)
                                ? Image.network(
                                    ad.image!,
                                    width: 110,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 110,
                                        height: 60,
                                        color: AppColors.textField,
                                        child: const Icon(
                                          Icons.broken_image,
                                          color: AppColors.textSecondary,
                                          size: 24,
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    width: 110,
                                    height: 60,
                                    color: AppColors.textField,
                                    child: const Icon(
                                      Icons.image,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      // 2. العيادة
                      DataCell(
                        Text(
                          ad.clinicName ?? '',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // 3. الحالة (نشط / غير نشط)
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: ad.isActive
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            ad.isActive ? 'نشط' : 'غير نشط',
                            style: TextStyle(
                              color: ad.isActive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      // 4. تاريخ الإنشاء
                      DataCell(
                        Text(
                          ad.createdAt,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      // 5. الإجراءات والتوغل
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              onPressed: () => onEdit(ad),
                              tooltip: 'تعديل',
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                                size: 20,
                              ),
                              onPressed: () => onDelete(ad.id),
                              tooltip: 'حذف',
                            ),
                            const SizedBox(width: 8),
                            // زر التوغل مع ربط القيمة والـ onChanged
                            Switch(
                              value: ad.isActive,
                              activeColor: AppColors.primary,
                              onChanged: (val) {
                                onToggleStatus(ad.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
