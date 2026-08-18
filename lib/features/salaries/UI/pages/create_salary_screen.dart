import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medica_admin/core/helpers/AppsnackBar.dart';
import 'package:medica_admin/core/helpers/app_colors.dart';
import 'package:medica_admin/core/networking/service_locator.dart';
import 'package:medica_admin/features/clinics/data/models/clinic_model.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_bloc.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_event.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_state.dart';
import 'package:medica_admin/features/doctors/ui/widgets/select_clinic_dialog.dart';

import 'package:medica_admin/features/salaries/logic/salary_cubit/salary_cubit.dart';
import 'package:medica_admin/features/salaries/logic/salary_cubit/salary_state.dart';

class CreateSalaryScreen extends StatefulWidget {
  final int? initialClinicId;

  const CreateSalaryScreen({super.key, this.initialClinicId});

  @override
  State<CreateSalaryScreen> createState() => _CreateSalaryScreenState();
}

class _CreateSalaryScreenState extends State<CreateSalaryScreen> {
  int? selectedClinicId;
  String? selectedClinicName;
  DateTime? startDate;
  DateTime? endDate;
  List<ClinicModel> cachedClinics = [];

  @override
  void initState() {
    super.initState();
    selectedClinicId = widget.initialClinicId;
  }

  String _getArabicErrorMessage(String error) {
    if (error.contains('SocketException') || error.contains('network')) {
      return "لا يوجد اتصال بالإنترنت.";
    }
    if (error.contains('No salaries')) {
      return "لا توجد رواتب قابلة للتوليد في هذه الفترة.";
    }
    return "فشل إنشاء الرواتب، يرجى المحاولة مرة أخرى.";
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? startDate : endDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  void _openSelectClinicDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (_) => BlocProvider(
        create: (context) => getIt<ClinicsBloc>()..add(FetchClinicsEvent()),
        child: SelectClinicDialog(
          clinics: cachedClinics,
          selectedClinic: selectedClinicId != null && cachedClinics.isNotEmpty
              ? cachedClinics.firstWhere(
                  (c) => c.id == selectedClinicId,
                  orElse: () => cachedClinics.first,
                )
              : null,
          onClinicSelected: (clinic) {
            setState(() {
              selectedClinicId = clinic.id;
              selectedClinicName = clinic.name;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // نستخدم BlocProvider لتوفير الـ SalaryCubit للصفحة
    return BlocProvider(
      create: (context) => getIt<SalaryCubit>(),
      child: BlocProvider(
        create: (context) => getIt<ClinicsBloc>()..add(FetchClinicsEvent()),
        child: BlocListener<ClinicsBloc, ClinicsState>(
          listener: (context, state) {
            if (state is ClinicsSuccessState) {
              setState(() {
                cachedClinics = state.clinics;
                if (selectedClinicId == null && cachedClinics.isNotEmpty) {
                  selectedClinicId = cachedClinics.first.id;
                  selectedClinicName = cachedClinics.first.name;
                } else if (selectedClinicId != null &&
                    cachedClinics.isNotEmpty) {
                  final clinic = cachedClinics.firstWhere(
                    (c) => c.id == selectedClinicId,
                    orElse: () => cachedClinics.first,
                  );
                  selectedClinicName = clinic.name;
                }
              });
            }
          },
          child: BlocConsumer<SalaryCubit, SalaryState>(
            listener: (context, state) {
              if (state is GenerateSalariesSuccess) {
                Appsnackbar.showSuccess(context, "تم إنشاء الرواتب بنجاح");
              } else if (state is GenerateSalariesError) {
                print(state.message);
                Appsnackbar.showError(
                  context,
                  _getArabicErrorMessage(state.message),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is GenerateSalariesLoading;

              return Scaffold(
                backgroundColor: AppColors.scaffoldBackground,
                body: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "إنشاء رواتب",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Container(
                            width: 600, // يمكنك التحكم بالعرض من هنا
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // العيادة
                                const Text(
                                  "العيادة *",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: isLoading
                                      ? null
                                      : () => _openSelectClinicDialog(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.textField,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.borderColor,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          selectedClinicName ??
                                              "اختر العيادة...",
                                          style: TextStyle(
                                            color: selectedClinicName != null
                                                ? AppColors.textPrimary
                                                : Colors.grey,
                                          ),
                                        ),
                                        const Icon(Icons.arrow_drop_down),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // تاريخ البداية
                                const Text(
                                  "تاريخ بداية الفترة *",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: isLoading
                                      ? null
                                      : () => _pickDate(context, true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.textField,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.borderColor,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          startDate != null
                                              ? DateFormat(
                                                  'yyyy-MM-dd',
                                                ).format(startDate!)
                                              : "اختر تاريخ البداية...",
                                          style: TextStyle(
                                            color: startDate != null
                                                ? AppColors.textPrimary
                                                : Colors.grey,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // تاريخ النهاية
                                const Text(
                                  "تاريخ نهاية الفترة *",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: isLoading
                                      ? null
                                      : () => _pickDate(context, false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.textField,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.borderColor,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          endDate != null
                                              ? DateFormat(
                                                  'yyyy-MM-dd',
                                                ).format(endDate!)
                                              : "اختر تاريخ النهاية...",
                                          style: TextStyle(
                                            color: endDate != null
                                                ? AppColors.textPrimary
                                                : Colors.grey,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                Center(
                                  child: SizedBox(
                                    width: 200,
                                    child: ElevatedButton(
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                              // التحقق (Validation)
                                              if (selectedClinicId == null) {
                                                Appsnackbar.showError(
                                                  context,
                                                  "يرجى اختيار العيادة أولاً",
                                                );
                                                return;
                                              }
                                              if (startDate == null ||
                                                  endDate == null) {
                                                Appsnackbar.showError(
                                                  context,
                                                  "يرجى تحديد فترة زمنية كاملة (بداية ونهاية)",
                                                );
                                                return;
                                              }
                                              // استدعاء الكيوبت
                                              context
                                                  .read<SalaryCubit>()
                                                  .generateSalaries(
                                                    clinicId: selectedClinicId!,
                                                    periodStart: DateFormat(
                                                      'yyyy-MM-dd',
                                                    ).format(startDate!),
                                                    periodEnd: DateFormat(
                                                      'yyyy-MM-dd',
                                                    ).format(endDate!),
                                                  );
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text(
                                              "إنشاء الرواتب",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
