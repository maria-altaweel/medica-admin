import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';
import 'package:medica_admin/core/helpers/AppsnackBar.dart';
import 'package:medica_admin/features/doctors/data/models/doctor_model.dart';
import 'package:medica_admin/features/doctors/logic/doctor_cubit/doctor_cubit.dart';
import 'package:medica_admin/features/doctors/logic/doctor_cubit/doctor_state.dart';

class EditDoctorDialog extends StatefulWidget {
  final DoctorModel doctor;
  final int clinicId;

  const EditDoctorDialog({
    super.key,
    required this.doctor,
    required this.clinicId,
  });

  @override
  State<EditDoctorDialog> createState() => _EditDoctorDialogState();
}

class _EditDoctorDialogState extends State<EditDoctorDialog> {
  late TextEditingController feeController;
  late TextEditingController percentageController;
  late bool isAvailable;

  @override
  void initState() {
    super.initState();
    feeController = TextEditingController(
      text: widget.doctor.consultationFee.toString(),
    );
    percentageController = TextEditingController(
      text: (widget.doctor.salaryPercentage ?? 0).toString(),
    );
    isAvailable = widget.doctor.isAvailable;
  }

  @override
  void dispose() {
    feeController.dispose();
    percentageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DoctorCubit, DoctorState>(
      listener: (context, state) {
        if (state is UpdateDoctorSuccessState) {
          // ✅ عند النجاح فقط: نعرض رسالة النجاح ونغلق النافذة
          Appsnackbar.showSuccess(context, "تم تعديل بيانات الطبيب بنجاح");
          Navigator.pop(context);
        } else if (state is UpdateDoctorErrorState) {
          // ❌ عند أي خطأ: نعرض رسالة الخطأ بوضوح وتبقى النافذة مفتوحة لتصحيح أو إعادة المحاولة
          Appsnackbar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is UpdateDoctorLoadingState;

        return Dialog(
          backgroundColor: AppColors.scaffoldBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 440,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'تعديل بيانات الطبيب',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkHeader,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textTertiary,
                      ),
                      onPressed: isLoading
                          ? null
                          : () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // حقل رسوم المعاينة
                const Text(
                  'رسوم المعاينة *',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: feeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.textField,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.borderColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // مفتاح التوفر
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'متاح',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Switch(
                      value: isAvailable,
                      activeColor: AppColors.success,
                      onChanged: isLoading
                          ? null
                          : (val) {
                              setState(() {
                                isAvailable = val;
                              });
                            },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // حقل نسبة الراتب
                const Text(
                  'نسبة الراتب (%) *',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: percentageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.textField,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.borderColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // الأزرار
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () {
                                if (feeController.text.trim().isEmpty) {
                                  Appsnackbar.showError(
                                    context,
                                    'يرجى إدخال رسوم المعاينة',
                                  );
                                  return;
                                }
                                if (percentageController.text.trim().isEmpty) {
                                  Appsnackbar.showError(
                                    context,
                                    'يرجى إدخال نسبة الراتب',
                                  );
                                  return;
                                }

                                final fee =
                                    num.tryParse(feeController.text) ??
                                    widget.doctor.consultationFee;
                                final percentage =
                                    num.tryParse(percentageController.text) ??
                                    (widget.doctor.salaryPercentage ?? 0);
                                context.read<DoctorCubit>().updateDoctor(
                                  clinicId: widget.clinicId,
                                  clinicDoctorId: widget.doctor.id,
                                  consultationFee: fee,
                                  salaryPercentage: percentage,
                                  isAvailable: isAvailable,
                                );
                              },
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'حفظ التعديلات',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
