import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/app_colors.dart';
import 'package:medica_admin/features/secretaries/UI/widgets/secretary_dialogs.dart';
import 'package:medica_admin/features/secretaries/data/models/secretary_model.dart';
import 'package:medica_admin/features/secretaries/logic/secretary_cubit/secretary_cubit.dart';

class SecretariesTable extends StatelessWidget {
  final List<SecretaryModel> secretaries;
  final int clinicId;

  const SecretariesTable({
    super.key,
    required this.secretaries,
    required this.clinicId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.cardBackground),
            columns: const [
              DataColumn(
                label: Text('#', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text(
                  'الإسم',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'الهاتف',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'الحالة',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'مفعلة',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'تاريخ الإضافة',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'الإجراءات',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: secretaries.asMap().entries.map((entry) {
              int index = entry.key + 1;
              SecretaryModel item = entry.value;

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
                          radius: 18,
                          backgroundColor: AppColors.lightPrimary,
                          backgroundImage:
                              item.profile != null && item.profile!.isNotEmpty
                              ? NetworkImage(item.profile!)
                              : null,
                          child: item.profile == null || item.profile!.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 20,
                                  color: AppColors.primary,
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.fullName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Text(
                      item.phone,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  DataCell(_buildStatusBadge(item.status)),
                  DataCell(
                    Switch(
                      value: item.isActive,
                      activeColor: AppColors.success,
                      onChanged: (val) {
                        context.read<SecretaryCubit>().updateSecretary(
                          clinicId: clinicId,
                          secretaryId: item.id,
                          isActive: val,
                        );
                      },
                    ),
                  ),
                  DataCell(
                    Text(
                      item.createdAt,
                      style: const TextStyle(color: AppColors.textTertiary),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          onPressed: () => SecretaryDialogs.showEditDialog(
                            context,
                            clinicId,
                            item,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          onPressed: () => SecretaryDialogs.showRemoveDialog(
                            context,
                            clinicId,
                            item.id,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                            size: 20,
                          ),
                          onPressed: () => SecretaryDialogs.showDeleteDialog(
                            context,
                            clinicId,
                            item.id,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    bool isActive = status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.successLight : AppColors.errorLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? "نشط" : "موقوف",
        style: TextStyle(
          color: isActive ? AppColors.success : AppColors.error,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
