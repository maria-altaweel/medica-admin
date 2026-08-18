import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';
import 'package:medica_admin/features/salaries/data/models/salary_model.dart';
import 'package:medica_admin/features/salaries/logic/salary_cubit/salary_cubit.dart';

class SalaryHeaderCard extends StatelessWidget {
  final SalaryPayoutModel salary;

  const SalaryHeaderCard({super.key, required this.salary});

  @override
  Widget build(BuildContext context) {
    bool isApproved = salary.financials.status == 'approved';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // إذا كانت الشاشة ضيقة، نعرض العناصر بشكل عمودي لضمان عدم حدوث Overflow
          bool isSmallScreen = constraints.maxWidth < 650;

          if (isSmallScreen) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDoctorInfoRow(),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFE2E8F0), height: 1),
                const SizedBox(height: 16),
                _buildActionSection(context, isApproved),
              ],
            );
          }

          // إذا كانت الشاشة واسعة، نعرضها جنباً إلى جنب كما في التصميم الأصلي
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildDoctorInfoRow()),
              const SizedBox(width: 16),
              _buildActionSection(context, isApproved),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDoctorInfoRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.lightPrimary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.person, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                salary.doctor.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'العيادة: ${salary.clinic.name} | التخصص: ${salary.doctor.specialization ?? 'عام'}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection(BuildContext context, bool isApproved) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isApproved ? AppColors.successLight : AppColors.warningLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isApproved ? 'معتمد' : 'قيد الانتظار',
            style: TextStyle(
              color: isApproved ? AppColors.success : AppColors.warning,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (!isApproved)
          ElevatedButton.icon(
            onPressed: () => _showApprovalDialog(context, salary.id),
            icon: const Icon(Icons.check, color: Colors.white, size: 16),
            label: const Text(
              'اعتماد الراتب',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
      ],
    );
  }

  void _showApprovalDialog(BuildContext context, int salaryId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'تأكيد الاعتماد',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'هل أنت متأكد من رغبتك في اعتماد هذا الراتب؟ لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<SalaryCubit>().approveSalary(salaryId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'تأكيد الاعتماد',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
