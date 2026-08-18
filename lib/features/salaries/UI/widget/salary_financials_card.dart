import 'package:flutter/material.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';
import 'package:medica_admin/features/salaries/data/models/salary_model.dart';

class SalaryFinancialsCard extends StatelessWidget {
  final SalaryFinancialsModel financials;

  const SalaryFinancialsCard({super.key, required this.financials});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildSummaryCard(
          'إجمالي الإيرادات',
          '${financials.revenue ?? 0} ل.س',
          Icons.attach_money,
          AppColors.info,
        ),
        const SizedBox(width: 16),
        _buildSummaryCard(
          'النسبة',
          '${financials.salaryPercentage}%',
          Icons.percent,
          AppColors.edit,
        ),
        const SizedBox(width: 16),
        _buildSummaryCard(
          'حصة الطبيب',
          '${financials.doctorShare} ل.س',
          Icons.medical_services,
          AppColors.success,
        ),
        const SizedBox(width: 16),
        _buildSummaryCard(
          'الفترة',
          '${financials.periodStart ?? ''}\nإلى ${financials.periodEnd ?? ''}',
          Icons.date_range,
          AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
