import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/AppsnackBar.dart';
import 'package:medica_admin/core/helpers/app_colors.dart';
import 'package:medica_admin/core/networking/service_locator.dart';
import 'package:medica_admin/core/widgets/App_Loadingindicator.dart';
import 'package:medica_admin/features/dashbord/UI/pages/admin_layout.dart';
import 'package:medica_admin/features/salaries/UI/pages/salary_details_screen.dart';
import 'package:medica_admin/features/salaries/data/models/salary_model.dart';
import 'package:medica_admin/features/salaries/logic/salary_cubit/salary_cubit.dart';
import 'package:medica_admin/features/salaries/logic/salary_cubit/salary_state.dart';

class SalariesTableWidget extends StatelessWidget {
  const SalariesTableWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SalaryCubit, SalaryState>(
      listener: (context, state) {
        if (state is GetSalariesError) {
          Appsnackbar.showError(
            context,
            'حدث خطأ في جلب الرواتب: ${state.message}',
          );
        }
      },
      buildWhen: (previous, current) {
        return current is GetSalariesLoading ||
            current is GetSalariesSuccess ||
            current is GetSalariesError ||
            current is SalaryInitial;
      },
      builder: (context, state) {
        // 1. حالة التحميل
        if (state is GetSalariesLoading) {
          return const Center(child: AppLoadingIndicator());
        }
        // 2. حالة الخطأ
        else if (state is GetSalariesError) {
          return const Center(
            child: Text(
              'حدث خطأ في جلب الرواتب، يرجى المحاولة لاحقاً',
              style: TextStyle(color: AppColors.error, fontSize: 16),
            ),
          );
        }
        // 3. حالة النجاح
        else if (state is GetSalariesSuccess) {
          final salariesList = state.salaries;

          if (salariesList.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد رواتب مطابقة للبحث أو العيادة المحددة.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            );
          }

          return Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  AppColors.pageBackground,
                ),
                dataRowMaxHeight: 70,
                dividerThickness: 0.5,
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
                      'الطبيب',
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
                      'الفترة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkHeader,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'الإيرادات',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkHeader,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'النسبة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkHeader,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'حصة الطبيب',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkHeader,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'الحالة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkHeader,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'إجراءات',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkHeader,
                      ),
                    ),
                  ),
                ],
                rows: salariesList.asMap().entries.map((entry) {
                  int index = entry.key + 1;
                  SalaryPayoutModel salary = entry.value;
                  return _buildDataRow(context, index, salary);
                }).toList(),
              ),
            ),
          );
        }

        // 4. الحالة الافتراضية
        return const Center(
          child: Text(
            'يرجى تحديد العيادة والفترة لعرض الرواتب',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        );
      },
    );
  }

  DataRow _buildDataRow(
    BuildContext context,
    int index,
    SalaryPayoutModel salary,
  ) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            index.toString(),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                salary.doctor.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                salary.doctor.specialization ?? '',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Text(
            salary.clinic.name,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
        ),
        DataCell(
          Text(
            '${salary.financials.periodStart ?? ''}\nإلى ${salary.financials.periodEnd ?? ''}',
            style: const TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                salary.financials.revenue?.toStringAsFixed(2) ?? '0.00',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                'ل.س',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
        DataCell(
          Text(
            '${salary.financials.salaryPercentage}%',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                salary.financials.doctorShare.toStringAsFixed(2),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                'ل.س',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
        DataCell(_buildStatusBadge(salary.financials.status)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // زر عرض التفاصيل (زر العين) - تم ربطه بنجاح
              _buildActionButton(Icons.visibility_outlined, AppColors.info, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminLayout(
                      // نضع صفحة التفاصيل مع الـ BlocProvider الخاص بها داخل الـ body
                      body: BlocProvider(
                        create: (context) =>
                            getIt<SalaryCubit>()..getSalaryDetails(salary.id),
                        child: SalaryDetailsScreen(salaryId: salary.id),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 4),
              // زر الطباعة (اختياري مستقبلاً)
              _buildActionButton(
                Icons.description_outlined,
                AppColors.textSecondary,
                () {
                  // كود الطباعة مستقبلاً
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    String text;
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'pending':
        text = 'قيد الانتظار';
        bgColor = AppColors.warningLight;
        textColor = AppColors.warning;
        break;
      case 'approved':
        text = 'معتمد';
        bgColor = AppColors.successLight;
        textColor = AppColors.success;
        break;
      case 'delivered':
        text = 'تم التسليم';
        bgColor = AppColors.infoLight;
        textColor = AppColors.info;
        break;
      case 'rejected':
        text = 'مرفوض';
        bgColor = AppColors.errorLight;
        textColor = AppColors.error;
        break;
      default:
        text = status;
        bgColor = AppColors.textField;
        textColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderColor),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
