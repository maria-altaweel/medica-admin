import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';
import 'package:medica_admin/core/helpers/AppsnackBar.dart';
import 'package:medica_admin/core/networking/service_locator.dart';
import 'package:medica_admin/core/widgets/App_Loadingindicator.dart';
import 'package:medica_admin/features/doctors/UI/widgets/doctor_details_dialog.dart';
import 'package:medica_admin/features/doctors/UI/widgets/edit_doctor_dialog.dart';
import 'package:medica_admin/features/doctors/data/models/doctor_model.dart';
import 'package:medica_admin/features/doctors/data/repos/doctor_repo.dart';
import 'package:medica_admin/features/doctors/logic/doctor_cubit/doctor_cubit.dart';
import 'package:medica_admin/features/doctors/logic/doctor_cubit/doctor_state.dart';

class DoctorsTable extends StatelessWidget {
  final int clinicId;

  const DoctorsTable({super.key, required this.clinicId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DoctorCubit, DoctorState>(
      listener: (context, state) {
        if (state is GetDoctorsErrorState) {
          Appsnackbar.showError(context, state.message);
        } else if (state is RemoveDoctorErrorState) {
          Appsnackbar.showError(context, state.message);
        } else if (state is UpdateDoctorErrorState) {
          Appsnackbar.showError(context, state.message);
        }

        if (state is RemoveDoctorSuccessState ||
            state is UpdateDoctorSuccessState) {
          final message = state is RemoveDoctorSuccessState
              ? state.message
              : (state as UpdateDoctorSuccessState).message;

          Appsnackbar.showSuccess(context, message);
        }
      },
      builder: (context, state) {
        if (state is GetDoctorsLoadingState) {
          return const Center(child: AppLoadingIndicator());
        }

        final cubit = context.read<DoctorCubit>();
        final doctors = cubit.doctorsList;

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
              _buildTableHeader(),
              Expanded(
                child: ListView.separated(
                  itemCount: doctors.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.borderColor),
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    return _buildDoctorRow(context, doctor, index);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(bottom: BorderSide(color: AppColors.borderColor)),
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
            width: 120,
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
    );
  }

  Widget _buildDoctorRow(BuildContext context, DoctorModel doctor, int index) {
    final hasProfile =
        doctor.profile != null && doctor.profile!.trim().isNotEmpty;

    // التقاط الـ Cubit بشكل آمن
    final doctorCubit = context.read<DoctorCubit>();

    // جلب الـ Repository باستخدام GetIt بناءً على طلبك السابق لضمان عدم حدوث مشاكل
    final doctorRepo = getIt<DoctorRepository>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '${index + 1}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.lightPrimary,
                  backgroundImage: hasProfile
                      ? NetworkImage(doctor.profile!)
                      : null,
                  child: !hasProfile
                      ? const Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 20,
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    doctor.doctorName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              doctor.specialization,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              doctor.doctorPhone,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 1,
            child: Switch(
              value: doctor.isAvailable,
              activeColor: AppColors.success,
              onChanged: (val) {
                doctorCubit.updateDoctor(
                  clinicId: clinicId,
                  clinicDoctorId: doctor.id,
                  isAvailable: val,
                );
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${doctor.salaryPercentage ?? 0} %',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '\$ ${doctor.consultationFee}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // زر التفاصيل مع تمرير الـ Repository بدون أي نقص
                IconButton(
                  icon: const Icon(
                    Icons.remove_red_eye_outlined,
                    color: AppColors.info,
                    size: 20,
                  ),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => BlocProvider.value(
                      value: doctorCubit,
                      child: DoctorDetailsDialog(
                        doctor: doctor,
                        clinicId: clinicId,
                        doctorRepository:
                            doctorRepo, // تم وضع الريبو هنا لإنهاء الخطأ
                      ),
                    ),
                  ),
                ),
                // زر التعديل
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.edit,
                    size: 20,
                  ),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => BlocProvider.value(
                      value: doctorCubit,
                      child: EditDoctorDialog(
                        doctor: doctor,
                        clinicId: clinicId,
                      ),
                    ),
                  ),
                ),
                // زر الحذف
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: 20,
                  ),
                  onPressed: () => _confirmDelete(context, doctorCubit, doctor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    DoctorCubit doctorCubit,
    DoctorModel doctor,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف الطبيب'),
        content: Text(
          'هل أنت متأكد من إزالة الطبيب ${doctor.doctorName} من العيادة؟',
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
              doctorCubit.removeDoctor(
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
