import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';
import 'package:medica_admin/core/helpers/AppsnackBar.dart';
import 'package:medica_admin/core/widgets/App_Loadingindicator.dart';
import 'package:medica_admin/features/salaries/UI/widget/salary_breakdown_card.dart';
import 'package:medica_admin/features/salaries/UI/widget/salary_financials_card.dart';
import 'package:medica_admin/features/salaries/UI/widget/salary_header_card.dart';
import 'package:medica_admin/features/salaries/UI/widget/salary_payments_list.dart';
import 'package:medica_admin/features/salaries/data/models/salary_model.dart';
import 'package:medica_admin/features/salaries/logic/salary_cubit/salary_cubit.dart';
import 'package:medica_admin/features/salaries/logic/salary_cubit/salary_state.dart';

class SalaryDetailsScreen extends StatefulWidget {
  final int salaryId;

  const SalaryDetailsScreen({super.key, required this.salaryId});

  @override
  State<SalaryDetailsScreen> createState() => _SalaryDetailsScreenState();
}

class _SalaryDetailsScreenState extends State<SalaryDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SalaryCubit>().getSalaryDetails(widget.salaryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: const Text(
          'تفاصيل الراتب',
          style: TextStyle(
            color: AppColors.darkHeader,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.darkHeader),
      ),
      body: BlocConsumer<SalaryCubit, SalaryState>(
        listener: (context, state) {
          if (state is ApproveSalarySuccess) {
            Appsnackbar.showSuccess(context, 'تم اعتماد الراتب بنجاح');
            // إعادة جلب التفاصيل فوراً لتحديث الحالة والواجهة
            context.read<SalaryCubit>().getSalaryDetails(widget.salaryId);
          } else if (state is ApproveSalaryError) {
            Appsnackbar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          // 1. حالات التحميل (سواء عند فتح الصفحة أو عند الضغط على اعتماد)
          if (state is GetSalaryDetailsLoading ||
              state is ApproveSalaryLoading) {
            return const Center(child: AppLoadingIndicator());
          }
          // 2. حالة الخطأ
          else if (state is GetSalaryDetailsError) {
            return Center(
              child: Text(
                'حدث خطأ: ${state.message}',
                style: const TextStyle(color: AppColors.error, fontSize: 16),
              ),
            );
          }

          SalaryPayoutModel? salary;

          if (state is GetSalaryDetailsSuccess) {
            salary = state.salaryDetails;
          } else {
            try {
              salary = context.read<SalaryCubit>().salariesList.firstWhere(
                (element) => element.id == widget.salaryId,
              );
            } catch (_) {
              salary = null;
            }
          }

          if (salary == null) {
            return const Center(child: Text('جاري تحميل البيانات...'));
          }

          // 4. عرض المحتوى بشكل كامل وثابت
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SalaryHeaderCard(salary: salary),
                const SizedBox(height: 20),
                SalaryFinancialsCard(financials: salary.financials),
                const SizedBox(height: 20),
                if (salary.breakdown != null) ...[
                  const Text(
                    'توزيع طرق الدفع',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkHeader,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SalaryBreakdownCard(breakdown: salary.breakdown!),
                  const SizedBox(height: 24),
                ],
                const Text(
                  'قائمة المرضى والدفعات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkHeader,
                  ),
                ),
                const SizedBox(height: 12),
                SalaryPaymentsList(payments: salary.payments),
              ],
            ),
          );
        },
      ),
    );
  }
}
