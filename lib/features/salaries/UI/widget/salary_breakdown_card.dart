import 'package:flutter/material.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';
import 'package:medica_admin/features/salaries/data/models/salary_model.dart';

class SalaryBreakdownCard extends StatelessWidget {
  final SalaryBreakdownModel breakdown;

  const SalaryBreakdownCard({super.key, required this.breakdown});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildCard(
          'كاش',
          '${breakdown.cash} ل.س',
          Icons.money,
          AppColors.success,
        ),
        const SizedBox(width: 16),
        _buildCard('نقاط', '${breakdown.points}', Icons.star, AppColors.star),
        const SizedBox(width: 16),
        _buildCard(
          'إلكتروني',
          '${breakdown.onlinePayment} ل.س',
          Icons.payment,
          AppColors.info,
        ),
        const SizedBox(width: 16),
        _buildCard(
          'بطاقة ائتمان',
          '${breakdown.creditCard} ل.س',
          Icons.credit_card,
          AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildCard(String title, String value, IconData icon, Color color) {
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
