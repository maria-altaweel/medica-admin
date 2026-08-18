import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';
import 'package:medica_admin/features/clinics/data/models/clinic_model.dart';
import 'package:medica_admin/features/leaves/UI/widgets/leave_status_badge.dart';
import 'package:medica_admin/features/leaves/data/models/leave_model.dart';

import 'package:medica_admin/features/leaves/logic/leave_cubit/leave_cubit.dart';

class LeaveRequestDetailsPanel extends StatelessWidget {
  final LeaveModel? selectedLeave;
  final ClinicModel currentClinic;

  const LeaveRequestDetailsPanel({
    super.key,
    required this.selectedLeave,
    required this.currentClinic,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedLeave == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        alignment: Alignment.center,
        child: const Text(
          'الرجاء تحديد طلب إجازة من الجدول لعرض التفاصيل واتخاذ الإجراء',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final leave = selectedLeave!;
    final bool isPending = leave.status?.toLowerCase() == 'pending';

    return SingleChildScrollView(
      child: Column(
        children: [
          // تفاصيل الطلب
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'تفاصيل طلب الإجازة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkHeader,
                  ),
                ),
                const Divider(height: 24),
                _detailRow('رقم الطلب', '#${leave.id}'),
                _detailRow('اسم الطبيب', leave.doctorName ?? '-'),
                _detailRow('التخصص', leave.specialization ?? '-'),
                _detailRow('تاريخ الإجازة', leave.unavailableDate ?? '-'),
                _detailRow('السبب', leave.reason ?? '-'),
                _detailRow('تاريخ الإنشاء', leave.createdAt ?? '-'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // كرت الإجراءات (اعتماد / رفض)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'إجراءات الطلب',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkHeader,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'الحالة الحالية: ',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    LeaveStatusBadge(status: leave.status),
                  ],
                ),
                const SizedBox(height: 16),
                if (isPending) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        context.read<LeaveCubit>().approveLeave(
                          clinicId: currentClinic.id,
                          id: leave.id,
                          onSuccess: () {},
                        );
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('اعتماد الطلب'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        context.read<LeaveCubit>().rejectLeave(
                          clinicId: currentClinic.id,
                          id: leave.id,
                          onSuccess: () {},
                        );
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('رفض الطلب'),
                    ),
                  ),
                ] else ...[
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'تمت معالجة هذا الطلب مسبقاً',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
