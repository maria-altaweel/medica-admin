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
            Appsnackbar.showError(context, state.error);
          }
        },
        builder: (context, state) {
          if (state is LeavesLoading) {
            return const Center(child: AppLoadingIndicator());
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
            return const Center(
              child: Text(
                'لا توجد طلبات إجازة مطابقة',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
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
                            color: AppColors.info,
                          ),
                          onPressed: () => onLeaveSelected(leave),
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
