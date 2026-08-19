import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';
import 'package:medica_admin/core/helpers/AppsnackBar.dart';
import 'package:medica_admin/core/widgets/App_Loadingindicator.dart';
import 'package:medica_admin/features/leaves/UI/widgets/leave_status_badge.dart';
import 'package:medica_admin/features/leaves/data/models/leave_model.dart';
import 'package:medica_admin/features/leaves/logic/leave_cubit/leave_cubit.dart';

class LeaveRequestsTableCard extends StatelessWidget {
  final String searchQuery;
  final LeaveModel? selectedLeave;
  final ValueChanged<LeaveModel> onLeaveSelected;
  final VoidCallback onRefreshNeeded;

  const LeaveRequestsTableCard({
    super.key,
    required this.searchQuery,
    required this.selectedLeave,
    required this.onLeaveSelected,
    required this.onRefreshNeeded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // لضمان أخذ العرض كاملاً
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: BlocConsumer<LeaveCubit, LeaveState>(
        listener: (context, state) {
          if (state is LeaveActionSuccess) {
            Appsnackbar.showSuccess(context, state.message);
            onRefreshNeeded();
          } else if (state is LeaveError) {
            // رسالة خطأ عربية في السناك بار أيضاً
            Appsnackbar.showError(
              context,
              'حدث خطأ أثناء تنفيذ الإجراء، يرجى المحاولة لاحقاً',
            );
          }
        },
        builder: (context, state) {
          // حالة التحميل
          if (state is LeavesLoading) {
            return const Padding(
              padding: EdgeInsets.all(40.0),
              child: Center(child: AppLoadingIndicator()),
            );
          }

          // 🔴 حالة حدوث خطأ في السيرفر (عرض شاشة خطأ واضحة مع زر إعادة تحميل)
          if (state is LeaveError) {
            return Padding(
              padding: const EdgeInsets.all(40.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 50,
                      color: Color(0xFFFF5252),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'عذراً، حدث خطأ في الاتصال بالسيرفر',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'تعذر جلب بيانات طلبات الإجازة، يرجى التحقق من الاتصال والمحاولة مرة أخرى.',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: onRefreshNeeded,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text(
                        'إعادة التحميل',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final leaves = state is LeavesLoaded ? state.leaves : <LeaveModel>[];

          // فلترة محلية سريعة للبحث النصي
          final filteredLeaves = leaves.where((leave) {
            final name = leave.doctorName?.toLowerCase() ?? '';
            final reason = leave.reason?.toLowerCase() ?? '';
            return name.contains(searchQuery.toLowerCase()) ||
                reason.contains(searchQuery.toLowerCase());
          }).toList();

          if (filteredLeaves.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(40.0),
              child: Center(
                child: Text(
                  'لا توجد طلبات إجازة مطابقة للبحث',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            );
          }

          // استخدام LayoutBuilder لجعل الجدول يملأ عرض الكارد بالكامل
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      AppColors.pageBackground,
                    ),
                    columns: const [
                      DataColumn(label: Text('#')),
                      DataColumn(label: Text('الطبيب')),
                      DataColumn(label: Text('تاريخ الإجازة')),
                      DataColumn(label: Text('السبب')),
                      DataColumn(label: Text('الحالة')),
                      DataColumn(label: Text('تاريخ الطلب')),
                      DataColumn(label: Text('الإجراءات')),
                    ],
                    rows: filteredLeaves.map((leave) {
                      return DataRow(
                        selected: selectedLeave?.id == leave.id,
                        cells: [
                          DataCell(Text('${leave.id}')),
                          DataCell(Text(leave.doctorName ?? '-')),
                          DataCell(Text(leave.unavailableDate ?? '-')),
                          DataCell(Text(leave.reason ?? '-')),
                          DataCell(LeaveStatusBadge(status: leave.status)),
                          DataCell(Text(leave.createdAt ?? '-')),
                          DataCell(
                            IconButton(
                              icon: const Icon(
                                Icons.visibility,
                                color: Color(0xFF2196F3),
                              ),
                              onPressed: () => onLeaveSelected(leave),
                              tooltip: 'عرض التفاصيل',
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
