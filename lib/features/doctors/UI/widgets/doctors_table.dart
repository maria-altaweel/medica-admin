import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';
import 'package:medica_admin/features/doctors/UI/widgets/doctor_details_dialog.dart';
import 'package:medica_admin/features/doctors/UI/widgets/edit_doctor_dialog.dart';
import 'package:medica_admin/features/doctors/data/models/doctor_model.dart';
import 'package:medica_admin/features/doctors/logic/doctor_cubit/doctor_cubit.dart';
import 'package:medica_admin/features/doctors/logic/doctor_cubit/doctor_state.dart';

class DoctorsTable extends StatelessWidget {
  final int clinicId;
  final String searchQuery;

  const DoctorsTable({
    super.key,
    required this.clinicId,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DoctorCubit, DoctorState>(
      listener: (context, state) {
        if (state is RemoveDoctorSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
        }
        if (state is UpdateDoctorSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is GetDoctorsLoadingState) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        // فلترة القائمة حسب البحث في الاسم أو التخصص
        final doctors = context.read<DoctorCubit>().doctorsList.where((doc) {
          final nameMatches = doc.doctorName.contains(searchQuery);
          final specMatches = doc.specialization.contains(searchQuery);
          return nameMatches || specMatches;
        }).toList();

        if (doctors.isEmpty) {
          return const Center(
            child: Text(
              'لا يوجد أطباء في هذه العيادة حالياً',
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
              // الهيدر الخاص بالجدول
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
                      flex: 1,
                      child: Text(
                        'متاح',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkHeader,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'نسبة الراتب',
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
                      width: 140,
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
              // الأسطر الخاصة بالأطباء
              Expanded(
                child: ListView.separated(
                  itemCount: doctors.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.borderColor),
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
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

                          // اسم الطبيب وصورته (profile)
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.lightPrimary,
                                  backgroundImage:
                                      doctor.profile != null &&
                                          doctor.profile!.isNotEmpty
                                      ? NetworkImage(doctor.profile!)
                                      : null,
                                  child:
                                      doctor.profile == null ||
                                          doctor.profile!.isEmpty
                                      ? const Icon(
                                          Icons.person,
                                          color: AppColors.primary,
                                          size: 20,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  doctor.doctorName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // التخصص والهاتف
                          Expanded(
                            flex: 2,
                            child: Text(
                              doctor.specialization,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              doctor.doctorPhone,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),

                          // التوفر Switch
                          Expanded(
                            flex: 1,
                            child: Switch(
                              value: doctor.isAvailable,
                              activeColor: AppColors.success,
                              onChanged: (val) {
                                context.read<DoctorCubit>().updateDoctor(
                                  clinicId: clinicId,
                                  clinicDoctorId: doctor.id,
                                  isAvailable: val,
                                );
                              },
                            ),
                          ),

                          // النسبة والكشفية
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${doctor.salaryPercentage ?? 0} %',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '\$ ${doctor.consultationFee}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          // أزرار الإجراءات (تفاصيل، تعديل، حذف)
                          SizedBox(
                            width: 140,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // 👁️ زر تفاصيل الطبيب
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_red_eye_outlined,
                                    color: AppColors.info,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => DoctorDetailsDialog(
                                        doctor: doctor,
                                        clinicId: clinicId,
                                      ),
                                    );
                                  },
                                ),
                                // ✏️ زر تعديل بيانات الطبيب
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: AppColors.edit,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => EditDoctorDialog(
                                        doctor: doctor,
                                        clinicId: clinicId,
                                      ),
                                    );
                                  },
                                ),
                                // 🗑️ زر حذف الطبيب
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      _confirmDelete(context, doctor),
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

  void _confirmDelete(BuildContext context, DoctorModel doctor) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف الطبيب'),
        content: Text(
          'هل أنت تأكد من إزالة الطبيب ${doctor.doctorName} من العيادة؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<DoctorCubit>().removeDoctor(
                clinicId: clinicId,
                clinicDoctorId: doctor.id,
              );
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
