import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/app_colors.dart';
import 'package:medica_admin/core/widgets/App_Loadingindicator.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_bloc.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_event.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_state.dart';

class ClinicDoctorsDialog extends StatefulWidget {
  final int clinicId;
  final int specializationId;
  final String specializationName;
  final String clinicName;

  const ClinicDoctorsDialog({
    super.key,
    required this.clinicId,
    required this.specializationId,
    required this.specializationName,
    required this.clinicName,
  });

  @override
  State<ClinicDoctorsDialog> createState() => _ClinicDoctorsDialogState();
}

class _ClinicDoctorsDialogState extends State<ClinicDoctorsDialog> {
  @override
  void initState() {
    super.initState();
    // جلب أطباء هذا التخصص للعيادة الحالية
    context.read<ClinicsBloc>().add(
      FetchClinicDoctorsEvent(
        clinicId: widget.clinicId,
        specializationId: widget.specializationId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1️⃣ الهيدر (أطباء تخصص...)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textTertiary),
                ),
                Text(
                  'أطباء تخصص ${widget.specializationName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkHeader,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                widget.clinicName,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // 2️⃣ قائمة الأطباء مع حالة التحميل
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 380),
              child: BlocBuilder<ClinicsBloc, ClinicsState>(
                builder: (context, state) {
                  if (state is ClinicsLoadingState) {
                    return const Center(child: AppLoadingIndicator(size: 40));
                  } else if (state is ClinicDoctorsSuccessState) {
                    if (state.doctors.isEmpty) {
                      return const Center(
                        child: Text(
                          'لا يوجد أطباء متاحة حالياً لهذا التخصص',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: state.doctors.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final doctor = state.doctors[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: Row(
                            children: [
                              // صورة الطبيب
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.lightPrimary,
                                backgroundImage: doctor.profile != null
                                    ? NetworkImage(doctor.profile!)
                                    : null,
                                child: doctor.profile == null
                                    ? const Icon(
                                        Icons.person,
                                        color: AppColors.primary,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),

                              // معلومات الطبيب
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doctor.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      doctor.specialization,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // التقييم وسعر الكشفية
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${doctor.rating}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.star,
                                        size: 14,
                                        color: AppColors.star,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  if (doctor.consultationFee != null)
                                    Text(
                                      '${doctor.consultationFee} ل.س',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else if (state is ClinicsErrorState) {
                    return Center(
                      child: Text(
                        state.errorMessage,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            const SizedBox(height: 20),

            // 3️⃣ زر الإغلاق
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: AppColors.textField,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'إغلاق',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
