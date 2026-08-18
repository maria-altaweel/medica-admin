import 'package:flutter/material.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';
import 'package:medica_admin/features/salaries/data/models/salary_model.dart';

class SalaryPaymentsList extends StatelessWidget {
  final List<SalaryPaymentModel>? payments;

  const SalaryPaymentsList({super.key, required this.payments});

  @override
  Widget build(BuildContext context) {
    if (payments == null || payments!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: const Text(
          'لا توجد دفعات مسجلة لهذه الفترة',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: payments!.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final payment = payments![index];
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.lightPrimary,
              child: Icon(Icons.receipt, color: AppColors.primary, size: 20),
            ),
            title: Text(
              'رقم الدفعة: #${payment.id} - الطريقة: ${payment.paymentMethod}',
            ),
            subtitle: Text('تاريخ الدفع: ${payment.paidAt ?? 'غير محدد'}'),
            trailing: Text(
              '${payment.amount} ل.س',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.success,
                fontSize: 16,
              ),
            ),
          );
        },
      ),
    );
  }
}
