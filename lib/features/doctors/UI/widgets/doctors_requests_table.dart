import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';

import 'package:medica_admin/features/doctors/data/models/doctor_model.dart';
import 'package:medica_admin/features/doctors/logic/doctor_cubit/doctor_cubit.dart';
import 'package:medica_admin/features/doctors/logic/doctor_cubit/doctor_state.dart';

class DoctorRequestsTable extends StatelessWidget {
  final int clinicId;
  final String searchQuery;

  const DoctorRequestsTable({
    super.key,
    required this.clinicId,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DoctorCubit, DoctorState>(
      listener: (context, state) {
        if (state is ActionDoctorRequestSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is GetDoctorRequestsLoadingState) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        // فلترة طلبات الانضمام المعلقة
        final requests = context.read<DoctorCubit>().requestsList.where((doc) {
          return doc.doctorName.contains(searchQuery) ||
              doc.specialization.contains(searchQuery);
        }).toList();

        if (requests.isEmpty) {
          return const Center(
            child: Text(
              'لا توجد طلبات انضمام معلقة حالياً',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Column(
            children: [
              // الهيدر
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  border: Border(
                    bottom: BorderSide(color: AppColors.borderColor),
                  ),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        '#',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkHeader,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'الطبيب',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkHeader,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'التخصص',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkHeader,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'الهاتف',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkHeader,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'رسوم المعاينة',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkHeader,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: Text(
                        'الإجراءات',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkHeader,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // الأسطر
              Expanded(
                child: ListView.separated(
                  itemCount: requests.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.borderColor),
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),

                          // الطبيب وصورته
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.lightPrimary,
                                  backgroundImage:
                                      request.profile != null &&
                                          request.profile!.isNotEmpty
                                      ? NetworkImage(request.profile!)
                                      : null,
                                  child:
                                      request.profile == null ||
                                          request.profile!.isEmpty
                                      ? const Icon(
                                          Icons.person,
                                          color: AppColors.primary,
                                          size: 20,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  request.doctorName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                            flex: 2,
                            child: Text(
                              request.specialization,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              request.doctorPhone,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '\$ ${request.consultationFee}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          // أزرار قبول ورفض (مطابقة تماماً للـ UI بالأعلى)
                          SizedBox(
                            width: 180,
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.success,
                                      side: const BorderSide(
                                        color: AppColors.success,
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                    onPressed: () => _showConfirmDialog(
                                      context,
                                      doctor: request,
                                      isAccept: true,
                                    ),
                                    child: const Text('قبول'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.error,
                                      side: const BorderSide(
                                        color: AppColors.error,
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                    onPressed: () => _showConfirmDialog(
                                      context,
                                      doctor: request,
                                      isAccept: false,
                                    ),
                                    child: const Text('رفض'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConfirmDialog(
    BuildContext context, {
    required DoctorModel doctor,
    required bool isAccept,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isAccept ? 'قبول طلب الانضمام' : 'رفض طلب الانضمام'),
        content: Text(
          isAccept
              ? 'هل أنت تأكد من قبول طلب انضمام د. ${doctor.doctorName}؟'
              : 'هل أنت تأكد من رفض طلب انضمام د. ${doctor.doctorName}؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isAccept ? AppColors.success : AppColors.error,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              if (isAccept) {
                context.read<DoctorCubit>().acceptRequest(
                  clinicId: clinicId,
                  clinicDoctorId: doctor.id,
                );
              } else {
                context.read<DoctorCubit>().rejectRequest(
                  clinicId: clinicId,
                  clinicDoctorId: doctor.id,
                );
              }
            },
            child: Text(
              isAccept ? 'قبول' : 'رفض',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
